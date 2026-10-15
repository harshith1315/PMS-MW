import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Task } from './task.entity';
import { AppUser } from './app-user.entity';

@Entity('task_comment')
export class TaskComment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  @Column({ name: 'task_id', type: 'uuid' })
  taskId: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({ name: 'comment_text', type: 'text' })
  comment: string;

  @Column({ name: 'parent_comment_id', type: 'uuid', nullable: true })
  parentCommentId: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', nullable: true })
  updatedAt: Date;

  @ManyToOne(() => Task, (task) => task.comments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'task_id' })
  task: Task;

  @ManyToOne(() => AppUser, (user) => user.comments)
  @JoinColumn({ name: 'user_id' })
  user: AppUser;

  @ManyToOne(() => TaskComment, (comment) => comment.replies)
  @JoinColumn({ name: 'parent_comment_id' })
  parentComment: TaskComment;

  @OneToMany(() => TaskComment, (comment) => comment.parentComment)
  replies: TaskComment[];
}
