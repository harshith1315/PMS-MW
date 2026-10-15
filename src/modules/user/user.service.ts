import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  ConflictException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository, ILike } from "typeorm";
import { AppUser } from "../../entities/app-user.entity";
import { Role } from "../../entities/role.entity";
import { UserPermission } from "../../entities/user-permission.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import { UserDailySummary } from "../../entities/user-daily-summary.entity";
import { Task } from "../../entities/task.entity";
import { TimeLog } from "../../entities/time-log.entity";
import {
  UpdateUserDto,
  UpdateUserRoleDto,
  UpdateUserStatusDto,
  UserQueryDto,
  InviteUserDto,
  UserStatsDto,
  BulkInviteResultDto,
} from "./dto/user.dto";
import { ActivityLogService } from "../activity-log/activity-log.service";
import { deriveDisplayNameFromEmail } from "../../common/services/email-name.service";
import { createPasswordSetupToken } from "../../common/utils/auth-tokens";
import * as ExcelJS from "exceljs";

type UserWorkbookFile = {
  fileName: string;
  buffer: Buffer;
};

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(AppUser)
    private readonly userRepository: Repository<AppUser>,
    @InjectRepository(UserProjectMapping)
    private readonly userProjectMappingRepository: Repository<UserProjectMapping>,
    @InjectRepository(UserDailySummary)
    private readonly userDailySummaryRepository: Repository<UserDailySummary>,
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
    @InjectRepository(TimeLog)
    private readonly timeLogRepository: Repository<TimeLog>,
    @InjectRepository(Role)
    private readonly roleRepository: Repository<Role>,
    @InjectRepository(UserPermission)
    private readonly userPermissionRepository: Repository<UserPermission>,
    private readonly activityLogService: ActivityLogService,
  ) {}

  private async resolveRoleForAssignment(
    roleKey?: string,
    roleId?: string,
  ): Promise<Role> {
    let role: Role | null = null;

    if (roleId) {
      role = await this.roleRepository.findOne({
        where: { id: roleId, isActive: true },
      });
    } else if (roleKey) {
      role = await this.roleRepository.findOne({
        where: { key: roleKey.toUpperCase(), isActive: true },
      });
    }

    if (!role) {
      throw new BadRequestException("Invalid role assignment payload");
    }

    return role;
  }

  private logUserActivity(params: {
    orgId: string;
    actionType: string;
    message: string;
    requestPath: string;
    resourceId: string;
    actorUserId?: string;
    metadata?: Record<string, unknown>;
    method?: "POST" | "PATCH" | "PUT" | "DELETE" | "GET";
  }): void {
    void this.activityLogService.create({
      orgId: params.orgId,
      actorUserId: params.actorUserId,
      method: params.method ?? "PATCH",
      resourceType: "user",
      resourceId: params.resourceId,
      actionType: params.actionType,
      message: params.message,
      requestPath: params.requestPath,
      metadata: params.metadata,
    });
  }

  private resolveInviteFailureMessage(error: unknown): string {
    if (
      error instanceof BadRequestException ||
      error instanceof ConflictException
    ) {
      return error.message ?? "Row failed to process";
    }
    return "Unexpected error while inviting user";
  }

  private normalizeHeader(value: string): string {
    return value
      .toLowerCase()
      .trim()
      .replaceAll(/[^a-z0-9]/g, "");
  }

  private normalizeCellValue(value: unknown): string {
    if (value === null || value === undefined) {
      return "";
    }

    return String(value).trim();
  }

  private isLikelyEmail(value: string): boolean {
    if (!value) return false;
    if (value.includes(" ")) return false;

    const atIndex = value.indexOf("@");
    if (atIndex <= 0 || atIndex !== value.lastIndexOf("@")) {
      return false;
    }

    const localPart = value.slice(0, atIndex);
    const domainPart = value.slice(atIndex + 1);
    if (!localPart || !domainPart) return false;

    const dotIndex = domainPart.indexOf(".");
    if (dotIndex <= 0 || dotIndex === domainPart.length - 1) {
      return false;
    }

    return true;
  }

  private extractHeaderMap(worksheet: ExcelJS.Worksheet): Map<string, number> {
    const headerMap = new Map<string, number>();
    const headerRow = worksheet.getRow(1);

    headerRow.eachCell((cell, colNumber) => {
      const normalized = this.normalizeHeader(cell.text ?? "");
      if (normalized) {
        headerMap.set(normalized, colNumber);
      }
    });

    return headerMap;
  }

  private resolveColumnIndex(
    headerMap: Map<string, number>,
    candidates: string[],
  ): number | null {
    for (const candidate of candidates) {
      const col = headerMap.get(this.normalizeHeader(candidate));
      if (col) {
        return col;
      }
    }

    return null;
  }

  private buildFindAllQuery(orgId: string, query: UserQueryDto) {
    const { status, role, search } = query;

    const queryBuilder = this.userRepository
      .createQueryBuilder("user")
      .where("user.org_id = :orgId", { orgId });

    if (status) {
      queryBuilder.andWhere("user.status = :status", { status });
    }

    if (role) {
      queryBuilder.andWhere("user.role = :role", { role });
    }

    if (search) {
      queryBuilder.andWhere(
        "(user.name ILIKE :search OR user.email ILIKE :search)",
        { search: `%${search}%` },
      );
    }

    return queryBuilder;
  }

  async findAll(orgId: string, query: UserQueryDto) {
    const { status, role, search, page = 1, limit = 20 } = query;

    const queryBuilder = this.buildFindAllQuery(orgId, {
      status,
      role,
      search,
    });

    const [users, total] = await queryBuilder
      .orderBy("user.createdAt", "DESC")
      .skip((page - 1) * limit)
      .take(limit)
      .getManyAndCount();

    return {
      data: users,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async exportUsersWorkbook(
    orgId: string,
    query: UserQueryDto,
  ): Promise<UserWorkbookFile> {
    const users = await this.buildFindAllQuery(orgId, query)
      .orderBy("user.createdAt", "DESC")
      .getMany();

    const workbook = new ExcelJS.Workbook();
    workbook.creator = "OneLign PMS";
    workbook.created = new Date();

    const worksheet = workbook.addWorksheet("Users");
    worksheet.columns = [
      { header: "Name", key: "name", width: 28 },
      { header: "Email", key: "email", width: 34 },
      { header: "Role", key: "role", width: 18 },
      { header: "Status", key: "status", width: 18 },
    ];

    worksheet.getRow(1).font = { bold: true };
    worksheet.getRow(1).fill = {
      type: "pattern",
      pattern: "solid",
      fgColor: { argb: "FFE8EEF9" },
    };

    users.forEach((user) => {
      worksheet.addRow({
        name: user.name ?? "",
        email: user.email ?? "",
        role: user.role ?? "",
        status: user.status ?? "",
      });
    });

    worksheet.views = [{ state: "frozen", ySplit: 1 }];
    worksheet.autoFilter = {
      from: "A1",
      to: "D1",
    };

    const arrayBuffer = await workbook.xlsx.writeBuffer();
    return {
      fileName: `users_${new Date().toISOString().slice(0, 10)}.xlsx`,
      buffer: Buffer.from(arrayBuffer as ArrayBuffer),
    };
  }

  async getBulkInviteTemplateWorkbook(): Promise<UserWorkbookFile> {
    const workbook = new ExcelJS.Workbook();
    workbook.creator = "OneLign PMS";
    workbook.created = new Date();

    const worksheet = workbook.addWorksheet("Bulk Invite Template");
    worksheet.columns = [
      { header: "email", key: "email", width: 34 },
      { header: "role", key: "role", width: 18 },
    ];

    worksheet.getRow(1).font = { bold: true };
    worksheet.getRow(1).fill = {
      type: "pattern",
      pattern: "solid",
      fgColor: { argb: "FFE8EEF9" },
    };

    worksheet.addRow({ email: "user.one@company.com", role: "USER" });
    worksheet.addRow({ email: "user.two@company.com", role: "MANAGER" });
    worksheet.views = [{ state: "frozen", ySplit: 1 }];

    const arrayBuffer = await workbook.xlsx.writeBuffer();
    return {
      fileName: "bulk-user-invite-template.xlsx",
      buffer: Buffer.from(arrayBuffer as ArrayBuffer),
    };
  }

  async findOne(orgId: string, userId: string): Promise<AppUser> {
    const user = await this.userRepository.findOne({
      where: { id: userId, orgId },
      relations: ["organization"],
    });

    if (!user) {
      throw new NotFoundException("User not found");
    }

    return user;
  }

  async findByEmail(orgId: string, email: string): Promise<AppUser | null> {
    return this.userRepository.findOne({
      where: { email, orgId },
    });
  }

  async update(
    orgId: string,
    userId: string,
    updateUserDto: UpdateUserDto,
  ): Promise<AppUser> {
    const user = await this.findOne(orgId, userId);

    Object.assign(user, updateUserDto);

    return this.userRepository.save(user);
  }

  async updateRole(
    orgId: string,
    userId: string,
    currentUserId: string,
    updateRoleDto: UpdateUserRoleDto,
  ): Promise<AppUser> {
    const user = await this.findOne(orgId, userId);

    // Permission is enforced at controller guard level (EDIT_USER_ROLE).
    // Keep current user lookup only for audit logging.
    const currentUser = await this.findOne(orgId, currentUserId);

    const role = await this.resolveRoleForAssignment(
      updateRoleDto.role,
      updateRoleDto.roleId,
    );

    if (user.roleId !== role.id) {
      await this.userPermissionRepository.delete({ userId: user.id });
    }

    user.role = role.key;
    user.roleId = role.id;

    const updated = await this.userRepository.save(user);

    this.logUserActivity({
      orgId,
      actorUserId: currentUserId,
      resourceId: userId,
      actionType: "USER_ROLE_UPDATED",
      message: `User '${user.email}' role changed to ${role.key}`,
      requestPath: `/users/${userId}/role`,
      metadata: { newRole: role.key, newRoleId: role.id },
    });

    return updated;
  }

  async updateStatus(
    orgId: string,
    userId: string,
    currentUserId: string,
    updateStatusDto: UpdateUserStatusDto,
  ): Promise<AppUser> {
    // Prevent self deactivation
    if (userId === currentUserId && updateStatusDto.status === "DEACTIVATED") {
      throw new ForbiddenException("Cannot deactivate your own account");
    }

    const user = await this.findOne(orgId, userId);
    user.status = updateStatusDto.status;

    const updated = await this.userRepository.save(user);

    this.logUserActivity({
      orgId,
      actorUserId: currentUserId,
      resourceId: userId,
      actionType:
        updateStatusDto.status === "ACTIVE"
          ? "USER_ACTIVATED"
          : "USER_DEACTIVATED",
      message: `User '${user.email}' ${updateStatusDto.status === "ACTIVE" ? "activated" : "deactivated"}`,
      requestPath: `/users/${userId}/status`,
      metadata: { status: updateStatusDto.status },
    });

    return updated;
  }

  async getUserProjects(orgId: string, userId: string) {
    // Verify user exists
    await this.findOne(orgId, userId);

    const mappings = await this.userProjectMappingRepository.find({
      where: { userId, orgId },
      relations: ["project"],
      order: { createdAt: "DESC" },
    });

    return mappings.map((mapping) => ({
      id: mapping.id,
      userId: mapping.userId,
      projectId: mapping.projectId,
      projectRole: mapping.projectRole,
      status: mapping.status,
      project: mapping.project
        ? {
            id: mapping.project.id,
            name: mapping.project.name,
            projectCode: mapping.project.projectCode,
            status: mapping.project.status,
          }
        : null,
    }));
  }

  async getDailySummaries(
    orgId: string,
    userId: string,
    startDate?: string,
    endDate?: string,
  ) {
    // Verify user exists
    await this.findOne(orgId, userId);

    const queryBuilder = this.userDailySummaryRepository
      .createQueryBuilder("summary")
      .where("summary.user_id = :userId", { userId })
      .andWhere("summary.org_id = :orgId", { orgId });

    if (startDate) {
      queryBuilder.andWhere("summary.summary_date >= :startDate", {
        startDate,
      });
    }

    if (endDate) {
      queryBuilder.andWhere("summary.summary_date <= :endDate", { endDate });
    }

    return queryBuilder.orderBy("summary.logDate", "DESC").getMany();
  }

  /**
   * Invite a user by email (ORG_ADMIN only).
   * Pre-creates the user and returns a one-time password setup token.
   */
  async inviteUser(orgId: string, dto: InviteUserDto): Promise<AppUser & { setupToken: string }> {
    const email = dto.email.toLowerCase().trim();

    const existing = await this.userRepository.findOne({
      where: { email, orgId },
    });

    if (existing) {
      throw new ConflictException(
        `A user with email ${email} already exists in this organization`,
      );
    }

    const role = await this.resolveRoleForAssignment(
      dto.role ?? "USER",
      dto.roleId,
    );
    const setup = createPasswordSetupToken();

    const user = this.userRepository.create({
      email,
      name: deriveDisplayNameFromEmail(email),
      orgId,
      role: role.key,
      roleId: role.id,
      status: "ACTIVE",
      passwordSetupTokenHash: setup.tokenHash,
      passwordSetupExpiresAt: new Date(Date.now() + 48 * 60 * 60 * 1000),
    });

    const saved = await this.userRepository.save(user);

    this.logUserActivity({
      orgId,
      method: "POST",
      resourceId: saved.id,
      actionType: "USER_INVITED",
      message: `User '${email}' invited to organization with role ${role.key}`,
      requestPath: "/users/invite",
      metadata: { email, role: role.key, roleId: role.id },
    });

    return Object.assign(saved, { setupToken: setup.token });
  }

  async createPasswordSetupLink(
    orgId: string,
    userId: string,
  ): Promise<{ setupToken: string }> {
    const user = await this.userRepository.findOne({ where: { id: userId, orgId } });
    if (!user) {
      throw new NotFoundException("User not found in this organization");
    }
    const setup = createPasswordSetupToken();
    user.passwordSetupTokenHash = setup.tokenHash;
    user.passwordSetupExpiresAt = new Date(Date.now() + 48 * 60 * 60 * 1000);
    await this.userRepository.save(user);
    this.logUserActivity({
      orgId,
      method: "POST",
      resourceId: user.id,
      actionType: "PASSWORD_SETUP_LINK_CREATED",
      message: `Password setup link created for '${user.email}'`,
      requestPath: `/users/${user.id}/password-setup-link`,
    });
    return { setupToken: setup.token };
  }

  async bulkInviteUsersFromWorkbook(
    orgId: string,
    fileBuffer: Uint8Array,
    defaults?: { defaultRole?: string; defaultRoleId?: string },
  ): Promise<BulkInviteResultDto> {
    if (!fileBuffer || fileBuffer.length === 0) {
      throw new BadRequestException("Uploaded file is empty");
    }

    const workbook = new ExcelJS.Workbook();
    try {
      await workbook.xlsx.load(fileBuffer as any);
    } catch {
      throw new BadRequestException(
        "Invalid Excel file. Please upload a valid .xlsx file",
      );
    }

    const worksheet = workbook.worksheets[0];
    if (!worksheet) {
      throw new BadRequestException("Workbook must contain at least one sheet");
    }

    const headerMap = this.extractHeaderMap(worksheet);
    const emailCol = this.resolveColumnIndex(headerMap, [
      "email",
      "email address",
      "mail",
    ]);
    const roleCol = this.resolveColumnIndex(headerMap, ["role", "user role"]);
    const roleIdCol = this.resolveColumnIndex(headerMap, ["roleId", "role id"]);

    if (!emailCol) {
      throw new BadRequestException(
        "Excel must include an email column (email/email address)",
      );
    }

    const seenEmails = new Set<string>();

    const invited: BulkInviteResultDto["invited"] = [];
    const skipped: Array<{ row: number; email: string; reason: string }> = [];
    const failed: Array<{ row: number; email?: string; error: string }> = [];

    let totalRows = 0;

    for (let rowIndex = 2; rowIndex <= worksheet.rowCount; rowIndex++) {
      const row = worksheet.getRow(rowIndex);

      const emailRaw = this.normalizeCellValue(row.getCell(emailCol).text);
      const roleRaw = roleCol
        ? this.normalizeCellValue(row.getCell(roleCol).text)
        : "";
      const roleIdRaw = roleIdCol
        ? this.normalizeCellValue(row.getCell(roleIdCol).text)
        : "";

      if (!emailRaw && !roleRaw && !roleIdRaw) {
        continue;
      }

      totalRows += 1;

      const normalizedEmail = emailRaw.toLowerCase();

      if (!emailRaw) {
        failed.push({ row: rowIndex, error: "Email is required" });
        continue;
      }

      if (!this.isLikelyEmail(normalizedEmail)) {
        failed.push({
          row: rowIndex,
          email: emailRaw,
          error: "Invalid email format",
        });
        continue;
      }

      if (seenEmails.has(normalizedEmail)) {
        skipped.push({
          row: rowIndex,
          email: normalizedEmail,
          reason: "Duplicate email in upload file",
        });
        continue;
      }

      seenEmails.add(normalizedEmail);

      const existing = await this.userRepository.findOne({
        where: { orgId, email: normalizedEmail },
      });

      if (existing) {
        skipped.push({
          row: rowIndex,
          email: normalizedEmail,
          reason: "User already exists in organization",
        });
        continue;
      }

      try {
        const created = await this.inviteUser(orgId, {
          email: normalizedEmail,
          role: roleRaw || defaults?.defaultRole,
          roleId: roleIdRaw || defaults?.defaultRoleId,
        });
        invited.push({
          id: created.id,
          orgId: created.orgId,
          email: created.email,
          name: created.name ?? undefined,
          role: created.role ?? "USER",
          status: created.status,
          createdAt: created.createdAt,
          setupToken: created.setupToken,
        });
      } catch (error) {
        failed.push({
          row: rowIndex,
          email: normalizedEmail,
          error: this.resolveInviteFailureMessage(error),
        });
      }
    }

    return {
      totalRows,
      invitedCount: invited.length,
      skippedCount: skipped.length,
      failedCount: failed.length,
      invited,
      skipped,
      failed,
    };
  }

  async getMyStats(orgId: string, userId: string): Promise<UserStatsDto> {
    const mappings = await this.userProjectMappingRepository.find({
      where: { userId, orgId },
      relations: ["project"],
    });

    const activeProjects = mappings
      .filter((m) => m.project?.status === "ACTIVE")
      .map((m) => ({
        projectId: m.projectId,
        name: m.project.name,
        projectCode: m.project.projectCode,
        projectStatus: m.project.status,
        projectRole: m.projectRole || "MEMBER",
        managerId: m.project.managerId,
      }));

    const tasks = await this.taskRepository.find({
      where: { assignedTo: userId, orgId },
      select: ["id", "status"],
    });

    const totalTasksAssigned = tasks.length;
    const completedTasks = tasks.filter((t) => t.status === "DONE").length;
    const openTasks = totalTasksAssigned - completedTasks;
    const completionRate =
      totalTasksAssigned > 0
        ? Math.round((completedTasks / totalTasksAssigned) * 10000) / 100
        : 0;

    const tasksByStatus = {
      TODO: 0,
      IN_PROGRESS: 0,
      IN_REVIEW: 0,
      QA: 0,
      DONE: 0,
      BLOCKED: 0,
    };
    for (const task of tasks) {
      if (task.status in tasksByStatus) {
        tasksByStatus[task.status as keyof typeof tasksByStatus]++;
      }
    }

    const timeLogResult = await this.timeLogRepository
      .createQueryBuilder("tl")
      .select("COALESCE(SUM(tl.minutes), 0)", "total")
      .where("tl.user_id = :userId", { userId })
      .andWhere("tl.org_id = :orgId", { orgId })
      .getRawOne<{ total: string }>();

    const totalMinutesLogged = Number(timeLogResult?.total ?? 0);

    return {
      totalProjectsAssigned: mappings.length,
      activeProjectsCount: activeProjects.length,
      totalTasksAssigned,
      openTasks,
      completedTasks,
      completionRate,
      totalMinutesLogged,
      tasksByStatus,
      activeProjects,
    };
  }

  async getMyTasks(orgId: string, userId: string): Promise<Task[]> {
    // Verify user exists in org
    await this.findOne(orgId, userId);

    return this.taskRepository.find({
      where: { orgId, assignedTo: userId },
      order: { createdAt: "DESC" },
    });
  }

  async getMyProfile(orgId: string, userId: string): Promise<AppUser> {
    return this.findOne(orgId, userId);
  }

  async updateMyProfile(
    orgId: string,
    userId: string,
    updateUserDto: UpdateUserDto,
  ): Promise<AppUser> {
    return this.update(orgId, userId, updateUserDto);
  }

  /**
   * Get bandwidth allocation summary for a user across all projects
   */
  async getBandwidthSummary(orgId: string, userId: string) {
    const user = await this.findOne(orgId, userId);

    // Get all project mappings for this user
    const mappings = await this.userProjectMappingRepository.find({
      where: { userId, orgId },
      relations: ["project"],
      order: { createdAt: "DESC" },
    });

    // Calculate total approved bandwidth
    const totalApprovedBandwidth = mappings
      .filter((m) => m.approvalStatus === "APPROVED")
      .reduce((sum, m) => sum + m.allocatedBandwidth, 0);

    // Calculate total pending bandwidth
    const pendingBandwidth = mappings
      .filter((m) => m.approvalStatus === "PENDING")
      .reduce((sum, m) => sum + m.allocatedBandwidth, 0);

    // Total allocated includes both approved and pending
    const totalAllocatedBandwidth = totalApprovedBandwidth + pendingBandwidth;

    return {
      userId,
      email: user.email,
      name: user.name,
      totalApprovedBandwidth,
      totalPendingBandwidth: pendingBandwidth,
      totalAllocatedBandwidth,
      availableBandwidth: Math.max(0, 100 - totalAllocatedBandwidth),
      projects: mappings.map((m) => ({
        projectId: m.projectId,
        projectName: m.project?.name,
        projectRole: m.projectRole,
        allocatedBandwidth: m.allocatedBandwidth,
        approvalStatus: m.approvalStatus,
        requestedByUserId: m.requestedByUserId,
        approvedByUserId: m.approvedByUserId,
        approvedAt: m.approvedAt,
        assignedAt: m.createdAt,
      })),
    };
  }
}
