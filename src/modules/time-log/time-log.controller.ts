import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { TenantGuard } from '../../common/guards/tenant.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserContext } from '../auth/auth.service';
import { TimeLogService } from './time-log.service';
import {
  CreateTimeLogDto,
  UpdateTimeLogDto,
  TimeLogQueryDto,
  TimeLogResponseDto,
  DailySummaryResponseDto,
} from './dto/time-log.dto';

@ApiTags('Time Logs')
@Controller('time-logs')
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth('bearer')
export class TimeLogController {
  constructor(private readonly timeLogService: TimeLogService) {}

  @Post()
  @ApiOperation({ summary: 'Log time on a task' })
  @ApiResponse({
    status: 201,
    description: 'Time logged successfully',
    type: TimeLogResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input or validation error' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Not assigned to project' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async create(
    @CurrentUser() user: UserContext,
    @Body() createTimeLogDto: CreateTimeLogDto,
  ) {
    return this.timeLogService.create(user.orgId, user.userId, createTimeLogDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all time logs' })
  @ApiResponse({
    status: 200,
    description: 'List of time logs',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { $ref: '#/components/schemas/TimeLogResponseDto' } },
        total: { type: 'number' },
        page: { type: 'number' },
        limit: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(
    @CurrentUser() user: UserContext,
    @Query() query: TimeLogQueryDto,
  ) {
    return this.timeLogService.findAll(user.orgId, user.userId, user.role, query);
  }

  @Get('my-logs')
  @ApiOperation({ summary: 'Get my time logs for a date range' })
  @ApiQuery({ name: 'startDate', required: true, description: 'Start date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'endDate', required: true, description: 'End date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'projectId', required: false, description: 'Filter by project ID (UUID)' })
  @ApiResponse({
    status: 200,
    description: 'List of my time logs',
    type: [TimeLogResponseDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMyTimeLogs(
    @CurrentUser() user: UserContext,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Query('projectId') projectId?: string,
  ) {
    return this.timeLogService.getMyTimeLogs(
      user.orgId,
      user.userId,
      startDate,
      endDate,
      projectId,
    );
  }

  @Get('daily-summary')
  @ApiOperation({ summary: 'Get daily summary for calendar view' })
  @ApiQuery({ name: 'userId', required: false, description: 'User ID (admin only)' })
  @ApiQuery({ name: 'startDate', required: true, description: 'Start date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'endDate', required: true, description: 'End date (YYYY-MM-DD)' })
  @ApiResponse({
    status: 200,
    description: 'Daily summary with status colors',
    type: [DailySummaryResponseDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getDailySummary(
    @CurrentUser() user: UserContext,
    @Query('userId') userId: string,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    // Non-admin users can only view their own summary
    const targetUserId = user.role === 'ORG_ADMIN' && userId ? userId : user.userId;

    return this.timeLogService.getDailySummary(
      user.orgId,
      targetUserId,
      startDate,
      endDate,
    );
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get time log by ID' })
  @ApiParam({ name: 'id', description: 'Time log ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Time log details',
    type: TimeLogResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Time log not found' })
  async findOne(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.timeLogService.findOne(user.orgId, id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update time log' })
  @ApiParam({ name: 'id', description: 'Time log ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Time log updated successfully',
    type: TimeLogResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Can only update own time logs' })
  @ApiResponse({ status: 404, description: 'Time log not found' })
  async update(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateTimeLogDto: UpdateTimeLogDto,
  ) {
    return this.timeLogService.update(
      user.orgId,
      user.userId,
      id,
      updateTimeLogDto,
    );
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete time log' })
  @ApiParam({ name: 'id', description: 'Time log ID', format: 'uuid' })
  @ApiResponse({ status: 204, description: 'Time log deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Can only delete own time logs' })
  @ApiResponse({ status: 404, description: 'Time log not found' })
  async remove(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.timeLogService.remove(user.orgId, user.userId, id);
  }
}
