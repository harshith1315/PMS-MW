import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import {
  IsDateString,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
} from "class-validator";

export class CreateTimesheetDto {
  @ApiProperty({ description: "Timesheet date", example: "2026-03-26" })
  @IsDateString()
  date: string;

  @ApiProperty({
    description: "Project name",
    maxLength: 255,
    example: "LMS-SA",
  })
  @IsString()
  @MaxLength(255)
  projectName: string;

  @ApiProperty({
    description: "Task details",
    example: "R&D of AI implementation",
  })
  @IsString()
  taskDetails: string;

  @ApiProperty({ enum: ["IN_PROGRESS", "COMPLETED"], example: "IN_PROGRESS" })
  @IsIn(["IN_PROGRESS", "COMPLETED"])
  status: string;
}

export class TimesheetQueryDto {
  @ApiPropertyOptional({ description: "Start date (YYYY-MM-DD)" })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: "End date (YYYY-MM-DD)" })
  @IsOptional()
  @IsDateString()
  endDate?: string;
}

export class TimesheetResponseDto {
  @ApiProperty({ format: "uuid" })
  id: string;

  @ApiProperty({ example: "2026-03-26" })
  date: string;

  @ApiProperty({ example: "LMS-SA" })
  projectName: string;

  @ApiProperty({ example: "R&D of AI implementation" })
  taskDetails: string;

  @ApiProperty({ enum: ["IN_PROGRESS", "COMPLETED"] })
  status: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}
