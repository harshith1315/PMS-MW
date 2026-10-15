import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
} from 'typeorm';
import { AppUser } from './app-user.entity';
import { Project } from './project.entity';
import { Task } from './task.entity';
import { Tag } from './tag.entity';
import { TaskLink } from './task-link.entity';
import { TimeLog } from './time-log.entity';
import { UserDailySummary } from './user-daily-summary.entity';
import { ResourceCost } from './resource-cost.entity';

@Entity('organization')
export class Organization {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ name: 'azure_tenant_id', type: 'varchar', length: 255, nullable: true })
  azureTenantId: string;

  @Column({ type: 'varchar', length: 50, default: 'ACTIVE' })
  status: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @OneToMany(() => AppUser, (user) => user.organization)
  users: AppUser[];

  @OneToMany(() => Project, (project) => project.organization)
  projects: Project[];

  @OneToMany(() => Task, (task) => task.organization)
  tasks: Task[];

  @OneToMany(() => Tag, (tag) => tag.organization)
  tags: Tag[];

  @OneToMany(() => TaskLink, (taskLink) => taskLink.organization)
  taskLinks: TaskLink[];

  @OneToMany(() => TimeLog, (timeLog) => timeLog.organization)
  timeLogs: TimeLog[];

  @OneToMany(() => UserDailySummary, (summary) => summary.organization)
  dailySummaries: UserDailySummary[];

  @OneToMany(() => ResourceCost, (cost) => cost.organization)
  resourceCosts: ResourceCost[];
}
