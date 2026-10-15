import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
  ApiParam,
  ApiConsumes,
  ApiBody,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { TenantGuard } from '../../common/guards/tenant.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserContext } from '../auth/auth.service';
import { AttachmentService } from './attachment.service';
import {
  AttachmentResponseDto,
  GetUploadUrlDto,
  UploadUrlResponseDto,
  ConfirmUploadDto,
} from './dto/attachment.dto';

@ApiTags('Attachments')
@Controller('attachments')
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth('bearer')
export class AttachmentController {
  constructor(private readonly attachmentService: AttachmentService) {}

  @Post('upload/:taskId')
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Upload attachment to a task' })
  @ApiParam({ name: 'taskId', description: 'Task ID', format: 'uuid' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'File uploaded successfully',
    type: AttachmentResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async uploadFile(
    @CurrentUser() user: UserContext,
    @Param('taskId', ParseUUIDPipe) taskId: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.attachmentService.uploadFile(
      user.orgId,
      user.userId,
      taskId,
      file,
    );
  }

  @Post('upload-url')
  @ApiOperation({ summary: 'Get pre-signed URL for direct S3 upload' })
  @ApiResponse({
    status: 200,
    description: 'Pre-signed upload URL',
    type: UploadUrlResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async getUploadUrl(
    @CurrentUser() user: UserContext,
    @Body() dto: GetUploadUrlDto,
  ) {
    return this.attachmentService.getUploadUrl(user.orgId, user.userId, dto);
  }

  @Post('confirm-upload')
  @ApiOperation({ summary: 'Confirm upload after direct S3 upload' })
  @ApiResponse({
    status: 201,
    description: 'Upload confirmed',
    type: AttachmentResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async confirmUpload(
    @CurrentUser() user: UserContext,
    @Body() dto: ConfirmUploadDto,
  ) {
    return this.attachmentService.confirmUpload(user.orgId, user.userId, dto);
  }

  @Get('task/:taskId')
  @ApiOperation({ summary: 'Get all attachments for a task' })
  @ApiParam({ name: 'taskId', description: 'Task ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'List of attachments',
    type: [AttachmentResponseDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async findByTask(
    @CurrentUser() user: UserContext,
    @Param('taskId', ParseUUIDPipe) taskId: string,
  ) {
    return this.attachmentService.findByTask(user.orgId, taskId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get attachment by ID' })
  @ApiParam({ name: 'id', description: 'Attachment ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Attachment details',
    type: AttachmentResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Attachment not found' })
  async findOne(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.attachmentService.findOne(user.orgId, id);
  }

  @Get(':id/download')
  @ApiOperation({ summary: 'Get download URL for attachment' })
  @ApiParam({ name: 'id', description: 'Attachment ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Pre-signed download URL',
    schema: {
      type: 'object',
      properties: {
        downloadUrl: { type: 'string' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Attachment not found' })
  async getDownloadUrl(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const downloadUrl = await this.attachmentService.getDownloadUrl(
      user.orgId,
      id,
    );
    return { downloadUrl };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete attachment' })
  @ApiParam({ name: 'id', description: 'Attachment ID', format: 'uuid' })
  @ApiResponse({ status: 204, description: 'Attachment deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Can only delete own attachments' })
  @ApiResponse({ status: 404, description: 'Attachment not found' })
  async remove(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.attachmentService.remove(user.orgId, user.userId, user.role, id);
  }
}
