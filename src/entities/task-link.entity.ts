import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { Organization } from './organization.entity';
import { Task } from './task.entity';
import { AppUser } from './app-user.entity';

@Entity('task_link')
@Unique('unique_task_link', ['sourceTaskId', 'targetTaskId', 'linkType'])
export class TaskLink {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  @Column({ name: 'source_task_id', type: 'uuid' })
  sourceTaskId: string;

  @Column({ name: 'target_task_id', type: 'uuid' })
  targetTaskId: string;

  @Column({ name: 'link_type', type: 'varchar', length: 50 })
  linkType: string;

  @Column({ name: 'created_by', type: 'uuid', nullable: true })
  createdBy: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => Organization, (org) => org.taskLinks)
  @JoinColumn({ name: 'org_id' })
  organization: Organization;

  @ManyToOne(() => Task, (task) => task.outgoingLinks, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'source_task_id' })
  sourceTask: Task;

  @ManyToOne(() => Task, (task) => task.incomingLinks, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'target_task_id' })
  targetTask: Task;

  @ManyToOne(() => AppUser, (user) => user.createdTaskLinks)
  @JoinColumn({ name: 'created_by' })
  createdByUser: AppUser;
}
