import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TaskLink } from '../../entities/task-link.entity';
import { Task } from '../../entities/task.entity';
import { TaskLinkController } from './task-link.controller';
import { TaskLinkService } from './task-link.service';

@Module({
  imports: [TypeOrmModule.forFeature([TaskLink, Task])],
  controllers: [TaskLinkController],
  providers: [TaskLinkService],
  exports: [TaskLinkService],
})
export class TaskLinkModule {}
