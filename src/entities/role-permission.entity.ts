import { Entity, Column, CreateDateColumn, UpdateDateColumn, PrimaryColumn } from "typeorm";

@Entity("role_permission")
export class RolePermission {
  @PrimaryColumn({ type: "varchar", length: 50 })
  role: string;

  @PrimaryColumn({ name: "permission_key", type: "varchar", length: 100 })
  permissionKey: string;

  @Column({ name: "is_granted", type: "boolean", default: true })
  isGranted: boolean;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;
}
