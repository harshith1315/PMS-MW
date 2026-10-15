import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { AppUser } from './app-user.entity';
import { Task } from './task.entity';

@Entity('notification')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'recipient_id', type: 'uuid' })
  recipientId: string;

  @Column({ name: 'task_id', type: 'uuid' })
  taskId: string;

  @Column({ type: 'varchar', length: 50 })
  type: string;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @Column({ name: 'is_read', type: 'boolean', default: false })
  isRead: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', nullable: true })
  updatedAt: Date;

  @ManyToOne(() => AppUser, (user) => user.notifications)
  @JoinColumn({ name: 'recipient_id' })
  recipient: AppUser;

  @ManyToOne(() => Task)
  @JoinColumn({ name: 'task_id' })
  task: Task;
}
