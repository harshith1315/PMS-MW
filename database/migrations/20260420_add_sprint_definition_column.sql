-- Migration: Add missing definition column to sprint table
-- Date: 2026-04-20

BEGIN;

ALTER TABLE sprint
  ADD COLUMN IF NOT EXISTS definition TEXT;

COMMIT;
