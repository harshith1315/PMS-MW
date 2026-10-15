import {
  Entity,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  PrimaryGeneratedColumn,
  OneToMany,
  Unique,
} from "typeorm";
import { AppUser } from "./app-user.entity";

@Entity("role")
@Unique(["key"])
export class Role {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ type: "varchar", length: 50 })
  key: string;

  @Column({ type: "varchar", length: 100 })
  name: string;

  @Column({ type: "text", nullable: true })
  description: string | null;

  @Column({ type: "jsonb", default: () => "'{}'::jsonb" })
  permissions: Record<string, boolean>;

  @Column({ name: "is_system", type: "boolean", default: false })
  isSystem: boolean;

  @Column({ name: "is_active", type: "boolean", default: true })
  isActive: boolean;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;

  @OneToMany(() => AppUser, (user) => user.roleEntity)
  users: AppUser[];
}
