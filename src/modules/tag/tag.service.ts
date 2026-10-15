import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In, ILike } from 'typeorm';
import { Tag } from '../../entities/tag.entity';
import { Task } from '../../entities/task.entity';
import {
  CreateTagDto,
  UpdateTagDto,
  UpdateTagStatusDto,
  TagQueryDto,
} from './dto/tag.dto';

@Injectable()
export class TagService {
  constructor(
    @InjectRepository(Tag)
    private readonly tagRepository: Repository<Tag>,
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
  ) {}

  async create(orgId: string, createTagDto: CreateTagDto): Promise<Tag> {
    // Check for duplicate tag name within organization
    const existing = await this.tagRepository.findOne({
      where: {
        orgId,
        name: createTagDto.name,
      },
    });

    if (existing) {
      throw new ConflictException('Tag with this name already exists');
    }

    const tag = this.tagRepository.create({
      orgId,
      name: createTagDto.name,
      color: createTagDto.color,
      status: 'ACTIVE',
    });

    return this.tagRepository.save(tag);
  }

  async findAll(orgId: string, query: TagQueryDto): Promise<Tag[]> {
    const { status, search } = query;

    const queryBuilder = this.tagRepository
      .createQueryBuilder('tag')
      .where('tag.org_id = :orgId', { orgId });

    if (status) {
      queryBuilder.andWhere('tag.status = :status', { status });
    }

    if (search) {
      queryBuilder.andWhere('tag.name ILIKE :search', {
        search: `%${search}%`,
      });
    }

    return queryBuilder.orderBy('tag.name', 'ASC').getMany();
  }

  async findOne(orgId: string, id: string): Promise<Tag> {
    const tag = await this.tagRepository.findOne({
      where: { id, orgId },
    });

    if (!tag) {
      throw new NotFoundException('Tag not found');
    }

    return tag;
  }

  async findByIds(orgId: string, ids: string[]): Promise<Tag[]> {
    return this.tagRepository.find({
      where: {
        id: In(ids),
        orgId,
        status: 'ACTIVE',
      },
    });
  }

  async update(
    orgId: string,
    id: string,
    updateTagDto: UpdateTagDto,
  ): Promise<Tag> {
    const tag = await this.findOne(orgId, id);

    // Check for duplicate name if updating name
    if (updateTagDto.name && updateTagDto.name !== tag.name) {
      const existing = await this.tagRepository.findOne({
        where: {
          orgId,
          name: updateTagDto.name,
        },
      });

      if (existing) {
        throw new ConflictException('Tag with this name already exists');
      }
    }

    Object.assign(tag, updateTagDto);

    return this.tagRepository.save(tag);
  }

  async updateStatus(
    orgId: string,
    id: string,
    updateStatusDto: UpdateTagStatusDto,
  ): Promise<Tag> {
    const tag = await this.findOne(orgId, id);

    tag.status = updateStatusDto.status;

    return this.tagRepository.save(tag);
  }

  async remove(orgId: string, id: string): Promise<void> {
    const tag = await this.findOne(orgId, id);

    // Check if tag is used by any tasks (ManyToMany via task_tag_mapping)
    const taskCount = await this.taskRepository
      .createQueryBuilder('task')
      .innerJoin('task.tags', 'tag', 'tag.id = :tagId', { tagId: id })
      .where('task.org_id = :orgId', { orgId })
      .getCount();

    if (taskCount > 0) {
      throw new ConflictException(
        `Cannot delete tag: it is used by ${taskCount} task(s)`,
      );
    }

    await this.tagRepository.remove(tag);
  }

  async getTasksWithTag(orgId: string, tagId: string) {
    // Verify tag exists
    await this.findOne(orgId, tagId);

    return this.taskRepository
      .createQueryBuilder('task')
      .innerJoin('task.tags', 'tag', 'tag.id = :tagId', { tagId })
      .where('task.org_id = :orgId', { orgId })
      .leftJoinAndSelect('task.project', 'project')
      .leftJoinAndSelect('task.assignee', 'assignee')
      .orderBy('task.createdAt', 'DESC')
      .getMany();
  }

  /**
   * Ensure predefined semantic tags exist for an organization (Feature, Bug, Tech debt)
   * Creates them if they don't already exist
   */
  async ensurePredefinedTags(orgId: string): Promise<void> {
    const predefinedTags = [
      { name: 'Feature', color: '#21A1F1' },
      { name: 'Bug', color: '#F44235' },
      { name: 'Tech debt', color: '#FF9800' },
    ];

    for (const tagDef of predefinedTags) {
      const existing = await this.tagRepository.findOne({
        where: { orgId, name: tagDef.name },
      });

      if (!existing) {
        await this.tagRepository.save(
          this.tagRepository.create({
            orgId,
            name: tagDef.name,
            color: tagDef.color,
            status: 'ACTIVE',
          }),
        );
      }
    }
  }
}
