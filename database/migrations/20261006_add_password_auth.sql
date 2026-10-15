BEGIN;

ALTER TABLE app_user
  ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255),
  ADD COLUMN IF NOT EXISTS password_setup_token_hash VARCHAR(64),
  ADD COLUMN IF NOT EXISTS password_setup_expires_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_app_user_password_setup_token_hash
  ON app_user(password_setup_token_hash)
  WHERE password_setup_token_hash IS NOT NULL;

COMMIT;
