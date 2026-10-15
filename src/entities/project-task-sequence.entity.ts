import {
  Entity,
  PrimaryColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Project } from './project.entity';

@Entity('project_task_sequence')
export class ProjectTaskSequence {
  @PrimaryColumn({ name: 'project_id', type: 'uuid' })
  projectId: string;

  @Column({ name: 'last_sequence', type: 'int', default: 0 })
  lastSequence: number;

  @ManyToOne(() => Project, (project) => project.taskSequences)
  @JoinColumn({ name: 'project_id' })
  project: Project;
}
