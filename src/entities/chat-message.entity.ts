import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { ChatSession } from "./chat-session.entity";

export type ChatMessageRole = "user" | "assistant";

@Entity("chat_message")
@Index("idx_chat_message_session_created", ["sessionId", "createdAt"])
export class ChatMessage {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ name: "session_id", type: "uuid" })
  sessionId: string;

  @Column({ type: "varchar", length: 20 })
  role: ChatMessageRole;

  @Column({ type: "text" })
  text: string;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @ManyToOne(() => ChatSession, (session) => session.messages, {
    onDelete: "CASCADE",
  })
  @JoinColumn({ name: "session_id" })
  session: ChatSession;
}
