import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TaskComment } from '../../entities/task-comment.entity';
import { Task } from '../../entities/task.entity';
import { CommentController } from './comment.controller';
import { CommentService } from './comment.service';

@Module({
  imports: [TypeOrmModule.forFeature([TaskComment, Task])],
  controllers: [CommentController],
  providers: [CommentService],
  exports: [CommentService],
})
export class CommentModule {}
