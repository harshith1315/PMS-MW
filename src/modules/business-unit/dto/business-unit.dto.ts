import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class CreateBusinessUnitDto {
  @ApiProperty({ description: 'Business unit name', example: 'Engineering' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name: string;

  @ApiPropertyOptional({ description: 'Owner user ID', format: 'uuid' })
  @IsOptional()
  @IsUUID()
  ownerId?: string;
}

export class UpdateBusinessUnitDto {
  @ApiPropertyOptional({ description: 'Business unit name', example: 'Engineering' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name?: string;

  @ApiPropertyOptional({ description: 'Owner user ID', format: 'uuid' })
  @IsOptional()
  @IsUUID()
  ownerId?: string;
}

export class BusinessUnitResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  status: string;

  @ApiPropertyOptional()
  ownerId?: string;

  @ApiPropertyOptional()
  owner?: { id: string; name: string; email: string };

  @ApiProperty()
  createdAt: Date;
}
