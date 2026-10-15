-- Migration: Add blockedBy column to task table and updated_at timestamp
-- This migration adds support for tracking task blocking

ALTER TABLE task
ADD COLUMN IF NOT EXISTS blocked_by UUID REFERENCES app_user(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Create index for blocked_by foreign key lookup
CREATE INDEX IF NOT EXISTS idx_task_blocked_by ON task(blocked_by);

-- Create index for finding blocked tasks
CREATE INDEX IF NOT EXISTS idx_task_blocked_status ON task(status) 
WHERE status = 'BLOCKED';
