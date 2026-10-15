import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Attachment } from '../../entities/attachment.entity';
import { Task } from '../../entities/task.entity';
import { S3Service } from '../../common/services/s3.service';
import {
  GetUploadUrlDto,
  ConfirmUploadDto,
} from './dto/attachment.dto';

@Injectable()
export class AttachmentService {
  private readonly logger = new Logger(AttachmentService.name);

  constructor(
    @InjectRepository(Attachment)
    private readonly attachmentRepository: Repository<Attachment>,
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
    private readonly s3Service: S3Service,
  ) {}

  /**
   * Upload file directly (multipart form)
   */
  async uploadFile(
    orgId: string,
    userId: string,
    taskId: string,
    file: Express.Multer.File,
  ): Promise<Attachment> {
    // Verify task exists and belongs to org
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    // Upload to S3
    const folder = `attachments/${orgId}/${task.projectId}/${taskId}`;
    const uploadResult = await this.s3Service.uploadFile(file, folder);

    // Save attachment record
    const attachment = this.attachmentRepository.create({
      orgId,
      taskId,
      fileName: uploadResult.fileName,
      fileUrl: uploadResult.key, // Store S3 key instead of URL
      uploadedBy: userId,
    });

    const saved = await this.attachmentRepository.save(attachment);
    this.logger.log(`File uploaded: ${saved.fileName} for task ${taskId}`);

    return saved;
  }

  /**
   * Get pre-signed upload URL for direct browser upload
   */
  async getUploadUrl(
    orgId: string,
    userId: string,
    dto: GetUploadUrlDto,
  ): Promise<{ uploadUrl: string; key: string; fileName: string }> {
    // Verify task exists and belongs to org
    const task = await this.taskRepository.findOne({
      where: { id: dto.taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    const folder = `attachments/${orgId}/${task.projectId}/${dto.taskId}`;
    const result = await this.s3Service.getUploadSignedUrl(
      folder,
      dto.fileName,
      dto.contentType,
    );

    return {
      uploadUrl: result.uploadUrl,
      key: result.key,
      fileName: dto.fileName,
    };
  }

  /**
   * Confirm upload (after direct S3 upload)
   */
  async confirmUpload(
    orgId: string,
    userId: string,
    dto: ConfirmUploadDto,
  ): Promise<Attachment> {
    // Verify task exists and belongs to org
    const task = await this.taskRepository.findOne({
      where: { id: dto.taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    // Save attachment record
    const attachment = this.attachmentRepository.create({
      orgId,
      taskId: dto.taskId,
      fileName: dto.fileName,
      fileUrl: dto.key,
      uploadedBy: userId,
    });

    const saved = await this.attachmentRepository.save(attachment);
    this.logger.log(`Upload confirmed: ${saved.fileName} for task ${dto.taskId}`);

    return saved;
  }

  /**
   * Get all attachments for a task
   */
  async findByTask(orgId: string, taskId: string): Promise<Attachment[]> {
    // Verify task exists and belongs to org
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    const attachments = await this.attachmentRepository.find({
      where: { taskId, orgId },
      relations: ['uploadedByUser'],
      order: { uploadedAt: 'DESC' },
    });

    return attachments;
  }

  /**
   * Get attachment by ID
   */
  async findOne(orgId: string, attachmentId: string): Promise<Attachment> {
    const attachment = await this.attachmentRepository
      .createQueryBuilder('attachment')
      .innerJoin('task', 'task', 'task.id = attachment.task_id')
      .leftJoinAndSelect('attachment.uploadedByUser', 'user')
      .where('attachment.id = :attachmentId', { attachmentId })
      .andWhere('task.org_id = :orgId', { orgId })
      .getOne();

    if (!attachment) {
      throw new NotFoundException('Attachment not found');
    }

    return attachment;
  }

  /**
   * Get download URL for attachment
   */
  async getDownloadUrl(orgId: string, attachmentId: string): Promise<string> {
    const attachment = await this.findOne(orgId, attachmentId);
    return this.s3Service.getSignedUrl(attachment.fileUrl);
  }

  /**
   * Delete attachment
   */
  async remove(
    orgId: string,
    userId: string,
    userRole: string,
    attachmentId: string,
  ): Promise<void> {
    const attachment = await this.findOne(orgId, attachmentId);

    // Users can delete their own uploads, ORG_ADMIN can delete any
    if (attachment.uploadedBy !== userId && userRole !== 'ORG_ADMIN') {
      throw new ForbiddenException('You can only delete your own attachments');
    }

    // Delete from S3
    try {
      await this.s3Service.deleteFile(attachment.fileUrl);
    } catch (error) {
      this.logger.warn(`Failed to delete S3 file: ${attachment.fileUrl}`);
    }

    // Delete record
    await this.attachmentRepository.remove(attachment);
    this.logger.log(`Attachment deleted: ${attachmentId}`);
  }
}
