import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  ManyToMany,
  JoinColumn,
  JoinTable,
} from 'typeorm';
import { Organization } from './organization.entity';
import { Project } from './project.entity';
import { Sprint } from './sprint.entity';
import { AppUser } from './app-user.entity';
import { Tag } from './tag.entity';
import { Attachment } from './attachment.entity';
import { TaskComment } from './task-comment.entity';
import { TaskLink } from './task-link.entity';
import { TimeLog } from './time-log.entity';

@Entity('task')
export class Task {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  @Column({ name: 'project_id', type: 'uuid' })
  projectId: string;

  @Column({ name: 'sprint_id', type: 'uuid', nullable: true })
  sprintId: string | null;

  @Column({ name: 'task_code', type: 'varchar', length: 50, unique: true, nullable: true })
  taskCode: string;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ name: 'output_description', type: 'text', nullable: true })
  outputDescription: string;

  @Column({ name: 'task_type', type: 'varchar', length: 50, nullable: true })
  taskType: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  status: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  priority: string;

  @Column({ name: 'assigned_to', type: 'uuid', nullable: true })
  assignedTo: string | null;

  @Column({ name: 'created_by', type: 'uuid', nullable: true })
  createdBy: string;

  @Column({ name: 'due_date', type: 'date', nullable: true })
  dueDate: Date;

  @Column({ name: 'blocked_by', type: 'uuid', nullable: true })
  blockedBy: string;

  @Column({ name: 'epic_id', type: 'uuid', nullable: true })
  epicId: string | null;

  @Column({ name: 'story_id', type: 'uuid', nullable: true })
  storyId: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', nullable: true })
  updatedAt: Date;

  @ManyToOne(() => Organization, (org) => org.tasks)
  @JoinColumn({ name: 'org_id' })
  organization: Organization;

  @ManyToOne(() => Project, (project) => project.tasks)
  @JoinColumn({ name: 'project_id' })
  project: Project;

  @ManyToOne(() => Sprint, (sprint) => sprint.tasks)
  @JoinColumn({ name: 'sprint_id' })
  sprint: Sprint;

  @ManyToOne(() => AppUser, (user) => user.assignedTasks)
  @JoinColumn({ name: 'assigned_to' })
  assignee: AppUser;

  @ManyToOne(() => AppUser, (user) => user.createdTasks)
  @JoinColumn({ name: 'created_by' })
  creator: AppUser;

  @ManyToOne(() => AppUser, (user) => user.blockedTasks)
  @JoinColumn({ name: 'blocked_by' })
  blocker: AppUser;

  @ManyToOne(() => Task, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'epic_id' })
  epic: Task;

  @ManyToOne(() => Task, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'story_id' })
  story: Task;

  @ManyToMany(() => Tag, (tag) => tag.tasks)
  @JoinTable({
    name: 'task_tag_mapping',
    joinColumn: { name: 'task_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'tag_id', referencedColumnName: 'id' },
  })
  tags: Tag[];

  @OneToMany(() => Attachment, (attachment) => attachment.task)
  attachments: Attachment[];

  @OneToMany(() => TaskComment, (comment) => comment.task)
  comments: TaskComment[];

  @OneToMany(() => TaskLink, (taskLink) => taskLink.sourceTask)
  outgoingLinks: TaskLink[];

  @OneToMany(() => TaskLink, (taskLink) => taskLink.targetTask)
  incomingLinks: TaskLink[];

  @OneToMany(() => TimeLog, (timeLog) => timeLog.task)
  timeLogs: TimeLog[];
}
