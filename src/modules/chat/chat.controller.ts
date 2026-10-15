import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Res,
  UseGuards,
} from "@nestjs/common";
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from "@nestjs/swagger";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { TenantGuard } from "../../common/guards/tenant.guard";
import { UserContext } from "../auth/auth.service";
import { ChatService } from "./chat.service";
import {
  ChatMessageResponseDto,
  ChatSessionHistoryItemDto,
  CreateChatSessionResponseDto,
  EndChatSessionResponseDto,
  GenerateTaskSummaryDto,
  GenerateTaskSummaryResponseDto,
  SendChatMessageDto,
  SendChatMessageResponseDto,
} from "./dto/chat.dto";

@ApiTags("Chat")
@Controller("chat")
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth("bearer")
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post("sessions")
  @ApiOperation({ summary: "Start or resume active chat session" })
  @ApiResponse({
    status: 201,
    description: "Chat session created or resumed",
    type: CreateChatSessionResponseDto,
  })
  createSession(@CurrentUser() user: UserContext) {
    return this.chatService.createSession(user.orgId, user.userId);
  }

  @Get("sessions")
  @ApiOperation({ summary: "Get chat session history for current user" })
  @ApiResponse({
    status: 200,
    description: "List of previous chat sessions",
    type: [ChatSessionHistoryItemDto],
  })
  getHistory(@CurrentUser() user: UserContext) {
    return this.chatService.listHistory(user.orgId, user.userId);
  }

  @Get("sessions/:sessionId/messages")
  @ApiOperation({
    summary: "Get messages from an active or historical chat session",
  })
  @ApiParam({ name: "sessionId", description: "Chat session ID" })
  @ApiResponse({
    status: 200,
    description: "Session messages",
    type: [ChatMessageResponseDto],
  })
  getMessages(
    @CurrentUser() user: UserContext,
    @Param("sessionId") sessionId: string,
  ) {
    return this.chatService.getSessionMessages(
      user.orgId,
      user.userId,
      sessionId,
    );
  }

  @Post("sessions/:sessionId/messages")
  @ApiOperation({ summary: "Send message to current chat session" })
  @ApiParam({ name: "sessionId", description: "Chat session ID" })
  @ApiResponse({
    status: 201,
    description: "Message sent and assistant response generated",
    type: SendChatMessageResponseDto,
  })
  async sendMessage(
    @CurrentUser() user: UserContext,
    @Param("sessionId") sessionId: string,
    @Body() dto: SendChatMessageDto,
    @Res() res: any,
  ) {
    return this.chatService.sendMessage(
      user.orgId,
      user.userId,
      sessionId,
      dto.message,
      res,
    );
  }


  @Post("sessions/:sessionId/end")
  @ApiOperation({ summary: "End active chat session and move it to history" })
  @ApiParam({ name: "sessionId", description: "Chat session ID" })
  @ApiResponse({
    status: 201,
    description: "Session ended successfully",
    type: EndChatSessionResponseDto,
  })
  endSession(
    @CurrentUser() user: UserContext,
    @Param("sessionId") sessionId: string,
  ) {
    return this.chatService.endSession(user.orgId, user.userId, sessionId);
  }

  @Delete("sessions/:sessionId")
  @ApiOperation({ summary: "Delete a specific chat session from history" })
  @ApiParam({ name: "sessionId", description: "Chat session ID" })
  @ApiResponse({
    status: 200,
    description: "Session deleted successfully",
  })
  async deleteSession(
    @CurrentUser() user: UserContext,
    @Param("sessionId") sessionId: string,
  ) {
    await this.chatService.deleteSession(user.orgId, user.userId, sessionId);
    return { success: true };
  }

  @Post("task-summary")
  @ApiOperation({ summary: "Generate AI-powered summary for a specific task" })
  @ApiResponse({
    status: 201,
    description: "Task summary generated successfully",
    type: GenerateTaskSummaryResponseDto,
  })
  async generateTaskSummary(
    @CurrentUser() user: UserContext,
    @Body() dto: GenerateTaskSummaryDto,
  ) {
    const summary = await this.chatService.generateTaskSummary(
      user.orgId,
      dto.taskId,
    );
    return { summary };
  }
}
