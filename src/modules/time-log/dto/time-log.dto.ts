import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsUUID,
  IsOptional,
  IsDateString,
  IsNumber,
  IsInt,
  Min,
  Max,
  IsNotEmpty,
} from 'class-validator';

export class CreateTimeLogDto {
  @ApiProperty({ description: 'Task ID', format: 'uuid' })
  @IsUUID()
  @IsNotEmpty()
  taskId: string;

  @ApiProperty({ description: 'Log date (YYYY-MM-DD)', format: 'date' })
  @IsDateString()
  @IsNotEmpty()
  logDate: string;

  @ApiProperty({
    description: 'Minutes logged (max 720 per entry, i.e. 12 hours)',
    minimum: 15,
    maximum: 720,
  })
  @IsInt()
  @Min(15)
  @Max(720)
  minutes: number;

  @ApiPropertyOptional({ description: 'Work description' })
  @IsString()
  @IsOptional()
  description?: string;
}

export class UpdateTimeLogDto {
  @ApiPropertyOptional({
    description: 'Minutes logged (max 720 per entry, i.e. 12 hours)',
    minimum: 15,
    maximum: 720,
  })
  @IsInt()
  @Min(15)
  @Max(720)
  @IsOptional()
  minutes?: number;

  @ApiPropertyOptional({ description: 'Work description' })
  @IsString()
  @IsOptional()
  description?: string;
}

export class TimeLogQueryDto {
  @ApiPropertyOptional({ description: 'Filter by project ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  projectId?: string;

  @ApiPropertyOptional({ description: 'Filter by task ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  taskId?: string;

  @ApiPropertyOptional({ description: 'Filter by user ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  userId?: string;

  @ApiPropertyOptional({ description: 'Start date (YYYY-MM-DD)', format: 'date' })
  @IsDateString()
  @IsOptional()
  startDate?: string;

  @ApiPropertyOptional({ description: 'End date (YYYY-MM-DD)', format: 'date' })
  @IsDateString()
  @IsOptional()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Page number', default: 1 })
  @IsOptional()
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Items per page', default: 20 })
  @IsOptional()
  limit?: number = 20;
}

export class TimeLogResponseDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty({ format: 'uuid' })
  userId: string;

  @ApiProperty({ format: 'uuid' })
  orgId: string;

  @ApiProperty({ format: 'uuid' })
  projectId: string;

  @ApiProperty({ format: 'uuid' })
  taskId: string;

  @ApiProperty({ format: 'date' })
  logDate: Date;

  @ApiProperty({ description: 'Minutes logged' })
  minutes: number;

  @ApiPropertyOptional()
  description?: string;

  @ApiProperty({ format: 'date-time' })
  createdAt: Date;
}

export class DailySummaryResponseDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty({ format: 'uuid' })
  userId: string;

  @ApiProperty({ format: 'uuid' })
  orgId: string;

  @ApiProperty({ format: 'date' })
  logDate: Date;

  @ApiProperty({ description: 'Total hours logged' })
  totalHours: number;

  @ApiProperty({
    description: 'Status color',
    enum: ['RED', 'YELLOW', 'GREEN', 'PURPLE'],
  })
  statusColor: string;
}
