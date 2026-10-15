import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { AppUser } from './app-user.entity';
import { Organization } from './organization.entity';
import { Project } from './project.entity';
import { Task } from './task.entity';

@Entity('time_log')
export class TimeLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  @Column({ name: 'project_id', type: 'uuid' })
  projectId: string;

  @Column({ name: 'task_id', type: 'uuid' })
  taskId: string;

  @Column({ name: 'log_date', type: 'date' })
  logDate: Date;

  @Column({ name: 'minutes', type: 'int' })
  minutes: number;

  @Column({ type: 'text', nullable: true })
  description: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => AppUser, (user) => user.timeLogs)
  @JoinColumn({ name: 'user_id' })
  user: AppUser;

  @ManyToOne(() => Organization, (org) => org.timeLogs)
  @JoinColumn({ name: 'org_id' })
  organization: Organization;

  @ManyToOne(() => Project, (project) => project.timeLogs)
  @JoinColumn({ name: 'project_id' })
  project: Project;

  @ManyToOne(() => Task, (task) => task.timeLogs)
  @JoinColumn({ name: 'task_id' })
  task: Task;
}
