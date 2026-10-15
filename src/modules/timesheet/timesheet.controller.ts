import { Body, Controller, Get, Post, Query, UseGuards } from "@nestjs/common";
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from "@nestjs/swagger";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { TenantGuard } from "../../common/guards/tenant.guard";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { Permissions } from "../../common/decorators/permissions.decorator";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { UserContext } from "../auth/auth.service";
import {
  CreateTimesheetDto,
  TimesheetQueryDto,
  TimesheetResponseDto,
} from "./dto/timesheet.dto";
import { TimesheetService } from "./timesheet.service";

function formatDateOnly(value: Date | string): string {
  // PostgreSQL DATE fields may come back as string depending on driver settings.
  return typeof value === "string"
    ? value.slice(0, 10)
    : value.toISOString().slice(0, 10);
}

@ApiTags("Timesheets")
@Controller("timesheets")
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth("bearer")
export class TimesheetController {
  constructor(private readonly timesheetService: TimesheetService) {}

  @Post()
  @ApiOperation({ summary: "Create timesheet entry" })
  @ApiResponse({
    status: 201,
    description: "Timesheet created",
    type: TimesheetResponseDto,
  })
  @ApiResponse({ status: 400, description: "Invalid input" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async create(
    @CurrentUser() user: UserContext,
    @Body() dto: CreateTimesheetDto,
  ) {
    const created = await this.timesheetService.create(
      user.orgId,
      user.userId,
      dto,
    );
    return {
      id: created.id,
      date: formatDateOnly(created.entryDate),
      projectName: created.projectName,
      taskDetails: created.taskDetails,
      status: created.status,
      createdAt: created.createdAt,
      updatedAt: created.updatedAt,
    };
  }

  @Get("my")
  @ApiOperation({ summary: "List current user timesheets" })
  @ApiResponse({
    status: 200,
    description: "Timesheet list",
    type: [TimesheetResponseDto],
  })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  async listMine(
    @CurrentUser() user: UserContext,
    @Query() query: TimesheetQueryDto,
  ) {
    const list = await this.timesheetService.listMine(
      user.orgId,
      user.userId,
      query,
    );
    return list.map((item) => ({
      id: item.id,
      date: formatDateOnly(item.entryDate),
      projectName: item.projectName,
      taskDetails: item.taskDetails,
      status: item.status,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    }));
  }

  @Get("team")
  @UseGuards(PermissionsGuard)
  @Permissions("VIEW_TEAM_TIMESHEETS")
  @ApiOperation({ summary: "List timesheets for team members" })
  @ApiResponse({ status: 200, description: "Team timesheet list" })
  @ApiResponse({ status: 401, description: "Unauthorized" })
  @ApiResponse({ status: 403, description: "Forbidden" })
  async listTeam(
    @CurrentUser() user: UserContext,
    @Query() query: TimesheetQueryDto,
  ) {
    const list = await this.timesheetService.listTeam(
      user.orgId,
      user.userId,
      user.role,
      query,
    );
    return list.map((item) => ({
      id: item.id,
      date: formatDateOnly(item.entryDate),
      projectName: item.projectName,
      taskDetails: item.taskDetails,
      status: item.status,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      userName: item.userName,
      userEmail: item.userEmail,
      userId: item.userId,
    }));
  }
}
