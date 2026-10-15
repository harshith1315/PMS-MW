import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { AppUser } from "../../entities/app-user.entity";
import { Role } from "../../entities/role.entity";
import { UserPermission } from "../../entities/user-permission.entity";
import { AccessControlController } from "./access-control.controller";
import { AccessControlService } from "./access-control.service";

@Module({
  imports: [TypeOrmModule.forFeature([AppUser, Role, UserPermission])],
  controllers: [AccessControlController],
  providers: [AccessControlService],
  exports: [AccessControlService],
})
export class AccessControlModule {}
