import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, ObjectLiteral, Repository, SelectQueryBuilder } from 'typeorm';
import * as ExcelJS from 'exceljs';
import { AppUser } from '../../entities/app-user.entity';
import { Project } from '../../entities/project.entity';
import { Sprint } from '../../entities/sprint.entity';
import { Task } from '../../entities/task.entity';
import { TimeLog } from '../../entities/time-log.entity';
import { Timesheet } from '../../entities/timesheet.entity';
import { UserProjectMapping } from '../../entities/user-project-mapping.entity';
import { ReportQueryDto } from './dto/report.dto';

interface ReportFile {
  fileName: string;
  buffer: Buffer;
}

interface SheetSpec {
  name: string;
  columns: Array<{ header: string; key: string; width?: number }>;
  rows: Array<Record<string, unknown>>;
}

@Injectable()
export class ReportService {
  private readonly privilegedOrgRoles = new Set(['ADMIN', 'ORG_ADMIN']);

  constructor(
    @InjectRepository(Project)
    private readonly projectRepository: Repository<Project>,
    @InjectRepository(UserProjectMapping)
    private readonly mappingRepository: Repository<UserProjectMapping>,
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
    @InjectRepository(TimeLog)
    private readonly timeLogRepository: Repository<TimeLog>,
    @InjectRepository(AppUser)
    private readonly appUserRepository: Repository<AppUser>,
    @InjectRepository(Sprint)
    private readonly sprintRepository: Repository<Sprint>,
    @InjectRepository(Timesheet)
    private readonly timesheetRepository: Repository<Timesheet>,
  ) {}

  private formatDateToken(date: Date = new Date()): string {
    return date.toISOString().slice(0, 10);
  }

  private async buildWorkbook(sheets: SheetSpec[]): Promise<Buffer> {
    const workbook = new ExcelJS.Workbook();

    for (const spec of sheets) {
      const worksheet = workbook.addWorksheet(spec.name);
      worksheet.columns = spec.columns;
      worksheet.addRows(spec.rows);
      worksheet.getRow(1).font = { bold: true };
      worksheet.views = [{ state: 'frozen', ySplit: 1 }];
    }

    const arrayBuffer = await workbook.xlsx.writeBuffer();
    return Buffer.from(arrayBuffer);
  }

  private applyDateRange(
    queryBuilder: SelectQueryBuilder<ObjectLiteral>,
    columnName: string,
    startDate?: string,
    endDate?: string,
  ): void {
    if (startDate) {
      queryBuilder.andWhere(`${columnName} >= :startDate`, { startDate });
    }
    if (endDate) {
      queryBuilder.andWhere(`${columnName} <= :endDate`, { endDate });
    }
  }

  private async resolveScopedProjectIds(
    orgId: string,
    userId: string,
    userRole: string,
    projectId?: string,
  ): Promise<string[] | null> {
    if (this.privilegedOrgRoles.has(userRole)) {
      if (!projectId) {
        return null;
      }

      const project = await this.projectRepository.findOne({
        where: { id: projectId, orgId },
        select: ['id'],
      });

      if (!project) {
        throw new NotFoundException('Project not found');
      }

      return [project.id];
    }

    if (userRole !== 'MANAGER') {
      if (!projectId) {
        return null;
      }

      const project = await this.projectRepository.findOne({
        where: { id: projectId, orgId },
        select: ['id'],
      });

      if (!project) {
        throw new NotFoundException('Project not found');
      }

      return [project.id];
    }

    const managedProjects = await this.projectRepository.find({
      where: { orgId, managerId: userId },
      select: ['id'],
    });

    const mappedProjects = await this.mappingRepository.find({
      where: {
        orgId,
        userId,
        status: 'ACTIVE',
        approvalStatus: 'APPROVED',
      },
      select: ['projectId'],
    });

    const scoped = [
      ...new Set([
        ...managedProjects.map((project) => project.id),
        ...mappedProjects.map((mapping) => mapping.projectId),
      ]),
    ];

    if (!projectId) {
      return scoped;
    }

    if (!scoped.includes(projectId)) {
      throw new ForbiddenException('Managers can only access reports for their own projects');
    }

    return [projectId];
  }

  private async resolveScopedProjectIdsForTimesheetReport(
    orgId: string,
    projectId?: string,
  ): Promise<string[] | null> {
    if (!projectId) {
      return null;
    }

    const project = await this.projectRepository.findOne({
      where: { id: projectId, orgId },
      select: ['id'],
    });

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    return [project.id];
  }

  private async getScopedMemberIds(
    orgId: string,
    projectIds: string[] | null,
  ): Promise<string[]> {
    const where = projectIds
      ? {
          orgId,
          projectId: In(projectIds),
          status: 'ACTIVE',
          approvalStatus: 'APPROVED',
        }
      : {
          orgId,
          status: 'ACTIVE',
          approvalStatus: 'APPROVED',
        };

    const members = await this.mappingRepository.find({
      where,
      select: ['userId'],
    });

    return [...new Set(members.map((member) => member.userId))];
  }

  async downloadIndividualReport(
    orgId: string,
    userId: string,
    userRole: string,
    query: ReportQueryDto,
  ): Promise<ReportFile> {
    const scopedProjectIds = await this.resolveScopedProjectIds(
      orgId,
      userId,
      userRole,
      query.projectId,
    );

    if (scopedProjectIds && scopedProjectIds.length === 0) {
      throw new NotFoundException('No accessible projects for this report');
    }

    const targetUserId = query.userId || userId;
    const targetUser = await this.appUserRepository.findOne({
      where: { id: targetUserId, orgId },
      select: ['id', 'name', 'email'],
    });

    if (!targetUser) {
      throw new NotFoundException('Target user not found');
    }

    const detailQuery = this.timeLogRepository
      .createQueryBuilder('timelog')
      .innerJoin('task', 'task', 'task.id = timelog.task_id')
      .innerJoin('project', 'project', 'project.id = timelog.project_id')
      .leftJoin('sprint', 'sprint', 'sprint.id = task.sprint_id')
      .where('timelog.org_id = :orgId', { orgId })
      .andWhere('timelog.user_id = :targetUserId', { targetUserId });

    if (scopedProjectIds) {
      detailQuery.andWhere('timelog.project_id IN (:...projectIds)', {
        projectIds: scopedProjectIds,
      });
    }

    if (query.sprintId) {
      detailQuery.andWhere('task.sprint_id = :sprintId', {
        sprintId: query.sprintId,
      });
    }

    this.applyDateRange(
      detailQuery,
      'timelog.log_date',
      query.startDate,
      query.endDate,
    );

    const rows = await detailQuery
      .select('task.task_code', 'taskCode')
      .addSelect('task.title', 'title')
      .addSelect('task.status', 'status')
      .addSelect('task.priority', 'priority')
      .addSelect('project.project_code', 'projectCode')
      .addSelect('project.name', 'projectName')
      .addSelect('COALESCE(sprint.name, \'Backlog\')', 'sprintName')
      .addSelect('SUM(timelog.minutes)', 'totalMinutes')
      .addSelect('COUNT(DISTINCT timelog.log_date)', 'activeDays')
      .addSelect('MAX(timelog.log_date)', 'lastLogDate')
      .groupBy('task.id')
      .addGroupBy('task.task_code')
      .addGroupBy('task.title')
      .addGroupBy('task.status')
      .addGroupBy('task.priority')
      .addGroupBy('project.project_code')
      .addGroupBy('project.name')
      .addGroupBy('sprint.name')
      .orderBy('MAX(timelog.log_date)', 'DESC')
      .getRawMany();

    const totalMinutes = rows.reduce(
      (sum, row) => sum + Number(row.totalMinutes || 0),
      0,
    );
    const completedTasks = rows.filter((row) => row.status === 'DONE').length;
    const completionRate = rows.length
      ? Number(((completedTasks / rows.length) * 100).toFixed(2))
      : 0;

    const summarySheet: SheetSpec = {
      name: 'Summary',
      columns: [
        { header: 'Metric', key: 'metric', width: 32 },
        { header: 'Value', key: 'value', width: 32 },
      ],
      rows: [
        { metric: 'User', value: targetUser.name || targetUser.email },
        { metric: 'Email', value: targetUser.email },
        { metric: 'Total Tasks Logged', value: rows.length },
        { metric: 'Completed Tasks', value: completedTasks },
        { metric: 'Completion Rate (%)', value: completionRate },
        { metric: 'Total Logged Minutes', value: totalMinutes },
        { metric: 'Total Logged Hours', value: Number((totalMinutes / 60).toFixed(2)) },
      ],
    };

    const detailsSheet: SheetSpec = {
      name: 'Task Details',
      columns: [
        { header: 'Task Code', key: 'taskCode', width: 16 },
        { header: 'Title', key: 'title', width: 36 },
        { header: 'Status', key: 'status', width: 16 },
        { header: 'Priority', key: 'priority', width: 14 },
        { header: 'Project', key: 'project', width: 26 },
        { header: 'Sprint', key: 'sprint', width: 24 },
        { header: 'Minutes', key: 'minutes', width: 12 },
        { header: 'Hours', key: 'hours', width: 10 },
        { header: 'Active Days', key: 'activeDays', width: 12 },
        { header: 'Last Log Date', key: 'lastLogDate', width: 16 },
      ],
      rows: rows.map((row) => ({
        taskCode: row.taskCode,
        title: row.title,
        status: row.status,
        priority: row.priority,
        project: `${row.projectCode} - ${row.projectName}`,
        sprint: row.sprintName,
        minutes: Number(row.totalMinutes || 0),
        hours: Number((Number(row.totalMinutes || 0) / 60).toFixed(2)),
        activeDays: Number(row.activeDays || 0),
        lastLogDate: row.lastLogDate,
      })),
    };

    return {
      fileName: `individual-task-report-${this.formatDateToken()}.xlsx`,
      buffer: await this.buildWorkbook([summarySheet, detailsSheet]),
    };
  }

  async downloadOverallReport(
    orgId: string,
    userId: string,
    userRole: string,
    query: ReportQueryDto,
  ): Promise<ReportFile> {
    const scopedProjectIds = await this.resolveScopedProjectIds(
      orgId,
      userId,
      userRole,
      query.projectId,
    );

    if (scopedProjectIds && scopedProjectIds.length === 0) {
      throw new NotFoundException('No accessible projects for this report');
    }

    const statusQuery = this.taskRepository
      .createQueryBuilder('task')
      .innerJoin('project', 'project', 'project.id = task.project_id')
      .where('task.org_id = :orgId', { orgId });

    if (scopedProjectIds) {
      statusQuery.andWhere('task.project_id IN (:...projectIds)', {
        projectIds: scopedProjectIds,
      });
    }

    if (query.sprintId) {
      statusQuery.andWhere('task.sprint_id = :sprintId', { sprintId: query.sprintId });
    }

    this.applyDateRange(
      statusQuery,
      'task.created_at',
      query.startDate,
      query.endDate,
    );

    const statusRows = await statusQuery
      .select('task.status', 'status')
      .addSelect('COUNT(*)', 'count')
      .groupBy('task.status')
      .orderBy('task.status', 'ASC')
      .getRawMany();

    const totalTasks = statusRows.reduce(
      (sum, row) => sum + Number(row.count || 0),
      0,
    );
    const completedTasks = statusRows
      .filter((row) => row.status === 'DONE')
      .reduce((sum, row) => sum + Number(row.count || 0), 0);
    const completionRate = totalTasks
      ? Number(((completedTasks / totalTasks) * 100).toFixed(2))
      : 0;

    const effortQuery = this.timeLogRepository
      .createQueryBuilder('timelog')
      .innerJoin('task', 'task', 'task.id = timelog.task_id')
      .where('timelog.org_id = :orgId', { orgId });

    if (scopedProjectIds) {
      effortQuery.andWhere('timelog.project_id IN (:...projectIds)', {
        projectIds: scopedProjectIds,
      });
    }

    if (query.sprintId) {
      effortQuery.andWhere('task.sprint_id = :sprintId', { sprintId: query.sprintId });
    }

    this.applyDateRange(
      effortQuery,
      'timelog.log_date',
      query.startDate,
      query.endDate,
    );

    const effort = await effortQuery.select('SUM(timelog.minutes)', 'minutes').getRawOne();
    const totalMinutes = Number(effort?.minutes || 0);

    const projectBreakdownQuery = this.taskRepository
      .createQueryBuilder('task')
      .innerJoin('project', 'project', 'project.id = task.project_id')
      .where('task.org_id = :orgId', { orgId });

    if (scopedProjectIds) {
      projectBreakdownQuery.andWhere('task.project_id IN (:...projectIds)', {
        projectIds: scopedProjectIds,
      });
    }

    if (query.sprintId) {
      projectBreakdownQuery.andWhere('task.sprint_id = :sprintId', {
        sprintId: query.sprintId,
      });
    }

    this.applyDateRange(
      projectBreakdownQuery,
      'task.created_at',
      query.startDate,
      query.endDate,
    );

    const projectRows = await projectBreakdownQuery
      .select('project.project_code', 'projectCode')
      .addSelect('project.name', 'projectName')
      .addSelect('COUNT(*)', 'taskCount')
      .addSelect("SUM(CASE WHEN task.status = 'DONE' THEN 1 ELSE 0 END)", 'doneCount')
      .groupBy('project.id')
      .addGroupBy('project.project_code')
      .addGroupBy('project.name')
      .orderBy('COUNT(*)', 'DESC')
      .getRawMany();

    const summarySheet: SheetSpec = {
      name: 'Summary',
      columns: [
        { header: 'Metric', key: 'metric', width: 32 },
        { header: 'Value', key: 'value', width: 32 },
      ],
      rows: [
        { metric: 'Total Tasks', value: totalTasks },
        { metric: 'Completed Tasks', value: completedTasks },
        { metric: 'Completion Rate (%)', value: completionRate },
        { metric: 'Total Logged Minutes', value: totalMinutes },
        { metric: 'Total Logged Hours', value: Number((totalMinutes / 60).toFixed(2)) },
      ],
    };

    const statusSheet: SheetSpec = {
      name: 'Status Breakdown',
      columns: [
        { header: 'Status', key: 'status', width: 20 },
        { header: 'Task Count', key: 'count', width: 16 },
      ],
      rows: statusRows.map((row) => ({
        status: row.status || 'UNSPECIFIED',
        count: Number(row.count || 0),
      })),
    };

    const projectSheet: SheetSpec = {
      name: 'Project Breakdown',
      columns: [
        { header: 'Project Code', key: 'projectCode', width: 18 },
        { header: 'Project Name', key: 'projectName', width: 28 },
        { header: 'Total Tasks', key: 'taskCount', width: 14 },
        { header: 'Done Tasks', key: 'doneCount', width: 14 },
      ],
      rows: projectRows.map((row) => ({
        projectCode: row.projectCode,
        projectName: row.projectName,
        taskCount: Number(row.taskCount || 0),
        doneCount: Number(row.doneCount || 0),
      })),
    };

    return {
      fileName: `overall-task-report-${this.formatDateToken()}.xlsx`,
      buffer: await this.buildWorkbook([summarySheet, statusSheet, projectSheet]),
    };
  }

  async downloadTeamReport(
    orgId: string,
    userId: string,
    userRole: string,
    query: ReportQueryDto,
  ): Promise<ReportFile> {
    const scopedProjectIds = await this.resolveScopedProjectIds(
      orgId,
      userId,
      userRole,
      query.projectId,
    );

    if (scopedProjectIds && scopedProjectIds.length === 0) {
      throw new NotFoundException('No accessible projects for this report');
    }

    const memberIds = await this.getScopedMemberIds(orgId, scopedProjectIds);
    if (memberIds.length === 0) {
      throw new NotFoundException('No team members found for this scope');
    }

    const members = await this.appUserRepository.find({
      where: { id: In(memberIds), orgId },
      select: ['id', 'name', 'email'],
      order: { name: 'ASC' },
    });

    const taskQuery = this.taskRepository
      .createQueryBuilder('task')
      .where('task.org_id = :orgId', { orgId })
      .andWhere('task.assigned_to IN (:...memberIds)', { memberIds });

    if (scopedProjectIds) {
      taskQuery.andWhere('task.project_id IN (:...projectIds)', {
        projectIds: scopedProjectIds,
      });
    }

    if (query.sprintId) {
      taskQuery.andWhere('task.sprint_id = :sprintId', { sprintId: query.sprintId });
    }

    this.applyDateRange(
      taskQuery,
      'task.created_at',
      query.startDate,
      query.endDate,
    );

    const taskRows = await taskQuery
      .select('task.assigned_to', 'userId')
      .addSelect('COUNT(*)', 'taskCount')
      .addSelect("SUM(CASE WHEN task.status = 'DONE' THEN 1 ELSE 0 END)", 'doneCount')
      .groupBy('task.assigned_to')
      .getRawMany();

    const timeQuery = this.timeLogRepository
      .createQueryBuilder('timelog')
      .innerJoin('task', 'task', 'task.id = timelog.task_id')
      .where('timelog.org_id = :orgId', { orgId })
      .andWhere('timelog.user_id IN (:...memberIds)', { memberIds });

    if (scopedProjectIds) {
      timeQuery.andWhere('timelog.project_id IN (:...projectIds)', {
        projectIds: scopedProjectIds,
      });
    }

    if (query.sprintId) {
      timeQuery.andWhere('task.sprint_id = :sprintId', { sprintId: query.sprintId });
    }

    this.applyDateRange(
      timeQuery,
      'timelog.log_date',
      query.startDate,
      query.endDate,
    );

    const timeRows = await timeQuery
      .select('timelog.user_id', 'userId')
      .addSelect('SUM(timelog.minutes)', 'minutes')
      .groupBy('timelog.user_id')
      .getRawMany();

    const taskMap = new Map(taskRows.map((row) => [row.userId, row]));
    const timeMap = new Map(timeRows.map((row) => [row.userId, row]));

    const rows = members.map((member) => {
      const taskStats = taskMap.get(member.id);
      const timeStats = timeMap.get(member.id);
      const totalTasks = Number(taskStats?.taskCount || 0);
      const doneTasks = Number(taskStats?.doneCount || 0);
      const completionRate = totalTasks
        ? Number(((doneTasks / totalTasks) * 100).toFixed(2))
        : 0;
      const totalMinutes = Number(timeStats?.minutes || 0);

      return {
        userName: member.name || member.email,
        email: member.email,
        assignedTasks: totalTasks,
        completedTasks: doneTasks,
        completionRate,
        totalMinutes,
        totalHours: Number((totalMinutes / 60).toFixed(2)),
      };
    });

    const summarySheet: SheetSpec = {
      name: 'Team Summary',
      columns: [
        { header: 'Team Members', key: 'members', width: 16 },
        { header: 'Total Assigned Tasks', key: 'tasks', width: 20 },
        { header: 'Total Completed Tasks', key: 'done', width: 22 },
        { header: 'Total Logged Hours', key: 'hours', width: 18 },
      ],
      rows: [
        {
          members: rows.length,
          tasks: rows.reduce((sum, row) => sum + Number(row.assignedTasks), 0),
          done: rows.reduce((sum, row) => sum + Number(row.completedTasks), 0),
          hours: Number(
            (
              rows.reduce((sum, row) => sum + Number(row.totalMinutes), 0) / 60
            ).toFixed(2),
          ),
        },
      ],
    };

    const detailSheet: SheetSpec = {
      name: 'Member Breakdown',
      columns: [
        { header: 'Member', key: 'userName', width: 26 },
        { header: 'Email', key: 'email', width: 32 },
        { header: 'Assigned Tasks', key: 'assignedTasks', width: 16 },
        { header: 'Completed Tasks', key: 'completedTasks', width: 16 },
        { header: 'Completion %', key: 'completionRate', width: 14 },
        { header: 'Logged Minutes', key: 'totalMinutes', width: 14 },
        { header: 'Logged Hours', key: 'totalHours', width: 12 },
      ],
      rows,
    };

    return {
      fileName: `team-task-report-${this.formatDateToken()}.xlsx`,
      buffer: await this.buildWorkbook([summarySheet, detailSheet]),
    };
  }

  async downloadSprintReport(
    orgId: string,
    userId: string,
    userRole: string,
    query: ReportQueryDto,
  ): Promise<ReportFile> {
    const scopedProjectIds = await this.resolveScopedProjectIds(
      orgId,
      userId,
      userRole,
      query.projectId,
    );

    if (scopedProjectIds && scopedProjectIds.length === 0) {
      throw new NotFoundException('No accessible projects for this report');
    }

    const sprintQuery = this.sprintRepository
      .createQueryBuilder('sprint')
      .innerJoin('project', 'project', 'project.id = sprint.project_id')
      .where('project.org_id = :orgId', { orgId });

    if (scopedProjectIds) {
      sprintQuery.andWhere('sprint.project_id IN (:...projectIds)', {
        projectIds: scopedProjectIds,
      });
    }

    if (query.sprintId) {
      sprintQuery.andWhere('sprint.id = :sprintId', { sprintId: query.sprintId });
    }

    const sprints = await sprintQuery
      .select('sprint.id', 'id')
      .addSelect('sprint.name', 'name')
      .addSelect('sprint.status', 'status')
      .addSelect('sprint.start_date', 'startDate')
      .addSelect('sprint.end_date', 'endDate')
      .addSelect('project.project_code', 'projectCode')
      .addSelect('project.name', 'projectName')
      .orderBy('sprint.start_date', 'DESC')
      .getRawMany();

    if (sprints.length === 0) {
      throw new NotFoundException('No sprints found for this scope');
    }

    const sprintIds = sprints.map((sprint) => sprint.id);

    const taskQuery = this.taskRepository
      .createQueryBuilder('task')
      .where('task.org_id = :orgId', { orgId })
      .andWhere('task.sprint_id IN (:...sprintIds)', { sprintIds });

    this.applyDateRange(
      taskQuery,
      'task.created_at',
      query.startDate,
      query.endDate,
    );

    const taskRows = await taskQuery
      .select('task.sprint_id', 'sprintId')
      .addSelect('COUNT(*)', 'taskCount')
      .addSelect("SUM(CASE WHEN task.status = 'DONE' THEN 1 ELSE 0 END)", 'doneCount')
      .groupBy('task.sprint_id')
      .getRawMany();

    const effortQuery = this.timeLogRepository
      .createQueryBuilder('timelog')
      .innerJoin('task', 'task', 'task.id = timelog.task_id')
      .where('timelog.org_id = :orgId', { orgId })
      .andWhere('task.sprint_id IN (:...sprintIds)', { sprintIds });

    this.applyDateRange(
      effortQuery,
      'timelog.log_date',
      query.startDate,
      query.endDate,
    );

    const effortRows = await effortQuery
      .select('task.sprint_id', 'sprintId')
      .addSelect('SUM(timelog.minutes)', 'minutes')
      .groupBy('task.sprint_id')
      .getRawMany();

    const taskMap = new Map(taskRows.map((row) => [row.sprintId, row]));
    const effortMap = new Map(effortRows.map((row) => [row.sprintId, row]));

    const rows = sprints.map((sprint) => {
      const taskStats = taskMap.get(sprint.id);
      const effortStats = effortMap.get(sprint.id);
      const totalTasks = Number(taskStats?.taskCount || 0);
      const doneTasks = Number(taskStats?.doneCount || 0);
      const completionRate = totalTasks
        ? Number(((doneTasks / totalTasks) * 100).toFixed(2))
        : 0;
      const totalMinutes = Number(effortStats?.minutes || 0);

      return {
        sprintName: sprint.name,
        sprintStatus: sprint.status,
        project: `${sprint.projectCode} - ${sprint.projectName}`,
        startDate: sprint.startDate,
        endDate: sprint.endDate,
        totalTasks,
        doneTasks,
        completionRate,
        totalMinutes,
        totalHours: Number((totalMinutes / 60).toFixed(2)),
      };
    });

    const summarySheet: SheetSpec = {
      name: 'Sprint Summary',
      columns: [
        { header: 'Metric', key: 'metric', width: 32 },
        { header: 'Value', key: 'value', width: 24 },
      ],
      rows: [
        { metric: 'Sprints Covered', value: rows.length },
        {
          metric: 'Total Tasks',
          value: rows.reduce((sum, row) => sum + Number(row.totalTasks), 0),
        },
        {
          metric: 'Total Completed Tasks',
          value: rows.reduce((sum, row) => sum + Number(row.doneTasks), 0),
        },
        {
          metric: 'Total Logged Hours',
          value: Number(
            (
              rows.reduce((sum, row) => sum + Number(row.totalMinutes), 0) / 60
            ).toFixed(2),
          ),
        },
      ],
    };

    const detailSheet: SheetSpec = {
      name: 'Sprint Breakdown',
      columns: [
        { header: 'Sprint', key: 'sprintName', width: 26 },
        { header: 'Status', key: 'sprintStatus', width: 14 },
        { header: 'Project', key: 'project', width: 30 },
        { header: 'Start Date', key: 'startDate', width: 14 },
        { header: 'End Date', key: 'endDate', width: 14 },
        { header: 'Total Tasks', key: 'totalTasks', width: 14 },
        { header: 'Done Tasks', key: 'doneTasks', width: 14 },
        { header: 'Completion %', key: 'completionRate', width: 14 },
        { header: 'Logged Minutes', key: 'totalMinutes', width: 14 },
        { header: 'Logged Hours', key: 'totalHours', width: 12 },
      ],
      rows,
    };

    return {
      fileName: `sprint-report-${this.formatDateToken()}.xlsx`,
      buffer: await this.buildWorkbook([summarySheet, detailSheet]),
    };
  }

  async downloadTimesheetReport(
    orgId: string,
    userId: string,
    userRole: string,
    query: ReportQueryDto,
  ): Promise<ReportFile> {
    const scopedProjectIds = await this.resolveScopedProjectIdsForTimesheetReport(
      orgId,
      query.projectId,
    );

    if (scopedProjectIds && scopedProjectIds.length === 0) {
      throw new NotFoundException('No accessible projects for this report');
    }

    const memberIds = await this.getScopedMemberIds(orgId, scopedProjectIds);
    if (memberIds.length === 0) {
      throw new NotFoundException('No team members found for this scope');
    }

    const queryBuilder = this.timesheetRepository
      .createQueryBuilder('timesheet')
      .leftJoin('app_user', 'user', 'user.id = timesheet.user_id')
      .where('timesheet.org_id = :orgId', { orgId })
      .andWhere('timesheet.user_id IN (:...memberIds)', { memberIds });

    this.applyDateRange(
      queryBuilder,
      'timesheet.entry_date',
      query.startDate,
      query.endDate,
    );

    if (query.projectId) {
      const filteredProject = await this.projectRepository.findOne({
        where: { id: query.projectId, orgId },
        select: ['name'],
      });

      if (!filteredProject) {
        throw new NotFoundException('Project not found');
      }

      queryBuilder.andWhere('timesheet.project_name = :projectName', {
        projectName: filteredProject.name,
      });
    }

    const rows = await queryBuilder
      .select('timesheet.entry_date', 'entryDate')
      .addSelect('timesheet.project_name', 'projectName')
      .addSelect('timesheet.task_details', 'taskDetails')
      .addSelect('timesheet.status', 'status')
      .addSelect('user.name', 'userName')
      .addSelect('user.email', 'userEmail')
      .orderBy('timesheet.entry_date', 'DESC')
      .addOrderBy('timesheet.created_at', 'DESC')
      .getRawMany();

    const summarySheet: SheetSpec = {
      name: 'Summary',
      columns: [
        { header: 'Metric', key: 'metric', width: 32 },
        { header: 'Value', key: 'value', width: 32 },
      ],
      rows: [
        { metric: 'Total Entries', value: rows.length },
        {
          metric: 'Employees Covered',
          value: new Set(rows.map((row) => row.userEmail).filter(Boolean)).size,
        },
        {
          metric: 'Completed Entries',
          value: rows.filter((row) => row.status === 'COMPLETED').length,
        },
      ],
    };

    const detailSheet: SheetSpec = {
      name: 'Entries',
      columns: [
        { header: 'Date', key: 'entryDate', width: 14 },
        { header: 'Employee', key: 'userName', width: 24 },
        { header: 'Email', key: 'userEmail', width: 32 },
        { header: 'Project', key: 'projectName', width: 24 },
        { header: 'Task Details', key: 'taskDetails', width: 52 },
        { header: 'Status', key: 'status', width: 14 },
      ],
      rows,
    };

    return {
      fileName: `timesheet-report-${this.formatDateToken()}.xlsx`,
      buffer: await this.buildWorkbook([summarySheet, detailSheet]),
    };
  }
}
