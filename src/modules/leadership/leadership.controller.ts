import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
} from "@nestjs/common";
import { ApiTags, ApiOperation, ApiBearerAuth } from "@nestjs/swagger";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { TenantGuard } from "../../common/guards/tenant.guard";
import { RolesGuard } from "../../common/guards/roles.guard";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { Roles } from "../../common/decorators/roles.decorator";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Permissions } from "../../common/decorators/permissions.decorator";
import { UserContext } from "../auth/auth.service";
import { LeadershipService } from "./leadership.service";
import { CreateLeaderDto, UpdateLeaderDto } from "./dto/leadership.dto";

@ApiTags("Leadership")
@ApiBearerAuth()
@Controller("leadership")
@UseGuards(JwtAuthGuard, TenantGuard)
export class LeadershipController {
  constructor(private readonly leadershipService: LeadershipService) {}

  /**
   * GET /api/v1/leadership
   * Get all leaders in organization (Admin only)
   */
  @Get()
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_LEADERSHIP")
  @ApiOperation({ summary: "Get all leaders (Admin only)" })
  async getLeaders(@CurrentUser() user: UserContext) {
    return this.leadershipService.getLeaders(user.orgId);
  }

  /**
   * GET /api/v1/leadership/:id
   * Get specific leader details
   */
  @Get(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_LEADERSHIP")
  @ApiOperation({ summary: "Get leader details" })
  async getLeaderById(
    @Param("id") leaderId: string,
    @CurrentUser() user: UserContext,
  ) {
    return this.leadershipService.getLeaderById(user.orgId, leaderId);
  }

  /**
   * GET /api/v1/leadership/:id/projects
   * Get projects managed by a leader
   */
  @Get(":id/projects")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_LEADERSHIP")
  @ApiOperation({ summary: "Get leader projects (Admin only)" })
  async getLeaderProjects(
    @Param("id") leaderId: string,
    @CurrentUser() user: UserContext,
  ) {
    return this.leadershipService.getLeaderProjects(user.orgId, leaderId);
  }

  /**
   * POST /api/v1/leadership
   * Create a new leader (Admin only)
   */
  @Post()
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_LEADERSHIP")
  @ApiOperation({ summary: "Create a new leader (Admin only)" })
  async createLeader(
    @Body() createLeaderDto: CreateLeaderDto,
    @CurrentUser() user: UserContext,
  ) {
    return this.leadershipService.createLeader(user.orgId, createLeaderDto);
  }

  /**
   * PUT /api/v1/leadership/:id
   * Update a leader (Admin only)
   */
  @Put(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_LEADERSHIP")
  @ApiOperation({ summary: "Update a leader (Admin only)" })
  async updateLeader(
    @Param("id") leaderId: string,
    @Body() updateLeaderDto: UpdateLeaderDto,
    @CurrentUser() user: UserContext,
  ) {
    return this.leadershipService.updateLeader(
      user.orgId,
      leaderId,
      updateLeaderDto,
    );
  }

  /**
   * DELETE /api/v1/leadership/:id
   * Delete/deactivate a leader (Admin only)
   */
  @Delete(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("MANAGE_LEADERSHIP")
  @ApiOperation({ summary: "Delete a leader (Admin only)" })
  async deleteLeader(
    @Param("id") leaderId: string,
    @CurrentUser() user: UserContext,
  ) {
    await this.leadershipService.deleteLeader(user.orgId, leaderId);
    return { message: "Leader removed successfully" };
  }
}
