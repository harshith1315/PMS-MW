import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from '../../entities/notification.entity';

export interface CreateNotificationDto {
  recipientId: string;
  taskId: string;
  type: string;
  title: string;
  message: string;
  metadata?: Record<string, any>;
}

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepository: Repository<Notification>,
  ) {}

  /**
   * Create a notification
   */
  async create(dto: CreateNotificationDto): Promise<Notification> {
    try {
      const notification = this.notificationRepository.create({
        recipientId: dto.recipientId,
        taskId: dto.taskId,
        type: dto.type,
        title: dto.title,
        message: dto.message,
        metadata: dto.metadata || {},
        isRead: false,
      });

      const saved = await this.notificationRepository.save(notification);
      this.logger.log(
        `Notification created: ${saved.id} for user ${dto.recipientId}`,
      );
      return saved;
    } catch (error) {
      this.logger.error(`Failed to create notification: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get notifications for a recipient
   */
  async getByRecipient(
    recipientId: string,
    {
      skip = 0,
      take = 20,
      isRead,
    }: { skip?: number; take?: number; isRead?: boolean } = {},
  ): Promise<{ data: Notification[]; total: number }> {
    const query = this.notificationRepository
      .createQueryBuilder('notification')
      .where('notification.recipientId = :recipientId', { recipientId })
      .leftJoinAndSelect('notification.task', 'task')
      .leftJoinAndSelect('notification.recipient', 'recipient')
      .orderBy('notification.createdAt', 'DESC');

    if (isRead !== undefined) {
      query.andWhere('notification.isRead = :isRead', { isRead });
    }

    const [data, total] = await query
      .skip(skip)
      .take(take)
      .getManyAndCount();

    return { data, total };
  }

  /**
   * Mark a notification as read
   */
  async markAsRead(notificationId: string): Promise<Notification> {
    const notification = await this.notificationRepository.findOne({
      where: { id: notificationId },
    });

    if (!notification) {
      throw new Error(`Notification not found: ${notificationId}`);
    }

    notification.isRead = true;
    const updated = await this.notificationRepository.save(notification);
    this.logger.log(`Notification marked as read: ${notificationId}`);
    return updated;
  }

  /**
   * Mark all notifications as read for a recipient
   */
  async markAllAsRead(recipientId: string): Promise<void> {
    await this.notificationRepository.update(
      { recipientId, isRead: false },
      { isRead: true },
    );
    this.logger.log(
      `All notifications marked as read for user: ${recipientId}`,
    );
  }

  /**
   * Delete a notification
   */
  async delete(notificationId: string): Promise<void> {
    const result = await this.notificationRepository.delete(notificationId);
    if (result.affected === 0) {
      throw new Error(`Notification not found: ${notificationId}`);
    }
    this.logger.log(`Notification deleted: ${notificationId}`);
  }

  /**
   * Get unread count for a recipient
   */
  async getUnreadCount(recipientId: string): Promise<number> {
    return this.notificationRepository.countBy({
      recipientId,
      isRead: false,
    });
  }

  /**
   * Create notifications for multiple recipients
   */
  async createBatch(
    dtos: CreateNotificationDto[],
  ): Promise<Notification[]> {
    if (dtos.length === 0) {
      return [];
    }

    const notifications = dtos.map((dto) =>
      this.notificationRepository.create({
        recipientId: dto.recipientId,
        taskId: dto.taskId,
        type: dto.type,
        title: dto.title,
        message: dto.message,
        metadata: dto.metadata || {},
        isRead: false,
      }),
    );

    const saved = await this.notificationRepository.save(notifications);
    this.logger.log(`Batch created ${saved.length} notifications`);
    return saved;
  }
}
