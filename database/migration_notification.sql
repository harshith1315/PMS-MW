-- Migration: Create notification table
-- This migration creates the notification system for alerts

CREATE TABLE IF NOT EXISTS notification (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  task_id UUID NOT NULL REFERENCES task(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  metadata JSONB,
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_notification_recipient_id ON notification(recipient_id);
CREATE INDEX IF NOT EXISTS idx_notification_recipient_is_read ON notification(recipient_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notification_recipient_created_at ON notification(recipient_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_task_id ON notification(task_id);
CREATE INDEX IF NOT EXISTS idx_notification_type ON notification(type);
CREATE INDEX IF NOT EXISTS idx_notification_created_at ON notification(created_at DESC);
