import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { In, Repository } from "typeorm";
import { Sprint } from "../../entities/sprint.entity";
import { Project } from "../../entities/project.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import { CreateSprintDto, UpdateSprintDto } from "./dto/sprint.dto";
import { SprintStatus } from "../../common/enums";
import { ActivityLogService } from "../activity-log/activity-log.service";

@Injectable()
export class SprintService {
  private readonly logger = new Logger(SprintService.name);

  private readonly privilegedOrgRoles = new Set(["ADMIN", "ORG_ADMIN"]);

  constructor(
    @InjectRepository(Sprint)
    private readonly sprintRepository: Repository<Sprint>,
    @InjectRepository(Project)
    private readonly projectRepository: Repository<Project>,
    @InjectRepository(UserProjectMapping)
    private readonly userProjectMappingRepository: Repository<UserProjectMapping>,
    private readonly activityLogService: ActivityLogService,
  ) {}

  private async getAccessibleProjectIds(
    orgId: string,
    userId: string,
    userRole: string,
  ): Promise<string[] | null> {
    if (this.privilegedOrgRoles.has(userRole)) {
      return null;
    }

    const mappings = await this.userProjectMappingRepository.find({
      where: {
        orgId,
        userId,
        status: "ACTIVE",
        approvalStatus: "APPROVED",
      },
      select: ["projectId"],
    });

    if (userRole !== "MANAGER") {
      return [...new Set(mappings.map((mapping) => mapping.projectId))];
    }

    const managedProjects = await this.projectRepository.find({
      where: { orgId, managerId: userId },
      select: ["id"],
    });

    return [
      ...new Set([
        ...mappings.map((mapping) => mapping.projectId),
        ...managedProjects.map((project) => project.id),
      ]),
    ];
  }

  private async assertSprintAdminAccess(
    orgId: string,
    userId: string,
    userRole: string,
    projectId: string,
  ): Promise<void> {
    if (this.privilegedOrgRoles.has(userRole)) {
      return;
    }

    const accessibleProjectIds = await this.getAccessibleProjectIds(
      orgId,
      userId,
      userRole,
    );

    if (!accessibleProjectIds?.includes(projectId)) {
      throw new ForbiddenException(
        "You can only manage sprints in projects assigned to you",
      );
    }
  }

  async create(
    orgId: string,
    userId: string,
    userRole: string,
    dto: CreateSprintDto,
  ): Promise<Sprint> {
    // Verify project belongs to org
    const project = await this.projectRepository.findOne({
      where: { id: dto.projectId, orgId },
    });

    if (!project) {
      throw new NotFoundException("Project not found");
    }

    await this.assertSprintAdminAccess(orgId, userId, userRole, dto.projectId);

    // Validate dates
    if (
      dto.startDate &&
      dto.endDate &&
      new Date(dto.startDate) > new Date(dto.endDate)
    ) {
      throw new BadRequestException("Start date must be before end date");
    }

    const sprint = this.sprintRepository.create({
      projectId: dto.projectId,
      name: dto.sprintName,
      goal: dto.goal,
      startDate: dto.startDate,
      endDate: dto.endDate,
      status: SprintStatus.PLANNED,
    });

    const saved = await this.sprintRepository.save(sprint);
    this.logger.log(`Sprint created: ${saved.name} (${saved.id})`);

    void this.activityLogService.create({
      orgId,
      actorUserId: userId,
      method: 'POST',
      resourceType: 'sprint',
      resourceId: saved.id,
      actionType: 'SPRINT_CREATED',
      message: `Sprint '${saved.name}' created`,
      requestPath: '/sprints',
    });

    return saved;
  }

  async findAll(
    orgId: string,
    userId: string,
    userRole: string,
    projectId?: string,
  ): Promise<Sprint[]> {
    const accessibleProjectIds = await this.getAccessibleProjectIds(
      orgId,
      userId,
      userRole,
    );

    if (accessibleProjectIds && accessibleProjectIds.length === 0) {
      return [];
    }

    if (
      projectId &&
      accessibleProjectIds &&
      !accessibleProjectIds.includes(projectId)
    ) {
      throw new ForbiddenException("You are not assigned to this project");
    }

    const queryBuilder = this.sprintRepository
      .createQueryBuilder("sprint")
      .innerJoin("project", "project", "project.id = sprint.project_id")
      .where("project.org_id = :orgId", { orgId });

    if (accessibleProjectIds) {
      queryBuilder.andWhere("sprint.project_id IN (:...projectIds)", {
        projectIds: accessibleProjectIds,
      });
    }

    if (projectId) {
      queryBuilder.andWhere("sprint.project_id = :projectId", { projectId });
    }

    return queryBuilder.orderBy("sprint.startDate", "ASC").getMany();
  }

  async findOne(
    orgId: string,
    sprintId: string,
    userId: string,
    userRole: string,
  ): Promise<Sprint> {
    const accessibleProjectIds = await this.getAccessibleProjectIds(
      orgId,
      userId,
      userRole,
    );

    const sprint = await this.sprintRepository
      .createQueryBuilder("sprint")
      .innerJoin("project", "project", "project.id = sprint.project_id")
      .where("sprint.id = :sprintId", { sprintId })
      .andWhere("project.org_id = :orgId", { orgId })
      .andWhere(
        accessibleProjectIds ? "sprint.project_id IN (:...projectIds)" : "1=1",
        accessibleProjectIds ? { projectIds: accessibleProjectIds } : {},
      )
      .getOne();

    if (!sprint) {
      throw new NotFoundException("Sprint not found");
    }

    return sprint;
  }

  async update(
    orgId: string,
    sprintId: string,
    dto: UpdateSprintDto,
    userId: string,
    userRole: string,
  ): Promise<Sprint> {
    const sprint = await this.findOne(orgId, sprintId, userId, userRole);
    await this.assertSprintAdminAccess(
      orgId,
      userId,
      userRole,
      sprint.projectId,
    );

    // Validate dates
    const startDate = dto.startDate
      ? new Date(dto.startDate)
      : sprint.startDate;
    const endDate = dto.endDate ? new Date(dto.endDate) : sprint.endDate;

    if (startDate && endDate && startDate > endDate) {
      throw new BadRequestException("Start date must be before end date");
    }

    if (dto.sprintName !== undefined) sprint.name = dto.sprintName;
    if (dto.goal !== undefined) sprint.goal = dto.goal;
    if (dto.definition !== undefined) sprint.definition = dto.definition;
    if (dto.startDate !== undefined) sprint.startDate = new Date(dto.startDate);
    if (dto.endDate !== undefined) sprint.endDate = new Date(dto.endDate);
    if (dto.status !== undefined) sprint.status = dto.status;
    const updated = await this.sprintRepository.save(sprint);

    this.logger.log(`Sprint updated: ${updated.name} (${updated.id})`);

    void this.activityLogService.create({
      orgId,
      actorUserId: userId,
      method: 'PATCH',
      resourceType: 'sprint',
      resourceId: sprintId,
      actionType: 'SPRINT_UPDATED',
      message: `Sprint '${updated.name}' updated`,
      requestPath: `/sprints/${sprintId}`,
    });

    return updated;
  }

  async startSprint(
    orgId: string,
    sprintId: string,
    userId: string,
    userRole: string,
  ): Promise<Sprint> {
    const sprint = await this.findOne(orgId, sprintId, userId, userRole);
    await this.assertSprintAdminAccess(
      orgId,
      userId,
      userRole,
      sprint.projectId,
    );

    if (sprint.status !== SprintStatus.PLANNED) {
      throw new BadRequestException("Only planned sprints can be started");
    }

    // Check for active sprints in the same project
    const activeSprints = await this.sprintRepository.find({
      where: { projectId: sprint.projectId, status: SprintStatus.ACTIVE },
    });

    if (activeSprints.length > 0) {
      throw new BadRequestException(
        "There is already an active sprint in this project",
      );
    }

    sprint.status = SprintStatus.ACTIVE;
    if (!sprint.startDate) {
      sprint.startDate = new Date();
    }

    const updated = await this.sprintRepository.save(sprint);
    this.logger.log(`Sprint started: ${updated.name} (${updated.id})`);

    void this.activityLogService.create({
      orgId,
      actorUserId: userId,
      method: 'PATCH',
      resourceType: 'sprint',
      resourceId: sprintId,
      actionType: 'SPRINT_STARTED',
      message: `Sprint '${updated.name}' started`,
      requestPath: `/sprints/${sprintId}/start`,
    });

    return updated;
  }

  async completeSprint(
    orgId: string,
    sprintId: string,
    userId: string,
    userRole: string,
  ): Promise<Sprint> {
    const sprint = await this.findOne(orgId, sprintId, userId, userRole);
    await this.assertSprintAdminAccess(
      orgId,
      userId,
      userRole,
      sprint.projectId,
    );

    if (sprint.status !== SprintStatus.ACTIVE) {
      throw new BadRequestException("Only active sprints can be completed");
    }

    sprint.status = SprintStatus.COMPLETED;
    if (!sprint.endDate) {
      sprint.endDate = new Date();
    }

    const updated = await this.sprintRepository.save(sprint);
    this.logger.log(`Sprint completed: ${updated.name} (${updated.id})`);

    void this.activityLogService.create({
      orgId,
      actorUserId: userId,
      method: 'PATCH',
      resourceType: 'sprint',
      resourceId: sprintId,
      actionType: 'SPRINT_COMPLETED',
      message: `Sprint '${updated.name}' completed`,
      requestPath: `/sprints/${sprintId}/complete`,
    });

    return updated;
  }

  async remove(
    orgId: string,
    sprintId: string,
    userId: string,
    userRole: string,
  ): Promise<void> {
    const sprint = await this.findOne(orgId, sprintId, userId, userRole);
    await this.assertSprintAdminAccess(
      orgId,
      userId,
      userRole,
      sprint.projectId,
    );
    await this.sprintRepository.remove(sprint);

    this.logger.log(`Sprint deleted: ${sprint.name} (${sprintId})`);

    void this.activityLogService.create({
      orgId,
      actorUserId: userId,
      method: 'DELETE',
      resourceType: 'sprint',
      resourceId: sprintId,
      actionType: 'SPRINT_DELETED',
      message: `Sprint '${sprint.name}' deleted`,
      requestPath: `/sprints/${sprintId}`,
    });
  }
}
