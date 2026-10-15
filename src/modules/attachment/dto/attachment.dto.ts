import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsUUID, IsNotEmpty } from 'class-validator';

export class UploadAttachmentDto {
  @ApiProperty({ description: 'Task ID', format: 'uuid' })
  @IsUUID()
  @IsNotEmpty()
  taskId: string;
}

export class AttachmentResponseDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty({ format: 'uuid' })
  taskId: string;

  @ApiProperty()
  fileName: string;

  @ApiProperty()
  fileUrl: string;

  @ApiPropertyOptional({ format: 'uuid' })
  uploadedBy?: string;

  @ApiProperty({ format: 'date-time' })
  uploadedAt: Date;

  @ApiPropertyOptional({ description: 'Pre-signed download URL (temporary)' })
  downloadUrl?: string;
}

export class GetUploadUrlDto {
  @ApiProperty({ description: 'Task ID', format: 'uuid' })
  @IsUUID()
  @IsNotEmpty()
  taskId: string;

  @ApiProperty({ description: 'Original file name' })
  @IsString()
  @IsNotEmpty()
  fileName: string;

  @ApiProperty({ description: 'MIME type', example: 'application/pdf' })
  @IsString()
  @IsNotEmpty()
  contentType: string;
}

export class UploadUrlResponseDto {
  @ApiProperty({ description: 'Pre-signed upload URL' })
  uploadUrl: string;

  @ApiProperty({ description: 'S3 object key' })
  key: string;

  @ApiProperty({ description: 'File name' })
  fileName: string;
}

export class ConfirmUploadDto {
  @ApiProperty({ description: 'Task ID', format: 'uuid' })
  @IsUUID()
  @IsNotEmpty()
  taskId: string;

  @ApiProperty({ description: 'S3 object key from upload URL response' })
  @IsString()
  @IsNotEmpty()
  key: string;

  @ApiProperty({ description: 'Original file name' })
  @IsString()
  @IsNotEmpty()
  fileName: string;
}
