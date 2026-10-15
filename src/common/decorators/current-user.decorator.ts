import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { UserContext } from '../../modules/auth/auth.service';

/**
 * Custom decorator to extract current user from request
 * 
 * Usage:
 * @CurrentUser() user: UserContext
 * @CurrentUser('userId') userId: string
 */
export const CurrentUser = createParamDecorator(
  (data: keyof UserContext | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as UserContext;

    if (data) {
      return user?.[data];
    }

    return user;
  },
);
