import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Project } from './project.entity';

@Entity('project_cost')
export class ProjectCost {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'project_id', type: 'uuid' })
  projectId: string;

  @Column({ name: 'total_hours', type: 'decimal', precision: 10, scale: 2, nullable: true })
  totalHours: number;

  @Column({ name: 'total_cost', type: 'decimal', precision: 15, scale: 2, nullable: true })
  totalCost: number;

  @CreateDateColumn({ name: 'calculated_at' })
  calculatedAt: Date;

  @ManyToOne(() => Project, (project) => project.costs)
  @JoinColumn({ name: 'project_id' })
  project: Project;
}
