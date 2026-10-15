import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Project } from "../../entities/project.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import { ProjectTaskSequence } from "../../entities/project-task-sequence.entity";
import { ProjectLink } from "../../entities/project-link.entity";
import { AppUser } from "../../entities/app-user.entity";
import { Sprint } from "../../entities/sprint.entity";
import { ProjectController } from "./project.controller";
import { ProjectService } from "./project.service";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { ActivityLogModule } from "../activity-log/activity-log.module";

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Project,
      UserProjectMapping,
      ProjectTaskSequence,
      ProjectLink,
      AppUser,
      Sprint,
    ]),
    ActivityLogModule,
  ],
  controllers: [ProjectController],
  providers: [ProjectService, PermissionsGuard],
  exports: [ProjectService],
})
export class ProjectModule {}
