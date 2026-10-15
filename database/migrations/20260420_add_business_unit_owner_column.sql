-- Migration: Add missing owner_id column to business_unit table
-- Date: 2026-04-20

ALTER TABLE business_unit
  ADD COLUMN IF NOT EXISTS owner_id UUID;

ALTER TABLE business_unit
  DROP CONSTRAINT IF EXISTS business_unit_owner_id_fkey;

ALTER TABLE business_unit
  ADD CONSTRAINT business_unit_owner_id_fkey
  FOREIGN KEY (owner_id)
  REFERENCES app_user(id)
  ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_business_unit_owner
  ON business_unit(owner_id);
