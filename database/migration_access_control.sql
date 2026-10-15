-- Access Control schema for role defaults and user overrides

CREATE TABLE IF NOT EXISTS role_permission (
  role VARCHAR(50) NOT NULL,
  permission_key VARCHAR(100) NOT NULL,
  is_granted BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (role, permission_key)
);

CREATE TABLE IF NOT EXISTS user_permission (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  permission_key VARCHAR(100) NOT NULL,
  is_granted BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_permission_user FOREIGN KEY (user_id)
    REFERENCES app_user(id) ON DELETE CASCADE,
  CONSTRAINT uq_user_permission UNIQUE (user_id, permission_key)
);

CREATE INDEX IF NOT EXISTS idx_role_permission_role ON role_permission(role);
CREATE INDEX IF NOT EXISTS idx_user_permission_user_id ON user_permission(user_id);

-- Seed MANAGER defaults
INSERT INTO role_permission (role, permission_key, is_granted)
VALUES
  ('MANAGER', 'CREATE_PROJECT', false),
  ('MANAGER', 'VIEW_PROJECT', true),
  ('MANAGER', 'EDIT_TASK', true),
  ('MANAGER', 'DELETE_TASK', false),
  ('MANAGER', 'LOG_TIME', true),
  ('MANAGER', 'VIEW_FINANCE', true),
  ('MANAGER', 'MANAGE_SPRINT', true),
  ('MANAGER', 'ASSIGN_USERS', true),
  ('MANAGER', 'VIEW_REPORTS', true),
  ('MANAGER', 'MANAGE_LINKS', false),
  ('MANAGER', 'MANAGE_LEADERSHIP', false),
  ('MANAGER', 'EDIT_PROJECT_DETAILS', true),
  ('MANAGER', 'EDIT_TECH_STACK', true),
  ('MANAGER', 'EDIT_DEPENDENCIES', true)
ON CONFLICT (role, permission_key) DO UPDATE
SET is_granted = EXCLUDED.is_granted,
    updated_at = CURRENT_TIMESTAMP;

-- Seed USER defaults
INSERT INTO role_permission (role, permission_key, is_granted)
VALUES
  ('USER', 'CREATE_PROJECT', false),
  ('USER', 'VIEW_PROJECT', true),
  ('USER', 'EDIT_TASK', true),
  ('USER', 'DELETE_TASK', false),
  ('USER', 'LOG_TIME', true),
  ('USER', 'VIEW_FINANCE', false),
  ('USER', 'MANAGE_SPRINT', false),
  ('USER', 'ASSIGN_USERS', false),
  ('USER', 'VIEW_REPORTS', false),
  ('USER', 'MANAGE_LINKS', false),
  ('USER', 'MANAGE_LEADERSHIP', false),
  ('USER', 'EDIT_PROJECT_DETAILS', false),
  ('USER', 'EDIT_TECH_STACK', false),
  ('USER', 'EDIT_DEPENDENCIES', false)
ON CONFLICT (role, permission_key) DO UPDATE
SET is_granted = EXCLUDED.is_granted,
    updated_at = CURRENT_TIMESTAMP;
