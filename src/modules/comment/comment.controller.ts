import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
  ApiParam,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { TenantGuard } from '../../common/guards/tenant.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserContext } from '../auth/auth.service';
import { CommentService } from './comment.service';
import {
  CreateCommentDto,
  UpdateCommentDto,
  CommentResponseDto,
} from './dto/comment.dto';

@ApiTags('Comments')
@Controller('comments')
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth('bearer')
export class CommentController {
  constructor(private readonly commentService: CommentService) {}

  @Post()
  @ApiOperation({ summary: 'Create a comment on a task' })
  @ApiResponse({
    status: 201,
    description: 'Comment created successfully',
    type: CommentResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task or parent comment not found' })
  async create(
    @CurrentUser() user: UserContext,
    @Body() createCommentDto: CreateCommentDto,
  ) {
    return this.commentService.create(user.orgId, user.userId, createCommentDto);
  }

  @Get('task/:taskId')
  @ApiOperation({ summary: 'Get all comments for a task (threaded)' })
  @ApiParam({ name: 'taskId', description: 'Task ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'List of threaded comments',
    type: [CommentResponseDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async findByTask(
    @CurrentUser() user: UserContext,
    @Param('taskId', ParseUUIDPipe) taskId: string,
  ) {
    return this.commentService.findByTask(user.orgId, taskId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get comment by ID' })
  @ApiParam({ name: 'id', description: 'Comment ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Comment details',
    type: CommentResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Comment not found' })
  async findOne(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.commentService.findOne(user.orgId, id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update comment' })
  @ApiParam({ name: 'id', description: 'Comment ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Comment updated successfully',
    type: CommentResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Can only edit own comments' })
  @ApiResponse({ status: 404, description: 'Comment not found' })
  async update(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateCommentDto: UpdateCommentDto,
  ) {
    return this.commentService.update(
      user.orgId,
      user.userId,
      id,
      updateCommentDto,
    );
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete comment' })
  @ApiParam({ name: 'id', description: 'Comment ID', format: 'uuid' })
  @ApiResponse({ status: 204, description: 'Comment deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Can only delete own comments' })
  @ApiResponse({ status: 404, description: 'Comment not found' })
  async remove(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.commentService.remove(user.orgId, user.userId, user.role, id);
  }
}
