import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import type { Request } from 'express';
import { AuthService, UserContext } from '../auth.service';
import { getJwtSecret } from '../jwt-secret';

interface AccessTokenPayload {
  sub: string;
  orgId: string;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    configService: ConfigService,
    private readonly authService: AuthService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: getJwtSecret(configService),
      algorithms: ['HS256'],
      passReqToCallback: true,
    });
  }

  validate(_request: Request, payload: AccessTokenPayload): Promise<UserContext> {
    return this.authService.validateJwtUser(payload);
  }
}
