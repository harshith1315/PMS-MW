-- =====================================================
-- Migration: Align project & user_project_mapping tables
--            with the current TypeORM entity definitions
-- Run once against the onelign_pms database
-- Date: 2026-04-10
-- =====================================================

BEGIN;

-- =====================================================
-- project: add all columns that exist in the entity
--          but are absent from the live table
-- =====================================================

ALTER TABLE project
  -- Tab 1: Basic Info
  ADD COLUMN IF NOT EXISTS description          TEXT,
  ADD COLUMN IF NOT EXISTS deliverable_type     VARCHAR(50),
  ADD COLUMN IF NOT EXISTS project_type         VARCHAR(20),
  ADD COLUMN IF NOT EXISTS execution_model      VARCHAR(50),

  -- Tab 2: Ownership & Governance
  ADD COLUMN IF NOT EXISTS delivery_manager_id  UUID REFERENCES app_user(id),
  ADD COLUMN IF NOT EXISTS sponsor_id           UUID REFERENCES app_user(id),
  ADD COLUMN IF NOT EXISTS created_by_id        UUID REFERENCES app_user(id),
  ADD COLUMN IF NOT EXISTS approved_by_id       UUID REFERENCES app_user(id),
  ADD COLUMN IF NOT EXISTS priority             VARCHAR(20)  DEFAULT 'MEDIUM',
  ADD COLUMN IF NOT EXISTS risk_level           VARCHAR(20)  DEFAULT 'LOW',

  -- Tab 3: Timeline
  ADD COLUMN IF NOT EXISTS start_date           DATE,
  ADD COLUMN IF NOT EXISTS end_date             DATE,
  ADD COLUMN IF NOT EXISTS actual_start_date    DATE,
  ADD COLUMN IF NOT EXISTS actual_end_date      DATE,
  ADD COLUMN IF NOT EXISTS kickoff_date         DATE,
  ADD COLUMN IF NOT EXISTS milestone_template   VARCHAR(100),

  -- Tab 4: Financials
  ADD COLUMN IF NOT EXISTS budget               DECIMAL(15,2),
  ADD COLUMN IF NOT EXISTS budget_approved      DECIMAL(15,2),
  ADD COLUMN IF NOT EXISTS currency             VARCHAR(10)  DEFAULT 'INR',
  ADD COLUMN IF NOT EXISTS cost_center_id       VARCHAR(100),
  ADD COLUMN IF NOT EXISTS finance_code         VARCHAR(50),
  ADD COLUMN IF NOT EXISTS billing_type         VARCHAR(20),
  ADD COLUMN IF NOT EXISTS contract_type        VARCHAR(20),
  ADD COLUMN IF NOT EXISTS revenue              DECIMAL(15,2),

  -- Tab 6: Configuration
  ADD COLUMN IF NOT EXISTS sprint_duration      INT,
  ADD COLUMN IF NOT EXISTS iteration_start_day  VARCHAR(20),
  ADD COLUMN IF NOT EXISTS estimation_unit      VARCHAR(20),
  ADD COLUMN IF NOT EXISTS velocity_tracking    BOOLEAN      DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS wip_limits           INT,
  ADD COLUMN IF NOT EXISTS continuous_flow      BOOLEAN      DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS phase_template       VARCHAR(100),
  ADD COLUMN IF NOT EXISTS stage_gates          JSONB        DEFAULT '[]'::jsonb,

  -- Tab 7: Integrations
  ADD COLUMN IF NOT EXISTS document_repository  VARCHAR(500),

  -- Tab 8: Client & Contract Info
  ADD COLUMN IF NOT EXISTS client_name          VARCHAR(255),
  ADD COLUMN IF NOT EXISTS client_location      VARCHAR(255),
  ADD COLUMN IF NOT EXISTS client_spoc          VARCHAR(255),
  ADD COLUMN IF NOT EXISTS contract_start_date  DATE,
  ADD COLUMN IF NOT EXISTS contract_end_date    DATE,

  -- Tab 9: Additional Details
  ADD COLUMN IF NOT EXISTS purpose              TEXT,
  ADD COLUMN IF NOT EXISTS cost_management      TEXT,
  ADD COLUMN IF NOT EXISTS comments             TEXT,
  ADD COLUMN IF NOT EXISTS tech_stack           JSONB        NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS dependencies         JSONB        NOT NULL DEFAULT '[]'::jsonb;

-- Conditional unique index on (org_id, finance_code)
CREATE UNIQUE INDEX IF NOT EXISTS uq_project_org_finance_code
  ON project(org_id, finance_code)
  WHERE finance_code IS NOT NULL;

-- =====================================================
-- user_project_mapping: add columns missing from DB
-- =====================================================

ALTER TABLE user_project_mapping
  ADD COLUMN IF NOT EXISTS allocated_bandwidth    INT         DEFAULT 0,
  ADD COLUMN IF NOT EXISTS approval_status        VARCHAR(50) DEFAULT 'PENDING',
  ADD COLUMN IF NOT EXISTS requested_by_user_id   UUID REFERENCES app_user(id),
  ADD COLUMN IF NOT EXISTS approved_by_user_id    UUID REFERENCES app_user(id),
  ADD COLUMN IF NOT EXISTS approved_at            TIMESTAMP;

-- =====================================================
-- sprint: add columns missing from DB
-- =====================================================

ALTER TABLE sprint
  ADD COLUMN IF NOT EXISTS definition TEXT;

-- =====================================================
-- task: add columns missing from DB
-- =====================================================

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

-- =====================================================
-- project: drop stale chk_* check constraints that
--          conflict with the newer project_*_check
--          constraints (old enums like APPLICATION,
--          APPLIANCE, T_AND_M, etc. vs current values)
-- =====================================================

ALTER TABLE project
  DROP CONSTRAINT IF EXISTS chk_deliverable_type_values,
  DROP CONSTRAINT IF EXISTS chk_execution_model_values,
  DROP CONSTRAINT IF EXISTS chk_billing_type_values,
  DROP CONSTRAINT IF EXISTS chk_contract_type_values,
  DROP CONSTRAINT IF EXISTS chk_currency_values,
  DROP CONSTRAINT IF EXISTS chk_priority_values,
  DROP CONSTRAINT IF EXISTS chk_risk_level_values,
  DROP CONSTRAINT IF EXISTS chk_estimation_unit_values;

COMMIT;
