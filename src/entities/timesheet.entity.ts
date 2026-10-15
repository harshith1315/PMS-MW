import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from "typeorm";
import { AppUser } from "./app-user.entity";
import { Organization } from "./organization.entity";

@Entity("timesheet")
@Index("idx_timesheet_org", ["orgId"])
@Index("idx_timesheet_user", ["userId"])
@Index("idx_timesheet_user_date", ["userId", "entryDate"])
export class Timesheet {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "org_id", type: "uuid" })
  orgId: string;

  @Column({ name: "user_id", type: "uuid" })
  userId: string;

  @Column({ name: "entry_date", type: "date" })
  entryDate: Date;

  @Column({ name: "project_name", type: "varchar", length: 255 })
  projectName: string;

  @Column({ name: "task_details", type: "text" })
  taskDetails: string;

  @Column({ type: "varchar", length: 50, default: "IN_PROGRESS" })
  status: string;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;

  @ManyToOne(() => AppUser)
  @JoinColumn({ name: "user_id" })
  user: AppUser;

  @ManyToOne(() => Organization)
  @JoinColumn({ name: "org_id" })
  organization: Organization;
}
