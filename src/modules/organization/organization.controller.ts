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
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserContext } from '../auth/auth.service';
import { OrganizationService } from './organization.service';
import {
  CreateOrganizationDto,
  UpdateOrganizationDto,
  OrganizationResponseDto,
  CreateOrganizationResponseDto,
  SetOrgAdminDto,
  PlatformStatsDto,
  AdminDashboardDto,
} from './dto/organization.dto';

@ApiTags('Organizations')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@Controller('organizations')
export class OrganizationController {
  constructor(private readonly organizationService: OrganizationService) {}

  @Get('stats')
  @ApiOperation({ summary: 'Get platform-wide stats (ADMIN only)' })
  @ApiResponse({
    status: 200,
    description: 'Platform statistics',
    type: PlatformStatsDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - ADMIN only' })
  async getStats() {
    return this.organizationService.getStats();
  }

  @Get('dashboard')
  @Roles('ADMIN', 'ORG_ADMIN')
  @ApiOperation({
    summary: 'Dashboard stats — scoped by role',
    description:
      'ADMIN: returns all orgs or a specific org when `orgId` is provided. ' +
      'ORG_ADMIN: always returns their own organization\'s stats (orgId query param is ignored).',
  })
  @ApiQuery({
    name: 'orgId',
    required: false,
    type: String,
    description: 'Scope to a specific organization (UUID). ADMIN only — ORG_ADMIN always sees their own org.',
  })
  @ApiResponse({
    status: 200,
    description: 'Dashboard statistics',
    type: AdminDashboardDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - ADMIN or ORG_ADMIN only' })
  async getDashboard(
    @CurrentUser() user: UserContext,
    @Query('orgId', new ParseUUIDPipe({ optional: true })) orgId?: string,
  ) {
    // ORG_ADMIN can only see their own organization
    const scopedOrgId = user.role === 'ORG_ADMIN' ? user.orgId : orgId;
    return this.organizationService.getDashboardStats(scopedOrgId);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new organization (ADMIN only)' })
  @ApiResponse({
    status: 201,
    description: 'Organization created with ORG_ADMIN pre-provisioned',
    type: CreateOrganizationResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - ADMIN only' })
  @ApiResponse({ status: 409, description: 'Organization metadata already exists' })
  async create(@Body() createDto: CreateOrganizationDto) {
    return this.organizationService.create(createDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all organizations (ADMIN only)' })
  @ApiResponse({
    status: 200,
    description: 'List of organizations',
    type: [OrganizationResponseDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - ADMIN only' })
  async findAll() {
    return this.organizationService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get organization by ID (ADMIN only)' })
  @ApiParam({ name: 'id', description: 'Organization ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Organization details',
    type: OrganizationResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - ADMIN only' })
  @ApiResponse({ status: 404, description: 'Organization not found' })
  async findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.organizationService.findOne(id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update organization (ADMIN only)' })
  @ApiParam({ name: 'id', description: 'Organization ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Organization updated successfully',
    type: OrganizationResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - ADMIN only' })
  @ApiResponse({ status: 404, description: 'Organization not found' })
  @ApiResponse({ status: 409, description: 'Azure tenant ID already exists' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateDto: UpdateOrganizationDto,
  ) {
    return this.organizationService.update(id, updateDto);
  }

  @Patch(':id/org-admin')
  @ApiOperation({
    summary: 'Set or change ORG_ADMIN of an organization (ADMIN only)',
    description:
      'Pass the target user\'s email address. ' +
      'An existing organization user is promoted, or a new account is created.',
  })
  @ApiParam({ name: 'id', description: 'Organization ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'ORG_ADMIN assigned successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - ADMIN only' })
  @ApiResponse({ status: 404, description: 'Organization or user not found' })
  async setOrgAdmin(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SetOrgAdminDto,
  ) {
    return this.organizationService.setOrgAdmin(id, dto.email);
  }

  @Patch(':id/deactivate')
  @ApiOperation({ summary: 'Deactivate organization (ADMIN only)' })
  @ApiParam({ name: 'id', description: 'Organization ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Organization deactivated',
    type: OrganizationResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - ADMIN only' })
  @ApiResponse({ status: 404, description: 'Organization not found' })
  async deactivate(@Param('id', ParseUUIDPipe) id: string) {
    return this.organizationService.deactivate(id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete organization (ADMIN only)' })
  @ApiParam({ name: 'id', description: 'Organization ID', format: 'uuid' })
  @ApiResponse({ status: 204, description: 'Organization deleted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - ADMIN only' })
  @ApiResponse({ status: 404, description: 'Organization not found' })
  async remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.organizationService.remove(id);
  }
}
