import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Task } from './task.entity';
import { AppUser } from './app-user.entity';

@Entity('attachment')
export class Attachment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  @Column({ name: 'task_id', type: 'uuid' })
  taskId: string;

  @Column({ name: 'file_name', type: 'varchar', length: 255, nullable: true })
  fileName: string;

  @Column({ name: 's3_key', type: 'varchar', length: 500, nullable: true })
  fileUrl: string;

  @Column({ name: 'uploaded_by', type: 'uuid', nullable: true })
  uploadedBy: string;

  @CreateDateColumn({ name: 'created_at' })
  uploadedAt: Date;

  @ManyToOne(() => Task, (task) => task.attachments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'task_id' })
  task: Task;

  @ManyToOne(() => AppUser, (user) => user.uploadedAttachments)
  @JoinColumn({ name: 'uploaded_by' })
  uploadedByUser: AppUser;
}
