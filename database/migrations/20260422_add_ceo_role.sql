-- Migration: Add CEO system role
-- Date: 2026-04-22
-- Description: Inserts the CEO role with executive read-only permissions.
--              CEO can view projects, reports, leadership, business units,
--              tech stack, dependencies and sprint tabs but has NO access to
--              board task management (no EDIT_TASK, MANAGE_SPRINT, LOG_TIME).

BEGIN;

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
    ('VIEW_TECH_STACK'),
    ('EDIT_TECH_STACK'),
    ('VIEW_DEPENDENCIES'),
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
    ('VIEW_SPRINT'),
    ('MANAGE_SPRINT'),
    ('MANAGE_LINKS'),
    ('MANAGE_LEADERSHIP'),
    ('ASSIGN_USERS'),
    ('VIEW_REPORTS'),
    ('LOG_TIME'),
    ('VIEW_TEAM_TIMESHEETS'),
    ('VIEW_ACTIVITY_LOGS'),
    ('VIEW_BOARD'),
    ('VIEW_TASK'),
    ('VIEW_BACKLOG')
),
ceo_grants(permission_key, is_granted) AS (
  VALUES
    ('VIEW_ORGANIZATION',    true),
    ('EDIT_ORGANIZATION',    false),
    ('DELETE_ORGANIZATION',  false),
    ('MANAGE_USERS',         false),
    ('MANAGE_BUSINESS_UNITS',false),
    ('VIEW_BUSINESS_UNIT',   true),
    ('CREATE_BUSINESS_UNIT', false),
    ('EDIT_BUSINESS_UNIT',   false),
    ('DELETE_BUSINESS_UNIT', false),
    ('VIEW_USER',            true),
    ('EDIT_USER',            false),
    ('EDIT_USER_ROLE',       false),
    ('EDIT_USER_STATUS',     false),
    ('CREATE_PROJECT',       false),
    ('VIEW_PROJECT',         true),
    ('EDIT_PROJECT',         false),
    ('DELETE_PROJECT',       false),
    ('EDIT_PROJECT_DETAILS', false),
    ('VIEW_PROJECT_DETAILS', true),
    ('VIEW_TECH_STACK',      true),
    ('EDIT_TECH_STACK',      false),
    ('VIEW_DEPENDENCIES',    true),
    ('EDIT_DEPENDENCIES',    false),
    ('VIEW_BUDGET',          true),
    ('VIEW_FINANCE',         false),
    ('VIEW_FINANCE_CODE',    true),
    ('CREATE_TASK',          false),
    ('EDIT_TASK',            false),
    ('DELETE_TASK',          false),
    ('CREATE_COMMENT',       false),
    ('EDIT_COMMENT',         false),
    ('DELETE_COMMENT',       false),
    ('VIEW_ATTACHMENT',      false),
    ('CREATE_ATTACHMENT',    false),
    ('DELETE_ATTACHMENT',    false),
    ('VIEW_SPRINT',          true),
    ('MANAGE_SPRINT',        false),
    ('MANAGE_LINKS',         false),
    ('MANAGE_LEADERSHIP',    true),
    ('ASSIGN_USERS',         false),
    ('VIEW_REPORTS',         true),
    ('LOG_TIME',             false),
    ('VIEW_TEAM_TIMESHEETS', false),
    ('VIEW_ACTIVITY_LOGS',   true),
    ('VIEW_BOARD',           false),
    ('VIEW_TASK',            false),
    ('VIEW_BACKLOG',         true)
)
INSERT INTO "role" (key, name, description, permissions, is_system, is_active)
VALUES (
  'CEO',
  'Chief Executive Officer',
  'Executive read-only role. Full visibility into projects, finance, reports and leadership. No access to board task management.',
  (
    SELECT jsonb_object_agg(ap.permission_key, COALESCE(cg.is_granted, false))
    FROM all_permissions ap
    LEFT JOIN ceo_grants cg ON cg.permission_key = ap.permission_key
  ),
  true,
  true
)
ON CONFLICT (key) DO UPDATE
SET name        = EXCLUDED.name,
    description = EXCLUDED.description,
    permissions = EXCLUDED.permissions,
    is_system   = EXCLUDED.is_system,
    is_active   = EXCLUDED.is_active,
    updated_at  = CURRENT_TIMESTAMP;

COMMIT;
