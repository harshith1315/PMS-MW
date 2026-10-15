import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from "typeorm";
import { ChatMessage } from "./chat-message.entity";

@Entity("chat_session")
@Index("idx_chat_session_org_user_active", ["orgId", "userId", "endedAt"])
@Index("idx_chat_session_org_user_started", ["orgId", "userId", "startedAt"])
export class ChatSession {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "org_id", type: "uuid" })
  orgId: string;

  @Column({ name: "user_id", type: "uuid" })
  userId: string;

  @Column({ type: "varchar", length: 255, default: "New conversation" })
  title: string;

  @CreateDateColumn({ name: "started_at" })
  startedAt: Date;

  @Column({
    name: "ended_at",
    type: "timestamp with time zone",
    nullable: true,
  })
  endedAt: Date | null;

  @OneToMany(() => ChatMessage, (message) => message.session)
  messages: ChatMessage[];
}
