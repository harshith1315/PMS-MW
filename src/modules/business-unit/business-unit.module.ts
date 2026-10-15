import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { BusinessUnit } from "../../entities/business-unit.entity";
import { AppUser } from "../../entities/app-user.entity";
import { BusinessUnitController } from "./business-unit.controller";
import { BusinessUnitService } from "./business-unit.service";
import { PermissionsGuard } from "../../common/guards/permissions.guard";

@Module({
  imports: [TypeOrmModule.forFeature([BusinessUnit, AppUser])],
  controllers: [BusinessUnitController],
  providers: [BusinessUnitService, PermissionsGuard],
  exports: [BusinessUnitService],
})
export class BusinessUnitModule {}
