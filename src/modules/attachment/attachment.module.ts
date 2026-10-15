import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Attachment } from '../../entities/attachment.entity';
import { Task } from '../../entities/task.entity';
import { S3Service } from '../../common/services/s3.service';
import { AttachmentController } from './attachment.controller';
import { AttachmentService } from './attachment.service';

@Module({
  imports: [TypeOrmModule.forFeature([Attachment, Task])],
  controllers: [AttachmentController],
  providers: [AttachmentService, S3Service],
  exports: [AttachmentService],
})
export class AttachmentModule {}
