import { SetMetadata } from "@nestjs/common";

export const PERMISSIONS_KEY = "required_permissions";

/**
 * Permissions decorator for permission-based access control.
 * Works with PermissionsGuard to check the user's effective permissions
 * from the access_control tables (role_permission + user_permission).
 *
 * Usage:
 * @Permissions('MANAGE_SPRINT')
 * @Permissions('CREATE_PROJECT')
 * @Permissions('VIEW_USER', 'MANAGE_USERS')   // OR logic — any one is enough
 */
export const Permissions = (...permissions: string[]) =>
  SetMetadata(PERMISSIONS_KEY, permissions);
