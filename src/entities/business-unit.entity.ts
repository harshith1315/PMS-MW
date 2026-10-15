import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Organization } from './organization.entity';
import { AppUser } from './app-user.entity';

@Entity('business_unit')
@Index('idx_business_unit_org', ['orgId'])
@Index('uq_business_unit_org_name', ['orgId', 'name'], { unique: true })
export class BusinessUnit {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  @Column({ type: 'varchar', length: 100 })
  name: string;

  @Column({ type: 'varchar', length: 50, default: 'ACTIVE' })
  status: string;

  @Column({ name: 'owner_id', type: 'uuid', nullable: true })
  ownerId?: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => Organization)
  @JoinColumn({ name: 'org_id' })
  organization: Organization;

  @ManyToOne(() => AppUser, { nullable: true })
  @JoinColumn({ name: 'owner_id' })
  owner?: AppUser;
}
