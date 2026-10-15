import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsUUID, IsEnum, IsNotEmpty } from 'class-validator';
import { TaskLinkType } from '../../../common/enums';

export class CreateTaskLinkDto {
  @ApiProperty({ description: 'Source task ID', format: 'uuid' })
  @IsUUID()
  @IsNotEmpty()
  sourceTaskId: string;

  @ApiProperty({ description: 'Target task ID', format: 'uuid' })
  @IsUUID()
  @IsNotEmpty()
  targetTaskId: string;

  @ApiProperty({
    enum: TaskLinkType,
    description: 'Type of link relationship',
    example: 'BLOCKS',
  })
  @IsEnum(TaskLinkType)
  @IsNotEmpty()
  linkType: TaskLinkType;
}

export class TaskLinkResponseDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty({ format: 'uuid' })
  orgId: string;

  @ApiProperty({ format: 'uuid' })
  sourceTaskId: string;

  @ApiProperty({ format: 'uuid' })
  targetTaskId: string;

  @ApiProperty({ enum: TaskLinkType })
  linkType: string;

  @ApiPropertyOptional({ format: 'uuid' })
  createdBy?: string;

  @ApiProperty({ format: 'date-time' })
  createdAt: Date;

  @ApiPropertyOptional({ description: 'Source task details' })
  sourceTask?: {
    id: string;
    taskCode: string;
    title: string;
    status: string;
  };

  @ApiPropertyOptional({ description: 'Target task details' })
  targetTask?: {
    id: string;
    taskCode: string;
    title: string;
    status: string;
  };
}
