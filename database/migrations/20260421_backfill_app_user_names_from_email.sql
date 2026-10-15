-- Migration: Backfill existing app_user names from email local-part
-- Date: 2026-04-21

WITH derived_names AS (
  SELECT
    id,
    NULLIF(
      INITCAP(
        LOWER(
          REGEXP_REPLACE(
            REGEXP_REPLACE(
              SPLIT_PART(email, '@', 1),
              '([[:lower:][:digit:]])([[:upper:]])',
              '\1 \2',
              'g'
            ),
            '[._-]+',
            ' ',
            'g'
          )
        )
      ),
      ''
    ) AS derived_name,
    SPLIT_PART(email, '@', 1) AS email_local_part
  FROM app_user
)
UPDATE app_user AS target
SET name = source.derived_name
FROM derived_names AS source
WHERE target.id = source.id
  AND source.derived_name IS NOT NULL
  AND (
    target.name IS NULL
    OR BTRIM(target.name) = ''
    OR LOWER(BTRIM(target.name)) = LOWER(source.email_local_part)
  );