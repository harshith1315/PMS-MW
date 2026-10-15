-- Activity log table for organization audit trail
CREATE TABLE IF NOT EXISTS public.activity_log (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    actor_user_id uuid,
    actor_name character varying(255),
    actor_email character varying(255),
    method character varying(10) NOT NULL,
    resource_type character varying(100) NOT NULL,
    resource_id uuid,
    action_type character varying(50) NOT NULL,
    message text NOT NULL,
    request_path character varying(500) NOT NULL,
    ip_address character varying(100),
    user_agent character varying(500),
    metadata jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_activity_log PRIMARY KEY (id),
    CONSTRAINT fk_activity_log_org FOREIGN KEY (org_id) REFERENCES public.organization(id),
    CONSTRAINT fk_activity_log_actor FOREIGN KEY (actor_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_activity_log_org_created_at
    ON public.activity_log (org_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_activity_log_actor_user_id
    ON public.activity_log (actor_user_id);

CREATE INDEX IF NOT EXISTS idx_activity_log_action_type
    ON public.activity_log (action_type);
