import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
  Res,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
  ApiParam,
  ApiQuery,
  ApiConsumes,
  ApiBody,
} from "@nestjs/swagger";
import { FileInterceptor } from "@nestjs/platform-express";
import { Response } from "express";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { TenantGuard } from "../../common/guards/tenant.guard";
import { RolesGuard } from "../../common/guards/roles.guard";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { Roles } from "../../common/decorators/roles.decorator";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Permissions } from "../../common/decorators/permissions.decorator";
import { UserContext } from "../auth/auth.service";
import { UserService } from "./user.service";
import {
  UpdateUserDto,
  UpdateUserRoleDto,
  UpdateUserStatusDto,
  UserQueryDto,
  UserResponseDto,
  UserDailySummaryResponseDto,
  UserProjectMappingDetailDto,
  InviteUserDto,
  UserStatsDto,
  BulkInviteResultDto,
  BulkInviteUserUploadDto,
} from "./dto/user.dto";

@ApiTags("Users")
@Controller("users")
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth("bearer")
export class UserController {
  constructor(private readonly userService: UserService) {}

  private downloadXlsx(res: Response, fileName: string, buffer: Buffer): void {
    res.setHeader(
      "Content-Type",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    );
    res.setHeader("Content-Disposition", `attachment; filename="${fileName}"`);
    res.send(buffer);
  }

  @Post("invite")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_USERS")
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: "Invite a user by email",
    description:
      "Creates an organization account and returns a single-use password setup token.",
  })
  @ApiResponse({
    status: 201,
    description: "User invited successfully",
    type: UserResponseDto,
  })
  @ApiResponse({ status: 400, description: "Invalid email" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden - ORG_ADMIN only" })
  @ApiResponse({
    status: 409,
    description: "User with this email already exists in the organization",
  })
  async inviteUser(
    @CurrentUser() user: UserContext,
    @Body() inviteUserDto: InviteUserDto,
  ) {
    return this.userService.inviteUser(user.orgId, inviteUserDto);
  }

  @Post(":id/password-setup-link")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_USERS")
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: "Create a one-time password setup link for an organization user" })
  @ApiParam({ name: "id", description: "User ID", format: "uuid" })
  async createPasswordSetupLink(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) userId: string,
  ) {
    return this.userService.createPasswordSetupLink(user.orgId, userId);
  }

  @Post("invite/bulk")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_USERS")
  @UseInterceptors(FileInterceptor("file"))
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: "Bulk invite users via Excel (.xlsx)",
    description:
      "Upload an Excel file with an email column and optional role/roleId columns to onboard users in bulk.",
  })
  @ApiConsumes("multipart/form-data")
  @ApiBody({
    schema: {
      type: "object",
      required: ["file"],
      properties: {
        file: {
          type: "string",
          format: "binary",
          description: "Excel file (.xlsx) with headers email, role (optional), roleId (optional)",
        },
        defaultRole: {
          type: "string",
          example: "USER",
          description: "Applied when a row does not include role",
        },
        defaultRoleId: {
          type: "string",
          format: "uuid",
          description: "Applied when a row does not include roleId/role",
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: "Bulk invite processed",
    type: BulkInviteResultDto,
  })
  @ApiResponse({ status: 400, description: "Invalid file or payload" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden - ORG_ADMIN only" })
  async bulkInviteUsers(
    @CurrentUser() user: UserContext,
    @UploadedFile() file: Express.Multer.File,
    @Body() body: BulkInviteUserUploadDto,
  ) {
    if (!file?.buffer) {
      throw new BadRequestException("Excel file is required");
    }

    return this.userService.bulkInviteUsersFromWorkbook(user.orgId, file.buffer, {
      defaultRole: body.defaultRole,
      defaultRoleId: body.defaultRoleId,
    });
  }

  @Get("me")
  @ApiOperation({ summary: "Get current user profile" })
  @ApiResponse({
    status: 200,
    description: "Current user profile",
    type: UserResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async getMyProfile(@CurrentUser() user: UserContext) {
    return this.userService.getMyProfile(user.orgId, user.userId);
  }

  @Patch("me")
  @ApiOperation({ summary: "Update current user profile" })
  @ApiResponse({
    status: 200,
    description: "Profile updated successfully",
    type: UserResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async updateMyProfile(
    @CurrentUser() user: UserContext,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.userService.updateMyProfile(
      user.orgId,
      user.userId,
      updateUserDto,
    );
  }

  @Get("me/stats")
  @ApiOperation({
    summary: "Get my stats",
    description:
      "Returns a summary of the authenticated user: projects assigned, open/completed tasks, total minutes logged, completion rate, and active projects with roles.",
  })
  @ApiResponse({
    status: 200,
    description: "User statistics",
    type: UserStatsDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async getMyStats(@CurrentUser() user: UserContext) {
    return this.userService.getMyStats(user.orgId, user.userId);
  }

  @Get("me/tasks")
  @ApiOperation({ summary: "Get my assigned tasks" })
  @ApiResponse({
    status: 200,
    description: "List of tasks assigned to the current user",
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async getMyTasks(@CurrentUser() user: UserContext) {
    return this.userService.getMyTasks(user.orgId, user.userId);
  }

  @Get("me/projects")
  @ApiOperation({ summary: "Get current user projects" })
  @ApiResponse({
    status: 200,
    description: "List of user projects",
    type: [UserProjectMappingDetailDto],
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async getMyProjects(@CurrentUser() user: UserContext) {
    return this.userService.getUserProjects(user.orgId, user.userId);
  }

  @Get("me/daily-summaries")
  @ApiOperation({ summary: "Get current user daily summaries" })
  @ApiQuery({ name: "startDate", required: false, type: String })
  @ApiQuery({ name: "endDate", required: false, type: String })
  @ApiResponse({
    status: 200,
    description: "List of daily summaries",
    type: [UserDailySummaryResponseDto],
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async getMyDailySummaries(
    @CurrentUser() user: UserContext,
    @Query("startDate") startDate?: string,
    @Query("endDate") endDate?: string,
  ) {
    return this.userService.getDailySummaries(
      user.orgId,
      user.userId,
      startDate,
      endDate,
    );
  }

  @Get()
  @UseGuards(PermissionsGuard)
  @Permissions("VIEW_USER", "MANAGE_USERS")
  @ApiOperation({ summary: "Get all users in organization" })
  @ApiResponse({
    status: 200,
    description: "List of users",
    type: [UserResponseDto],
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden - Admin/Manager only" })
  async findAll(
    @CurrentUser() user: UserContext,
    @Query() query: UserQueryDto,
  ) {
    return this.userService.findAll(user.orgId, query);
  }

  @Get("export")
  @UseGuards(PermissionsGuard)
  @Permissions("VIEW_USER", "MANAGE_USERS")
  @ApiOperation({ summary: "Download users list as XLSX" })
  @ApiResponse({
    status: 200,
    description: "Users workbook generated successfully",
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden - Admin/Manager only" })
  async exportUsers(
    @CurrentUser() user: UserContext,
    @Query() query: UserQueryDto,
    @Res() res: Response,
  ) {
    const file = await this.userService.exportUsersWorkbook(user.orgId, query);
    this.downloadXlsx(res, file.fileName, file.buffer);
  }

  @Get("invite/template")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_USERS")
  @ApiOperation({ summary: "Download bulk invite template as XLSX" })
  @ApiResponse({
    status: 200,
    description: "Bulk invite template workbook generated successfully",
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden - ORG_ADMIN only" })
  async downloadBulkInviteTemplate(@Res() res: Response) {
    const file = await this.userService.getBulkInviteTemplateWorkbook();
    this.downloadXlsx(res, file.fileName, file.buffer);
  }

  @Get(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("VIEW_USER", "MANAGE_USERS")
  @ApiOperation({ summary: "Get user by ID" })
  @ApiParam({ name: "id", description: "User ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "User details",
    type: UserResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden - Admin/Manager only" })
  @ApiResponse({ status: 404, description: "User not found" })
  async findOne(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.userService.findOne(user.orgId, id);
  }

  @Patch(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("EDIT_USER")
  @ApiOperation({ summary: "Update user (ORG_ADMIN only)" })
  @ApiParam({ name: "id", description: "User ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "User updated successfully",
    type: UserResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden - Admin only" })
  @ApiResponse({ status: 404, description: "User not found" })
  async update(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.userService.update(user.orgId, id, updateUserDto);
  }

  @Patch(":id/role")
  @UseGuards(PermissionsGuard)
  @Permissions("EDIT_USER_ROLE")
  @ApiOperation({ summary: "Update user role (ORG_ADMIN only)" })
  @ApiParam({ name: "id", description: "User ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Role updated successfully",
    type: UserResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({
    status: 403,
    description: "Forbidden - Admin only or cannot change own role",
  })
  @ApiResponse({ status: 404, description: "User not found" })
  async updateRole(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() updateRoleDto: UpdateUserRoleDto,
  ) {
    return this.userService.updateRole(
      user.orgId,
      id,
      user.userId,
      updateRoleDto,
    );
  }

  @Patch(":id/status")
  @UseGuards(PermissionsGuard)
  @Permissions("EDIT_USER_STATUS")
  @ApiOperation({ summary: "Activate or deactivate user (ORG_ADMIN only)" })
  @ApiParam({ name: "id", description: "User ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Status updated successfully",
    type: UserResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({
    status: 403,
    description: "Forbidden - Admin only or cannot deactivate self",
  })
  @ApiResponse({ status: 404, description: "User not found" })
  async updateStatus(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() updateStatusDto: UpdateUserStatusDto,
  ) {
    return this.userService.updateStatus(
      user.orgId,
      id,
      user.userId,
      updateStatusDto,
    );
  }

  @Get(":id/projects")
  @UseGuards(PermissionsGuard)
  @Permissions("VIEW_USER", "MANAGE_USERS")
  @ApiOperation({ summary: "Get user projects (ORG_ADMIN/Manager only)" })
  @ApiParam({ name: "id", description: "User ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "List of user projects",
    type: [UserProjectMappingDetailDto],
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden - Admin/Manager only" })
  @ApiResponse({ status: 404, description: "User not found" })
  async getUserProjects(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.userService.getUserProjects(user.orgId, id);
  }

  @Get(":id/daily-summaries")
  @UseGuards(PermissionsGuard)
  @Permissions("VIEW_USER", "MANAGE_USERS")
  @ApiOperation({
    summary: "Get user daily summaries (ORG_ADMIN/Manager only)",
  })
  @ApiParam({ name: "id", description: "User ID", format: "uuid" })
  @ApiQuery({ name: "startDate", required: false, type: String })
  @ApiQuery({ name: "endDate", required: false, type: String })
  @ApiResponse({
    status: 200,
    description: "List of daily summaries",
    type: [UserDailySummaryResponseDto],
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden - Admin/Manager only" })
  @ApiResponse({ status: 404, description: "User not found" })
  async getUserDailySummaries(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Query("startDate") startDate?: string,
    @Query("endDate") endDate?: string,
  ) {
    return this.userService.getDailySummaries(
      user.orgId,
      id,
      startDate,
      endDate,
    );
  }

  @Get(":id/bandwidth-summary")
  @UseGuards(PermissionsGuard)
  @Permissions("VIEW_USER", "MANAGE_USERS")
  @ApiOperation({
    summary: "Get user bandwidth allocation summary (ORG_ADMIN/Manager only)",
  })
  @ApiParam({ name: "id", description: "User ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Bandwidth allocation summary",
    schema: {
      type: "object",
      properties: {
        userId: { type: "string", format: "uuid" },
        email: { type: "string" },
        name: { type: "string" },
        totalApprovedBandwidth: {
          type: "number",
          description: "Total approved bandwidth %",
        },
        totalPendingBandwidth: {
          type: "number",
          description: "Total pending bandwidth %",
        },
        totalAllocatedBandwidth: {
          type: "number",
          description: "Total allocated (approved + pending)",
        },
        availableBandwidth: {
          type: "number",
          description: "Remaining available bandwidth %",
        },
        projects: {
          type: "array",
          items: {
            type: "object",
            properties: {
              projectId: { type: "string", format: "uuid" },
              projectName: { type: "string" },
              projectRole: { type: "string" },
              allocatedBandwidth: { type: "number" },
              approvalStatus: {
                type: "string",
                enum: ["PENDING", "APPROVED", "REJECTED"],
              },
              requestedByUserId: { type: "string", format: "uuid" },
              approvedByUserId: { type: "string", format: "uuid" },
              approvedAt: { type: "string", format: "date-time" },
              assignedAt: { type: "string", format: "date-time" },
            },
          },
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden - Admin/Manager only" })
  @ApiResponse({ status: 404, description: "User not found" })
  async getBandwidthSummary(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.userService.getBandwidthSummary(user.orgId, id);
  }

  @Get("me/bandwidth-summary")
  @ApiOperation({ summary: "Get my bandwidth allocation summary" })
  @ApiResponse({
    status: 200,
    description: "My bandwidth allocation summary",
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async getMyBandwidthSummary(@CurrentUser() user: UserContext) {
    return this.userService.getBandwidthSummary(user.orgId, user.userId);
  }
}
