-- Add sprint definition column
-- Allows storing detailed sprint scope/definition alongside the goal

ALTER TABLE sprint ADD COLUMN IF NOT EXISTS definition TEXT;

CREATE INDEX IF NOT EXISTS idx_sprint_definition ON sprint(id) WHERE definition IS NOT NULL;
