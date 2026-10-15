import {
  Body,
  Controller,
  Get,
  Post,
  Param,
  Put,
  Query,
  UseGuards,
} from "@nestjs/common";
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from "@nestjs/swagger";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { RolesGuard } from "../../common/guards/roles.guard";
import { TenantGuard } from "../../common/guards/tenant.guard";
import { UserContext } from "../auth/auth.service";
import { AccessControlService } from "./access-control.service";
import {
  AccessControlUserQueryDto,
  AssignRoleDto,
  CreateRoleDto,
  EffectivePermissionsResponseDto,
  UpdatePermissionStatesDto,
} from "./dto/access-control.dto";

@ApiTags("Access Control")
@Controller("access-control")
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth("bearer")
export class AccessControlController {
  constructor(private readonly accessControlService: AccessControlService) {}

  @Get("permissions")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({ summary: "Get all configurable permissions" })
  @ApiResponse({ status: 200, description: "Permission catalog" })
  getAllPermissions() {
    return this.accessControlService.getAllPermissions();
  }

  @Get("roles/id/:roleId/permissions")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({ summary: "Get role default permissions by role id" })
  @ApiResponse({ status: 200, description: "Role permission state list" })
  async getRolePermissionsById(@Param("roleId") roleId: string) {
    return this.accessControlService.getRolePermissions(roleId);
  }

  @Get("roles/:role/permissions")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({ summary: "Get role default permissions by role key" })
  @ApiResponse({ status: 200, description: "Role permission state list" })
  async getRolePermissions(@Param("role") role: string) {
    return this.accessControlService.getRolePermissionsByKey(role);
  }

  @Get("roles")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({ summary: "List active roles" })
  @ApiResponse({ status: 200, description: "Role list" })
  async listRoles() {
    return this.accessControlService.listRoles();
  }

  @Post("roles")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({ summary: "Create a custom role" })
  @ApiResponse({ status: 201, description: "Role created" })
  async createRole(@Body() dto: CreateRoleDto) {
    return this.accessControlService.createRole(
      dto.key,
      dto.name,
      dto.description,
      dto.permissions,
    );
  }

  @Put("roles/id/:roleId/permissions")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({ summary: "Update role default permissions in bulk by role id" })
  @ApiResponse({ status: 200, description: "Updated role permission state list" })
  async updateRolePermissionsById(
    @Param("roleId") roleId: string,
    @Body() dto: UpdatePermissionStatesDto,
  ) {
    return this.accessControlService.updateRolePermissions(
      roleId,
      dto.permissions,
    );
  }

  @Put("roles/:role/permissions")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({ summary: "Update role default permissions in bulk by role key" })
  @ApiResponse({ status: 200, description: "Updated role permission state list" })
  async updateRolePermissions(
    @Param("role") role: string,
    @Body() dto: UpdatePermissionStatesDto,
  ) {
    return this.accessControlService.updateRolePermissionsByKey(
      role,
      dto.permissions,
    );
  }

  @Get("users")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({ summary: "List users for individual overrides" })
  @ApiQuery({ name: "search", required: false })
  @ApiQuery({ name: "orgId", required: false })
  @ApiResponse({ status: 200, description: "User list" })
  async getUsers(
    @CurrentUser() currentUser: UserContext,
    @Query() query: AccessControlUserQueryDto,
  ) {
    return this.accessControlService.listUsersForAccessControl(
      currentUser,
      query.search,
      query.orgId,
    );
  }

  @Get("users/:userId/permissions")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({
    summary:
      "Get effective permission states for a user (role defaults + user overrides)",
  })
  @ApiResponse({
    status: 200,
    description: "Effective user permission state list",
  })
  async getUserPermissions(
    @CurrentUser() currentUser: UserContext,
    @Param("userId") userId: string,
  ) {
    return this.accessControlService.getUserPermissions(currentUser, userId);
  }

  @Put("users/:userId/permissions")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({ summary: "Update user permission overrides in bulk" })
  @ApiResponse({ status: 200, description: "Updated user permission override state list" })
  async updateUserPermissions(
    @CurrentUser() currentUser: UserContext,
    @Param("userId") userId: string,
    @Body() dto: UpdatePermissionStatesDto,
  ) {
    return this.accessControlService.updateUserPermissions(
      currentUser,
      userId,
      dto.permissions,
    );
  }

  @Put("users/:userId/role")
  @UseGuards(RolesGuard)
  @Roles("ADMIN", "ORG_ADMIN")
  @ApiOperation({ summary: "Assign role to user" })
  @ApiResponse({ status: 200, description: "User role assignment updated" })
  async assignRoleToUser(
    @CurrentUser() currentUser: UserContext,
    @Param("userId") userId: string,
    @Body() dto: AssignRoleDto,
  ) {
    return this.accessControlService.assignRoleToUser(
      currentUser,
      userId,
      dto.roleId,
    );
  }

  @Get("me/effective-permissions")
  @ApiOperation({ summary: "Get effective permissions for current user" })
  @ApiResponse({ status: 200, type: EffectivePermissionsResponseDto })
  async getMyEffectivePermissions(@CurrentUser() currentUser: UserContext) {
    const permissions = await this.accessControlService.getEffectivePermissions(
      currentUser,
    );

    return { permissions };
  }
}
