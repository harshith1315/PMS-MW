import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import {
  ChatMessage,
  ChatSession,
  Task,
  Project,
  TaskComment,
  AppUser,
  BusinessUnit,
} from "../../entities";
import { ChatController } from "./chat.controller";
import { ChatService } from "./chat.service";
import { ContextBuilderService } from "./context-builder.service";
import { LlmService } from "./llm.service";
import { AccessControlModule } from "../access-control/access-control.module";

@Module({
  imports: [
    AccessControlModule,
    TypeOrmModule.forFeature([
      ChatSession,
      ChatMessage,
      Task,
      Project,
      TaskComment,
      AppUser,
      BusinessUnit,
    ]),
  ],
  controllers: [ChatController],
  providers: [ChatService, ContextBuilderService, LlmService],
  exports: [ChatService, LlmService],
})
export class ChatModule {}
