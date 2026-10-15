import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsUUID,
  IsOptional,
  IsNotEmpty,
  MaxLength,
} from 'class-validator';

export class CreateCommentDto {
  @ApiProperty({ description: 'Task ID', format: 'uuid' })
  @IsUUID()
  @IsNotEmpty()
  taskId: string;

  @ApiProperty({ description: 'Comment text' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(5000)
  comment: string;

  @ApiPropertyOptional({
    description: 'Parent comment ID for threaded replies',
    format: 'uuid',
  })
  @IsUUID()
  @IsOptional()
  parentCommentId?: string;
}

export class UpdateCommentDto {
  @ApiProperty({ description: 'Comment text' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(5000)
  comment: string;
}

export class CommentResponseDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty({ format: 'uuid' })
  taskId: string;

  @ApiProperty({ format: 'uuid' })
  userId: string;

  @ApiProperty()
  comment: string;

  @ApiPropertyOptional({ format: 'uuid' })
  parentCommentId?: string;

  @ApiProperty({ format: 'date-time' })
  createdAt: Date;

  @ApiPropertyOptional({ format: 'date-time' })
  updatedAt?: Date;

  @ApiPropertyOptional({
    type: [CommentResponseDto],
    description: 'Child comments (replies)',
  })
  replies?: CommentResponseDto[];
}
