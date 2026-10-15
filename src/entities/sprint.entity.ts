import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Project } from './project.entity';
import { Task } from './task.entity';

@Entity('sprint')
export class Sprint {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'project_id', type: 'uuid' })
  projectId: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  name: string;

  @Column({ type: 'text', nullable: true })
  goal: string;

  @Column({ type: 'text', nullable: true })
  definition: string;

  @Column({ name: 'start_date', type: 'date', nullable: true })
  startDate: Date;

  @Column({ name: 'end_date', type: 'date', nullable: true })
  endDate: Date;

  @Column({ type: 'varchar', length: 50, default: 'PLANNED' })
  status: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => Project, (project) => project.sprints)
  @JoinColumn({ name: 'project_id' })
  project: Project;

  @OneToMany(() => Task, (task) => task.sprint)
  tasks: Task[];
}
