import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';

/**
 * Roles Guard - Role-based access control
 * 
 * Use with @Roles() decorator to restrict access to specific roles
 */
@Injectable()
export class RolesGuard implements CanActivate {
  private readonly logger = new Logger(RolesGuard.name);

  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    // If no roles specified, allow access
    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('Authentication required');
    }

    const hasRole = requiredRoles.some((role) => user.role === role);

    if (!hasRole) {
      this.logger.warn(
        `User ${user.userId} with role ${user.role} denied access - required roles: ${requiredRoles.join(', ')}`,
      );
      throw new ForbiddenException('Insufficient permissions');
    }

    return true;
  }
}
