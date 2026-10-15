-- Idempotent migration: Business Unit table
-- Run once against any existing DB

CREATE TABLE IF NOT EXISTS public.business_unit (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    status character varying(50) DEFAULT 'ACTIVE'::character varying NOT NULL,
  owner_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT business_unit_pkey PRIMARY KEY (id)
);

ALTER TABLE public.business_unit OWNER TO postgres;

-- Unique constraint: one name per org
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'uq_business_unit_org_name'
  ) THEN
    ALTER TABLE ONLY public.business_unit
      ADD CONSTRAINT uq_business_unit_org_name UNIQUE (org_id, name);
  END IF;
END$$;

-- FK to app_user for owner mapping (nullable)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'business_unit_owner_id_fkey'
  ) THEN
    ALTER TABLE ONLY public.business_unit
      ADD CONSTRAINT business_unit_owner_id_fkey
      FOREIGN KEY (owner_id) REFERENCES public.app_user(id)
      ON DELETE SET NULL;
  END IF;
END$$;

-- FK to organization
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'business_unit_org_id_fkey'
  ) THEN
    ALTER TABLE ONLY public.business_unit
      ADD CONSTRAINT business_unit_org_id_fkey
      FOREIGN KEY (org_id) REFERENCES public.organization(id);
  END IF;
END$$;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_business_unit_org ON public.business_unit USING btree (org_id);
CREATE INDEX IF NOT EXISTS idx_business_unit_owner ON public.business_unit USING btree (owner_id);

-- Seed sample units for existing org  (idempotent - skip if name already exists)
INSERT INTO public.business_unit (org_id, name)
SELECT o.id, u.name
FROM public.organization o
CROSS JOIN (VALUES
  ('Engineering'),
  ('Product'),
  ('Design'),
  ('Marketing'),
  ('Operations')
) AS u(name)
WHERE o.status = 'ACTIVE'
ON CONFLICT (org_id, name) DO NOTHING;
