import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Project } from './project.entity';

@Entity('project_link')
export class ProjectLink {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'project_id', type: 'uuid' })
  projectId: string;

  @Column({ name: 'link_type', type: 'varchar', length: 50, nullable: true })
  linkType: string;

  @Column({ type: 'text', nullable: true })
  url: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => Project, (project) => project.links)
  @JoinColumn({ name: 'project_id' })
  project: Project;
}
