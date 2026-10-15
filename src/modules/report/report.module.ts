import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppUser } from '../../entities/app-user.entity';
import { Project } from '../../entities/project.entity';
import { Sprint } from '../../entities/sprint.entity';
import { Task } from '../../entities/task.entity';
import { TimeLog } from '../../entities/time-log.entity';
import { Timesheet } from '../../entities/timesheet.entity';
import { UserProjectMapping } from '../../entities/user-project-mapping.entity';
import { ReportController } from './report.controller';
import { ReportService } from './report.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      AppUser,
      Project,
      Sprint,
      Task,
      TimeLog,
      Timesheet,
      UserProjectMapping,
    ]),
  ],
  controllers: [ReportController],
  providers: [ReportService],
  exports: [ReportService],
})
export class ReportModule {}
