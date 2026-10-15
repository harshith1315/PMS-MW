ALTER TABLE user_project_mapping
ADD COLUMN IF NOT EXISTS resource_type varchar(20) NOT NULL DEFAULT 'DEDICATED';

ALTER TABLE user_project_mapping
DROP CONSTRAINT IF EXISTS user_project_mapping_resource_type_check;

ALTER TABLE user_project_mapping
ADD CONSTRAINT user_project_mapping_resource_type_check
CHECK (resource_type IN ('SHARED', 'DEDICATED'));