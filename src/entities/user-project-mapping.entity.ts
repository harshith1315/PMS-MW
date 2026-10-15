import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { AppUser } from './app-user.entity';
import { Project } from './project.entity';

@Entity('user_project_mapping')
@Unique(['userId', 'projectId', 'projectRole'])
export class UserProjectMapping {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({ name: 'project_id', type: 'uuid' })
  projectId: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  @Column({ name: 'project_role', type: 'varchar', length: 50 })
  projectRole: string;

  @Column({ name: 'resource_type', type: 'varchar', length: 20, default: 'DEDICATED' })
  resourceType: string;

  @Column({ type: 'varchar', length: 50, default: 'ACTIVE' })
  status: string;

  @Column({ name: 'allocated_bandwidth', type: 'int', default: 0 })
  allocatedBandwidth: number;

  @Column({ name: 'approval_status', type: 'varchar', length: 50, default: 'PENDING' })
  approvalStatus: string;

  @Column({ name: 'requested_by_user_id', type: 'uuid', nullable: true })
  requestedByUserId?: string;

  @Column({ name: 'approved_by_user_id', type: 'uuid', nullable: true })
  approvedByUserId?: string;

  @Column({ name: 'approved_at', type: 'timestamp', nullable: true })
  approvedAt?: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => AppUser, (user) => user.projectMappings)
  @JoinColumn({ name: 'user_id' })
  user: AppUser;

  @ManyToOne(() => Project, (project) => project.userMappings)
  @JoinColumn({ name: 'project_id' })
  project: Project;
}
