import {
  Injectable,
  Logger,
  NotFoundException,
  ConflictException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Project } from '../../entities/project.entity';
import { UserProjectMapping } from '../../entities/user-project-mapping.entity';
import { ProjectTaskSequence } from '../../entities/project-task-sequence.entity';
import { ProjectLink } from '../../entities/project-link.entity';
import { AppUser } from '../../entities/app-user.entity';
import { Sprint } from '../../entities/sprint.entity';
import {
  CreateProjectDto,
  UpdateProjectDto,
  AssignUserToProjectDto,
  AddProjectLinkDto,
  ProjectQueryDto,
  ProjectType,
  UpdateTeamMemberAllocationDto,
} from './dto/project.dto';
import { deriveDisplayNameFromEmail } from '../../common/services/email-name.service';
import { ActivityLogService } from '../activity-log/activity-log.service';

@Injectable()
export class ProjectService {
  private readonly logger = new Logger(ProjectService.name);

  private readonly privilegedOrgRoles = new Set(['ADMIN', 'ORG_ADMIN', 'CEO']);

  constructor(
    @InjectRepository(Project)
    private readonly projectRepository: Repository<Project>,
    @InjectRepository(UserProjectMapping)
    private readonly userProjectMappingRepository: Repository<UserProjectMapping>,
    @InjectRepository(ProjectTaskSequence)
    private readonly sequenceRepository: Repository<ProjectTaskSequence>,
    @InjectRepository(ProjectLink)
    private readonly projectLinkRepository: Repository<ProjectLink>,
    @InjectRepository(AppUser)
    private readonly appUserRepository: Repository<AppUser>,
    @InjectRepository(Sprint)
    private readonly sprintRepository: Repository<Sprint>,
    private readonly dataSource: DataSource,
    private readonly activityLogService: ActivityLogService,
  ) {}

  private normalizeStringArray(values?: string[]): string[] {
    return (values ?? [])
      .map((v) => v.trim())
      .filter((v, index, arr) => v.length > 0 && arr.indexOf(v) === index);
  }

  private validateDateOrder(kickoffDate?: string, startDate?: string, endDate?: string): void {
    if (kickoffDate && startDate && new Date(kickoffDate) > new Date(startDate)) {
      throw new BadRequestException('Kick-off date must be earlier than or equal to start date');
    }

    if (startDate && endDate && new Date(startDate) > new Date(endDate)) {
      throw new BadRequestException('Start date must be earlier than or equal to end date');
    }
  }

  private async assertFinanceCodeUnique(orgId: string, financeCode?: string, excludeProjectId?: string): Promise<void> {
    if (!financeCode) {
      return;
    }

    const queryBuilder = this.projectRepository
      .createQueryBuilder('project')
      .where('project.orgId = :orgId', { orgId })
      .andWhere('project.financeCode = :financeCode', { financeCode });

    if (excludeProjectId) {
      queryBuilder.andWhere('project.id != :excludeProjectId', { excludeProjectId });
    }

    const existing = await queryBuilder.getOne();

    if (existing) {
      throw new ConflictException('Finance code already exists in this organization');
    }
  }

  private async assertProjectAdminAccess(
    orgId: string,
    projectId: string,
    userId: string,
    userRole: string,
  ): Promise<void> {
    if (this.privilegedOrgRoles.has(userRole)) {
      return;
    }

    if (userRole !== 'MANAGER') {
      throw new ForbiddenException('Insufficient permissions for this project');
    }

    const project = await this.projectRepository.findOne({
      where: { id: projectId, orgId },
      select: ['id', 'managerId'],
    });

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    const hasMapping = await this.userProjectMappingRepository.exist({
      where: {
        orgId,
        projectId,
        userId,
        status: 'ACTIVE',
        approvalStatus: 'APPROVED',
      },
    });

    if (project.managerId !== userId && !hasMapping) {
      throw new ForbiddenException('Managers can only manage their own projects');
    }
  }

  /**
   * Create a new project
   */
  async create(orgId: string, dto: CreateProjectDto, createdById?: string): Promise<Project> {
    // Check for duplicate project code
    const existing = await this.projectRepository.findOne({
      where: { projectCode: dto.projectCode },
    });

    if (existing) {
      throw new ConflictException('Project code already exists');
    }

    // Verify manager belongs to organization
    if (dto.managerId) {
      const manager = await this.appUserRepository.findOne({
        where: { id: dto.managerId, orgId },
      });

      if (!manager) {
        throw new BadRequestException('Manager not found in organization');
      }
    }

    // Verify delivery manager belongs to organization
    if (dto.deliveryManagerId) {
      const deliveryManager = await this.appUserRepository.findOne({
        where: { id: dto.deliveryManagerId, orgId },
      });

      if (!deliveryManager) {
        throw new BadRequestException('Delivery manager not found in organization');
      }
    }

    // Verify sponsor belongs to organization
    if (dto.sponsorId) {
      const sponsor = await this.appUserRepository.findOne({
        where: { id: dto.sponsorId, orgId },
      });

      if (!sponsor) {
        throw new BadRequestException('Sponsor not found in organization');
      }
    }

    // Verify finance member belongs to organization
    if (dto.financeMemberId) {
      const financeMember = await this.appUserRepository.findOne({
        where: { id: dto.financeMemberId, orgId },
      });

      if (!financeMember) {
        throw new BadRequestException('Finance member not found in organization');
      }
    }

    this.validateDateOrder(dto.kickoffDate, dto.startDate, dto.endDate);

    // Validate contract dates if provided
    if (dto.contractStartDate && dto.contractEndDate) {
      if (new Date(dto.contractStartDate) > new Date(dto.contractEndDate)) {
        throw new BadRequestException('Contract start date must be earlier than or equal to contract end date');
      }
    }

    const financeCode = dto.financeCode?.trim();
    await this.assertFinanceCodeUnique(orgId, financeCode);

    if (dto.budget !== undefined && dto.budget < 0) {
      throw new BadRequestException('Budget cannot be negative');
    }

    const normalizedTechStack = this.normalizeStringArray(dto.techStack);
    const normalizedDependencies = this.normalizeStringArray(dto.dependencies);
    const normalizedStageGates = this.normalizeStringArray(dto.stageGates);

    // Use transaction to create project and initialize sequence
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const project = queryRunner.manager.create(Project, {
        ...dto,
        orgId,
        createdById,
        financeCode,
        projectType: dto.projectType?.toUpperCase(),
        techStack: normalizedTechStack,
        dependencies: normalizedDependencies,
        stageGates: normalizedStageGates,
        status: dto.status || 'DRAFT',
      });

      const savedProject = await queryRunner.manager.save(project);

      // Initialize task sequence for the project
      const sequence = queryRunner.manager.create(ProjectTaskSequence, {
        projectId: savedProject.id,
        lastSequence: 0,
      });
      await queryRunner.manager.save(sequence);

      await queryRunner.commitTransaction();

      this.logger.log(`Project created: ${savedProject.projectCode} (${savedProject.id})`);

      void this.activityLogService.create({
        orgId,
        actorUserId: createdById,
        method: 'POST',
        resourceType: 'project',
        resourceId: savedProject.id,
        actionType: 'PROJECT_CREATED',
        message: `Project '${savedProject.name}' (${savedProject.projectCode}) created`,
        requestPath: '/projects',
      });

      return savedProject;
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Get all projects for organization
   */
  async findAll(
    orgId: string,
    userId: string,
    userRole: string,
    query: ProjectQueryDto,
  ): Promise<{ data: Project[]; total: number; page: number; limit: number }> {
    const { page = 1, limit = 20, ...filters } = query;
    const skip = (page - 1) * limit;

    const queryBuilder = this.projectRepository
      .createQueryBuilder('project')
      .where('project.org_id = :orgId', { orgId });

    // ORG_ADMIN and CEO can see all projects.
    // MANAGER can only see projects allocated to them (managed or assigned).
    if (userRole === 'MANAGER') {
      queryBuilder
        .leftJoin(
          'user_project_mapping',
          'upm',
          'upm.project_id = project.id AND upm.user_id = :userId',
          { userId },
        )
        .andWhere('(project.manager_id = :userId OR upm.user_id IS NOT NULL)', { userId });
    } else if (!this.privilegedOrgRoles.has(userRole)) {
      queryBuilder
        .innerJoin(
          'user_project_mapping',
          'upm',
          'upm.project_id = project.id AND upm.user_id = :userId',
          { userId },
        );
    }

    // Always exclude archived projects unless explicitly requested
    if (filters.status) {
      queryBuilder.andWhere('project.status = :status', { status: filters.status });
    } else {
      queryBuilder.andWhere("project.status != 'ARCHIVED'");
    }

    if (filters.search) {
      queryBuilder.andWhere(
        '(project.name ILIKE :search OR project.project_code ILIKE :search)',
        { search: `%${filters.search}%` },
      );
    }

    const total = await queryBuilder.getCount();

    const data = await queryBuilder
      .orderBy('project.createdAt', 'DESC')
      .skip(skip)
      .take(limit)
      .getMany();

    return { data, total, page, limit };
  }

  /**
   * Get project by ID — includes manager, links, team size and active sprint
   */
  async findOne(orgId: string, projectId: string): Promise<Project & { teamSize: number; activeSprint: Pick<Sprint, 'id' | 'name' | 'status'> | null }> {
    const project = await this.projectRepository.findOne({
      where: { id: projectId, orgId },
      relations: ['manager', 'links', 'userMappings', 'userMappings.user', 'financeMember'],
    });

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    const [teamSize, activeSprint] = await Promise.all([
      this.userProjectMappingRepository.count({
        where: { projectId, status: 'ACTIVE', approvalStatus: 'APPROVED' },
      }),
      this.sprintRepository.findOne({
        where: { projectId, status: 'ACTIVE' },
        select: ['id', 'name', 'status'],
      }),
    ]);

    return { ...project, teamSize, activeSprint: activeSprint ?? null };
  }

  async findOneForUser(
    orgId: string,
    projectId: string,
    userId: string,
    userRole: string,
  ): Promise<Project & { teamSize: number; activeSprint: Pick<Sprint, 'id' | 'name' | 'status'> | null }> {
    const project = await this.findOne(orgId, projectId);

    if (this.privilegedOrgRoles.has(userRole)) {
      return project;
    }

    if (userRole === 'MANAGER' && project.managerId === userId) {
      return project;
    }

    const hasMapping = await this.userProjectMappingRepository.exist({
      where: {
        orgId,
        projectId,
        userId,
      },
    });

    if (!hasMapping) {
      throw new ForbiddenException('You are not assigned to this project');
    }

    return project;
  }

  /**
   * Update project
   */
  async update(
    orgId: string,
    projectId: string,
    dto: UpdateProjectDto,
  ): Promise<Project> {
    const project = await this.findOne(orgId, projectId);

    // Verify new manager belongs to organization
    if (dto.managerId) {
      const manager = await this.appUserRepository.findOne({
        where: { id: dto.managerId, orgId },
      });

      if (!manager) {
        throw new BadRequestException('Manager not found in organization');
      }
    }

    // Verify finance member belongs to organization
    if (dto.financeMemberId) {
      const financeMember = await this.appUserRepository.findOne({
        where: { id: dto.financeMemberId, orgId },
      });

      if (!financeMember) {
        throw new BadRequestException('Finance member not found in organization');
      }
    }

    // Verify finance member belongs to organization
    if (dto.financeMemberId) {
      const financeMember = await this.appUserRepository.findOne({
        where: { id: dto.financeMemberId, orgId },
      });

      if (!financeMember) {
        throw new BadRequestException('Finance member not found in organization');
      }
    }

    this.validateDateOrder(dto.kickoffDate, dto.startDate, dto.endDate);

    const financeCode = dto.financeCode?.trim();
    await this.assertFinanceCodeUnique(orgId, financeCode, projectId);

    if (dto.budget !== undefined && dto.budget < 0) {
      throw new BadRequestException('Budget cannot be negative');
    }

    const payload: UpdateProjectDto = {
      ...dto,
      ...(financeCode !== undefined ? { financeCode } : {}),
      ...(dto.projectType ? { projectType: dto.projectType.toUpperCase() as ProjectType } : {}),
      ...(dto.techStack ? { techStack: this.normalizeStringArray(dto.techStack) } : {}),
      ...(dto.dependencies ? { dependencies: this.normalizeStringArray(dto.dependencies) } : {}),
    };

    Object.assign(project, payload);
    const updated = await this.projectRepository.save(project);

    this.logger.log(`Project updated: ${updated.projectCode} (${updated.id})`);

    void this.activityLogService.create({
      orgId,
      method: 'PUT',
      resourceType: 'project',
      resourceId: projectId,
      actionType: 'PROJECT_UPDATED',
      message: `Project '${updated.name}' (${updated.projectCode}) updated`,
      requestPath: `/projects/${projectId}`,
    });

    return updated;
  }

  /**
   * Archive project (soft delete)
   */
  async remove(orgId: string, projectId: string): Promise<void> {
    const project = await this.findOne(orgId, projectId);
    project.status = 'ARCHIVED';
    await this.projectRepository.save(project);

    this.logger.log(`Project archived: ${project.projectCode} (${projectId})`);

    void this.activityLogService.create({
      orgId,
      method: 'DELETE',
      resourceType: 'project',
      resourceId: projectId,
      actionType: 'PROJECT_ARCHIVED',
      message: `Project '${project.name}' (${project.projectCode}) archived`,
      requestPath: `/projects/${projectId}`,
    });
  }

  /**
  /**
   * Assign user to project with bandwidth allocation
   * Creates a PENDING approval record that requires manager/admin approval
   */
  async assignUser(
    orgId: string,
    projectId: string,
    dto: AssignUserToProjectDto,
    actorUserId: string,
    actorRole: string,
  ): Promise<UserProjectMapping> {
    await this.assertProjectAdminAccess(orgId, projectId, actorUserId, actorRole);
    await this.findOne(orgId, projectId);

    const email = dto.email.toLowerCase().trim();
    const normalizedRole = dto.projectRole.trim().toUpperCase();
    const normalizedResourceType = dto.resourceType.trim().toUpperCase();

    // Find existing user in org or create a stub
    let user = await this.appUserRepository.findOne({
      where: { email, orgId },
    });

    if (!user) {
      this.logger.log(`User ${email} not in org ${orgId} — pre-provisioning stub`);
      user = this.appUserRepository.create({
        email,
        name: deriveDisplayNameFromEmail(email),
        orgId,
        role: 'USER',
        status: 'ACTIVE',
      });
      user = await this.appUserRepository.save(user);
    }

    // Check if same role already exists in this project
    const existing = await this.userProjectMappingRepository.findOne({
      where: { userId: user.id, projectId, projectRole: normalizedRole },
    });

    if (existing) {
      throw new BadRequestException(
        `User ${email} is already assigned in role ${normalizedRole} for this project. Use Edit to change bandwidth for that role.`,
      );
    }

    // Validate bandwidth allocation
    const validationError = await this.validateBandwidthAllocation(user.id, dto.allocatedBandwidth);
    if (validationError) {
      throw new BadRequestException(validationError);
    }

    // Create new mapping with PENDING approval status
    const mapping = this.userProjectMappingRepository.create({
      userId: user.id,
      projectId,
      orgId,
      projectRole: normalizedRole,
      resourceType: normalizedResourceType,
      allocatedBandwidth: dto.allocatedBandwidth,
      approvalStatus: 'PENDING',
    });

    const saved = await this.userProjectMappingRepository.save(mapping);
    this.logger.log(
      `User ${email} assigned to project ${projectId} as ${normalizedRole} (${normalizedResourceType}) with ${dto.allocatedBandwidth}% bandwidth (pending approval)`,
    );

    return saved;
  }

  /**
   * Remove user from project
   */
  async removeUser(
    orgId: string,
    projectId: string,
    mappingId: string,
    actorUserId: string,
    actorRole: string,
  ): Promise<void> {
    await this.assertProjectAdminAccess(orgId, projectId, actorUserId, actorRole);
    const project = await this.findOne(orgId, projectId);

    const mapping = await this.userProjectMappingRepository.findOne({
      where: { id: mappingId, projectId },
    });

    if (!mapping) {
      throw new NotFoundException('User not assigned to this project');
    }

    await this.userProjectMappingRepository.remove(mapping);
    this.logger.log(`Team mapping ${mappingId} removed from project ${projectId}`);
  }

  /**
   * Get project team members
   */
  async getTeamMembers(
    orgId: string,
    projectId: string,
  ): Promise<UserProjectMapping[]> {
    await this.findOne(orgId, projectId);

    return this.userProjectMappingRepository.find({
      where: { projectId },
      relations: ['user'],
    });
  }

  /**
   * Add link to project
   */
  async addLink(
    orgId: string,
    projectId: string,
    dto: AddProjectLinkDto,
  ): Promise<ProjectLink> {
    await this.findOne(orgId, projectId);

    const link = this.projectLinkRepository.create({
      projectId,
      linkType: dto.linkType,
      url: dto.url,
    });

    const saved = await this.projectLinkRepository.save(link);
    this.logger.log(`Link added to project ${projectId}: ${dto.linkType}`);

    return saved;
  }

  /**
   * Remove link from project
   */
  async removeLink(
    orgId: string,
    projectId: string,
    linkId: string,
  ): Promise<void> {
    await this.findOne(orgId, projectId);

    const link = await this.projectLinkRepository.findOne({
      where: { id: linkId, projectId },
    });

    if (!link) {
      throw new NotFoundException('Link not found');
    }

    await this.projectLinkRepository.remove(link);
    this.logger.log(`Link removed from project ${projectId}: ${linkId}`);
  }

  /**
   * Get project links
   */
  async getLinks(orgId: string, projectId: string): Promise<ProjectLink[]> {
    await this.findOne(orgId, projectId);

    return this.projectLinkRepository.find({
      where: { projectId },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Calculate total bandwidth allocation for a user across all projects
   * Counts both APPROVED and PENDING allocations
   */
  async calculateTotalBandwidth(userId: string): Promise<number> {
    const mappings = await this.userProjectMappingRepository.find({
      where: [
        { userId, approvalStatus: 'APPROVED' },
        { userId, approvalStatus: 'PENDING' },
      ],
    });

    return mappings.reduce((total, mapping) => total + mapping.allocatedBandwidth, 0);
  }

  /**
   * Validate that bandwidth allocation does not exceed 100%
   * Returns error message if invalid, null if valid
   * Includes both APPROVED and PENDING allocations in calculation
   */
  async validateBandwidthAllocation(
    userId: string,
    newBandwidth: number,
    excludeMappingId?: string,
  ): Promise<string | null> {
    if (newBandwidth < 1 || newBandwidth > 100) {
      return 'Bandwidth must be between 1 and 100';
    }

    // Get all approved and pending allocations for this user
    let query = this.userProjectMappingRepository.createQueryBuilder('upm')
      .where('upm.userId = :userId', { userId })
      .andWhere("upm.approvalStatus IN ('APPROVED', 'PENDING')");

    // Exclude the current mapping if updating/approving existing allocation
    if (excludeMappingId) {
      query = query.andWhere('upm.id != :mappingId', { mappingId: excludeMappingId });
    }

    const mappings = await query.getMany();
    const totalAllocated = mappings.reduce((sum, m) => sum + m.allocatedBandwidth, 0);

    if (totalAllocated + newBandwidth > 100) {
      const available = 100 - totalAllocated;
      return `Employee already allocated ${totalAllocated}%. Only ${available}% available. Cannot allocate ${newBandwidth}%.`;
    }

    return null;
  }

  /**
   * Approve or reject a bandwidth allocation request
   */
  async approveBandwidthAllocation(
    orgId: string,
    projectId: string,
    mappingId: string,
    approvalStatus: 'APPROVED' | 'REJECTED',
    approvedByUserId: string,
    approvedByRole: string,
  ): Promise<UserProjectMapping | null> {
    await this.assertProjectAdminAccess(orgId, projectId, approvedByUserId, approvedByRole);
    const project = await this.findOne(orgId, projectId);

    let mapping = await this.userProjectMappingRepository.findOne({
      where: { id: mappingId, projectId },
    });

    // Backward compatibility: if caller still sends userId instead of mappingId,
    // resolve the latest pending allocation for that user in this project.
    if (!mapping) {
      const pendingMappings = await this.userProjectMappingRepository.find({
        where: { userId: mappingId, projectId, approvalStatus: 'PENDING' },
        order: { createdAt: 'DESC' },
      });

      if (pendingMappings.length === 1) {
        mapping = pendingMappings[0];
      } else if (pendingMappings.length > 1) {
        throw new BadRequestException(
          'Multiple pending allocations found for this user in the project. Please refresh and approve a specific role row.',
        );
      }
    }

    if (!mapping) {
      throw new NotFoundException('User not assigned to this project');
    }

    if (mapping.approvalStatus !== 'PENDING') {
      throw new BadRequestException(
        `Cannot approve allocation with status ${mapping.approvalStatus}. Only PENDING allocations can be approved.`,
      );
    }

    if (approvalStatus === 'REJECTED') {
      // Delete the mapping when rejected
      await this.userProjectMappingRepository.remove(mapping);
      this.logger.log(
        `Bandwidth allocation mapping ${mapping.id} in project ${projectId} rejected and removed`,
      );
      return null;
    }

    if (approvalStatus === 'APPROVED') {
      // Validate bandwidth before approving - exclude current mapping to avoid double-counting
      const validationError = await this.validateBandwidthAllocation(
        mapping.userId,
        mapping.allocatedBandwidth,
        mapping.id,
      );
      if (validationError) {
        throw new BadRequestException(validationError);
      }
    }

    mapping.approvalStatus = approvalStatus;
    mapping.approvedByUserId = approvedByUserId;
    mapping.approvedAt = new Date();

    const updated = await this.userProjectMappingRepository.save(mapping);
    this.logger.log(
      `Bandwidth allocation mapping ${mappingId} in project ${projectId} ${approvalStatus}`,
    );

    return updated;
  }

  /**
   * Update bandwidth allocation for an existing project assignment
   */
  async updateBandwidthAllocation(
    orgId: string,
    projectId: string,
    mappingId: string,
    newBandwidth: number,
    actorUserId: string,
    actorRole: string,
  ): Promise<UserProjectMapping> {
    await this.assertProjectAdminAccess(orgId, projectId, actorUserId, actorRole);
    const project = await this.findOne(orgId, projectId);

    const mapping = await this.userProjectMappingRepository.findOne({
      where: { id: mappingId, projectId },
    });

    if (!mapping) {
      throw new NotFoundException('User not assigned to this project');
    }

    // Validate new bandwidth allocation
    const validationError = await this.validateBandwidthAllocation(
      mapping.userId,
      newBandwidth,
      mapping.id, // Exclude current mapping from calculation
    );

    if (validationError) {
      throw new BadRequestException(validationError);
    }

    const oldBandwidth = mapping.allocatedBandwidth;
    mapping.allocatedBandwidth = newBandwidth;
    // Keep the current approval status, don't reset to PENDING
    const updated = await this.userProjectMappingRepository.save(mapping);

    this.logger.log(
      `Bandwidth updated for mapping ${mappingId} in project ${projectId}: ${oldBandwidth}% -> ${newBandwidth}%`,
    );

    return updated;
  }

  async updateTeamMemberAllocation(
    orgId: string,
    projectId: string,
    mappingId: string,
    dto: UpdateTeamMemberAllocationDto,
    actorUserId: string,
    actorRole: string,
  ): Promise<UserProjectMapping> {
    await this.assertProjectAdminAccess(orgId, projectId, actorUserId, actorRole);
    await this.findOne(orgId, projectId);

    const mapping = await this.userProjectMappingRepository.findOne({
      where: { id: mappingId, projectId },
    });

    if (!mapping) {
      throw new NotFoundException('User not assigned to this project');
    }

    const hasRoleUpdate = dto.projectRole !== undefined;
    const hasBandwidthUpdate = dto.allocatedBandwidth !== undefined;

    if (!hasRoleUpdate && !hasBandwidthUpdate) {
      throw new BadRequestException('Provide at least one field: projectRole or allocatedBandwidth');
    }

    const oldRole = mapping.projectRole;
    const oldBandwidth = mapping.allocatedBandwidth;

    if (hasRoleUpdate) {
      const normalizedRole = dto.projectRole!.trim().toUpperCase();
      const duplicateRoleMapping = await this.userProjectMappingRepository.findOne({
        where: {
          projectId,
          userId: mapping.userId,
          projectRole: normalizedRole,
        },
      });

      if (duplicateRoleMapping && duplicateRoleMapping.id !== mapping.id) {
        throw new ConflictException(
          `User is already assigned in role ${normalizedRole} for this project`,
        );
      }

      mapping.projectRole = normalizedRole;
    }

    if (hasBandwidthUpdate) {
      const newBandwidth = dto.allocatedBandwidth!;
      const validationError = await this.validateBandwidthAllocation(
        mapping.userId,
        newBandwidth,
        mapping.id,
      );

      if (validationError) {
        throw new BadRequestException(validationError);
      }

      mapping.allocatedBandwidth = newBandwidth;
    }

    const updated = await this.userProjectMappingRepository.save(mapping);
    this.logger.log(
      `Team member allocation updated for mapping ${mappingId} in project ${projectId}: role ${oldRole} -> ${updated.projectRole}, bandwidth ${oldBandwidth}% -> ${updated.allocatedBandwidth}%`,
    );

    return updated;
  }
}

