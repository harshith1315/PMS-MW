import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, MaxLength, IsNotEmpty, IsEnum, IsEmail } from 'class-validator';
import { Status } from '../../../common/enums';

export class CreateOrganizationDto {
  @ApiProperty({ description: 'Organization name', maxLength: 255 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name: string;

  @ApiPropertyOptional({ description: 'Legacy identity tenant metadata (not used for authentication)' })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  azureTenantId?: string;

  @ApiProperty({
    description:
      'Email of the initial ORG_ADMIN. A one-time password setup link is returned after creation.',
    example: 'jane.admin@acme.com',
  })
  @IsEmail()
  @IsNotEmpty()
  orgAdminEmail: string;
}

export class CreateOrganizationResponseDto {
  @ApiProperty({ format: 'uuid' }) id: string;
  @ApiProperty() name: string;
  @ApiPropertyOptional() azureTenantId?: string;
  @ApiProperty() status: string;
  @ApiProperty({ format: 'date-time' }) createdAt: Date;
  @ApiProperty({ description: 'Pre-created ORG_ADMIN account' }) orgAdmin: {
    id: string;
    email: string;
    role: string;
    status: string;
  };
  @ApiProperty({ description: 'One-time password setup token; share via a trusted channel' })
  setupToken: string;
}

export class UpdateOrganizationDto {
  @ApiPropertyOptional({ description: 'Organization name', maxLength: 255 })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  name?: string;

  @ApiPropertyOptional({ description: 'Legacy identity tenant metadata (not used for authentication)' })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  azureTenantId?: string;

  @ApiPropertyOptional({ enum: Status, description: 'Organization status' })
  @IsEnum(Status)
  @IsOptional()
  status?: Status;
}

export class OrganizationResponseDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  azureTenantId?: string;

  @ApiProperty({ enum: Status })
  status: string;

  @ApiProperty({ format: 'date-time' })
  createdAt: Date;
}

export class SetOrgAdminDto {
  @ApiProperty({
    description:
      'Email address of the user to assign as ORG_ADMIN. ' +
      'The user must complete password setup using an invitation link.',
    example: 'jane.admin@acme.com',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;
}

export class OrgProjectStatsDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  taskCount: number;
}

export class OrgStatsItemDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty({ enum: Status })
  status: string;

  @ApiProperty()
  userCount: number;

  @ApiProperty()
  projectCount: number;

  @ApiProperty({ type: [OrgProjectStatsDto] })
  projects: OrgProjectStatsDto[];
}

export class PlatformStatsDto {
  @ApiProperty()
  totalOrganizations: number;

  @ApiProperty()
  totalUsers: number;

  @ApiProperty()
  totalProjects: number;

  @ApiProperty()
  totalTasks: number;

  @ApiProperty({ type: [OrgStatsItemDto] })
  organizations: OrgStatsItemDto[];
}

// ─── Admin Dashboard DTOs ────────────────────────────────────────────────────

export class DashboardUserCountsDto {
  @ApiProperty() total: number;
  @ApiProperty() active: number;
  @ApiProperty() inactive: number;
}

export class DashboardProjectCountsDto {
  @ApiProperty() total: number;
  @ApiProperty() active: number;
}

export class DashboardSprintCountsDto {
  @ApiProperty() total: number;
  @ApiProperty() planned: number;
  @ApiProperty() active: number;
  @ApiProperty() completed: number;
}

export class DashboardTaskCountsDto {
  @ApiProperty() total: number;
  @ApiProperty() todo: number;
  @ApiProperty() inProgress: number;
  @ApiProperty() done: number;
  @ApiProperty() cancelled: number;
}

export class DashboardProjectBreakdownDto {
  @ApiProperty({ format: 'uuid' }) id: string;
  @ApiProperty() name: string;
  @ApiProperty() status: string;
  @ApiProperty() teamSize: number;
  @ApiProperty({ type: DashboardSprintCountsDto }) sprints: DashboardSprintCountsDto;
  @ApiProperty({ type: DashboardTaskCountsDto }) tasks: DashboardTaskCountsDto;
}

export class DashboardOrgTileDto {
  @ApiProperty({ format: 'uuid' }) id: string;
  @ApiProperty() name: string;
  @ApiProperty() status: string;
  @ApiProperty({ format: 'date-time' }) createdAt: Date;
  @ApiProperty({ type: DashboardUserCountsDto }) users: DashboardUserCountsDto;
  @ApiProperty({ type: DashboardProjectCountsDto }) projects: DashboardProjectCountsDto;
  @ApiProperty({ type: DashboardSprintCountsDto }) sprints: DashboardSprintCountsDto;
  @ApiProperty({ type: DashboardTaskCountsDto }) tasks: DashboardTaskCountsDto;
  @ApiProperty({ type: [DashboardProjectBreakdownDto] }) projectBreakdown: DashboardProjectBreakdownDto[];
}

export class DashboardSummaryDto {
  @ApiProperty() totalOrganizations: number;
  @ApiProperty() activeOrganizations: number;
  @ApiProperty() totalUsers: number;
  @ApiProperty() activeUsers: number;
  @ApiProperty() totalProjects: number;
  @ApiProperty() activeProjects: number;
  @ApiProperty() totalSprints: number;
  @ApiProperty() activeSprints: number;
  @ApiProperty() totalTasks: number;
  @ApiProperty() openTasks: number;
  @ApiProperty() inProgressTasks: number;
  @ApiProperty() completedTasks: number;
}

export class AdminDashboardDto {
  @ApiProperty({ description: 'ISO timestamp when the stats were generated' })
  generatedAt: string;

  @ApiProperty({ description: 'Active filters applied to the query' })
  filter: { orgId: string | null };

  @ApiProperty({ type: DashboardSummaryDto })
  summary: DashboardSummaryDto;

  @ApiProperty({ type: [DashboardOrgTileDto] })
  organizations: DashboardOrgTileDto[];
}
