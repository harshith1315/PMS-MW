--
-- PostgreSQL database dump
--

\restrict 25Qw007LUiCUVKssGtJbpHeqb1xWfYCvxl05AEaiv8kfl1ao5dGDxpvusXhXXO9

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-13 11:21:54

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 19179)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5412 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 19190)
-- Name: app_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_user (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255),
    role character varying(50) DEFAULT 'USER'::character varying,
    is_leader boolean DEFAULT false,
    is_manager boolean DEFAULT false,
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.app_user OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 19204)
-- Name: attachment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attachment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    task_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    file_type character varying(100),
    file_size bigint,
    s3_key character varying(500) NOT NULL,
    uploaded_by uuid,
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.attachment OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 19217)
-- Name: business_unit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.business_unit (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    status character varying(50) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    owner_id uuid
);


ALTER TABLE public.business_unit OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 19227)
-- Name: chat_message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_message (
    id uuid NOT NULL,
    session_id uuid NOT NULL,
    role character varying(20) NOT NULL,
    text text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.chat_message OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 19238)
-- Name: chat_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_session (
    id uuid NOT NULL,
    org_id uuid NOT NULL,
    user_id uuid NOT NULL,
    title character varying(255) DEFAULT 'New conversation'::character varying NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone
);


ALTER TABLE public.chat_session OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 19248)
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    recipient_id uuid NOT NULL,
    task_id uuid NOT NULL,
    type character varying(50) NOT NULL,
    title character varying(255) NOT NULL,
    message text NOT NULL,
    metadata jsonb,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.notification OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 19266)
-- Name: organization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    azure_tenant_id character varying(255),
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.organization OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 19276)
-- Name: platform_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.platform_user (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255),
    role character varying(50) DEFAULT 'PLATFORM_ADMIN'::character varying,
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.platform_user OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 19287)
-- Name: project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    project_code character varying(50) NOT NULL,
    business_unit character varying(100),
    manager_id uuid,
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    finance_code character varying(50),
    budget numeric(15,2),
    kickoff_date date,
    start_date date,
    end_date date,
    project_type character varying(20),
    client_name character varying(255),
    client_location character varying(255),
    purpose text,
    cost_management text,
    tech_stack jsonb DEFAULT '[]'::jsonb NOT NULL,
    dependencies jsonb DEFAULT '[]'::jsonb NOT NULL,
    finance_member_id uuid,
    CONSTRAINT chk_project_budget_non_negative CHECK (((budget IS NULL) OR (budget >= (0)::numeric))),
    CONSTRAINT chk_project_type_values CHECK ((((project_type)::text = ANY (ARRAY[('WEB'::character varying)::text, ('MOBILE'::character varying)::text, ('BOTH'::character varying)::text])) OR (project_type IS NULL)))
);


ALTER TABLE public.project OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 19305)
-- Name: project_cost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_cost (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    project_id uuid NOT NULL,
    cost_type character varying(50) NOT NULL,
    amount numeric(10,2) NOT NULL,
    description text,
    cost_date date NOT NULL,
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.project_cost OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 19319)
-- Name: project_link; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_link (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    project_id uuid NOT NULL,
    link_type character varying(50) NOT NULL,
    url character varying(500) NOT NULL,
    title character varying(255),
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.project_link OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 19332)
-- Name: project_task_sequence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_task_sequence (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    project_id uuid NOT NULL,
    last_sequence integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.project_task_sequence OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 19340)
-- Name: resource_cost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resource_cost (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    user_id uuid NOT NULL,
    hourly_rate numeric(10,2) NOT NULL,
    effective_from date NOT NULL,
    effective_to date,
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.resource_cost OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 19351)
-- Name: role_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permission (
    role character varying(50) NOT NULL,
    permission_key character varying(100) NOT NULL,
    is_granted boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.role_permission OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 19362)
-- Name: sprint; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sprint (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    project_id uuid NOT NULL,
    name character varying(255),
    start_date date,
    end_date date,
    status character varying(50) DEFAULT 'PLANNED'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    goal text,
    definition text
);


ALTER TABLE public.sprint OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 19372)
-- Name: tag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tag (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    color character varying(20),
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tag OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 19381)
-- Name: task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    project_id uuid NOT NULL,
    sprint_id uuid,
    task_code character varying(50),
    title character varying(255) NOT NULL,
    description text,
    task_type character varying(50),
    status character varying(50) DEFAULT 'TODO'::character varying,
    priority character varying(50) DEFAULT 'MEDIUM'::character varying,
    assigned_to uuid,
    created_by uuid,
    due_date date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    output_description text,
    blocked_by uuid,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    epic_id uuid,
    story_id uuid
);


ALTER TABLE public.task OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 19395)
-- Name: task_comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_comment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    task_id uuid NOT NULL,
    user_id uuid NOT NULL,
    parent_comment_id uuid,
    comment_text text NOT NULL,
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone
);


ALTER TABLE public.task_comment OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 19408)
-- Name: task_link; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_link (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    source_task_id uuid NOT NULL,
    target_task_id uuid NOT NULL,
    link_type character varying(50) NOT NULL,
    created_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.task_link OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 19418)
-- Name: task_tag_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_tag_mapping (
    task_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.task_tag_mapping OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 19423)
-- Name: time_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.time_log (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    user_id uuid NOT NULL,
    task_id uuid NOT NULL,
    project_id uuid NOT NULL,
    log_date date NOT NULL,
    minutes integer NOT NULL,
    description text,
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT time_log_minutes_check CHECK (((minutes > 0) AND (minutes <= 720)))
);


ALTER TABLE public.time_log OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 19439)
-- Name: timesheet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.timesheet (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    user_id uuid NOT NULL,
    entry_date date NOT NULL,
    project_name character varying(255) NOT NULL,
    task_details text NOT NULL,
    status character varying(50) DEFAULT 'IN_PROGRESS'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.timesheet OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 19454)
-- Name: user_daily_summary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_daily_summary (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    user_id uuid NOT NULL,
    summary_date date NOT NULL,
    total_minutes integer DEFAULT 0,
    color character varying(20) DEFAULT 'RED'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone
);


ALTER TABLE public.user_daily_summary OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 19465)
-- Name: user_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_permission (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    permission_key character varying(100) NOT NULL,
    is_granted boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.user_permission OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 19478)
-- Name: user_project_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_project_mapping (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    user_id uuid NOT NULL,
    project_id uuid NOT NULL,
    project_role character varying(50) DEFAULT 'MEMBER'::character varying NOT NULL,
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    allocated_bandwidth integer DEFAULT 0,
    approval_status character varying(50) DEFAULT 'PENDING'::character varying,
    requested_by_user_id uuid,
    approved_by_user_id uuid,
    approved_at timestamp without time zone,
    CONSTRAINT user_project_mapping_allocated_bandwidth_check CHECK (((allocated_bandwidth >= 0) AND (allocated_bandwidth <= 100)))
);


ALTER TABLE public.user_project_mapping OWNER TO postgres;

--
-- TOC entry 5382 (class 0 OID 19190)
-- Dependencies: 220
-- Data for Name: app_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_user (id, org_id, email, name, role, is_leader, is_manager, status, created_at) FROM stdin;
b762cce3-dac1-4aa0-bc38-a8488eaf994f	1d105d8b-95d8-411e-9844-b6683e8b7f51	princy.joseph@bonbloc.com	princy	ORG_ADMIN	f	f	ACTIVE	2026-03-19 14:23:34.808615
b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	manager@acme.com	Jane	ORG_ADMIN	f	f	ACTIVE	2026-03-18 20:14:20.348231
b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	developer1@acme.com	Alice	USER	f	f	ACTIVE	2026-03-18 20:14:20.348231
b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	developer2@acme.com	Bob	USER	f	f	ACTIVE	2026-03-18 20:14:20.348231
b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	qa@acme.com	Charlie	USER	f	f	ACTIVE	2026-03-18 20:14:20.348231
65b2f9f4-a049-4766-b6f6-4ecca8fb8de7	1d105d8b-95d8-411e-9844-b6683e8b7f51	santhosh.sankar@bonbloc.com	Santhosh	USER	f	f	ACTIVE	2026-03-19 17:57:36.529875
b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	alicia.antony@bonbloc.com	Alicia	USER	f	f	ACTIVE	2026-03-18 20:14:20.348231
fbfbe066-9918-412c-835d-f92a30ac44e4	1d105d8b-95d8-411e-9844-b6683e8b7f51	narayanareddy.mallidi@bonbloc.com	Narayana	USER	t	t	ACTIVE	2026-03-27 10:02:54.511576
1400ccae-fcaa-452d-9d61-30afb052b604	1d105d8b-95d8-411e-9844-b6683e8b7f51	komali.avirneni@bonbloc.com	komali.avirneni	MANAGER	f	f	ACTIVE	2026-04-01 11:45:59.188686
d4c27066-b249-42ef-ac9d-bccbd7cced4e	1d105d8b-95d8-411e-9844-b6683e8b7f51	test@gmail.com	sai ram	MANAGER	t	t	DEACTIVATED	2026-03-26 23:56:13.01749
e8f598e6-df54-46ee-bf25-ccadaee8681c	1d105d8b-95d8-411e-9844-b6683e8b7f51	harshith@example.com	Kanumuri Harshith	USER	t	t	DEACTIVATED	2026-04-07 18:31:21.344863
57617275-688c-4353-9faa-b561834044d8	1d105d8b-95d8-411e-9844-b6683e8b7f51	sairam.mathi@bonbloc.com	sai ram	MANAGER	t	t	ACTIVE	2026-04-09 22:16:51.949285
6d7b3010-5f27-4495-b7b1-85d6f734657f	1d105d8b-95d8-411e-9844-b6683e8b7f51	pranathi@bonbloc.com	Pranathi	USER	t	t	DEACTIVATED	2026-03-26 23:01:27.496598
edb1541e-efee-435d-a4cd-6e7da392464a	1d105d8b-95d8-411e-9844-b6683e8b7f51	harshith.kanumuri@bonbloc.com	Harshith Kanumuri	ORG_ADMIN	t	t	ACTIVE	2026-03-26 22:48:28.989947
011e345e-7736-44cb-82c5-f3ebac81971e	1d105d8b-95d8-411e-9844-b6683e8b7f51	krishnapranathi.dande@bonbloc.com	Krishna Pranathi	ORG_ADMIN	t	t	ACTIVE	2026-04-09 22:17:52.654766
a6909bd5-59bb-480a-b0a2-d5e33775d45e	1d105d8b-95d8-411e-9844-b6683e8b7f51	saieswarkumar.anupoju@bonbloc.com	Sai Eswar Kumar Anupoju	MANAGER	f	f	ACTIVE	2026-04-10 11:43:32.387661
\.


--
-- TOC entry 5383 (class 0 OID 19204)
-- Dependencies: 221
-- Data for Name: attachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attachment (id, org_id, task_id, file_name, file_type, file_size, s3_key, uploaded_by, status, created_at) FROM stdin;
0b432db8-80e5-4f85-a370-609448813852	1d105d8b-95d8-411e-9844-b6683e8b7f51	86d4af01-800a-435d-ac7c-d4594c1f495b	Screenshot 2026-03-28 135646.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/86d4af01-800a-435d-ac7c-d4594c1f495b/83071b02-a25f-4221-bd47-b11516a8e4da.png	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-28 14:11:59.09885
\.


--
-- TOC entry 5384 (class 0 OID 19217)
-- Dependencies: 222
-- Data for Name: business_unit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.business_unit (id, org_id, name, status, created_at, owner_id) FROM stdin;
04b47b7b-b06c-4441-acd1-7aea89aadde6	1d105d8b-95d8-411e-9844-b6683e8b7f51	Operations	ACTIVE	2026-04-01 11:16:35.682725	\N
36c4f874-5aa5-4a99-9361-911fea0e5eb9	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Engineering	ACTIVE	2026-04-01 11:16:35.682725	\N
0e7662da-81ac-476c-bf8f-1a91275cdd50	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Product	ACTIVE	2026-04-01 11:16:35.682725	\N
a186ebe2-6aa2-4bc7-b4b6-6961c610c5da	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Design	ACTIVE	2026-04-01 11:16:35.682725	\N
7e0db4ce-21ee-49ee-8327-2bf012dc7937	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Marketing	ACTIVE	2026-04-01 11:16:35.682725	\N
03e7d5d0-4240-462c-a84d-156ca43874ac	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Operations	ACTIVE	2026-04-01 11:16:35.682725	\N
ee83e77f-7d5e-4499-b5cb-7d93f05d435d	1d105d8b-95d8-411e-9844-b6683e8b7f51	Marketing	INACTIVE	2026-04-01 11:16:35.682725	\N
f497a687-70c3-470a-a7af-e70cc224a1ea	1d105d8b-95d8-411e-9844-b6683e8b7f51	Engineering	INACTIVE	2026-04-01 11:16:35.682725	\N
bc9d4299-678d-4759-a824-499a2b56a171	1d105d8b-95d8-411e-9844-b6683e8b7f51	Design	INACTIVE	2026-04-01 11:16:35.682725	\N
55bb480b-297c-424f-bf05-8ab471366e0a	1d105d8b-95d8-411e-9844-b6683e8b7f51	Public Sector	ACTIVE	2026-04-01 11:31:51.957415	d4c27066-b249-42ef-ac9d-bccbd7cced4e
325e8743-5704-40e0-ae85-11519c117b6f	1d105d8b-95d8-411e-9844-b6683e8b7f51	Product	INACTIVE	2026-04-01 11:16:35.682725	\N
\.


--
-- TOC entry 5385 (class 0 OID 19227)
-- Dependencies: 223
-- Data for Name: chat_message; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_message (id, session_id, role, text, created_at) FROM stdin;
731185fe-5400-422a-879f-1ee7e8b37a29	879c8c1c-8026-41b1-8d33-deca2b7e5c31	user	hi	2026-04-10 12:06:20.271203+05:30
2326740b-a827-46ce-8913-ab56ac1b5443	879c8c1c-8026-41b1-8d33-deca2b7e5c31	assistant	Hi Sai, how can I assist you today?	2026-04-10 12:06:20.271203+05:30
78d294f5-e684-4715-8b0b-5fba19f50ae4	879c8c1c-8026-41b1-8d33-deca2b7e5c31	user	hi	2026-04-10 12:11:31.763037+05:30
5984661c-9f3a-40a6-a66e-c9bb116e2d05	879c8c1c-8026-41b1-8d33-deca2b7e5c31	assistant	Hi Sai, how can I assist you today?	2026-04-10 12:11:31.763037+05:30
bb292f58-1149-4393-bcf6-e9a81590406d	879c8c1c-8026-41b1-8d33-deca2b7e5c31	user	what are my tasks	2026-04-10 12:11:53.751848+05:30
008906f9-4812-45eb-9fc9-6dc6900235e2	879c8c1c-8026-41b1-8d33-deca2b7e5c31	assistant	I need more information to provide your tasks. Can you tell me which project or team you belong to?	2026-04-10 12:11:53.751848+05:30
f6ca9a76-f975-4a04-9d6a-d99d59d863d2	879c8c1c-8026-41b1-8d33-deca2b7e5c31	user	hi	2026-04-10 12:14:43.55205+05:30
49444f24-9e25-42fc-ac1f-39f2d50e0e2e	879c8c1c-8026-41b1-8d33-deca2b7e5c31	assistant	Hi Sai, how can I assist you today?	2026-04-10 12:14:43.55205+05:30
049575b4-1868-4660-9523-11c9e31d9aca	879c8c1c-8026-41b1-8d33-deca2b7e5c31	user	hi	2026-04-10 12:14:50.154865+05:30
a0f989b9-408f-4072-87c2-f16289e8f4d2	879c8c1c-8026-41b1-8d33-deca2b7e5c31	assistant	Hi Sai, how can I assist you today?	2026-04-10 12:14:50.154865+05:30
3917ea68-5507-4fc0-b613-0027303925ef	879c8c1c-8026-41b1-8d33-deca2b7e5c31	user	i want to chnage user permisions how can y	2026-04-10 12:15:35.69015+05:30
9df567a3-1277-489a-a887-33fe983a8023	879c8c1c-8026-41b1-8d33-deca2b7e5c31	assistant	To change user permissions, you can go to the user management section of the PMS. From there, select the user whose permissions you want to modify and adjust the settings accordingly. If you need further assistance, let me know!	2026-04-10 12:15:35.69015+05:30
703a8d03-9a7e-49f2-8ab2-5a82d7e8494c	879c8c1c-8026-41b1-8d33-deca2b7e5c31	user	i	2026-04-10 12:19:06.854932+05:30
92194ef2-9e62-4790-b6bf-7a623600917d	879c8c1c-8026-41b1-8d33-deca2b7e5c31	assistant	To change user permissions, go to the user management section of the PMS, select the user, and adjust the settings as needed.	2026-04-10 12:19:06.854932+05:30
b5355740-17d3-4df3-88dc-9a1236915c93	879c8c1c-8026-41b1-8d33-deca2b7e5c31	user	i	2026-04-10 12:23:56.987035+05:30
025b2188-a346-487c-97d5-e16323f6ef42	879c8c1c-8026-41b1-8d33-deca2b7e5c31	assistant	I need a little more detail to help you correctly. Please type a full question, for example: 'show my tasks for this week'.	2026-04-10 12:23:56.987035+05:30
4938d5c9-b95f-46c6-8ec5-f4b584dfc902	5933e265-f980-4f4a-9a9d-faacc584d262	user	hi	2026-04-10 12:25:53.652966+05:30
8481196a-a1ee-408f-b2b3-91f44dab5a09	5933e265-f980-4f4a-9a9d-faacc584d262	assistant	Hi Sai, how can I assist you today?	2026-04-10 12:25:53.652966+05:30
21e30136-98a0-4070-bf43-666262d24df7	5933e265-f980-4f4a-9a9d-faacc584d262	user	hi	2026-04-10 12:26:00.279651+05:30
fb95716b-1348-4d1e-b414-5a4add4fa8eb	5933e265-f980-4f4a-9a9d-faacc584d262	assistant	Hi Sai, how can I assist you today?	2026-04-10 12:26:00.279651+05:30
d1cb0247-c6ec-47e5-aee2-841e246bf12f	f00c0c6c-e3f1-4a7f-8057-d30c2ff5ed6e	user	how are you	2026-04-10 12:27:58.609633+05:30
03d69d9a-cc63-4556-9f5b-4127c005e4bf	f00c0c6c-e3f1-4a7f-8057-d30c2ff5ed6e	assistant	I am doing well, Sai. How can I assist you today?	2026-04-10 12:27:58.609633+05:30
48be7c74-e78b-49b2-9d4e-5a5e6488d64d	62881412-20b1-42d3-8b6f-0042ac43936f	user	hi	2026-04-10 12:29:02.7789+05:30
b938096b-48e4-404c-b307-c84d430d460a	62881412-20b1-42d3-8b6f-0042ac43936f	assistant	Hi Sai, how can I assist you today?	2026-04-10 12:29:02.7789+05:30
3789c6c6-2c0e-4830-ade5-b026c062df11	ceb60be1-c124-4146-ac3d-171092ed56d5	user	hi	2026-04-10 12:30:22.781438+05:30
4cf67b85-8811-45ee-94aa-4a1a253c3cd5	ceb60be1-c124-4146-ac3d-171092ed56d5	assistant	Hi Sai, how can I assist you today?	2026-04-10 12:30:22.781438+05:30
aa43aba3-a4b4-495a-b32b-08f7f8ef0785	dbbdbe94-00b9-464c-a62b-2027d7ada78a	user	what are high priority tasks i have to complete	2026-04-10 12:42:46.328587+05:30
8de67410-9c0f-4235-b401-5fbc62230259	dbbdbe94-00b9-464c-a62b-2027d7ada78a	assistant	Hi Sai,\n\nBased on the information provided, there are no specific high-priority tasks listed for you to complete. Please check your task list or project management system for updates.	2026-04-10 12:42:46.328587+05:30
9893ec5c-8ce8-44a5-9b73-051db78ba267	dbbdbe94-00b9-464c-a62b-2027d7ada78a	user	then are there any task to do ,give with dead line	2026-04-10 12:43:21.005515+05:30
22e7b3ea-1732-41d0-99a7-ffada7669e84	dbbdbe94-00b9-464c-a62b-2027d7ada78a	assistant	Based on the information provided, there are no specific high-priority tasks listed for you to complete. Please check your task list or project management system for updates.	2026-04-10 12:43:21.005515+05:30
065eaf5b-4cdb-4c3c-9582-690a0f462a19	dbbdbe94-00b9-464c-a62b-2027d7ada78a	user	what are the task i have to complete	2026-04-10 12:44:04.624455+05:30
5122a3d8-b0e8-441c-b2ad-baf17bdd570b	dbbdbe94-00b9-464c-a62b-2027d7ada78a	assistant	Based on the information provided, there are no specific tasks listed for you to complete at this time. Please check your task list or project management system for updates.	2026-04-10 12:44:04.624455+05:30
66259856-550e-4cad-80e9-25f2771fdbe3	21f714e9-c140-4c4b-8fb7-516a73142928	user	How many tasks are assigned to me this week?	2026-04-10 12:45:25.327746+05:30
dc8059c4-8cc4-43fe-9df3-2f2a82469c57	21f714e9-c140-4c4b-8fb7-516a73142928	assistant	3	2026-04-10 12:45:25.327746+05:30
a0f5d37e-80c6-4dd9-8a39-4a4c34258b43	21f714e9-c140-4c4b-8fb7-516a73142928	user	what are those and help to how can i complete those	2026-04-10 12:46:00.967412+05:30
74369596-6b8e-4fa7-a620-2f8cc3c2ac02	21f714e9-c140-4c4b-8fb7-516a73142928	assistant	You have one task assigned: R&D Validation rules. To complete it, you need to review and implement the validation rules for the R&D process. The priority is medium, so it should be addressed when you have some availability but isn't urgent.	2026-04-10 12:46:00.967412+05:30
c30f906d-abf9-463d-9f93-7df51855e563	21f714e9-c140-4c4b-8fb7-516a73142928	user	hi	2026-04-10 12:49:53.298328+05:30
8ae94169-7a4b-4cb8-a381-741087b67860	21f714e9-c140-4c4b-8fb7-516a73142928	assistant	You have one task assigned: R&D Validation rules. To complete it, you need to review and implement the validation rules for the R&D process. The priority is medium, so address it when you have some availability. If you need any guidance on the specific rules, feel free to ask!	2026-04-10 12:49:53.298328+05:30
11820301-466a-4c5e-a7d5-90f10a6415b6	5bafd5dd-1472-471d-925d-60b93f648559	user	hi	2026-04-10 12:50:13.870809+05:30
1bbb90a3-5b42-4288-ad33-46257cab1cc1	5bafd5dd-1472-471d-925d-60b93f648559	assistant	Hello Sai, how can I assist you today?	2026-04-10 12:50:13.870809+05:30
c182a4f3-0161-43b7-b3d3-f78116d8f7a8	5bafd5dd-1472-471d-925d-60b93f648559	user	how many task i have to do	2026-04-10 12:50:31.271579+05:30
adfc5065-d2b8-43f7-bb84-de6219923e6d	5bafd5dd-1472-471d-925d-60b93f648559	assistant	You have one task assigned to you.	2026-04-10 12:50:31.271579+05:30
bd7baab8-7aca-48b1-944f-fe23fe7c4533	5bafd5dd-1472-471d-925d-60b93f648559	user	whats your name	2026-04-10 12:52:18.755937+05:30
14655427-0157-4029-a79f-02056a64bc21	5bafd5dd-1472-471d-925d-60b93f648559	assistant	My name is Myra.	2026-04-10 12:52:18.755937+05:30
528f81e8-b8aa-4fe0-9ded-23a5547d4375	5bafd5dd-1472-471d-925d-60b93f648559	user	what are the active projects we have	2026-04-10 12:53:11.954644+05:30
2b764f82-2fea-44d9-9a7f-b32ba37f11d3	5bafd5dd-1472-471d-925d-60b93f648559	assistant	You have the following active projects:\n- LMS [PROJ_101] | BU: Onelign Software Applications\n- API Integration [API] | BU: Engineering\n- Website Redesign [WEB] | BU: Marketing\n- Mobile App Development [MOB] | BU: Engineering\n- COld Chain [PROJ-123] | BU: Onelign Software Applications\n- FPO [FPO-101] | BU: Onelign Software Applications\n- LMS-PH [PROJ-1237] | BU: Public Sector\n- CEL [PROJ-1234] | BU: Onelign Software Applications	2026-04-10 12:53:11.954644+05:30
7d6f73b9-3442-4bec-86f5-793e834a2677	5bafd5dd-1472-471d-925d-60b93f648559	user	what are the active projects we have	2026-04-10 12:53:53.53755+05:30
905e355a-8e37-4be4-812e-f5827a8a401c	5bafd5dd-1472-471d-925d-60b93f648559	assistant	You have the following active projects:\n- LMS [PROJ_101] | BU: Onelign Software Applications\n- API Integration [API] | BU: Engineering\n- Website Redesign [WEB] | BU: Marketing\n- Mobile App Development [MOB] | BU: Engineering\n- COld Chain [PROJ-123] | BU: Onelign Software Applications\n- FPO [FPO-101] | BU: Onelign Software Applications\n- LMS-PH [PROJ-1237] | BU: Public Sector\n- CEL [PROJ-1234] | BU: Onelign Software Applications	2026-04-10 12:53:53.53755+05:30
59af84bc-fad1-4e29-a6d3-19a1cb1021f2	5bafd5dd-1472-471d-925d-60b93f648559	user	hi	2026-04-10 14:07:34.775244+05:30
691a88c8-452f-47c2-a4d7-0db0466bbaf1	5bafd5dd-1472-471d-925d-60b93f648559	assistant	how can I assist you today?	2026-04-10 14:07:34.775244+05:30
c0cea793-fca4-4aaa-947c-cd0427db512f	5bafd5dd-1472-471d-925d-60b93f648559	user	hi	2026-04-10 14:33:36.044833+05:30
ced780ea-ac14-4856-88f8-c704e7ecbc11	5bafd5dd-1472-471d-925d-60b93f648559	assistant	how can I assist you today?	2026-04-10 14:33:36.044833+05:30
68390aff-9d9d-437f-993d-b736871a888d	5bafd5dd-1472-471d-925d-60b93f648559	user	hi	2026-04-10 14:49:44.073041+05:30
ecd9a5bf-cf60-41ad-8953-2fb3bed42216	5bafd5dd-1472-471d-925d-60b93f648559	assistant	You have the following active projects:\n- LMS [PROJ_101] | BU: Onelign Software Applications\n- API Integration [API] | BU: Engineering\n- Website Redesign [WEB] | BU: Marketing\n- Mobile App Development [MOB] | BU: Engineering\n- COld Chain [PROJ-123] | BU: Onelign Software Applications\n- FPO [FPO-101] | BU: Onelign Software Applications\n- LMS-PH [PROJ-1237] | BU: Public Sector\n- CEL [PROJ-1234] | BU: Onelign Software Applications	2026-04-10 14:49:44.073041+05:30
dbc24ac5-0cb9-4ec2-9235-f0ac79a02362	eb77d1bf-db1e-4dd8-ac0a-6e7ed1dd8157	user	hi	2026-04-10 14:56:13.252045+05:30
57ec83bf-b568-4c48-8fb3-de6b951a3766	eb77d1bf-db1e-4dd8-ac0a-6e7ed1dd8157	assistant	Hello Sai, how can I assist you today?	2026-04-10 14:56:13.252045+05:30
5642252a-b93c-4fd0-bc7b-cc03af4f200d	eb77d1bf-db1e-4dd8-ac0a-6e7ed1dd8157	user	hi	2026-04-10 15:01:47.499413+05:30
52afa0d8-3df4-4c73-8448-8c0bc0a50db5	eb77d1bf-db1e-4dd8-ac0a-6e7ed1dd8157	assistant	How can I assist you today, Sai?	2026-04-10 15:01:47.499413+05:30
903e34bd-6210-42e9-b776-351155310176	eb77d1bf-db1e-4dd8-ac0a-6e7ed1dd8157	user	hi	2026-04-10 15:15:17.068497+05:30
e46e7e9c-8c67-4e1a-bdd7-fd498d5045cd	eb77d1bf-db1e-4dd8-ac0a-6e7ed1dd8157	assistant	How can I assist you today, Sai?	2026-04-10 15:15:17.068497+05:30
ff2c782c-6049-4767-817d-120a2f1edaab	263eb688-1710-41ed-9f42-28ec1b9b0daf	user	hi	2026-04-10 15:33:09.857808+05:30
b366d120-29a1-47d2-8c51-db0be091c907	263eb688-1710-41ed-9f42-28ec1b9b0daf	assistant	Hi Sai,	2026-04-10 15:33:09.857808+05:30
2d7fc8e0-e160-41a3-b22a-297b9f983fef	c0b7e1a4-3052-4917-a164-ab116fb5917d	user	hi	2026-04-10 15:40:17.873156+05:30
fa32b09c-3bc1-44e9-a0b0-af570f3c8eb7	c0b7e1a4-3052-4917-a164-ab116fb5917d	assistant	Hi Sai,	2026-04-10 15:40:17.873156+05:30
3e9f31bf-7282-4be4-8d5c-6d9bc30801fd	c0b7e1a4-3052-4917-a164-ab116fb5917d	user	hi	2026-04-10 16:22:18.379361+05:30
d9fa48ec-e3e9-41b4-a75f-27aa58d2b21b	c0b7e1a4-3052-4917-a164-ab116fb5917d	assistant	Sai, how can I assist you today?	2026-04-10 16:22:18.379361+05:30
e75bf1c3-1b23-472e-bd7b-10d3f38b854b	c0b7e1a4-3052-4917-a164-ab116fb5917d	user	how are you	2026-04-10 16:24:55.037065+05:30
e9fa6eff-f213-4542-bbb6-c8d7e9acc6cc	c0b7e1a4-3052-4917-a164-ab116fb5917d	assistant	Sai, how can I assist you today?	2026-04-10 16:24:55.037065+05:30
773119a1-2e93-4a2f-a339-492b3f90f141	c0b7e1a4-3052-4917-a164-ab116fb5917d	user	hi	2026-04-10 16:38:56.627506+05:30
cb97c939-9e20-452c-8aa0-a75734bb8deb	c0b7e1a4-3052-4917-a164-ab116fb5917d	assistant	Sai, how can I assist you today?	2026-04-10 16:38:56.627506+05:30
6639270f-c469-4822-865c-4aa5ef21ba84	c0b7e1a4-3052-4917-a164-ab116fb5917d	user	what is your name?	2026-04-10 16:39:17.002295+05:30
c730678c-dcf1-43fb-a596-a86a813901ae	c0b7e1a4-3052-4917-a164-ab116fb5917d	assistant	Myra	2026-04-10 16:39:17.002295+05:30
53922de0-fb9e-4be9-9d43-be78278d59d4	c0b7e1a4-3052-4917-a164-ab116fb5917d	user	i want to know about user lists	2026-04-10 16:39:56.575632+05:30
459a6929-c931-42f7-8e5f-8545764698bf	c0b7e1a4-3052-4917-a164-ab116fb5917d	assistant	Sai, what would you like to know about user lists?	2026-04-10 16:39:56.575632+05:30
362dd91c-c88e-4080-8a17-83c01aee875d	c0b7e1a4-3052-4917-a164-ab116fb5917d	user	platform users list	2026-04-10 16:42:17.453474+05:30
c1f65eaf-0ead-4391-99e3-07e5f9d680e8	c0b7e1a4-3052-4917-a164-ab116fb5917d	assistant	Sai, here is the list of users:\n\n- Alice | developer1@acme.com | Role: USER | Status: ACTIVE\n- Alicia | alicia.antony@bonbloc.com | Role: USER | Status: ACTIVE\n- Bob | developer2@acme.com | Role: USER | Status: ACTIVE\n- Charlie | qa@acme.com | Role: USER | Status: ACTIVE\n- Harshith Kanumuri | harshith.kanumuri@bonbloc.com | Role: ORG_ADMIN | Status: ACTIVE | Leader | Manager\n- Jane | manager@acme.com | Role: ORG_ADMIN | Status: ACTIVE\n- komali.avirneni | komali.avirneni@bonbloc.com | Role: MANAGER | Status: ACTIVE\n- Krishna Pranathi | krishnapranathi.dande@bonbloc.com | Role: MANAGER | Status: ACTIVE | Leader | Manager\n- Narayana | narayanareddy.mallidi@bonbloc.com | Role: USER | Status: ACTIVE | Leader | Manager\n- Princy | princy.joseph@bonbloc.com | Role: ORG_ADMIN | Status: ACTIVE\n- Sai Eswar Kumar Anupoju | saieswarkumar.anupoju@bonbloc.com | Role: ORG_ADMIN | Status: ACTIVE\n- Sai Ram | sairam.mathi@bonbloc.com | Role: MANAGER | Status: ACTIVE | Leader | Manager\n- Santhosh |	2026-04-10 16:42:17.453474+05:30
1909fef1-bfb8-49d2-9a7f-904f63350ffa	4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	user	who many user are there	2026-04-11 10:54:26.2243+05:30
5cc052b3-5808-42c4-a570-279d1b56d426	4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	assistant	Myra	2026-04-11 10:54:26.2243+05:30
32171816-6852-4ff0-8a09-24f30304725b	4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	user	no of user in the application	2026-04-11 10:54:52.240089+05:30
768aba4e-37e5-45a7-be2f-5d7bd4f42228	4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	assistant	Myra	2026-04-11 10:54:52.240089+05:30
0b38a7b1-5c92-429c-8b10-c8eecc8f2e95	4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	user	who is the leader ship team	2026-04-11 10:55:22.699685+05:30
3c817d94-ff2e-4bf7-a648-36c7ae9912be	4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	assistant	Myra\n\nThe leadership team consists of:\n- Harshith Kanumuri (ORG_ADMIN)\n- Krishna Pranathi (MANAGER)\n- Narayana (USER)\n- sai ram (MANAGER)	2026-04-11 10:55:22.699685+05:30
cac35f0b-68ae-40e5-8ca8-c3c1f2d69693	4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	user	who can i change a user role	2026-04-11 10:56:06.465701+05:30
638b4608-cacf-4d5f-b3d9-0c53366eacbb	4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	assistant	Myra\n\nThe leadership team includes:\n- Harshith Kanumuri (ORG_ADMIN)\n- Krishna Pranathi (MANAGER)	2026-04-11 10:56:06.465701+05:30
f9aebdbd-0d7d-49d7-94d2-0c73de184011	4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	user	i want to change Narayana role premission from user to manager who can i do it	2026-04-11 10:57:01.631252+05:30
8d89814b-5505-40eb-baa6-879045705c64	4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	assistant	Narayana's role permission can be changed by Harshith Kanumuri (ORG_ADMIN) or Krishna Pranathi (MANAGER).	2026-04-11 10:57:01.631252+05:30
817db864-0540-42b6-a658-be944fda5070	53eb8d09-1169-45ee-a948-30dfa31334e7	user	How many tasks are assigned to me this week?	2026-04-11 10:57:31.592647+05:30
78b3da00-c915-4600-9910-d4fe44b29180	53eb8d09-1169-45ee-a948-30dfa31334e7	assistant	Myra, there are 2 tasks assigned to you this week.	2026-04-11 10:57:31.592647+05:30
61464f41-8a73-4dbc-aed3-221a7c5ce0fb	53eb8d09-1169-45ee-a948-30dfa31334e7	user	what are those tasks	2026-04-11 10:57:56.740508+05:30
76018ad3-22f6-4032-a287-d250a497feff	53eb8d09-1169-45ee-a948-30dfa31334e7	assistant	Myra, the tasks assigned to you this week are:\n\n1. R&D Animation for login page\n2. Tenant Configuration\n3. Tenant Management/platform	2026-04-11 10:57:56.740508+05:30
d98c724b-95cc-44fb-ac5c-7d2a94e07504	4d979c71-6373-4255-9763-c75497661504	user	How many tasks are assigned to me this week?	2026-04-11 11:45:54.828568+05:30
86c5887e-e28d-4a8a-b286-505ab68e5f51	4d979c71-6373-4255-9763-c75497661504	assistant	Myra, there are 2 tasks assigned to you this week.	2026-04-11 11:45:54.828568+05:30
108fe8d9-bc2e-4a4d-8d13-5d72f17c1abf	4d979c71-6373-4255-9763-c75497661504	user	what are the 2 tasks	2026-04-11 11:46:23.590826+05:30
83793dc3-8cac-41ab-8bba-eaeba8b03a21	4d979c71-6373-4255-9763-c75497661504	assistant	Myra, the 2 tasks assigned to you this week are:\n- R&D Animation for login page\n- Tenant Configuration	2026-04-11 11:46:23.590826+05:30
\.


--
-- TOC entry 5386 (class 0 OID 19238)
-- Dependencies: 224
-- Data for Name: chat_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_session (id, org_id, user_id, title, started_at, ended_at) FROM stdin;
879c8c1c-8026-41b1-8d33-deca2b7e5c31	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-10 12:06:20.189405+05:30	2026-04-10 12:24:23.564+05:30
5933e265-f980-4f4a-9a9d-faacc584d262	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-10 12:25:53.474079+05:30	2026-04-10 12:26:34.639+05:30
f00c0c6c-e3f1-4a7f-8057-d30c2ff5ed6e	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	how are you	2026-04-10 12:27:49.100777+05:30	2026-04-10 12:28:58.368+05:30
62881412-20b1-42d3-8b6f-0042ac43936f	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-10 12:29:02.709779+05:30	2026-04-10 12:29:54.389+05:30
ceb60be1-c124-4146-ac3d-171092ed56d5	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-10 12:30:22.718086+05:30	2026-04-10 12:42:04.073+05:30
dbbdbe94-00b9-464c-a62b-2027d7ada78a	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	what are high priority tasks i have to complete	2026-04-10 12:42:34.513861+05:30	2026-04-10 12:44:33.311+05:30
21f714e9-c140-4c4b-8fb7-516a73142928	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	How many tasks are assigned to me this week?	2026-04-10 12:45:19.628296+05:30	2026-04-10 12:50:05.601+05:30
5bafd5dd-1472-471d-925d-60b93f648559	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-10 12:50:07.678354+05:30	2026-04-10 14:48:37.22+05:30
eb77d1bf-db1e-4dd8-ac0a-6e7ed1dd8157	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-10 14:55:21.790425+05:30	2026-04-10 15:13:50.623+05:30
263eb688-1710-41ed-9f42-28ec1b9b0daf	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-10 15:32:43.10198+05:30	2026-04-10 15:33:23.142+05:30
c0b7e1a4-3052-4917-a164-ab116fb5917d	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-10 15:39:58.600251+05:30	\N
4a0bc8d5-2f85-49da-9c6b-cf755eb9e529	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	who many user are there	2026-04-11 10:54:18.389306+05:30	2026-04-11 10:57:14.339+05:30
53eb8d09-1169-45ee-a948-30dfa31334e7	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	How many tasks are assigned to me this week?	2026-04-11 10:57:19.91903+05:30	2026-04-11 10:58:08.707+05:30
4d979c71-6373-4255-9763-c75497661504	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	How many tasks are assigned to me this week?	2026-04-11 11:45:35.383126+05:30	2026-04-11 11:46:29.769+05:30
\.


--
-- TOC entry 5387 (class 0 OID 19248)
-- Dependencies: 225
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, recipient_id, task_id, type, title, message, metadata, is_read, created_at, updated_at) FROM stdin;
7454bc41-0d36-44a3-b9e7-a2523e8bc19a	b762cce3-dac1-4aa0-bc38-a8488eaf994f	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	TASK_BLOCKED	Task Blocked	Task "Login Page" has been blocked by Harshith Kanumuri	{"taskCode": "PROJ-1237-1", "blockedBy": "edb1541e-efee-435d-a4cd-6e7da392464a", "taskTitle": "Login Page", "blockerName": "Harshith Kanumuri"}	f	2026-04-09 17:53:36.587035	2026-04-09 17:53:36.587035
9df09bb7-e20f-49b1-b783-387ea30a507e	b762cce3-dac1-4aa0-bc38-a8488eaf994f	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	TASK_BLOCKED	Task Blocked	Task "Login Page" has been blocked by Harshith Kanumuri	{"taskCode": "PROJ-1237-1", "blockedBy": "edb1541e-efee-435d-a4cd-6e7da392464a", "taskTitle": "Login Page", "blockerName": "Harshith Kanumuri"}	f	2026-04-09 22:20:04.128823	2026-04-09 22:20:04.128823
e054f494-918e-41cf-afcc-1141805901d3	b762cce3-dac1-4aa0-bc38-a8488eaf994f	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	TASK_BLOCKED	Task Blocked	Task "Login Page" has been blocked by Harshith Kanumuri	{"taskCode": "PROJ-1237-1", "blockedBy": "edb1541e-efee-435d-a4cd-6e7da392464a", "taskTitle": "Login Page", "blockerName": "Harshith Kanumuri"}	f	2026-04-09 22:22:00.232744	2026-04-09 22:22:00.232744
9219cf88-50c6-4ca0-a539-b6172f9171bf	edb1541e-efee-435d-a4cd-6e7da392464a	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	TASK_BLOCKED	Task Blocked	Task "R&D Animation for login page" has been blocked by Harshith Kanumuri	{"taskCode": "PROJ-1237-3", "blockedBy": "edb1541e-efee-435d-a4cd-6e7da392464a", "taskTitle": "R&D Animation for login page", "blockerName": "Harshith Kanumuri"}	t	2026-04-11 12:07:12.46244	2026-04-11 12:07:58.689083
\.


--
-- TOC entry 5388 (class 0 OID 19266)
-- Dependencies: 226
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization (id, name, azure_tenant_id, status, created_at) FROM stdin;
1d105d8b-95d8-411e-9844-b6683e8b7f51	BONbLOC Technologies	7915d0a8-0a13-4824-ba52-43a1ad694c42	ACTIVE	2026-03-19 14:23:34.808615
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Acme Corporation	null	ACTIVE	2026-03-18 20:14:20.339403
\.


--
-- TOC entry 5389 (class 0 OID 19276)
-- Dependencies: 227
-- Data for Name: platform_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.platform_user (id, email, name, role, status, created_at) FROM stdin;
d2c3a954-c0f7-4718-92be-e97449206874	oviiyadominic@gmail.com	Oviiya Dominic	ADMIN	ACTIVE	2026-03-19 14:28:31.763376
\.


--
-- TOC entry 5390 (class 0 OID 19287)
-- Dependencies: 228
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project (id, org_id, name, project_code, business_unit, manager_id, status, created_at, finance_code, budget, kickoff_date, start_date, end_date, project_type, client_name, client_location, purpose, cost_management, tech_stack, dependencies, finance_member_id) FROM stdin;
c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Mobile App Development	MOB	Engineering	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N
c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Website Redesign	WEB	Marketing	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N
c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	API Integration	API	Engineering	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N
a3f75871-11e5-49ba-9fb7-2659f7283f2a	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS	PROJ_101	Onelign Software Applications	b762cce3-dac1-4aa0-bc38-a8488eaf994f	ACTIVE	2026-03-19 17:48:25.948931	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N
6564025c-356b-4e87-96e6-44360bde99f0	1d105d8b-95d8-411e-9844-b6683e8b7f51	FPO	FPO-101	Onelign Software Applications	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-19 18:10:00.907041	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N
cc556634-367e-4ff9-a331-a000d92c89e3	1d105d8b-95d8-411e-9844-b6683e8b7f51	COld Chain	PROJ-123	Onelign Software Applications	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-19 18:31:10.938558	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N
d901321d-b502-4a26-8cb7-483ca57ba66d	1d105d8b-95d8-411e-9844-b6683e8b7f51	CEL	PROJ-1234	Onelign Software Applications	6d7b3010-5f27-4495-b7b1-85d6f734657f	ACTIVE	2026-03-26 23:01:53.185218	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N
71bb0f85-cdde-469a-900d-e8761da76e45	1d105d8b-95d8-411e-9844-b6683e8b7f51	test	PROJ-1235	Onelign Software Applications	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-26 23:02:59.560141	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N
eeb797e6-385c-4376-a607-9663e4313e60	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS	PROJ-1236	Onelign Software Applications	fbfbe066-9918-412c-835d-f92a30ac44e4	ACTIVE	2026-03-27 10:03:20.826154	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N
10ac6760-95d0-4f5d-acb5-52126ff0c7e1	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS-PH	PROJ-1237	Public Sector	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-27 12:19:05.01159	FIN1234	1000000.00	2026-04-01	2026-04-01	2027-04-01	BOTH	PH	PH	\N	\N	["React JS"]	["SMS Gate way", "SMTP"]	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
\.


--
-- TOC entry 5391 (class 0 OID 19305)
-- Dependencies: 229
-- Data for Name: project_cost; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_cost (id, org_id, project_id, cost_type, amount, description, cost_date, status, created_at) FROM stdin;
\.


--
-- TOC entry 5392 (class 0 OID 19319)
-- Dependencies: 230
-- Data for Name: project_link; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_link (id, org_id, project_id, link_type, url, title, status, created_at) FROM stdin;
e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	REPOSITORY	https://github.com/acme/mobile-app	GitHub Repository	ACTIVE	2026-03-18 20:14:20.388767
e2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DOCUMENTATION	https://docs.acme.com/mobile	Project Documentation	ACTIVE	2026-03-18 20:14:20.388767
e3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DESIGN	https://figma.com/file/xxx	Figma Designs	ACTIVE	2026-03-18 20:14:20.388767
e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	REPOSITORY	https://github.com/acme/website	GitHub Repository	ACTIVE	2026-03-18 20:14:20.388767
e5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	REPOSITORY	https://github.com/acme/api	GitHub Repository	ACTIVE	2026-03-18 20:14:20.388767
e6eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DOCUMENTATION	https://api.acme.com/docs	API Documentation	ACTIVE	2026-03-18 20:14:20.388767
\.


--
-- TOC entry 5393 (class 0 OID 19332)
-- Dependencies: 231
-- Data for Name: project_task_sequence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_task_sequence (id, project_id, last_sequence, created_at) FROM stdin;
d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	5	2026-03-18 20:14:20.362464
d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	3	2026-03-18 20:14:20.362464
d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2	2026-03-18 20:14:20.362464
a5e71526-3737-49dc-b526-bf387e79775d	a3f75871-11e5-49ba-9fb7-2659f7283f2a	0	2026-03-19 17:48:25.948931
91c798db-b385-4277-a57c-860e1bcf4919	6564025c-356b-4e87-96e6-44360bde99f0	0	2026-03-19 18:10:00.907041
62a04d0e-faca-41ab-89d0-cf8a94b4980c	cc556634-367e-4ff9-a331-a000d92c89e3	1	2026-03-19 18:31:10.938558
1dfa76a9-d52f-4977-9b89-29166f343a22	d901321d-b502-4a26-8cb7-483ca57ba66d	0	2026-03-26 23:01:53.185218
79f7343b-516b-4e49-8fda-490079c1d6e5	71bb0f85-cdde-469a-900d-e8761da76e45	0	2026-03-26 23:02:59.560141
cd3557cb-7581-473f-b0c3-396eea5c9434	eeb797e6-385c-4376-a607-9663e4313e60	0	2026-03-27 10:03:20.826154
207a9436-a4b3-48d3-82d1-61b42740693b	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	8	2026-03-27 12:19:05.01159
\.


--
-- TOC entry 5394 (class 0 OID 19340)
-- Dependencies: 232
-- Data for Name: resource_cost; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.resource_cost (id, org_id, user_id, hourly_rate, effective_from, effective_to, status, created_at) FROM stdin;
d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	150.00	2026-01-01	\N	ACTIVE	2026-03-18 20:14:20.386239
d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	120.00	2026-01-01	\N	ACTIVE	2026-03-18 20:14:20.386239
d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	85.00	2026-01-01	\N	ACTIVE	2026-03-18 20:14:20.386239
d4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	90.00	2026-01-01	\N	ACTIVE	2026-03-18 20:14:20.386239
d5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	75.00	2026-01-01	\N	ACTIVE	2026-03-18 20:14:20.386239
\.


--
-- TOC entry 5395 (class 0 OID 19351)
-- Dependencies: 233
-- Data for Name: role_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permission (role, permission_key, is_granted, created_at, updated_at) FROM stdin;
MANAGER	CREATE_PROJECT	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	VIEW_PROJECT	t	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	EDIT_TASK	t	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	DELETE_TASK	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	LOG_TIME	t	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	VIEW_FINANCE	t	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	MANAGE_SPRINT	t	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	ASSIGN_USERS	t	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	VIEW_REPORTS	t	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	MANAGE_LINKS	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	MANAGE_LEADERSHIP	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
MANAGER	EDIT_PROJECT_DETAILS	t	2026-04-01 10:59:10.673115	2026-04-01 10:59:10.673115
MANAGER	EDIT_TECH_STACK	t	2026-04-01 10:59:10.673115	2026-04-01 10:59:10.673115
MANAGER	EDIT_DEPENDENCIES	t	2026-04-01 10:59:10.673115	2026-04-01 10:59:10.673115
USER	CREATE_PROJECT	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	VIEW_PROJECT	t	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	EDIT_TASK	t	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	DELETE_TASK	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	LOG_TIME	t	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	VIEW_FINANCE	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	MANAGE_SPRINT	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	ASSIGN_USERS	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	VIEW_REPORTS	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	MANAGE_LINKS	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	MANAGE_LEADERSHIP	f	2026-03-31 11:37:13.525336	2026-04-01 10:59:10.673115
USER	EDIT_PROJECT_DETAILS	f	2026-04-01 10:59:10.673115	2026-04-01 10:59:10.673115
USER	EDIT_TECH_STACK	f	2026-04-01 10:59:10.673115	2026-04-01 10:59:10.673115
USER	EDIT_DEPENDENCIES	f	2026-04-01 10:59:10.673115	2026-04-01 10:59:10.673115
\.


--
-- TOC entry 5396 (class 0 OID 19362)
-- Dependencies: 234
-- Data for Name: sprint; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sprint (id, project_id, name, start_date, end_date, status, created_at, goal, definition) FROM stdin;
f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sprint 1 - Foundation	2026-03-01	2026-03-15	COMPLETED	2026-03-18 20:14:20.367127	\N	\N
f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sprint 2 - Auth Module	2026-03-16	2026-03-30	ACTIVE	2026-03-18 20:14:20.367127	\N	\N
f3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sprint 3 - Dashboard	2026-03-31	2026-04-14	PLANNED	2026-03-18 20:14:20.367127	\N	\N
f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sprint 1 - Homepage	2026-03-01	2026-03-15	ACTIVE	2026-03-18 20:14:20.367127	\N	\N
f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sprint 1 - Core APIs	2026-03-10	2026-03-24	ACTIVE	2026-03-18 20:14:20.367127	\N	\N
d697d764-de47-4525-8567-bb08f4edf96d	6564025c-356b-4e87-96e6-44360bde99f0	Sprint 1	2026-03-22	2026-03-27	PLANNED	2026-03-19 18:22:17.123305	Develop	\N
f4fad8f2-9b37-43bc-a021-62675674efb2	cc556634-367e-4ff9-a331-a000d92c89e3	Sprint 1	2026-03-20	2026-03-21	PLANNED	2026-03-20 10:16:38.351924	\N	\N
1caa5563-3120-430a-a398-dacffb2123f9	cc556634-367e-4ff9-a331-a000d92c89e3	Sprint 1	2026-03-19	2026-03-19	ACTIVE	2026-03-19 18:31:36.785698	Develop	\N
87c72569-6047-4ce3-ae14-5a401d0c0f3d	71bb0f85-cdde-469a-900d-e8761da76e45	Sprint 2	2026-03-28	2026-03-31	COMPLETED	2026-03-26 23:14:20.116282	\N	\N
37f0972a-3887-4618-93f1-11f453e673e5	71bb0f85-cdde-469a-900d-e8761da76e45	Sprint 1	2026-03-27	2026-04-27	PLANNED	2026-03-27 00:04:03.877572	\N	\N
cd43809a-31ed-4d2e-8925-70892ba59078	71bb0f85-cdde-469a-900d-e8761da76e45	Sprint 1	2026-03-26	2026-04-26	ACTIVE	2026-03-26 23:07:46.283323	\N	\N
4343a450-7655-41c0-835a-7bba93cc7aeb	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	S 1	2026-03-27	2026-04-27	ACTIVE	2026-03-27 16:54:18.139567	\N	\N
b4c1e7a2-4bc1-4b75-aea7-a84f2559e4e9	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	S2	2026-04-11	2026-04-28	PLANNED	2026-04-10 00:27:46.829507	Version1	\N
5a519088-1bbf-4d6e-8960-f3c62bb9e851	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	S4	2026-04-09	2026-04-10	PLANNED	2026-04-10 00:39:35.848874	test	\N
e6e582cb-6487-4bcd-a8db-a782e3de2f29	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	S3	2026-04-10	2026-04-16	PLANNED	2026-04-10 00:33:49.936718	test	test
\.


--
-- TOC entry 5397 (class 0 OID 19372)
-- Dependencies: 235
-- Data for Name: tag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tag (id, org_id, name, color, status, created_at) FROM stdin;
668ef1fa-f43a-476f-9fee-6a0bba660211	1d105d8b-95d8-411e-9844-b6683e8b7f51	Feature	#21A1F1	ACTIVE	2026-04-09 23:48:50.026625
ea289523-868a-45fc-b189-e40fb00b4335	1d105d8b-95d8-411e-9844-b6683e8b7f51	Bug	#F44235	ACTIVE	2026-04-09 23:48:50.093259
3953b9be-1f99-4482-bd60-568373068dbd	1d105d8b-95d8-411e-9844-b6683e8b7f51	Tech debt	#FF9800	ACTIVE	2026-04-09 23:48:50.115386
71eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Frontend	#3498DB	ACTIVE	2026-03-18 20:14:20.369254
72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Backend	#2ECC71	ACTIVE	2026-03-18 20:14:20.369254
73eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Database	#9B59B6	ACTIVE	2026-03-18 20:14:20.369254
74eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	UI/UX	#E74C3C	ACTIVE	2026-03-18 20:14:20.369254
75eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Security	#F39C12	ACTIVE	2026-03-18 20:14:20.369254
76eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Performance	#1ABC9C	ACTIVE	2026-03-18 20:14:20.369254
\.


--
-- TOC entry 5398 (class 0 OID 19381)
-- Dependencies: 236
-- Data for Name: task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task (id, org_id, project_id, sprint_id, task_code, title, description, task_type, status, priority, assigned_to, created_by, due_date, created_at, output_description, blocked_by, updated_at, epic_id, story_id) FROM stdin;
81eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-1	Setup project structure	Initialize React Native project with TypeScript	STORY	DONE	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-10	2026-03-18 20:14:20.370886	\N	\N	2026-04-09 17:25:15.523881	\N	\N
82eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-2	Configure CI/CD pipeline	Setup GitHub Actions for automated builds	STORY	DONE	MEDIUM	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-12	2026-03-18 20:14:20.370886	\N	\N	2026-04-09 17:25:15.523881	\N	\N
83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-3	Implement login screen	Create login UI with email and password fields	STORY	IN_PROGRESS	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-20	2026-03-18 20:14:20.370886	\N	\N	2026-04-09 17:25:15.523881	\N	\N
84eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-4	Integrate Azure AD auth	Implement Microsoft authentication	STORY	TODO	HIGH	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-25	2026-03-18 20:14:20.370886	\N	\N	2026-04-09 17:25:15.523881	\N	\N
85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-5	Login button not responsive on iOS	Touch event not firing consistently	BUG	TODO	CRITICAL	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-22	2026-03-18 20:14:20.370886	\N	\N	2026-04-09 17:25:15.523881	\N	\N
86eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	WEB-1	Design homepage mockup	Create Figma designs for new homepage	STORY	DONE	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-08	2026-03-18 20:14:20.370886	\N	\N	2026-04-09 17:25:15.523881	\N	\N
87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	WEB-2	Implement hero section	Build responsive hero component	STORY	IN_PROGRESS	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-12	2026-03-18 20:14:20.370886	\N	\N	2026-04-09 17:25:15.523881	\N	\N
88eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	WEB-3	Add SEO meta tags	Implement dynamic meta tags for all pages	STORY	TODO	MEDIUM	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-15	2026-03-18 20:14:20.370886	\N	\N	2026-04-09 17:25:15.523881	\N	\N
89eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	API-1	Design REST API endpoints	Document all API endpoints in OpenAPI spec	STORY	DONE	HIGH	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-15	2026-03-18 20:14:20.370886	\N	\N	2026-04-09 17:25:15.523881	\N	\N
8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	API-2	Implement rate limiting	Add rate limiting middleware	STORY	IN_PROGRESS	MEDIUM	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-20	2026-03-18 20:14:20.370886	\N	\N	2026-04-09 17:25:15.523881	\N	\N
f0e9f76c-8905-4f8c-9667-aa2a202bf4a0	1d105d8b-95d8-411e-9844-b6683e8b7f51	cc556634-367e-4ff9-a331-a000d92c89e3	1caa5563-3120-430a-a398-dacffb2123f9	PROJ-123-1	Login Page	Login Page	STORY	IN_REVIEW	MEDIUM	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-28	2026-03-20 10:25:16.159343	\N	\N	2026-04-09 17:25:15.523881	\N	\N
f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-1	Login Page	\N	TASK	TODO	MEDIUM	b762cce3-dac1-4aa0-bc38-a8488eaf994f	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-30	2026-03-27 16:54:46.380157	\N	\N	2026-04-09 22:22:40.895588	\N	\N
f393b18f-a52f-47ef-96cd-76ac61dc4033	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-7	R&D	<p>R&amp;D</p>	SUB_TASK	TODO	MEDIUM	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-16	2026-04-09 23:01:33.978349	\N	\N	2026-04-09 23:01:33.978349	\N	\N
594fbc67-ea13-439b-9e47-e1b7cfd64a96	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-8	R&D Validation rules	<p>R&amp;D</p>	SUB_TASK	TODO	MEDIUM	a6909bd5-59bb-480a-b0a2-d5e33775d45e	edb1541e-efee-435d-a4cd-6e7da392464a	\N	2026-04-09 23:12:26.30255	\N	\N	2026-04-10 12:45:10.361681	\N	\N
e8a7a8f2-9bf5-4cfa-9f57-127667fa51ca	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-4	Tenant Management/platform	<p><span style="color: rgb(41, 42, 46);">This epic covers the implementation of multi-tenant architecture for the LMS platform. It includes tenant creation, tenant configuration, tenant switching, and database isolation to ensure each organization can securely use the system independently with its own data and settings.</span></p>	EPIC	TODO	MEDIUM	fbfbe066-9918-412c-835d-f92a30ac44e4	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-16	2026-04-09 22:57:29.351302	\N	\N	2026-04-11 11:59:21.223101	\N	\N
1a9422aa-2e12-4253-ad11-edb74af5926e	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	\N	PROJ-1237-5	Tenant Configuration	<p>As an admin, I want to configure tenant-specific settings so that each tenant can customize their usage and limits as per requirements.&nbsp;</p><p>Tasks:&nbsp;</p><ul><li><p>Implement validation rules for configuration inputs.&nbsp;</p></li></ul><ul><li><p>Build frontend UI form for managing configuration.&nbsp;</p></li></ul><p></p>	STORY	TODO	MEDIUM	fbfbe066-9918-412c-835d-f92a30ac44e4	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-14	2026-04-09 22:59:56.122202	\N	\N	2026-04-11 11:59:21.223101	e8a7a8f2-9bf5-4cfa-9f57-127667fa51ca	\N
1c71d85b-0504-4f31-9a26-14e8117ccc0f	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-6	Implement validation rules for configuration inputs	<p>Configure</p>	TASK	TODO	MEDIUM	fbfbe066-9918-412c-835d-f92a30ac44e4	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-16	2026-04-09 23:00:52.207975	\N	\N	2026-04-11 11:59:21.223101	e8a7a8f2-9bf5-4cfa-9f57-127667fa51ca	1a9422aa-2e12-4253-ad11-edb74af5926e
c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	\N	PROJ-1237-3	R&D Animation for login page	\N	SUB_TASK	BLOCKED	HIGH	edb1541e-efee-435d-a4cd-6e7da392464a	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-31	2026-03-28 14:10:32.206133	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-11 12:07:12.531727	\N	\N
86d4af01-800a-435d-ac7c-d4594c1f495b	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-2	Registration Page	\N	TASK	IN_REVIEW	MEDIUM	a6909bd5-59bb-480a-b0a2-d5e33775d45e	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-31	2026-03-27 16:55:49.638554	LOGIN PAGE	\N	2026-04-13 11:13:33.214364	\N	\N
\.


--
-- TOC entry 5399 (class 0 OID 19395)
-- Dependencies: 237
-- Data for Name: task_comment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_comment (id, org_id, task_id, user_id, parent_comment_id, comment_text, status, created_at, updated_at) FROM stdin;
a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	Please make sure to follow our design system guidelines for the login screen.	ACTIVE	2026-03-18 20:14:20.377379	\N
a2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sure! I have the Figma link. Will follow the color palette and spacing guidelines.	ACTIVE	2026-03-18 20:14:20.377379	\N
a3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	Reproduced on iPhone 14 Pro with iOS 17.2. The button requires multiple taps.	ACTIVE	2026-03-18 20:14:20.377379	\N
a4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	Great progress! Lets add the animation for the CTA button.	ACTIVE	2026-03-18 20:14:20.377379	\N
37d8f2d7-2740-4ebe-8dcd-22d46300a612	1d105d8b-95d8-411e-9844-b6683e8b7f51	f0e9f76c-8905-4f8c-9667-aa2a202bf4a0	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	hello	ACTIVE	2026-03-20 14:47:48.196972	\N
35011d39-d64c-47c6-b214-586c1de6ef61	1d105d8b-95d8-411e-9844-b6683e8b7f51	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	edb1541e-efee-435d-a4cd-6e7da392464a	\N	good	ACTIVE	2026-03-28 14:11:13.966961	\N
\.


--
-- TOC entry 5400 (class 0 OID 19408)
-- Dependencies: 238
-- Data for Name: task_link; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_link (id, org_id, source_task_id, target_task_id, link_type, created_by, created_at) FROM stdin;
91eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	84eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEPENDS_ON	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18 20:14:20.375602
92eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	RELATES_TO	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18 20:14:20.375602
93eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	86eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEPENDS_ON	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18 20:14:20.375602
91062d25-7af6-48bb-9fed-2c20e9d65203	1d105d8b-95d8-411e-9844-b6683e8b7f51	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	PARENT_OF	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-28 14:10:32.206133
7e07fc3d-be55-4e08-81a0-c5188b31343f	1d105d8b-95d8-411e-9844-b6683e8b7f51	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	CHILD_OF	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-28 14:10:32.206133
a4270ce4-d4af-48ef-aa61-2ee4f1c2410a	1d105d8b-95d8-411e-9844-b6683e8b7f51	1c71d85b-0504-4f31-9a26-14e8117ccc0f	594fbc67-ea13-439b-9e47-e1b7cfd64a96	PARENT_OF	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-09 23:12:26.30255
30f14aa3-3e5f-4c6b-a7c1-e05c970873f6	1d105d8b-95d8-411e-9844-b6683e8b7f51	594fbc67-ea13-439b-9e47-e1b7cfd64a96	1c71d85b-0504-4f31-9a26-14e8117ccc0f	CHILD_OF	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-09 23:12:26.30255
\.


--
-- TOC entry 5401 (class 0 OID 19418)
-- Dependencies: 239
-- Data for Name: task_tag_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_tag_mapping (task_id, tag_id) FROM stdin;
81eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	71eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
81eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	71eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	74eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
84eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	75eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
86eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	74eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	71eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
89eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11	72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11	76eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
1c71d85b-0504-4f31-9a26-14e8117ccc0f	668ef1fa-f43a-476f-9fee-6a0bba660211
e8a7a8f2-9bf5-4cfa-9f57-127667fa51ca	72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
e8a7a8f2-9bf5-4cfa-9f57-127667fa51ca	73eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
\.


--
-- TOC entry 5402 (class 0 OID 19423)
-- Dependencies: 240
-- Data for Name: time_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.time_log (id, org_id, user_id, task_id, project_id, log_date, minutes, description, status, created_at) FROM stdin;
b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	81eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-10	480	Project setup and configuration	ACTIVE	2026-03-18 20:14:20.378956
b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-17	360	Started login screen implementation	ACTIVE	2026-03-18 20:14:20.378956
b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18	480	Login form validation and error handling	ACTIVE	2026-03-18 20:14:20.378956
b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-11	240	Hero section initial implementation	ACTIVE	2026-03-18 20:14:20.378956
b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	82eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-11	480	CI/CD pipeline setup with GitHub Actions	ACTIVE	2026-03-18 20:14:20.378956
b6eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	89eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-14	480	API documentation with OpenAPI	ACTIVE	2026-03-18 20:14:20.378956
b7eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-17	300	Rate limiting middleware research and implementation	ACTIVE	2026-03-18 20:14:20.378956
b8eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18	540	Rate limiting testing and configuration	ACTIVE	2026-03-18 20:14:20.378956
a30f52ce-72ec-4339-8ddc-6c78c2cdbd56	1d105d8b-95d8-411e-9844-b6683e8b7f51	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f0e9f76c-8905-4f8c-9667-aa2a202bf4a0	cc556634-367e-4ff9-a331-a000d92c89e3	2026-03-20	480	he	ACTIVE	2026-03-20 15:33:31.66641
1af1d543-432b-43ab-9b36-6333a31cf990	1d105d8b-95d8-411e-9844-b6683e8b7f51	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f0e9f76c-8905-4f8c-9667-aa2a202bf4a0	cc556634-367e-4ff9-a331-a000d92c89e3	2026-03-23	480	\N	ACTIVE	2026-03-23 12:43:10.837547
8584ddb5-1aef-4d2a-b342-01378cfa1820	1d105d8b-95d8-411e-9844-b6683e8b7f51	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f0e9f76c-8905-4f8c-9667-aa2a202bf4a0	cc556634-367e-4ff9-a331-a000d92c89e3	2026-03-24	480	dev	ACTIVE	2026-03-24 10:10:27.218267
\.


--
-- TOC entry 5403 (class 0 OID 19439)
-- Dependencies: 241
-- Data for Name: timesheet; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.timesheet (id, org_id, user_id, entry_date, project_name, task_details, status, created_at, updated_at) FROM stdin;
68882a45-6b13-418f-aa90-c7a7a64a0ec4	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27	LMS-PH	LOGIN PAGE	COMPLETED	2026-03-27 15:01:07.907162	2026-03-27 15:01:07.907162
4ed047fa-b1e1-4426-bc62-08d94f8f2311	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-26	LMS-PH	Registration page	COMPLETED	2026-03-27 15:15:32.387673	2026-03-27 15:15:32.387673
276c673d-d8e0-42f1-9143-d5521544891a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-25	LMS-PH	R&D Devops	COMPLETED	2026-03-27 15:15:52.8347	2026-03-27 15:15:52.8347
c158855d-1742-4d2c-9e1b-475a13615cf2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-24	LMS-PH	PM tool	IN_PROGRESS	2026-03-27 15:16:10.026095	2026-03-27 15:16:10.026095
46d976ad-14f8-46a7-aa2e-612e0075f46a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-23	LMS-PH	PM tool	IN_PROGRESS	2026-03-27 15:16:28.48031	2026-03-27 15:16:28.48031
c1a69369-7cfc-4800-b84d-5d34356c7452	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-22	LMS-PH	PM tool	IN_PROGRESS	2026-03-27 15:16:50.353392	2026-03-27 15:16:50.353392
2e06b6f8-9de4-4ac8-8b34-6f4156a2d3fb	1d105d8b-95d8-411e-9844-b6683e8b7f51	fbfbe066-9918-412c-835d-f92a30ac44e4	2026-03-26	lms	register	IN_PROGRESS	2026-03-27 15:25:00	2026-03-27 15:25:00
7fb625fd-52fc-4ed4-a767-fcb8964a1285	1d105d8b-95d8-411e-9844-b6683e8b7f51	fbfbe066-9918-412c-835d-f92a30ac44e4	2026-03-27	lms	login	IN_PROGRESS	2026-03-27 15:25:00	2026-03-27 15:25:00
\.


--
-- TOC entry 5404 (class 0 OID 19454)
-- Dependencies: 242
-- Data for Name: user_daily_summary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_daily_summary (id, org_id, user_id, summary_date, total_minutes, color, created_at, updated_at) FROM stdin;
c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-10	480	GREEN	2026-03-18 20:14:20.382519	\N
c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-11	240	YELLOW	2026-03-18 20:14:20.382519	\N
c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-17	360	YELLOW	2026-03-18 20:14:20.382519	\N
c4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18	480	GREEN	2026-03-18 20:14:20.382519	\N
c5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-11	480	GREEN	2026-03-18 20:14:20.382519	\N
c6eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-14	480	GREEN	2026-03-18 20:14:20.382519	\N
c7eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-17	300	YELLOW	2026-03-18 20:14:20.382519	\N
c8eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18	540	PURPLE	2026-03-18 20:14:20.382519	\N
78a755da-3426-435b-b0c0-a159a0aa0fd5	1d105d8b-95d8-411e-9844-b6683e8b7f51	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-20	480	GREEN	2026-03-20 15:33:31.66641	\N
23e2d704-8888-4d24-8fa4-f5ea5776474a	1d105d8b-95d8-411e-9844-b6683e8b7f51	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-23	480	GREEN	2026-03-23 12:43:10.837547	\N
585af519-1bc7-4952-8cb9-87f5d9836a55	1d105d8b-95d8-411e-9844-b6683e8b7f51	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-24	480	GREEN	2026-03-24 10:10:27.218267	\N
\.


--
-- TOC entry 5405 (class 0 OID 19465)
-- Dependencies: 243
-- Data for Name: user_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_permission (id, user_id, permission_key, is_granted, created_at, updated_at) FROM stdin;
b75c4326-6ae7-4ceb-bdca-d657afbfedfd	fbfbe066-9918-412c-835d-f92a30ac44e4	CREATE_PROJECT	t	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
4637c521-7035-43b8-b636-733526a9beec	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_PROJECT	t	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
ba7c034f-3b66-463a-9aa1-5c9ae846d40f	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_TASK	f	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
78abf4f5-f012-460a-a97d-f29f90e2402a	fbfbe066-9918-412c-835d-f92a30ac44e4	DELETE_TASK	f	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
184f9d65-2645-407a-8bc1-ce90be6277ee	fbfbe066-9918-412c-835d-f92a30ac44e4	LOG_TIME	t	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
ca4ee37a-f55a-443e-8d59-27320b0a948c	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_FINANCE	t	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
6439823a-08b3-45bb-9277-91331ec96245	fbfbe066-9918-412c-835d-f92a30ac44e4	MANAGE_SPRINT	f	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
29e066ed-ac8e-4af2-9671-e309905ff5fd	fbfbe066-9918-412c-835d-f92a30ac44e4	ASSIGN_USERS	t	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
9cbc6b04-6f4e-4fee-9102-67ee56cb3e36	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_REPORTS	t	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
bd8dead9-3c94-425c-a032-1ae646686894	fbfbe066-9918-412c-835d-f92a30ac44e4	MANAGE_LINKS	t	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
a392344a-5fbf-421b-b122-326690535505	fbfbe066-9918-412c-835d-f92a30ac44e4	MANAGE_LEADERSHIP	t	2026-03-31 11:44:01.150287	2026-04-01 10:32:16.723092
c7410d76-f191-4c36-8e6b-86175678aee5	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_ORGANIZATION	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
f237c9d3-15eb-45ed-b395-2a0f105e9b81	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_ORGANIZATION	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
b26e57ae-0131-4c0f-b20f-f813c11304a4	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_ORGANIZATION	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
39a28cd0-1b8a-48ca-b86a-a032dfd9bae7	e8f598e6-df54-46ee-bf25-ccadaee8681c	MANAGE_USERS	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
76f8e67a-de18-4e1d-8d64-a26705ff02b8	e8f598e6-df54-46ee-bf25-ccadaee8681c	MANAGE_BUSINESS_UNITS	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
20a8c8d6-370e-41a1-9ee0-7af7ad9b10bc	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_BUSINESS_UNIT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
672d3ee8-62e9-464f-8c23-29b84ed7740d	e8f598e6-df54-46ee-bf25-ccadaee8681c	CREATE_BUSINESS_UNIT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
3b62a55e-5abe-4d7c-837b-ff954dcf20b1	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_BUSINESS_UNIT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
6992e3f9-7f48-4529-9bd2-a2c75898e913	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_BUSINESS_UNIT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
683d3ab1-cd30-480b-8fdc-741e4f96f040	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_USER	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
71114ac5-a3f4-49b2-a69e-ff7924563b68	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_USER	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
6bfeb972-6b07-4c4e-9c26-0a2a95260037	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_USER_ROLE	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
3f837f3a-97b6-4454-b095-4cf46ce8a730	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_USER_STATUS	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
ad0ed61b-f3b5-4f71-b3f7-fee733263dc1	e8f598e6-df54-46ee-bf25-ccadaee8681c	CREATE_PROJECT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
0b2cc5a4-6bdc-44f7-83ce-147862f25e14	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_PROJECT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
232c4e19-70b9-43c2-836a-20360de44d21	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_PROJECT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
a9d6e4ba-cfb3-4d25-9366-a02c405a46d5	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_PROJECT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
a09d57e4-e29c-42e7-a165-cfff421b3ec2	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_PROJECT_DETAILS	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
bed4b120-19a2-4b0e-a0fe-069d85e9b996	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_PROJECT_DETAILS	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
3017c10c-da60-406a-afea-09244630ae6c	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_TECH_STACK	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
5cfc5c6a-56ab-40d5-8cc2-ef34f62d586f	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_DEPENDENCIES	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
f505861b-075a-465f-b57c-ff42c81fc1f3	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_BUDGET	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
0b165031-7a68-4e07-b97d-665d912e8e55	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_FINANCE	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
6432dccc-78cd-4d0e-90e1-65b8664078a8	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_FINANCE_CODE	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
93789ace-2bee-47ad-ada6-a354024729b2	e8f598e6-df54-46ee-bf25-ccadaee8681c	CREATE_TASK	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
d3049db1-c482-46fb-819a-3d948cb92dc9	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_TASK	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
0e8256d5-cd2e-4022-bf89-bfa124dce4df	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_TASK	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
bfc11813-2a21-4a39-a648-0669a2bbadf9	e8f598e6-df54-46ee-bf25-ccadaee8681c	CREATE_COMMENT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
3395b537-78fe-43d4-86b6-6fc1a4582b80	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_COMMENT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
f0a0b1b6-87cc-4b2d-9bda-67127521c83f	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_COMMENT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
c7a901f5-c2f9-4cde-bc4a-1a7c394b9fb0	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_ATTACHMENT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
048ef01b-e4aa-4bfe-8173-7d7664815dee	e8f598e6-df54-46ee-bf25-ccadaee8681c	CREATE_ATTACHMENT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
b20b3f3a-6150-4a24-ac39-15123776edc9	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_ATTACHMENT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
eca83a37-61d1-489c-a6d3-c9b7df093072	e8f598e6-df54-46ee-bf25-ccadaee8681c	MANAGE_SPRINT	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
82977cf2-45f8-44d6-aac3-215bd6656812	e8f598e6-df54-46ee-bf25-ccadaee8681c	MANAGE_LINKS	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
f8998488-dbfb-478b-83f5-129f1a113fef	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_ORGANIZATION	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
34775ddc-c0a7-4c2c-9c73-5812038981d3	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_ORGANIZATION	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
2cf41771-b997-4763-95c4-af89f03d1e3e	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_ORGANIZATION	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
0d7d5400-1999-4385-a2f0-21888297baeb	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_USERS	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
84f01e74-667a-46b3-8471-0eb94350fe66	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_BUSINESS_UNITS	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
76580054-94ef-48d3-875a-cd26e2e11803	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_BUSINESS_UNIT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
2e3625d5-ec59-4471-a367-0f7d7135d1c8	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_BUSINESS_UNIT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
204ae7d4-bcd4-4bf7-813d-e40d1e290cbf	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_BUSINESS_UNIT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
ad3f7490-0813-460c-a615-94f783334aeb	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_BUSINESS_UNIT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
aacad41c-0b61-4bcf-8c0b-1cf4b73c45be	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_USER	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
14186aae-dd4b-421d-946f-d52b23b6c893	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_USER	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
93ad334f-6ac5-4c06-b97d-13b065fa78ae	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_USER_ROLE	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
421019d0-6eb1-46ba-bd8f-2f78c2481024	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_USER_STATUS	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
f4867696-8c2a-495b-9ac4-800546a94afb	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_PROJECT	t	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
7fb3a16a-ac84-4d13-abc8-62ebac30d3b7	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_PROJECT	t	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
f2f8b579-8e5b-4415-9ca1-b8853d3bb4f5	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_PROJECT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
a1048392-bd5e-4fe7-acf8-dcd890654b86	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_PROJECT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
7c2b836f-e36c-4a00-b321-5d945471b705	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_PROJECT_DETAILS	t	2026-04-01 11:43:11.199024	2026-04-11 12:18:41.994747
c2a4602a-a44b-4947-905d-2757ffebec65	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_PROJECT_DETAILS	t	2026-04-01 11:59:54.866193	2026-04-11 12:18:41.994747
885e2858-c73a-40e3-9c00-9e1f7f36816c	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_TECH_STACK	t	2026-04-01 11:43:11.199024	2026-04-11 12:18:41.994747
82c46cd3-f4a5-4e99-b208-4a9e6f1531d7	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_DEPENDENCIES	t	2026-04-01 11:43:11.199024	2026-04-11 12:18:41.994747
1419d972-c296-445f-bd57-b6a496e53531	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_BUDGET	t	2026-04-01 11:59:54.866193	2026-04-11 12:18:41.994747
460754f1-e26e-4888-b660-f1bdc4edc65b	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_FINANCE	t	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
19cf8667-e7dc-4646-a839-7309fd300dce	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_FINANCE_CODE	t	2026-04-01 11:59:54.866193	2026-04-11 12:18:41.994747
2e8473ae-835e-4ea5-9233-9a740e415934	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_TASK	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
4dd814c1-7776-4667-8343-4229f79e635c	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_TASK	t	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
725d9558-0739-47c3-9c2d-cdc2a4e992fb	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_TASK	t	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
b8d7b74a-e3db-4ad7-83d4-bf0cea19f9ce	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_COMMENT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
3de8fd51-827c-4de5-a086-5c7438ed1093	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_COMMENT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
9f0cdc9f-7d6f-4880-a4de-dc5da5161c4d	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_COMMENT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
cc881e66-c213-403a-8359-033feb6013a5	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_ATTACHMENT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
c2b95954-e150-42b1-9f77-f8c3d24f9013	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_ATTACHMENT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
672b0eab-53b0-4ec5-b925-3f2695cd46ab	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_ATTACHMENT	t	2026-04-01 17:44:37.426169	2026-04-11 12:18:41.994747
91f66a30-2895-4873-8dd6-916f228dc077	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_SPRINT	t	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
3f50d91c-1fe6-4a64-b6de-f5ffb77f6331	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_LINKS	t	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
a621bcfb-c604-4fd1-8bd4-fe67c095eb7a	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_LEADERSHIP	t	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
2b0a62bb-c589-48b9-947e-c52d35028eac	edb1541e-efee-435d-a4cd-6e7da392464a	ASSIGN_USERS	t	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
2eeec1f9-1bca-40c1-abac-7f33931c835b	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_REPORTS	f	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
be2acfe4-b48c-4353-a820-6c93ffa0fdac	edb1541e-efee-435d-a4cd-6e7da392464a	LOG_TIME	t	2026-03-31 12:36:45.657251	2026-04-11 12:18:41.994747
a2137e3f-cbf6-4b7f-9048-2a3a9b0aecab	e8f598e6-df54-46ee-bf25-ccadaee8681c	MANAGE_LEADERSHIP	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
f1221d62-9769-4a41-95a1-b311bfd84925	e8f598e6-df54-46ee-bf25-ccadaee8681c	ASSIGN_USERS	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
5351f526-e600-4f57-aa2c-c8ec94671c55	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_REPORTS	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
298f7862-d890-4a88-91b8-a051841b3fd2	e8f598e6-df54-46ee-bf25-ccadaee8681c	LOG_TIME	t	2026-04-09 09:50:24.821044	2026-04-12 18:51:09.945672
\.


--
-- TOC entry 5406 (class 0 OID 19478)
-- Dependencies: 244
-- Data for Name: user_project_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_project_mapping (id, org_id, user_id, project_id, project_role, status, created_at, allocated_bandwidth, approval_status, requested_by_user_id, approved_by_user_id, approved_at) FROM stdin;
e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MANAGER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N
e2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEVELOPER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N
e3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEVELOPER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N
e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	QA	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N
e5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MANAGER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N
e6eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEVELOPER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N
e7eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MANAGER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N
e8eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEVELOPER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N
f57de93d-1d7f-483c-ace8-a06c8777717d	1d105d8b-95d8-411e-9844-b6683e8b7f51	65b2f9f4-a049-4766-b6f6-4ecca8fb8de7	cc556634-367e-4ff9-a331-a000d92c89e3	DEV	ACTIVE	2026-03-20 14:15:31.492414	0	PENDING	\N	\N	\N
892c9d61-da2c-457b-9fa5-3f46a52605e8	1d105d8b-95d8-411e-9844-b6683e8b7f51	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	cc556634-367e-4ff9-a331-a000d92c89e3	MANAGER	ACTIVE	2026-03-20 15:26:56.929039	0	PENDING	\N	\N	\N
a8249a6a-f2e0-477a-8751-b1b961ea8096	1d105d8b-95d8-411e-9844-b6683e8b7f51	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	71bb0f85-cdde-469a-900d-e8761da76e45	MANAGER	ACTIVE	2026-03-27 00:03:11.641963	0	REJECTED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:04:00.384
4669f46e-3526-449e-b5bd-e4811f73017c	1d105d8b-95d8-411e-9844-b6683e8b7f51	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	71bb0f85-cdde-469a-900d-e8761da76e45	DEV	ACTIVE	2026-03-27 00:03:18.341318	0	REJECTED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:04:03.561
990bfa40-f689-4c86-b889-c94fac44bb5d	1d105d8b-95d8-411e-9844-b6683e8b7f51	b762cce3-dac1-4aa0-bc38-a8488eaf994f	71bb0f85-cdde-469a-900d-e8761da76e45	QA	ACTIVE	2026-03-27 12:16:26.351317	50	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:17:59.381
b0f86c88-daa5-4db2-95eb-e3853e1076b5	1d105d8b-95d8-411e-9844-b6683e8b7f51	b762cce3-dac1-4aa0-bc38-a8488eaf994f	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-03-27 12:19:21.433172	50	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:19:30.431
690f4d4c-7363-4fd7-9870-3e1876f75feb	1d105d8b-95d8-411e-9844-b6683e8b7f51	fbfbe066-9918-412c-835d-f92a30ac44e4	eeb797e6-385c-4376-a607-9663e4313e60	DEV	ACTIVE	2026-03-27 11:48:45.554344	60	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:21:58.008
c2bb69e7-aaf2-407c-ac56-525ffc71643c	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	71bb0f85-cdde-469a-900d-e8761da76e45	DEV	ACTIVE	2026-03-27 12:35:42.529365	60	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:35:46.957
74c845ad-3beb-4289-be4f-e565eb5a3ccc	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-03-27 14:59:45.637328	40	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 14:59:50.019
6544a869-d2fe-41d8-8f59-cd6e90245479	1d105d8b-95d8-411e-9844-b6683e8b7f51	fbfbe066-9918-412c-835d-f92a30ac44e4	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-03-27 16:11:07.351416	40	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 16:11:15.047
5482585b-9902-415a-9835-3c0385edcce8	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-04-10 12:44:56.436446	50	APPROVED	\N	a6909bd5-59bb-480a-b0a2-d5e33775d45e	2026-04-10 12:45:02.848
\.


--
-- TOC entry 5050 (class 2606 OID 19494)
-- Name: app_user app_user_org_id_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_email_key UNIQUE (org_id, email);


--
-- TOC entry 5052 (class 2606 OID 19496)
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- TOC entry 5056 (class 2606 OID 19498)
-- Name: attachment attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- TOC entry 5060 (class 2606 OID 19500)
-- Name: business_unit business_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_pkey PRIMARY KEY (id);


--
-- TOC entry 5065 (class 2606 OID 19502)
-- Name: chat_message chat_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_pkey PRIMARY KEY (id);


--
-- TOC entry 5068 (class 2606 OID 19504)
-- Name: chat_session chat_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_pkey PRIMARY KEY (id);


--
-- TOC entry 5078 (class 2606 OID 19506)
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- TOC entry 5081 (class 2606 OID 19508)
-- Name: organization organization_azure_tenant_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_azure_tenant_id_key UNIQUE (azure_tenant_id);


--
-- TOC entry 5083 (class 2606 OID 19510)
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- TOC entry 5085 (class 2606 OID 19512)
-- Name: platform_user platform_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_email_key UNIQUE (email);


--
-- TOC entry 5087 (class 2606 OID 19514)
-- Name: platform_user platform_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_pkey PRIMARY KEY (id);


--
-- TOC entry 5098 (class 2606 OID 19516)
-- Name: project_cost project_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_pkey PRIMARY KEY (id);


--
-- TOC entry 5101 (class 2606 OID 19518)
-- Name: project_link project_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5092 (class 2606 OID 19520)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- TOC entry 5094 (class 2606 OID 19522)
-- Name: project project_project_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_project_code_key UNIQUE (project_code);


--
-- TOC entry 5104 (class 2606 OID 19524)
-- Name: project_task_sequence project_task_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_pkey PRIMARY KEY (id);


--
-- TOC entry 5106 (class 2606 OID 19526)
-- Name: project_task_sequence project_task_sequence_project_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_key UNIQUE (project_id);


--
-- TOC entry 5109 (class 2606 OID 19528)
-- Name: resource_cost resource_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_pkey PRIMARY KEY (id);


--
-- TOC entry 5111 (class 2606 OID 19530)
-- Name: resource_cost resource_cost_user_id_effective_from_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_effective_from_key UNIQUE (user_id, effective_from);


--
-- TOC entry 5114 (class 2606 OID 19532)
-- Name: role_permission role_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_pkey PRIMARY KEY (role, permission_key);


--
-- TOC entry 5118 (class 2606 OID 19534)
-- Name: sprint sprint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_pkey PRIMARY KEY (id);


--
-- TOC entry 5121 (class 2606 OID 19536)
-- Name: tag tag_org_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_name_key UNIQUE (org_id, name);


--
-- TOC entry 5123 (class 2606 OID 19538)
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- TOC entry 5140 (class 2606 OID 19540)
-- Name: task_comment task_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_pkey PRIMARY KEY (id);


--
-- TOC entry 5144 (class 2606 OID 19542)
-- Name: task_link task_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5146 (class 2606 OID 19544)
-- Name: task_link task_link_source_task_id_target_task_id_link_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_target_task_id_link_type_key UNIQUE (source_task_id, target_task_id, link_type);


--
-- TOC entry 5134 (class 2606 OID 19546)
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- TOC entry 5150 (class 2606 OID 19548)
-- Name: task_tag_mapping task_tag_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_pkey PRIMARY KEY (task_id, tag_id);


--
-- TOC entry 5136 (class 2606 OID 19550)
-- Name: task task_task_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_task_code_key UNIQUE (task_code);


--
-- TOC entry 5156 (class 2606 OID 19552)
-- Name: time_log time_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5161 (class 2606 OID 19554)
-- Name: timesheet timesheet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_pkey PRIMARY KEY (id);


--
-- TOC entry 5063 (class 2606 OID 19556)
-- Name: business_unit uq_business_unit_org_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT uq_business_unit_org_name UNIQUE (org_id, name);


--
-- TOC entry 5170 (class 2606 OID 19558)
-- Name: user_permission uq_user_permission; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT uq_user_permission UNIQUE (user_id, permission_key);


--
-- TOC entry 5179 (class 2606 OID 19560)
-- Name: user_project_mapping uq_user_project_mapping_user_project_role; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT uq_user_project_mapping_user_project_role UNIQUE (user_id, project_id, project_role);


--
-- TOC entry 5165 (class 2606 OID 19562)
-- Name: user_daily_summary user_daily_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_pkey PRIMARY KEY (id);


--
-- TOC entry 5167 (class 2606 OID 19564)
-- Name: user_daily_summary user_daily_summary_user_id_summary_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_summary_date_key UNIQUE (user_id, summary_date);


--
-- TOC entry 5172 (class 2606 OID 19566)
-- Name: user_permission user_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT user_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 5181 (class 2606 OID 19568)
-- Name: user_project_mapping user_project_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_pkey PRIMARY KEY (id);


--
-- TOC entry 5053 (class 1259 OID 19569)
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- TOC entry 5054 (class 1259 OID 19570)
-- Name: idx_app_user_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_org ON public.app_user USING btree (org_id);


--
-- TOC entry 5057 (class 1259 OID 19571)
-- Name: idx_attachment_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_org ON public.attachment USING btree (org_id);


--
-- TOC entry 5058 (class 1259 OID 19572)
-- Name: idx_attachment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_task ON public.attachment USING btree (task_id);


--
-- TOC entry 5061 (class 1259 OID 19573)
-- Name: idx_business_unit_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_business_unit_org ON public.business_unit USING btree (org_id);


--
-- TOC entry 5066 (class 1259 OID 19574)
-- Name: idx_chat_message_session_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_message_session_created ON public.chat_message USING btree (session_id, created_at);


--
-- TOC entry 5069 (class 1259 OID 19575)
-- Name: idx_chat_session_org_user_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_session_org_user_active ON public.chat_session USING btree (org_id, user_id, ended_at);


--
-- TOC entry 5070 (class 1259 OID 19576)
-- Name: idx_chat_session_org_user_started; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_session_org_user_started ON public.chat_session USING btree (org_id, user_id, started_at DESC);


--
-- TOC entry 5071 (class 1259 OID 19577)
-- Name: idx_notification_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_created_at ON public.notification USING btree (created_at DESC);


--
-- TOC entry 5072 (class 1259 OID 19578)
-- Name: idx_notification_recipient_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_recipient_created_at ON public.notification USING btree (recipient_id, created_at DESC);


--
-- TOC entry 5073 (class 1259 OID 19579)
-- Name: idx_notification_recipient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_recipient_id ON public.notification USING btree (recipient_id);


--
-- TOC entry 5074 (class 1259 OID 19580)
-- Name: idx_notification_recipient_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_recipient_is_read ON public.notification USING btree (recipient_id, is_read);


--
-- TOC entry 5075 (class 1259 OID 19581)
-- Name: idx_notification_task_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_task_id ON public.notification USING btree (task_id);


--
-- TOC entry 5076 (class 1259 OID 19582)
-- Name: idx_notification_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_type ON public.notification USING btree (type);


--
-- TOC entry 5079 (class 1259 OID 19583)
-- Name: idx_organization_azure_tenant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_organization_azure_tenant ON public.organization USING btree (azure_tenant_id);


--
-- TOC entry 5088 (class 1259 OID 19584)
-- Name: idx_project_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_code ON public.project USING btree (project_code);


--
-- TOC entry 5096 (class 1259 OID 19585)
-- Name: idx_project_cost_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_cost_project ON public.project_cost USING btree (project_id);


--
-- TOC entry 5099 (class 1259 OID 19586)
-- Name: idx_project_link_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_link_project ON public.project_link USING btree (project_id);


--
-- TOC entry 5089 (class 1259 OID 19587)
-- Name: idx_project_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_org ON public.project USING btree (org_id);


--
-- TOC entry 5102 (class 1259 OID 19588)
-- Name: idx_project_task_sequence_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_task_sequence_project ON public.project_task_sequence USING btree (project_id);


--
-- TOC entry 5090 (class 1259 OID 19589)
-- Name: idx_project_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_type ON public.project USING btree (project_type);


--
-- TOC entry 5107 (class 1259 OID 19590)
-- Name: idx_resource_cost_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_resource_cost_user ON public.resource_cost USING btree (user_id);


--
-- TOC entry 5112 (class 1259 OID 19591)
-- Name: idx_role_permission_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_role_permission_role ON public.role_permission USING btree (role);


--
-- TOC entry 5115 (class 1259 OID 19592)
-- Name: idx_sprint_definition; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sprint_definition ON public.sprint USING btree (id) WHERE (definition IS NOT NULL);


--
-- TOC entry 5116 (class 1259 OID 19593)
-- Name: idx_sprint_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sprint_project ON public.sprint USING btree (project_id);


--
-- TOC entry 5119 (class 1259 OID 19594)
-- Name: idx_tag_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tag_org ON public.tag USING btree (org_id);


--
-- TOC entry 5124 (class 1259 OID 19595)
-- Name: idx_task_assignee; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_assignee ON public.task USING btree (assigned_to);


--
-- TOC entry 5125 (class 1259 OID 19596)
-- Name: idx_task_blocked_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_blocked_by ON public.task USING btree (blocked_by);


--
-- TOC entry 5126 (class 1259 OID 19597)
-- Name: idx_task_blocked_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_blocked_status ON public.task USING btree (status) WHERE ((status)::text = 'BLOCKED'::text);


--
-- TOC entry 5127 (class 1259 OID 19598)
-- Name: idx_task_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_code ON public.task USING btree (task_code);


--
-- TOC entry 5137 (class 1259 OID 19599)
-- Name: idx_task_comment_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_parent ON public.task_comment USING btree (parent_comment_id);


--
-- TOC entry 5138 (class 1259 OID 19600)
-- Name: idx_task_comment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_task ON public.task_comment USING btree (task_id);


--
-- TOC entry 5128 (class 1259 OID 19601)
-- Name: idx_task_epic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_epic ON public.task USING btree (epic_id) WHERE (epic_id IS NOT NULL);


--
-- TOC entry 5141 (class 1259 OID 19602)
-- Name: idx_task_link_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_source ON public.task_link USING btree (source_task_id);


--
-- TOC entry 5142 (class 1259 OID 19603)
-- Name: idx_task_link_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_target ON public.task_link USING btree (target_task_id);


--
-- TOC entry 5129 (class 1259 OID 19604)
-- Name: idx_task_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_org ON public.task USING btree (org_id);


--
-- TOC entry 5130 (class 1259 OID 19605)
-- Name: idx_task_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_project ON public.task USING btree (project_id);


--
-- TOC entry 5131 (class 1259 OID 19606)
-- Name: idx_task_sprint; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_sprint ON public.task USING btree (sprint_id);


--
-- TOC entry 5132 (class 1259 OID 19607)
-- Name: idx_task_story; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_story ON public.task USING btree (story_id) WHERE (story_id IS NOT NULL);


--
-- TOC entry 5147 (class 1259 OID 19608)
-- Name: idx_task_tag_mapping_tag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_tag ON public.task_tag_mapping USING btree (tag_id);


--
-- TOC entry 5148 (class 1259 OID 19609)
-- Name: idx_task_tag_mapping_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_task ON public.task_tag_mapping USING btree (task_id);


--
-- TOC entry 5151 (class 1259 OID 19610)
-- Name: idx_time_log_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_date ON public.time_log USING btree (log_date);


--
-- TOC entry 5152 (class 1259 OID 19611)
-- Name: idx_time_log_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_task ON public.time_log USING btree (task_id);


--
-- TOC entry 5153 (class 1259 OID 19612)
-- Name: idx_time_log_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user ON public.time_log USING btree (user_id);


--
-- TOC entry 5154 (class 1259 OID 19613)
-- Name: idx_time_log_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user_date ON public.time_log USING btree (user_id, log_date);


--
-- TOC entry 5157 (class 1259 OID 19614)
-- Name: idx_timesheet_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_org ON public.timesheet USING btree (org_id);


--
-- TOC entry 5158 (class 1259 OID 19615)
-- Name: idx_timesheet_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user ON public.timesheet USING btree (user_id);


--
-- TOC entry 5159 (class 1259 OID 19616)
-- Name: idx_timesheet_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user_date ON public.timesheet USING btree (user_id, entry_date);


--
-- TOC entry 5162 (class 1259 OID 19617)
-- Name: idx_user_daily_summary_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_date ON public.user_daily_summary USING btree (summary_date);


--
-- TOC entry 5163 (class 1259 OID 19618)
-- Name: idx_user_daily_summary_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_user ON public.user_daily_summary USING btree (user_id);


--
-- TOC entry 5168 (class 1259 OID 19619)
-- Name: idx_user_permission_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_permission_user_id ON public.user_permission USING btree (user_id);


--
-- TOC entry 5173 (class 1259 OID 19620)
-- Name: idx_user_project_mapping_approval_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_approval_status ON public.user_project_mapping USING btree (approval_status);


--
-- TOC entry 5174 (class 1259 OID 19621)
-- Name: idx_user_project_mapping_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project ON public.user_project_mapping USING btree (project_id);


--
-- TOC entry 5175 (class 1259 OID 19622)
-- Name: idx_user_project_mapping_project_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project_approval ON public.user_project_mapping USING btree (project_id, approval_status);


--
-- TOC entry 5176 (class 1259 OID 19623)
-- Name: idx_user_project_mapping_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user ON public.user_project_mapping USING btree (user_id);


--
-- TOC entry 5177 (class 1259 OID 19624)
-- Name: idx_user_project_mapping_user_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user_approval ON public.user_project_mapping USING btree (user_id, approval_status);


--
-- TOC entry 5095 (class 1259 OID 19625)
-- Name: uq_project_org_finance_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_project_org_finance_code ON public.project USING btree (org_id, finance_code) WHERE (finance_code IS NOT NULL);


--
-- TOC entry 5182 (class 2606 OID 19626)
-- Name: app_user app_user_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5183 (class 2606 OID 19631)
-- Name: attachment attachment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5184 (class 2606 OID 19636)
-- Name: attachment attachment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5185 (class 2606 OID 19641)
-- Name: attachment attachment_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.app_user(id);


--
-- TOC entry 5186 (class 2606 OID 19646)
-- Name: business_unit business_unit_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5187 (class 2606 OID 19651)
-- Name: business_unit business_unit_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.app_user(id);


--
-- TOC entry 5188 (class 2606 OID 19656)
-- Name: chat_message chat_message_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.chat_session(id) ON DELETE CASCADE;


--
-- TOC entry 5229 (class 2606 OID 19661)
-- Name: user_permission fk_user_permission_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT fk_user_permission_user FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- TOC entry 5189 (class 2606 OID 19666)
-- Name: notification notification_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- TOC entry 5190 (class 2606 OID 19671)
-- Name: notification notification_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5194 (class 2606 OID 19676)
-- Name: project_cost project_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5195 (class 2606 OID 19681)
-- Name: project_cost project_cost_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5191 (class 2606 OID 19686)
-- Name: project project_finance_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_finance_member_id_fkey FOREIGN KEY (finance_member_id) REFERENCES public.app_user(id);


--
-- TOC entry 5196 (class 2606 OID 19691)
-- Name: project_link project_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5197 (class 2606 OID 19696)
-- Name: project_link project_link_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5192 (class 2606 OID 19701)
-- Name: project project_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.app_user(id);


--
-- TOC entry 5193 (class 2606 OID 19706)
-- Name: project project_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5198 (class 2606 OID 19711)
-- Name: project_task_sequence project_task_sequence_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5199 (class 2606 OID 19716)
-- Name: resource_cost resource_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5200 (class 2606 OID 19721)
-- Name: resource_cost resource_cost_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5201 (class 2606 OID 19726)
-- Name: sprint sprint_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5202 (class 2606 OID 19731)
-- Name: tag tag_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5203 (class 2606 OID 19736)
-- Name: task task_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.app_user(id);


--
-- TOC entry 5204 (class 2606 OID 19741)
-- Name: task task_blocked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_blocked_by_fkey FOREIGN KEY (blocked_by) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5211 (class 2606 OID 19746)
-- Name: task_comment task_comment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5212 (class 2606 OID 19751)
-- Name: task_comment task_comment_parent_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.task_comment(id);


--
-- TOC entry 5213 (class 2606 OID 19756)
-- Name: task_comment task_comment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5214 (class 2606 OID 19761)
-- Name: task_comment task_comment_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5205 (class 2606 OID 19766)
-- Name: task task_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- TOC entry 5206 (class 2606 OID 19771)
-- Name: task task_epic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_epic_id_fkey FOREIGN KEY (epic_id) REFERENCES public.task(id) ON DELETE SET NULL;


--
-- TOC entry 5215 (class 2606 OID 19776)
-- Name: task_link task_link_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- TOC entry 5216 (class 2606 OID 19781)
-- Name: task_link task_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5217 (class 2606 OID 19786)
-- Name: task_link task_link_source_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_fkey FOREIGN KEY (source_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5218 (class 2606 OID 19791)
-- Name: task_link task_link_target_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_target_task_id_fkey FOREIGN KEY (target_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5207 (class 2606 OID 19796)
-- Name: task task_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5208 (class 2606 OID 19801)
-- Name: task task_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5209 (class 2606 OID 19806)
-- Name: task task_sprint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_sprint_id_fkey FOREIGN KEY (sprint_id) REFERENCES public.sprint(id);


--
-- TOC entry 5210 (class 2606 OID 19811)
-- Name: task task_story_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_story_id_fkey FOREIGN KEY (story_id) REFERENCES public.task(id) ON DELETE SET NULL;


--
-- TOC entry 5219 (class 2606 OID 19816)
-- Name: task_tag_mapping task_tag_mapping_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id) ON DELETE CASCADE;


--
-- TOC entry 5220 (class 2606 OID 19821)
-- Name: task_tag_mapping task_tag_mapping_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5221 (class 2606 OID 19826)
-- Name: time_log time_log_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5222 (class 2606 OID 19831)
-- Name: time_log time_log_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5223 (class 2606 OID 19836)
-- Name: time_log time_log_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5224 (class 2606 OID 19841)
-- Name: time_log time_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5225 (class 2606 OID 19846)
-- Name: timesheet timesheet_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5226 (class 2606 OID 19851)
-- Name: timesheet timesheet_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5227 (class 2606 OID 19856)
-- Name: user_daily_summary user_daily_summary_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5228 (class 2606 OID 19861)
-- Name: user_daily_summary user_daily_summary_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5230 (class 2606 OID 19866)
-- Name: user_project_mapping user_project_mapping_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5231 (class 2606 OID 19871)
-- Name: user_project_mapping user_project_mapping_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5232 (class 2606 OID 19876)
-- Name: user_project_mapping user_project_mapping_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5233 (class 2606 OID 19881)
-- Name: user_project_mapping user_project_mapping_requested_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_requested_by_user_id_fkey FOREIGN KEY (requested_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5234 (class 2606 OID 19886)
-- Name: user_project_mapping user_project_mapping_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: activity_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_log (
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.activity_log OWNER TO postgres;

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_pkey PRIMARY KEY (id);

CREATE INDEX idx_activity_log_org_created_at ON public.activity_log USING btree (org_id, created_at DESC);

CREATE INDEX idx_activity_log_actor_user_id ON public.activity_log USING btree (actor_user_id);

CREATE INDEX idx_activity_log_action_type ON public.activity_log USING btree (action_type);

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


-- Completed on 2026-04-13 11:21:55

--
-- PostgreSQL database dump complete
--

\unrestrict 25Qw007LUiCUVKssGtJbpHeqb1xWfYCvxl05AEaiv8kfl1ao5dGDxpvusXhXXO9

