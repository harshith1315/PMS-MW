import { ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import {
  IsDateString,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from "class-validator";

export class ActivityLogQueryDto {
  @ApiPropertyOptional({ description: "Records to skip", default: 0 })
  @Type(() => Number)
  @IsOptional()
  @IsInt()
  @Min(0)
  skip?: number = 0;

  @ApiPropertyOptional({ description: "Records to fetch", default: 20 })
  @Type(() => Number)
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  take?: number = 20;

  @ApiPropertyOptional({
    description: "Filter by action type",
    example: "USER_ACTIVATED",
  })
  @IsOptional()
  @IsString()
  @IsIn([
    // Users
    "USER_ACTIVATED",
    "USER_DEACTIVATED",
    "USER_ROLE_UPDATED",
    "USER_INVITED",
    "USER_REMOVED",
    "USER_PROFILE_UPDATED",
    // Tasks
    "TASK_CREATED",
    "TASK_UPDATED",
    "TASK_DELETED",
    "TASK_STATUS_UPDATED",
    "TASK_ASSIGNEE_UPDATED",
    "TASK_SPRINT_UPDATED",
    "TASK_TAG_UPDATED",
    // Projects
    "PROJECT_CREATED",
    "PROJECT_UPDATED",
    "PROJECT_DELETED",
    "PROJECT_TEAM_ADDED",
    "PROJECT_TEAM_REMOVED",
    "PROJECT_LINK_ADDED",
    "PROJECT_LINK_REMOVED",
    "PROJECT_BANDWIDTH_UPDATED",
    "PROJECT_APPROVE_BANDWIDTH_UPDATED",
    // Sprints
    "SPRINT_CREATED",
    "SPRINT_UPDATED",
    "SPRINT_DELETED",
    "SPRINT_STARTED",
    "SPRINT_COMPLETED",
    // Comments
    "COMMENT_CREATED",
    "COMMENT_UPDATED",
    "COMMENT_DELETED",
    // Business Units
    "BUSINESS_UNIT_CREATED",
    "BUSINESS_UNIT_UPDATED",
    "BUSINESS_UNIT_DELETED",
    // Time Logs
    "TIME_LOG_CREATED",
    "TIME_LOG_UPDATED",
    "TIME_LOG_DELETED",
    // Tags
    "TAG_CREATED",
    "TAG_UPDATED",
    "TAG_DELETED",
    "TAG_STATUS_UPDATED",
    // Organizations
    "ORGANIZATION_CREATED",
    "ORGANIZATION_UPDATED",
    "ORGANIZATION_DELETED",
    // Access Control
    "ACCESS_CONTROL_PERMISSIONS_UPDATED",
    // Attachments
    "ATTACHMENT_UPLOADED",
    "ATTACHMENT_DELETED",
    // Notifications
    "NOTIFICATION_MARKED_READ",
    "NOTIFICATION_MARKED_ALL_READ",
    "NOTIFICATION_DELETED",
  ])
  actionType?: string;

  @ApiPropertyOptional({
    description: "Filter by actor user id",
    format: "uuid",
  })
  @IsOptional()
  @IsUUID()
  actorUserId?: string;

  @ApiPropertyOptional({
    description: "Filter by resource type",
    example: "project",
  })
  @IsOptional()
  @IsString()
  resourceType?: string;

  @ApiPropertyOptional({
    description: "Filter from date-time (ISO)",
    example: "2026-04-01T00:00:00.000Z",
  })
  @IsOptional()
  @IsDateString()
  fromDate?: string;

  @ApiPropertyOptional({
    description: "Filter to date-time (ISO)",
    example: "2026-04-13T23:59:59.999Z",
  })
  @IsOptional()
  @IsDateString()
  toDate?: string;
}
