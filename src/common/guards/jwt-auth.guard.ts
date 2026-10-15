import { Injectable, ExecutionContext, Logger, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/** Validates locally issued application access tokens. */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  private readonly logger = new Logger(JwtAuthGuard.name);
  private static readonly MISSING_TOKEN_REASONS = new Set([
    'No auth token',
    'No authorization token was found',
  ]);
  private static readonly EXPECTED_AUTH_FAILURE_REASONS = new Set([
    'Account is inactive or unavailable',
  ]);

  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }

  handleRequest(err: any, user: any, info: any) {
    if (err || !user) {
      // Prefer explicit strategy/auth errors first, then passport info.
      const reason = err instanceof Error
        ? err.message
        : info instanceof Error
          ? info.message
          : (err?.message ?? info?.message ?? info ?? 'unknown');

      // Missing auth headers are common on anonymous or expired UI requests.
      // Keep returning 401, but avoid spamming error logs for this expected case.
      if (JwtAuthGuard.MISSING_TOKEN_REASONS.has(reason)) {
        throw new UnauthorizedException(reason || 'Invalid or missing authentication token');
      }

      // Strategy-level token rejections already log the underlying cause.
      // Avoid repeating them as ERROR with a second line from the guard.
      if (JwtAuthGuard.EXPECTED_AUTH_FAILURE_REASONS.has(reason)) {
        this.logger.warn(`JWT validation rejected: ${reason}`);
        throw new UnauthorizedException(reason || 'Invalid or missing authentication token');
      }

      this.logger.error(`JWT validation failed: ${reason}`);
      throw new UnauthorizedException(reason || 'Invalid or missing authentication token');
    }
    return user;
  }
}
