import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsDateString, IsOptional, IsUUID } from 'class-validator';

export class ReportQueryDto {
  @ApiPropertyOptional({ description: 'Start date filter (YYYY-MM-DD)' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'End date filter (YYYY-MM-DD)' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Project filter', format: 'uuid' })
  @IsOptional()
  @IsUUID()
  projectId?: string;

  @ApiPropertyOptional({ description: 'Sprint filter', format: 'uuid' })
  @IsOptional()
  @IsUUID()
  sprintId?: string;

  @ApiPropertyOptional({ description: 'Target user filter', format: 'uuid' })
  @IsOptional()
  @IsUUID()
  userId?: string;
}
