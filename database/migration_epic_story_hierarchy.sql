-- Epic → Story → Task → Subtask hierarchy
-- Adds epic_id and story_id self-referential FK columns to task table.
-- Both nullable for full backward compatibility with existing tasks.

ALTER TABLE task ADD COLUMN IF NOT EXISTS epic_id UUID REFERENCES task(id) ON DELETE SET NULL;
ALTER TABLE task ADD COLUMN IF NOT EXISTS story_id UUID REFERENCES task(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_task_epic   ON task(epic_id)   WHERE epic_id   IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_task_story  ON task(story_id)  WHERE story_id  IS NOT NULL;
