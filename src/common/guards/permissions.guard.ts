import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Logger,
} from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { InjectDataSource } from "@nestjs/typeorm";
import { DataSource } from "typeorm";
import { PERMISSIONS_KEY } from "../decorators/permissions.decorator";

/**
 * PermissionsGuard — permission-based access control backed by the DB.
 *
 * Replaces RolesGuard + @Roles() for endpoints that should be
 * configurable via the Access Control page.
 *
 * Logic (mirrors AccessControlService.getEffectivePermissions):
 *   1) user_permission override (most specific)
 *   2) role.permissions default map from role table (via app_user.role_id)
 *
 * Usage in controller:
 *   @UseGuards(PermissionsGuard)
 *   @Permissions('MANAGE_SPRINT')
 */
@Injectable()
export class PermissionsGuard implements CanActivate {
  private readonly logger = new Logger(PermissionsGuard.name);

  constructor(
    private reflector: Reflector,
    @InjectDataSource() private dataSource: DataSource,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredPermissions = this.reflector.getAllAndOverride<string[]>(
      PERMISSIONS_KEY,
      [context.getHandler(), context.getClass()],
    );

    // No permission specified — allow through
    if (!requiredPermissions || requiredPermissions.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException("Authentication required");
    }

    // Need at least one required permission
    for (const permission of requiredPermissions) {
      const granted = await this.hasPermission(
        user.userId,
        user.role,
        permission,
      );
      if (granted) return true;
    }

    this.logger.warn(
      `User ${user.userId} (role: ${user.role}) denied — required: [${requiredPermissions.join(", ")}]`,
    );
    throw new ForbiddenException("Insufficient permissions");
  }

  /**
   * Checks a single permission for a non-ADMIN, non-ORG_ADMIN user.
   * User-level override takes precedence over role-level default.
   */
  private async hasPermission(
    userId: string,
    roleKey: string,
    permission: string,
  ): Promise<boolean> {
    if (roleKey === "ADMIN" || roleKey === "ORG_ADMIN") {
      return true;
    }

    // 1. User-level override (most specific)
    const userRows: { is_granted: boolean }[] = await this.dataSource.query(
      `SELECT is_granted FROM user_permission
       WHERE user_id = $1 AND permission_key = $2
       LIMIT 1`,
      [userId, permission],
    );
    if (userRows.length > 0) {
      return Boolean(userRows[0].is_granted);
    }

    // 2. Role-level default from JSON map in role table
    const roleRows: { is_granted: boolean }[] = await this.dataSource.query(
      `SELECT COALESCE((r.permissions ->> $2)::boolean, false) AS is_granted
       FROM app_user u
       JOIN "role" r ON r.id = u.role_id
       WHERE u.id = $1
       LIMIT 1`,
      [userId, permission],
    );
    if (roleRows.length > 0) {
      return Boolean(roleRows[0].is_granted);
    }

    // Fallback by role key for users not yet backfilled with role_id
    if (roleKey) {
      const fallbackRows: { is_granted: boolean }[] = await this.dataSource.query(
        `SELECT COALESCE((permissions ->> $2)::boolean, false) AS is_granted
         FROM "role"
         WHERE key = $1 AND is_active = true
         LIMIT 1`,
        [roleKey.toUpperCase(), permission],
      );
      if (fallbackRows.length > 0) {
        return Boolean(fallbackRows[0].is_granted);
      }
    }

    return false;
  }
}
