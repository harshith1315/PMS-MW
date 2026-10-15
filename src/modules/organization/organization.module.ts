import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Organization } from '../../entities/organization.entity';
import { PlatformUser } from '../../entities/platform-user.entity';
import { AppUser } from '../../entities/app-user.entity';
import { OrganizationController } from './organization.controller';
import { OrganizationService } from './organization.service';

@Module({
  imports: [TypeOrmModule.forFeature([Organization, PlatformUser, AppUser])],
  controllers: [OrganizationController],
  providers: [OrganizationService],
  exports: [OrganizationService],
})
export class OrganizationModule {}
