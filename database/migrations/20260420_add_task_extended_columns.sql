-- Migration: Add missing extended columns to task table
-- Date: 2026-04-20

BEGIN;

ALTER TABLE task
  ADD COLUMN IF NOT EXISTS output_description TEXT,
  ADD COLUMN IF NOT EXISTS blocked_by UUID,
  ADD COLUMN IF NOT EXISTS epic_id UUID,
  ADD COLUMN IF NOT EXISTS story_id UUID,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'fk_task_blocked_by_app_user'
  ) THEN
    ALTER TABLE task
      ADD CONSTRAINT fk_task_blocked_by_app_user
      FOREIGN KEY (blocked_by)
      REFERENCES app_user(id)
      ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'fk_task_epic_id_task'
  ) THEN
    ALTER TABLE task
      ADD CONSTRAINT fk_task_epic_id_task
      FOREIGN KEY (epic_id)
      REFERENCES task(id)
      ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'fk_task_story_id_task'
  ) THEN
    ALTER TABLE task
      ADD CONSTRAINT fk_task_story_id_task
      FOREIGN KEY (story_id)
      REFERENCES task(id)
      ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_task_blocked_by ON task(blocked_by);
CREATE INDEX IF NOT EXISTS idx_task_epic_id ON task(epic_id);
CREATE INDEX IF NOT EXISTS idx_task_story_id ON task(story_id);

COMMIT;
