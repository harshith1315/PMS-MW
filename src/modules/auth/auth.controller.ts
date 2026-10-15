import { Controller, Get, Post, UseGuards, Req, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { Throttle, ThrottlerGuard } from '@nestjs/throttler';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthService, UserContext } from './auth.service';
import { LoginDto, SetPasswordDto } from './dto/auth.dto';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Sign in with email and password' })
  @ApiResponse({ status: 200, description: 'Access token issued' })
  @ApiResponse({ status: 401, description: 'Invalid email or password' })
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto.email, dto.password);
  }

  @Post('set-password')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Set a password using a single-use invitation link' })
  @ApiResponse({ status: 204, description: 'Password set successfully' })
  setPassword(@Body() dto: SetPasswordDto) {
    return this.authService.setPassword(dto.token, dto.password);
  }

  @Post('record-login')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('bearer')
  @ApiOperation({ summary: 'Record login activity (call once per session after authentication)' })
  @ApiResponse({ status: 200, description: 'Login recorded' })
  async recordLogin(@CurrentUser() user: UserContext, @Req() request: any) {
    const ipAddress = this.getIpAddress(request);
    const userAgent = request.headers?.['user-agent'] ?? null;
    await this.authService.logLogin(user, ipAddress, userAgent);
    return { recorded: true, userId: user.userId };
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('bearer')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({
    status: 200,
    description: 'Returns current authenticated user information',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        userId: { type: 'string', format: 'uuid' },
        orgId: { type: 'string', format: 'uuid' },
        email: { type: 'string', format: 'email' },
        name: { type: 'string' },
        role: { type: 'string', enum: ['ORG_ADMIN', 'USER'] },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  getProfile(@CurrentUser() user: UserContext) {
    return {
      id: user.userId,
      userId: user.userId,
      orgId: user.orgId,
      email: user.email,
      name: user.name,
      role: user.role,
    };
  }

  @Get('verify')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('bearer')
  @ApiOperation({ summary: 'Verify token and return basic status' })
  @ApiResponse({
    status: 200,
    description: 'Token is valid',
    schema: {
      type: 'object',
      properties: {
        valid: { type: 'boolean' },
        message: { type: 'string' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Invalid or expired token' })
  verifyToken(@CurrentUser() user: UserContext) {
    return {
      valid: true,
      message: 'Token is valid',
      userId: user.userId,
    };
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('bearer')
  @ApiOperation({ summary: 'Log user logout activity' })
  @ApiResponse({ status: 200, description: 'Logout logged successfully' })
  async logout(@CurrentUser() user: UserContext, @Req() request: any) {
    const ipAddress = this.getIpAddress(request);
    const userAgent = request.headers?.['user-agent'] ?? null;
    await this.authService.logLogout(user, ipAddress, userAgent);
    return { success: true, message: 'Logged out successfully' };
  }

  private getIpAddress(request: any): string | null {
    const xForwardedFor = request.headers?.['x-forwarded-for'];
    if (typeof xForwardedFor === 'string' && xForwardedFor.length > 0) {
      return xForwardedFor.split(',')[0].trim();
    }
    return request.ip ?? null;
  }
}
