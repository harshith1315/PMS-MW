-- Migration: Add new columns to project table for enhanced project creation
-- Date: 2026-04-10

-- Tab 1: Basic Information - New fields
ALTER TABLE project ADD COLUMN IF NOT EXISTS deliverable_type VARCHAR(50);
ALTER TABLE project ADD COLUMN IF NOT EXISTS execution_model VARCHAR(50);

-- Tab 2: Ownership & Governance - New fields
ALTER TABLE project ADD COLUMN IF NOT EXISTS delivery_manager_id UUID REFERENCES app_user(id);
ALTER TABLE project ADD COLUMN IF NOT EXISTS sponsor_id UUID REFERENCES app_user(id);
ALTER TABLE project ADD COLUMN IF NOT EXISTS created_by_id UUID REFERENCES app_user(id);
ALTER TABLE project ADD COLUMN IF NOT EXISTS approved_by_id UUID REFERENCES app_user(id);
ALTER TABLE project ADD COLUMN IF NOT EXISTS priority VARCHAR(20) DEFAULT 'MEDIUM';
ALTER TABLE project ADD COLUMN IF NOT EXISTS risk_level VARCHAR(20) DEFAULT 'LOW';

-- Tab 3: Timeline - New fields
ALTER TABLE project ADD COLUMN IF NOT EXISTS actual_start_date DATE;
ALTER TABLE project ADD COLUMN IF NOT EXISTS actual_end_date DATE;
ALTER TABLE project ADD COLUMN IF NOT EXISTS milestone_template VARCHAR(100);

-- Tab 4: Financials - New fields
ALTER TABLE project ADD COLUMN IF NOT EXISTS budget_approved NUMERIC(15,2);
ALTER TABLE project ADD COLUMN IF NOT EXISTS currency VARCHAR(10) DEFAULT 'INR';
ALTER TABLE project ADD COLUMN IF NOT EXISTS cost_center_id UUID;
ALTER TABLE project ADD COLUMN IF NOT EXISTS billing_type VARCHAR(20);
ALTER TABLE project ADD COLUMN IF NOT EXISTS contract_type VARCHAR(20);
ALTER TABLE project ADD COLUMN IF NOT EXISTS revenue NUMERIC(15,2);

-- Tab 6: Configuration (Agile/Kanban/Waterfall) - New fields
ALTER TABLE project ADD COLUMN IF NOT EXISTS sprint_duration INTEGER;
ALTER TABLE project ADD COLUMN IF NOT EXISTS iteration_start_day VARCHAR(20);
ALTER TABLE project ADD COLUMN IF NOT EXISTS estimation_unit VARCHAR(20);
ALTER TABLE project ADD COLUMN IF NOT EXISTS velocity_tracking BOOLEAN DEFAULT FALSE;
ALTER TABLE project ADD COLUMN IF NOT EXISTS wip_limits INTEGER;
ALTER TABLE project ADD COLUMN IF NOT EXISTS continuous_flow BOOLEAN DEFAULT FALSE;
ALTER TABLE project ADD COLUMN IF NOT EXISTS phase_template VARCHAR(100);
ALTER TABLE project ADD COLUMN IF NOT EXISTS stage_gates JSONB DEFAULT '[]'::jsonb;

-- Tab 7: Integrations - New fields
ALTER TABLE project ADD COLUMN IF NOT EXISTS document_repository VARCHAR(500);

-- Tab 8: Client & Contract Info - New fields
ALTER TABLE project ADD COLUMN IF NOT EXISTS client_spoc VARCHAR(255);
ALTER TABLE project ADD COLUMN IF NOT EXISTS contract_start_date DATE;
ALTER TABLE project ADD COLUMN IF NOT EXISTS contract_end_date DATE;

-- Tab 9: Additional Details - New fields
ALTER TABLE project ADD COLUMN IF NOT EXISTS comments TEXT;

-- Update project_type check constraint for new types
ALTER TABLE project DROP CONSTRAINT IF EXISTS chk_project_type_values;
ALTER TABLE project ADD CONSTRAINT chk_project_type_values CHECK (
  project_type IN ('SUPPORT', 'INTERNAL', 'CLIENT', 'MAINTENANCE', 'TIME_TRACKING') OR project_type IS NULL
);

-- Add check constraints for new enum fields
ALTER TABLE project DROP CONSTRAINT IF EXISTS chk_deliverable_type_values;
ALTER TABLE project ADD CONSTRAINT chk_deliverable_type_values CHECK (
  deliverable_type IN ('APPLICATION', 'SERVICE', 'APPLIANCE') OR deliverable_type IS NULL
);

ALTER TABLE project DROP CONSTRAINT IF EXISTS chk_execution_model_values;
ALTER TABLE project ADD CONSTRAINT chk_execution_model_values CHECK (
  execution_model IN ('AGILE', 'KANBAN', 'WATERFALL') OR execution_model IS NULL
);

ALTER TABLE project DROP CONSTRAINT IF EXISTS chk_priority_values;
ALTER TABLE project ADD CONSTRAINT chk_priority_values CHECK (
  priority IN ('HIGH', 'MEDIUM', 'LOW') OR priority IS NULL
);

ALTER TABLE project DROP CONSTRAINT IF EXISTS chk_risk_level_values;
ALTER TABLE project ADD CONSTRAINT chk_risk_level_values CHECK (
  risk_level IN ('HIGH', 'MEDIUM', 'LOW') OR risk_level IS NULL
);

ALTER TABLE project DROP CONSTRAINT IF EXISTS chk_currency_values;
ALTER TABLE project ADD CONSTRAINT chk_currency_values CHECK (
  currency IN ('INR', 'USD') OR currency IS NULL
);

ALTER TABLE project DROP CONSTRAINT IF EXISTS chk_billing_type_values;
ALTER TABLE project ADD CONSTRAINT chk_billing_type_values CHECK (
  billing_type IN ('FIXED', 'T_AND_M') OR billing_type IS NULL
);

ALTER TABLE project DROP CONSTRAINT IF EXISTS chk_contract_type_values;
ALTER TABLE project ADD CONSTRAINT chk_contract_type_values CHECK (
  contract_type IN ('INTERNAL', 'EXTERNAL') OR contract_type IS NULL
);

ALTER TABLE project DROP CONSTRAINT IF EXISTS chk_estimation_unit_values;
ALTER TABLE project ADD CONSTRAINT chk_estimation_unit_values CHECK (
  estimation_unit IN ('STORY_POINTS', 'HOURS') OR estimation_unit IS NULL
);

-- Create indexes for new foreign keys
CREATE INDEX IF NOT EXISTS idx_project_delivery_manager ON project(delivery_manager_id);
CREATE INDEX IF NOT EXISTS idx_project_sponsor ON project(sponsor_id);
CREATE INDEX IF NOT EXISTS idx_project_created_by ON project(created_by_id);

-- Update default status to DRAFT for new projects
ALTER TABLE project ALTER COLUMN status SET DEFAULT 'DRAFT';
