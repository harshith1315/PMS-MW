-- Idempotent migration: seed VIEW_BUDGET, VIEW_FINANCE_CODE, VIEW_PROJECT_DETAILS
-- as granted by default for the MANAGER role.
-- DEVELOPER / USER default to false (not inserted = not granted).
-- ORG_ADMIN always gets all permissions via code, no rows needed.

INSERT INTO public.role_permission (role, permission_key, is_granted)
VALUES
  ('MANAGER', 'VIEW_BUDGET',         true),
  ('MANAGER', 'VIEW_FINANCE_CODE',   true),
  ('MANAGER', 'VIEW_PROJECT_DETAILS', true)
ON CONFLICT (role, permission_key) DO UPDATE
  SET is_granted = EXCLUDED.is_granted;
