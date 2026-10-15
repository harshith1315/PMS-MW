import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  Post,
  Query,
  Put,
  UseGuards,
} from "@nestjs/common";
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from "@nestjs/swagger";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import { Permissions } from "../../common/decorators/permissions.decorator";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { RolesGuard } from "../../common/guards/roles.guard";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { TenantGuard } from "../../common/guards/tenant.guard";
import { UserContext } from "../auth/auth.service";
import { BusinessUnitService } from "./business-unit.service";
import {
  BusinessUnitResponseDto,
  CreateBusinessUnitDto,
  UpdateBusinessUnitDto,
} from "./dto/business-unit.dto";

@ApiTags("Business Units")
@Controller("business-units")
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth("bearer")
export class BusinessUnitController {
  constructor(private readonly service: BusinessUnitService) {}

  @Get()
  @ApiOperation({
    summary: "List all active business units for the organization",
  })
  @ApiResponse({ status: 200, type: [BusinessUnitResponseDto] })
  list(
    @CurrentUser() user: UserContext,
    @Query("includeInactive") includeInactive?: string,
  ) {
    return this.service.list(user.orgId, includeInactive === "true");
  }

  @Post()
  @UseGuards(PermissionsGuard)
  @Permissions("CREATE_BUSINESS_UNIT")
  @ApiOperation({ summary: "Create a business unit (ORG_ADMIN only)" })
  @ApiResponse({ status: 201, type: BusinessUnitResponseDto })
  create(@CurrentUser() user: UserContext, @Body() dto: CreateBusinessUnitDto) {
    return this.service.create(user.orgId, dto);
  }

  @Put(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("EDIT_BUSINESS_UNIT")
  @ApiOperation({ summary: "Update a business unit (ORG_ADMIN only)" })
  @ApiResponse({ status: 200, type: BusinessUnitResponseDto })
  update(
    @CurrentUser() user: UserContext,
    @Param("id") id: string,
    @Body() dto: UpdateBusinessUnitDto,
  ) {
    return this.service.update(user.orgId, id, dto);
  }

  @Delete(":id")
  @UseGuards(PermissionsGuard)
  @Permissions("DELETE_BUSINESS_UNIT")
  @HttpCode(204)
  @ApiOperation({ summary: "Delete a business unit (ORG_ADMIN only)" })
  @ApiResponse({ status: 204, description: "Business unit deleted" })
  async remove(@CurrentUser() user: UserContext, @Param("id") id: string) {
    await this.service.remove(user.orgId, id);
  }
}
