import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
  ApiParam,
  ApiQuery,
} from "@nestjs/swagger";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { TenantGuard } from "../../common/guards/tenant.guard";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Permissions } from "../../common/decorators/permissions.decorator";
import { UserContext } from "../auth/auth.service";
import { TaskService } from "./task.service";
import {
  CreateTaskDto,
  UpdateTaskDto,
  TaskQueryDto,
  TaskResponseDto,
  TaskSummarizerDto,
  TaskSummaryResponseDto,
} from "./dto/task.dto";
import { TaskStatus } from "../../common/enums";

@ApiTags("Tasks")
@Controller("tasks")
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth("bearer")
export class TaskController {
  constructor(private readonly taskService: TaskService) {}

  @Post()
  @UseGuards(PermissionsGuard)
  @Permissions("CREATE_TASK")
  @ApiOperation({ summary: "Create a new task" })
  @ApiResponse({
    status: 201,
    description: "Task created successfully",
    type: TaskResponseDto,
  })
  @ApiResponse({ status: 400, description: "Invalid input" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Project not found" })
  async create(
    @CurrentUser() user: UserContext,
    @Body() createTaskDto: CreateTaskDto,
  ) {
    return this.taskService.create(
      user.orgId,
      user.userId,
      user.role,
      createTaskDto,
    );
  }

  @Get()
  @ApiOperation({ summary: "Get all tasks for the organization" })
  @ApiResponse({
    status: 200,
    description: "List of tasks",
    schema: {
      type: "object",
      properties: {
        data: {
          type: "array",
          items: { $ref: "#/components/schemas/TaskResponseDto" },
        },
        total: { type: "number" },
        page: { type: "number" },
        limit: { type: "number" },
      },
    },
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async findAll(
    @CurrentUser() user: UserContext,
    @Query() query: TaskQueryDto,
  ) {
    return this.taskService.findAll(user.orgId, user.userId, user.role, query);
  }

  @Get(":id")
  @ApiOperation({ summary: "Get task by ID" })
  @ApiParam({ name: "id", description: "Task ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Task details",
    type: TaskResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Task not found" })
  async findOne(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.taskService.findOne(user.orgId, id);
  }

  @Get("code/:taskCode")
  @ApiOperation({ summary: "Get task by task code" })
  @ApiParam({ name: "taskCode", description: "Task code (e.g., PROJ-123)" })
  @ApiResponse({
    status: 200,
    description: "Task details",
    type: TaskResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Task not found" })
  async findByCode(
    @CurrentUser() user: UserContext,
    @Param("taskCode") taskCode: string,
  ) {
    return this.taskService.findByTaskCode(user.orgId, taskCode);
  }

  @Put(":id")
  @ApiOperation({ summary: "Update task" })
  @ApiParam({ name: "id", description: "Task ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Task updated successfully",
    type: TaskResponseDto,
  })
  @ApiResponse({ status: 400, description: "Invalid input" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Task not found" })
  async update(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() updateTaskDto: UpdateTaskDto,
  ) {
    return this.taskService.update(
      user.orgId,
      id,
      updateTaskDto,
      user.userId,
      user.role,
    );
  }

  @Patch(":id/status")
  @ApiOperation({ summary: "Update task status" })
  @ApiParam({ name: "id", description: "Task ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Task status updated",
    type: TaskResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Task not found" })
  async updateStatus(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body("status") status: TaskStatus,
  ) {
    return this.taskService.updateStatus(
      user.orgId,
      id,
      status,
      user.userId,
      user.role,
    );
  }

  @Patch(":id/assign")
  @ApiOperation({
    summary: "Assign task to a user or unassign with cascade for epics/stories",
  })
  @ApiParam({ name: "id", description: "Task ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Task assigned/unassigned successfully",
    type: TaskResponseDto,
  })
  @ApiResponse({ status: 400, description: "User not assigned to project" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Task not found" })
  async assignTask(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body("assigneeId") assigneeId: string | null,
  ) {
    return this.taskService.assignTask(
      user.orgId,
      id,
      assigneeId,
      user.userId,
      user.role,
    );
  }

  @Get(":id/cascade-preview")
  @ApiOperation({
    summary:
      "Get preview of tasks that will be cascaded when assigning this epic/story",
  })
  @ApiParam({ name: "id", description: "Task ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Cascade preview",
    schema: {
      type: "object",
      properties: {
        cascadeCount: {
          type: "number",
          description: "Number of child tasks that will be affected",
        },
        cascadedTasks: {
          type: "array",
          items: { $ref: "#/components/schemas/TaskResponseDto" },
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Task not found" })
  async getCascadePreview(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.taskService.getCascadePreview(user.orgId, id);
  }

  @Patch(":id/sprint")
  @ApiOperation({ summary: "Move task to a sprint (or to backlog if null)" })
  @ApiParam({ name: "id", description: "Task ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Task moved to sprint",
    type: TaskResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Task not found" })
  async moveToSprint(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body("sprintId") sprintId: string | null,
  ) {
    return this.taskService.moveToSprint(
      user.orgId,
      id,
      sprintId,
      user.userId,
      user.role,
    );
  }

  @Patch(":id/tags")
  @ApiOperation({ summary: "Assign tags to a task" })
  @ApiParam({ name: "id", description: "Task ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Tags assigned successfully",
    type: TaskResponseDto,
  })
  @ApiResponse({ status: 400, description: "Invalid or inactive tags" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Task not found" })
  async assignTags(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body("tagIds") tagIds: string[],
  ) {
    return this.taskService.assignTagsToTask(
      user.orgId,
      id,
      tagIds,
      user.userId,
      user.role,
    );
  }

  @Delete(":id")
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Delete task" })
  @ApiParam({ name: "id", description: "Task ID", format: "uuid" })
  @ApiResponse({ status: 204, description: "Task deleted successfully" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Task not found" })
  async remove(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.taskService.remove(user.orgId, id, user.role);
  }

  @Get("sprint/:sprintId")
  @ApiOperation({ summary: "Get all tasks in a sprint" })
  @ApiParam({ name: "sprintId", description: "Sprint ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "List of tasks in sprint",
    type: [TaskResponseDto],
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async findBySprintId(
    @CurrentUser() user: UserContext,
    @Param("sprintId", ParseUUIDPipe) sprintId: string,
  ) {
    return this.taskService.findBySprintId(user.orgId, sprintId);
  }

  @Post(":id/summarize")
  @ApiOperation({ summary: "Generate AI summary for a task" })
  @ApiParam({ name: "id", description: "Task ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Task summary generated successfully",
    type: TaskSummaryResponseDto,
  })
  @ApiResponse({ status: 400, description: "AI service unavailable" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Task not found" })
  async summarizeTask(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() summarizerDto: TaskSummarizerDto,
  ): Promise<TaskSummaryResponseDto> {
    return this.taskService.summarizeTask(
      user.orgId,
      id,
      summarizerDto.focusLength || "standard",
    );
  }
}
