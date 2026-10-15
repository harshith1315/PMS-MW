import { Injectable, Logger } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { ActivityLog } from "../../entities/activity-log.entity";
import { ActivityLogQueryDto } from "./dto/activity-log-query.dto";

export interface CreateActivityLogInput {
  orgId: string;
  actorUserId?: string;
  actorName?: string;
  actorEmail?: string;
  method: string;
  resourceType?: string;
  resourceId?: string;
  actionType: string;
  message: string;
  requestPath: string;
  ipAddress?: string;
  userAgent?: string;
  metadata?: Record<string, unknown>;
}

@Injectable()
export class ActivityLogService {
  private readonly logger = new Logger(ActivityLogService.name);

  constructor(
    @InjectRepository(ActivityLog)
    private readonly repo: Repository<ActivityLog>,
  ) {}

  async create(input: CreateActivityLogInput): Promise<void> {
    try {
      const entity = this.repo.create({
        orgId: input.orgId,
        actorUserId: input.actorUserId,
        actorName: input.actorName,
        actorEmail: input.actorEmail,
        method: input.method,
        resourceType: input.resourceType,
        resourceId: input.resourceId,
        actionType: input.actionType,
        message: input.message,
        requestPath: input.requestPath,
        ipAddress: input.ipAddress,
        userAgent: input.userAgent,
        metadata: input.metadata ?? {},
      });

      await this.repo.save(entity);
    } catch (error) {
      const err = error instanceof Error ? error.message : String(error);
      this.logger.error(`Failed to write activity log: ${err}`);
    }
  }

  async list(orgId: string, query: ActivityLogQueryDto) {
    const skip = query.skip ?? 0;
    const take = query.take ?? 20;

    const qb = this.repo
      .createQueryBuilder("activity")
      .where("activity.org_id = :orgId", { orgId });

    if (query.actionType) {
      qb.andWhere("activity.action_type = :actionType", {
        actionType: query.actionType,
      });
    }

    if (query.actorUserId) {
      qb.andWhere("activity.actor_user_id = :actorUserId", {
        actorUserId: query.actorUserId,
      });
    }

    if (query.resourceType) {
      qb.andWhere("activity.resource_type = :resourceType", {
        resourceType: query.resourceType,
      });
    }

    if (query.fromDate) {
      qb.andWhere("activity.created_at >= :fromDate", {
        fromDate: `${query.fromDate}T00:00:00.000Z`,
      });
    }

    if (query.toDate) {
      qb.andWhere("activity.created_at <= :toDate", {
        toDate: `${query.toDate}T23:59:59.999Z`,
      });
    }

    const [data, total] = await qb
      .orderBy("activity.created_at", "DESC")
      .skip(skip)
      .take(take)
      .getManyAndCount();

    return {
      data,
      total,
      skip,
      take,
    };
  }
}
