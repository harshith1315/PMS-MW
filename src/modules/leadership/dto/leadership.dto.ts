import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import {
  IsString,
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
} from "class-validator";

export class CreateLeaderDto {
  @ApiProperty({ description: "Leader email", example: "pranathi@example.com" })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ description: "Leader name", example: "Pranathi" })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({
    description: "Also assign Manager role",
    default: true,
  })
  @IsOptional()
  @IsBoolean()
  isManager?: boolean;
}

export class UpdateLeaderDto {
  @ApiPropertyOptional({ description: "Leader name" })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ description: "Also assign Manager role" })
  @IsOptional()
  @IsBoolean()
  isManager?: boolean;
}

export class LeaderResponseDto {
  @ApiProperty({ description: "Leader user ID" })
  id: string;

  @ApiProperty({ description: "Leader email" })
  email: string;

  @ApiProperty({ description: "Leader name" })
  name: string;

  @ApiProperty({ description: "Is also a Manager" })
  isManager: boolean;

  @ApiProperty({ description: "Total projects assigned" })
  projectCount?: number;

  @ApiProperty({
    description: "Total active team members across managed projects",
  })
  teamSize?: number;

  @ApiProperty({ description: "User status" })
  status: string;

  @ApiProperty({ description: "Created date" })
  createdAt: Date;
}
