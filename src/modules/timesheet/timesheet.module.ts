import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Timesheet } from "../../entities/timesheet.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import { TimesheetController } from "./timesheet.controller";
import { TimesheetService } from "./timesheet.service";
import { PermissionsGuard } from "../../common/guards/permissions.guard";

@Module({
  imports: [TypeOrmModule.forFeature([Timesheet, UserProjectMapping])],
  controllers: [TimesheetController],
  providers: [TimesheetService, PermissionsGuard],
  exports: [TimesheetService],
})
export class TimesheetModule {}
