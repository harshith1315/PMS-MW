import { ApiProperty } from "@nestjs/swagger";
import {
  IsArray,
  IsBoolean,
  IsEmail,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MinLength,
  ValidateNested,
} from "class-validator";
import { Type } from "class-transformer";
import {
  ACCESS_CONTROL_PERMISSIONS,
  SYSTEM_ROLE_KEYS,
} from "../access-control.constants";

export class PermissionStateDto {
  @ApiProperty({ enum: ACCESS_CONTROL_PERMISSIONS })
  @IsString()
  @IsIn(ACCESS_CONTROL_PERMISSIONS)
  permissionKey: string;

  @ApiProperty({ type: Boolean })
  @IsBoolean()
  isGranted: boolean;
}

export class UpdatePermissionStatesDto {
  @ApiProperty({ type: [PermissionStateDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => PermissionStateDto)
  permissions: PermissionStateDto[];
}

export class RoleParamDto {
  @ApiProperty({ enum: SYSTEM_ROLE_KEYS })
  @IsString()
  @IsIn(SYSTEM_ROLE_KEYS)
  role: string;
}

export class CreateRoleDto {
  @ApiProperty({
    description: "Role key (unique)",
    example: "FINANCE_MANAGER",
  })
  @IsString()
  @MinLength(2)
  key: string;

  @ApiProperty({
    description: "Role display name",
    example: "Finance Manager",
  })
  @IsString()
  @MinLength(2)
  name: string;

  @ApiProperty({
    description: "Role description",
    required: false,
    example: "Can view and manage finance fields",
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ type: [PermissionStateDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => PermissionStateDto)
  permissions: PermissionStateDto[];
}

export class AssignRoleDto {
  @ApiProperty({ description: "Role ID", format: "uuid" })
  @IsUUID()
  roleId: string;
}

export class RoleListItemDto {
  @ApiProperty({ format: "uuid" })
  id: string;

  @ApiProperty()
  key: string;

  @ApiProperty()
  name: string;

  @ApiProperty({ nullable: true })
  description: string | null;

  @ApiProperty()
  isSystem: boolean;

  @ApiProperty()
  isActive: boolean;
}

export class AccessControlUserQueryDto {
  @ApiProperty({ required: false, description: "Search by name or email" })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiProperty({ required: false, description: "Filter by organization id (ADMIN only)" })
  @IsOptional()
  @IsUUID()
  orgId?: string;
}

export class AccessControlUserListItemDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  @IsEmail()
  email: string;

  @ApiProperty()
  role: string;

  @ApiProperty()
  orgId: string;

  @ApiProperty()
  status: string;
}

export class EffectivePermissionsResponseDto {
  @ApiProperty({ type: [String], enum: ACCESS_CONTROL_PERMISSIONS })
  permissions: string[];
}
