--
-- PostgreSQL database dump
--

\restrict Yp9357tJf4fuKvgPMe3yo0y9lsBfwhHp4Gxg5K3oo6zmonl0PzUbjHCUTfMbNxV

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-08 16:59:11

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
-- TOC entry 2 (class 3079 OID 18497)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5363 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 18508)
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
-- TOC entry 221 (class 1259 OID 18523)
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
-- TOC entry 241 (class 1259 OID 19091)
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
-- TOC entry 222 (class 1259 OID 18536)
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
-- TOC entry 223 (class 1259 OID 18546)
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
-- TOC entry 224 (class 1259 OID 18557)
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
    CONSTRAINT chk_project_type_values CHECK ((((project_type)::text = ANY ((ARRAY['WEB'::character varying, 'MOBILE'::character varying, 'BOTH'::character varying])::text[])) OR (project_type IS NULL)))
);


ALTER TABLE public.project OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 18567)
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
-- TOC entry 226 (class 1259 OID 18581)
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
-- TOC entry 227 (class 1259 OID 18594)
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
-- TOC entry 228 (class 1259 OID 18602)
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
-- TOC entry 239 (class 1259 OID 19044)
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
-- TOC entry 229 (class 1259 OID 18613)
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
    goal text
);


ALTER TABLE public.sprint OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 18623)
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
-- TOC entry 231 (class 1259 OID 18632)
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
    output_description text
);


ALTER TABLE public.task OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 18645)
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
-- TOC entry 233 (class 1259 OID 18658)
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
-- TOC entry 234 (class 1259 OID 18668)
-- Name: task_tag_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_tag_mapping (
    task_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.task_tag_mapping OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 18673)
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
-- TOC entry 236 (class 1259 OID 18689)
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
-- TOC entry 237 (class 1259 OID 18704)
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
-- TOC entry 240 (class 1259 OID 19057)
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
-- TOC entry 238 (class 1259 OID 18715)
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
-- TOC entry 5336 (class 0 OID 18508)
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
6d7b3010-5f27-4495-b7b1-85d6f734657f	1d105d8b-95d8-411e-9844-b6683e8b7f51	pranathi@bonbloc.com	Pranathi	USER	t	t	ACTIVE	2026-03-26 23:01:27.496598
d4c27066-b249-42ef-ac9d-bccbd7cced4e	1d105d8b-95d8-411e-9844-b6683e8b7f51	test@gmail.com	sai ram	MANAGER	t	t	ACTIVE	2026-03-26 23:56:13.01749
edb1541e-efee-435d-a4cd-6e7da392464a	1d105d8b-95d8-411e-9844-b6683e8b7f51	harshith.kanumuri@bonbloc.com	Harshith Kanumuri	ORG_ADMIN	t	t	ACTIVE	2026-03-26 22:48:28.989947
e8f598e6-df54-46ee-bf25-ccadaee8681c	1d105d8b-95d8-411e-9844-b6683e8b7f51	harshith@example.com	Kanumuri Harshith	USER	t	t	ACTIVE	2026-04-07 18:31:21.344863
fbfbe066-9918-412c-835d-f92a30ac44e4	1d105d8b-95d8-411e-9844-b6683e8b7f51	narayanareddy.mallidi@bonbloc.com	Narayana	USER	t	t	ACTIVE	2026-03-27 10:02:54.511576
1400ccae-fcaa-452d-9d61-30afb052b604	1d105d8b-95d8-411e-9844-b6683e8b7f51	komali.avirneni@bonbloc.com	komali.avirneni	MANAGER	f	f	ACTIVE	2026-04-01 11:45:59.188686
\.


--
-- TOC entry 5337 (class 0 OID 18523)
-- Dependencies: 221
-- Data for Name: attachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attachment (id, org_id, task_id, file_name, file_type, file_size, s3_key, uploaded_by, status, created_at) FROM stdin;
0b432db8-80e5-4f85-a370-609448813852	1d105d8b-95d8-411e-9844-b6683e8b7f51	86d4af01-800a-435d-ac7c-d4594c1f495b	Screenshot 2026-03-28 135646.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/86d4af01-800a-435d-ac7c-d4594c1f495b/83071b02-a25f-4221-bd47-b11516a8e4da.png	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-28 14:11:59.09885
\.


--
-- TOC entry 5357 (class 0 OID 19091)
-- Dependencies: 241
-- Data for Name: business_unit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.business_unit (id, org_id, name, status, created_at, owner_id) FROM stdin;
325e8743-5704-40e0-ae85-11519c117b6f	1d105d8b-95d8-411e-9844-b6683e8b7f51	Product	ACTIVE	2026-04-01 11:16:35.682725	\N
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
\.


--
-- TOC entry 5338 (class 0 OID 18536)
-- Dependencies: 222
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization (id, name, azure_tenant_id, status, created_at) FROM stdin;
1d105d8b-95d8-411e-9844-b6683e8b7f51	BONbLOC Technologies	7915d0a8-0a13-4824-ba52-43a1ad694c42	ACTIVE	2026-03-19 14:23:34.808615
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Acme Corporation	null	ACTIVE	2026-03-18 20:14:20.339403
\.


--
-- TOC entry 5339 (class 0 OID 18546)
-- Dependencies: 223
-- Data for Name: platform_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.platform_user (id, email, name, role, status, created_at) FROM stdin;
d2c3a954-c0f7-4718-92be-e97449206874	oviiyadominic@gmail.com	Oviiya Dominic	ADMIN	ACTIVE	2026-03-19 14:28:31.763376
\.


--
-- TOC entry 5340 (class 0 OID 18557)
-- Dependencies: 224
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
-- TOC entry 5341 (class 0 OID 18567)
-- Dependencies: 225
-- Data for Name: project_cost; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_cost (id, org_id, project_id, cost_type, amount, description, cost_date, status, created_at) FROM stdin;
\.


--
-- TOC entry 5342 (class 0 OID 18581)
-- Dependencies: 226
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
-- TOC entry 5343 (class 0 OID 18594)
-- Dependencies: 227
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
207a9436-a4b3-48d3-82d1-61b42740693b	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	3	2026-03-27 12:19:05.01159
\.


--
-- TOC entry 5344 (class 0 OID 18602)
-- Dependencies: 228
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
-- TOC entry 5355 (class 0 OID 19044)
-- Dependencies: 239
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
-- TOC entry 5345 (class 0 OID 18613)
-- Dependencies: 229
-- Data for Name: sprint; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sprint (id, project_id, name, start_date, end_date, status, created_at, goal) FROM stdin;
f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sprint 1 - Foundation	2026-03-01	2026-03-15	COMPLETED	2026-03-18 20:14:20.367127	\N
f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sprint 2 - Auth Module	2026-03-16	2026-03-30	ACTIVE	2026-03-18 20:14:20.367127	\N
f3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sprint 3 - Dashboard	2026-03-31	2026-04-14	PLANNED	2026-03-18 20:14:20.367127	\N
f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sprint 1 - Homepage	2026-03-01	2026-03-15	ACTIVE	2026-03-18 20:14:20.367127	\N
f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sprint 1 - Core APIs	2026-03-10	2026-03-24	ACTIVE	2026-03-18 20:14:20.367127	\N
d697d764-de47-4525-8567-bb08f4edf96d	6564025c-356b-4e87-96e6-44360bde99f0	Sprint 1	2026-03-22	2026-03-27	PLANNED	2026-03-19 18:22:17.123305	Develop
f4fad8f2-9b37-43bc-a021-62675674efb2	cc556634-367e-4ff9-a331-a000d92c89e3	Sprint 1	2026-03-20	2026-03-21	PLANNED	2026-03-20 10:16:38.351924	\N
1caa5563-3120-430a-a398-dacffb2123f9	cc556634-367e-4ff9-a331-a000d92c89e3	Sprint 1	2026-03-19	2026-03-19	ACTIVE	2026-03-19 18:31:36.785698	Develop
87c72569-6047-4ce3-ae14-5a401d0c0f3d	71bb0f85-cdde-469a-900d-e8761da76e45	Sprint 2	2026-03-28	2026-03-31	COMPLETED	2026-03-26 23:14:20.116282	\N
37f0972a-3887-4618-93f1-11f453e673e5	71bb0f85-cdde-469a-900d-e8761da76e45	Sprint 1	2026-03-27	2026-04-27	PLANNED	2026-03-27 00:04:03.877572	\N
cd43809a-31ed-4d2e-8925-70892ba59078	71bb0f85-cdde-469a-900d-e8761da76e45	Sprint 1	2026-03-26	2026-04-26	ACTIVE	2026-03-26 23:07:46.283323	\N
4343a450-7655-41c0-835a-7bba93cc7aeb	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	S 1	2026-03-27	2026-04-27	ACTIVE	2026-03-27 16:54:18.139567	\N
\.


--
-- TOC entry 5346 (class 0 OID 18623)
-- Dependencies: 230
-- Data for Name: tag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tag (id, org_id, name, color, status, created_at) FROM stdin;
71eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Frontend	#3498DB	ACTIVE	2026-03-18 20:14:20.369254
72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Backend	#2ECC71	ACTIVE	2026-03-18 20:14:20.369254
73eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Database	#9B59B6	ACTIVE	2026-03-18 20:14:20.369254
74eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	UI/UX	#E74C3C	ACTIVE	2026-03-18 20:14:20.369254
75eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Security	#F39C12	ACTIVE	2026-03-18 20:14:20.369254
76eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Performance	#1ABC9C	ACTIVE	2026-03-18 20:14:20.369254
\.


--
-- TOC entry 5347 (class 0 OID 18632)
-- Dependencies: 231
-- Data for Name: task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task (id, org_id, project_id, sprint_id, task_code, title, description, task_type, status, priority, assigned_to, created_by, due_date, created_at, output_description) FROM stdin;
81eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-1	Setup project structure	Initialize React Native project with TypeScript	STORY	DONE	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-10	2026-03-18 20:14:20.370886	\N
82eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-2	Configure CI/CD pipeline	Setup GitHub Actions for automated builds	STORY	DONE	MEDIUM	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-12	2026-03-18 20:14:20.370886	\N
83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-3	Implement login screen	Create login UI with email and password fields	STORY	IN_PROGRESS	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-20	2026-03-18 20:14:20.370886	\N
84eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-4	Integrate Azure AD auth	Implement Microsoft authentication	STORY	TODO	HIGH	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-25	2026-03-18 20:14:20.370886	\N
85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-5	Login button not responsive on iOS	Touch event not firing consistently	BUG	TODO	CRITICAL	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-22	2026-03-18 20:14:20.370886	\N
86eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	WEB-1	Design homepage mockup	Create Figma designs for new homepage	STORY	DONE	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-08	2026-03-18 20:14:20.370886	\N
87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	WEB-2	Implement hero section	Build responsive hero component	STORY	IN_PROGRESS	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-12	2026-03-18 20:14:20.370886	\N
88eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	WEB-3	Add SEO meta tags	Implement dynamic meta tags for all pages	STORY	TODO	MEDIUM	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-15	2026-03-18 20:14:20.370886	\N
89eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	API-1	Design REST API endpoints	Document all API endpoints in OpenAPI spec	STORY	DONE	HIGH	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-15	2026-03-18 20:14:20.370886	\N
8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	API-2	Implement rate limiting	Add rate limiting middleware	STORY	IN_PROGRESS	MEDIUM	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-20	2026-03-18 20:14:20.370886	\N
f0e9f76c-8905-4f8c-9667-aa2a202bf4a0	1d105d8b-95d8-411e-9844-b6683e8b7f51	cc556634-367e-4ff9-a331-a000d92c89e3	1caa5563-3120-430a-a398-dacffb2123f9	PROJ-123-1	Login Page	Login Page	STORY	IN_REVIEW	MEDIUM	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-28	2026-03-20 10:25:16.159343	\N
f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-1	Login Page	\N	TASK	TODO	MEDIUM	b762cce3-dac1-4aa0-bc38-a8488eaf994f	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-30	2026-03-27 16:54:46.380157	\N
86d4af01-800a-435d-ac7c-d4594c1f495b	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-2	Registration Page	\N	TASK	IN_REVIEW	MEDIUM	edb1541e-efee-435d-a4cd-6e7da392464a	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-31	2026-03-27 16:55:49.638554	LOGIN PAGE
c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	\N	PROJ-1237-3	R&D Animation for login page	\N	SUB_TASK	TODO	HIGH	fbfbe066-9918-412c-835d-f92a30ac44e4	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-31	2026-03-28 14:10:32.206133	\N
\.


--
-- TOC entry 5348 (class 0 OID 18645)
-- Dependencies: 232
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
-- TOC entry 5349 (class 0 OID 18658)
-- Dependencies: 233
-- Data for Name: task_link; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_link (id, org_id, source_task_id, target_task_id, link_type, created_by, created_at) FROM stdin;
91eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	84eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEPENDS_ON	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18 20:14:20.375602
92eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	RELATES_TO	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18 20:14:20.375602
93eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	86eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEPENDS_ON	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18 20:14:20.375602
91062d25-7af6-48bb-9fed-2c20e9d65203	1d105d8b-95d8-411e-9844-b6683e8b7f51	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	PARENT_OF	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-28 14:10:32.206133
7e07fc3d-be55-4e08-81a0-c5188b31343f	1d105d8b-95d8-411e-9844-b6683e8b7f51	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	CHILD_OF	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-28 14:10:32.206133
\.


--
-- TOC entry 5350 (class 0 OID 18668)
-- Dependencies: 234
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
\.


--
-- TOC entry 5351 (class 0 OID 18673)
-- Dependencies: 235
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
-- TOC entry 5352 (class 0 OID 18689)
-- Dependencies: 236
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
-- TOC entry 5353 (class 0 OID 18704)
-- Dependencies: 237
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
-- TOC entry 5356 (class 0 OID 19057)
-- Dependencies: 240
-- Data for Name: user_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_permission (id, user_id, permission_key, is_granted, created_at, updated_at) FROM stdin;
f4867696-8c2a-495b-9ac4-800546a94afb	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_PROJECT	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
7fb3a16a-ac84-4d13-abc8-62ebac30d3b7	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_PROJECT	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
c2a4602a-a44b-4947-905d-2757ffebec65	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_PROJECT_DETAILS	t	2026-04-01 11:59:54.866193	2026-04-01 17:44:37.426169
1419d972-c296-445f-bd57-b6a496e53531	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_BUDGET	t	2026-04-01 11:59:54.866193	2026-04-01 17:44:37.426169
460754f1-e26e-4888-b660-f1bdc4edc65b	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_FINANCE	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
19cf8667-e7dc-4646-a839-7309fd300dce	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_FINANCE_CODE	t	2026-04-01 11:59:54.866193	2026-04-01 17:44:37.426169
4dd814c1-7776-4667-8343-4229f79e635c	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_TASK	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
725d9558-0739-47c3-9c2d-cdc2a4e992fb	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_TASK	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
91f66a30-2895-4873-8dd6-916f228dc077	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_SPRINT	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
3f50d91c-1fe6-4a64-b6de-f5ffb77f6331	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_LINKS	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
a621bcfb-c604-4fd1-8bd4-fe67c095eb7a	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_LEADERSHIP	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
2b0a62bb-c589-48b9-947e-c52d35028eac	edb1541e-efee-435d-a4cd-6e7da392464a	ASSIGN_USERS	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
2eeec1f9-1bca-40c1-abac-7f33931c835b	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_REPORTS	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
be2acfe4-b48c-4353-a820-6c93ffa0fdac	edb1541e-efee-435d-a4cd-6e7da392464a	LOG_TIME	t	2026-03-31 12:36:45.657251	2026-04-01 17:44:37.426169
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
f8998488-dbfb-478b-83f5-129f1a113fef	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_ORGANIZATION	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
34775ddc-c0a7-4c2c-9c73-5812038981d3	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_ORGANIZATION	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
2cf41771-b997-4763-95c4-af89f03d1e3e	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_ORGANIZATION	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
0d7d5400-1999-4385-a2f0-21888297baeb	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_USERS	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
84f01e74-667a-46b3-8471-0eb94350fe66	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_BUSINESS_UNITS	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
76580054-94ef-48d3-875a-cd26e2e11803	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_BUSINESS_UNIT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
2e3625d5-ec59-4471-a367-0f7d7135d1c8	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_BUSINESS_UNIT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
204ae7d4-bcd4-4bf7-813d-e40d1e290cbf	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_BUSINESS_UNIT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
ad3f7490-0813-460c-a615-94f783334aeb	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_BUSINESS_UNIT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
aacad41c-0b61-4bcf-8c0b-1cf4b73c45be	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_USER	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
14186aae-dd4b-421d-946f-d52b23b6c893	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_USER	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
93ad334f-6ac5-4c06-b97d-13b065fa78ae	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_USER_ROLE	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
421019d0-6eb1-46ba-bd8f-2f78c2481024	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_USER_STATUS	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
f2f8b579-8e5b-4415-9ca1-b8853d3bb4f5	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_PROJECT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
a1048392-bd5e-4fe7-acf8-dcd890654b86	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_PROJECT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
7c2b836f-e36c-4a00-b321-5d945471b705	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_PROJECT_DETAILS	t	2026-04-01 11:43:11.199024	2026-04-01 17:44:37.426169
885e2858-c73a-40e3-9c00-9e1f7f36816c	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_TECH_STACK	t	2026-04-01 11:43:11.199024	2026-04-01 17:44:37.426169
82c46cd3-f4a5-4e99-b208-4a9e6f1531d7	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_DEPENDENCIES	t	2026-04-01 11:43:11.199024	2026-04-01 17:44:37.426169
2e8473ae-835e-4ea5-9233-9a740e415934	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_TASK	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
b8d7b74a-e3db-4ad7-83d4-bf0cea19f9ce	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_COMMENT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
3de8fd51-827c-4de5-a086-5c7438ed1093	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_COMMENT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
9f0cdc9f-7d6f-4880-a4de-dc5da5161c4d	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_COMMENT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
cc881e66-c213-403a-8359-033feb6013a5	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_ATTACHMENT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
c2b95954-e150-42b1-9f77-f8c3d24f9013	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_ATTACHMENT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
672b0eab-53b0-4ec5-b925-3f2695cd46ab	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_ATTACHMENT	t	2026-04-01 17:44:37.426169	2026-04-01 17:44:37.426169
\.


--
-- TOC entry 5354 (class 0 OID 18715)
-- Dependencies: 238
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
\.


--
-- TOC entry 5030 (class 2606 OID 18731)
-- Name: app_user app_user_org_id_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_email_key UNIQUE (org_id, email);


--
-- TOC entry 5032 (class 2606 OID 18733)
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- TOC entry 5036 (class 2606 OID 18735)
-- Name: attachment attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- TOC entry 5138 (class 2606 OID 19102)
-- Name: business_unit business_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_pkey PRIMARY KEY (id);


--
-- TOC entry 5041 (class 2606 OID 18737)
-- Name: organization organization_azure_tenant_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_azure_tenant_id_key UNIQUE (azure_tenant_id);


--
-- TOC entry 5043 (class 2606 OID 18739)
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- TOC entry 5045 (class 2606 OID 18741)
-- Name: platform_user platform_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_email_key UNIQUE (email);


--
-- TOC entry 5047 (class 2606 OID 18743)
-- Name: platform_user platform_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_pkey PRIMARY KEY (id);


--
-- TOC entry 5058 (class 2606 OID 18745)
-- Name: project_cost project_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_pkey PRIMARY KEY (id);


--
-- TOC entry 5061 (class 2606 OID 18747)
-- Name: project_link project_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5052 (class 2606 OID 18749)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- TOC entry 5054 (class 2606 OID 18751)
-- Name: project project_project_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_project_code_key UNIQUE (project_code);


--
-- TOC entry 5064 (class 2606 OID 18753)
-- Name: project_task_sequence project_task_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_pkey PRIMARY KEY (id);


--
-- TOC entry 5066 (class 2606 OID 18755)
-- Name: project_task_sequence project_task_sequence_project_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_key UNIQUE (project_id);


--
-- TOC entry 5069 (class 2606 OID 18757)
-- Name: resource_cost resource_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_pkey PRIMARY KEY (id);


--
-- TOC entry 5071 (class 2606 OID 18759)
-- Name: resource_cost resource_cost_user_id_effective_from_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_effective_from_key UNIQUE (user_id, effective_from);


--
-- TOC entry 5131 (class 2606 OID 19056)
-- Name: role_permission role_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_pkey PRIMARY KEY (role, permission_key);


--
-- TOC entry 5074 (class 2606 OID 18761)
-- Name: sprint sprint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_pkey PRIMARY KEY (id);


--
-- TOC entry 5077 (class 2606 OID 18763)
-- Name: tag tag_org_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_name_key UNIQUE (org_id, name);


--
-- TOC entry 5079 (class 2606 OID 18765)
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- TOC entry 5092 (class 2606 OID 18767)
-- Name: task_comment task_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_pkey PRIMARY KEY (id);


--
-- TOC entry 5096 (class 2606 OID 18769)
-- Name: task_link task_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5098 (class 2606 OID 18771)
-- Name: task_link task_link_source_task_id_target_task_id_link_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_target_task_id_link_type_key UNIQUE (source_task_id, target_task_id, link_type);


--
-- TOC entry 5086 (class 2606 OID 18773)
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- TOC entry 5102 (class 2606 OID 18775)
-- Name: task_tag_mapping task_tag_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_pkey PRIMARY KEY (task_id, tag_id);


--
-- TOC entry 5088 (class 2606 OID 18777)
-- Name: task task_task_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_task_code_key UNIQUE (task_code);


--
-- TOC entry 5108 (class 2606 OID 18779)
-- Name: time_log time_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5113 (class 2606 OID 18781)
-- Name: timesheet timesheet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_pkey PRIMARY KEY (id);


--
-- TOC entry 5141 (class 2606 OID 19104)
-- Name: business_unit uq_business_unit_org_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT uq_business_unit_org_name UNIQUE (org_id, name);


--
-- TOC entry 5134 (class 2606 OID 19073)
-- Name: user_permission uq_user_permission; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT uq_user_permission UNIQUE (user_id, permission_key);


--
-- TOC entry 5126 (class 2606 OID 18783)
-- Name: user_project_mapping uq_user_project_mapping_user_project_role; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT uq_user_project_mapping_user_project_role UNIQUE (user_id, project_id, project_role);


--
-- TOC entry 5117 (class 2606 OID 18785)
-- Name: user_daily_summary user_daily_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_pkey PRIMARY KEY (id);


--
-- TOC entry 5119 (class 2606 OID 18787)
-- Name: user_daily_summary user_daily_summary_user_id_summary_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_summary_date_key UNIQUE (user_id, summary_date);


--
-- TOC entry 5136 (class 2606 OID 19071)
-- Name: user_permission user_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT user_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 5128 (class 2606 OID 18789)
-- Name: user_project_mapping user_project_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_pkey PRIMARY KEY (id);


--
-- TOC entry 5033 (class 1259 OID 18790)
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- TOC entry 5034 (class 1259 OID 18791)
-- Name: idx_app_user_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_org ON public.app_user USING btree (org_id);


--
-- TOC entry 5037 (class 1259 OID 18792)
-- Name: idx_attachment_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_org ON public.attachment USING btree (org_id);


--
-- TOC entry 5038 (class 1259 OID 18793)
-- Name: idx_attachment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_task ON public.attachment USING btree (task_id);


--
-- TOC entry 5139 (class 1259 OID 19110)
-- Name: idx_business_unit_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_business_unit_org ON public.business_unit USING btree (org_id);


--
-- TOC entry 5039 (class 1259 OID 18794)
-- Name: idx_organization_azure_tenant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_organization_azure_tenant ON public.organization USING btree (azure_tenant_id);


--
-- TOC entry 5048 (class 1259 OID 18795)
-- Name: idx_project_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_code ON public.project USING btree (project_code);


--
-- TOC entry 5056 (class 1259 OID 18796)
-- Name: idx_project_cost_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_cost_project ON public.project_cost USING btree (project_id);


--
-- TOC entry 5059 (class 1259 OID 18797)
-- Name: idx_project_link_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_link_project ON public.project_link USING btree (project_id);


--
-- TOC entry 5049 (class 1259 OID 18798)
-- Name: idx_project_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_org ON public.project USING btree (org_id);


--
-- TOC entry 5062 (class 1259 OID 18799)
-- Name: idx_project_task_sequence_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_task_sequence_project ON public.project_task_sequence USING btree (project_id);


--
-- TOC entry 5050 (class 1259 OID 19089)
-- Name: idx_project_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_type ON public.project USING btree (project_type);


--
-- TOC entry 5067 (class 1259 OID 18800)
-- Name: idx_resource_cost_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_resource_cost_user ON public.resource_cost USING btree (user_id);


--
-- TOC entry 5129 (class 1259 OID 19079)
-- Name: idx_role_permission_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_role_permission_role ON public.role_permission USING btree (role);


--
-- TOC entry 5072 (class 1259 OID 18801)
-- Name: idx_sprint_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sprint_project ON public.sprint USING btree (project_id);


--
-- TOC entry 5075 (class 1259 OID 18802)
-- Name: idx_tag_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tag_org ON public.tag USING btree (org_id);


--
-- TOC entry 5080 (class 1259 OID 18803)
-- Name: idx_task_assignee; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_assignee ON public.task USING btree (assigned_to);


--
-- TOC entry 5081 (class 1259 OID 18804)
-- Name: idx_task_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_code ON public.task USING btree (task_code);


--
-- TOC entry 5089 (class 1259 OID 18805)
-- Name: idx_task_comment_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_parent ON public.task_comment USING btree (parent_comment_id);


--
-- TOC entry 5090 (class 1259 OID 18806)
-- Name: idx_task_comment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_task ON public.task_comment USING btree (task_id);


--
-- TOC entry 5093 (class 1259 OID 18807)
-- Name: idx_task_link_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_source ON public.task_link USING btree (source_task_id);


--
-- TOC entry 5094 (class 1259 OID 18808)
-- Name: idx_task_link_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_target ON public.task_link USING btree (target_task_id);


--
-- TOC entry 5082 (class 1259 OID 18809)
-- Name: idx_task_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_org ON public.task USING btree (org_id);


--
-- TOC entry 5083 (class 1259 OID 18810)
-- Name: idx_task_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_project ON public.task USING btree (project_id);


--
-- TOC entry 5084 (class 1259 OID 18811)
-- Name: idx_task_sprint; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_sprint ON public.task USING btree (sprint_id);


--
-- TOC entry 5099 (class 1259 OID 18812)
-- Name: idx_task_tag_mapping_tag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_tag ON public.task_tag_mapping USING btree (tag_id);


--
-- TOC entry 5100 (class 1259 OID 18813)
-- Name: idx_task_tag_mapping_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_task ON public.task_tag_mapping USING btree (task_id);


--
-- TOC entry 5103 (class 1259 OID 18814)
-- Name: idx_time_log_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_date ON public.time_log USING btree (log_date);


--
-- TOC entry 5104 (class 1259 OID 18815)
-- Name: idx_time_log_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_task ON public.time_log USING btree (task_id);


--
-- TOC entry 5105 (class 1259 OID 18816)
-- Name: idx_time_log_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user ON public.time_log USING btree (user_id);


--
-- TOC entry 5106 (class 1259 OID 18817)
-- Name: idx_time_log_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user_date ON public.time_log USING btree (user_id, log_date);


--
-- TOC entry 5109 (class 1259 OID 18818)
-- Name: idx_timesheet_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_org ON public.timesheet USING btree (org_id);


--
-- TOC entry 5110 (class 1259 OID 18819)
-- Name: idx_timesheet_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user ON public.timesheet USING btree (user_id);


--
-- TOC entry 5111 (class 1259 OID 18820)
-- Name: idx_timesheet_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user_date ON public.timesheet USING btree (user_id, entry_date);


--
-- TOC entry 5114 (class 1259 OID 18821)
-- Name: idx_user_daily_summary_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_date ON public.user_daily_summary USING btree (summary_date);


--
-- TOC entry 5115 (class 1259 OID 18822)
-- Name: idx_user_daily_summary_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_user ON public.user_daily_summary USING btree (user_id);


--
-- TOC entry 5132 (class 1259 OID 19080)
-- Name: idx_user_permission_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_permission_user_id ON public.user_permission USING btree (user_id);


--
-- TOC entry 5120 (class 1259 OID 18823)
-- Name: idx_user_project_mapping_approval_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_approval_status ON public.user_project_mapping USING btree (approval_status);


--
-- TOC entry 5121 (class 1259 OID 18824)
-- Name: idx_user_project_mapping_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project ON public.user_project_mapping USING btree (project_id);


--
-- TOC entry 5122 (class 1259 OID 18825)
-- Name: idx_user_project_mapping_project_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project_approval ON public.user_project_mapping USING btree (project_id, approval_status);


--
-- TOC entry 5123 (class 1259 OID 18826)
-- Name: idx_user_project_mapping_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user ON public.user_project_mapping USING btree (user_id);


--
-- TOC entry 5124 (class 1259 OID 18827)
-- Name: idx_user_project_mapping_user_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user_approval ON public.user_project_mapping USING btree (user_id, approval_status);


--
-- TOC entry 5055 (class 1259 OID 19090)
-- Name: uq_project_org_finance_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_project_org_finance_code ON public.project USING btree (org_id, finance_code) WHERE (finance_code IS NOT NULL);


--
-- TOC entry 5142 (class 2606 OID 18828)
-- Name: app_user app_user_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5143 (class 2606 OID 18833)
-- Name: attachment attachment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5144 (class 2606 OID 18838)
-- Name: attachment attachment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5145 (class 2606 OID 18843)
-- Name: attachment attachment_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.app_user(id);


--
-- TOC entry 5187 (class 2606 OID 19105)
-- Name: business_unit business_unit_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5188 (class 2606 OID 19111)
-- Name: business_unit business_unit_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.app_user(id);


--
-- TOC entry 5186 (class 2606 OID 19074)
-- Name: user_permission fk_user_permission_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT fk_user_permission_user FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- TOC entry 5149 (class 2606 OID 18848)
-- Name: project_cost project_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5150 (class 2606 OID 18853)
-- Name: project_cost project_cost_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5146 (class 2606 OID 19116)
-- Name: project project_finance_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_finance_member_id_fkey FOREIGN KEY (finance_member_id) REFERENCES public.app_user(id);


--
-- TOC entry 5151 (class 2606 OID 18858)
-- Name: project_link project_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5152 (class 2606 OID 18863)
-- Name: project_link project_link_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5147 (class 2606 OID 18868)
-- Name: project project_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.app_user(id);


--
-- TOC entry 5148 (class 2606 OID 18873)
-- Name: project project_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5153 (class 2606 OID 18878)
-- Name: project_task_sequence project_task_sequence_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5154 (class 2606 OID 18883)
-- Name: resource_cost resource_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5155 (class 2606 OID 18888)
-- Name: resource_cost resource_cost_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5156 (class 2606 OID 18893)
-- Name: sprint sprint_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5157 (class 2606 OID 18898)
-- Name: tag tag_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5158 (class 2606 OID 18903)
-- Name: task task_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.app_user(id);


--
-- TOC entry 5163 (class 2606 OID 18908)
-- Name: task_comment task_comment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5164 (class 2606 OID 18913)
-- Name: task_comment task_comment_parent_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.task_comment(id);


--
-- TOC entry 5165 (class 2606 OID 18918)
-- Name: task_comment task_comment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5166 (class 2606 OID 18923)
-- Name: task_comment task_comment_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5159 (class 2606 OID 18928)
-- Name: task task_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- TOC entry 5167 (class 2606 OID 18933)
-- Name: task_link task_link_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- TOC entry 5168 (class 2606 OID 18938)
-- Name: task_link task_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5169 (class 2606 OID 18943)
-- Name: task_link task_link_source_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_fkey FOREIGN KEY (source_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5170 (class 2606 OID 18948)
-- Name: task_link task_link_target_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_target_task_id_fkey FOREIGN KEY (target_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5160 (class 2606 OID 18953)
-- Name: task task_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5161 (class 2606 OID 18958)
-- Name: task task_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5162 (class 2606 OID 18963)
-- Name: task task_sprint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_sprint_id_fkey FOREIGN KEY (sprint_id) REFERENCES public.sprint(id);


--
-- TOC entry 5171 (class 2606 OID 18968)
-- Name: task_tag_mapping task_tag_mapping_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id) ON DELETE CASCADE;


--
-- TOC entry 5172 (class 2606 OID 18973)
-- Name: task_tag_mapping task_tag_mapping_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5173 (class 2606 OID 18978)
-- Name: time_log time_log_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5174 (class 2606 OID 18983)
-- Name: time_log time_log_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5175 (class 2606 OID 18988)
-- Name: time_log time_log_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5176 (class 2606 OID 18993)
-- Name: time_log time_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5177 (class 2606 OID 18998)
-- Name: timesheet timesheet_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5178 (class 2606 OID 19003)
-- Name: timesheet timesheet_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5179 (class 2606 OID 19008)
-- Name: user_daily_summary user_daily_summary_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5180 (class 2606 OID 19013)
-- Name: user_daily_summary user_daily_summary_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5181 (class 2606 OID 19018)
-- Name: user_project_mapping user_project_mapping_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5182 (class 2606 OID 19023)
-- Name: user_project_mapping user_project_mapping_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5183 (class 2606 OID 19028)
-- Name: user_project_mapping user_project_mapping_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5184 (class 2606 OID 19033)
-- Name: user_project_mapping user_project_mapping_requested_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_requested_by_user_id_fkey FOREIGN KEY (requested_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5185 (class 2606 OID 19038)
-- Name: user_project_mapping user_project_mapping_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


-- Completed on 2026-04-08 16:59:11

--
-- PostgreSQL database dump complete
--

\unrestrict Yp9357tJf4fuKvgPMe3yo0y9lsBfwhHp4Gxg5K3oo6zmonl0PzUbjHCUTfMbNxV

