import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { AppUser } from './app-user.entity';
import { Organization } from './organization.entity';

@Entity('resource_cost')
export class ResourceCost {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  @Column({ name: 'cost_per_hour', type: 'decimal', precision: 10, scale: 2, nullable: true })
  costPerHour: number;

  @Column({ name: 'effective_from', type: 'date', nullable: true })
  effectiveFrom: Date;

  @ManyToOne(() => AppUser, (user) => user.resourceCosts)
  @JoinColumn({ name: 'user_id' })
  user: AppUser;

  @ManyToOne(() => Organization, (org) => org.resourceCosts)
  @JoinColumn({ name: 'org_id' })
  organization: Organization;
}
