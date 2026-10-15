import {
  Injectable,
  Logger,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { Organization } from '../../entities/organization.entity';
import { AppUser } from '../../entities/app-user.entity';
import { deriveDisplayNameFromEmail } from '../../common/services/email-name.service';
import { createPasswordSetupToken } from '../../common/utils/auth-tokens';
import {
  CreateOrganizationDto,
  UpdateOrganizationDto,
  PlatformStatsDto,
  AdminDashboardDto,
  DashboardOrgTileDto,
  DashboardSummaryDto,
} from './dto/organization.dto';

/**
 * Organization Service - Managed by platform admins (ADMIN role)
 */
@Injectable()
export class OrganizationService {
  private readonly logger = new Logger(OrganizationService.name);

  constructor(
    @InjectRepository(Organization)
    private readonly organizationRepository: Repository<Organization>,
    @InjectRepository(AppUser)
    private readonly appUserRepository: Repository<AppUser>,
    private readonly dataSource: DataSource,
  ) {}

  /**
   * Create a new organization and pre-create its ORG_ADMIN (ADMIN only).
   * Both records are written in a single transaction — if either fails,
   * neither is persisted.
   */
  async create(
    dto: CreateOrganizationDto,
  ): Promise<Organization & { orgAdmin: AppUser; setupToken: string }> {
    const normalizedEmail = dto.orgAdminEmail.toLowerCase().trim();

    // Check for duplicate Azure tenant ID
    if (dto.azureTenantId) {
      const existing = await this.organizationRepository.findOne({
        where: { azureTenantId: dto.azureTenantId },
      });
      if (existing) {
        throw new ConflictException(
          'An organization with this Azure tenant ID already exists',
        );
      }
    }

    return this.dataSource.transaction(async (manager) => {
      const setup = createPasswordSetupToken();
      // 1. Create the organization
      const organization = manager.create(Organization, {
        name: dto.name,
        azureTenantId: dto.azureTenantId,
        status: 'ACTIVE',
      });
      const savedOrg = await manager.save(Organization, organization);

      // 2. Pre-create the ORG_ADMIN stub
      const adminUser = manager.create(AppUser, {
        email: normalizedEmail,
        name: deriveDisplayNameFromEmail(normalizedEmail),
        orgId: savedOrg.id,
        role: 'ORG_ADMIN',
        status: 'ACTIVE',
        passwordSetupTokenHash: setup.tokenHash,
        passwordSetupExpiresAt: new Date(Date.now() + 48 * 60 * 60 * 1000),
      });
      const savedAdmin = await manager.save(AppUser, adminUser);

      this.logger.log(
        `Organization created: ${savedOrg.name} (${savedOrg.id}) with ORG_ADMIN: ${normalizedEmail}`,
      );

      return { ...savedOrg, orgAdmin: savedAdmin, setupToken: setup.token };
    });
  }

  /**
   * Get all organizations (ADMIN only)
   */
  async findAll(): Promise<Organization[]> {
    return this.organizationRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get organization by ID
   */
  async findOne(id: string): Promise<Organization> {
    const organization = await this.organizationRepository.findOne({
      where: { id },
    });

    if (!organization) {
      throw new NotFoundException('Organization not found');
    }

    return organization;
  }

  /**
   * Get organization by Azure tenant ID
   */
  async findByAzureTenantId(azureTenantId: string): Promise<Organization | null> {
    return this.organizationRepository.findOne({
      where: { azureTenantId },
    });
  }

  /**
   * Update organization (ADMIN only)
   */
  async update(id: string, dto: UpdateOrganizationDto): Promise<Organization> {
    const organization = await this.findOne(id);

    // Check for duplicate Azure tenant ID
    if (dto.azureTenantId && dto.azureTenantId !== organization.azureTenantId) {
      const existing = await this.organizationRepository.findOne({
        where: { azureTenantId: dto.azureTenantId },
      });

      if (existing) {
        throw new ConflictException(
          'An organization with this Azure tenant ID already exists',
        );
      }
    }

    Object.assign(organization, dto);
    const updated = await this.organizationRepository.save(organization);

    this.logger.log(`Organization updated: ${updated.name} (${updated.id})`);

    return updated;
  }

  /**
   * Deactivate organization (ADMIN only)
   */
  async deactivate(id: string): Promise<Organization> {
    const organization = await this.findOne(id);
    organization.status = 'INACTIVE';

    const updated = await this.organizationRepository.save(organization);
    this.logger.log(`Organization deactivated: ${updated.name} (${updated.id})`);

    return updated;
  }

  /**
   * Delete organization (ADMIN only)
   * WARNING: This is a hard delete
   */
  async remove(id: string): Promise<void> {
    const organization = await this.findOne(id);
    await this.organizationRepository.remove(organization);

    this.logger.log(`Organization deleted: ${organization.name} (${id})`);
  }

  /**
   * Get platform-wide stats (ADMIN only)
   * Returns org count, users per org, projects per org, tasks per project
   */
  async getStats(): Promise<PlatformStatsDto> {
    const rows: Array<{
      org_id: string;
      org_name: string;
      org_status: string;
      user_count: string;
      project_id: string | null;
      project_name: string | null;
      task_count: string;
    }> = await this.dataSource.query(`
      SELECT
        o.id            AS org_id,
        o.name          AS org_name,
        o.status        AS org_status,
        COUNT(DISTINCT u.id)  AS user_count,
        p.id            AS project_id,
        p.name          AS project_name,
        COUNT(DISTINCT t.id)  AS task_count
      FROM organization o
      LEFT JOIN app_user u  ON u.org_id = o.id
      LEFT JOIN project  p  ON p.org_id = o.id
      LEFT JOIN task     t  ON t.project_id = p.id
      GROUP BY o.id, o.name, o.status, p.id, p.name
      ORDER BY o.name, p.name
    `);

    // Aggregate raw rows into nested structure
    const orgMap = new Map<string, {
      id: string; name: string; status: string;
      userCount: number; projectCount: number;
      projects: Map<string, { id: string; name: string; taskCount: number }>;
    }>();

    for (const row of rows) {
      if (!orgMap.has(row.org_id)) {
        orgMap.set(row.org_id, {
          id: row.org_id,
          name: row.org_name,
          status: row.org_status,
          userCount: Number(row.user_count),
          projectCount: 0,
          projects: new Map(),
        });
      }
      const org = orgMap.get(row.org_id)!;
      // Update userCount (same value repeated per project row — take max)
      org.userCount = Math.max(org.userCount, Number(row.user_count));

      if (row.project_id && !org.projects.has(row.project_id)) {
        org.projects.set(row.project_id, {
          id: row.project_id,
          name: row.project_name!,
          taskCount: Number(row.task_count),
        });
        org.projectCount += 1;
      }
    }

    const organizations = Array.from(orgMap.values()).map((o) => ({
      id: o.id,
      name: o.name,
      status: o.status,
      userCount: o.userCount,
      projectCount: o.projectCount,
      projects: Array.from(o.projects.values()),
    }));

    return {
      totalOrganizations: organizations.length,
      totalUsers: organizations.reduce((s, o) => s + o.userCount, 0),
      totalProjects: organizations.reduce((s, o) => s + o.projectCount, 0),
      totalTasks: organizations.reduce(
        (s, o) => s + o.projects.reduce((ps, p) => ps + p.taskCount, 0),
        0,
      ),
      organizations,
    };
  }

  /**
   * Assign or change the ORG_ADMIN of an organization by EMAIL (ADMIN only).
   *
   * Two cases:
   *  1. User already exists (has logged in before) → promote them.
   *  2. User does not exist yet → pre-create an account with ORG_ADMIN role.
   */
  async setOrgAdmin(orgId: string, email: string): Promise<AppUser> {
    // Ensure org exists
    await this.findOne(orgId);

    const normalizedEmail = email.toLowerCase().trim();

    // Demote any existing ORG_ADMIN in this org first
    await this.appUserRepository
      .createQueryBuilder()
      .update(AppUser)
      .set({ role: 'MEMBER' })
      .where('org_id = :orgId AND role = :role', { orgId, role: 'ORG_ADMIN' })
      .execute();

    let user = await this.appUserRepository.findOne({
      where: { email: normalizedEmail, orgId },
    });

    if (!user) {
      // New organization administrators complete setup with an invitation link.
      this.logger.log(
        `Pre-creating ORG_ADMIN stub for ${normalizedEmail} in org ${orgId}`,
      );
      user = this.appUserRepository.create({
        email: normalizedEmail,
        name: deriveDisplayNameFromEmail(normalizedEmail),
        orgId,
        role: 'ORG_ADMIN',
        status: 'ACTIVE',
      });
    } else {
      user.role = 'ORG_ADMIN';
    }

    const saved = await this.appUserRepository.save(user);
    this.logger.log(`ORG_ADMIN set to ${normalizedEmail} (id: ${saved.id}) in org ${orgId}`);
    return saved;
  }

  /**
   * Get ADMIN dashboard statistics.
   * If orgId is provided, scope to that org only; otherwise return all orgs.
   */
  async getDashboardStats(orgId?: string): Promise<AdminDashboardDto> {
    const param = orgId ?? null;

    // ── Query 1: org-level aggregates ───────────────────────────────────────
    const orgRows: Array<Record<string, string>> = await this.dataSource.query(
      `
      SELECT
        o.id         AS org_id,
        o.name       AS org_name,
        o.status     AS org_status,
        o.created_at AS org_created_at,

        COUNT(DISTINCT u.id)                                             AS total_users,
        COUNT(DISTINCT u.id) FILTER (WHERE u.status = 'ACTIVE')         AS active_users,
        COUNT(DISTINCT u.id) FILTER (WHERE u.status != 'ACTIVE')        AS inactive_users,

        COUNT(DISTINCT p.id)                                             AS total_projects,
        COUNT(DISTINCT p.id) FILTER (WHERE p.status = 'ACTIVE')         AS active_projects,

        COUNT(DISTINCT s.id)                                             AS total_sprints,
        COUNT(DISTINCT s.id) FILTER (WHERE s.status = 'PLANNED')        AS planned_sprints,
        COUNT(DISTINCT s.id) FILTER (WHERE s.status = 'ACTIVE')         AS active_sprints,
        COUNT(DISTINCT s.id) FILTER (WHERE s.status = 'COMPLETED')      AS completed_sprints,

        COUNT(DISTINCT t.id)                                             AS total_tasks,
        COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'TODO')           AS todo_tasks,
        COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'IN_PROGRESS')    AS in_progress_tasks,
        COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'DONE')           AS done_tasks,
        COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'CANCELLED')      AS cancelled_tasks

      FROM organization o
      LEFT JOIN app_user u ON u.org_id = o.id
      LEFT JOIN project  p ON p.org_id = o.id
      LEFT JOIN sprint   s ON s.project_id = p.id
      LEFT JOIN task     t ON t.project_id = p.id
      WHERE ($1::uuid IS NULL OR o.id = $1::uuid)
      GROUP BY o.id, o.name, o.status, o.created_at
      ORDER BY o.name
      `,
      [param],
    );

    // ── Query 2: project-level breakdown ────────────────────────────────────
    const projectRows: Array<Record<string, string>> =
      await this.dataSource.query(
        `
      SELECT
        p.id         AS project_id,
        p.name       AS project_name,
        p.status     AS project_status,
        p.org_id     AS org_id,

        COUNT(DISTINCT upm.user_id)                                      AS team_size,

        COUNT(DISTINCT s.id)                                             AS total_sprints,
        COUNT(DISTINCT s.id) FILTER (WHERE s.status = 'PLANNED')        AS planned_sprints,
        COUNT(DISTINCT s.id) FILTER (WHERE s.status = 'ACTIVE')         AS active_sprints,
        COUNT(DISTINCT s.id) FILTER (WHERE s.status = 'COMPLETED')      AS completed_sprints,

        COUNT(DISTINCT t.id)                                             AS total_tasks,
        COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'TODO')           AS todo_tasks,
        COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'IN_PROGRESS')    AS in_progress_tasks,
        COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'DONE')           AS done_tasks,
        COUNT(DISTINCT t.id) FILTER (WHERE t.status = 'CANCELLED')      AS cancelled_tasks

      FROM project p
      LEFT JOIN user_project_mapping upm ON upm.project_id = p.id AND upm.status = 'ACTIVE'
      LEFT JOIN sprint   s ON s.project_id = p.id
      LEFT JOIN task     t ON t.project_id = p.id
      WHERE ($1::uuid IS NULL OR p.org_id = $1::uuid)
      GROUP BY p.id, p.name, p.status, p.org_id
      ORDER BY p.name
      `,
        [param],
      );

    // ── Group projects by org ───────────────────────────────────────────────
    const projectsByOrg = new Map<string, Array<Record<string, string>>>();
    for (const pr of projectRows) {
      if (!projectsByOrg.has(pr['org_id'])) {
        projectsByOrg.set(pr['org_id'], []);
      }
      projectsByOrg.get(pr['org_id'])!.push(pr);
    }

    // ── Build org tiles ─────────────────────────────────────────────────────
    const n = (v: string) => Number(v ?? 0);

    const organizations: DashboardOrgTileDto[] = orgRows.map((row) => {
      const projectBreakdown = (
        projectsByOrg.get(row['org_id']) ?? []
      ).map((pr) => ({
        id: pr['project_id'],
        name: pr['project_name'],
        status: pr['project_status'],
        teamSize: n(pr['team_size']),
        sprints: {
          total: n(pr['total_sprints']),
          planned: n(pr['planned_sprints']),
          active: n(pr['active_sprints']),
          completed: n(pr['completed_sprints']),
        },
        tasks: {
          total: n(pr['total_tasks']),
          todo: n(pr['todo_tasks']),
          inProgress: n(pr['in_progress_tasks']),
          done: n(pr['done_tasks']),
          cancelled: n(pr['cancelled_tasks']),
        },
      }));

      return {
        id: row['org_id'],
        name: row['org_name'],
        status: row['org_status'],
        createdAt: row['org_created_at'] as unknown as Date,
        users: {
          total: n(row['total_users']),
          active: n(row['active_users']),
          inactive: n(row['inactive_users']),
        },
        projects: {
          total: n(row['total_projects']),
          active: n(row['active_projects']),
        },
        sprints: {
          total: n(row['total_sprints']),
          planned: n(row['planned_sprints']),
          active: n(row['active_sprints']),
          completed: n(row['completed_sprints']),
        },
        tasks: {
          total: n(row['total_tasks']),
          todo: n(row['todo_tasks']),
          inProgress: n(row['in_progress_tasks']),
          done: n(row['done_tasks']),
          cancelled: n(row['cancelled_tasks']),
        },
        projectBreakdown,
      };
    });

    // ── Build platform summary ──────────────────────────────────────────────
    const summary: DashboardSummaryDto = {
      totalOrganizations: organizations.length,
      activeOrganizations: organizations.filter((o) => o.status === 'ACTIVE').length,
      totalUsers: organizations.reduce((s, o) => s + o.users.total, 0),
      activeUsers: organizations.reduce((s, o) => s + o.users.active, 0),
      totalProjects: organizations.reduce((s, o) => s + o.projects.total, 0),
      activeProjects: organizations.reduce((s, o) => s + o.projects.active, 0),
      totalSprints: organizations.reduce((s, o) => s + o.sprints.total, 0),
      activeSprints: organizations.reduce((s, o) => s + o.sprints.active, 0),
      totalTasks: organizations.reduce((s, o) => s + o.tasks.total, 0),
      openTasks: organizations.reduce((s, o) => s + o.tasks.todo, 0),
      inProgressTasks: organizations.reduce((s, o) => s + o.tasks.inProgress, 0),
      completedTasks: organizations.reduce((s, o) => s + o.tasks.done, 0),
    };

    return {
      generatedAt: new Date().toISOString(),
      filter: { orgId: orgId ?? null },
      summary,
      organizations,
    };
  }
}
