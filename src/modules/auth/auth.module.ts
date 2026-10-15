import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { ThrottlerModule } from '@nestjs/throttler';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtStrategy } from './strategies/jwt.strategy';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { AppUser } from '../../entities/app-user.entity';
import { Organization } from '../../entities/organization.entity';
import { ActivityLogModule } from '../activity-log/activity-log.module';
import { getJwtSecret } from './jwt-secret';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: getJwtSecret(configService),
        signOptions: { expiresIn: '15m' },
      }),
    }),
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 10 }]),
    TypeOrmModule.forFeature([Organization, AppUser]),
    ActivityLogModule,
  ],
  providers: [JwtStrategy, AuthService],
  controllers: [AuthController],
  exports: [AuthService, PassportModule],
})
export class AuthModule {}
