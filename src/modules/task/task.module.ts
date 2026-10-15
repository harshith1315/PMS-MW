import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Task } from "../../entities/task.entity";
import { Project } from "../../entities/project.entity";
import { ProjectTaskSequence } from "../../entities/project-task-sequence.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import { TimeLog } from "../../entities/time-log.entity";
import { TaskLink } from "../../entities/task-link.entity";
import { TaskComment } from "../../entities/task-comment.entity";
import { AppUser } from "../../entities/app-user.entity";
import { Tag } from "../../entities/tag.entity";
import { TaskController } from "./task.controller";
import { TaskService } from "./task.service";
import { PermissionsGuard } from "../../common/guards/permissions.guard";
import { NotificationModule } from "../notification/notification.module";
import { ChatModule } from "../chat/chat.module";
import { ActivityLogModule } from "../activity-log/activity-log.module";

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Task,
      Project,
      ProjectTaskSequence,
      UserProjectMapping,
      TimeLog,
      TaskLink,
      TaskComment,
      AppUser,
      Tag,
    ]),
    NotificationModule,
    ChatModule,
    ActivityLogModule,
  ],
  controllers: [TaskController],
  providers: [TaskService, PermissionsGuard],
  exports: [TaskService],
})
export class TaskModule {}
