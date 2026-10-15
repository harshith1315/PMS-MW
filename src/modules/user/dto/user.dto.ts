import { ApiProperty, ApiPropertyOptional, PartialType } from "@nestjs/swagger";
import {
  IsString,
  IsEmail,
  IsIn,
  IsOptional,
  IsUrl,
  MaxLength,
  IsNotEmpty,
} from "class-validator";

export class InviteUserDto {
  @ApiProperty({
    description: "Email address of the user to invite",
    example: "john.doe@company.com",
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiPropertyOptional({
    description: "Role to assign to the invited user",
    enum: ["ADMIN", "MANAGER", "USER", "ORG_ADMIN", "DEVELOPER"],
    example: "USER",
  })
  @IsOptional()
  @IsString()
  role?: string;

  @ApiPropertyOptional({
    description: "Role ID to assign to the invited user",
    format: "uuid",
  })
  @IsOptional()
  @IsString()
  roleId?: string;
}

export class BulkInviteUserUploadDto {
  @ApiPropertyOptional({
    description: "Default role key to apply when a row does not include role",
    enum: ["ADMIN", "MANAGER", "USER", "ORG_ADMIN", "DEVELOPER"],
    example: "USER",
  })
  @IsOptional()
  @IsString()
  defaultRole?: string;

  @ApiPropertyOptional({
    description:
      "Default role ID to apply when a row does not include roleId or role",
    format: "uuid",
  })
  @IsOptional()
  @IsString()
  defaultRoleId?: string;
}

export class BulkInviteSkippedItemDto {
  @ApiProperty({ description: "Spreadsheet row number" })
  row: number;

  @ApiProperty({ description: "Email value from spreadsheet" })
  email: string;

  @ApiProperty({ description: "Skip reason" })
  reason: string;
}

export class BulkInviteFailedItemDto {
  @ApiProperty({ description: "Spreadsheet row number" })
  row: number;

  @ApiPropertyOptional({ description: "Email value if present" })
  email?: string;

  @ApiProperty({ description: "Validation or processing error" })
  error: string;
}

export class BulkInviteInvitedUserDto {
  @ApiProperty({ description: "User ID", format: "uuid" })
  id: string;

  @ApiProperty({ description: "Organization ID", format: "uuid" })
  orgId: string;

  @ApiProperty({ description: "User email" })
  email: string;

  @ApiPropertyOptional({ description: "Display name" })
  name?: string;

  @ApiProperty({ description: "Role" })
  role: string;

  @ApiProperty({ description: "Status" })
  status: string;

  @ApiProperty({ description: "Created timestamp" })
  createdAt: Date;

  @ApiProperty({ description: "Single-use password setup token; share via a trusted channel" })
  setupToken: string;
}

export class BulkInviteResultDto {
  @ApiProperty({ description: "Number of non-empty rows processed" })
  totalRows: number;

  @ApiProperty({ description: "Users successfully invited" })
  invitedCount: number;

  @ApiProperty({ description: "Rows skipped (e.g. duplicates/existing users)" })
  skippedCount: number;

  @ApiProperty({ description: "Rows that failed due to validation or errors" })
  failedCount: number;

  @ApiProperty({
    description: "Invited users",
    type: [BulkInviteInvitedUserDto],
  })
  invited: BulkInviteInvitedUserDto[];

  @ApiProperty({
    description: "Skipped rows",
    type: [BulkInviteSkippedItemDto],
  })
  skipped: BulkInviteSkippedItemDto[];

  @ApiProperty({
    description: "Failed rows",
    type: [BulkInviteFailedItemDto],
  })
  failed: BulkInviteFailedItemDto[];
}

export class UpdateUserDto {
  @ApiPropertyOptional({ description: "Display name", maxLength: 255 })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  name?: string;

  @ApiPropertyOptional({ description: "Phone number" })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  phone?: string;

  @ApiPropertyOptional({ description: "Profile picture URL" })
  @IsOptional()
  @IsUrl()
  profilePic?: string;
}

export class UpdateUserRoleDto {
  @ApiProperty({
    description: "User role key (optional when roleId is provided)",
    enum: ["ADMIN", "MANAGER", "USER", "ORG_ADMIN", "DEVELOPER"],
    example: "MANAGER",
    required: false,
  })
  @IsOptional()
  @IsString()
  role?: string;

  @ApiPropertyOptional({
    description: "Role ID",
    format: "uuid",
    example: "11111111-2222-3333-4444-555555555555",
  })
  @IsOptional()
  @IsString()
  roleId?: string;
}

export class UpdateUserStatusDto {
  @ApiProperty({
    description: "User status",
    enum: ["ACTIVE", "DEACTIVATED"],
    example: "DEACTIVATED",
  })
  @IsIn(["ACTIVE", "DEACTIVATED"])
  status: string;
}

export class UserQueryDto {
  @ApiPropertyOptional({ description: "Filter by status" })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ description: "Filter by role" })
  @IsOptional()
  @IsString()
  role?: string;

  @ApiPropertyOptional({ description: "Search by name or email" })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: "Page number", default: 1 })
  @IsOptional()
  page?: number;

  @ApiPropertyOptional({ description: "Page size", default: 20 })
  @IsOptional()
  limit?: number;
}

export class UserResponseDto {
  @ApiProperty({ description: "User ID", format: "uuid" })
  id: string;

  @ApiProperty({ description: "Organization ID", format: "uuid" })
  orgId: string;

  @ApiProperty({ description: "Microsoft Azure Object ID" })
  microsoftUserId: string;

  @ApiProperty({ description: "User email" })
  email: string;

  @ApiPropertyOptional({ description: "First name" })
  firstName?: string;

  @ApiPropertyOptional({ description: "Last name" })
  lastName?: string;

  @ApiPropertyOptional({ description: "Phone number" })
  phone?: string;

  @ApiPropertyOptional({ description: "Profile picture URL" })
  profilePic?: string;

  @ApiProperty({ description: "User role in organization" })
  role: string;

  @ApiProperty({ description: "User status" })
  status: string;

  @ApiProperty({ description: "Created timestamp" })
  createdAt: Date;

  @ApiProperty({ description: "Last updated timestamp" })
  updatedAt: Date;
}

export class UserDailySummaryResponseDto {
  @ApiProperty({ description: "Summary ID", format: "uuid" })
  id: string;

  @ApiProperty({ description: "User ID", format: "uuid" })
  userId: string;

  @ApiProperty({ description: "Summary date", format: "date" })
  summaryDate: string;

  @ApiProperty({ description: "Total minutes logged" })
  totalMinutes: number;

  @ApiProperty({
    description: "Color indicator",
    enum: ["RED", "YELLOW", "GREEN", "PURPLE"],
  })
  color: string;
}

export class UserStatsProjectDto {
  @ApiProperty({ format: "uuid" })
  projectId: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  projectCode: string;

  @ApiProperty()
  projectStatus: string;

  @ApiProperty({ description: "User role in this project" })
  projectRole?: string;

  @ApiPropertyOptional({
    format: "uuid",
    description: "Project manager user ID",
  })
  managerId?: string;
}

export class TaskStatusBreakdownDto {
  @ApiProperty() TODO: number;
  @ApiProperty() IN_PROGRESS: number;
  @ApiProperty() IN_REVIEW: number;
  @ApiProperty() QA: number;
  @ApiProperty() DONE: number;
  @ApiProperty() BLOCKED: number;
}

export class UserStatsDto {
  @ApiProperty({ description: "Total projects the user is assigned to" })
  totalProjectsAssigned: number;

  @ApiProperty({ description: "Active projects the user is assigned to" })
  activeProjectsCount: number;

  @ApiProperty({ description: "Total tasks assigned to the user" })
  totalTasksAssigned: number;

  @ApiProperty({ description: "Open tasks (not DONE)" })
  openTasks: number;

  @ApiProperty({ description: "Completed tasks (DONE)" })
  completedTasks: number;

  @ApiProperty({
    description: "Task completion rate as a percentage (0–100)",
    example: 66.67,
  })
  completionRate: number;

  @ApiProperty({ description: "Total minutes logged (all time)" })
  totalMinutesLogged: number;

  @ApiProperty({
    description: "Task count broken down by status",
    type: () => TaskStatusBreakdownDto,
  })
  tasksByStatus: TaskStatusBreakdownDto;

  @ApiProperty({
    description: "Active projects with role info",
    type: [UserStatsProjectDto],
  })
  activeProjects: UserStatsProjectDto[];
}

export class UserProjectMappingDetailDto {
  @ApiProperty({ description: "Mapping ID", format: "uuid" })
  id: string;

  @ApiProperty({ description: "User ID", format: "uuid" })
  userId: string;

  @ApiProperty({ description: "Project ID", format: "uuid" })
  projectId: string;

  @ApiProperty({ description: "Role in project" })
  projectRole: string;

  @ApiProperty({ description: "Mapping status" })
  status: string;

  @ApiPropertyOptional({ description: "Project details" })
  project?: {
    id: string;
    projectName: string;
    projectCode: string;
    status: string;
  };
}
