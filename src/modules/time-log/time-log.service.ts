import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource, Between, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { TimeLog } from '../../entities/time-log.entity';
import { UserDailySummary } from '../../entities/user-daily-summary.entity';
import { Task } from '../../entities/task.entity';
import { UserProjectMapping } from '../../entities/user-project-mapping.entity';
import {
  CreateTimeLogDto,
  UpdateTimeLogDto,
  TimeLogQueryDto,
} from './dto/time-log.dto';
import { StatusColor } from '../../common/enums';

@Injectable()
export class TimeLogService {
  private readonly logger = new Logger(TimeLogService.name);

  constructor(
    @InjectRepository(TimeLog)
    private readonly timeLogRepository: Repository<TimeLog>,
    @InjectRepository(UserDailySummary)
    private readonly dailySummaryRepository: Repository<UserDailySummary>,
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
    @InjectRepository(UserProjectMapping)
    private readonly userProjectMappingRepository: Repository<UserProjectMapping>,
    private readonly dataSource: DataSource,
  ) {}

  /**
   * Create a time log entry
   * Validates:
   * - No future dates
   * - Max 12 hours per day total
   * - User is assigned to project
   */
  async create(
    orgId: string,
    userId: string,
    dto: CreateTimeLogDto,
  ): Promise<TimeLog> {
    const logDate = new Date(dto.logDate);
    const today = new Date();
    today.setHours(23, 59, 59, 999);

    // Validate: No future dates
    if (logDate > today) {
      throw new BadRequestException('Cannot log time for future dates');
    }

    // Get task and verify it belongs to org
    const task = await this.taskRepository.findOne({
      where: { id: dto.taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    // Verify user is assigned to the project
    const projectMapping = await this.userProjectMappingRepository.findOne({
      where: { userId, projectId: task.projectId },
    });

    if (!projectMapping) {
      throw new ForbiddenException('You are not assigned to this project');
    }

    // Get total hours already logged for this day
    const existingLogs = await this.timeLogRepository.find({
      where: {
        userId,
        orgId,
        logDate: logDate,
      },
    });

    const totalExistingMinutes = existingLogs.reduce(
      (sum, log) => sum + Number(log.minutes),
      0,
    );
    const newMinutes = dto.minutes;

    // Validate: Max 12 hours (720 minutes) per day
    if (totalExistingMinutes + newMinutes > 720) {
      throw new BadRequestException(
        `Cannot log more than 12 hours per day. You have already logged ${totalExistingMinutes} minutes for this date.`,
      );
    }

    // Use transaction for time log and daily summary update
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Create time log
      const timeLog = queryRunner.manager.create(TimeLog, {
        userId,
        orgId,
        projectId: task.projectId,
        taskId: dto.taskId,
        logDate: logDate,
        minutes: newMinutes,
        description: dto.description,
      });

      const savedLog = await queryRunner.manager.save(timeLog);

      // Update daily summary
      await this.updateDailySummary(
        queryRunner.manager,
        userId,
        orgId,
        logDate,
      );

      await queryRunner.commitTransaction();

      this.logger.log(
        `Time logged: ${dto.minutes}m for task ${task.taskCode} by user ${userId}`,
      );

      return savedLog;
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Get all time logs with filtering
   */
  async findAll(
    orgId: string,
    userId: string,
    userRole: string,
    query: TimeLogQueryDto,
  ): Promise<{ data: TimeLog[]; total: number; page: number; limit: number }> {
    const { page = 1, limit = 20, ...filters } = query;
    const skip = (page - 1) * limit;

    const queryBuilder = this.timeLogRepository
      .createQueryBuilder('timelog')
      .leftJoinAndSelect('timelog.task', 'task')
      .where('timelog.org_id = :orgId', { orgId });

    // Non-admin users can only see their own time logs
    if (userRole !== 'ORG_ADMIN' && !filters.userId) {
      queryBuilder.andWhere('timelog.user_id = :userId', { userId });
    } else if (filters.userId) {
      queryBuilder.andWhere('timelog.user_id = :filterUserId', {
        filterUserId: filters.userId,
      });
    }

    // Apply filters
    if (filters.projectId) {
      queryBuilder.andWhere('timelog.project_id = :projectId', {
        projectId: filters.projectId,
      });
    }

    if (filters.taskId) {
      queryBuilder.andWhere('timelog.task_id = :taskId', {
        taskId: filters.taskId,
      });
    }

    if (filters.startDate && filters.endDate) {
      queryBuilder.andWhere('timelog.log_date BETWEEN :startDate AND :endDate', {
        startDate: filters.startDate,
        endDate: filters.endDate,
      });
    } else if (filters.startDate) {
      queryBuilder.andWhere('timelog.log_date >= :startDate', {
        startDate: filters.startDate,
      });
    } else if (filters.endDate) {
      queryBuilder.andWhere('timelog.log_date <= :endDate', {
        endDate: filters.endDate,
      });
    }

    const total = await queryBuilder.getCount();

    const data = await queryBuilder
      .orderBy('timelog.logDate', 'DESC')
      .addOrderBy('timelog.createdAt', 'DESC')
      .skip(skip)
      .take(limit)
      .getMany();

    return { data, total, page, limit };
  }

  /**
   * Get time log by ID
   */
  async findOne(orgId: string, timeLogId: string): Promise<TimeLog> {
    const timeLog = await this.timeLogRepository.findOne({
      where: { id: timeLogId, orgId },
      relations: ['task', 'user'],
    });

    if (!timeLog) {
      throw new NotFoundException('Time log not found');
    }

    return timeLog;
  }

  /**
   * Update time log
   */
  async update(
    orgId: string,
    userId: string,
    timeLogId: string,
    dto: UpdateTimeLogDto,
  ): Promise<TimeLog> {
    const timeLog = await this.timeLogRepository.findOne({
      where: { id: timeLogId, orgId },
    });

    if (!timeLog) {
      throw new NotFoundException('Time log not found');
    }

    // Users can only update their own logs
    if (timeLog.userId !== userId) {
      throw new ForbiddenException('You can only update your own time logs');
    }

    // If hours are being updated, validate total hours for the day
    if (dto.minutes !== undefined) {
      const existingLogs = await this.timeLogRepository.find({
        where: {
          userId,
          orgId,
          logDate: timeLog.logDate,
        },
      });

      const totalOtherMinutes = existingLogs
        .filter((log) => log.id !== timeLogId)
        .reduce((sum, log) => sum + Number(log.minutes), 0);
      const newMinutes = dto.minutes;

      if (totalOtherMinutes + newMinutes > 720) {
        throw new BadRequestException(
          `Cannot log more than 12 hours per day. Other entries for this date total ${totalOtherMinutes} minutes.`,
        );
      }
    }

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      if (dto.minutes !== undefined) {
        timeLog.minutes = dto.minutes;
      }
      if (dto.description !== undefined) {
        timeLog.description = dto.description;
      }
      const updated = await queryRunner.manager.save(timeLog);

      // Update daily summary
      await this.updateDailySummary(
        queryRunner.manager,
        userId,
        orgId,
        timeLog.logDate,
      );

      await queryRunner.commitTransaction();

      this.logger.log(`Time log updated: ${timeLogId}`);

      return updated;
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Delete time log
   */
  async remove(orgId: string, userId: string, timeLogId: string): Promise<void> {
    const timeLog = await this.timeLogRepository.findOne({
      where: { id: timeLogId, orgId },
    });

    if (!timeLog) {
      throw new NotFoundException('Time log not found');
    }

    // Users can only delete their own logs
    if (timeLog.userId !== userId) {
      throw new ForbiddenException('You can only delete your own time logs');
    }

    const logDate = timeLog.logDate;

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      await queryRunner.manager.remove(timeLog);

      // Update daily summary
      await this.updateDailySummary(queryRunner.manager, userId, orgId, logDate);

      await queryRunner.commitTransaction();

      this.logger.log(`Time log deleted: ${timeLogId}`);
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Get daily summary for a user
   */
  async getDailySummary(
    orgId: string,
    userId: string,
    startDate: string,
    endDate: string,
  ): Promise<UserDailySummary[]> {
    return this.dailySummaryRepository.find({
      where: {
        userId,
        orgId,
        summaryDate: Between(new Date(startDate), new Date(endDate)),
      },
      order: { summaryDate: 'ASC' },
    });
  }

  /**
   * Get my time logs for a date range
   */
  async getMyTimeLogs(
    orgId: string,
    userId: string,
    startDate: string,
    endDate: string,
    projectId?: string,
  ): Promise<TimeLog[]> {
    return this.timeLogRepository.find({
      where: {
        userId,
        orgId,
        logDate: Between(new Date(startDate), new Date(endDate)),
        ...(projectId && { projectId }),
      },
      relations: ['task'],
      order: { logDate: 'DESC', createdAt: 'DESC' },
    });
  }

  /**
   * Update or create daily summary for a user/date
   * Calculates color based on hours:
   * - RED = 0 hours
   * - YELLOW < 8 hours
   * - GREEN = 8 hours
   * - PURPLE > 8 hours
   */
  private async updateDailySummary(
    manager: any,
    userId: string,
    orgId: string,
    logDate: Date,
  ): Promise<void> {
    // Get total hours for the day
    const result = await manager
      .createQueryBuilder(TimeLog, 'timelog')
      .select('SUM(timelog.minutes)', 'totalMinutes')
      .where('timelog.user_id = :userId', { userId })
      .andWhere('timelog.org_id = :orgId', { orgId })
      .andWhere('timelog.log_date = :logDate', { logDate })
      .getRawOne();

    const totalMinutes = Number(result?.totalMinutes) || 0;

    // Calculate status color
    let color: StatusColor;
    if (totalMinutes === 0) {
      color = StatusColor.RED;
    } else if (totalMinutes < 480) {
      color = StatusColor.YELLOW;
    } else if (totalMinutes === 480) {
      color = StatusColor.GREEN;
    } else {
      color = StatusColor.PURPLE;
    }

    // Find or create daily summary
    let summary = await manager.findOne(UserDailySummary, {
      where: { userId, summaryDate: logDate },
    });

    if (summary) {
      summary.totalMinutes = totalMinutes;
      summary.color = color;
    } else {
      summary = manager.create(UserDailySummary, {
        userId,
        orgId,
        summaryDate: logDate,
        totalMinutes,
        color,
      });
    }

    await manager.save(summary);

    this.logger.debug(
      `Daily summary updated: ${userId} on ${logDate} - ${totalMinutes}min (${color})`,
    );
  }
}
