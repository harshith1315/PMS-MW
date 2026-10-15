import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('platform_user')
export class PlatformUser {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255, unique: true })
  email: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  name: string;

  @Column({ type: 'varchar', length: 50, default: 'SUPER_ADMIN' })
  role: string;

  @Column({ type: 'varchar', length: 50, default: 'ACTIVE' })
  status: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
