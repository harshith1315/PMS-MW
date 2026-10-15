-- Migration: Add VIEW_BOARD and VIEW_TASK permissions
-- Date: 2026-04-22
-- Description: Adds VIEW_BOARD and VIEW_TASK to the permission catalog and
--              grants them to all existing roles that previously had EDIT_TASK
--              access. CEO role is explicitly denied these permissions.

BEGIN;

-- ─── Update each system role's permissions JSONB ─────────────────────────────

-- ADMIN: grant all (already has everything, add the two new keys)
UPDATE "role"
SET permissions = permissions
  || jsonb_build_object('VIEW_BOARD', true, 'VIEW_TASK', true),
    updated_at = CURRENT_TIMESTAMP
WHERE key = 'ADMIN';

-- ORG_ADMIN: grant both
UPDATE "role"
SET permissions = permissions
  || jsonb_build_object('VIEW_BOARD', true, 'VIEW_TASK', true),
    updated_at = CURRENT_TIMESTAMP
WHERE key = 'ORG_ADMIN';

-- MANAGER: grant both
UPDATE "role"
SET permissions = permissions
  || jsonb_build_object('VIEW_BOARD', true, 'VIEW_TASK', true),
    updated_at = CURRENT_TIMESTAMP
WHERE key = 'MANAGER';

-- DEVELOPER: grant both
UPDATE "role"
SET permissions = permissions
  || jsonb_build_object('VIEW_BOARD', true, 'VIEW_TASK', true),
    updated_at = CURRENT_TIMESTAMP
WHERE key = 'DEVELOPER';

-- USER: grant both
UPDATE "role"
SET permissions = permissions
  || jsonb_build_object('VIEW_BOARD', true, 'VIEW_TASK', true),
    updated_at = CURRENT_TIMESTAMP
WHERE key = 'USER';

-- CEO: explicitly deny both (executive read-only, no board/task access)
UPDATE "role"
SET permissions = permissions
  || jsonb_build_object('VIEW_BOARD', false, 'VIEW_TASK', false),
    updated_at = CURRENT_TIMESTAMP
WHERE key = 'CEO';

-- ─── Update any custom (non-system) roles ────────────────────────────────────
-- Custom roles default to false for new permissions unless they had EDIT_TASK
UPDATE "role"
SET permissions = permissions
  || jsonb_build_object(
       'VIEW_BOARD', COALESCE((permissions->>'EDIT_TASK')::boolean, false),
       'VIEW_TASK',  COALESCE((permissions->>'EDIT_TASK')::boolean, false)
     ),
    updated_at = CURRENT_TIMESTAMP
WHERE is_system = false
  AND is_active = true;

COMMIT;
