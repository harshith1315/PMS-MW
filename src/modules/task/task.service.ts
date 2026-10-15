import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository, DataSource, In, IsNull, FindOptionsWhere } from "typeorm";
import { Task } from "../../entities/task.entity";
import { Project } from "../../entities/project.entity";
import { ProjectTaskSequence } from "../../entities/project-task-sequence.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import { TimeLog } from "../../entities/time-log.entity";
import { TaskLink } from "../../entities/task-link.entity";
import { TaskComment } from "../../entities/task-comment.entity";
import { Tag } from "../../entities/tag.entity";
import {
  CreateTaskDto,
  UpdateTaskDto,
  TaskQueryDto,
  TaskSummaryResponseDto,
} from "./dto/task.dto";
import { TaskStatus, TaskType, TaskLinkType } from "../../common/enums";
import { NotificationService } from "../notification/notification.service";
import { LlmService } from "../chat/llm.service";
import { AppUser } from "../../entities/app-user.entity";
import { ActivityLogService } from "../activity-log/activity-log.service";

type SummaryParseSection = "summary" | "actions" | "blockers";

@Injectable()
export class TaskService {
  private readonly logger = new Logger(TaskService.name);

  private readonly privilegedOrgRoles = new Set(["ADMIN", "ORG_ADMIN"]);

  constructor(
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
    @InjectRepository(Project)
    private readonly projectRepository: Repository<Project>,
    @InjectRepository(ProjectTaskSequence)
    private readonly sequenceRepository: Repository<ProjectTaskSequence>,
    @InjectRepository(UserProjectMapping)
    private readonly userProjectMappingRepository: Repository<UserProjectMapping>,
    @InjectRepository(TimeLog)
    private readonly timeLogRepository: Repository<TimeLog>,
    @InjectRepository(AppUser)
    private readonly appUserRepository: Repository<AppUser>,
    @InjectRepository(Tag)
    private readonly tagRepository: Repository<Tag>,
    @InjectRepository(TaskComment)
    private readonly commentRepository: Repository<TaskComment>,
    private readonly dataSource: DataSource,
    private readonly notificationService: NotificationService,
    private readonly llmService: LlmService,
    private readonly activityLogService: ActivityLogService,
  ) {}

  private isPrivilegedRole(userRole: string): boolean {
    return this.privilegedOrgRoles.has(userRole) || userRole === "MANAGER";
  }

  private async getAccessibleProjectIds(
    orgId: string,
    userId: string,
    userRole: string,
  ): Promise<string[] | null> {
    if (this.isPrivilegedRole(userRole)) {
      return null;
    }

    const mappedProjects = await this.userProjectMappingRepository.find({
      where: {
        orgId,
        userId,
        status: "ACTIVE",
        approvalStatus: "APPROVED",
      },
      select: ["projectId"],
    });

    if (userRole !== "MANAGER") {
      return [...new Set(mappedProjects.map((mapping) => mapping.projectId))];
    }

    const managedProjects = await this.projectRepository.find({
      where: { orgId, managerId: userId },
      select: ["id"],
    });

    return [
      ...new Set([
        ...mappedProjects.map((mapping) => mapping.projectId),
        ...managedProjects.map((project) => project.id),
      ]),
    ];
  }

  private async assertTaskMutationAllowed(
    task: Task,
    actorUserId: string,
    actorRole: string,
  ): Promise<void> {
    if (this.isPrivilegedRole(actorRole)) {
      return;
    }

    if (!task.assignedTo || task.assignedTo !== actorUserId) {
      throw new ForbiddenException("You can only update tasks assigned to you");
    }
  }

  /**
   * Create a new task with auto-generated task code
   * Uses transaction with row locking for sequence generation
   */
  async create(
    orgId: string,
    userId: string,
    userRole: string,
    dto: CreateTaskDto,
  ): Promise<Task> {
    const { parentTaskId, epicId, storyId, ...taskPayload } = dto;

    // Verify project exists and belongs to organization
    const project = await this.projectRepository.findOne({
      where: { id: taskPayload.projectId, orgId },
    });

    if (!project) {
      throw new NotFoundException("Project not found");
    }

    const accessibleProjectIds = await this.getAccessibleProjectIds(
      orgId,
      userId,
      userRole,
    );

    if (
      accessibleProjectIds &&
      !accessibleProjectIds.includes(taskPayload.projectId)
    ) {
      throw new ForbiddenException(
        "You are not allowed to create tasks in this project",
      );
    }

    if (parentTaskId) {
      const parentTask = await this.taskRepository.findOne({
        where: { id: parentTaskId, orgId },
      });

      if (!parentTask) {
        throw new NotFoundException("Parent task not found");
      }

      if (parentTask.projectId !== taskPayload.projectId) {
        throw new BadRequestException(
          "Subtask must belong to the same project as parent task",
        );
      }
    }

    // Validate Epic ΓåÆ Story ΓåÆ Task hierarchy
    let resolvedEpicId: string | null = epicId ?? null;

    if (taskPayload.taskType === TaskType.STORY) {
      if (!epicId) {
        throw new BadRequestException(
          "epicId is required when creating a Story",
        );
      }
      const epicTask = await this.taskRepository.findOne({
        where: { id: epicId, orgId },
        select: ["id", "taskType", "projectId"],
      });
      if (!epicTask) {
        throw new NotFoundException("Epic not found");
      }
      if (epicTask.taskType !== TaskType.EPIC) {
        throw new BadRequestException("epicId must reference an EPIC task");
      }
      if (epicTask.projectId !== taskPayload.projectId) {
        throw new BadRequestException(
          "Story must belong to the same project as its Epic",
        );
      }
    }

    if (storyId) {
      const storyTask = await this.taskRepository.findOne({
        where: { id: storyId, orgId },
        select: ["id", "taskType", "projectId", "epicId"],
      });
      if (!storyTask) {
        throw new NotFoundException("Story not found");
      }
      if (storyTask.taskType !== TaskType.STORY) {
        throw new BadRequestException("storyId must reference a STORY task");
      }
      if (storyTask.projectId !== taskPayload.projectId) {
        throw new BadRequestException(
          "Task must belong to the same project as its Story",
        );
      }
      // Auto-propagate epicId from the parent story when not explicitly provided
      if (!resolvedEpicId && storyTask.epicId) {
        resolvedEpicId = storyTask.epicId;
      }
    }

    if (taskPayload.assignedTo) {
      const assigneeMapping = await this.userProjectMappingRepository.findOne({
        where: {
          orgId,
          userId: taskPayload.assignedTo,
          projectId: taskPayload.projectId,
          status: "ACTIVE",
          approvalStatus: "APPROVED",
        },
      });

      if (!assigneeMapping) {
        throw new BadRequestException(
          "Assigned user must be an approved member of the project",
        );
      }
    }

    // Use transaction for task code generation
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Get and lock the sequence row
      let sequence = await queryRunner.manager.findOne(ProjectTaskSequence, {
        where: { projectId: taskPayload.projectId },
        lock: { mode: "pessimistic_write" },
      });

      // Initialize sequence if not exists
      if (!sequence) {
        sequence = queryRunner.manager.create(ProjectTaskSequence, {
          projectId: taskPayload.projectId,
          lastSequence: 0,
        });
      }

      // Increment sequence
      sequence.lastSequence += 1;
      await queryRunner.manager.save(sequence);

      // Generate task code: PROJECTCODE-SEQ
      const taskCode = `${project.projectCode}-${sequence.lastSequence}`;

      // Create task
      const task = queryRunner.manager.create(Task, {
        ...taskPayload,
        orgId,
        createdBy: userId,
        taskCode,
        status: taskPayload.status || TaskStatus.TODO,
        taskType: parentTaskId
          ? TaskType.SUB_TASK
          : (taskPayload.taskType ?? TaskType.TASK),
        ...(resolvedEpicId ? { epicId: resolvedEpicId } : {}),
        ...(storyId ? { storyId } : {}),
      });

      const savedTask = await queryRunner.manager.save(task);

      if (parentTaskId) {
        const parentLink = queryRunner.manager.create(TaskLink, {
          orgId,
          sourceTaskId: parentTaskId,
          targetTaskId: savedTask.id,
          linkType: TaskLinkType.PARENT_OF,
          createdBy: userId,
        });

        const childLink = queryRunner.manager.create(TaskLink, {
          orgId,
          sourceTaskId: savedTask.id,
          targetTaskId: parentTaskId,
          linkType: TaskLinkType.CHILD_OF,
          createdBy: userId,
        });

        await queryRunner.manager.save(TaskLink, [parentLink, childLink]);
      }

      await queryRunner.commitTransaction();

      this.logger.log(`Task created: ${taskCode} (${savedTask.id})`);

      void this.activityLogService.create({
        orgId,
        actorUserId: userId,
        method: "POST",
        resourceType: "task",
        resourceId: savedTask.id,
        actionType: "TASK_CREATED",
        message: `Task '${savedTask.title}' (${taskCode}) created`,
        requestPath: `/tasks`,
      });

      return savedTask;
    } catch (error: unknown) {
      await queryRunner.rollbackTransaction();
      const message = error instanceof Error ? error.message : "Unknown error";
      const stack = error instanceof Error ? error.stack : undefined;
      this.logger.error(`Failed to create task: ${message}`, stack);
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Get all tasks for organization with filtering and pagination
   */
  async findAll(
    orgId: string,
    userId: string,
    userRole: string,
    query: TaskQueryDto,
  ): Promise<{ data: Task[]; total: number; page: number; limit: number }> {
    const { page = 1, limit = 20, ...filters } = query;
    const skip = (page - 1) * limit;
    const isSelfAssignedQuery = filters.assignedTo === userId;

    const accessibleProjectIds = await this.getAccessibleProjectIds(
      orgId,
      userId,
      userRole,
    );

    if (
      accessibleProjectIds &&
      accessibleProjectIds.length === 0 &&
      !isSelfAssignedQuery
    ) {
      return { data: [], total: 0, page, limit };
    }

    if (
      filters.projectId &&
      accessibleProjectIds &&
      !isSelfAssignedQuery &&
      !accessibleProjectIds.includes(filters.projectId)
    ) {
      throw new ForbiddenException("You are not assigned to this project");
    }

    // Build query
    const queryBuilder = this.taskRepository
      .createQueryBuilder("task")
      .where("task.org_id = :orgId", { orgId });

    // Apply project access filter for non-admin/non-manager users
    if (accessibleProjectIds && !isSelfAssignedQuery) {
      queryBuilder.andWhere("task.project_id IN (:...projectIds)", {
        projectIds: accessibleProjectIds,
      });
    }

    // Apply filters
    if (filters.projectId) {
      queryBuilder.andWhere("task.project_id = :projectId", {
        projectId: filters.projectId,
      });
    }
    if (filters.sprintId) {
      queryBuilder.andWhere("task.sprint_id = :sprintId", {
        sprintId: filters.sprintId,
      });
    }
    if (filters.status) {
      queryBuilder.andWhere("task.status = :status", {
        status: filters.status,
      });
    }
    if (filters.taskType) {
      queryBuilder.andWhere("task.task_type = :taskType", {
        taskType: filters.taskType,
      });
    }
    if (filters.priority) {
      queryBuilder.andWhere("task.priority = :priority", {
        priority: filters.priority,
      });
    }
    if (filters.epicId) {
      queryBuilder.andWhere("task.epic_id = :epicId", {
        epicId: filters.epicId,
      });
    }
    if (filters.storyId) {
      queryBuilder.andWhere("task.story_id = :storyId", {
        storyId: filters.storyId,
      });
    }
    if (filters.assignedTo) {
      queryBuilder.andWhere("task.assigned_to = :assignedTo", {
        assignedTo: filters.assignedTo,
      });
    }

    // Search filter
    if (filters.search) {
      queryBuilder.andWhere(
        "(task.title ILIKE :search OR task.description ILIKE :search OR task.task_code ILIKE :search)",
        { search: `%${filters.search}%` },
      );
    }

    // Get total count
    const total = await queryBuilder.getCount();

    // Apply pagination and get results
    const data = await queryBuilder
      .orderBy("task.createdAt", "DESC")
      .skip(skip)
      .take(limit)
      .getMany();

    return { data, total, page, limit };
  }

  /**
   * Get task by ID
   */
  async findOne(
    orgId: string,
    taskId: string,
  ): Promise<Task & { totalHoursLogged: number }> {
    const [task, timeLogResult] = await Promise.all([
      this.taskRepository.findOne({
        where: { id: taskId, orgId },
        relations: [
          "assignee",
          "creator",
          "blocker",
          "sprint",
          "project",
          "tags",
          "attachments",
          "comments",
          "comments.user",
          "epic",
          "story",
        ],
      }),
      this.timeLogRepository
        .createQueryBuilder("tl")
        .select("SUM(tl.minutes)", "totalMinutes")
        .where("tl.task_id = :taskId", { taskId })
        .andWhere("tl.org_id = :orgId", { orgId })
        .getRawOne(),
    ]);

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    const totalMinutes = Number(timeLogResult?.totalMinutes) || 0;

    return {
      ...task,
      totalHoursLogged: Math.round((totalMinutes / 60) * 100) / 100,
    };
  }

  /**
   * Get task by task code
   */
  async findByTaskCode(orgId: string, taskCode: string): Promise<Task> {
    const task = await this.taskRepository.findOne({
      where: { taskCode, orgId },
      relations: ["assignee", "creator", "sprint", "project", "tags"],
    });

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    return task;
  }

  /**
   * Update task
   */
  async update(
    orgId: string,
    taskId: string,
    dto: UpdateTaskDto,
    userId: string,
    userRole: string,
  ): Promise<Task> {
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    await this.assertTaskMutationAllowed(task, userId, userRole);

    // Update task fields
    Object.assign(task, dto);

    const updatedTask = await this.taskRepository.save(task);

    this.logger.log(`Task updated: ${task.taskCode} (${taskId})`);

    void this.activityLogService.create({
      orgId,
      actorUserId: userId,
      method: "PUT",
      resourceType: "task",
      resourceId: taskId,
      actionType: "TASK_UPDATED",
      message: `Task '${task.title}' (${task.taskCode}) updated`,
      requestPath: `/tasks/${taskId}`,
    });

    return updatedTask;
  }

  /**
   * Assign tags to a task
   */
  async assignTagsToTask(
    orgId: string,
    taskId: string,
    tagIds: string[],
    userId: string,
    userRole: string,
  ): Promise<Task> {
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
      relations: ["tags"],
    });

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    await this.assertTaskMutationAllowed(task, userId, userRole);

    // Verify all tags exist and belong to the same org
    const tags = await this.tagRepository.find({
      where: {
        id: In(tagIds),
        orgId,
        status: "ACTIVE",
      },
    });

    if (tags.length !== tagIds.length) {
      throw new BadRequestException("One or more tags not found or inactive");
    }

    // Update the task's tags relation
    task.tags = tags;
    const updatedTask = await this.taskRepository.save(task);

    this.logger.log(`Task ${task.taskCode} tags updated by user ${userId}`);

    return updatedTask;
  }

  /**
   * Delete task (soft delete by changing status)
   */
  async remove(orgId: string, taskId: string, userRole: string): Promise<void> {
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    if (!this.isPrivilegedRole(userRole)) {
      throw new ForbiddenException(
        "Only manager or org admin can delete tasks",
      );
    }

    await this.taskRepository.remove(task);

    this.logger.log(`Task deleted: ${task.taskCode} (${taskId})`);
  }

  /**
   * Find all child tasks of an epic or story
   * For Epic: returns all direct stories and tasks under it
   * For Story: returns all tasks/subtasks under it
   */
  private async findChildTasks(orgId: string, task: Task): Promise<Task[]> {
    const children: Task[] = [];

    if (task.taskType === TaskType.EPIC) {
      // Find all stories directly under this epic
      const storiesUnderEpic = await this.taskRepository.find({
        where: {
          orgId,
          epicId: task.id,
          taskType: TaskType.STORY,
        },
      });

      children.push(...storiesUnderEpic);

      // Find all story IDs for recursive task search
      const storyIds = storiesUnderEpic.map((s) => s.id);

      // Find all tasks/subtasks under these stories
      if (storyIds.length > 0) {
        const tasksUnderStories = await this.taskRepository.find({
          where: {
            orgId,
            storyId: In(storyIds),
          },
        });
        children.push(...tasksUnderStories);
      }

      // Also find direct tasks under the epic (without a story)
      const directTasksUnderEpic = await this.taskRepository.find({
        where: {
          orgId,
          epicId: task.id,
          storyId: IsNull(),
          taskType: In([TaskType.TASK, TaskType.SUB_TASK]),
        },
      });

      children.push(...directTasksUnderEpic);
    } else if (task.taskType === TaskType.STORY) {
      // Find all tasks/subtasks under this story
      const tasksUnderStory = await this.taskRepository.find({
        where: {
          orgId,
          storyId: task.id,
        },
      });

      children.push(...tasksUnderStory);
    }

    return children;
  }

  /**
   * Assign task to user with cascade support for epics and stories
   * When assigneeId is null: Unassigns task and optionally cascades unassignment
   * When assigning an Epic: cascades to all stories and tasks under it
   * When assigning a Story: cascades to all tasks/subtasks under it
   * When assigning a Task/Subtask: only assigns that task
   */
  async assignTask(
    orgId: string,
    taskId: string,
    assigneeId: string | null,
    userId: string,
    userRole: string,
  ): Promise<Task> {
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    if (!this.isPrivilegedRole(userRole)) {
      const accessibleProjectIds = await this.getAccessibleProjectIds(
        orgId,
        userId,
        userRole,
      );

      if (
        !accessibleProjectIds ||
        !accessibleProjectIds.includes(task.projectId)
      ) {
        throw new ForbiddenException(
          "You are not allowed to assign tasks in this project",
        );
      }

      if (task.assignedTo && task.assignedTo !== userId) {
        throw new ForbiddenException(
          "You can only assign unassigned tasks or tasks assigned to you",
        );
      }
    }

    // If assigning to a user, verify they are assigned to the project
    if (assigneeId) {
      const mapping = await this.userProjectMappingRepository.findOne({
        where: {
          orgId,
          userId: assigneeId,
          projectId: task.projectId,
          status: "ACTIVE",
          approvalStatus: "APPROVED",
        },
      });

      if (!mapping) {
        throw new BadRequestException(
          "User is not an approved active member of this project",
        );
      }
    }

    // Use transaction for cascade assignment
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Assign/unassign the main task
      task.assignedTo = assigneeId;
      const updatedTask = await queryRunner.manager.save(task);

      // Cascade assignment for epics and stories
      if (task.taskType === TaskType.EPIC || task.taskType === TaskType.STORY) {
        const childTasks = await this.findChildTasks(orgId, task);

        if (childTasks.length > 0) {
          // Update all child tasks
          await queryRunner.manager.update(
            Task,
            {
              id: In(childTasks.map((t) => t.id)),
            },
            {
              assignedTo: assigneeId,
            },
          );

          this.logger.log(
            `Cascaded ${assigneeId ? "assignment" : "unassignment"} of ${task.taskCode}: ${childTasks.length} children updated`,
          );
        }
      }

      await queryRunner.commitTransaction();

      this.logger.log(
        `Task ${task.taskCode} ${assigneeId ? "assigned" : "unassigned"} ${assigneeId ? "to user " + assigneeId : ""}`,
      );

      void this.activityLogService.create({
        orgId,
        actorUserId: userId,
        method: "PATCH",
        resourceType: "task",
        resourceId: taskId,
        actionType: "TASK_ASSIGNED",
        message: assigneeId
          ? `Task '${task.title}' (${task.taskCode}) assigned to user ${assigneeId}`
          : `Task '${task.title}' (${task.taskCode}) unassigned`,
        requestPath: `/tasks/${taskId}/assign`,
        metadata: { assigneeId },
      });

      return updatedTask;
    } catch (error: unknown) {
      await queryRunner.rollbackTransaction();
      const message = error instanceof Error ? error.message : "Unknown error";
      const stack = error instanceof Error ? error.stack : undefined;
      this.logger.error(`Failed to assign task: ${message}`, stack);
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Get tasks that will be affected by cascading assignment for an epic or story
   * Useful for showing preview in UI before actually assigning
   */
  async getCascadePreview(
    orgId: string,
    taskId: string,
  ): Promise<{ cascadeCount: number; cascadedTasks: Task[] }> {
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    if (task.taskType !== TaskType.EPIC && task.taskType !== TaskType.STORY) {
      return { cascadeCount: 0, cascadedTasks: [] };
    }

    const cascadedTasks = await this.findChildTasks(orgId, task);

    return {
      cascadeCount: cascadedTasks.length,
      cascadedTasks,
    };
  }

  /**
   * Update task status
   */
  async updateStatus(
    orgId: string,
    taskId: string,
    status: TaskStatus,
    userId: string,
    userRole: string,
  ): Promise<Task> {
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
      relations: ["project", "assignee"],
    });
    if (!task) {
      throw new NotFoundException("Task not found");
    }

    await this.assertTaskMutationAllowed(task, userId, userRole);

    // If task is currently BLOCKED and we're trying to change status from it
    if (task.status === TaskStatus.BLOCKED && status !== TaskStatus.BLOCKED) {
      const isOrgAdmin = this.privilegedOrgRoles.has(userRole);
      const isBlocker = task.blockedBy === userId;
      const isProjectManager = task.project?.managerId === userId;

      if (!isOrgAdmin && !isBlocker && !isProjectManager) {
        throw new ForbiddenException(
          "Only the user who blocked this task or the project manager can unblock it",
        );
      }
    }

    // If setting status to BLOCKED
    if (status === TaskStatus.BLOCKED && task.status !== TaskStatus.BLOCKED) {
      task.blockedBy = userId;

      // Fetch blocker details for notification
      const blocker = await this.appUserRepository.findOne({
        where: { id: userId },
      });

      // Create notifications for task assignee and project manager.
      // The project manager is ALWAYS notified (they must know when any task is blocked).
      // The assignee is notified only if they weren't the one who blocked the task.
      const recipients = new Set<string>();

      if (task.assignedTo && task.assignedTo !== userId) {
        recipients.add(task.assignedTo);
      }

      if (task.project?.managerId) {
        recipients.add(task.project.managerId);
      }

      // Send notifications
      const blockerName = blocker?.name || "A user";
      const notificationDtos = Array.from(recipients).map((recipientId) => ({
        recipientId,
        taskId,
        type: "TASK_BLOCKED",
        title: "Task Blocked",
        message: `Task "${task.title}" has been blocked by ${blockerName}`,
        metadata: {
          blockedBy: userId,
          taskCode: task.taskCode,
          taskTitle: task.title,
          blockerName,
        },
      }));

      if (notificationDtos.length > 0) {
        try {
          await this.notificationService.createBatch(notificationDtos);
        } catch (err: unknown) {
          const message = err instanceof Error ? err.message : "Unknown error";
          this.logger.error(
            `Failed to create blocked-task notifications for task ${task.taskCode}: ${message}`,
          );
        }
      }
    }

    // If unsetting BLOCKED status
    if (task.status === TaskStatus.BLOCKED && status !== TaskStatus.BLOCKED) {
      task.blockedBy = null as any;
    }

    task.status = status;
    await this.taskRepository.save(task);

    this.logger.log(`Task ${task.taskCode} status updated to ${status}`);

    void this.activityLogService.create({
      orgId,
      actorUserId: userId,
      method: "PATCH",
      resourceType: "task",
      resourceId: taskId,
      actionType: "TASK_STATUS_UPDATED",
      message: `Task '${task.title}' (${task.taskCode}) status changed to ${status}`,
      requestPath: `/tasks/${taskId}/status`,
      metadata: { status },
    });

    // Reload with all relations so the response includes blocker, assignee, etc.
    const reloaded = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
      relations: [
        "assignee",
        "creator",
        "blocker",
        "sprint",
        "project",
        "tags",
      ],
    });

    return reloaded!;
  }

  /**
   * Get tasks by sprint
   */
  async findBySprintId(orgId: string, sprintId: string): Promise<Task[]> {
    return this.taskRepository.find({
      where: { sprintId, orgId },
      relations: ["assignee"],
      order: { createdAt: "DESC" },
    });
  }

  /**
   * Move task to sprint
   */
  async moveToSprint(
    orgId: string,
    taskId: string,
    sprintId: string | null,
    userId: string,
    userRole: string,
  ): Promise<Task> {
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    await this.assertTaskMutationAllowed(task, userId, userRole);

    task.sprintId = sprintId;
    const updatedTask = await this.taskRepository.save(task);

    this.logger.log(
      `Task ${task.taskCode} moved to sprint ${sprintId || "backlog"}`,
    );

    void this.activityLogService.create({
      orgId,
      actorUserId: userId,
      method: "PATCH",
      resourceType: "task",
      resourceId: taskId,
      actionType: "TASK_SPRINT_UPDATED",
      message: sprintId
        ? `Task '${task.title}' (${task.taskCode}) moved to sprint`
        : `Task '${task.title}' (${task.taskCode}) moved to backlog`,
      requestPath: `/tasks/${taskId}/sprint`,
      metadata: { sprintId },
    });

    return updatedTask;
  }

  /**
   * Generate AI summary for a task using LLM service
   * Gathers task context (title, description, comments, related tasks) and generates a professional summary
   */
  async summarizeTask(
    orgId: string,
    taskId: string,
    focusLength: "brief" | "standard" | "detailed" = "standard",
  ): Promise<TaskSummaryResponseDto> {
    const startTime = Date.now();

    // Fetch task with all relevant context
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
      relations: ["assignee", "creator", "sprint", "project"],
    });

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    // Fetch comments
    const comments = await this.commentRepository.find({
      where: { taskId },
      relations: ["user"],
      order: { createdAt: "DESC" },
      take: 10,
    });

    // Fetch related tasks (blocked by, blocking)
    const relatedTaskWhere: FindOptionsWhere<Task>[] = [
      { blockedBy: taskId, orgId },
    ];
    if (task.blockedBy) {
      relatedTaskWhere.push({ id: task.blockedBy, orgId });
    }

    const relatedTasks = await this.taskRepository.find({
      where: relatedTaskWhere,
      select: ["id", "title", "status", "priority"],
    });

    // Build context for LLM
    const taskContext = this.buildTaskSummaryContext(
      task,
      comments,
      relatedTasks,
      focusLength,
    );

    try {
      // Generate summary using LLM
      const summary = await this.llmService.generate(taskContext);

      // Parse summary to extract action items and blockers
      const { summaryText, actionItems, blockers } =
        this.parseAISummary(summary);

      const processingTimeMs = Date.now() - startTime;

      return {
        taskId: task.id,
        title: task.title,
        summary: summaryText,
        actionItems,
        blockers,
        generatedAt: new Date().toISOString(),
        processingTimeMs,
      };
    } catch (error) {
      this.logger.error(`Failed to summarize task ${taskId}:`, error);
      throw new BadRequestException(
        "AI service unavailable. Please try again later.",
      );
    }
  }

  /**
   * Build context prompt for task summarization
   */
  private buildTaskSummaryContext(
    task: Task,
    comments: TaskComment[],
    relatedTasks: Task[],
    focusLength: string,
  ): string {
    const lengthGuidance =
      {
        brief: "Create a brief 2-3 line summary",
        standard: "Create a 5-7 line professional summary",
        detailed: "Create a comprehensive 10-15 line detailed summary",
      }[focusLength] || "Create a 5-7 line professional summary";

    const commentsSection =
      comments.length > 0
        ? `Recent Comments:\n${comments
            .map((c) => `- ${c.user?.name || "Unknown"}: ${c.comment}`)
            .join("\n")}`
        : "No comments";

    const relatedTasksSection =
      relatedTasks.length > 0
        ? `Related Tasks:\n${relatedTasks
            .map(
              (t) =>
                `- ${t.title} (Status: ${t.status}, Priority: ${t.priority})`,
            )
            .join("\n")}`
        : "No related tasks";

    return `
TASK SUMMARIZATION REQUEST

Task: ${task.title}
Task Code: ${task.taskCode || "N/A"}
Status: ${task.status || "Not set"}
Priority: ${task.priority || "Not set"}
Type: ${task.taskType || "Not set"}
Due Date: ${task.dueDate ? new Date(task.dueDate).toLocaleDateString() : "Not set"}
Assigned To: ${task.assignee?.name || "Unassigned"}
Sprint: ${task.sprint?.name || "Backlog"}

Description:
${task.description || "No description provided"}

Output/Implementation Notes:
${task.outputDescription || "Not specified"}

${commentsSection}

${relatedTasksSection}

INSTRUCTIONS:
${lengthGuidance}

Focus on:
1. Clear summary of what needs to be done
2. Action items required
3. Any blockers or dependencies
4. Risk areas if applicable

Format your response as:
SUMMARY: [Your summary here]
ACTION ITEMS:
- [Item 1]
- [Item 2]
...
BLOCKERS: [List blockers or "None identified"]

Please provide a professional, concise summary suitable for team communication.
`;
  }

  /**
   * Parse AI-generated summary to extract structured data
   */
  private parseAISummary(aiResponse: string): {
    summaryText: string;
    actionItems: string[];
    blockers: string[];
  } {
    const summaryLines: string[] = [];
    const actionLines: string[] = [];
    const blockerLines: string[] = [];

    let currentSection: SummaryParseSection | null = null;

    for (const rawLine of aiResponse.split("\n")) {
      const line = rawLine.trim();
      const section = this.parseSummarySectionHeader(line);
      if (section) {
        currentSection = section.section;
        this.appendLineForSection(
          section.section,
          section.value,
          summaryLines,
          actionLines,
          blockerLines,
        );
        continue;
      }

      if (!line || !currentSection) {
        continue;
      }

      this.appendLineForSection(
        currentSection,
        line,
        summaryLines,
        actionLines,
        blockerLines,
      );
    }

    const summaryText = (
      summaryLines.join(" ").trim() || aiResponse.trim()
    ).slice(0, 500);

    const actionItems = actionLines
      .map((line) => line.trim())
      .filter((line) => line.startsWith("-"))
      .map((line) => line.slice(1).trim())
      .filter((item) => item.length > 0);

    const blockersText = blockerLines.join(" ").trim() || "None identified";
    const blockers = this.splitBlockers(blockersText);

    return { summaryText, actionItems, blockers };
  }

  private appendLineForSection(
    section: SummaryParseSection,
    value: string,
    summaryLines: string[],
    actionLines: string[],
    blockerLines: string[],
  ): void {
    if (!value) {
      return;
    }

    if (section === "summary") {
      summaryLines.push(value);
      return;
    }

    if (section === "actions") {
      actionLines.push(value);
      return;
    }

    blockerLines.push(value);
  }

  private parseSummarySectionHeader(
    line: string,
  ): { section: SummaryParseSection; value: string } | null {
    const upper = line.toUpperCase();

    const markers: Array<{
      marker: "SUMMARY:" | "ACTION ITEMS:" | "BLOCKERS:";
      section: SummaryParseSection;
    }> = [
      { marker: "SUMMARY:", section: "summary" },
      { marker: "ACTION ITEMS:", section: "actions" },
      { marker: "BLOCKERS:", section: "blockers" },
    ];

    for (const markerConfig of markers) {
      if (upper.startsWith(markerConfig.marker)) {
        return {
          section: markerConfig.section,
          value: line.slice(markerConfig.marker.length).trim(),
        };
      }
    }

    return null;
  }

  private splitBlockers(blockersText: string): string[] {
    if (blockersText.toLowerCase() === "none identified") {
      return [];
    }

    const blockers: string[] = [];
    let token = "";

    for (const char of blockersText) {
      if (char === "," || char === ";") {
        const part = token.trim();
        if (part) blockers.push(part);
        token = "";
      } else {
        token += char;
      }
    }

    const tail = token.trim();
    if (tail) blockers.push(tail);

    return blockers;
  }
}
