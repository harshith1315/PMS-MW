import {
  BadRequestException,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import {
  Between,
  In,
  LessThanOrEqual,
  MoreThanOrEqual,
  Repository,
} from "typeorm";
import { Timesheet } from "../../entities/timesheet.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import { CreateTimesheetDto, TimesheetQueryDto } from "./dto/timesheet.dto";

@Injectable()
export class TimesheetService {
  private readonly logger = new Logger(TimesheetService.name);

  private handleStorageError(error: unknown): never {
    const message = error instanceof Error ? error.message : "";
    if (message.includes('relation "timesheet" does not exist')) {
      throw new ServiceUnavailableException(
        "Timesheet storage is not initialized. Apply the latest database schema and retry.",
      );
    }
    throw error as Error;
  }

  constructor(
    @InjectRepository(Timesheet)
    private readonly timesheetRepository: Repository<Timesheet>,
    @InjectRepository(UserProjectMapping)
    private readonly mappingRepository: Repository<UserProjectMapping>,
  ) {}

  async create(
    orgId: string,
    userId: string,
    dto: CreateTimesheetDto,
  ): Promise<Timesheet> {
    const entryDate = new Date(dto.date);
    const today = new Date();
    today.setHours(23, 59, 59, 999);

    if (entryDate > today) {
      throw new BadRequestException("Cannot create timesheet for future dates");
    }

    const timesheet = this.timesheetRepository.create({
      orgId,
      userId,
      entryDate,
      projectName: dto.projectName.trim(),
      taskDetails: dto.taskDetails.trim(),
      status: dto.status,
    });

    try {
      const saved = await this.timesheetRepository.save(timesheet);
      this.logger.log(`Timesheet created: ${saved.id} for user ${userId}`);
      return saved;
    } catch (error) {
      this.handleStorageError(error);
    }
  }

  async listMine(
    orgId: string,
    userId: string,
    query: TimesheetQueryDto,
  ): Promise<Timesheet[]> {
    const where: Record<string, unknown> = { orgId, userId };

    if (query.startDate && query.endDate) {
      where.entryDate = Between(
        new Date(query.startDate),
        new Date(query.endDate),
      );
    } else if (query.startDate) {
      where.entryDate = MoreThanOrEqual(new Date(query.startDate));
    } else if (query.endDate) {
      where.entryDate = LessThanOrEqual(new Date(query.endDate));
    }

    try {
      return await this.timesheetRepository.find({
        where,
        order: {
          entryDate: "DESC",
          createdAt: "DESC",
        },
      });
    } catch (error) {
      this.handleStorageError(error);
    }
  }

  async listTeam(
    orgId: string,
    _managerId: string,
    _role: string,
    query: TimesheetQueryDto,
  ): Promise<(Timesheet & { userName: string; userEmail: string })[]> {
    const mappings = await this.mappingRepository.find({
      where: { orgId, approvalStatus: 'APPROVED' },
      select: ['userId'],
    });
    const memberIds = [...new Set(mappings.map((m) => m.userId))];

    if (memberIds.length === 0) {
      return [];
    }

    const where: Record<string, unknown> = { orgId, userId: In(memberIds) };

    if (query.startDate && query.endDate) {
      where.entryDate = Between(
        new Date(query.startDate),
        new Date(query.endDate),
      );
    } else if (query.startDate) {
      where.entryDate = MoreThanOrEqual(new Date(query.startDate));
    } else if (query.endDate) {
      where.entryDate = LessThanOrEqual(new Date(query.endDate));
    }

    try {
      const timesheets = await this.timesheetRepository.find({
        where,
        relations: ["user"],
        order: { entryDate: "DESC", createdAt: "DESC" },
      });
      return timesheets.map((t) => ({
        ...t,
        userName: t.user?.name ?? "",
        userEmail: t.user?.email ?? "",
      }));
    } catch (error) {
      this.handleStorageError(error);
    }
  }
}
