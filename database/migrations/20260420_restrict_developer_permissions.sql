-- Migration: Restrict Developer system-role permissions
-- Date: 2026-04-20

BEGIN;

UPDATE role
SET permissions =
  jsonb_set(
    jsonb_set(
      jsonb_set(
        jsonb_set(
          jsonb_set(
            jsonb_set(
              jsonb_set(
                COALESCE(permissions, '{}'::jsonb),
                '{CREATE_PROJECT}',
                'false'::jsonb,
                true
              ),
              '{VIEW_BUSINESS_UNIT}',
              'false'::jsonb,
              true
            ),
            '{CREATE_BUSINESS_UNIT}',
            'false'::jsonb,
            true
          ),
          '{EDIT_BUSINESS_UNIT}',
          'false'::jsonb,
          true
        ),
        '{DELETE_BUSINESS_UNIT}',
        'false'::jsonb,
        true
      ),
      '{MANAGE_BUSINESS_UNITS}',
      'false'::jsonb,
      true
    ),
    '{MANAGE_LEADERSHIP}',
    'false'::jsonb,
    true
  ),
  updated_at = CURRENT_TIMESTAMP
WHERE key = 'DEVELOPER'
  AND is_system = true;

COMMIT;
