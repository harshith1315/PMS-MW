-- Chat persistence tables
CREATE TABLE IF NOT EXISTS chat_session (
  id uuid PRIMARY KEY,
  org_id uuid NOT NULL,
  user_id uuid NOT NULL,
  title varchar(255) NOT NULL DEFAULT 'New conversation',
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz NULL
);

CREATE INDEX IF NOT EXISTS idx_chat_session_org_user_active
  ON chat_session (org_id, user_id, ended_at);

CREATE INDEX IF NOT EXISTS idx_chat_session_org_user_started
  ON chat_session (org_id, user_id, started_at DESC);

CREATE TABLE IF NOT EXISTS chat_message (
  id uuid PRIMARY KEY,
  session_id uuid NOT NULL REFERENCES chat_session(id) ON DELETE CASCADE,
  role varchar(20) NOT NULL,
  text text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_chat_message_session_created
  ON chat_message (session_id, created_at);
