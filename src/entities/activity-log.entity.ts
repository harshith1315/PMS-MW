import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from "typeorm";

@Entity("activity_log")
@Index("idx_activity_log_org_id", ["orgId"])
@Index("idx_activity_log_created_at", ["createdAt"])
@Index("idx_activity_log_action_type", ["actionType"])
@Index("idx_activity_log_actor_user_id", ["actorUserId"])
@Index("idx_activity_log_resource_type", ["resourceType"])
export class ActivityLog {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "org_id", type: "uuid" })
  orgId: string;

  @Column({ name: "actor_user_id", type: "uuid", nullable: true })
  actorUserId?: string;

  @Column({ name: "actor_name", type: "varchar", length: 255, nullable: true })
  actorName?: string;

  @Column({ name: "actor_email", type: "varchar", length: 255, nullable: true })
  actorEmail?: string;

  @Column({ type: "varchar", length: 10 })
  method: string;

  @Column({
    name: "resource_type",
    type: "varchar",
    length: 100,
    nullable: true,
  })
  resourceType?: string;

  @Column({ name: "resource_id", type: "varchar", length: 255, nullable: true })
  resourceId?: string;

  @Column({ name: "action_type", type: "varchar", length: 100 })
  actionType: string;

  @Column({ type: "text" })
  message: string;

  @Column({ name: "request_path", type: "varchar", length: 500 })
  requestPath: string;

  @Column({ name: "ip_address", type: "varchar", length: 64, nullable: true })
  ipAddress?: string;

  @Column({ name: "user_agent", type: "varchar", length: 500, nullable: true })
  userAgent?: string;

  @Column({ type: "jsonb", nullable: true, default: () => "'{}'::jsonb" })
  metadata?: Record<string, unknown>;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;
}
