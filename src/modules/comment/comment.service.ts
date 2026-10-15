import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { TaskComment } from '../../entities/task-comment.entity';
import { Task } from '../../entities/task.entity';
import { CreateCommentDto, UpdateCommentDto } from './dto/comment.dto';

@Injectable()
export class CommentService {
  private readonly logger = new Logger(CommentService.name);

  constructor(
    @InjectRepository(TaskComment)
    private readonly commentRepository: Repository<TaskComment>,
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
  ) {}

  /**
   * Create a comment on a task
   */
  async create(
    orgId: string,
    userId: string,
    dto: CreateCommentDto,
  ): Promise<TaskComment> {
    // Verify task exists and belongs to org
    const task = await this.taskRepository.findOne({
      where: { id: dto.taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    // Verify parent comment exists if specified
    if (dto.parentCommentId) {
      const parentComment = await this.commentRepository.findOne({
        where: { id: dto.parentCommentId, taskId: dto.taskId },
      });

      if (!parentComment) {
        throw new NotFoundException('Parent comment not found');
      }
    }

    const comment = this.commentRepository.create({
      orgId,
      taskId: dto.taskId,
      userId,
      comment: dto.comment,
      parentCommentId: dto.parentCommentId,
    });

    const saved = await this.commentRepository.save(comment);
    this.logger.log(`Comment created on task ${dto.taskId} by user ${userId}`);

    // Reload with user relation so the response includes user name
    const withUser = await this.commentRepository.findOne({
      where: { id: saved.id },
      relations: ['user'],
    });

    return withUser ?? saved;
  }

  /**
   * Get all comments for a task (threaded)
   */
  async findByTask(orgId: string, taskId: string): Promise<TaskComment[]> {
    // Verify task exists and belongs to org
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    // Get top-level comments with user info
    const topLevelComments = await this.commentRepository.find({
      where: { taskId, parentCommentId: IsNull() },
      relations: ['user'],
      order: { createdAt: 'ASC' },
    });

    // Load replies recursively
    for (const comment of topLevelComments) {
      await this.loadReplies(comment);
    }

    return topLevelComments;
  }

  /**
   * Get comment by ID
   */
  async findOne(orgId: string, commentId: string): Promise<TaskComment> {
    const comment = await this.commentRepository
      .createQueryBuilder('comment')
      .innerJoin('task', 'task', 'task.id = comment.task_id')
      .leftJoinAndSelect('comment.user', 'user')
      .where('comment.id = :commentId', { commentId })
      .andWhere('task.org_id = :orgId', { orgId })
      .getOne();

    if (!comment) {
      throw new NotFoundException('Comment not found');
    }

    return comment;
  }

  /**
   * Update comment
   */
  async update(
    orgId: string,
    userId: string,
    commentId: string,
    dto: UpdateCommentDto,
  ): Promise<TaskComment> {
    const comment = await this.findOne(orgId, commentId);

    // Users can only edit their own comments
    if (comment.userId !== userId) {
      throw new ForbiddenException('You can only edit your own comments');
    }

    comment.comment = dto.comment;
    comment.updatedAt = new Date();

    const updated = await this.commentRepository.save(comment);
    this.logger.log(`Comment updated: ${commentId}`);

    return updated;
  }

  /**
   * Delete comment
   */
  async remove(
    orgId: string,
    userId: string,
    userRole: string,
    commentId: string,
  ): Promise<void> {
    const comment = await this.findOne(orgId, commentId);

    // Users can delete their own comments, ORG_ADMIN can delete any
    if (comment.userId !== userId && userRole !== 'ORG_ADMIN') {
      throw new ForbiddenException('You can only delete your own comments');
    }

    await this.commentRepository.remove(comment);
    this.logger.log(`Comment deleted: ${commentId}`);
  }

  /**
   * Load replies recursively for a comment
   */
  private async loadReplies(comment: TaskComment): Promise<void> {
    const replies = await this.commentRepository.find({
      where: { parentCommentId: comment.id },
      relations: ['user'],
      order: { createdAt: 'ASC' },
    });

    (comment as any).replies = replies;

    for (const reply of replies) {
      await this.loadReplies(reply);
    }
  }
}
