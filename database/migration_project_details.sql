-- Project details, finance, and metadata extension
-- Safe to run multiple times.

ALTER TABLE project
  ADD COLUMN IF NOT EXISTS finance_code VARCHAR(50),
  ADD COLUMN IF NOT EXISTS budget DECIMAL(15,2),
  ADD COLUMN IF NOT EXISTS kickoff_date DATE,
  ADD COLUMN IF NOT EXISTS start_date DATE,
  ADD COLUMN IF NOT EXISTS end_date DATE,
  ADD COLUMN IF NOT EXISTS project_type VARCHAR(20),
  ADD COLUMN IF NOT EXISTS client_name VARCHAR(255),
  ADD COLUMN IF NOT EXISTS client_location VARCHAR(255),
  ADD COLUMN IF NOT EXISTS purpose TEXT,
  ADD COLUMN IF NOT EXISTS cost_management TEXT,
  ADD COLUMN IF NOT EXISTS tech_stack JSONB,
  ADD COLUMN IF NOT EXISTS dependencies JSONB;

UPDATE project
SET tech_stack = '[]'::jsonb
WHERE tech_stack IS NULL;

UPDATE project
SET dependencies = '[]'::jsonb
WHERE dependencies IS NULL;

ALTER TABLE project
  ALTER COLUMN tech_stack SET DEFAULT '[]'::jsonb,
  ALTER COLUMN dependencies SET DEFAULT '[]'::jsonb,
  ALTER COLUMN tech_stack SET NOT NULL,
  ALTER COLUMN dependencies SET NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'chk_project_type_values'
  ) THEN
    ALTER TABLE project
      ADD CONSTRAINT chk_project_type_values CHECK (project_type IN ('WEB', 'MOBILE', 'BOTH') OR project_type IS NULL);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'chk_project_budget_non_negative'
  ) THEN
    ALTER TABLE project
      ADD CONSTRAINT chk_project_budget_non_negative CHECK (budget IS NULL OR budget >= 0);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_project_type ON project(project_type);
CREATE UNIQUE INDEX IF NOT EXISTS uq_project_org_finance_code ON project(org_id, finance_code) WHERE finance_code IS NOT NULL;
