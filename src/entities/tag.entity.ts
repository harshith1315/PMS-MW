import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  ManyToMany,
  JoinColumn,
} from 'typeorm';
import { Organization } from './organization.entity';
import { Task } from './task.entity';

@Entity('tag')
export class Tag {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  name: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  color: string;

  @Column({ type: 'varchar', length: 50, default: 'ACTIVE' })
  status: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => Organization, (org) => org.tags)
  @JoinColumn({ name: 'org_id' })
  organization: Organization;

  @ManyToMany(() => Task, (task) => task.tags)
  tasks: Task[];
}
