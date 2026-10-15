import { SetMetadata } from '@nestjs/common';

export const ROLES_KEY = 'roles';

/**
 * Roles decorator for role-based access control
 * 
 * Usage:
 * @Roles('ORG_ADMIN')
 * @Roles('ORG_ADMIN', 'USER')
 */
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
