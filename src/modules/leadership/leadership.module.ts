import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { AppUser } from "../../entities/app-user.entity";
import { Project } from "../../entities/project.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import { LeadershipService } from "./leadership.service";
import { LeadershipController } from "./leadership.controller";
import { PermissionsGuard } from "../../common/guards/permissions.guard";

@Module({
  imports: [TypeOrmModule.forFeature([AppUser, Project, UserProjectMapping])],
  providers: [LeadershipService, PermissionsGuard],
  controllers: [LeadershipController],
  exports: [LeadershipService],
})
export class LeadershipModule {}
