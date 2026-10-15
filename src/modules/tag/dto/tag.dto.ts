import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import {
  IsString,
  IsIn,
  IsOptional,
  MaxLength,
  IsHexColor,
  IsUUID,
} from 'class-validator';

export class CreateTagDto {
  @ApiProperty({ description: 'Tag name', maxLength: 100, example: 'Frontend' })
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiPropertyOptional({
    description: 'Tag color in hex format',
    example: '#FF5733',
  })
  @IsOptional()
  @IsHexColor()
  color?: string;
}

export class UpdateTagDto extends PartialType(CreateTagDto) {}

export class UpdateTagStatusDto {
  @ApiProperty({
    description: 'Tag status',
    enum: ['ACTIVE', 'ARCHIVED'],
    example: 'ARCHIVED',
  })
  @IsIn(['ACTIVE', 'ARCHIVED'])
  status: string;
}

export class TagQueryDto {
  @ApiPropertyOptional({ description: 'Filter by status' })
  @IsOptional()
  @IsIn(['ACTIVE', 'ARCHIVED'])
  status?: string;

  @ApiPropertyOptional({ description: 'Search by tag name' })
  @IsOptional()
  @IsString()
  search?: string;
}

export class AssignTagsDto {
  @ApiProperty({
    description: 'Array of tag IDs to assign',
    type: [String],
    example: ['550e8400-e29b-41d4-a716-446655440000'],
  })
  @IsUUID('4', { each: true })
  tagIds: string[];
}

export class TagResponseDto {
  @ApiProperty({ description: 'Tag ID', format: 'uuid' })
  id: string;

  @ApiProperty({ description: 'Organization ID', format: 'uuid' })
  orgId: string;

  @ApiProperty({ description: 'Tag name' })
  name: string;

  @ApiPropertyOptional({ description: 'Tag color' })
  color?: string;

  @ApiProperty({ description: 'Tag status' })
  status: string;

  @ApiProperty({ description: 'Created timestamp' })
  createdAt: Date;

  @ApiProperty({ description: 'Last updated timestamp' })
  updatedAt: Date;
}
