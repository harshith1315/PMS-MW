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
import { RolesGuard } from "../../common/guards/roles.guard";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import { Permissions } from "../../common/decorators/permissions.decorator";
import { UserContext } from "../auth/auth.service";
import { SprintService } from "./sprint.service";
import {
  CreateSprintDto,
  UpdateSprintDto,
  SprintResponseDto,
} from "./dto/sprint.dto";

@ApiTags("Sprints")
@Controller("sprints")
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth("bearer")
export class SprintController {
  constructor(private readonly sprintService: SprintService) {}

  @Post()
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_SPRINT")
  @ApiOperation({ summary: "Create a new sprint" })
  @ApiResponse({
    status: 201,
    description: "Sprint created successfully",
    type: SprintResponseDto,
  })
  @ApiResponse({ status: 400, description: "Invalid input" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Project not found" })
  async create(
    @CurrentUser() user: UserContext,
    @Body() createSprintDto: CreateSprintDto,
  ) {
    return this.sprintService.create(
      user.orgId,
      user.userId,
      user.role,
      createSprintDto,
    );
  }

  @Get()
  @ApiOperation({ summary: "Get all sprints" })
  @ApiQuery({
    name: "projectId",
    required: false,
    description: "Filter by project ID",
  })
  @ApiResponse({
    status: 200,
    description: "List of sprints",
    type: [SprintResponseDto],
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async findAll(
    @CurrentUser() user: UserContext,
    @Query("projectId") projectId?: string,
  ) {
    return this.sprintService.findAll(
      user.orgId,
      user.userId,
      user.role,
      projectId,
    );
  }

  @Get(":id")
  @ApiOperation({ summary: "Get sprint by ID" })
  @ApiParam({ name: "id", description: "Sprint ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Sprint details",
    type: SprintResponseDto,
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Sprint not found" })
  async findOne(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.sprintService.findOne(user.orgId, id, user.userId, user.role);
  }

  @Patch(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_SPRINT")
  @ApiOperation({ summary: "Update sprint" })
  @ApiParam({ name: "id", description: "Sprint ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Sprint updated successfully",
    type: SprintResponseDto,
  })
  @ApiResponse({ status: 400, description: "Invalid input" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Sprint not found" })
  async update(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() updateSprintDto: UpdateSprintDto,
  ) {
    return this.sprintService.update(
      user.orgId,
      id,
      updateSprintDto,
      user.userId,
      user.role,
    );
  }

  @Patch(":id/start")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_SPRINT")
  @ApiOperation({ summary: "Start a sprint" })
  @ApiParam({ name: "id", description: "Sprint ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Sprint started",
    type: SprintResponseDto,
  })
  @ApiResponse({ status: 400, description: "Sprint cannot be started" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Sprint not found" })
  async startSprint(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.sprintService.startSprint(
      user.orgId,
      id,
      user.userId,
      user.role,
    );
  }

  @Patch(":id/complete")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_SPRINT")
  @ApiOperation({ summary: "Complete a sprint" })
  @ApiParam({ name: "id", description: "Sprint ID", format: "uuid" })
  @ApiResponse({
    status: 200,
    description: "Sprint completed",
    type: SprintResponseDto,
  })
  @ApiResponse({ status: 400, description: "Sprint cannot be completed" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Sprint not found" })
  async completeSprint(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.sprintService.completeSprint(
      user.orgId,
      id,
      user.userId,
      user.role,
    );
  }

  @Delete(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_SPRINT")
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Delete sprint" })
  @ApiParam({ name: "id", description: "Sprint ID", format: "uuid" })
  @ApiResponse({ status: 204, description: "Sprint deleted successfully" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 404, description: "Sprint not found" })
  async remove(
    @CurrentUser() user: UserContext,
    @Param("id", ParseUUIDPipe) id: string,
  ) {
    return this.sprintService.remove(user.orgId, id, user.userId, user.role);
  }
}
