-- Migration: Add VIEW_TECH_STACK, VIEW_DEPENDENCIES, VIEW_SPRINT, VIEW_BACKLOG permissions
-- Date: 2026-04-22
-- Description: Adds new view permissions into existing role JSON policies.

BEGIN;

-- System roles
UPDATE "role"
SET permissions = permissions || jsonb_build_object(
  'VIEW_TECH_STACK', true,
  'VIEW_DEPENDENCIES', true,
  'VIEW_SPRINT', true,
  'VIEW_BACKLOG', true
),
updated_at = CURRENT_TIMESTAMP
WHERE key IN ('ADMIN', 'ORG_ADMIN', 'MANAGER', 'DEVELOPER', 'USER', 'CEO')
  AND is_active = true;

-- Keep CEO restricted from board/task while still allowing tab visibility
UPDATE "role"
SET permissions = permissions || jsonb_build_object(
  'VIEW_BOARD', false,
  'VIEW_TASK', false,
  'VIEW_TECH_STACK', false,
  'VIEW_DEPENDENCIES', false,
  'VIEW_SPRINT', false,
  'VIEW_BACKLOG', false
),
updated_at = CURRENT_TIMESTAMP
WHERE key = 'CEO'
  AND is_active = true;

-- Custom roles: derive view permissions from nearest existing semantics
UPDATE "role"
SET permissions = permissions || jsonb_build_object(
  'VIEW_TECH_STACK', COALESCE((permissions->>'EDIT_TECH_STACK')::boolean, COALESCE((permissions->>'VIEW_PROJECT')::boolean, false)),
  'VIEW_DEPENDENCIES', COALESCE((permissions->>'EDIT_DEPENDENCIES')::boolean, COALESCE((permissions->>'VIEW_PROJECT')::boolean, false)),
  'VIEW_SPRINT', COALESCE((permissions->>'MANAGE_SPRINT')::boolean, COALESCE((permissions->>'VIEW_PROJECT')::boolean, false)),
  'VIEW_BACKLOG', COALESCE((permissions->>'VIEW_TASK')::boolean, COALESCE((permissions->>'VIEW_PROJECT')::boolean, false))
),
updated_at = CURRENT_TIMESTAMP
WHERE is_system = false
  AND is_active = true;

COMMIT;
