import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import {
  IsString,
  IsUUID,
  IsOptional,
  IsEnum,
  IsDateString,
  MaxLength,
  IsNotEmpty,
} from "class-validator";
import { TaskType, TaskStatus, TaskPriority } from "../../../common/enums";

export class CreateTaskDto {
  @ApiProperty({ description: "Project ID", format: "uuid" })
  @IsUUID()
  @IsNotEmpty()
  projectId: string;

  @ApiProperty({ description: "Task title", maxLength: 255 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  title: string;

  @ApiPropertyOptional({ description: "Task description" })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ enum: TaskType, description: "Task type" })
  @IsEnum(TaskType)
  @IsOptional()
  taskType?: TaskType;

  @ApiPropertyOptional({
    enum: TaskStatus,
    description: "Task status",
    default: "TODO",
  })
  @IsEnum(TaskStatus)
  @IsOptional()
  status?: TaskStatus;

  @ApiPropertyOptional({ enum: TaskPriority, description: "Task priority" })
  @IsEnum(TaskPriority)
  @IsOptional()
  priority?: TaskPriority;

  @ApiPropertyOptional({ description: "Sprint ID", format: "uuid" })
  @IsUUID()
  @IsOptional()
  sprintId?: string;

  @ApiPropertyOptional({ description: "Assigned user ID", format: "uuid" })
  @IsUUID()
  @IsOptional()
  assignedTo?: string;

  @ApiPropertyOptional({ description: "Due date", format: "date" })
  @IsDateString()
  @IsOptional()
  dueDate?: string;

  @ApiPropertyOptional({
    description: "Parent task ID for subtask creation",
    format: "uuid",
  })
  @IsUUID()
  @IsOptional()
  parentTaskId?: string;

  @ApiPropertyOptional({ description: "Task output/implementation notes" })
  @IsString()
  @IsOptional()
  outputDescription?: string;

  @ApiPropertyOptional({
    description: "Epic task ID — required when taskType is STORY",
    format: "uuid",
  })
  @IsUUID()
  @IsOptional()
  epicId?: string;

  @ApiPropertyOptional({
    description: "Story task ID — links a Task/Bug/Spike to a parent Story",
    format: "uuid",
  })
  @IsUUID()
  @IsOptional()
  storyId?: string;
}

export class UpdateTaskDto {
  @ApiPropertyOptional({ description: "Task title", maxLength: 255 })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  title?: string;

  @ApiPropertyOptional({ description: "Task description" })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ enum: TaskType, description: "Task type" })
  @IsEnum(TaskType)
  @IsOptional()
  taskType?: TaskType;

  @ApiPropertyOptional({ enum: TaskStatus, description: "Task status" })
  @IsEnum(TaskStatus)
  @IsOptional()
  status?: TaskStatus;

  @ApiPropertyOptional({ enum: TaskPriority, description: "Task priority" })
  @IsEnum(TaskPriority)
  @IsOptional()
  priority?: TaskPriority;

  @ApiPropertyOptional({ description: "Sprint ID", format: "uuid" })
  @IsUUID()
  @IsOptional()
  sprintId?: string;

  @ApiPropertyOptional({ description: "Assigned user ID", format: "uuid" })
  @IsUUID()
  @IsOptional()
  assignedTo?: string;

  @ApiPropertyOptional({ description: "Due date", format: "date" })
  @IsDateString()
  @IsOptional()
  dueDate?: string;

  @ApiPropertyOptional({ description: "Task output/implementation notes" })
  @IsString()
  @IsOptional()
  outputDescription?: string;

  @ApiPropertyOptional({ description: "Epic task ID", format: "uuid" })
  @IsUUID()
  @IsOptional()
  epicId?: string;

  @ApiPropertyOptional({ description: "Story task ID", format: "uuid" })
  @IsUUID()
  @IsOptional()
  storyId?: string;
}

export class TaskQueryDto {
  @ApiPropertyOptional({ description: "Filter by project ID", format: "uuid" })
  @IsUUID()
  @IsOptional()
  projectId?: string;

  @ApiPropertyOptional({ description: "Filter by sprint ID", format: "uuid" })
  @IsUUID()
  @IsOptional()
  sprintId?: string;

  @ApiPropertyOptional({ enum: TaskStatus, description: "Filter by status" })
  @IsEnum(TaskStatus)
  @IsOptional()
  status?: TaskStatus;

  @ApiPropertyOptional({ enum: TaskType, description: "Filter by type" })
  @IsEnum(TaskType)
  @IsOptional()
  taskType?: TaskType;

  @ApiPropertyOptional({
    enum: TaskPriority,
    description: "Filter by priority",
  })
  @IsEnum(TaskPriority)
  @IsOptional()
  priority?: TaskPriority;

  @ApiPropertyOptional({
    description: "Filter by assigned user",
    format: "uuid",
  })
  @IsUUID()
  @IsOptional()
  assignedTo?: string;

  @ApiPropertyOptional({ description: "Search in title and description" })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({
    description: "Filter by epic task ID",
    format: "uuid",
  })
  @IsUUID()
  @IsOptional()
  epicId?: string;

  @ApiPropertyOptional({
    description: "Filter by story task ID",
    format: "uuid",
  })
  @IsUUID()
  @IsOptional()
  storyId?: string;

  @ApiPropertyOptional({ description: "Page number", default: 1 })
  @IsOptional()
  page?: number = 1;

  @ApiPropertyOptional({ description: "Items per page", default: 20 })
  @IsOptional()
  limit?: number = 20;
}

export class TaskResponseDto {
  @ApiProperty({ format: "uuid" })
  id: string;

  @ApiProperty({ format: "uuid" })
  orgId: string;

  @ApiProperty({ format: "uuid" })
  projectId: string;

  @ApiPropertyOptional({ format: "uuid" })
  sprintId?: string;

  @ApiProperty({ description: "Auto-generated task code (e.g., PROJ-123)" })
  taskCode: string;

  @ApiProperty()
  title: string;

  @ApiPropertyOptional()
  description?: string;

  @ApiPropertyOptional()
  outputDescription?: string;

  @ApiPropertyOptional({ enum: TaskType })
  taskType?: string;

  @ApiPropertyOptional({ enum: TaskStatus })
  status?: string;

  @ApiPropertyOptional({ enum: TaskPriority })
  priority?: string;

  @ApiPropertyOptional({ format: "uuid" })
  assignedTo?: string;

  @ApiPropertyOptional({ format: "uuid" })
  createdBy?: string;

  @ApiPropertyOptional({ format: "date" })
  dueDate?: Date;

  @ApiProperty({ format: "date-time" })
  createdAt: Date;
}

export class TaskSummarizerDto {
  @ApiProperty({ format: "uuid", description: "Task ID to summarize" })
  @IsUUID()
  @IsNotEmpty()
  taskId: string;

  @ApiPropertyOptional({
    description:
      "Summary focus: brief (3 lines), standard (5-7 lines), or detailed (10+ lines)",
    enum: ["brief", "standard", "detailed"],
    default: "standard",
  })
  @IsString()
  @IsOptional()
  focusLength?: "brief" | "standard" | "detailed" = "standard";
}

export class TaskSummaryResponseDto {
  @ApiProperty({ description: "Task ID" })
  taskId: string;

  @ApiProperty({ description: "Task title" })
  title: string;

  @ApiProperty({ description: "Generated AI summary" })
  summary: string;

  @ApiProperty({ description: "Key action items from the task" })
  actionItems: string[];

  @ApiProperty({ description: "Risk or blockers identified" })
  blockers: string[];

  @ApiProperty({ description: "Generation timestamp" })
  generatedAt: string;

  @ApiProperty({ description: "Time taken to generate summary in ms" })
  processingTimeMs: number;
}
