import {
  Controller,
  Get,
  Post,
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
import { TaskLinkService } from './task-link.service';
import { CreateTaskLinkDto, TaskLinkResponseDto } from './dto/task-link.dto';

@ApiTags('Task Links')
@Controller('task-links')
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth('bearer')
export class TaskLinkController {
  constructor(private readonly taskLinkService: TaskLinkService) {}

  @Post()
  @ApiOperation({ summary: 'Create a link between two tasks' })
  @ApiResponse({
    status: 201,
    description: 'Task link created successfully',
    type: TaskLinkResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  @ApiResponse({ status: 409, description: 'Link already exists' })
  async create(
    @CurrentUser() user: UserContext,
    @Body() createTaskLinkDto: CreateTaskLinkDto,
  ) {
    return this.taskLinkService.create(
      user.orgId,
      user.userId,
      createTaskLinkDto,
    );
  }

  @Get('task/:taskId')
  @ApiOperation({ summary: 'Get all links for a task' })
  @ApiParam({ name: 'taskId', description: 'Task ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'List of task links',
    type: [TaskLinkResponseDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async findByTask(
    @CurrentUser() user: UserContext,
    @Param('taskId', ParseUUIDPipe) taskId: string,
  ) {
    return this.taskLinkService.findByTask(user.orgId, taskId);
  }

  @Get('task/:taskId/blocking')
  @ApiOperation({ summary: 'Get tasks that are blocking this task' })
  @ApiParam({ name: 'taskId', description: 'Task ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'List of blocking tasks',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async getBlockingTasks(
    @CurrentUser() user: UserContext,
    @Param('taskId', ParseUUIDPipe) taskId: string,
  ) {
    return this.taskLinkService.getBlockingTasks(user.orgId, taskId);
  }

  @Get('task/:taskId/dependent')
  @ApiOperation({ summary: 'Get tasks that depend on this task' })
  @ApiParam({ name: 'taskId', description: 'Task ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'List of dependent tasks',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async getDependentTasks(
    @CurrentUser() user: UserContext,
    @Param('taskId', ParseUUIDPipe) taskId: string,
  ) {
    return this.taskLinkService.getDependentTasks(user.orgId, taskId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get task link by ID' })
  @ApiParam({ name: 'id', description: 'Link ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Task link details',
    type: TaskLinkResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task link not found' })
  async findOne(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.taskLinkService.findOne(user.orgId, id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete task link' })
  @ApiParam({ name: 'id', description: 'Link ID', format: 'uuid' })
  @ApiResponse({ status: 204, description: 'Task link deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Task link not found' })
  async remove(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.taskLinkService.remove(user.orgId, id);
  }
}
