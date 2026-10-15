-- Migration: Add missing finance_member_id column to project table
-- Date: 2026-04-20

ALTER TABLE project
  ADD COLUMN IF NOT EXISTS finance_member_id UUID;

ALTER TABLE project
  DROP CONSTRAINT IF EXISTS fk_project_finance_member;

ALTER TABLE project
  ADD CONSTRAINT fk_project_finance_member
  FOREIGN KEY (finance_member_id)
  REFERENCES app_user(id)
  ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_project_finance_member
  ON project(finance_member_id);