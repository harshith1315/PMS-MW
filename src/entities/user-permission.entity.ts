import {
  Entity,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  Unique,
} from "typeorm";
import { AppUser } from "./app-user.entity";

@Entity("user_permission")
@Unique(["userId", "permissionKey"])
export class UserPermission {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "user_id", type: "uuid" })
  userId: string;

  @Column({ name: "permission_key", type: "varchar", length: 100 })
  permissionKey: string;

  @Column({ name: "is_granted", type: "boolean", default: true })
  isGranted: boolean;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;

  @ManyToOne(() => AppUser, { onDelete: "CASCADE" })
  @JoinColumn({ name: "user_id" })
  user: AppUser;
}
