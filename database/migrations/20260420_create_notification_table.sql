-- Migration: Create notification table used by notification module
-- Date: 2026-04-20

CREATE TABLE IF NOT EXISTS notification (
  id UUID PRIMARY KEY DEFAULT public.uuid_generate_v4(),
  recipient_id UUID NOT NULL REFERENCES app_user(id),
  task_id UUID NOT NULL REFERENCES task(id),
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  metadata JSON,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notification_recipient_is_read
  ON notification(recipient_id, is_read);

CREATE INDEX IF NOT EXISTS idx_notification_created_at
  ON notification(created_at);