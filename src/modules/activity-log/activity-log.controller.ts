import { Controller, Get, Query, UseGuards } from "@nestjs/common";
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from "@nestjs/swagger";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Permissions } from "../../common/decorators/permissions.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { RolesGuard } from "../../common/guards/roles.guard";
import { TenantGuard } from "../../common/guards/tenant.guard";
import { UserContext } from "../auth/auth.service";
import { ActivityLogQueryDto } from "./dto/activity-log-query.dto";
import { ActivityLogService } from "./activity-log.service";

@ApiTags("Activity Logs")
@Controller("activity-logs")
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth("bearer")
export class ActivityLogController {
  constructor(private readonly activityLogService: ActivityLogService) {}

  @Get()
  @UseGuards(RolesGuard, PermissionsGuard)
  @Roles("ORG_ADMIN", "CEO")
  @Permissions("VIEW_ACTIVITY_LOGS")
  @ApiOperation({ summary: "List activity logs (ORG_ADMIN/CEO with permission)" })
  @ApiResponse({
    status: 200,
    description: "Paginated activity logs",
  })
  list(@CurrentUser() user: UserContext, @Query() query: ActivityLogQueryDto) {
    return this.activityLogService.list(user.orgId, query);
  }
}
