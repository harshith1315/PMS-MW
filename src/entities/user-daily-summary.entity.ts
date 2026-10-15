import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { AppUser } from './app-user.entity';
import { Organization } from './organization.entity';

@Entity('user_daily_summary')
@Unique(['userId', 'summaryDate'])
export class UserDailySummary {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({ name: 'org_id', type: 'uuid' })
  orgId: string;

  @Column({ name: 'summary_date', type: 'date' })
  summaryDate: Date;

  @Column({ name: 'total_minutes', type: 'int', default: 0 })
  totalMinutes: number;

  @Column({ name: 'color', type: 'varchar', length: 20, nullable: true })
  color: string;

  @ManyToOne(() => AppUser, (user) => user.dailySummaries)
  @JoinColumn({ name: 'user_id' })
  user: AppUser;

  @ManyToOne(() => Organization, (org) => org.dailySummaries)
  @JoinColumn({ name: 'org_id' })
  organization: Organization;
}
