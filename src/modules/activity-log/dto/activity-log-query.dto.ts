import { ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import {
  IsDateString,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from "class-validator";

export class ActivityLogQueryDto {
  @ApiPropertyOptional({ default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  skip?: number = 0;

  @ApiPropertyOptional({ default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  take?: number = 20;

  @ApiPropertyOptional({ example: "TASK_STATUS_UPDATED" })
  @IsOptional()
  @IsString()
  actionType?: string;

  @ApiPropertyOptional({ format: "uuid" })
  @IsOptional()
  @IsUUID()
  actorUserId?: string;

  @ApiPropertyOptional({ example: "task" })
  @IsOptional()
  @IsString()
  resourceType?: string;

  @ApiPropertyOptional({ example: "2026-04-01" })
  @IsOptional()
  @IsDateString()
  fromDate?: string;

  @ApiPropertyOptional({ example: "2026-04-30" })
  @IsOptional()
  @IsDateString()
  toDate?: string;
}
