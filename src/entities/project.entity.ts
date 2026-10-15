import {
  Entity,
  Index,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Organization } from './organization.entity';
import { AppUser } from './app-user.entity';
import { UserProjectMapping } from './user-project-mapping.entity';
import { Sprint } from './sprint.entity';
import { Task } from './task.entity';
import { TimeLog } from './time-log.entity';
import { ProjectCost } from './project-cost.entity';
import { ProjectLink } from './project-link.entity';
import { ProjectTaskSequence } from './project-task-sequence.entity';

@Entity('project')
@Index('uq_project_org_finance_code', ['orgId', 'financeCode'], {
  unique: true,
  where: 'finance_code IS NOT NULL',
})
export class Project {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  // ===== Tab 1: Basic Information =====
  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ name: 'project_code', type: 'varchar', length: 50, unique: true })
  projectCode: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ name: 'business_unit', type: 'varchar', length: 100, nullable: true })
  businessUnit: string;

  @Column({ name: 'deliverable_type', type: 'varchar', length: 50, nullable: true })
  deliverableType?: string;

  @Column({ name: 'project_type', type: 'varchar', length: 20, nullable: true })
  projectType?: string;

  @Column({ name: 'execution_model', type: 'varchar', length: 50, nullable: true })
  executionModel?: string;

  // ===== Tab 2: Ownership & Governance =====
  @Column({ name: 'manager_id', type: 'uuid', nullable: true })
  managerId: string;

  @Column({ name: 'delivery_manager_id', type: 'uuid', nullable: true })
  deliveryManagerId?: string;

  @Column({ name: 'sponsor_id', type: 'uuid', nullable: true })
  sponsorId?: string;

  @Column({ name: 'created_by_id', type: 'uuid', nullable: true })
  createdById?: string;

  @Column({ name: 'approved_by_id', type: 'uuid', nullable: true })
  approvedById?: string;

  @Column({ type: 'varchar', length: 50, default: 'DRAFT' })
  status: string;

  @Column({ type: 'varchar', length: 20, default: 'MEDIUM', nullable: true })
  priority?: string;

  @Column({ name: 'risk_level', type: 'varchar', length: 20, default: 'LOW', nullable: true })
  riskLevel?: string;

  // ===== Tab 3: Timeline =====
  @Column({ name: 'start_date', type: 'date', nullable: true })
  startDate?: Date;

  @Column({ name: 'end_date', type: 'date', nullable: true })
  endDate?: Date;

  @Column({ name: 'actual_start_date', type: 'date', nullable: true })
  actualStartDate?: Date;

  @Column({ name: 'actual_end_date', type: 'date', nullable: true })
  actualEndDate?: Date;

  @Column({ name: 'kickoff_date', type: 'date', nullable: true })
  kickoffDate?: Date;

  @Column({ name: 'milestone_template', type: 'varchar', length: 100, nullable: true })
  milestoneTemplate?: string;

  // ===== Tab 4: Financials =====
  @Column({ name: 'budget', type: 'decimal', precision: 15, scale: 2, nullable: true })
  budget?: number;

  @Column({ name: 'budget_approved', type: 'decimal', precision: 15, scale: 2, nullable: true })
  budgetApproved?: number;

  @Column({ type: 'varchar', length: 10, default: 'INR', nullable: true })
  currency?: string;

  @Column({ name: 'cost_center_id', type: 'varchar', length: 100, nullable: true })
  costCenterId?: string;

  @Column({ name: 'finance_code', type: 'varchar', length: 50, nullable: true })
  financeCode?: string;

  @Column({ name: 'billing_type', type: 'varchar', length: 20, nullable: true })
  billingType?: string;

  @Column({ name: 'contract_type', type: 'varchar', length: 20, nullable: true })
  contractType?: string;

  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  revenue?: number;

  // ===== Tab 6: Configuration (Agile/Kanban/Waterfall) =====
  @Column({ name: 'sprint_duration', type: 'int', nullable: true })
  sprintDuration?: number;

  @Column({ name: 'iteration_start_day', type: 'varchar', length: 20, nullable: true })
  iterationStartDay?: string;

  @Column({ name: 'estimation_unit', type: 'varchar', length: 20, nullable: true })
  estimationUnit?: string;

  @Column({ name: 'velocity_tracking', type: 'boolean', default: false })
  velocityTracking?: boolean;

  @Column({ name: 'wip_limits', type: 'int', nullable: true })
  wipLimits?: number;

  @Column({ name: 'continuous_flow', type: 'boolean', default: false })
  continuousFlow?: boolean;

  @Column({ name: 'phase_template', type: 'varchar', length: 100, nullable: true })
  phaseTemplate?: string;

  @Column({ name: 'stage_gates', type: 'jsonb', nullable: true, default: () => "'[]'::jsonb" })
  stageGates?: string[];

  // ===== Tab 7: Integrations =====
  @Column({ name: 'document_repository', type: 'varchar', length: 500, nullable: true })
  documentRepository?: string;

  // ===== Tab 8: Client & Contract Info =====
  @Column({ name: 'client_name', type: 'varchar', length: 255, nullable: true })
  clientName?: string;

  @Column({ name: 'client_location', type: 'varchar', length: 255, nullable: true })
  clientLocation?: string;

  @Column({ name: 'client_spoc', type: 'varchar', length: 255, nullable: true })
  clientSpoc?: string;

  @Column({ name: 'contract_start_date', type: 'date', nullable: true })
  contractStartDate?: Date;

  @Column({ name: 'contract_end_date', type: 'date', nullable: true })
  contractEndDate?: Date;

  // ===== Tab 9: Additional Details =====
  @Column({ name: 'purpose', type: 'text', nullable: true })
  purpose?: string;

  @Column({ name: 'project_summary', type: 'text', nullable: true })
  projectSummary?: string;

  @Column({ name: 'cost_management', type: 'text', nullable: true })
  costManagement?: string;

  @Column({ type: 'text', nullable: true })
  comments?: string;

  @Column({ name: 'tech_stack', type: 'jsonb', nullable: false, default: () => "'[]'::jsonb" })
  techStack: string[];

  @Column({ name: 'dependencies', type: 'jsonb', nullable: false, default: () => "'[]'::jsonb" })
  dependencies: string[];

  @Column({ name: 'finance_member_id', type: 'uuid', nullable: true })
  financeMemberId?: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  // ===== Relations =====
  @ManyToOne(() => Organization, (org) => org.projects)
  @JoinColumn({ name: 'org_id' })
  organization: Organization;

  @ManyToOne(() => AppUser, (user) => user.managedProjects)
  @JoinColumn({ name: 'manager_id' })
  manager: AppUser;

  @ManyToOne(() => AppUser)
  @JoinColumn({ name: 'delivery_manager_id' })
  deliveryManager?: AppUser;

  @ManyToOne(() => AppUser)
  @JoinColumn({ name: 'sponsor_id' })
  sponsor?: AppUser;

  @ManyToOne(() => AppUser)
  @JoinColumn({ name: 'created_by_id' })
  createdBy?: AppUser;

  @ManyToOne(() => AppUser)
  @JoinColumn({ name: 'approved_by_id' })
  approvedBy?: AppUser;
  @ManyToOne(() => AppUser, { nullable: true, eager: false })
  @JoinColumn({ name: 'finance_member_id' })
  financeMember?: AppUser;

  @OneToMany(() => UserProjectMapping, (mapping) => mapping.project)
  userMappings: UserProjectMapping[];

  @OneToMany(() => Sprint, (sprint) => sprint.project)
  sprints: Sprint[];

  @OneToMany(() => Task, (task) => task.project)
  tasks: Task[];

  @OneToMany(() => TimeLog, (timeLog) => timeLog.project)
  timeLogs: TimeLog[];

  @OneToMany(() => ProjectCost, (cost) => cost.project)
  costs: ProjectCost[];

  @OneToMany(() => ProjectLink, (link) => link.project)
  links: ProjectLink[];

  @OneToMany(() => ProjectTaskSequence, (seq) => seq.project)
  taskSequences: ProjectTaskSequence[];
}
