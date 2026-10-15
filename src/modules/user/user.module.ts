import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { AppUser } from "../../entities/app-user.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import { UserDailySummary } from "../../entities/user-daily-summary.entity";
import { Task } from "../../entities/task.entity";
import { TimeLog } from "../../entities/time-log.entity";
import { Role } from "../../entities/role.entity";
import { UserPermission } from "../../entities/user-permission.entity";
import { UserService } from "./user.service";
import { UserController } from "./user.controller";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { ActivityLogModule } from "../activity-log/activity-log.module";

@Module({
  imports: [
    TypeOrmModule.forFeature([
      AppUser,
      UserProjectMapping,
      UserDailySummary,
      Task,
      TimeLog,
      Role,
      UserPermission,
    ]),
    ActivityLogModule,
  ],
  controllers: [UserController],
  providers: [UserService, PermissionsGuard],
  exports: [UserService],
})
export class UserModule {}
