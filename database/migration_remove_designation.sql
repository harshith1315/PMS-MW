-- Migration: Remove designation column from app_user table
-- Date: 2026-04-07

ALTER TABLE public.app_user DROP COLUMN IF EXISTS designation;

-- Migration: Add business unit owner + project finance member
-- Date: 2026-04-07

ALTER TABLE public.business_unit
  ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES public.app_user(id);

ALTER TABLE public.project
  ADD COLUMN IF NOT EXISTS finance_member_id UUID REFERENCES public.app_user(id);
