import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TimeLog } from '../../entities/time-log.entity';
import { UserDailySummary } from '../../entities/user-daily-summary.entity';
import { Task } from '../../entities/task.entity';
import { UserProjectMapping } from '../../entities/user-project-mapping.entity';
import { TimeLogController } from './time-log.controller';
import { TimeLogService } from './time-log.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      TimeLog,
      UserDailySummary,
      Task,
      UserProjectMapping,
    ]),
  ],
  controllers: [TimeLogController],
  providers: [TimeLogService],
  exports: [TimeLogService],
})
export class TimeLogModule {}
