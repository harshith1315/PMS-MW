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
} from "@nestjs/swagger";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { TenantGuard } from "../../common/guards/tenant.guard";
import { RolesGuard } from "../../common/guards/roles.guard";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import { Permissions } from "../../common/decorators/permissions.decorator";
import { UserContext } from "../auth/auth.service";
import { ProjectService } from "./project.service";
import {
  CreateProjectDto,
  UpdateProjectDto,
  AssignUserToProjectDto,
  AddProjectLinkDto,
  ProjectQueryDto,
  ProjectResponseDto,
  UserProjectMappingResponseDto,
  ApproveBandwidthAllocationDto,
  UpdateBandwidthAllocationDto,
  UpdateTeamMemberAllocationDto,
} from "./dto/project.dto";

@ApiTags("Projects")
@Controller("projects")
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth("bearer")
export class ProjectController {
  constructor(private readonly projectService: ProjectService) {}

  @Post()
  @UseGuards(PermissionsGuard)
  @Permissions("CREATE_PROJECT")
  @ApiOperation({ summary: "Create a new project (ORG_ADMIN only)" })
  @ApiResponse({
    status: 201,
    description: "Project created successfully",
    type: ProjectResponseDto,
  })
  @ApiResponse({ status: 400, description: "Invalid input" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({
    status: 403,
    description: "Forbidden - requires ORG_ADMIN role",
  })
  @ApiResponse({ status: 409, description: "Project code already exists" })
  async create(
    @CurrentUser() user: UserContext,
    @Body() createProjectDto: CreateProjectDto,
  ) {
    return this.projectService.create(user.orgId, createProjectDto, user.userId);
  }

  @Get()
  @ApiOperation({ summary: "Get all projects for the organization" })
  @ApiResponse({
    status: 200,
    description: "List of projects",
    schema: {
      type: "object",
      properties: {
        data: {
          type: "array",
          items: { $ref: "#/components/schemas/ProjectResponseDto" },
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
    @Query() query: ProjectQueryDto,
  ) {
    return this.projectService.findAll(
      user.orgId,
      user.userId,
      user.role,
      query,
    );
  }

  @Get(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("VIEW_PROJECT")
  @ApiOperation({ summary: "Get project by ID" })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Project details",
    type: ProjectResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Project not found" })
  async findOne(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.projectService.findOneForUser(
      user.orgId,
      id,
      user.userId,
      user.role,
    );
  }

  @Put(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("EDIT_PROJECT")
  @ApiOperation({ summary: "Update project (ORG_ADMIN only)" })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Project updated successfully",
    type: ProjectResponseDto,
  })
  @ApiResponse({ status: 400, description: "Invalid input" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden" })
  @ApiResponse({ status: 404, description: "Project not found" })
  async update(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() updateProjectDto: UpdateProjectDto,
  ) {
    return this.projectService.update(user.orgId, id, updateProjectDto);
  }

  @Delete(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("DELETE_PROJECT")
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Delete project (ORG_ADMIN only)" })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiResponse({ status: 204, description: "Project deleted successfully" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden" })
  @ApiResponse({ status: 404, description: "Project not found" })
  async remove(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.projectService.remove(user.orgId, id);
  }

  @Post(":id/team")
  @UseGuards(PermissionsGuard)
  @Permissions("ASSIGN_USERS")
  @ApiOperation({ summary: "Assign user to project (ORG_ADMIN or MANAGER)" })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiResponse({
    status: 201,
    description: "User assigned to project",
    type: UserProjectMappingResponseDto,
  })
  @ApiResponse({ status: 400, description: "User not in organization" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden" })
  @ApiResponse({ status: 404, description: "Project not found" })
  async assignUser(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() assignDto: AssignUserToProjectDto,
  ) {
    return this.projectService.assignUser(
      user.orgId,
      id,
      assignDto,
      user.userId,
      user.role,
    );
  }

  @Delete(":id/team/:mappingId")
  @UseGuards(PermissionsGuard)
  @Permissions("ASSIGN_USERS")
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Remove user from project (ORG_ADMIN only)" })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiParam({
    name: "mappingId",
    description: "Team mapping ID to remove",
    format: "uuid",
  })
  @ApiResponse({ status: 204, description: "User removed from project" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden" })
  @ApiResponse({
    status: 404,
    description: "Project or user mapping not found",
  })
  async removeUser(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Param("mappingId", ParseUUIDPipe) mappingId: string,
  ) {
    return this.projectService.removeUser(
      user.orgId,
      id,
      mappingId,
      user.userId,
      user.role,
    );
  }

  @Get(":id/team")
  @ApiOperation({ summary: "Get project team members" })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "List of team members",
    type: [UserProjectMappingResponseDto],
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Project not found" })
  async getTeamMembers(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.projectService.getTeamMembers(user.orgId, id);
  }

  @Post(":id/team/:mappingId/approve-bandwidth")
  @UseGuards(PermissionsGuard)
  @Permissions("ASSIGN_USERS")
  @ApiOperation({
    summary: "Approve or reject bandwidth allocation (ORG_ADMIN or MANAGER)",
  })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiParam({
    name: "mappingId",
    description: "Team mapping ID",
    format: "uuid",
  })
  @ApiResponse({
    status: 200,
    description: "Bandwidth allocation approved/rejected",
    type: UserProjectMappingResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: "Invalid approval or bandwidth validation failed",
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden" })
  @ApiResponse({
    status: 404,
    description: "Project or user mapping not found",
  })
  async approveBandwidthAllocation(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Param("mappingId", ParseUUIDPipe) mappingId: string,
    @Body() approveDto: ApproveBandwidthAllocationDto,
  ) {
    return this.projectService.approveBandwidthAllocation(
      user.orgId,
      id,
      mappingId,
      approveDto.approvalStatus,
      user.userId,
      user.role,
    );
  }

  @Patch(":id/team/:mappingId/bandwidth")
  @UseGuards(PermissionsGuard)
  @Permissions("ASSIGN_USERS")
  @ApiOperation({
    summary: "Update employee bandwidth allocation (ORG_ADMIN or MANAGER)",
  })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiParam({
    name: "mappingId",
    description: "Team mapping ID",
    format: "uuid",
  })
  @ApiResponse({
    status: 200,
    description: "Bandwidth allocation updated",
    type: UserProjectMappingResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: "Invalid bandwidth or validation failed",
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden" })
  @ApiResponse({
    status: 404,
    description: "Project or user mapping not found",
  })
  async updateBandwidthAllocation(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Param("mappingId", ParseUUIDPipe) mappingId: string,
    @Body() updateDto: UpdateBandwidthAllocationDto,
  ) {
    return this.projectService.updateBandwidthAllocation(
      user.orgId,
      id,
      mappingId,
      updateDto.allocatedBandwidth,
      user.userId,
      user.role,
    );
  }

  @Patch(":id/team/:mappingId")
  @UseGuards(PermissionsGuard)
  @Permissions("ASSIGN_USERS")
  @ApiOperation({
    summary: "Update team member role and/or bandwidth (ORG_ADMIN or MANAGER)",
  })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiParam({
    name: "mappingId",
    description: "Team mapping ID",
    format: "uuid",
  })
  @ApiResponse({
    status: 200,
    description: "Team member allocation updated",
    type: UserProjectMappingResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: "Invalid role/bandwidth or validation failed",
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden" })
  @ApiResponse({
    status: 404,
    description: "Project or user mapping not found",
  })
  async updateTeamMemberAllocation(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Param("mappingId", ParseUUIDPipe) mappingId: string,
    @Body() updateDto: UpdateTeamMemberAllocationDto,
  ) {
    return this.projectService.updateTeamMemberAllocation(
      user.orgId,
      id,
      mappingId,
      updateDto,
      user.userId,
      user.role,
    );
  }

  @Post(":id/links")
  @ApiOperation({ summary: "Add link to project" })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiResponse({ status: 201, description: "Link added successfully" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Project not found" })
  async addLink(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() addLinkDto: AddProjectLinkDto,
  ) {
    return this.projectService.addLink(user.orgId, id, addLinkDto);
  }

  @Get(":id/links")
  @ApiOperation({ summary: "Get project links" })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiResponse({ status: 200, description: "List of project links" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Project not found" })
  async getLinks(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.projectService.getLinks(user.orgId, id);
  }

  @Delete(":id/links/:linkId")
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Remove link from project" })
  @ApiParam({ name: "id", description: "Project ID", format: "uuid" })
  @ApiParam({ name: "linkId", description: "Link ID", format: "uuid" })
  @ApiResponse({ status: 204, description: "Link removed successfully" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Project or link not found" })
  async removeLink(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Param("linkId", ParseUUIDPipe) linkId: string,
  ) {
    return this.projectService.removeLink(user.orgId, id, linkId);
  }
}
