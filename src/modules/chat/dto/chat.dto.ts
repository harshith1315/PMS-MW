import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, MaxLength } from "class-validator";

export class CreateChatSessionResponseDto {
  @ApiProperty() sessionId!: string;
  @ApiProperty({ format: "date-time" }) startedAt!: string;
}

export class SendChatMessageDto {
  @ApiProperty({ description: "User message to send to assistant" })
  @IsString()
  @IsNotEmpty()
  @MaxLength(4000)
  message!: string;
}

export class ChatMessageResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty({ enum: ["user", "assistant"] }) role!: "user" | "assistant";
  @ApiProperty() text!: string;
  @ApiProperty({ format: "date-time" }) createdAt!: string;
}

export class SendChatMessageResponseDto {
  @ApiProperty() sessionId!: string;
  @ApiProperty({ type: ChatMessageResponseDto })
  userMessage!: ChatMessageResponseDto;
  @ApiProperty({ type: ChatMessageResponseDto })
  assistantMessage!: ChatMessageResponseDto;
}

export class ChatSessionHistoryItemDto {
  @ApiProperty() id!: string;
  @ApiProperty() title!: string;
  @ApiProperty({ format: "date-time" }) startedAt!: string;
  @ApiProperty({ format: "date-time" }) endedAt!: string;
  @ApiProperty() messageCount!: number;
  @ApiProperty() lastMessagePreview!: string;
}

export class EndChatSessionResponseDto {
  @ApiProperty({ type: ChatSessionHistoryItemDto })
  session!: ChatSessionHistoryItemDto;
}

export class GenerateTaskSummaryDto {
  @ApiProperty({ description: "Task ID to summarize" })
  @IsString()
  @IsNotEmpty()
  taskId!: string;
}

export class GenerateTaskSummaryResponseDto {
  @ApiProperty({ description: "AI-generated task summary" })
  summary!: string;
}
