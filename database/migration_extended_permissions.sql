-- Extended Access Control Permissions Migration
-- Adds 23 new CRUD permissions for Business Unit, User, Project, Task, Comment, Attachment, and Organization management

-- Seed MANAGER defaults with all permissions (40 total)
INSERT INTO role_permission (role, permission_key, is_granted)
VALUES
  -- Organization
  ('MANAGER', 'VIEW_ORGANIZATION', false),
  ('MANAGER', 'EDIT_ORGANIZATION', false),
  ('MANAGER', 'DELETE_ORGANIZATION', false),
  ('MANAGER', 'MANAGE_USERS', false),
  ('MANAGER', 'MANAGE_BUSINESS_UNITS', false),

  -- Business Unit
  ('MANAGER', 'VIEW_BUSINESS_UNIT', true),
  ('MANAGER', 'CREATE_BUSINESS_UNIT', false),
  ('MANAGER', 'EDIT_BUSINESS_UNIT', false),
  ('MANAGER', 'DELETE_BUSINESS_UNIT', false),

  -- User
  ('MANAGER', 'VIEW_USER', true),
  ('MANAGER', 'EDIT_USER', false),
  ('MANAGER', 'EDIT_USER_ROLE', false),
  ('MANAGER', 'EDIT_USER_STATUS', false),

  -- Project (existing + new)
  ('MANAGER', 'CREATE_PROJECT', false),
  ('MANAGER', 'VIEW_PROJECT', true),
  ('MANAGER', 'EDIT_PROJECT', true),
  ('MANAGER', 'DELETE_PROJECT', false),
  ('MANAGER', 'EDIT_PROJECT_DETAILS', true),
  ('MANAGER', 'VIEW_PROJECT_DETAILS', true),
  ('MANAGER', 'EDIT_TECH_STACK', true),
  ('MANAGER', 'EDIT_DEPENDENCIES', true),
  ('MANAGER', 'VIEW_BUDGET', true),
  ('MANAGER', 'VIEW_FINANCE', true),
  ('MANAGER', 'VIEW_FINANCE_CODE', true),

  -- Task
  ('MANAGER', 'CREATE_TASK', true),
  ('MANAGER', 'EDIT_TASK', true),
  ('MANAGER', 'DELETE_TASK', false),

  -- Comment
  ('MANAGER', 'CREATE_COMMENT', true),
  ('MANAGER', 'EDIT_COMMENT', true),
  ('MANAGER', 'DELETE_COMMENT', false),

  -- Attachment
  ('MANAGER', 'VIEW_ATTACHMENT', true),
  ('MANAGER', 'CREATE_ATTACHMENT', true),
  ('MANAGER', 'DELETE_ATTACHMENT', false),

  -- Sprint
  ('MANAGER', 'MANAGE_SPRINT', true),

  -- Link
  ('MANAGER', 'MANAGE_LINKS', false),

  -- Leadership
  ('MANAGER', 'MANAGE_LEADERSHIP', false),

  -- Assignment
  ('MANAGER', 'ASSIGN_USERS', true),

  -- Reports
  ('MANAGER', 'VIEW_REPORTS', true),

  -- Time Tracking
  ('MANAGER', 'LOG_TIME', true)
ON CONFLICT (role, permission_key) DO UPDATE
SET is_granted = EXCLUDED.is_granted,
    updated_at = CURRENT_TIMESTAMP;

-- Seed USER defaults with limited permissions
INSERT INTO role_permission (role, permission_key, is_granted)
VALUES
  -- Organization
  ('USER', 'VIEW_ORGANIZATION', false),
  ('USER', 'EDIT_ORGANIZATION', false),
  ('USER', 'DELETE_ORGANIZATION', false),
  ('USER', 'MANAGE_USERS', false),
  ('USER', 'MANAGE_BUSINESS_UNITS', false),

  -- Business Unit
  ('USER', 'VIEW_BUSINESS_UNIT', true),
  ('USER', 'CREATE_BUSINESS_UNIT', false),
  ('USER', 'EDIT_BUSINESS_UNIT', false),
  ('USER', 'DELETE_BUSINESS_UNIT', false),

  -- User
  ('USER', 'VIEW_USER', true),
  ('USER', 'EDIT_USER', false),
  ('USER', 'EDIT_USER_ROLE', false),
  ('USER', 'EDIT_USER_STATUS', false),

  -- Project
  ('USER', 'CREATE_PROJECT', false),
  ('USER', 'VIEW_PROJECT', true),
  ('USER', 'EDIT_PROJECT', false),
  ('USER', 'DELETE_PROJECT', false),
  ('USER', 'EDIT_PROJECT_DETAILS', false),
  ('USER', 'VIEW_PROJECT_DETAILS', true),
  ('USER', 'EDIT_TECH_STACK', false),
  ('USER', 'EDIT_DEPENDENCIES', false),
  ('USER', 'VIEW_BUDGET', false),
  ('USER', 'VIEW_FINANCE', false),
  ('USER', 'VIEW_FINANCE_CODE', false),

  -- Task
  ('USER', 'CREATE_TASK', true),
  ('USER', 'EDIT_TASK', false),
  ('USER', 'DELETE_TASK', false),

  -- Comment
  ('USER', 'CREATE_COMMENT', true),
  ('USER', 'EDIT_COMMENT', true),
  ('USER', 'DELETE_COMMENT', false),

  -- Attachment
  ('USER', 'VIEW_ATTACHMENT', true),
  ('USER', 'CREATE_ATTACHMENT', true),
  ('USER', 'DELETE_ATTACHMENT', false),

  -- Sprint
  ('USER', 'MANAGE_SPRINT', false),

  -- Link
  ('USER', 'MANAGE_LINKS', false),

  -- Leadership
  ('USER', 'MANAGE_LEADERSHIP', false),

  -- Assignment
  ('USER', 'ASSIGN_USERS', false),

  -- Reports
  ('USER', 'VIEW_REPORTS', false),

  -- Time Tracking
  ('USER', 'LOG_TIME', true)
ON CONFLICT (role, permission_key) DO UPDATE
SET is_granted = EXCLUDED.is_granted,
    updated_at = CURRENT_TIMESTAMP;
