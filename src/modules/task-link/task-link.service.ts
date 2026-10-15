import {
  Injectable,
  Logger,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TaskLink } from '../../entities/task-link.entity';
import { Task } from '../../entities/task.entity';
import { CreateTaskLinkDto } from './dto/task-link.dto';

@Injectable()
export class TaskLinkService {
  private readonly logger = new Logger(TaskLinkService.name);

  constructor(
    @InjectRepository(TaskLink)
    private readonly taskLinkRepository: Repository<TaskLink>,
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
  ) {}

  /**
   * Create a link between two tasks
   */
  async create(
    orgId: string,
    userId: string,
    dto: CreateTaskLinkDto,
  ): Promise<TaskLink> {
    // Can't link task to itself
    if (dto.sourceTaskId === dto.targetTaskId) {
      throw new BadRequestException('Cannot link a task to itself');
    }

    // Verify both tasks exist and belong to org
    const [sourceTask, targetTask] = await Promise.all([
      this.taskRepository.findOne({
        where: { id: dto.sourceTaskId, orgId },
      }),
      this.taskRepository.findOne({
        where: { id: dto.targetTaskId, orgId },
      }),
    ]);

    if (!sourceTask) {
      throw new NotFoundException('Source task not found');
    }

    if (!targetTask) {
      throw new NotFoundException('Target task not found');
    }

    // Check for duplicate link
    const existingLink = await this.taskLinkRepository.findOne({
      where: {
        sourceTaskId: dto.sourceTaskId,
        targetTaskId: dto.targetTaskId,
        linkType: dto.linkType,
      },
    });

    if (existingLink) {
      throw new ConflictException('This link already exists');
    }

    const taskLink = this.taskLinkRepository.create({
      orgId,
      sourceTaskId: dto.sourceTaskId,
      targetTaskId: dto.targetTaskId,
      linkType: dto.linkType,
      createdBy: userId,
    });

    const saved = await this.taskLinkRepository.save(taskLink);
    this.logger.log(
      `Task link created: ${sourceTask.taskCode} ${dto.linkType} ${targetTask.taskCode}`,
    );

    return saved;
  }

  /**
   * Get all links for a task (both directions)
   */
  async findByTask(orgId: string, taskId: string): Promise<TaskLink[]> {
    // Verify task exists and belongs to org
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    // Get both outgoing and incoming links
    return this.taskLinkRepository.find({
      where: [
        { sourceTaskId: taskId, orgId },
        { targetTaskId: taskId, orgId },
      ],
      relations: ['sourceTask', 'targetTask'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get link by ID
   */
  async findOne(orgId: string, linkId: string): Promise<TaskLink> {
    const link = await this.taskLinkRepository.findOne({
      where: { id: linkId, orgId },
      relations: ['sourceTask', 'targetTask'],
    });

    if (!link) {
      throw new NotFoundException('Task link not found');
    }

    return link;
  }

  /**
   * Delete a task link
   */
  async remove(orgId: string, linkId: string): Promise<void> {
    const link = await this.findOne(orgId, linkId);
    await this.taskLinkRepository.remove(link);

    this.logger.log(`Task link deleted: ${linkId}`);
  }

  /**
   * Get blocking tasks (tasks that are blocking the given task)
   */
  async getBlockingTasks(orgId: string, taskId: string): Promise<Task[]> {
    const links = await this.taskLinkRepository.find({
      where: [
        { targetTaskId: taskId, linkType: 'BLOCKS', orgId },
        { sourceTaskId: taskId, linkType: 'BLOCKED_BY', orgId },
      ],
      relations: ['sourceTask', 'targetTask'],
    });

    const blockingTaskIds = links.map((link) =>
      link.linkType === 'BLOCKS' ? link.sourceTaskId : link.targetTaskId,
    );

    if (blockingTaskIds.length === 0) {
      return [];
    }

    return this.taskRepository
      .createQueryBuilder('task')
      .whereInIds(blockingTaskIds)
      .andWhere('task.org_id = :orgId', { orgId })
      .getMany();
  }

  /**
   * Get dependent tasks (tasks that depend on the given task)
   */
  async getDependentTasks(orgId: string, taskId: string): Promise<Task[]> {
    const links = await this.taskLinkRepository.find({
      where: [
        { sourceTaskId: taskId, linkType: 'BLOCKS', orgId },
        { targetTaskId: taskId, linkType: 'BLOCKED_BY', orgId },
      ],
      relations: ['sourceTask', 'targetTask'],
    });

    const dependentTaskIds = links.map((link) =>
      link.linkType === 'BLOCKS' ? link.targetTaskId : link.sourceTaskId,
    );

    if (dependentTaskIds.length === 0) {
      return [];
    }

    return this.taskRepository
      .createQueryBuilder('task')
      .whereInIds(dependentTaskIds)
      .andWhere('task.org_id = :orgId', { orgId })
      .getMany();
  }
}
