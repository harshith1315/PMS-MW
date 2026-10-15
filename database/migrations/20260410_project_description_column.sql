-- Migration: Add description column to project table
-- Date: 2026-04-10

-- Add description column
ALTER TABLE project ADD COLUMN IF NOT EXISTS description TEXT;

-- Change cost_center_id from UUID to VARCHAR (if it was UUID)
-- First, drop any foreign key constraints if they exist
-- ALTER TABLE project DROP CONSTRAINT IF EXISTS project_cost_center_id_fkey;

-- Change the column type
ALTER TABLE project ALTER COLUMN cost_center_id TYPE VARCHAR(100);

-- Update check constraints for new enum values (if they exist)
-- Drop old constraints
ALTER TABLE project DROP CONSTRAINT IF EXISTS project_deliverable_type_check;
ALTER TABLE project DROP CONSTRAINT IF EXISTS project_execution_model_check;
ALTER TABLE project DROP CONSTRAINT IF EXISTS project_priority_check;
ALTER TABLE project DROP CONSTRAINT IF EXISTS project_currency_check;
ALTER TABLE project DROP CONSTRAINT IF EXISTS project_billing_type_check;
ALTER TABLE project DROP CONSTRAINT IF EXISTS project_contract_type_check;
ALTER TABLE project DROP CONSTRAINT IF EXISTS project_estimation_unit_check;

-- Add new constraints with updated enum values
ALTER TABLE project ADD CONSTRAINT project_deliverable_type_check 
  CHECK (deliverable_type IS NULL OR deliverable_type IN ('PRODUCT', 'PROJECT', 'SERVICE', 'SUPPORT'));

ALTER TABLE project ADD CONSTRAINT project_execution_model_check 
  CHECK (execution_model IS NULL OR execution_model IN ('AGILE', 'KANBAN', 'WATERFALL', 'HYBRID'));

ALTER TABLE project ADD CONSTRAINT project_priority_check 
  CHECK (priority IS NULL OR priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'));

ALTER TABLE project ADD CONSTRAINT project_currency_check 
  CHECK (currency IS NULL OR currency IN ('USD', 'EUR', 'GBP', 'INR', 'AUD'));

ALTER TABLE project ADD CONSTRAINT project_billing_type_check 
  CHECK (billing_type IS NULL OR billing_type IN ('FIXED_PRICE', 'TIME_AND_MATERIAL', 'RETAINER', 'NOT_BILLABLE'));

ALTER TABLE project ADD CONSTRAINT project_contract_type_check 
  CHECK (contract_type IS NULL OR contract_type IN ('FIXED', 'RENEWABLE', 'ONGOING'));

ALTER TABLE project ADD CONSTRAINT project_estimation_unit_check 
  CHECK (estimation_unit IS NULL OR estimation_unit IN ('STORY_POINTS', 'HOURS', 'DAYS', 'T_SHIRT'));

-- Verify the changes
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'project' 
AND column_name IN ('description', 'cost_center_id');
