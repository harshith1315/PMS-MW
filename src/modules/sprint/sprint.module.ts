import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Sprint } from "../../entities/sprint.entity";
import { Project } from "../../entities/project.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import { SprintController } from "./sprint.controller";
import { SprintService } from "./sprint.service";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { ActivityLogModule } from "../activity-log/activity-log.module";

@Module({
  imports: [TypeOrmModule.forFeature([Sprint, Project, UserProjectMapping]), ActivityLogModule],
  controllers: [SprintController],
  providers: [SprintService, PermissionsGuard],
  exports: [SprintService],
})
export class SprintModule {}
