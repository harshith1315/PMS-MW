import { Injectable, Logger, UnauthorizedException, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { promisify } from 'util';
import { randomBytes, scrypt as scryptCallback, timingSafeEqual } from 'crypto';
import { Organization } from '../../entities/organization.entity';
import { AppUser } from '../../entities/app-user.entity';
import { ActivityLogService } from '../activity-log/activity-log.service';
import { hashPasswordSetupToken } from '../../common/utils/auth-tokens';

const scrypt = promisify(scryptCallback);

export interface UserContext {
  userId: string;
  orgId: string;
  email: string;
  name: string;
  role: string;
  roleId?: string | null;
  externalId: string;
}

interface JwtUserPayload {
  sub: string;
  orgId: string;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    @InjectRepository(Organization)
    private readonly organizationRepository: Repository<Organization>,
    @InjectRepository(AppUser)
    private readonly appUserRepository: Repository<AppUser>,
    private readonly activityLogService: ActivityLogService,
    private readonly jwtService: JwtService,
  ) {}

  private async hashPassword(password: string): Promise<string> {
    const salt = randomBytes(16);
    const derivedKey = (await scrypt(password, salt, 64)) as Buffer;
    return `scrypt$${salt.toString('hex')}$${derivedKey.toString('hex')}`;
  }

  private async verifyPassword(password: string, storedHash: string): Promise<boolean> {
    const [algorithm, saltHex, keyHex] = storedHash.split('$');
    if (algorithm !== 'scrypt' || !saltHex || !keyHex) return false;
    const expected = Buffer.from(keyHex, 'hex');
    const actual = (await scrypt(password, Buffer.from(saltHex, 'hex'), expected.length)) as Buffer;
    return actual.length === expected.length && timingSafeEqual(actual, expected);
  }

  async login(email: string, password: string): Promise<{ accessToken: string }> {
    const normalizedEmail = email.trim().toLowerCase();
    const users = await this.appUserRepository
      .createQueryBuilder('user')
      .addSelect('user.passwordHash')
      .leftJoinAndSelect('user.organization', 'organization')
      .where('LOWER(user.email) = :email', { email: normalizedEmail })
      .andWhere('user.status = :status', { status: 'ACTIVE' })
      .andWhere('organization.status = :orgStatus', { orgStatus: 'ACTIVE' })
      .getMany();

    const matches: AppUser[] = [];
    for (const user of users) {
      if (user.passwordHash && await this.verifyPassword(password, user.passwordHash)) {
        matches.push(user);
      }
    }
    if (matches.length !== 1) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const user = matches[0];
    const accessToken = await this.jwtService.signAsync({
      sub: user.id,
      orgId: user.orgId,
    } satisfies JwtUserPayload);
    return { accessToken };
  }

  async setPassword(token: string, password: string): Promise<void> {
    const tokenHash = hashPasswordSetupToken(token);
    const user = await this.appUserRepository
      .createQueryBuilder('user')
      .addSelect(['user.passwordSetupTokenHash', 'user.passwordSetupExpiresAt'])
      .where('user.passwordSetupTokenHash = :tokenHash', { tokenHash })
      .getOne();

    if (!user?.passwordSetupExpiresAt || user.passwordSetupExpiresAt <= new Date()) {
      throw new BadRequestException('This password setup link is invalid or expired');
    }

    const passwordHash = await this.hashPassword(password);
    const result = await this.appUserRepository
      .createQueryBuilder()
      .update(AppUser)
      .set({ passwordHash, passwordSetupTokenHash: null, passwordSetupExpiresAt: null })
      .where('id = :id', { id: user.id })
      .andWhere('password_setup_token_hash = :tokenHash', { tokenHash })
      .andWhere('password_setup_expires_at > NOW()')
      .execute();

    if (result.affected !== 1) {
      throw new BadRequestException('This password setup link is invalid or expired');
    }
  }

  async validateJwtUser(payload: JwtUserPayload): Promise<UserContext> {
    const user = await this.appUserRepository.findOne({
      where: { id: payload.sub, orgId: payload.orgId, status: 'ACTIVE' },
      relations: ['organization', 'roleEntity'],
    });
    if (!user || user.organization?.status !== 'ACTIVE') {
      throw new UnauthorizedException('Account is inactive or unavailable');
    }
    return {
      userId: user.id,
      orgId: user.orgId,
      email: user.email,
      name: user.name ?? user.email,
      role: user.roleEntity?.key ?? user.role ?? 'USER',
      roleId: user.roleId,
      externalId: user.id,
    };
  }

  /**
   * Log user login activity — called explicitly from POST /auth/login endpoint
   */
  async logLogin(
    user: UserContext,
    ipAddress?: string | null,
    userAgent?: string | null,
  ): Promise<void> {
    try {
      await this.activityLogService.create({
        orgId: user.orgId,
        actorUserId: user.userId,
        actorName: user.name,
        actorEmail: user.email,
        method: 'POST',
        resourceType: 'auth',
        actionType: 'USER_LOGGED_IN',
        message: `${user.name} (${user.email}) logged in`,
        requestPath: '/auth/record-login',
        ipAddress: ipAddress ?? undefined,
        userAgent: userAgent ?? undefined,
      });
      this.logger.debug(`Login activity logged for user: ${user.email}`);
    } catch (error) {
      this.logger.warn(`Failed to log login activity: ${error}`);
    }
  }

  /**
   * Log user logout activity — called explicitly from POST /auth/logout endpoint
   */
  async logLogout(
    user: UserContext,
    ipAddress?: string | null,
    userAgent?: string | null,
  ): Promise<void> {
    try {
      await this.activityLogService.create({
        orgId: user.orgId,
        actorUserId: user.userId,
        actorName: user.name,
        actorEmail: user.email,
        method: 'POST',
        resourceType: 'auth',
        actionType: 'USER_LOGGED_OUT',
        message: `${user.name} (${user.email}) logged out`,
        requestPath: '/auth/logout',
        ipAddress: ipAddress ?? undefined,
        userAgent: userAgent ?? undefined,
      });
      this.logger.debug(`Logout activity logged for user: ${user.email}`);
    } catch (error) {
      this.logger.warn(`Failed to log logout activity: ${error}`);
    }
  }

  /**
   * Get user by ID within organization
   */
  async getUserById(userId: string, orgId: string): Promise<AppUser> {
    const user = await this.appUserRepository.findOne({
      where: { id: userId, orgId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  /**
   * Get organization by ID
   */
  async getOrganizationById(orgId: string): Promise<Organization> {
    const org = await this.organizationRepository.findOne({
      where: { id: orgId },
    });

    if (!org) {
      throw new NotFoundException('Organization not found');
    }

    return org;
  }
}
