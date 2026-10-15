-- Migration: Cut over from role_permission to role table with JSON permissions
-- Date: 2026-04-20

BEGIN;

CREATE TABLE IF NOT EXISTS "role" (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  permissions JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_system BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_role_key UNIQUE (key)
);

CREATE INDEX IF NOT EXISTS idx_role_key ON "role"(key);
CREATE INDEX IF NOT EXISTS idx_role_active ON "role"(is_active);

ALTER TABLE app_user
  ADD COLUMN IF NOT EXISTS role_id UUID;

WITH all_permissions(permission_key) AS (
  VALUES
    ('VIEW_ORGANIZATION'),
    ('EDIT_ORGANIZATION'),
    ('DELETE_ORGANIZATION'),
    ('MANAGE_USERS'),
    ('MANAGE_BUSINESS_UNITS'),
    ('VIEW_BUSINESS_UNIT'),
    ('CREATE_BUSINESS_UNIT'),
    ('EDIT_BUSINESS_UNIT'),
    ('DELETE_BUSINESS_UNIT'),
    ('VIEW_USER'),
    ('EDIT_USER'),
    ('EDIT_USER_ROLE'),
    ('EDIT_USER_STATUS'),
    ('CREATE_PROJECT'),
    ('VIEW_PROJECT'),
    ('EDIT_PROJECT'),
    ('DELETE_PROJECT'),
    ('EDIT_PROJECT_DETAILS'),
    ('VIEW_PROJECT_DETAILS'),
    ('EDIT_TECH_STACK'),
    ('EDIT_DEPENDENCIES'),
    ('VIEW_BUDGET'),
    ('VIEW_FINANCE'),
    ('VIEW_FINANCE_CODE'),
    ('CREATE_TASK'),
    ('EDIT_TASK'),
    ('DELETE_TASK'),
    ('CREATE_COMMENT'),
    ('EDIT_COMMENT'),
    ('DELETE_COMMENT'),
    ('VIEW_ATTACHMENT'),
    ('CREATE_ATTACHMENT'),
    ('DELETE_ATTACHMENT'),
    ('MANAGE_SPRINT'),
    ('MANAGE_LINKS'),
    ('MANAGE_LEADERSHIP'),
    ('ASSIGN_USERS'),
    ('VIEW_REPORTS'),
    ('LOG_TIME'),
    ('VIEW_TEAM_TIMESHEETS'),
    ('VIEW_ACTIVITY_LOGS')
), role_catalog(role_key, role_name, role_description, default_all) AS (
  VALUES
    ('ADMIN', 'Administrator', 'Global administrator role', true),
    ('ORG_ADMIN', 'Organization Admin', 'Organization administrator role', true),
    ('MANAGER', 'Manager', 'Default manager role', false),
    ('DEVELOPER', 'Developer', 'Default developer role', false),
    ('USER', 'User', 'Default user role', false)
)
INSERT INTO "role" (key, name, description, permissions, is_system, is_active)
SELECT
  rc.role_key,
  rc.role_name,
  rc.role_description,
  CASE
    WHEN rc.default_all THEN (
      SELECT jsonb_object_agg(ap.permission_key, true)
      FROM all_permissions ap
    )
    WHEN rc.role_key = 'DEVELOPER' THEN (
      SELECT jsonb_object_agg(ap.permission_key, COALESCE(rp.is_granted, false))
      FROM all_permissions ap
      LEFT JOIN role_permission rp
        ON rp.role = 'USER'
       AND rp.permission_key = ap.permission_key
    )
    ELSE (
      SELECT jsonb_object_agg(ap.permission_key, COALESCE(rp.is_granted, false))
      FROM all_permissions ap
      LEFT JOIN role_permission rp
        ON rp.role = rc.role_key
       AND rp.permission_key = ap.permission_key
    )
  END,
  true,
  true
FROM role_catalog rc
ON CONFLICT (key) DO UPDATE
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    permissions = EXCLUDED.permissions,
    is_system = EXCLUDED.is_system,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

UPDATE app_user u
SET role_id = r.id
FROM "role" r
WHERE u.role_id IS NULL
  AND r.key = COALESCE(NULLIF(u.role, ''), 'USER');

UPDATE app_user u
SET role_id = r.id
FROM "role" r
WHERE u.role_id IS NULL
  AND r.key = 'USER';

ALTER TABLE app_user
  DROP CONSTRAINT IF EXISTS fk_app_user_role_id;

ALTER TABLE app_user
  ADD CONSTRAINT fk_app_user_role_id
  FOREIGN KEY (role_id)
  REFERENCES "role"(id)
  ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_app_user_role_id
  ON app_user(role_id);

DROP TABLE IF EXISTS role_permission;

COMMIT;
