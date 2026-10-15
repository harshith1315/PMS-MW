import {
  Controller,
  Get,
  Query,
  Res,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { Response } from 'express';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Permissions } from '../../common/decorators/permissions.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { PermissionsGuard } from '../../common/guards/permissions.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { TenantGuard } from '../../common/guards/tenant.guard';
import { UserContext } from '../auth/auth.service';
import { ReportQueryDto } from './dto/report.dto';
import { ReportService } from './report.service';

@ApiTags('Reports')
@Controller('reports')
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth('bearer')
export class ReportController {
  constructor(private readonly reportService: ReportService) {}

  private downloadXlsx(res: Response, fileName: string, buffer: Buffer): void {
    res.setHeader(
      'Content-Type',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
    res.send(buffer);
  }

  @Get('individual/download')
  @UseGuards(PermissionsGuard)
  @Permissions('VIEW_REPORTS')
  @ApiOperation({ summary: 'Download individual task report as XLSX' })
  async downloadIndividual(
    @CurrentUser() user: UserContext,
    @Query() query: ReportQueryDto,
    @Res() res: Response,
  ) {
    const file = await this.reportService.downloadIndividualReport(
      user.orgId,
      user.userId,
      user.role,
      query,
    );
    this.downloadXlsx(res, file.fileName, file.buffer);
  }

  @Get('overall/download')
  @UseGuards(PermissionsGuard)
  @Permissions('VIEW_REPORTS')
  @ApiOperation({ summary: 'Download overall task report as XLSX' })
  async downloadOverall(
    @CurrentUser() user: UserContext,
    @Query() query: ReportQueryDto,
    @Res() res: Response,
  ) {
    const file = await this.reportService.downloadOverallReport(
      user.orgId,
      user.userId,
      user.role,
      query,
    );
    this.downloadXlsx(res, file.fileName, file.buffer);
  }

  @Get('team/download')
  @UseGuards(PermissionsGuard)
  @Permissions('VIEW_REPORTS')
  @ApiOperation({ summary: 'Download team task report as XLSX' })
  async downloadTeam(
    @CurrentUser() user: UserContext,
    @Query() query: ReportQueryDto,
    @Res() res: Response,
  ) {
    const file = await this.reportService.downloadTeamReport(
      user.orgId,
      user.userId,
      user.role,
      query,
    );
    this.downloadXlsx(res, file.fileName, file.buffer);
  }

  @Get('sprint/download')
  @UseGuards(PermissionsGuard)
  @Permissions('VIEW_REPORTS')
  @ApiOperation({ summary: 'Download sprint report as XLSX' })
  async downloadSprint(
    @CurrentUser() user: UserContext,
    @Query() query: ReportQueryDto,
    @Res() res: Response,
  ) {
    const file = await this.reportService.downloadSprintReport(
      user.orgId,
      user.userId,
      user.role,
      query,
    );
    this.downloadXlsx(res, file.fileName, file.buffer);
  }

  @Get('timesheet/download')
  @UseGuards(PermissionsGuard)
  @Permissions('VIEW_TEAM_TIMESHEETS')
  @ApiOperation({ summary: 'Download team timesheet report as XLSX' })
  async downloadTimesheet(
    @CurrentUser() user: UserContext,
    @Query() query: ReportQueryDto,
    @Res() res: Response,
  ) {
    const file = await this.reportService.downloadTimesheetReport(
      user.orgId,
      user.userId,
      user.role,
      query,
    );
    this.downloadXlsx(res, file.fileName, file.buffer);
  }
}
