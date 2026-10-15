import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Unique,
} from "typeorm";
import { Organization } from "./organization.entity";
import { Project } from "./project.entity";
import { UserProjectMapping } from "./user-project-mapping.entity";
import { Task } from "./task.entity";
import { TaskComment } from "./task-comment.entity";
import { Attachment } from "./attachment.entity";
import { TimeLog } from "./time-log.entity";
import { Timesheet } from "./timesheet.entity";
import { UserDailySummary } from "./user-daily-summary.entity";
import { ResourceCost } from "./resource-cost.entity";
import { TaskLink } from "./task-link.entity";
import { Notification } from "./notification.entity";
import { Role } from "./role.entity";

@Entity("app_user")
@Unique(["orgId", "email"])
export class AppUser {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "org_id", type: "uuid" })
  orgId: string;

  @Column({ type: "varchar", length: 255 })
  email: string;

  @Column({ name: "password_hash", type: "varchar", length: 255, nullable: true, select: false })
  passwordHash: string | null;

  @Column({ name: "password_setup_token_hash", type: "varchar", length: 64, nullable: true, select: false })
  passwordSetupTokenHash: string | null;

  @Column({ name: "password_setup_expires_at", type: "timestamptz", nullable: true, select: false })
  passwordSetupExpiresAt: Date | null;

  @Column({ type: "varchar", length: 255, nullable: true })
  name: string;

  @Column({ type: "varchar", length: 50, nullable: true })
  role: string;

  @Column({ name: "role_id", type: "uuid", nullable: true })
  roleId: string | null;

  @Column({ type: "varchar", length: 255, nullable: true })
  designation: string;

  @Column({ name: "is_leader", type: "boolean", default: false })
  isLeader: boolean;

  @Column({ name: "is_manager", type: "boolean", default: false })
  isManager: boolean;

  @Column({ type: "varchar", length: 50, default: "ACTIVE" })
  status: string;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @ManyToOne(() => Organization, (org) => org.users)
  @JoinColumn({ name: "org_id" })
  organization: Organization;

  @ManyToOne(() => Role, (role) => role.users)
  @JoinColumn({ name: "role_id" })
  roleEntity: Role;

  @OneToMany(() => Project, (project) => project.manager)
  managedProjects: Project[];

  @OneToMany(() => UserProjectMapping, (mapping) => mapping.user)
  projectMappings: UserProjectMapping[];

  @OneToMany(() => Task, (task) => task.assignee)
  assignedTasks: Task[];

  @OneToMany(() => Task, (task) => task.creator)
  createdTasks: Task[];

  @OneToMany(() => Task, (task) => task.blocker)
  blockedTasks: Task[];

  @OneToMany(() => TaskComment, (comment) => comment.user)
  comments: TaskComment[];

  @OneToMany(() => Attachment, (attachment) => attachment.uploadedByUser)
  uploadedAttachments: Attachment[];

  @OneToMany(() => TimeLog, (timeLog) => timeLog.user)
  timeLogs: TimeLog[];

  @OneToMany(() => Timesheet, (timesheet) => timesheet.user)
  timesheets: Timesheet[];

  @OneToMany(() => UserDailySummary, (summary) => summary.user)
  dailySummaries: UserDailySummary[];

  @OneToMany(() => ResourceCost, (cost) => cost.user)
  resourceCosts: ResourceCost[];

  @OneToMany(() => TaskLink, (taskLink) => taskLink.createdByUser)
  createdTaskLinks: TaskLink[];

  @OneToMany(() => Notification, (notification) => notification.recipient)
  notifications: Notification[];
}
