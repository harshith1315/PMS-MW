import { ConfigService } from '@nestjs/config';

export function getJwtSecret(configService: ConfigService): string {
  const secret = configService.get<string>('JWT_SECRET');
  if (
    !secret ||
    secret.length < 32 ||
    secret.startsWith('replace-with-a-random-secret')
  ) {
    throw new Error('JWT_SECRET must be a unique secret of at least 32 characters');
  }
  return secret;
}
