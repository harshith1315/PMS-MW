import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { AppUser } from "../../entities/app-user.entity";
import { Role } from "../../entities/role.entity";
import { UserPermission } from "../../entities/user-permission.entity";
import {
  ACCESS_CONTROL_PERMISSIONS,
  AccessControlPermission,
} from "./access-control.constants";
import { UserContext } from "../auth/auth.service";

export interface PermissionState {
  permissionKey: string;
  isGranted: boolean;
}

@Injectable()
export class AccessControlService {
  constructor(
    @InjectRepository(Role)
    private readonly roleRepository: Repository<Role>,
    @InjectRepository(UserPermission)
    private readonly userPermissionRepository: Repository<UserPermission>,
    @InjectRepository(AppUser)
    private readonly appUserRepository: Repository<AppUser>,
  ) {}

  getAllPermissions() {
    return ACCESS_CONTROL_PERMISSIONS.map((permissionKey) => ({
      permissionKey,
      label: this.getPermissionLabel(permissionKey),
      description: this.getPermissionDescription(permissionKey),
    }));
  }

  async listRoles(): Promise<Role[]> {
    return this.roleRepository.find({
      where: { isActive: true },
      order: { isSystem: "DESC", name: "ASC" },
    });
  }

  async createRole(
    key: string,
    name: string,
    description: string | undefined,
    permissions: PermissionState[],
  ): Promise<Role> {
    this.validatePermissionKeys(permissions);

    const normalizedKey = key.trim().toUpperCase();
    const exists = await this.roleRepository.findOne({
      where: { key: normalizedKey },
      select: ["id"],
    });
    if (exists) {
      throw new BadRequestException(`Role key already exists: ${normalizedKey}`);
    }

    const role = this.roleRepository.create({
      key: normalizedKey,
      name: name.trim(),
      description: description?.trim() ?? null,
      permissions: this.toPermissionMap(permissions),
      isSystem: false,
      isActive: true,
    });

    return this.roleRepository.save(role);
  }

  async getRolePermissions(roleId: string): Promise<PermissionState[]> {
    const role = await this.roleRepository.findOne({ where: { id: roleId } });
    if (!role || !role.isActive) {
      throw new NotFoundException("Role not found");
    }

    return this.toPermissionStateList(role.permissions);
  }

  async getRolePermissionsByKey(roleKey: string): Promise<PermissionState[]> {
    const role = await this.getRoleByKey(roleKey);
    return this.toPermissionStateList(role.permissions);
  }

  async updateRolePermissions(
    roleId: string,
    permissions: PermissionState[],
  ): Promise<PermissionState[]> {
    this.validatePermissionKeys(permissions);

    const role = await this.roleRepository.findOne({ where: { id: roleId } });
    if (!role || !role.isActive) {
      throw new NotFoundException("Role not found");
    }

    role.permissions = this.toPermissionMap(permissions);
    await this.roleRepository.save(role);

    return this.toPermissionStateList(role.permissions);
  }

  async updateRolePermissionsByKey(
    roleKey: string,
    permissions: PermissionState[],
  ): Promise<PermissionState[]> {
    const role = await this.getRoleByKey(roleKey);
    return this.updateRolePermissions(role.id, permissions);
  }

  async assignRoleToUser(
    currentUser: UserContext,
    targetUserId: string,
    roleId: string,
  ): Promise<AppUser> {
    const targetUser = await this.getAndAuthorizeTargetUser(
      currentUser,
      targetUserId,
    );

    const role = await this.roleRepository.findOne({ where: { id: roleId } });
    if (!role || !role.isActive) {
      throw new NotFoundException("Role not found");
    }

    if (targetUser.roleId !== role.id) {
      await this.userPermissionRepository.delete({ userId: targetUser.id });
    }

    targetUser.roleId = role.id;
    targetUser.role = role.key;
    await this.appUserRepository.save(targetUser);

    return targetUser;
  }

  async listUsersForAccessControl(
    currentUser: UserContext,
    search?: string,
    orgId?: string,
  ) {
    const queryBuilder = this.appUserRepository
      .createQueryBuilder("user")
      .select([
        "user.id",
        "user.name",
        "user.email",
        "user.roleId",
        "user.role",
        "user.orgId",
        "user.status",
      ]);

    if (currentUser.role === "ADMIN" && orgId) {
      queryBuilder.where("user.org_id = :orgId", { orgId });
    } else {
      queryBuilder.where("user.org_id = :orgId", { orgId: currentUser.orgId });
    }

    if (search) {
      queryBuilder.andWhere(
        "(user.email ILIKE :search OR user.name ILIKE :search)",
        { search: `%${search}%` },
      );
    }

    const users = await queryBuilder
      .orderBy("user.createdAt", "DESC")
      .getMany();

    return users;
  }

  async getUserPermissions(
    currentUser: UserContext,
    targetUserId: string,
  ): Promise<PermissionState[]> {
    const targetUser = await this.getAndAuthorizeTargetUser(
      currentUser,
      targetUserId,
    );

    const effectiveMap = await this.getRolePermissionMapForUser(targetUser);

    const rows = await this.userPermissionRepository.find({
      where: { userId: targetUser.id },
    });
    for (const row of rows) {
      effectiveMap.set(row.permissionKey, row.isGranted);
    }

    return ACCESS_CONTROL_PERMISSIONS.map((permissionKey) => ({
      permissionKey,
      isGranted: effectiveMap.get(permissionKey) ?? false,
    }));
  }

  async updateUserPermissions(
    currentUser: UserContext,
    targetUserId: string,
    permissions: PermissionState[],
  ): Promise<PermissionState[]> {
    const targetUser = await this.getAndAuthorizeTargetUser(
      currentUser,
      targetUserId,
    );
    this.validatePermissionKeys(permissions);

    const entities = permissions.map((permission) =>
      this.userPermissionRepository.create({
        userId: targetUser.id,
        permissionKey: permission.permissionKey,
        isGranted: permission.isGranted,
      }),
    );

    await this.userPermissionRepository.upsert(entities, [
      "userId",
      "permissionKey",
    ]);
    return this.getUserPermissions(currentUser, targetUserId);
  }

  async getEffectivePermissions(currentUser: UserContext): Promise<string[]> {
    const current = await this.appUserRepository.findOne({
      where: { id: currentUser.userId },
      relations: ["roleEntity"],
      select: ["id", "role", "roleId", "orgId"],
    });
    if (!current) {
      throw new NotFoundException("Current user not found");
    }

    const effectiveMap = await this.getRolePermissionMapForUser(current);

    // User-level overrides take precedence over role defaults
    const userRows = await this.userPermissionRepository.find({
      where: { userId: currentUser.userId },
    });
    for (const row of userRows) {
      effectiveMap.set(row.permissionKey, row.isGranted);
    }

    return ACCESS_CONTROL_PERMISSIONS.filter(
      (permissionKey) => effectiveMap.get(permissionKey) === true,
    );
  }

  private validatePermissionKeys(permissions: PermissionState[]) {
    const uniqueKeys = new Set<string>();

    for (const permission of permissions) {
      if (
        !ACCESS_CONTROL_PERMISSIONS.includes(
          permission.permissionKey as AccessControlPermission,
        )
      ) {
        throw new BadRequestException(
          `Invalid permission key: ${permission.permissionKey}`,
        );
      }

      if (uniqueKeys.has(permission.permissionKey)) {
        throw new BadRequestException(
          `Duplicate permission key: ${permission.permissionKey}`,
        );
      }

      uniqueKeys.add(permission.permissionKey);
    }

    if (uniqueKeys.size !== ACCESS_CONTROL_PERMISSIONS.length) {
      throw new BadRequestException(
        `All permissions must be provided. Expected ${ACCESS_CONTROL_PERMISSIONS.length} permission states.`,
      );
    }
  }

  private toPermissionMap(
    permissions: PermissionState[],
  ): Record<string, boolean> {
    const map: Record<string, boolean> = {};
    for (const permission of permissions) {
      map[permission.permissionKey] = permission.isGranted;
    }
    return map;
  }

  private toPermissionStateList(
    permissionMap: Record<string, boolean> | null | undefined,
  ): PermissionState[] {
    return ACCESS_CONTROL_PERMISSIONS.map((permissionKey) => ({
      permissionKey,
      isGranted: permissionMap?.[permissionKey] === true,
    }));
  }

  private async getRoleByKey(roleKey: string): Promise<Role> {
    const role = await this.roleRepository.findOne({
      where: { key: roleKey.toUpperCase(), isActive: true },
    });
    if (!role) {
      throw new NotFoundException(`Role not found: ${roleKey}`);
    }
    return role;
  }

  private async getRolePermissionMapForUser(
    user: Pick<AppUser, "role" | "roleId" | "id">,
  ): Promise<Map<string, boolean>> {
    const effectiveMap = new Map<string, boolean>();
    for (const key of ACCESS_CONTROL_PERMISSIONS) {
      effectiveMap.set(key, false);
    }

    if (user.role === "ADMIN" || user.role === "ORG_ADMIN") {
      for (const key of ACCESS_CONTROL_PERMISSIONS) {
        effectiveMap.set(key, true);
      }
      return effectiveMap;
    }

    let role: Role | null = null;

    if (user.roleId) {
      role = await this.roleRepository.findOne({
        where: { id: user.roleId, isActive: true },
      });
    }

    if (!role && user.role) {
      role = await this.roleRepository.findOne({
        where: { key: user.role.toUpperCase(), isActive: true },
      });
    }

    if (role?.permissions) {
      for (const permissionKey of ACCESS_CONTROL_PERMISSIONS) {
        effectiveMap.set(permissionKey, role.permissions[permissionKey] === true);
      }
    }

    return effectiveMap;
  }

  private async getAndAuthorizeTargetUser(
    currentUser: UserContext,
    targetUserId: string,
  ): Promise<AppUser> {
    const targetUser = await this.appUserRepository.findOne({
      where: { id: targetUserId },
      select: ["id", "orgId", "role", "roleId"],
    });

    if (!targetUser) {
      throw new NotFoundException("Target user not found");
    }

    const isAdmin = currentUser.role === "ADMIN";
    if (!isAdmin && targetUser.orgId !== currentUser.orgId) {
      throw new ForbiddenException(
        "You can only manage users within your organization",
      );
    }

    return targetUser;
  }

  private getPermissionLabel(permissionKey: AccessControlPermission): string {
    return permissionKey
      .split("_")
      .map((part) => part.charAt(0) + part.slice(1).toLowerCase())
      .join(" ");
  }

  private getPermissionDescription(
    permissionKey: AccessControlPermission,
  ): string {
    const descriptions: Record<AccessControlPermission, string> = {
      // Organization
      VIEW_ORGANIZATION: "Allows viewing organization details and settings",
      EDIT_ORGANIZATION: "Allows editing organization information",
      DELETE_ORGANIZATION: "Allows deleting an organization",
      MANAGE_USERS: "Allows managing users within the organization",
      MANAGE_BUSINESS_UNITS:
        "Allows managing business units within the organization",

      // Business Unit
      VIEW_BUSINESS_UNIT: "Allows viewing business units",
      CREATE_BUSINESS_UNIT: "Allows creating new business units",
      EDIT_BUSINESS_UNIT: "Allows editing business unit information",
      DELETE_BUSINESS_UNIT: "Allows deleting business units",

      // User
      VIEW_USER: "Allows viewing user profiles and details",
      EDIT_USER: "Allows editing user profile information",
      EDIT_USER_ROLE: "Allows changing user roles",
      EDIT_USER_STATUS: "Allows changing user status (active/suspended)",

      // Project
      CREATE_PROJECT: "Allows creating new projects",
      VIEW_PROJECT: "Allows viewing project details and boards",
      EDIT_PROJECT: "Allows editing project information and settings",
      DELETE_PROJECT: "Allows deleting projects",
      EDIT_PROJECT_DETAILS: "Allows editing project detail fields",
      VIEW_PROJECT_DETAILS:
        "Allows viewing the Project Details tab (dates, client, purpose)",
      VIEW_TECH_STACK: "Allows viewing the Tech Stack tab",
      EDIT_TECH_STACK: "Allows editing project tech stack",
      VIEW_DEPENDENCIES: "Allows viewing the Dependencies tab",
      EDIT_DEPENDENCIES: "Allows editing project dependencies",
      VIEW_BUDGET: "Allows viewing the project budget field",
      VIEW_FINANCE: "Allows viewing project finance metrics",
      VIEW_FINANCE_CODE: "Allows viewing the project finance code field",

      // Task
      CREATE_TASK: "Allows creating new tasks",
      EDIT_TASK: "Allows editing existing tasks",
      DELETE_TASK: "Allows deleting tasks",

      // Comment
      CREATE_COMMENT: "Allows creating comments on tasks",
      EDIT_COMMENT: "Allows editing task comments",
      DELETE_COMMENT: "Allows deleting task comments",

      // Attachment
      VIEW_ATTACHMENT: "Allows viewing task attachments",
      CREATE_ATTACHMENT: "Allows uploading files as attachments",
      DELETE_ATTACHMENT: "Allows deleting attachments",

      // Sprint
      VIEW_SPRINT: "Allows viewing sprint details and sprint tabs",
      MANAGE_SPRINT: "Allows creating and managing sprints",

      // Link
      MANAGE_LINKS: "Allows managing linked tasks and dependencies",

      // Leadership
      MANAGE_LEADERSHIP: "Allows managing leadership assignments",

      // User Assignment
      ASSIGN_USERS: "Allows assigning users to projects and tasks",

      // Reports
      VIEW_REPORTS: "Allows viewing and downloading reports",
      VIEW_TEAM_TIMESHEETS:
        "Allows viewing team timesheets across the organization",

      // Time Tracking
      LOG_TIME: "Allows logging work time",

      // Activity Logs
      VIEW_ACTIVITY_LOGS: "Allows viewing API activity logs",

      // Board & Tasks
      VIEW_BOARD: "Allows viewing the sprint Kanban board",
      VIEW_TASK: "Allows viewing task lists and task details",
      VIEW_BACKLOG: "Allows viewing the project backlog tab",
    };

    return descriptions[permissionKey];
  }
}
