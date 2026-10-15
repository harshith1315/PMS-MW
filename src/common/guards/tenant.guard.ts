import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Logger,
} from '@nestjs/common';

/**
 * Tenant Guard - Ensures multi-tenant security
 * 
 * This guard:
 * 1. Verifies that user context has org_id
 * 2. Adds org_id to request for downstream processing
 * 3. Ensures all tenant-scoped queries filter by org_id
 * 
 * IMPORTANT: This guard should be used in combination with JwtAuthGuard
 */
@Injectable()
export class TenantGuard implements CanActivate {
  private readonly logger = new Logger(TenantGuard.name);

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      this.logger.warn('TenantGuard: No user in request');
      throw new ForbiddenException('Authentication required');
    }

    if (!user.orgId) {
      this.logger.warn(`TenantGuard: User ${user.userId} has no organization`);
      throw new ForbiddenException('User is not associated with any organization');
    }

    // Attach tenantId to request for easy access in services
    request.orgId = user.orgId;
    request.tenantId = user.orgId; // Alias for compatibility

    this.logger.debug(`TenantGuard: Allowing access for org ${user.orgId}`);

    return true;
  }
}
