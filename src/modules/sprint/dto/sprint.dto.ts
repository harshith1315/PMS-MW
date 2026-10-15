import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsUUID,
  IsOptional,
  IsEnum,
  IsDateString,
  MaxLength,
  IsNotEmpty,
} from 'class-validator';
import { SprintStatus } from '../../../common/enums';

export class CreateSprintDto {
  @ApiProperty({ description: 'Project ID', format: 'uuid' })
  @IsUUID()
  @IsNotEmpty()
  projectId: string;

  @ApiProperty({ description: 'Sprint name', maxLength: 255 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  sprintName: string;

  @ApiPropertyOptional({ description: 'Sprint goal', maxLength: 1000 })
  @IsString()
  @IsOptional()
  @MaxLength(1000)
  goal?: string;

  @ApiPropertyOptional({ description: 'Sprint definition', maxLength: 2000 })
  @IsString()
  @IsOptional()
  @MaxLength(2000)
  definition?: string;

  @ApiPropertyOptional({ description: 'Start date', format: 'date' })
  @IsDateString()
  @IsOptional()
  startDate?: string;

  @ApiPropertyOptional({ description: 'End date', format: 'date' })
  @IsDateString()
  @IsOptional()
  endDate?: string;
}

export class UpdateSprintDto {
  @ApiPropertyOptional({ description: 'Sprint name', maxLength: 255 })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  sprintName?: string;

  @ApiPropertyOptional({ description: 'Sprint goal', maxLength: 1000 })
  @IsString()
  @IsOptional()
  @MaxLength(1000)
  goal?: string;

  @ApiPropertyOptional({ description: 'Sprint definition', maxLength: 2000 })
  @IsString()
  @IsOptional()
  @MaxLength(2000)
  definition?: string;

  @ApiPropertyOptional({ description: 'Start date', format: 'date' })
  @IsDateString()
  @IsOptional()
  startDate?: string;

  @ApiPropertyOptional({ description: 'End date', format: 'date' })
  @IsDateString()
  @IsOptional()
  endDate?: string;

  @ApiPropertyOptional({ enum: SprintStatus, description: 'Sprint status' })
  @IsEnum(SprintStatus)
  @IsOptional()
  status?: SprintStatus;
}

export class SprintResponseDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty({ format: 'uuid' })
  projectId: string;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional({ format: 'date' })
  startDate?: Date;

  @ApiPropertyOptional({ format: 'date' })
  endDate?: Date;

  @ApiProperty({ enum: SprintStatus })
  status: string;

  @ApiProperty({ format: 'date-time' })
  createdAt: Date;
}
