import {
  Controller,
  Get,
  Patch,
  Delete,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { NotificationService } from './notification.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { TenantGuard } from '../../common/guards/tenant.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserContext } from '../auth/auth.service';

@Controller('notifications')
@UseGuards(JwtAuthGuard, TenantGuard)
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  /**
   * Get notifications for current user
   */
  @Get()
  async getNotifications(
    @CurrentUser() user: UserContext,
    @Query('skip') skip: string = '0',
    @Query('take') take: string = '20',
    @Query('isRead') isRead: string,
  ) {
    const skipNum = Number.parseInt(skip, 10) || 0;
    const takeNum = Number.parseInt(take, 10) || 20;
    const isReadBool = isRead ? isRead === 'true' : undefined;

    const result = await this.notificationService.getByRecipient(user.userId, {
      skip: skipNum,
      take: takeNum,
      isRead: isReadBool,
    });

    return {
      statusCode: HttpStatus.OK,
      data: result.data,
      total: result.total,
      skip: skipNum,
      take: takeNum,
    };
  }

  /**
   * Get unread count
   */
  @Get('unread/count')
  async getUnreadCount(@CurrentUser() user: UserContext) {
    const count = await this.notificationService.getUnreadCount(user.userId);
    return {
      statusCode: HttpStatus.OK,
      unreadCount: count,
    };
  }

  /**
   * Mark notification as read
   */
  @Patch(':id/read')
  @HttpCode(HttpStatus.OK)
  async markAsRead(@Param('id') notificationId: string) {
    const notification = await this.notificationService.markAsRead(notificationId);
    return {
      statusCode: HttpStatus.OK,
      data: notification,
    };
  }

  /**
   * Mark all notifications as read
   */
  @Patch('read-all')
  @HttpCode(HttpStatus.OK)
  async markAllAsRead(@CurrentUser() user: UserContext) {
    await this.notificationService.markAllAsRead(user.userId);
    return {
      statusCode: HttpStatus.OK,
      message: 'All notifications marked as read',
    };
  }

  /**
   * Delete a notification
   */
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async deleteNotification(@Param('id') notificationId: string) {
    await this.notificationService.delete(notificationId);
    return {
      statusCode: HttpStatus.OK,
      message: 'Notification deleted successfully',
    };
  }
}
