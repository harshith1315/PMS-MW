import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsUUID,
  IsOptional,
  IsEnum,
  IsDateString,
  IsIn,
  MaxLength,
  IsNotEmpty,
  IsEmail,
  Matches,
  IsArray,
  IsNumber,
  IsBoolean,
  Min,
  Max,
} from 'class-validator';
import { Status, ProjectRole, ProjectLinkType, ResourceType } from '../../../common/enums';

// ===== Enums for Project =====
export type DeliverableType = 'PRODUCT' | 'PROJECT' | 'SERVICE' | 'SUPPORT';
export type ProjectType = 'SUPPORT' | 'INTERNAL' | 'CLIENT' | 'MAINTENANCE' | 'TIME_TRACKING';
export type ExecutionModel = 'AGILE' | 'KANBAN' | 'WATERFALL' | 'HYBRID';
export type Priority = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
export type RiskLevel = 'LOW' | 'MEDIUM' | 'HIGH';
export type Currency = 'USD' | 'EUR' | 'GBP' | 'INR' | 'AUD';
export type BillingType = 'FIXED_PRICE' | 'TIME_AND_MATERIAL' | 'RETAINER' | 'NOT_BILLABLE';
export type ContractType = 'FIXED' | 'RENEWABLE' | 'ONGOING';
export type EstimationUnit = 'STORY_POINTS' | 'HOURS' | 'DAYS' | 'T_SHIRT';
export type IterationStartDay = 'MONDAY' | 'TUESDAY' | 'WEDNESDAY' | 'THURSDAY' | 'FRIDAY' | 'SATURDAY' | 'SUNDAY';
export type ProjectStatus = 'DRAFT' | 'ACTIVE' | 'ON_HOLD' | 'COMPLETED' | 'ARCHIVED';

export class CreateProjectDto {
  // ===== Tab 1: Basic Information =====
  @ApiProperty({ description: 'Project name', maxLength: 255 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name: string;

  @ApiProperty({
    description: 'Unique project code (used in task codes)',
    maxLength: 50,
    example: 'PROJ',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  @Matches(/^[A-Z][A-Z0-9_-]*$/, {
    message: 'Project code must start with a letter and contain only uppercase letters, numbers, hyphens, and underscores',
  })
  projectCode: string;

  @ApiPropertyOptional({ description: 'Project description/overview' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ description: 'Business unit ID', format: 'uuid' })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  businessUnit?: string;

  @ApiPropertyOptional({ description: 'Deliverable type', enum: ['PRODUCT', 'PROJECT', 'SERVICE', 'SUPPORT'] })
  @IsIn(['PRODUCT', 'PROJECT', 'SERVICE', 'SUPPORT'])
  @IsOptional()
  deliverableType?: DeliverableType;

  @ApiPropertyOptional({ description: 'Project type', enum: ['SUPPORT', 'INTERNAL', 'CLIENT', 'MAINTENANCE', 'TIME_TRACKING'] })
  @IsIn(['SUPPORT', 'INTERNAL', 'CLIENT', 'MAINTENANCE', 'TIME_TRACKING'])
  @IsOptional()
  projectType?: ProjectType;

  @ApiPropertyOptional({ description: 'Execution model', enum: ['AGILE', 'KANBAN', 'WATERFALL', 'HYBRID'] })
  @IsIn(['AGILE', 'KANBAN', 'WATERFALL', 'HYBRID'])
  @IsOptional()
  executionModel?: ExecutionModel;

  // ===== Tab 2: Ownership & Governance =====
  @ApiPropertyOptional({ description: 'Project manager user ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  managerId?: string;

  @ApiPropertyOptional({ description: 'Delivery manager user ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  deliveryManagerId?: string;

  @ApiPropertyOptional({ description: 'Finance member user ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  financeMemberId?: string;

  @ApiPropertyOptional({ description: 'Sponsor user ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  sponsorId?: string;

  @ApiPropertyOptional({ description: 'Approved by user ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  approvedById?: string;

  @ApiPropertyOptional({ description: 'Project status', enum: ['DRAFT', 'ACTIVE', 'ON_HOLD', 'COMPLETED', 'ARCHIVED'] })
  @IsIn(['DRAFT', 'ACTIVE', 'ON_HOLD', 'COMPLETED', 'ARCHIVED'])
  @IsOptional()
  status?: ProjectStatus;

  @ApiPropertyOptional({ description: 'Priority', enum: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'] })
  @IsIn(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'])
  @IsOptional()
  priority?: Priority;

  @ApiPropertyOptional({ description: 'Risk level', enum: ['LOW', 'MEDIUM', 'HIGH'] })
  @IsIn(['LOW', 'MEDIUM', 'HIGH'])
  @IsOptional()
  riskLevel?: RiskLevel;

  // ===== Tab 3: Timeline =====
  @ApiPropertyOptional({ description: 'Planned start date', format: 'date', example: '2026-03-10' })
  @IsDateString()
  @IsOptional()
  startDate?: string;

  @ApiPropertyOptional({ description: 'Planned end date', format: 'date', example: '2026-08-11' })
  @IsDateString()
  @IsOptional()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Kick-off date', format: 'date', example: '2026-03-09' })
  @IsDateString()
  @IsOptional()
  kickoffDate?: string;

  @ApiPropertyOptional({ description: 'Milestone template' })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  milestoneTemplate?: string;

  // ===== Tab 4: Financials =====
  @ApiPropertyOptional({ description: 'Planned budget', example: 2500000, minimum: 0 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  budget?: number;

  @ApiPropertyOptional({ description: 'Approved budget amount', example: 2500000, minimum: 0 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  budgetApproved?: number;

  @ApiPropertyOptional({ description: 'Currency', enum: ['USD', 'EUR', 'GBP', 'INR', 'AUD'] })
  @IsIn(['USD', 'EUR', 'GBP', 'INR', 'AUD'])
  @IsOptional()
  currency?: Currency;

  @ApiPropertyOptional({ description: 'Cost center ID', maxLength: 100, example: 'CC-2026-001' })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  costCenterId?: string;

  @ApiPropertyOptional({ description: 'Finance code', maxLength: 50, example: 'FIN-2026-001' })
  @IsString()
  @IsOptional()
  @MaxLength(50)
  financeCode?: string;

  @ApiPropertyOptional({ description: 'Billing type', enum: ['FIXED_PRICE', 'TIME_AND_MATERIAL', 'RETAINER', 'NOT_BILLABLE'] })
  @IsIn(['FIXED_PRICE', 'TIME_AND_MATERIAL', 'RETAINER', 'NOT_BILLABLE'])
  @IsOptional()
  billingType?: BillingType;

  @ApiPropertyOptional({ description: 'Contract type', enum: ['FIXED', 'RENEWABLE', 'ONGOING'] })
  @IsIn(['FIXED', 'RENEWABLE', 'ONGOING'])
  @IsOptional()
  contractType?: ContractType;

  @ApiPropertyOptional({ description: 'Revenue', example: 3000000, minimum: 0 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  revenue?: number;

  // ===== Tab 5: Team Setup (handled via user mappings) =====

  // ===== Tab 6: Configuration (Dynamic based on Execution Model) =====
  // Agile fields
  @ApiPropertyOptional({ description: 'Sprint duration in weeks (1-8)', example: 2 })
  @IsNumber()
  @Min(1)
  @Max(8)
  @IsOptional()
  sprintDuration?: number;

  @ApiPropertyOptional({ description: 'Iteration start day', enum: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'] })
  @IsIn(['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'])
  @IsOptional()
  iterationStartDay?: IterationStartDay;

  @ApiPropertyOptional({ description: 'Estimation unit', enum: ['STORY_POINTS', 'HOURS', 'DAYS', 'T_SHIRT'] })
  @IsIn(['STORY_POINTS', 'HOURS', 'DAYS', 'T_SHIRT'])
  @IsOptional()
  estimationUnit?: EstimationUnit;

  @ApiPropertyOptional({ description: 'Enable velocity tracking' })
  @IsBoolean()
  @IsOptional()
  velocityTracking?: boolean;

  // Kanban fields
  @ApiPropertyOptional({ description: 'WIP limits for Kanban', example: 5 })
  @IsNumber()
  @Min(1)
  @IsOptional()
  wipLimits?: number;

  @ApiPropertyOptional({ description: 'Enable continuous flow' })
  @IsBoolean()
  @IsOptional()
  continuousFlow?: boolean;

  // Waterfall fields
  @ApiPropertyOptional({ description: 'Phase template' })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  phaseTemplate?: string;

  @ApiPropertyOptional({ description: 'Stage gates as array of strings', type: [String] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  stageGates?: string[];

  // ===== Tab 7: Integrations =====
  @ApiPropertyOptional({ description: 'Document repository URL', example: 'https://sharepoint.com/sites/project' })
  @IsString()
  @IsOptional()
  @MaxLength(500)
  documentRepository?: string;

  // ===== Tab 8: Client & Contract Info =====
  @ApiPropertyOptional({ description: 'Client name', maxLength: 255 })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  clientName?: string;

  @ApiPropertyOptional({ description: 'Client location', maxLength: 255 })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  clientLocation?: string;

  @ApiPropertyOptional({ description: 'Client SPOC (Single Point of Contact)', maxLength: 255 })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  clientSpoc?: string;

  @ApiPropertyOptional({ description: 'Contract start date', format: 'date' })
  @IsDateString()
  @IsOptional()
  contractStartDate?: string;

  @ApiPropertyOptional({ description: 'Contract end date', format: 'date' })
  @IsDateString()
  @IsOptional()
  contractEndDate?: string;

  // ===== Tab 9: Additional Details =====
  @ApiPropertyOptional({ description: 'Project purpose/description' })
  @IsString()
  @IsOptional()
  purpose?: string;

  @ApiPropertyOptional({ description: 'Short project summary' })
  @IsString()
  @IsOptional()
  projectSummary?: string;

  @ApiPropertyOptional({ description: 'Cost management notes' })
  @IsString()
  @IsOptional()
  costManagement?: string;

  @ApiPropertyOptional({ description: 'Comments' })
  @IsString()
  @IsOptional()
  comments?: string;

  @ApiPropertyOptional({
    description: 'Project technology stack as simple list of names',
    type: [String],
    example: ['React JS', 'Node JS', 'PostgreSQL'],
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  techStack?: string[];

  @ApiPropertyOptional({
    description: 'Project dependencies as simple list of names',
    type: [String],
    example: ['SMS Gateway API'],
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  dependencies?: string[];
}

export class UpdateProjectDto {
  // ===== Tab 1: Basic Information =====
  @ApiPropertyOptional({ description: 'Project name', maxLength: 255 })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  name?: string;

  @ApiPropertyOptional({ description: 'Project description/overview' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ description: 'Business unit', maxLength: 100 })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  businessUnit?: string;

  @ApiPropertyOptional({ description: 'Deliverable type', enum: ['PRODUCT', 'PROJECT', 'SERVICE', 'SUPPORT'] })
  @IsIn(['PRODUCT', 'PROJECT', 'SERVICE', 'SUPPORT'])
  @IsOptional()
  deliverableType?: DeliverableType;

  @ApiPropertyOptional({ description: 'Project type', enum: ['SUPPORT', 'INTERNAL', 'CLIENT', 'MAINTENANCE', 'TIME_TRACKING'] })
  @IsIn(['SUPPORT', 'INTERNAL', 'CLIENT', 'MAINTENANCE', 'TIME_TRACKING'])
  @IsOptional()
  projectType?: ProjectType;

  @ApiPropertyOptional({ description: 'Execution model', enum: ['AGILE', 'KANBAN', 'WATERFALL', 'HYBRID'] })
  @IsIn(['AGILE', 'KANBAN', 'WATERFALL', 'HYBRID'])
  @IsOptional()
  executionModel?: ExecutionModel;

  // ===== Tab 2: Ownership & Governance =====
  @ApiPropertyOptional({ description: 'Project manager user ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  managerId?: string;

  @ApiPropertyOptional({ description: 'Delivery manager user ID', format: 'uuid' })
  @IsUUID()
  @ApiPropertyOptional({ description: 'Finance member user ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  financeMemberId?: string;

  @ApiPropertyOptional({ enum: Status, description: 'Project status' })
  @IsEnum(Status)
  @IsOptional()
  deliveryManagerId?: string;

  @ApiPropertyOptional({ description: 'Sponsor user ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  sponsorId?: string;

  @ApiPropertyOptional({ description: 'Approved by user ID', format: 'uuid' })
  @IsUUID()
  @IsOptional()
  approvedById?: string;

  @ApiPropertyOptional({ description: 'Project status', enum: ['DRAFT', 'ACTIVE', 'ON_HOLD', 'COMPLETED', 'ARCHIVED'] })
  @IsIn(['DRAFT', 'ACTIVE', 'ON_HOLD', 'COMPLETED', 'ARCHIVED'])
  @IsOptional()
  status?: ProjectStatus;

  @ApiPropertyOptional({ description: 'Priority', enum: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'] })
  @IsIn(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'])
  @IsOptional()
  priority?: Priority;

  @ApiPropertyOptional({ description: 'Risk level', enum: ['LOW', 'MEDIUM', 'HIGH'] })
  @IsIn(['LOW', 'MEDIUM', 'HIGH'])
  @IsOptional()
  riskLevel?: RiskLevel;

  // ===== Tab 3: Timeline =====
  @ApiPropertyOptional({ description: 'Planned start date', format: 'date' })
  @IsDateString()
  @IsOptional()
  startDate?: string;

  @ApiPropertyOptional({ description: 'Planned end date', format: 'date' })
  @IsDateString()
  @IsOptional()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Kick-off date', format: 'date' })
  @IsDateString()
  @IsOptional()
  kickoffDate?: string;

  @ApiPropertyOptional({ description: 'Milestone template' })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  milestoneTemplate?: string;

  // ===== Tab 4: Financials =====
  @ApiPropertyOptional({ description: 'Planned budget', minimum: 0 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  budget?: number;

  @ApiPropertyOptional({ description: 'Approved budget amount', minimum: 0 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  budgetApproved?: number;

  @ApiPropertyOptional({ description: 'Currency', enum: ['USD', 'EUR', 'GBP', 'INR', 'AUD'] })
  @IsIn(['USD', 'EUR', 'GBP', 'INR', 'AUD'])
  @IsOptional()
  currency?: Currency;

  @ApiPropertyOptional({ description: 'Cost center ID', maxLength: 100 })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  costCenterId?: string;

  @ApiPropertyOptional({ description: 'Finance code', maxLength: 50 })
  @IsString()
  @IsOptional()
  @MaxLength(50)
  financeCode?: string;

  @ApiPropertyOptional({ description: 'Billing type', enum: ['FIXED_PRICE', 'TIME_AND_MATERIAL', 'RETAINER', 'NOT_BILLABLE'] })
  @IsIn(['FIXED_PRICE', 'TIME_AND_MATERIAL', 'RETAINER', 'NOT_BILLABLE'])
  @IsOptional()
  billingType?: BillingType;

  @ApiPropertyOptional({ description: 'Contract type', enum: ['FIXED', 'RENEWABLE', 'ONGOING'] })
  @IsIn(['FIXED', 'RENEWABLE', 'ONGOING'])
  @IsOptional()
  contractType?: ContractType;

  @ApiPropertyOptional({ description: 'Revenue', minimum: 0 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  revenue?: number;

  // ===== Tab 6: Configuration =====
  @ApiPropertyOptional({ description: 'Sprint duration in weeks (1-8)' })
  @IsNumber()
  @Min(1)
  @Max(8)
  @IsOptional()
  sprintDuration?: number;

  @ApiPropertyOptional({ description: 'Iteration start day' })
  @IsIn(['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'])
  @IsOptional()
  iterationStartDay?: IterationStartDay;

  @ApiPropertyOptional({ description: 'Estimation unit' })
  @IsIn(['STORY_POINTS', 'HOURS', 'DAYS', 'T_SHIRT'])
  @IsOptional()
  estimationUnit?: EstimationUnit;

  @ApiPropertyOptional({ description: 'Enable velocity tracking' })
  @IsBoolean()
  @IsOptional()
  velocityTracking?: boolean;

  @ApiPropertyOptional({ description: 'WIP limits for Kanban' })
  @IsNumber()
  @Min(1)
  @IsOptional()
  wipLimits?: number;

  @ApiPropertyOptional({ description: 'Enable continuous flow' })
  @IsBoolean()
  @IsOptional()
  continuousFlow?: boolean;

  @ApiPropertyOptional({ description: 'Phase template' })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  phaseTemplate?: string;

  @ApiPropertyOptional({ description: 'Stage gates', type: [String] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  stageGates?: string[];

  // ===== Tab 7: Integrations =====
  @ApiPropertyOptional({ description: 'Document repository URL' })
  @IsString()
  @IsOptional()
  @MaxLength(500)
  documentRepository?: string;

  // ===== Tab 8: Client & Contract Info =====
  @ApiPropertyOptional({ description: 'Client name', maxLength: 255 })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  clientName?: string;

  @ApiPropertyOptional({ description: 'Client location', maxLength: 255 })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  clientLocation?: string;

  @ApiPropertyOptional({ description: 'Client SPOC', maxLength: 255 })
  @IsString()
  @IsOptional()
  @MaxLength(255)
  clientSpoc?: string;

  @ApiPropertyOptional({ description: 'Contract start date', format: 'date' })
  @IsDateString()
  @IsOptional()
  contractStartDate?: string;

  @ApiPropertyOptional({ description: 'Contract end date', format: 'date' })
  @IsDateString()
  @IsOptional()
  contractEndDate?: string;

  // ===== Tab 9: Additional Details =====
  @ApiPropertyOptional({ description: 'Project purpose/description' })
  @IsString()
  @IsOptional()
  purpose?: string;

  @ApiPropertyOptional({ description: 'Short project summary' })
  @IsString()
  @IsOptional()
  projectSummary?: string;

  @ApiPropertyOptional({ description: 'Cost management notes' })
  @IsString()
  @IsOptional()
  costManagement?: string;

  @ApiPropertyOptional({ description: 'Comments' })
  @IsString()
  @IsOptional()
  comments?: string;

  @ApiPropertyOptional({ description: 'Technology stack', type: [String] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  techStack?: string[];

  @ApiPropertyOptional({ description: 'Dependencies', type: [String] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  dependencies?: string[];
}

export class AssignUserToProjectDto {
  @ApiProperty({
    description: 'Email of the user to assign. If not yet in the org they will be pre-provisioned.',
    example: 'john.doe@company.com',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ enum: ProjectRole, description: 'Role in the project' })
  @IsEnum(ProjectRole)
  @IsNotEmpty()
  projectRole: ProjectRole;

  @ApiProperty({
    enum: ResourceType,
    description: 'Whether the user is shared across projects or dedicated to this project',
    example: ResourceType.DEDICATED,
  })
  @IsEnum(ResourceType)
  @IsNotEmpty()
  resourceType: ResourceType;

  @ApiProperty({
    description: 'Allocated bandwidth percentage (1-100)',
    example: 50,
    minimum: 1,
    maximum: 100,
  })
  @IsNumber()
  @IsNotEmpty()
  @Min(1)
  @Max(100)
  allocatedBandwidth: number;
}

export class AddProjectLinkDto {
  @ApiProperty({ enum: ProjectLinkType, description: 'Type of link' })
  @IsEnum(ProjectLinkType)
  @IsNotEmpty()
  linkType: ProjectLinkType;

  @ApiProperty({ description: 'URL', example: 'https://github.com/org/repo' })
  @IsString()
  @IsNotEmpty()
  url: string;
}

export class ProjectQueryDto {
  @ApiPropertyOptional({ enum: Status, description: 'Filter by status' })
  @IsEnum(Status)
  @IsOptional()
  status?: Status;

  @ApiPropertyOptional({ description: 'Search in name and project code' })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({ description: 'Page number', default: 1 })
  @IsOptional()
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Items per page', default: 20 })
  @IsOptional()
  limit?: number = 20;
}

export class ProjectResponseDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty({ format: 'uuid' })
  orgId: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  projectCode: string;

  @ApiPropertyOptional()
  businessUnit?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  managerId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  financeMemberId?: string;

  @ApiPropertyOptional()
  financeMember?: { id: string; name: string; email: string };

  @ApiPropertyOptional()
  financeCode?: string;

  @ApiPropertyOptional({ example: 2500000 })
  budget?: number;

  @ApiPropertyOptional({ format: 'date' })
  kickoffDate?: Date;

  @ApiPropertyOptional({ format: 'date' })
  startDate?: Date;

  @ApiPropertyOptional({ format: 'date' })
  endDate?: Date;

  @ApiPropertyOptional({ enum: ['WEB', 'MOBILE', 'BOTH'] })
  projectType?: string;

  @ApiPropertyOptional()
  clientName?: string;

  @ApiPropertyOptional()
  clientLocation?: string;

  @ApiPropertyOptional()
  purpose?: string;

  @ApiPropertyOptional()
  projectSummary?: string;

  @ApiPropertyOptional()
  costManagement?: string;

  @ApiPropertyOptional({ type: [String] })
  techStack?: string[];

  @ApiPropertyOptional({ type: [String] })
  dependencies?: string[];

  @ApiProperty({ enum: Status })
  status: string;

  @ApiProperty({ format: 'date-time' })
  createdAt: Date;
}

export class UserProjectMappingResponseDto {
  @ApiProperty({ format: 'uuid' })
  id: string;

  @ApiProperty({ format: 'uuid' })
  userId: string;

  @ApiProperty({ format: 'uuid' })
  projectId: string;

  @ApiProperty({ enum: ProjectRole })
  role: string;

  @ApiProperty({ enum: ResourceType })
  resourceType: string;

  @ApiProperty({ description: 'Allocated bandwidth percentage (0-100)' })
  allocatedBandwidth: number;

  @ApiProperty({ description: 'Approval status', enum: ['PENDING', 'APPROVED', 'REJECTED'] })
  approvalStatus: string;

  @ApiPropertyOptional({ format: 'uuid' })
  requestedByUserId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  approvedByUserId?: string;

  @ApiPropertyOptional({ format: 'date-time' })
  approvedAt?: Date;

  @ApiProperty({ format: 'date-time' })
  assignedAt: Date;
}

export class ApproveBandwidthAllocationDto {
  @ApiProperty({ enum: ['APPROVED', 'REJECTED'] })
  @IsEnum(['APPROVED', 'REJECTED'])
  @IsNotEmpty()
  approvalStatus: 'APPROVED' | 'REJECTED';

  @ApiPropertyOptional({ description: 'Reason for rejection' })
  @IsString()
  @IsOptional()
  rejectionReason?: string;
}

export class UpdateBandwidthAllocationDto {
  @ApiProperty({
    description: 'New allocated bandwidth percentage (1-100)',
    example: 60,
    minimum: 1,
    maximum: 100,
  })
  @IsNumber()
  @IsNotEmpty()
  @Min(1)
  @Max(100)
  allocatedBandwidth: number;
}

export class UpdateTeamMemberAllocationDto {
  @ApiPropertyOptional({
    enum: ProjectRole,
    description: 'New role in the project',
    example: ProjectRole.QA,
  })
  @IsEnum(ProjectRole)
  @IsOptional()
  projectRole?: ProjectRole;

  @ApiPropertyOptional({
    description: 'New allocated bandwidth percentage (1-100)',
    example: 60,
    minimum: 1,
    maximum: 100,
  })
  @IsNumber()
  @Min(1)
  @Max(100)
  @IsOptional()
  allocatedBandwidth?: number;
}
