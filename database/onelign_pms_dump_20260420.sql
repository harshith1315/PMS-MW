--
-- PostgreSQL database dump
--

\restrict cgkuKzLnN57rMQJpBNdadzdNHbk33TR2Mwm5mqC95TpqCPQxQndUvC85AQfzDgm

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-20 16:27:53

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
-- TOC entry 2 (class 3079 OID 22251)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5439 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 245 (class 1259 OID 22984)
-- Name: activity_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
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

--
-- TOC entry 220 (class 1259 OID 22262)
-- Name: app_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_user (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255),
    role character varying(50) DEFAULT 'USER'::character varying,
    designation character varying(255) DEFAULT NULL::character varying,
    is_leader boolean DEFAULT false,
    is_manager boolean DEFAULT false,
    status character varying(50) DEFAULT 'ACTIVE'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.app_user OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 22277)
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
-- TOC entry 222 (class 1259 OID 22290)
-- Name: business_unit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.business_unit (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    status character varying(50) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.business_unit OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 22962)
-- Name: chat_message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_message (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    session_id uuid NOT NULL,
    role character varying(20) NOT NULL,
    text text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.chat_message OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 22939)
-- Name: chat_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_session (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    user_id uuid NOT NULL,
    title character varying(255) DEFAULT 'New conversation'::character varying NOT NULL,
    started_at timestamp without time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone
);


ALTER TABLE public.chat_session OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 22901)
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    recipient_id uuid NOT NULL,
    task_id uuid NOT NULL,
    type character varying(50) NOT NULL,
    title character varying(255) NOT NULL,
    message text NOT NULL,
    metadata json,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.notification OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 22300)
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
-- TOC entry 224 (class 1259 OID 22310)
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
-- TOC entry 225 (class 1259 OID 22321)
-- Name: project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    project_code character varying(50) NOT NULL,
    business_unit character varying(100),
    manager_id uuid,
    status character varying(50) DEFAULT 'DRAFT'::character varying,
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
    deliverable_type character varying(50),
    execution_model character varying(50),
    delivery_manager_id uuid,
    sponsor_id uuid,
    created_by_id uuid,
    approved_by_id uuid,
    priority character varying(20) DEFAULT 'MEDIUM'::character varying,
    risk_level character varying(20) DEFAULT 'LOW'::character varying,
    actual_start_date date,
    actual_end_date date,
    milestone_template character varying(100),
    budget_approved numeric(15,2),
    currency character varying(10) DEFAULT 'INR'::character varying,
    cost_center_id character varying(100),
    billing_type character varying(20),
    contract_type character varying(20),
    revenue numeric(15,2),
    sprint_duration integer,
    iteration_start_day character varying(20),
    estimation_unit character varying(20),
    velocity_tracking boolean DEFAULT false,
    wip_limits integer,
    continuous_flow boolean DEFAULT false,
    phase_template character varying(100),
    stage_gates jsonb DEFAULT '[]'::jsonb,
    document_repository character varying(500),
    client_spoc character varying(255),
    contract_start_date date,
    contract_end_date date,
    comments text,
    description text,
    finance_member_id uuid,
    CONSTRAINT chk_project_budget_non_negative CHECK (((budget IS NULL) OR (budget >= (0)::numeric))),
    CONSTRAINT chk_project_type_values CHECK ((((project_type)::text = ANY (ARRAY[('SUPPORT'::character varying)::text, ('INTERNAL'::character varying)::text, ('CLIENT'::character varying)::text, ('MAINTENANCE'::character varying)::text, ('TIME_TRACKING'::character varying)::text])) OR (project_type IS NULL))),
    CONSTRAINT project_billing_type_check CHECK (((billing_type IS NULL) OR ((billing_type)::text = ANY (ARRAY[('FIXED_PRICE'::character varying)::text, ('TIME_AND_MATERIAL'::character varying)::text, ('RETAINER'::character varying)::text, ('NOT_BILLABLE'::character varying)::text])))),
    CONSTRAINT project_contract_type_check CHECK (((contract_type IS NULL) OR ((contract_type)::text = ANY (ARRAY[('FIXED'::character varying)::text, ('RENEWABLE'::character varying)::text, ('ONGOING'::character varying)::text])))),
    CONSTRAINT project_currency_check CHECK (((currency IS NULL) OR ((currency)::text = ANY (ARRAY[('USD'::character varying)::text, ('EUR'::character varying)::text, ('GBP'::character varying)::text, ('INR'::character varying)::text, ('AUD'::character varying)::text])))),
    CONSTRAINT project_deliverable_type_check CHECK (((deliverable_type IS NULL) OR ((deliverable_type)::text = ANY (ARRAY[('PRODUCT'::character varying)::text, ('PROJECT'::character varying)::text, ('SERVICE'::character varying)::text, ('SUPPORT'::character varying)::text])))),
    CONSTRAINT project_estimation_unit_check CHECK (((estimation_unit IS NULL) OR ((estimation_unit)::text = ANY (ARRAY[('STORY_POINTS'::character varying)::text, ('HOURS'::character varying)::text, ('DAYS'::character varying)::text, ('T_SHIRT'::character varying)::text])))),
    CONSTRAINT project_execution_model_check CHECK (((execution_model IS NULL) OR ((execution_model)::text = ANY (ARRAY[('AGILE'::character varying)::text, ('KANBAN'::character varying)::text, ('WATERFALL'::character varying)::text, ('HYBRID'::character varying)::text])))),
    CONSTRAINT project_priority_check CHECK (((priority IS NULL) OR ((priority)::text = ANY (ARRAY[('LOW'::character varying)::text, ('MEDIUM'::character varying)::text, ('HIGH'::character varying)::text, ('CRITICAL'::character varying)::text]))))
);


ALTER TABLE public.project OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 22352)
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
-- TOC entry 227 (class 1259 OID 22366)
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
-- TOC entry 228 (class 1259 OID 22379)
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
-- TOC entry 229 (class 1259 OID 22387)
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
-- TOC entry 230 (class 1259 OID 22398)
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
-- TOC entry 231 (class 1259 OID 22409)
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
-- TOC entry 232 (class 1259 OID 22419)
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
-- TOC entry 233 (class 1259 OID 22428)
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
-- TOC entry 234 (class 1259 OID 22441)
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
-- TOC entry 235 (class 1259 OID 22454)
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
-- TOC entry 236 (class 1259 OID 22464)
-- Name: task_tag_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_tag_mapping (
    task_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.task_tag_mapping OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 22469)
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
-- TOC entry 238 (class 1259 OID 22485)
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
-- TOC entry 239 (class 1259 OID 22500)
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
-- TOC entry 240 (class 1259 OID 22511)
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
-- TOC entry 241 (class 1259 OID 22524)
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
-- TOC entry 5433 (class 0 OID 22984)
-- Dependencies: 245
-- Data for Name: activity_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_log (id, org_id, actor_user_id, actor_name, actor_email, method, resource_type, resource_id, action_type, message, request_path, ip_address, user_agent, metadata, created_at) FROM stdin;
d544f5f1-f331-42e5-aec2-e82a409309b8	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 16:24:28.71736
b8cb0b08-c318-4d7c-b087-4a7272d59f65	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_OUT	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged out	/auth/logout	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 16:24:34.455094
\.


--
-- TOC entry 5408 (class 0 OID 22262)
-- Dependencies: 220
-- Data for Name: app_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_user (id, org_id, email, name, role, designation, is_leader, is_manager, status, created_at) FROM stdin;
b762cce3-dac1-4aa0-bc38-a8488eaf994f	1d105d8b-95d8-411e-9844-b6683e8b7f51	princy.joseph@bonbloc.com	princy	ORG_ADMIN	\N	f	f	ACTIVE	2026-03-19 14:23:34.808615
b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	manager@acme.com	Jane	ORG_ADMIN	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231
b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	developer1@acme.com	Alice	USER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231
b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	developer2@acme.com	Bob	USER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231
b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	qa@acme.com	Charlie	USER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231
65b2f9f4-a049-4766-b6f6-4ecca8fb8de7	1d105d8b-95d8-411e-9844-b6683e8b7f51	santhosh.sankar@bonbloc.com	Santhosh	USER	\N	f	f	ACTIVE	2026-03-19 17:57:36.529875
6d7b3010-5f27-4495-b7b1-85d6f734657f	1d105d8b-95d8-411e-9844-b6683e8b7f51	pranathi@bonbloc.com	Pranathi	USER	Manager	t	t	ACTIVE	2026-03-26 23:01:27.496598
d4c27066-b249-42ef-ac9d-bccbd7cced4e	1d105d8b-95d8-411e-9844-b6683e8b7f51	test@gmail.com	sai ram	MANAGER	director	t	t	ACTIVE	2026-03-26 23:56:13.01749
edb1541e-efee-435d-a4cd-6e7da392464a	1d105d8b-95d8-411e-9844-b6683e8b7f51	harshith.kanumuri@bonbloc.com	Harshith Kanumuri	ORG_ADMIN	DEV	t	t	ACTIVE	2026-03-26 22:48:28.989947
fbfbe066-9918-412c-835d-f92a30ac44e4	1d105d8b-95d8-411e-9844-b6683e8b7f51	narayanareddy.mallidi@bonbloc.com	Narayana Reddy Mallidi	ORG_ADMIN	DEV	t	t	ACTIVE	2026-03-27 10:02:54.511576
8710daee-65e4-4ffb-96d7-d19a6fccc3a8	1d105d8b-95d8-411e-9844-b6683e8b7f51	rahul.ravi@bonbloc.com	Rahul Ravi	USER	\N	f	f	ACTIVE	2026-04-02 06:20:52.533434
9f249425-c274-4eaa-b142-108b074503bd	1d105d8b-95d8-411e-9844-b6683e8b7f51	veluprasath.durai@bonbloc.com	Velu Prasath Durai	USER	\N	f	f	ACTIVE	2026-04-02 06:30:26.711782
47a94aa7-e849-40f1-9602-f08b894bdc5b	1d105d8b-95d8-411e-9844-b6683e8b7f51	krishnapranathi.dande@bonbloc.com	Krishna Pranathi Dande	USER	\N	f	f	ACTIVE	2026-04-02 06:55:21.209343
01a59c21-81cf-4931-9986-66a01a4f77d1	1d105d8b-95d8-411e-9844-b6683e8b7f51	sriram.pupathy@bonbloc.com	Sriram Pupathy	USER	\N	f	f	ACTIVE	2026-04-02 07:13:04.386918
701adbb8-edd0-409a-a040-d20f70d60edd	1d105d8b-95d8-411e-9844-b6683e8b7f51	manikiran.chegondi@bonbloc.com	Mani Kiran Chegondi	ORG_ADMIN	\N	f	f	ACTIVE	2026-04-01 15:45:05.032557
0b6ad5c0-f1b4-4865-8643-634eedf36d60	1d105d8b-95d8-411e-9844-b6683e8b7f51	sairam.mathi@bonbloc.com	sairam.mathi	ORG_ADMIN	\N	f	f	ACTIVE	2026-04-03 07:12:13.073759
a73473b6-e425-4843-b972-94936b9eeb23	1d105d8b-95d8-411e-9844-b6683e8b7f51	EFGH@gmail.com	EFGH	MANAGER	Team Lead	t	t	DEACTIVATED	2026-04-03 04:53:51.081401
8a00286c-b21d-46f7-816f-b9be2a66b62f	1d105d8b-95d8-411e-9844-b6683e8b7f51	abcd@bonbloc.com	Abcd	MANAGER	Manager	t	t	DEACTIVATED	2026-04-02 08:25:09.639662
f1eaa5c8-2d78-471b-937e-50a10eddf609	1d105d8b-95d8-411e-9844-b6683e8b7f51	cmnk2815@gmail.com	cmnk2815	MANAGER	\N	f	f	DEACTIVATED	2026-04-02 08:17:40.77174
1400ccae-fcaa-452d-9d61-30afb052b604	1d105d8b-95d8-411e-9844-b6683e8b7f51	komali.avirneni@bonbloc.com	Komali Avirneni	USER	\N	f	f	ACTIVE	2026-04-01 11:45:59.188686
08eb8d8d-46cf-4c92-a210-2d09cf7a550f	1d105d8b-95d8-411e-9844-b6683e8b7f51	durai.appadurai@bonbloc.com	Durai Appadurai	ORG_ADMIN	\N	f	f	ACTIVE	2026-04-03 07:11:04.719542
b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	alicia.antony@bonbloc.com	Alicia Antony	ORG_ADMIN	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231
2e745634-fcc5-46db-9651-a6cfe30aa537	1d105d8b-95d8-411e-9844-b6683e8b7f51	ganthikugan.jaipal@bonbloc.com	ganthikugan.jaipal	ORG_ADMIN	\N	f	f	ACTIVE	2026-04-10 16:48:35.336614
55d1bcf6-7a5f-4cf5-8c49-ab0051846bfa	1d105d8b-95d8-411e-9844-b6683e8b7f51	swaminathan.rajagopalan@bonbloc.com	swaminathan.rajagopalan	ORG_ADMIN	\N	f	f	ACTIVE	2026-04-10 16:52:59.283057
270dc0a2-82c3-452b-947a-f7bdbb5e883b	1d105d8b-95d8-411e-9844-b6683e8b7f51	saieswarkumar.anupoju@bonbloc.com	Sai Eswar Kumar Anupoju	USER	\N	f	f	ACTIVE	2026-04-02 06:56:57.543345
\.


--
-- TOC entry 5409 (class 0 OID 22277)
-- Dependencies: 221
-- Data for Name: attachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attachment (id, org_id, task_id, file_name, file_type, file_size, s3_key, uploaded_by, status, created_at) FROM stdin;
0b432db8-80e5-4f85-a370-609448813852	1d105d8b-95d8-411e-9844-b6683e8b7f51	86d4af01-800a-435d-ac7c-d4594c1f495b	Screenshot 2026-03-28 135646.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/86d4af01-800a-435d-ac7c-d4594c1f495b/83071b02-a25f-4221-bd47-b11516a8e4da.png	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-28 14:11:59.09885
90bc8b6e-5c99-4d10-abdc-c9e330aa7f0d	1d105d8b-95d8-411e-9844-b6683e8b7f51	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	Screenshot 2026-03-28 135646.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/c5b77141-3868-4b1b-849a-e9ffd1e5b4a4/4ef832b5-7d99-4620-93fc-3ea3e7329368.png	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-04-07 05:01:24.509587
3928966c-bec6-4df6-9856-58e0028e1d93	1d105d8b-95d8-411e-9844-b6683e8b7f51	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	Screenshot 2025-08-28 144154.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/c5b77141-3868-4b1b-849a-e9ffd1e5b4a4/c185d150-10cd-4f87-a169-78070c276455.png	1400ccae-fcaa-452d-9d61-30afb052b604	ACTIVE	2026-04-07 08:51:39.529558
\.


--
-- TOC entry 5410 (class 0 OID 22290)
-- Dependencies: 222
-- Data for Name: business_unit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.business_unit (id, org_id, name, status, created_at) FROM stdin;
36c4f874-5aa5-4a99-9361-911fea0e5eb9	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Engineering	ACTIVE	2026-04-01 11:16:35.682725
0e7662da-81ac-476c-bf8f-1a91275cdd50	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Product	ACTIVE	2026-04-01 11:16:35.682725
a186ebe2-6aa2-4bc7-b4b6-6961c610c5da	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Design	ACTIVE	2026-04-01 11:16:35.682725
7e0db4ce-21ee-49ee-8327-2bf012dc7937	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Marketing	ACTIVE	2026-04-01 11:16:35.682725
03e7d5d0-4240-462c-a84d-156ca43874ac	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Operations	ACTIVE	2026-04-01 11:16:35.682725
ee83e77f-7d5e-4499-b5cb-7d93f05d435d	1d105d8b-95d8-411e-9844-b6683e8b7f51	Marketing	INACTIVE	2026-04-01 11:16:35.682725
f497a687-70c3-470a-a7af-e70cc224a1ea	1d105d8b-95d8-411e-9844-b6683e8b7f51	Engineering	INACTIVE	2026-04-01 11:16:35.682725
bc9d4299-678d-4759-a824-499a2b56a171	1d105d8b-95d8-411e-9844-b6683e8b7f51	Design	INACTIVE	2026-04-01 11:16:35.682725
55bb480b-297c-424f-bf05-8ab471366e0a	1d105d8b-95d8-411e-9844-b6683e8b7f51	AI Appliances	ACTIVE	2026-04-01 11:31:51.957415
04b47b7b-b06c-4441-acd1-7aea89aadde6	1d105d8b-95d8-411e-9844-b6683e8b7f51	AI SAAS	ACTIVE	2026-04-01 11:16:35.682725
325e8743-5704-40e0-ae85-11519c117b6f	1d105d8b-95d8-411e-9844-b6683e8b7f51	AI Services	ACTIVE	2026-04-01 11:16:35.682725
c9f96bf8-ed9d-4254-8c28-084e36c6ecfa	1d105d8b-95d8-411e-9844-b6683e8b7f51	Sales	INACTIVE	2026-04-01 15:30:56.282453
\.


--
-- TOC entry 5432 (class 0 OID 22962)
-- Dependencies: 244
-- Data for Name: chat_message; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_message (id, session_id, role, text, created_at) FROM stdin;
5f1cf5ff-f66b-4423-8afc-7b8386c4de0d	90584828-75d3-4716-810d-65fa5603e5cf	user	hii	2026-04-20 14:52:46.230062
5c941b23-cb92-4674-8bc4-c44b1e5ae424	90584828-75d3-4716-810d-65fa5603e5cf	assistant	Hello, Harshith. How can I assist you today?	2026-04-20 14:52:46.230062
8a610ab9-5e9c-48da-a675-114bf558de8d	7e92e8ba-d2fd-4f0b-960a-d02268f2c76f	user	hi	2026-04-20 15:09:39.406802
a26c4b94-539f-4dbd-9ce4-0500b3f48eaa	7e92e8ba-d2fd-4f0b-960a-d02268f2c76f	assistant	Hello, Harshith. How can I assist you today?	2026-04-20 15:09:39.406802
4e8ae3a6-4603-47bc-9f80-3fd9e1e417cd	7e92e8ba-d2fd-4f0b-960a-d02268f2c76f	user	what are the projects	2026-04-20 15:10:11.212999
61759ce9-b2f1-44b2-b066-165e91ef94fb	7e92e8ba-d2fd-4f0b-960a-d02268f2c76f	assistant	Here are the active projects:\n\n- API Integration (API), Engineering, ACTIVE, Manager: Jane\n- Website Redesign (WEB), Marketing, ACTIVE, Manager: Jane\n- Mobile App Development (MOB), Engineering, ACTIVE, Manager: Jane\n- CEL (PROJ-1234), Onelign Software Applications, ACTIVE, Manager: Pranathi\n- ERP (PROJ-1235), Public Sector, ACTIVE, Manager: Harshith Kanumuri\n- LMS (PROJ-1236), Onelign Software Applications, ACTIVE, Manager: Narayana Reddy Mallidi\n- FPO Marketplace (FMAA884), ACTIVE, Manager: Alicia Antony\n- Cold Chain (PROJ-123), Onelign Software Applications, ACTIVE, Manager: Alicia Antony\n- FPO (FPO-101), Onelign Software Applications, ACTIVE, Manager: Alicia Antony	2026-04-20 15:10:11.212999
d37fd582-79f8-4603-98c6-8e30f02c376d	7e92e8ba-d2fd-4f0b-960a-d02268f2c76f	user	hi	2026-04-20 15:19:32.05638
ef880421-a3f5-4006-ac13-87105642bf0e	7e92e8ba-d2fd-4f0b-960a-d02268f2c76f	assistant	Hello, Harshith. How can I assist you today?	2026-04-20 15:19:32.05638
035eaa45-bbff-4f98-866c-c84b61d5bae3	7e92e8ba-d2fd-4f0b-960a-d02268f2c76f	user	what are my tasks	2026-04-20 15:19:43.532612
cb1b3393-aa55-456c-9d23-e706931b9081	7e92e8ba-d2fd-4f0b-960a-d02268f2c76f	assistant	I'm unable to provide information about your tasks as you do not have access to that data. If you need assistance with something else, feel free to ask.	2026-04-20 15:19:43.532612
\.


--
-- TOC entry 5431 (class 0 OID 22939)
-- Dependencies: 243
-- Data for Name: chat_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_session (id, org_id, user_id, title, started_at, ended_at) FROM stdin;
504dc540-f8df-4cd9-a10b-853cae1c67da	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	New conversation	2026-04-20 14:30:50.421256	2026-04-20 14:30:59.406+05:30
673e875b-2728-49ba-8073-51da72ea24cf	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	New conversation	2026-04-20 14:31:08.137283	2026-04-20 14:37:28.338+05:30
341a36d2-6826-4a85-8938-c155e7094f2c	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	New conversation	2026-04-20 14:39:36.073908	2026-04-20 14:39:50.015+05:30
26000b9d-19c7-467d-a87e-a66242d8bbaa	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	New conversation	2026-04-20 14:45:56.175672	2026-04-20 14:46:05.635+05:30
90584828-75d3-4716-810d-65fa5603e5cf	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	hii	2026-04-20 14:52:43.973409	2026-04-20 14:52:48.604+05:30
7e92e8ba-d2fd-4f0b-960a-d02268f2c76f	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	hi	2026-04-20 15:09:37.31353	2026-04-20 15:19:55.012+05:30
\.


--
-- TOC entry 5430 (class 0 OID 22901)
-- Dependencies: 242
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, recipient_id, task_id, type, title, message, metadata, is_read, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5411 (class 0 OID 22300)
-- Dependencies: 223
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization (id, name, azure_tenant_id, status, created_at) FROM stdin;
1d105d8b-95d8-411e-9844-b6683e8b7f51	BONbLOC Technologies	7915d0a8-0a13-4824-ba52-43a1ad694c42	ACTIVE	2026-03-19 14:23:34.808615
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Acme Corporation	null	ACTIVE	2026-03-18 20:14:20.339403
\.


--
-- TOC entry 5412 (class 0 OID 22310)
-- Dependencies: 224
-- Data for Name: platform_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.platform_user (id, email, name, role, status, created_at) FROM stdin;
d2c3a954-c0f7-4718-92be-e97449206874	oviiyadominic@gmail.com	Oviiya Dominic	ADMIN	ACTIVE	2026-03-19 14:28:31.763376
\.


--
-- TOC entry 5413 (class 0 OID 22321)
-- Dependencies: 225
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project (id, org_id, name, project_code, business_unit, manager_id, status, created_at, finance_code, budget, kickoff_date, start_date, end_date, project_type, client_name, client_location, purpose, cost_management, tech_stack, dependencies, deliverable_type, execution_model, delivery_manager_id, sponsor_id, created_by_id, approved_by_id, priority, risk_level, actual_start_date, actual_end_date, milestone_template, budget_approved, currency, cost_center_id, billing_type, contract_type, revenue, sprint_duration, iteration_start_day, estimation_unit, velocity_tracking, wip_limits, continuous_flow, phase_template, stage_gates, document_repository, client_spoc, contract_start_date, contract_end_date, comments, description, finance_member_id) FROM stdin;
c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Mobile App Development	MOB	Engineering	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Website Redesign	WEB	Marketing	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	API Integration	API	Engineering	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
6564025c-356b-4e87-96e6-44360bde99f0	1d105d8b-95d8-411e-9844-b6683e8b7f51	FPO	FPO-101	Onelign Software Applications	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-19 18:10:00.907041	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
cc556634-367e-4ff9-a331-a000d92c89e3	1d105d8b-95d8-411e-9844-b6683e8b7f51	COld Chain	PROJ-123	Onelign Software Applications	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-19 18:31:10.938558	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
d901321d-b502-4a26-8cb7-483ca57ba66d	1d105d8b-95d8-411e-9844-b6683e8b7f51	CEL	PROJ-1234	Onelign Software Applications	6d7b3010-5f27-4495-b7b1-85d6f734657f	ACTIVE	2026-03-26 23:01:53.185218	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
eeb797e6-385c-4376-a607-9663e4313e60	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS	PROJ-1236	Onelign Software Applications	fbfbe066-9918-412c-835d-f92a30ac44e4	ACTIVE	2026-03-27 10:03:20.826154	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
71bb0f85-cdde-469a-900d-e8761da76e45	1d105d8b-95d8-411e-9844-b6683e8b7f51	ERP	PROJ-1235	Public Sector	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-26 23:02:59.560141	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
1123d42d-aa3a-4c19-93e0-332366c7a4b9	1d105d8b-95d8-411e-9844-b6683e8b7f51	Anganwadi	A1249	Public Sector	8a00286c-b21d-46f7-816f-b9be2a66b62f	ARCHIVED	2026-04-02 08:28:37.351868	FIN-2026-002	0.12	2026-04-05	2026-05-10	2026-09-10	\N	Govt	Hyderabad	Anganwadi	HI	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
10ac6760-95d0-4f5d-acb5-52126ff0c7e1	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS-PH	PROJ-1237	Public Sector	edb1541e-efee-435d-a4cd-6e7da392464a	ARCHIVED	2026-03-27 12:19:05.01159	FIN1234	1000000.00	2026-04-01	2026-04-01	2027-04-01	\N	PH	PH	\N	\N	["React JS"]	["SMS Gate way", "SMTP"]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
0a6d9f1d-67f1-4f8d-b9fc-314b302e69ba	1d105d8b-95d8-411e-9844-b6683e8b7f51	FPO Marketplace	FMAA884	55bb480b-297c-424f-bf05-8ab471366e0a	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-04-10 17:05:19.652321	\N	\N	2026-03-02	2026-03-02	2026-05-31	INTERNAL	\N	\N	\N	\N	[]	[]	PRODUCT	AGILE	2e745634-fcc5-46db-9651-a6cfe30aa537	08eb8d8d-46cf-4c92-a210-2d09cf7a550f	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	MEDIUM	MEDIUM	\N	\N	Web Application	\N	USD	\N	\N	\N	\N	\N	MONDAY	HOURS	t	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
a3f75871-11e5-49ba-9fb7-2659f7283f2a	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS	PROJ_101	Onelign Software Applications	b762cce3-dac1-4aa0-bc38-a8488eaf994f	ARCHIVED	2026-03-19 17:48:25.948931	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5414 (class 0 OID 22352)
-- Dependencies: 226
-- Data for Name: project_cost; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_cost (id, org_id, project_id, cost_type, amount, description, cost_date, status, created_at) FROM stdin;
\.


--
-- TOC entry 5415 (class 0 OID 22366)
-- Dependencies: 227
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
-- TOC entry 5416 (class 0 OID 22379)
-- Dependencies: 228
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
bf4cd034-e5c1-4bcf-bd08-9669e7c06605	1123d42d-aa3a-4c19-93e0-332366c7a4b9	0	2026-04-02 08:28:37.351868
207a9436-a4b3-48d3-82d1-61b42740693b	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	6	2026-03-27 12:19:05.01159
47728cde-8c52-43c0-8e8e-1838a93f53ce	0a6d9f1d-67f1-4f8d-b9fc-314b302e69ba	1	2026-04-10 17:05:19.652321
\.


--
-- TOC entry 5417 (class 0 OID 22387)
-- Dependencies: 229
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
-- TOC entry 5418 (class 0 OID 22398)
-- Dependencies: 230
-- Data for Name: role_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permission (role, permission_key, is_granted, created_at, updated_at) FROM stdin;
MANAGER	VIEW_ORGANIZATION	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	EDIT_ORGANIZATION	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	DELETE_ORGANIZATION	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	MANAGE_USERS	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	MANAGE_BUSINESS_UNITS	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	VIEW_BUSINESS_UNIT	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	CREATE_BUSINESS_UNIT	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	EDIT_BUSINESS_UNIT	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	DELETE_BUSINESS_UNIT	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	VIEW_USER	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	EDIT_USER	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	EDIT_USER_ROLE	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	EDIT_USER_STATUS	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	CREATE_PROJECT	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
MANAGER	VIEW_PROJECT	t	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
MANAGER	EDIT_PROJECT	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	DELETE_PROJECT	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	EDIT_PROJECT_DETAILS	t	2026-04-01 10:59:10.673115	2026-04-01 15:28:50.822046
MANAGER	VIEW_PROJECT_DETAILS	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	EDIT_TECH_STACK	t	2026-04-01 10:59:10.673115	2026-04-01 15:28:50.822046
MANAGER	EDIT_DEPENDENCIES	t	2026-04-01 10:59:10.673115	2026-04-01 15:28:50.822046
MANAGER	VIEW_BUDGET	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	VIEW_FINANCE	t	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
MANAGER	VIEW_FINANCE_CODE	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	CREATE_TASK	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	EDIT_TASK	t	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
MANAGER	DELETE_TASK	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
MANAGER	CREATE_COMMENT	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	EDIT_COMMENT	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	DELETE_COMMENT	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	VIEW_ATTACHMENT	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	CREATE_ATTACHMENT	t	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	DELETE_ATTACHMENT	f	2026-04-01 15:28:50.822046	2026-04-01 15:28:50.822046
MANAGER	MANAGE_SPRINT	t	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
MANAGER	MANAGE_LINKS	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
MANAGER	MANAGE_LEADERSHIP	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
MANAGER	ASSIGN_USERS	t	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
MANAGER	VIEW_REPORTS	t	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
MANAGER	LOG_TIME	t	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.822046
USER	VIEW_ORGANIZATION	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	EDIT_ORGANIZATION	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	DELETE_ORGANIZATION	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	MANAGE_USERS	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	MANAGE_BUSINESS_UNITS	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	VIEW_BUSINESS_UNIT	t	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	CREATE_BUSINESS_UNIT	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	EDIT_BUSINESS_UNIT	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	DELETE_BUSINESS_UNIT	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	VIEW_USER	t	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	EDIT_USER	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	EDIT_USER_ROLE	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	EDIT_USER_STATUS	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	CREATE_PROJECT	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
USER	VIEW_PROJECT	t	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
USER	EDIT_PROJECT	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	DELETE_PROJECT	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	EDIT_PROJECT_DETAILS	f	2026-04-01 10:59:10.673115	2026-04-01 15:28:50.84937
USER	VIEW_PROJECT_DETAILS	t	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	EDIT_TECH_STACK	f	2026-04-01 10:59:10.673115	2026-04-01 15:28:50.84937
USER	EDIT_DEPENDENCIES	f	2026-04-01 10:59:10.673115	2026-04-01 15:28:50.84937
USER	VIEW_BUDGET	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	VIEW_FINANCE	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
USER	VIEW_FINANCE_CODE	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	CREATE_TASK	t	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	EDIT_TASK	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
USER	DELETE_TASK	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
USER	CREATE_COMMENT	t	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	EDIT_COMMENT	t	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	DELETE_COMMENT	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	VIEW_ATTACHMENT	t	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	CREATE_ATTACHMENT	t	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	DELETE_ATTACHMENT	f	2026-04-01 15:28:50.84937	2026-04-01 15:28:50.84937
USER	MANAGE_SPRINT	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
USER	MANAGE_LINKS	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
USER	MANAGE_LEADERSHIP	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
USER	ASSIGN_USERS	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
USER	VIEW_REPORTS	f	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
USER	LOG_TIME	t	2026-03-31 11:37:13.525336	2026-04-01 15:28:50.84937
\.


--
-- TOC entry 5419 (class 0 OID 22409)
-- Dependencies: 231
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
1b57119f-2766-4655-929b-ad17c636b07d	1123d42d-aa3a-4c19-93e0-332366c7a4b9	SP3	2026-04-08	2026-09-08	PLANNED	2026-04-02 08:29:11.984059	YYY
72fa7535-4dbb-4d7d-97b3-05019f572520	0a6d9f1d-67f1-4f8d-b9fc-314b302e69ba	Sprint-1	2026-03-02	2026-03-27	ACTIVE	2026-04-10 18:08:26.106287	\N
\.


--
-- TOC entry 5420 (class 0 OID 22419)
-- Dependencies: 232
-- Data for Name: tag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tag (id, org_id, name, color, status, created_at) FROM stdin;
71eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Frontend	#3498DB	ACTIVE	2026-03-18 20:14:20.369254
72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Backend	#2ECC71	ACTIVE	2026-03-18 20:14:20.369254
73eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Database	#9B59B6	ACTIVE	2026-03-18 20:14:20.369254
74eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	UI/UX	#E74C3C	ACTIVE	2026-03-18 20:14:20.369254
75eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Security	#F39C12	ACTIVE	2026-03-18 20:14:20.369254
76eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Performance	#1ABC9C	ACTIVE	2026-03-18 20:14:20.369254
a67cc96e-c7b8-4cf7-833a-59698ea78902	1d105d8b-95d8-411e-9844-b6683e8b7f51	Feature	#21A1F1	ACTIVE	2026-04-20 14:10:54.997035
92f235f4-0b8b-4273-ab61-d1abcc701c0d	1d105d8b-95d8-411e-9844-b6683e8b7f51	Bug	#F44235	ACTIVE	2026-04-20 14:10:55.030531
b8daa7c3-a21a-48ec-8298-751c2fdd9590	1d105d8b-95d8-411e-9844-b6683e8b7f51	Tech debt	#FF9800	ACTIVE	2026-04-20 14:10:55.045305
\.


--
-- TOC entry 5421 (class 0 OID 22428)
-- Dependencies: 233
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
c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	\N	PROJ-1237-3	R&D Animation for login page	Search for animations	SUB_TASK	BLOCKED	HIGH	edb1541e-efee-435d-a4cd-6e7da392464a	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-31	2026-03-28 14:10:32.206133	\N
adbaf084-20b3-440a-b95d-bb082955ba46	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	\N	PROJ-1237-4	R&D Animations for login page	\N	SUB_TASK	TODO	MEDIUM	\N	270dc0a2-82c3-452b-947a-f7bdbb5e883b	\N	2026-04-08 11:35:22.090914	\N
7a03bf7e-cf9c-4c6c-8990-60ec141a00d4	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-5	do r & d	something	STORY	TODO	LOW	\N	270dc0a2-82c3-452b-947a-f7bdbb5e883b	2026-04-17	2026-04-09 05:40:14.711899	\N
5ebec24f-9811-452e-9e8b-056e01d6d610	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-6	testing task	some	TASK	TODO	MEDIUM	\N	270dc0a2-82c3-452b-947a-f7bdbb5e883b	2026-04-17	2026-04-09 05:41:01.705898	\N
85850f79-5d93-4b84-8c82-833ab4ccf4b0	1d105d8b-95d8-411e-9844-b6683e8b7f51	0a6d9f1d-67f1-4f8d-b9fc-314b302e69ba	72fa7535-4dbb-4d7d-97b3-05019f572520	FMAA884-1	Base Code	Develop Base Code	TASK	TODO	MEDIUM	\N	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-05-18	2026-04-10 18:02:55.828561	\N
\.


--
-- TOC entry 5422 (class 0 OID 22441)
-- Dependencies: 234
-- Data for Name: task_comment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_comment (id, org_id, task_id, user_id, parent_comment_id, comment_text, status, created_at, updated_at) FROM stdin;
a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	Please make sure to follow our design system guidelines for the login screen.	ACTIVE	2026-03-18 20:14:20.377379	\N
a2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Sure! I have the Figma link. Will follow the color palette and spacing guidelines.	ACTIVE	2026-03-18 20:14:20.377379	\N
a3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	Reproduced on iPhone 14 Pro with iOS 17.2. The button requires multiple taps.	ACTIVE	2026-03-18 20:14:20.377379	\N
a4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	Great progress! Lets add the animation for the CTA button.	ACTIVE	2026-03-18 20:14:20.377379	\N
37d8f2d7-2740-4ebe-8dcd-22d46300a612	1d105d8b-95d8-411e-9844-b6683e8b7f51	f0e9f76c-8905-4f8c-9667-aa2a202bf4a0	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	hello	ACTIVE	2026-03-20 14:47:48.196972	\N
35011d39-d64c-47c6-b214-586c1de6ef61	1d105d8b-95d8-411e-9844-b6683e8b7f51	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	edb1541e-efee-435d-a4cd-6e7da392464a	\N	good	ACTIVE	2026-03-28 14:11:13.966961	\N
6a191562-5a59-4daa-8906-9ecc8e6d26eb	1d105d8b-95d8-411e-9844-b6683e8b7f51	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	1400ccae-fcaa-452d-9d61-30afb052b604	\N	comment test	ACTIVE	2026-04-07 08:48:21.885911	\N
\.


--
-- TOC entry 5423 (class 0 OID 22454)
-- Dependencies: 235
-- Data for Name: task_link; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_link (id, org_id, source_task_id, target_task_id, link_type, created_by, created_at) FROM stdin;
91eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	84eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEPENDS_ON	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18 20:14:20.375602
92eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	RELATES_TO	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18 20:14:20.375602
93eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	86eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEPENDS_ON	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-18 20:14:20.375602
91062d25-7af6-48bb-9fed-2c20e9d65203	1d105d8b-95d8-411e-9844-b6683e8b7f51	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	PARENT_OF	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-28 14:10:32.206133
7e07fc3d-be55-4e08-81a0-c5188b31343f	1d105d8b-95d8-411e-9844-b6683e8b7f51	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	CHILD_OF	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-28 14:10:32.206133
9def0d6c-b623-4e03-ac3a-f94b2a2d98bc	1d105d8b-95d8-411e-9844-b6683e8b7f51	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	adbaf084-20b3-440a-b95d-bb082955ba46	PARENT_OF	270dc0a2-82c3-452b-947a-f7bdbb5e883b	2026-04-08 11:35:22.090914
febbf31f-8475-49be-ae5e-89dae83b4d67	1d105d8b-95d8-411e-9844-b6683e8b7f51	adbaf084-20b3-440a-b95d-bb082955ba46	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	CHILD_OF	270dc0a2-82c3-452b-947a-f7bdbb5e883b	2026-04-08 11:35:22.090914
\.


--
-- TOC entry 5424 (class 0 OID 22464)
-- Dependencies: 236
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
-- TOC entry 5425 (class 0 OID 22469)
-- Dependencies: 237
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
-- TOC entry 5426 (class 0 OID 22485)
-- Dependencies: 238
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
1b5e871b-d645-466b-8f3a-16f2e53769af	1d105d8b-95d8-411e-9844-b6683e8b7f51	fbfbe066-9918-412c-835d-f92a30ac44e4	2026-04-01	vgsd	cf	COMPLETED	2026-04-01 12:49:12.848289	2026-04-01 12:49:12.848289
dbd63f16-fd1d-44f9-8fe6-d5f1d7f1904c	1d105d8b-95d8-411e-9844-b6683e8b7f51	fbfbe066-9918-412c-835d-f92a30ac44e4	2026-04-01	bb	Here's a professional favicon design prompt for your project management tool:\n\n---\n\n## **Favicon Design Prompt**\n\n**"Create a modern, professional favicon (256x256px) for a project management application called 'onelign-pms'. The design should:**\n\n1. **Core Elements:**\n   - Feature a stylized checkmark or task icon merged with a circular/orb shape (representing the 'O' from 'onelign')\n   - Show completion/progress concept (clean lines, professional aesthetic)\n   - Incorporate a subtle upward trending arrow or network connection lines suggesting growth and collaboration\n\n2. **Visual Style:**\n   - Minimalist and geometric design\n   - Works perfectly at small sizes (16x16, 32x32, 64x64 pixels)\n   - Bold, clear lines with no unnecessary details\n   - Clean and modern look suitable for enterprise software\n\n3. **Color Palette:**\n   - Primary color: Deep blue (#0846AA) at the core\n   - Accent color: Vibrant green (#16A34A) for the checkmark/progress element\n   - White or light background-friendly\n   - Optional: Subtle gradient for depth\n\n4. **Style Examples:**\n   - Similar to: Jira, Monday.com, Asana, or Notion favicons\n   - Professional tech startup aesthetic\n   - Memorable and instantly recognizable\n\n5. **Format Requirements:**\n   - PNG/SVG with transparent background\n   - Square format (1:1 aspect ratio)\n   - Should be clear and legible from 16 pixels and up"\n\n---\n\n**Where to use this prompt:**\n- 🎨 **DALL-E** / Midjourney / Adobe Firefly (AI Image Generators)\n- 👨‍💼 Give to a designer on Fiverr/Upwork\n- 🏗️ Use with design tools like Figma, Illustrator\n\n**Once generated, save as:**\n- `favicon.ico` (16x16, 32x32, 48x48)\n- `favicon.png` (192x192, 512x512)\n- Place in `/public/` folder in your React app\n\nWould you like me to help you integrate the favicon into your app once you have the image?Here's a professional favicon design prompt for your project management tool:\n\n---\n\n## **Favicon Design Prompt**\n\n**"Create a modern, professional favicon (256x256px) for a project management application called 'onelign-pms'. The design should:**\n\n1. **Core Elements:**\n   - Feature a stylized checkmark or task icon merged with a circular/orb shape (representing the 'O' from 'onelign')\n   - Show completion/progress concept (clean lines, professional aesthetic)\n   - Incorporate a subtle upward trending arrow or network connection lines suggesting growth and collaboration\n\n2. **Visual Style:**\n   - Minimalist and geometric design\n   - Works perfectly at small sizes (16x16, 32x32, 64x64 pixels)\n   - Bold, clear lines with no unnecessary details\n   - Clean and modern look suitable for enterprise software\n\n3. **Color Palette:**\n   - Primary color: Deep blue (#0846AA) at the core\n   - Accent color: Vibrant green (#16A34A) for the checkmark/progress element\n   - White or light background-friendly\n   - Optional: Subtle gradient for depth\n\n4. **Style Examples:**\n   - Similar to: Jira, Monday.com, Asana, or Notion favicons\n   - Professional tech startup aesthetic\n   - Memorable and instantly recognizable\n\n5. **Format Requirements:**\n   - PNG/SVG with transparent background\n   - Square format (1:1 aspect ratio)\n   - Should be clear and legible from 16 pixels and up"\n\n---\n\n**Where to use this prompt:**\n- 🎨 **DALL-E** / Midjourney / Adobe Firefly (AI Image Generators)\n- 👨‍💼 Give to a designer on Fiverr/Upwork\n- 🏗️ Use with design tools like Figma, Illustrator\n\n**Once generated, save as:**\n- `favicon.ico` (16x16, 32x32, 48x48)\n- `favicon.png` (192x192, 512x512)\n- Place in `/public/` folder in your React app\n\nWould you like me to help you integrate the favicon into your app once you have the image?	IN_PROGRESS	2026-04-01 13:14:39.643648	2026-04-01 13:14:39.643648
f1e7c4a2-052b-4cb3-978f-c809a03f6d26	1d105d8b-95d8-411e-9844-b6683e8b7f51	701adbb8-edd0-409a-a040-d20f70d60edd	2026-04-02	Anganwadi	QA	IN_PROGRESS	2026-04-02 08:32:24.550352	2026-04-02 08:32:24.550352
72513e67-1c1c-49df-8ef5-2510ede0c999	1d105d8b-95d8-411e-9844-b6683e8b7f51	270dc0a2-82c3-452b-947a-f7bdbb5e883b	2026-04-09	pms	ui design	IN_PROGRESS	2026-04-09 05:44:10.880468	2026-04-09 05:44:10.880468
\.


--
-- TOC entry 5427 (class 0 OID 22500)
-- Dependencies: 239
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
-- TOC entry 5428 (class 0 OID 22511)
-- Dependencies: 240
-- Data for Name: user_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_permission (id, user_id, permission_key, is_granted, created_at, updated_at) FROM stdin;
0cd7df7a-3462-4bca-bbae-3107fa7a5dd7	47a94aa7-e849-40f1-9602-f08b894bdc5b	VIEW_ORGANIZATION	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
b0ce2352-2274-4273-90d9-bc658c37b5fa	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_ORGANIZATION	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
d37b26fa-bf2c-4c23-a588-5ce7db74e98f	47a94aa7-e849-40f1-9602-f08b894bdc5b	DELETE_ORGANIZATION	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
0eef1570-9784-46a0-a20a-05784b5ded2b	47a94aa7-e849-40f1-9602-f08b894bdc5b	MANAGE_USERS	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
a07642fa-6a39-4f2a-b050-09ce47eaf138	47a94aa7-e849-40f1-9602-f08b894bdc5b	MANAGE_BUSINESS_UNITS	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
2b6ff291-71a8-4fc8-ba92-0c932164637a	47a94aa7-e849-40f1-9602-f08b894bdc5b	VIEW_BUSINESS_UNIT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
ed766fca-536a-408c-9f7b-0d66f9600e75	47a94aa7-e849-40f1-9602-f08b894bdc5b	CREATE_BUSINESS_UNIT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
155b196f-e02a-4e93-b7b6-3c5157c525fa	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_BUSINESS_UNIT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
e91e445c-93b3-4025-876e-787366d9cbd8	47a94aa7-e849-40f1-9602-f08b894bdc5b	DELETE_BUSINESS_UNIT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
d77c9d9b-9555-40a3-afde-325130ca90f0	47a94aa7-e849-40f1-9602-f08b894bdc5b	VIEW_USER	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
5caed6f4-408e-4622-b2f7-c8f6078a3640	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_USER	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
64ab7893-1285-40b0-85e8-b43379af6e09	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_USER_ROLE	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
f624af62-0099-4b18-b2a7-54507165efe9	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_USER_STATUS	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
38daa6df-e439-4175-b0f4-9202994e8734	47a94aa7-e849-40f1-9602-f08b894bdc5b	CREATE_PROJECT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
2287cb56-0225-49ee-9089-d7ba493cd3a9	47a94aa7-e849-40f1-9602-f08b894bdc5b	VIEW_PROJECT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
82be2046-403f-49d3-9257-2a2c2cb50184	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_PROJECT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
a6bc7767-28ca-4c4d-a087-f86d0cf70f56	47a94aa7-e849-40f1-9602-f08b894bdc5b	DELETE_PROJECT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
7523e552-cdae-463a-8524-920369f1fdd9	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_PROJECT_DETAILS	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
0d10117f-4b7c-458a-a7c5-8980e526befa	47a94aa7-e849-40f1-9602-f08b894bdc5b	VIEW_PROJECT_DETAILS	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
8021a6b6-4d33-408c-944a-7978a1efdaa4	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_TECH_STACK	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
c22ec72d-ef11-4e19-bb4e-19a4bd8daf48	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_DEPENDENCIES	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
29e0b1f1-79f6-4e51-ba16-feed2f70a51a	47a94aa7-e849-40f1-9602-f08b894bdc5b	VIEW_BUDGET	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
7fead7ca-dc81-4766-b70c-d3478ba0bd1a	47a94aa7-e849-40f1-9602-f08b894bdc5b	VIEW_FINANCE	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
bbd5ea9b-3755-4f2d-bcb7-205ac5c59134	47a94aa7-e849-40f1-9602-f08b894bdc5b	VIEW_FINANCE_CODE	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
6fc12902-2f96-4d4d-be93-96bb796aaf10	47a94aa7-e849-40f1-9602-f08b894bdc5b	CREATE_TASK	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
c6738e17-af22-4e36-a47b-becac9e2dc3f	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_TASK	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
626bf002-6aa4-4a16-a080-da9240f22864	47a94aa7-e849-40f1-9602-f08b894bdc5b	DELETE_TASK	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
b0f2655b-5db2-4d53-8bef-620da231f300	47a94aa7-e849-40f1-9602-f08b894bdc5b	CREATE_COMMENT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
6c27713d-0c6d-4c72-a287-c8b15f7e43b1	47a94aa7-e849-40f1-9602-f08b894bdc5b	EDIT_COMMENT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
5a63d015-fa1b-4cd6-b92d-1de299283bdb	47a94aa7-e849-40f1-9602-f08b894bdc5b	DELETE_COMMENT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
9c012712-c3e3-47e9-95a5-8ed0b16cc886	47a94aa7-e849-40f1-9602-f08b894bdc5b	VIEW_ATTACHMENT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
1b78f121-bae4-406c-a179-951b029343f2	47a94aa7-e849-40f1-9602-f08b894bdc5b	CREATE_ATTACHMENT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
38769f48-9797-4d4f-8f0b-61f773b2f66a	47a94aa7-e849-40f1-9602-f08b894bdc5b	DELETE_ATTACHMENT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
c03a51a1-91ec-462e-bebf-db7827e6860a	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_ORGANIZATION	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
9963de56-c9f0-479e-8f6c-4b8d063aa564	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_ORGANIZATION	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
807e6e77-8831-4251-9c6b-3ff2cbe8d1d8	fbfbe066-9918-412c-835d-f92a30ac44e4	DELETE_ORGANIZATION	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
90df5710-ba57-4a52-9d6e-89e36d26b34f	fbfbe066-9918-412c-835d-f92a30ac44e4	MANAGE_USERS	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
f2abfb55-9ca8-417f-a97a-979a8787de39	fbfbe066-9918-412c-835d-f92a30ac44e4	MANAGE_BUSINESS_UNITS	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
a3fcbcfc-1655-4ba8-98dc-419f2de01142	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_BUSINESS_UNIT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
2f715996-efaa-4247-b6cf-805f35ff4f4d	fbfbe066-9918-412c-835d-f92a30ac44e4	CREATE_BUSINESS_UNIT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
e7334bd1-eeea-4bd1-a370-34c8450c54ff	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_BUSINESS_UNIT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
cfa1c470-7fa9-48b2-acec-4ee54b8f3f7d	fbfbe066-9918-412c-835d-f92a30ac44e4	DELETE_BUSINESS_UNIT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
bb03a18c-8034-4a42-be03-077e29e7b08a	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_USER	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
1be66a91-35fe-4fee-b3bf-1a5747200136	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_USER	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
8a59940b-4cea-4348-9258-bdd966f28700	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_USER_ROLE	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
da16ad3a-95d8-4194-b1de-605bcc0ff705	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_USER_STATUS	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
b75c4326-6ae7-4ceb-bdca-d657afbfedfd	fbfbe066-9918-412c-835d-f92a30ac44e4	CREATE_PROJECT	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
4637c521-7035-43b8-b636-733526a9beec	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_PROJECT	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
c9bd87e2-9a9d-415c-b0b0-9ace734dd4e9	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_PROJECT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
25408373-4065-449a-9872-06e3d162e06f	47a94aa7-e849-40f1-9602-f08b894bdc5b	MANAGE_SPRINT	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
875f6db2-8196-48ee-aab7-dd403e9b4d5e	47a94aa7-e849-40f1-9602-f08b894bdc5b	MANAGE_LINKS	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
193d761f-e3cd-4288-b562-f87544987233	47a94aa7-e849-40f1-9602-f08b894bdc5b	MANAGE_LEADERSHIP	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
6f6e6b14-7268-4e7b-b03d-599a65db523c	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_ORGANIZATION	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
f0ec4b40-68a5-4c09-a70a-1ec39f684045	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_ORGANIZATION	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
d6378e53-bf6c-4ba4-88bb-482e5f9f2466	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_ORGANIZATION	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
8aafc2dc-efb0-4e03-b778-e0986f3d1f8a	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_USERS	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
17b8247a-c8a8-4368-b00e-d4468786b07c	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_BUSINESS_UNITS	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
80661b4b-7cad-43f1-b185-8b2896a7f92d	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_BUSINESS_UNIT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
64128b2b-96e5-420f-a718-2836296d908b	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_BUSINESS_UNIT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
c0cdf26b-e472-4ecb-a06b-5d550c9e6fde	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_BUSINESS_UNIT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
d771a8e6-211c-4faa-b923-7732ca591e77	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_BUSINESS_UNIT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
a538cb3c-6e1d-4aa3-aca1-18db1afa0e99	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_USER	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
c4c7f18f-f117-44c4-8c99-5a527562c5ea	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_USER	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
b436a709-ac0e-4222-b051-0264c91bf611	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_USER_ROLE	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
b6a4593a-5673-4d67-8973-9ba5b3e4f125	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_USER_STATUS	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
f4867696-8c2a-495b-9ac4-800546a94afb	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_PROJECT	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
7fb3a16a-ac84-4d13-abc8-62ebac30d3b7	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_PROJECT	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
5e9c2070-1f4b-4500-b19a-0c7e8478ddcd	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_PROJECT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
1acc5f54-f54b-4b15-8e8c-0a8df9e508b4	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_PROJECT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
7c2b836f-e36c-4a00-b321-5d945471b705	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_PROJECT_DETAILS	t	2026-04-01 11:43:11.199024	2026-04-02 06:32:53.087243
c2a4602a-a44b-4947-905d-2757ffebec65	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_PROJECT_DETAILS	t	2026-04-01 11:59:54.866193	2026-04-02 06:32:53.087243
885e2858-c73a-40e3-9c00-9e1f7f36816c	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_TECH_STACK	t	2026-04-01 11:43:11.199024	2026-04-02 06:32:53.087243
82c46cd3-f4a5-4e99-b208-4a9e6f1531d7	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_DEPENDENCIES	t	2026-04-01 11:43:11.199024	2026-04-02 06:32:53.087243
1419d972-c296-445f-bd57-b6a496e53531	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_BUDGET	t	2026-04-01 11:59:54.866193	2026-04-02 06:32:53.087243
460754f1-e26e-4888-b660-f1bdc4edc65b	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_FINANCE	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
19cf8667-e7dc-4646-a839-7309fd300dce	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_FINANCE_CODE	t	2026-04-01 11:59:54.866193	2026-04-02 06:32:53.087243
e276a0be-2025-4ecc-854c-3533f817d7c0	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_TASK	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
4dd814c1-7776-4667-8343-4229f79e635c	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_TASK	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
725d9558-0739-47c3-9c2d-cdc2a4e992fb	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_TASK	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
e39c94d5-b803-433f-843e-64762089ef75	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_COMMENT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
337ae4a0-1936-484c-b278-4cc5795fc726	edb1541e-efee-435d-a4cd-6e7da392464a	EDIT_COMMENT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
985d085c-3a05-4686-8571-3138bf68f08a	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_COMMENT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
b7d81721-0512-4cbc-89e3-5d373dafcfee	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_ATTACHMENT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
ee8408e1-3a4b-44d3-b7d9-f45f70629333	edb1541e-efee-435d-a4cd-6e7da392464a	CREATE_ATTACHMENT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
b55d2599-677f-40d2-8f8f-798213b8bc64	edb1541e-efee-435d-a4cd-6e7da392464a	DELETE_ATTACHMENT	t	2026-04-02 06:32:04.934538	2026-04-02 06:32:53.087243
91f66a30-2895-4873-8dd6-916f228dc077	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_SPRINT	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
3f50d91c-1fe6-4a64-b6de-f5ffb77f6331	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_LINKS	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
a621bcfb-c604-4fd1-8bd4-fe67c095eb7a	edb1541e-efee-435d-a4cd-6e7da392464a	MANAGE_LEADERSHIP	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
61ac29ca-a228-49e9-b667-dbbb3818ebbb	47a94aa7-e849-40f1-9602-f08b894bdc5b	ASSIGN_USERS	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
fbef411a-5718-42dd-8f72-2790dae17a05	47a94aa7-e849-40f1-9602-f08b894bdc5b	VIEW_REPORTS	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
51be08ee-fea2-4bf1-aede-16b9eda110ae	47a94aa7-e849-40f1-9602-f08b894bdc5b	LOG_TIME	t	2026-04-03 07:14:03.998979	2026-04-03 07:14:03.998979
4e6dffe9-793b-4cdf-8df7-c692f6937763	1400ccae-fcaa-452d-9d61-30afb052b604	VIEW_ORGANIZATION	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
f4253a00-b80d-48f3-a57d-8211032c1bc4	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_ORGANIZATION	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
35f1c46b-a3c9-4188-9f90-f984146bd86a	1400ccae-fcaa-452d-9d61-30afb052b604	DELETE_ORGANIZATION	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
015f5959-4076-4747-bc20-92f35042fb3c	1400ccae-fcaa-452d-9d61-30afb052b604	MANAGE_USERS	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
b5bb8355-311e-483d-a3f6-0fd39398b3b8	1400ccae-fcaa-452d-9d61-30afb052b604	MANAGE_BUSINESS_UNITS	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
a79cc601-99e6-402a-b6d3-541585184fb9	1400ccae-fcaa-452d-9d61-30afb052b604	VIEW_BUSINESS_UNIT	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
18a6fcd2-b398-44a6-9ff1-f36ff3fb7419	1400ccae-fcaa-452d-9d61-30afb052b604	CREATE_BUSINESS_UNIT	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
77bb8eee-dc3b-4c40-97d4-6ffb3b8b3e2e	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_BUSINESS_UNIT	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
b38e62ef-8e0d-4c65-9768-ef3173404067	1400ccae-fcaa-452d-9d61-30afb052b604	DELETE_BUSINESS_UNIT	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
87175114-9c56-420e-aa58-0cc5189b65b4	1400ccae-fcaa-452d-9d61-30afb052b604	VIEW_USER	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
f9888a24-cf48-48ed-9452-c0dc249119aa	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_USER	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
94e30688-33c9-4e92-81c4-d109ba016656	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_USER_ROLE	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
3e3c9ac4-39c1-4a45-aa37-52cd5192003f	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_USER_STATUS	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
31c2280a-3e79-4df8-9759-ef7a57ae4d94	1400ccae-fcaa-452d-9d61-30afb052b604	CREATE_PROJECT	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
a0474300-851a-47a0-bad1-92486a05a0aa	1400ccae-fcaa-452d-9d61-30afb052b604	VIEW_PROJECT	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
4df64844-76bd-49e4-b7e0-6b7f05deda00	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_PROJECT	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
7943ea37-10a2-4f7a-a760-4752d0235a77	1400ccae-fcaa-452d-9d61-30afb052b604	DELETE_PROJECT	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
1979b583-ba3e-4bb4-8014-2c511d2c02cd	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_PROJECT_DETAILS	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
34d80c20-ca95-4c7c-beb8-05f5066b2abd	1400ccae-fcaa-452d-9d61-30afb052b604	VIEW_PROJECT_DETAILS	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
dc8a902c-aedd-4698-bcbe-1dd4fe937893	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_TECH_STACK	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
ea207fe4-b292-491c-84aa-6aceb677f526	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_DEPENDENCIES	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
a4eb7deb-0d71-40a7-9bb5-4d6e801e9ca5	1400ccae-fcaa-452d-9d61-30afb052b604	VIEW_BUDGET	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
d3991a52-1184-4beb-8052-d1c17e118654	1400ccae-fcaa-452d-9d61-30afb052b604	VIEW_FINANCE	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
8940edd8-8d28-420c-b133-758df920fb46	1400ccae-fcaa-452d-9d61-30afb052b604	VIEW_FINANCE_CODE	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
6e7e0ac7-c398-47d1-aed3-efee2d5a5f66	1400ccae-fcaa-452d-9d61-30afb052b604	CREATE_TASK	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
f1bd3e5f-767a-4eab-a43f-afe89125ca15	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_TASK	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
bfe0c655-fc96-4909-8f7d-fdf6131992e6	1400ccae-fcaa-452d-9d61-30afb052b604	DELETE_TASK	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
2089c37a-79cf-4354-91aa-b4b8f28a89a6	1400ccae-fcaa-452d-9d61-30afb052b604	CREATE_COMMENT	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
ee1d7b13-8ff2-4c2b-a5fd-8a1567a03047	1400ccae-fcaa-452d-9d61-30afb052b604	EDIT_COMMENT	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
a7057181-a151-41b6-876d-09b33499482a	1400ccae-fcaa-452d-9d61-30afb052b604	DELETE_COMMENT	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
d5c7f1de-8519-4c39-9c56-88b66183750f	1400ccae-fcaa-452d-9d61-30afb052b604	VIEW_ATTACHMENT	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
6439823a-08b3-45bb-9277-91331ec96245	fbfbe066-9918-412c-835d-f92a30ac44e4	MANAGE_SPRINT	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
bd8dead9-3c94-425c-a032-1ae646686894	fbfbe066-9918-412c-835d-f92a30ac44e4	MANAGE_LINKS	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
a392344a-5fbf-421b-b122-326690535505	fbfbe066-9918-412c-835d-f92a30ac44e4	MANAGE_LEADERSHIP	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
29e066ed-ac8e-4af2-9671-e309905ff5fd	fbfbe066-9918-412c-835d-f92a30ac44e4	ASSIGN_USERS	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
2b0a62bb-c589-48b9-947e-c52d35028eac	edb1541e-efee-435d-a4cd-6e7da392464a	ASSIGN_USERS	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
2eeec1f9-1bca-40c1-abac-7f33931c835b	edb1541e-efee-435d-a4cd-6e7da392464a	VIEW_REPORTS	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
be2acfe4-b48c-4353-a820-6c93ffa0fdac	edb1541e-efee-435d-a4cd-6e7da392464a	LOG_TIME	t	2026-03-31 12:36:45.657251	2026-04-02 06:32:53.087243
b4a450ae-72d7-42e6-a800-247812bc6155	f1eaa5c8-2d78-471b-937e-50a10eddf609	VIEW_ORGANIZATION	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
91d0f6a0-3189-472f-8d2a-f0ba8c435c58	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_ORGANIZATION	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
6f0b9b72-ae2f-4902-b3d3-2f6b34c07853	f1eaa5c8-2d78-471b-937e-50a10eddf609	DELETE_ORGANIZATION	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
1fda842a-1a42-4534-8284-ef41c10b9888	f1eaa5c8-2d78-471b-937e-50a10eddf609	MANAGE_USERS	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
2613a803-b682-4e10-85eb-67d2c9a8741b	f1eaa5c8-2d78-471b-937e-50a10eddf609	MANAGE_BUSINESS_UNITS	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
029b746e-5a0a-438c-bafa-c95fb5e6874f	f1eaa5c8-2d78-471b-937e-50a10eddf609	VIEW_BUSINESS_UNIT	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
b6092715-a45b-4b8e-873c-8e6dad24d4f9	f1eaa5c8-2d78-471b-937e-50a10eddf609	CREATE_BUSINESS_UNIT	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
4373ecbd-7606-43c2-a42d-1d9f84ba9f00	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_BUSINESS_UNIT	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
af10ca56-875b-4c08-84c0-4482fd66c02c	f1eaa5c8-2d78-471b-937e-50a10eddf609	DELETE_BUSINESS_UNIT	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
eed65f61-0f6d-4387-ab80-9002d3a01873	f1eaa5c8-2d78-471b-937e-50a10eddf609	VIEW_USER	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
08cf3588-3b3b-4c9b-8849-893f0023524f	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_USER	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
616f1497-63b1-4330-ba43-77b07525f8a3	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_USER_ROLE	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
2f96f8fc-7041-41ee-8d0c-293af226764c	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_USER_STATUS	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
444eea6a-0ad7-48fc-956c-bc76353b1d4a	f1eaa5c8-2d78-471b-937e-50a10eddf609	CREATE_PROJECT	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
54cf78ab-90e9-4d8c-8a86-4cf6f7199a7d	f1eaa5c8-2d78-471b-937e-50a10eddf609	VIEW_PROJECT	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
909a64a5-bc8a-4d79-a42f-0707c3051397	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_PROJECT	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
df2f8ac9-b49a-44a3-ac2d-ee14d489f00e	f1eaa5c8-2d78-471b-937e-50a10eddf609	DELETE_PROJECT	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
48b79e14-4aa7-4925-bb1c-a5725bea8461	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_PROJECT_DETAILS	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
457e2567-3b56-4b10-acf4-4541fdb3854a	f1eaa5c8-2d78-471b-937e-50a10eddf609	VIEW_PROJECT_DETAILS	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
c9ca2739-faff-40a4-bf0a-4ae1464bff99	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_TECH_STACK	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
a72d4d06-fa7c-4c37-943f-0b13055dfc31	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_DEPENDENCIES	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
eb0189b2-2ce5-43fd-a51a-ef34be28b045	f1eaa5c8-2d78-471b-937e-50a10eddf609	VIEW_BUDGET	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
6d52d147-db04-43b9-a5ff-634dd3e8fd7d	f1eaa5c8-2d78-471b-937e-50a10eddf609	VIEW_FINANCE	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
afc5df33-6ed4-46fa-a2a4-71a08de2f431	f1eaa5c8-2d78-471b-937e-50a10eddf609	VIEW_FINANCE_CODE	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
09ed637d-9ef0-487f-bbae-b90aa8e564c1	f1eaa5c8-2d78-471b-937e-50a10eddf609	CREATE_TASK	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
cfad9952-bc68-4926-b065-86dcc70c0515	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_TASK	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
603a10f5-d256-4cf9-9a8d-20bf3686ca9d	f1eaa5c8-2d78-471b-937e-50a10eddf609	DELETE_TASK	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
e2cdf5be-c9c0-45f0-941b-2424874c666b	f1eaa5c8-2d78-471b-937e-50a10eddf609	CREATE_COMMENT	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
3f886234-f2cd-4273-bc78-417e6edebef1	f1eaa5c8-2d78-471b-937e-50a10eddf609	EDIT_COMMENT	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
08894e69-6a1e-4cfc-8cc1-abb0e01e6db0	f1eaa5c8-2d78-471b-937e-50a10eddf609	DELETE_COMMENT	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
e17fa3cc-8aa6-4089-98bf-26d41ec9113e	f1eaa5c8-2d78-471b-937e-50a10eddf609	VIEW_ATTACHMENT	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
4857c5f8-3c9f-45cd-bbd0-95d99e1de40e	f1eaa5c8-2d78-471b-937e-50a10eddf609	CREATE_ATTACHMENT	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
3fa9fd71-d164-4761-b058-4fe8a550b197	f1eaa5c8-2d78-471b-937e-50a10eddf609	DELETE_ATTACHMENT	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
f6f39eae-7803-4d1c-91e9-a84be764785f	f1eaa5c8-2d78-471b-937e-50a10eddf609	MANAGE_SPRINT	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
c401d08c-d674-403e-bbdd-fa7c99253d85	f1eaa5c8-2d78-471b-937e-50a10eddf609	MANAGE_LINKS	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
4d59f203-f56c-44b4-874f-ef9f4c7f9ee3	f1eaa5c8-2d78-471b-937e-50a10eddf609	MANAGE_LEADERSHIP	f	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
caa3c33d-8a44-4f15-9c15-7623b53c3b8e	f1eaa5c8-2d78-471b-937e-50a10eddf609	ASSIGN_USERS	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
8cef2c72-6f73-41ce-8c06-1fc6c7966e8d	f1eaa5c8-2d78-471b-937e-50a10eddf609	VIEW_REPORTS	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
d86191b1-7e77-4b0e-8f3a-b323f2655dff	f1eaa5c8-2d78-471b-937e-50a10eddf609	LOG_TIME	t	2026-04-02 08:23:53.995018	2026-04-02 08:23:53.995018
1b49d7a9-348d-423f-b779-3f67cdd26794	fbfbe066-9918-412c-835d-f92a30ac44e4	DELETE_PROJECT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
01ca3839-2e8a-4466-bbe8-97e9b33de68f	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_PROJECT_DETAILS	t	2026-04-01 13:04:31.537402	2026-04-09 05:52:24.145283
8bcfc781-899d-4bc0-8173-18b815726051	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_PROJECT_DETAILS	t	2026-04-01 13:04:31.537402	2026-04-09 05:52:24.145283
a9d700e5-190e-424b-bc2d-89a1fa376054	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_TECH_STACK	t	2026-04-01 13:04:31.537402	2026-04-09 05:52:24.145283
0457aac2-f531-43eb-a9fc-65fa0d2b4ef8	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_DEPENDENCIES	t	2026-04-01 13:04:31.537402	2026-04-09 05:52:24.145283
c0fa614d-1dc5-4dd9-8575-2e12c5844609	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_BUDGET	t	2026-04-01 13:04:31.537402	2026-04-09 05:52:24.145283
ca4ee37a-f55a-443e-8d59-27320b0a948c	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_FINANCE	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
9426c98e-941b-4c84-aa36-6db6e8cc5c3b	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_FINANCE_CODE	t	2026-04-01 13:04:31.537402	2026-04-09 05:52:24.145283
40bfc6fe-5122-4fd7-a1ea-0aa841655f73	fbfbe066-9918-412c-835d-f92a30ac44e4	CREATE_TASK	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
ba7c034f-3b66-463a-9aa1-5c9ae846d40f	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_TASK	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
78abf4f5-f012-460a-a97d-f29f90e2402a	fbfbe066-9918-412c-835d-f92a30ac44e4	DELETE_TASK	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
c4fbfef7-681c-4a18-a3d0-24791ba684ba	fbfbe066-9918-412c-835d-f92a30ac44e4	CREATE_COMMENT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
09bb37c8-b3b9-40a3-b592-50e71577ee83	fbfbe066-9918-412c-835d-f92a30ac44e4	EDIT_COMMENT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
0a9362b7-7cba-4a76-80f7-af15ffa3836c	fbfbe066-9918-412c-835d-f92a30ac44e4	DELETE_COMMENT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
fb3bd16e-6d0c-4734-bdd1-77feab6873b0	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_ATTACHMENT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
1358132b-9141-4497-aa96-6569e0c0c591	fbfbe066-9918-412c-835d-f92a30ac44e4	CREATE_ATTACHMENT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
7de8098d-f45d-4197-9918-a3d6e003e3fd	fbfbe066-9918-412c-835d-f92a30ac44e4	DELETE_ATTACHMENT	t	2026-04-01 15:30:40.456731	2026-04-09 05:52:24.145283
27ffd648-5fb7-4f80-aba7-5a90c4676739	8a00286c-b21d-46f7-816f-b9be2a66b62f	VIEW_ORGANIZATION	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
147ff684-9c23-4222-89c5-6e9f6f9b38c8	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_ORGANIZATION	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
6643ba20-882f-4c2a-8a0b-23ac4ea7dd1e	8a00286c-b21d-46f7-816f-b9be2a66b62f	DELETE_ORGANIZATION	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
c8925b84-721e-4686-bf08-65767c49d7f2	8a00286c-b21d-46f7-816f-b9be2a66b62f	MANAGE_USERS	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
cfa479ac-d808-4352-b26c-671cd648e558	8a00286c-b21d-46f7-816f-b9be2a66b62f	MANAGE_BUSINESS_UNITS	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
9e91e380-a39e-42e9-bf4b-2d9fdc8dbcf5	8a00286c-b21d-46f7-816f-b9be2a66b62f	VIEW_BUSINESS_UNIT	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
cdd423f4-f80c-45b0-a6fb-9a7e30a2bee4	8a00286c-b21d-46f7-816f-b9be2a66b62f	CREATE_BUSINESS_UNIT	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
5678f0a5-9ee1-4d7f-8825-ba178d5d8642	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_BUSINESS_UNIT	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
6e8c322e-be97-4864-b0f6-3c72720d7c35	8a00286c-b21d-46f7-816f-b9be2a66b62f	DELETE_BUSINESS_UNIT	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
3fdfea6b-e01a-4843-bc6a-00d1b5a16216	8a00286c-b21d-46f7-816f-b9be2a66b62f	VIEW_USER	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
1bf9a260-2e22-4e6b-84d3-1b58540c957e	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_USER	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
2bfd2f14-ebbe-4ff8-9048-ed87ed032317	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_USER_ROLE	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
ecb4b7bb-d089-449c-9a30-ee6b609de9e0	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_USER_STATUS	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
d46796a2-3e97-4d8b-b6d5-1eb6292dac76	8a00286c-b21d-46f7-816f-b9be2a66b62f	CREATE_PROJECT	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
b958089c-19ae-4efe-ad6d-f3e2a9462b47	8a00286c-b21d-46f7-816f-b9be2a66b62f	VIEW_PROJECT	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
6bb31072-56cb-4c19-9f15-568cc5fa6ddb	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_PROJECT	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
a26d64bf-15ca-44bc-a1bf-6ac7bab8c31f	8a00286c-b21d-46f7-816f-b9be2a66b62f	DELETE_PROJECT	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
7642fd5b-0aa7-4c0d-b16e-b22af6d6051f	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_PROJECT_DETAILS	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
5db8d984-4efa-4e88-b582-50173e84211f	8a00286c-b21d-46f7-816f-b9be2a66b62f	VIEW_PROJECT_DETAILS	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
9e7dce94-196a-4c36-b143-1d854e1a603a	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_TECH_STACK	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
05017bea-cbab-4ec9-a69e-7ebdaa90faeb	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_DEPENDENCIES	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
485563b8-d7df-437e-8afa-f56be45c3dad	8a00286c-b21d-46f7-816f-b9be2a66b62f	VIEW_BUDGET	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
61600307-10f0-4a8e-ac9b-58391ee91628	8a00286c-b21d-46f7-816f-b9be2a66b62f	VIEW_FINANCE	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
5575d2ab-1d1c-4f68-8d40-72ce6a52bbce	8a00286c-b21d-46f7-816f-b9be2a66b62f	VIEW_FINANCE_CODE	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
93248608-17b3-45df-b29a-8b6ae8963103	8a00286c-b21d-46f7-816f-b9be2a66b62f	CREATE_TASK	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
1197a1f5-af21-436c-9c5e-b16bfc4b104c	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_TASK	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
2a78d984-70e6-4d52-8183-d0e04a29b14e	8a00286c-b21d-46f7-816f-b9be2a66b62f	DELETE_TASK	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
2d03e631-f810-4c7e-894f-4071e4f07976	8a00286c-b21d-46f7-816f-b9be2a66b62f	CREATE_COMMENT	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
fedb3201-b582-4378-9c0c-9893f3c89693	8a00286c-b21d-46f7-816f-b9be2a66b62f	EDIT_COMMENT	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
c757e585-b7ef-49cf-aadb-104b561a04ba	8a00286c-b21d-46f7-816f-b9be2a66b62f	DELETE_COMMENT	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
c01681a2-7651-4ba7-8fd9-4cde5f168c41	8a00286c-b21d-46f7-816f-b9be2a66b62f	VIEW_ATTACHMENT	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
bbebeeb3-9741-4978-8882-afbad55f1386	8a00286c-b21d-46f7-816f-b9be2a66b62f	CREATE_ATTACHMENT	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
db9a365e-d0d2-4202-9578-14e719394ee6	8a00286c-b21d-46f7-816f-b9be2a66b62f	DELETE_ATTACHMENT	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
96c28f25-425f-4da0-a243-c486b0993f19	8a00286c-b21d-46f7-816f-b9be2a66b62f	MANAGE_SPRINT	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
14625420-e42d-4625-ad1c-b5929a0bf676	8a00286c-b21d-46f7-816f-b9be2a66b62f	MANAGE_LINKS	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
17122c9c-2cfd-4071-be00-8520192e33e2	8a00286c-b21d-46f7-816f-b9be2a66b62f	MANAGE_LEADERSHIP	f	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
e61d60fc-2df8-4f3e-a0e3-72fb54b2e504	8a00286c-b21d-46f7-816f-b9be2a66b62f	ASSIGN_USERS	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
86ed8f8b-ee84-4b72-b8ee-c98cd488d573	8a00286c-b21d-46f7-816f-b9be2a66b62f	VIEW_REPORTS	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
0b7e43f2-78b7-4f99-90a9-89876f4b612b	8a00286c-b21d-46f7-816f-b9be2a66b62f	LOG_TIME	t	2026-04-02 08:40:15.130076	2026-04-02 08:40:15.130076
9cbc6b04-6f4e-4fee-9102-67ee56cb3e36	fbfbe066-9918-412c-835d-f92a30ac44e4	VIEW_REPORTS	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
184f9d65-2645-407a-8bc1-ce90be6277ee	fbfbe066-9918-412c-835d-f92a30ac44e4	LOG_TIME	t	2026-03-31 11:44:01.150287	2026-04-09 05:52:24.145283
5d78c2d9-502f-4388-9071-538b8616d305	270dc0a2-82c3-452b-947a-f7bdbb5e883b	DELETE_TASK	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
296e012a-4aee-474b-8dce-3780809978d9	1400ccae-fcaa-452d-9d61-30afb052b604	CREATE_ATTACHMENT	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
9b2091d0-3c00-4575-a1d6-9101065a3081	701adbb8-edd0-409a-a040-d20f70d60edd	VIEW_ORGANIZATION	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
5f5c9026-f5f6-4ac9-b391-760bebdba493	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_ORGANIZATION	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
9d7ec56b-03eb-4884-bb4d-4c821d256653	701adbb8-edd0-409a-a040-d20f70d60edd	DELETE_ORGANIZATION	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
1fe0bf0e-66aa-484a-b915-0c1503f097c7	701adbb8-edd0-409a-a040-d20f70d60edd	MANAGE_USERS	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
3becb8c3-f4c7-4a09-ba8b-9704c076b41e	701adbb8-edd0-409a-a040-d20f70d60edd	MANAGE_BUSINESS_UNITS	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
dc8ea4cc-8b8d-42cc-a86a-e7bb0e4c736b	701adbb8-edd0-409a-a040-d20f70d60edd	VIEW_BUSINESS_UNIT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
f7bdf95a-fe09-417b-afc5-11cbdf1c67bf	701adbb8-edd0-409a-a040-d20f70d60edd	CREATE_BUSINESS_UNIT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
19d3b543-a2f7-499d-ad0f-79131369331e	1400ccae-fcaa-452d-9d61-30afb052b604	DELETE_ATTACHMENT	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
ba1f2ee8-5c91-467c-a70d-6d2e892acd03	1400ccae-fcaa-452d-9d61-30afb052b604	MANAGE_SPRINT	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
e2711197-5d1e-4043-a5a6-6de87c1950dc	1400ccae-fcaa-452d-9d61-30afb052b604	MANAGE_LINKS	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
5236cb28-e6af-4ed1-a567-95f3c129867b	1400ccae-fcaa-452d-9d61-30afb052b604	MANAGE_LEADERSHIP	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
65548d46-fd56-48a5-b6ed-5672684516ca	1400ccae-fcaa-452d-9d61-30afb052b604	ASSIGN_USERS	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
3651d941-b466-4e93-aa3a-740309b256bd	1400ccae-fcaa-452d-9d61-30afb052b604	VIEW_REPORTS	f	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
1fbf1503-7126-40c8-869c-3853dce9d5dd	1400ccae-fcaa-452d-9d61-30afb052b604	LOG_TIME	t	2026-04-01 15:37:57.949799	2026-04-07 08:47:42.19462
30ded68e-1f66-4908-91d2-cb4ac7c9d841	270dc0a2-82c3-452b-947a-f7bdbb5e883b	CREATE_COMMENT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
fd20e93c-5117-4a09-a51c-a4bba1393956	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_COMMENT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
b1eae64f-bb16-46ca-b43c-2f9052ddc6c2	270dc0a2-82c3-452b-947a-f7bdbb5e883b	DELETE_COMMENT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
24b8698d-b509-4da2-a161-6c1d1bfab6e8	270dc0a2-82c3-452b-947a-f7bdbb5e883b	VIEW_ATTACHMENT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
9576e2c3-bd96-43db-be6a-7a07b9a2744c	270dc0a2-82c3-452b-947a-f7bdbb5e883b	CREATE_ATTACHMENT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
e5970241-cb1c-4bb0-be87-776148074696	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_BUSINESS_UNIT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
dd168f84-22fd-4dcc-a922-5d978ff432a3	701adbb8-edd0-409a-a040-d20f70d60edd	DELETE_BUSINESS_UNIT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
9f3c8aaf-b319-4595-8ca6-586bb010ee68	701adbb8-edd0-409a-a040-d20f70d60edd	VIEW_USER	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
d44fd5f7-43d0-4c9a-9a16-5892cd904a47	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_USER	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
461922ed-c909-409d-917e-4eaff0770879	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_USER_ROLE	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
eaaba888-a3f7-4e7e-9080-6c777b641f8f	270dc0a2-82c3-452b-947a-f7bdbb5e883b	DELETE_ATTACHMENT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
94a7ce56-2c6f-4c1e-b311-2a34ca4ee79f	270dc0a2-82c3-452b-947a-f7bdbb5e883b	MANAGE_SPRINT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
54b98841-ddfb-4495-a262-00eb627f41b8	270dc0a2-82c3-452b-947a-f7bdbb5e883b	MANAGE_LINKS	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
63281667-c6ac-45c3-be76-cb7e79013830	270dc0a2-82c3-452b-947a-f7bdbb5e883b	MANAGE_LEADERSHIP	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
08c60fb5-7041-4df5-bc17-b0a565cfa291	270dc0a2-82c3-452b-947a-f7bdbb5e883b	ASSIGN_USERS	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
45920592-72d5-4384-9eac-76fd9d7b143d	270dc0a2-82c3-452b-947a-f7bdbb5e883b	VIEW_REPORTS	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
08d97b29-35e3-4679-8c90-e6340aae7a9b	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_USER_STATUS	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
593225de-122e-4c82-ba7b-16068885c158	701adbb8-edd0-409a-a040-d20f70d60edd	CREATE_PROJECT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
e2110124-d17d-43ae-a373-a2f7985b49b2	701adbb8-edd0-409a-a040-d20f70d60edd	VIEW_PROJECT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
a65ff917-4b7d-4f63-bbd7-8577f0bd6b8f	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_PROJECT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
2ef25436-c7ef-44e7-acad-69bbf34d7265	701adbb8-edd0-409a-a040-d20f70d60edd	DELETE_PROJECT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
004a53e7-6027-42d8-bcd8-bb642bb5966f	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_PROJECT_DETAILS	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
a8798bc9-ca86-4b1a-992d-e24c0eeadd68	701adbb8-edd0-409a-a040-d20f70d60edd	VIEW_PROJECT_DETAILS	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
07074dcb-a728-484a-93a7-7ee87a1e381f	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_TECH_STACK	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
604241f2-e7b6-41c1-b430-02edb1365f30	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_DEPENDENCIES	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
6746aaa1-1880-4b4b-973d-4e28c68bf56a	701adbb8-edd0-409a-a040-d20f70d60edd	VIEW_BUDGET	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
0b7ddbb0-9b39-49be-8885-235383067929	701adbb8-edd0-409a-a040-d20f70d60edd	VIEW_FINANCE	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
3baf7bc2-7f4f-4e09-bb20-72c2b802f980	701adbb8-edd0-409a-a040-d20f70d60edd	VIEW_FINANCE_CODE	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
0ecbeec7-daeb-4579-bbc9-2d744c387805	701adbb8-edd0-409a-a040-d20f70d60edd	CREATE_TASK	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
3af0ac95-5ac6-4d46-b472-2bf042ea74d9	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_TASK	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
6e53f68f-3a5f-4b25-ba07-2ce12d0e2e7a	701adbb8-edd0-409a-a040-d20f70d60edd	DELETE_TASK	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
e6459f55-8f1c-4295-9b1c-4389a3293503	701adbb8-edd0-409a-a040-d20f70d60edd	CREATE_COMMENT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
a270d6d9-fee6-42bc-9817-0b8eb0abe631	701adbb8-edd0-409a-a040-d20f70d60edd	EDIT_COMMENT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
02979c87-6039-458e-971f-03b4f66c9819	701adbb8-edd0-409a-a040-d20f70d60edd	DELETE_COMMENT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
9631e584-fa33-4368-9009-5acfd465329a	701adbb8-edd0-409a-a040-d20f70d60edd	VIEW_ATTACHMENT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
64ea5c46-9a05-40f5-9306-a02fdf48ea2b	701adbb8-edd0-409a-a040-d20f70d60edd	CREATE_ATTACHMENT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
1b2fdbc1-06b9-4bc2-997e-cea93155d912	701adbb8-edd0-409a-a040-d20f70d60edd	DELETE_ATTACHMENT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
cf7653ab-bf9f-4860-8e3c-b4552e77263f	701adbb8-edd0-409a-a040-d20f70d60edd	MANAGE_SPRINT	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
963ce567-b49b-4584-afbe-b3be6fa186a5	701adbb8-edd0-409a-a040-d20f70d60edd	MANAGE_LINKS	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
0d995232-d161-4a7b-82a3-859f1b42f7a0	701adbb8-edd0-409a-a040-d20f70d60edd	MANAGE_LEADERSHIP	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
d1ab5cea-09d0-4eac-bd78-f6ef5305e240	701adbb8-edd0-409a-a040-d20f70d60edd	ASSIGN_USERS	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
f0beb962-1662-478a-86d2-5cb1e26c31ba	701adbb8-edd0-409a-a040-d20f70d60edd	VIEW_REPORTS	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
be56ca89-5a92-49b3-89d5-928eb145b523	701adbb8-edd0-409a-a040-d20f70d60edd	LOG_TIME	t	2026-04-02 08:33:22.210908	2026-04-02 10:30:35.819468
afe1e84d-e885-4c27-9dd0-bca361d39b6f	270dc0a2-82c3-452b-947a-f7bdbb5e883b	VIEW_ORGANIZATION	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
59bc0074-7790-4641-a816-1ab050133e52	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_ORGANIZATION	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
c2d24e75-34c5-495e-9390-22ad2d6c708a	270dc0a2-82c3-452b-947a-f7bdbb5e883b	DELETE_ORGANIZATION	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
a34808f3-8c50-40a0-9ed0-692fb39f80ff	270dc0a2-82c3-452b-947a-f7bdbb5e883b	MANAGE_USERS	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
5657a886-a843-40e6-8e0e-ddc20a322a63	270dc0a2-82c3-452b-947a-f7bdbb5e883b	MANAGE_BUSINESS_UNITS	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
3f26bf60-d5ff-4348-930e-c253ad2283fa	270dc0a2-82c3-452b-947a-f7bdbb5e883b	VIEW_BUSINESS_UNIT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
a9a1932e-8368-422a-b791-9f38ece4710e	270dc0a2-82c3-452b-947a-f7bdbb5e883b	CREATE_BUSINESS_UNIT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
9f4d68c5-e5a9-484d-994b-0de83384d1a4	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_BUSINESS_UNIT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
63cb049d-8de0-4dd2-87a7-996fcf222af0	270dc0a2-82c3-452b-947a-f7bdbb5e883b	DELETE_BUSINESS_UNIT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
e971f427-f0cc-4be4-b195-1c95e3fc24e0	270dc0a2-82c3-452b-947a-f7bdbb5e883b	VIEW_USER	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
00a4ad9e-d27c-4adc-b47d-4cabb6f01a03	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_USER	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
62793bca-b4f3-4989-8ce2-856daf86971c	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_USER_ROLE	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
bde7203f-c86b-4a65-bf55-27c1d94b5a4e	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_USER_STATUS	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
e7337de7-21eb-411a-96c5-048436af2576	270dc0a2-82c3-452b-947a-f7bdbb5e883b	CREATE_PROJECT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
6b8b8110-33e9-4bfe-b34f-ad7113e2a8dc	270dc0a2-82c3-452b-947a-f7bdbb5e883b	VIEW_PROJECT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
814f2c98-aa00-4487-a93b-bdc269626be3	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_PROJECT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
91f3456f-fc94-42ab-91b3-18f608a9949b	270dc0a2-82c3-452b-947a-f7bdbb5e883b	DELETE_PROJECT	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
c491bf37-e80a-44d7-a303-17e91ad13a76	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_PROJECT_DETAILS	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
a2afd882-de94-456c-984f-b26b0912b5d8	270dc0a2-82c3-452b-947a-f7bdbb5e883b	VIEW_PROJECT_DETAILS	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
ae8eb960-ca73-4b72-b6f5-12d7588c096d	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_TECH_STACK	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
2f9e4ec0-66a8-4bd9-b16d-63a7217754bf	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_DEPENDENCIES	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
9f9b3919-554c-43ce-ae7c-c17e15aa5a98	270dc0a2-82c3-452b-947a-f7bdbb5e883b	VIEW_BUDGET	f	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
b57f6db3-b533-49ce-93a3-9abda4151d24	270dc0a2-82c3-452b-947a-f7bdbb5e883b	VIEW_FINANCE	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
bba2835c-9184-4f91-9331-1a180f0898ee	270dc0a2-82c3-452b-947a-f7bdbb5e883b	VIEW_FINANCE_CODE	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
816a1611-9845-41d4-8223-84f1bb43b4dc	270dc0a2-82c3-452b-947a-f7bdbb5e883b	CREATE_TASK	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
ea580176-41f8-4493-ad78-3c15fd598c74	270dc0a2-82c3-452b-947a-f7bdbb5e883b	EDIT_TASK	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
581adad4-309c-4b13-9770-f777d2da7604	270dc0a2-82c3-452b-947a-f7bdbb5e883b	LOG_TIME	t	2026-04-07 07:04:30.944461	2026-04-09 05:42:22.31998
\.


--
-- TOC entry 5429 (class 0 OID 22524)
-- Dependencies: 241
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
a8249a6a-f2e0-477a-8751-b1b961ea8096	1d105d8b-95d8-411e-9844-b6683e8b7f51	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	71bb0f85-cdde-469a-900d-e8761da76e45	MANAGER	ACTIVE	2026-03-27 00:03:11.641963	0	REJECTED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:04:00.384
4669f46e-3526-449e-b5bd-e4811f73017c	1d105d8b-95d8-411e-9844-b6683e8b7f51	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	71bb0f85-cdde-469a-900d-e8761da76e45	DEV	ACTIVE	2026-03-27 00:03:18.341318	0	REJECTED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:04:03.561
990bfa40-f689-4c86-b889-c94fac44bb5d	1d105d8b-95d8-411e-9844-b6683e8b7f51	b762cce3-dac1-4aa0-bc38-a8488eaf994f	71bb0f85-cdde-469a-900d-e8761da76e45	QA	ACTIVE	2026-03-27 12:16:26.351317	50	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:17:59.381
b0f86c88-daa5-4db2-95eb-e3853e1076b5	1d105d8b-95d8-411e-9844-b6683e8b7f51	b762cce3-dac1-4aa0-bc38-a8488eaf994f	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-03-27 12:19:21.433172	50	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:19:30.431
690f4d4c-7363-4fd7-9870-3e1876f75feb	1d105d8b-95d8-411e-9844-b6683e8b7f51	fbfbe066-9918-412c-835d-f92a30ac44e4	eeb797e6-385c-4376-a607-9663e4313e60	DEV	ACTIVE	2026-03-27 11:48:45.554344	60	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:21:58.008
c2bb69e7-aaf2-407c-ac56-525ffc71643c	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	71bb0f85-cdde-469a-900d-e8761da76e45	DEV	ACTIVE	2026-03-27 12:35:42.529365	60	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:35:46.957
74c845ad-3beb-4289-be4f-e565eb5a3ccc	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-03-27 14:59:45.637328	40	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 14:59:50.019
6544a869-d2fe-41d8-8f59-cd6e90245479	1d105d8b-95d8-411e-9844-b6683e8b7f51	fbfbe066-9918-412c-835d-f92a30ac44e4	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-03-27 16:11:07.351416	40	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 16:11:15.047
4a1a5636-275a-4261-8444-6260bb86f655	1d105d8b-95d8-411e-9844-b6683e8b7f51	8a00286c-b21d-46f7-816f-b9be2a66b62f	1123d42d-aa3a-4c19-93e0-332366c7a4b9	QA	ACTIVE	2026-04-02 08:31:41.111222	50	APPROVED	\N	701adbb8-edd0-409a-a040-d20f70d60edd	2026-04-02 08:31:46.125
d45efc6e-f2f7-45ce-a7d8-16bb749401a7	1d105d8b-95d8-411e-9844-b6683e8b7f51	270dc0a2-82c3-452b-947a-f7bdbb5e883b	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-04-07 07:06:05.091338	50	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-07 08:46:05.59
56264c7f-dc8f-4bac-9000-6328eee1168b	1d105d8b-95d8-411e-9844-b6683e8b7f51	1400ccae-fcaa-452d-9d61-30afb052b604	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	SCRUM_MASTER	ACTIVE	2026-04-07 08:45:53.556718	50	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-07 08:46:08.463
f57de93d-1d7f-483c-ace8-a06c8777717d	1d105d8b-95d8-411e-9844-b6683e8b7f51	65b2f9f4-a049-4766-b6f6-4ecca8fb8de7	cc556634-367e-4ff9-a331-a000d92c89e3	DEV	ACTIVE	2026-03-20 14:15:31.492414	0	APPROVED	\N	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-04-09 12:45:30.833
892c9d61-da2c-457b-9fa5-3f46a52605e8	1d105d8b-95d8-411e-9844-b6683e8b7f51	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	cc556634-367e-4ff9-a331-a000d92c89e3	MANAGER	ACTIVE	2026-03-20 15:26:56.929039	0	APPROVED	\N	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-04-09 12:45:32.359
\.


--
-- TOC entry 5199 (class 2606 OID 23000)
-- Name: activity_log activity_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5071 (class 2606 OID 22540)
-- Name: app_user app_user_org_id_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_email_key UNIQUE (org_id, email);


--
-- TOC entry 5073 (class 2606 OID 22542)
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- TOC entry 5077 (class 2606 OID 22544)
-- Name: attachment attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- TOC entry 5081 (class 2606 OID 22546)
-- Name: business_unit business_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_pkey PRIMARY KEY (id);


--
-- TOC entry 5196 (class 2606 OID 22975)
-- Name: chat_message chat_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_pkey PRIMARY KEY (id);


--
-- TOC entry 5192 (class 2606 OID 22951)
-- Name: chat_session chat_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_pkey PRIMARY KEY (id);


--
-- TOC entry 5190 (class 2606 OID 22920)
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- TOC entry 5087 (class 2606 OID 22548)
-- Name: organization organization_azure_tenant_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_azure_tenant_id_key UNIQUE (azure_tenant_id);


--
-- TOC entry 5089 (class 2606 OID 22550)
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- TOC entry 5091 (class 2606 OID 22552)
-- Name: platform_user platform_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_email_key UNIQUE (email);


--
-- TOC entry 5093 (class 2606 OID 22554)
-- Name: platform_user platform_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_pkey PRIMARY KEY (id);


--
-- TOC entry 5108 (class 2606 OID 22556)
-- Name: project_cost project_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_pkey PRIMARY KEY (id);


--
-- TOC entry 5111 (class 2606 OID 22558)
-- Name: project_link project_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5102 (class 2606 OID 22560)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- TOC entry 5104 (class 2606 OID 22562)
-- Name: project project_project_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_project_code_key UNIQUE (project_code);


--
-- TOC entry 5114 (class 2606 OID 22564)
-- Name: project_task_sequence project_task_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_pkey PRIMARY KEY (id);


--
-- TOC entry 5116 (class 2606 OID 22566)
-- Name: project_task_sequence project_task_sequence_project_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_key UNIQUE (project_id);


--
-- TOC entry 5119 (class 2606 OID 22568)
-- Name: resource_cost resource_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_pkey PRIMARY KEY (id);


--
-- TOC entry 5121 (class 2606 OID 22570)
-- Name: resource_cost resource_cost_user_id_effective_from_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_effective_from_key UNIQUE (user_id, effective_from);


--
-- TOC entry 5124 (class 2606 OID 22572)
-- Name: role_permission role_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_pkey PRIMARY KEY (role, permission_key);


--
-- TOC entry 5127 (class 2606 OID 22574)
-- Name: sprint sprint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_pkey PRIMARY KEY (id);


--
-- TOC entry 5130 (class 2606 OID 22576)
-- Name: tag tag_org_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_name_key UNIQUE (org_id, name);


--
-- TOC entry 5132 (class 2606 OID 22578)
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- TOC entry 5145 (class 2606 OID 22580)
-- Name: task_comment task_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_pkey PRIMARY KEY (id);


--
-- TOC entry 5149 (class 2606 OID 22582)
-- Name: task_link task_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5151 (class 2606 OID 22584)
-- Name: task_link task_link_source_task_id_target_task_id_link_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_target_task_id_link_type_key UNIQUE (source_task_id, target_task_id, link_type);


--
-- TOC entry 5139 (class 2606 OID 22586)
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- TOC entry 5155 (class 2606 OID 22588)
-- Name: task_tag_mapping task_tag_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_pkey PRIMARY KEY (task_id, tag_id);


--
-- TOC entry 5141 (class 2606 OID 22590)
-- Name: task task_task_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_task_code_key UNIQUE (task_code);


--
-- TOC entry 5161 (class 2606 OID 22592)
-- Name: time_log time_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5166 (class 2606 OID 22594)
-- Name: timesheet timesheet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_pkey PRIMARY KEY (id);


--
-- TOC entry 5084 (class 2606 OID 22596)
-- Name: business_unit uq_business_unit_org_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT uq_business_unit_org_name UNIQUE (org_id, name);


--
-- TOC entry 5175 (class 2606 OID 22598)
-- Name: user_permission uq_user_permission; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT uq_user_permission UNIQUE (user_id, permission_key);


--
-- TOC entry 5184 (class 2606 OID 22600)
-- Name: user_project_mapping uq_user_project_mapping_user_project_role; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT uq_user_project_mapping_user_project_role UNIQUE (user_id, project_id, project_role);


--
-- TOC entry 5170 (class 2606 OID 22602)
-- Name: user_daily_summary user_daily_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_pkey PRIMARY KEY (id);


--
-- TOC entry 5172 (class 2606 OID 22604)
-- Name: user_daily_summary user_daily_summary_user_id_summary_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_summary_date_key UNIQUE (user_id, summary_date);


--
-- TOC entry 5177 (class 2606 OID 22606)
-- Name: user_permission user_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT user_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 5186 (class 2606 OID 22608)
-- Name: user_project_mapping user_project_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_pkey PRIMARY KEY (id);


--
-- TOC entry 5200 (class 1259 OID 23013)
-- Name: idx_activity_log_action_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_action_type ON public.activity_log USING btree (action_type);


--
-- TOC entry 5201 (class 1259 OID 23012)
-- Name: idx_activity_log_actor_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_actor_user_id ON public.activity_log USING btree (actor_user_id);


--
-- TOC entry 5202 (class 1259 OID 23011)
-- Name: idx_activity_log_org_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_org_created_at ON public.activity_log USING btree (org_id, created_at DESC);


--
-- TOC entry 5203 (class 1259 OID 23014)
-- Name: idx_activity_log_resource_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_resource_type ON public.activity_log USING btree (resource_type);


--
-- TOC entry 5074 (class 1259 OID 22609)
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- TOC entry 5075 (class 1259 OID 22610)
-- Name: idx_app_user_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_org ON public.app_user USING btree (org_id);


--
-- TOC entry 5078 (class 1259 OID 22611)
-- Name: idx_attachment_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_org ON public.attachment USING btree (org_id);


--
-- TOC entry 5079 (class 1259 OID 22612)
-- Name: idx_attachment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_task ON public.attachment USING btree (task_id);


--
-- TOC entry 5082 (class 1259 OID 22613)
-- Name: idx_business_unit_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_business_unit_org ON public.business_unit USING btree (org_id);


--
-- TOC entry 5197 (class 1259 OID 22983)
-- Name: idx_chat_message_session_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_message_session_created ON public.chat_message USING btree (session_id, created_at);


--
-- TOC entry 5193 (class 1259 OID 22981)
-- Name: idx_chat_session_org_user_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_session_org_user_active ON public.chat_session USING btree (org_id, user_id, ended_at);


--
-- TOC entry 5194 (class 1259 OID 22982)
-- Name: idx_chat_session_org_user_started; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_session_org_user_started ON public.chat_session USING btree (org_id, user_id, started_at);


--
-- TOC entry 5187 (class 1259 OID 22932)
-- Name: idx_notification_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_created_at ON public.notification USING btree (created_at);


--
-- TOC entry 5188 (class 1259 OID 22931)
-- Name: idx_notification_recipient_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_recipient_is_read ON public.notification USING btree (recipient_id, is_read);


--
-- TOC entry 5085 (class 1259 OID 22614)
-- Name: idx_organization_azure_tenant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_organization_azure_tenant ON public.organization USING btree (azure_tenant_id);


--
-- TOC entry 5094 (class 1259 OID 22615)
-- Name: idx_project_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_code ON public.project USING btree (project_code);


--
-- TOC entry 5106 (class 1259 OID 22616)
-- Name: idx_project_cost_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_cost_project ON public.project_cost USING btree (project_id);


--
-- TOC entry 5095 (class 1259 OID 22617)
-- Name: idx_project_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_created_by ON public.project USING btree (created_by_id);


--
-- TOC entry 5096 (class 1259 OID 22618)
-- Name: idx_project_delivery_manager; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_delivery_manager ON public.project USING btree (delivery_manager_id);


--
-- TOC entry 5097 (class 1259 OID 22938)
-- Name: idx_project_finance_member; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_finance_member ON public.project USING btree (finance_member_id);


--
-- TOC entry 5109 (class 1259 OID 22619)
-- Name: idx_project_link_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_link_project ON public.project_link USING btree (project_id);


--
-- TOC entry 5098 (class 1259 OID 22620)
-- Name: idx_project_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_org ON public.project USING btree (org_id);


--
-- TOC entry 5099 (class 1259 OID 22621)
-- Name: idx_project_sponsor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_sponsor ON public.project USING btree (sponsor_id);


--
-- TOC entry 5112 (class 1259 OID 22622)
-- Name: idx_project_task_sequence_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_task_sequence_project ON public.project_task_sequence USING btree (project_id);


--
-- TOC entry 5100 (class 1259 OID 22623)
-- Name: idx_project_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_type ON public.project USING btree (project_type);


--
-- TOC entry 5117 (class 1259 OID 22624)
-- Name: idx_resource_cost_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_resource_cost_user ON public.resource_cost USING btree (user_id);


--
-- TOC entry 5122 (class 1259 OID 22625)
-- Name: idx_role_permission_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_role_permission_role ON public.role_permission USING btree (role);


--
-- TOC entry 5125 (class 1259 OID 22626)
-- Name: idx_sprint_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sprint_project ON public.sprint USING btree (project_id);


--
-- TOC entry 5128 (class 1259 OID 22627)
-- Name: idx_tag_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tag_org ON public.tag USING btree (org_id);


--
-- TOC entry 5133 (class 1259 OID 22628)
-- Name: idx_task_assignee; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_assignee ON public.task USING btree (assigned_to);


--
-- TOC entry 5134 (class 1259 OID 22629)
-- Name: idx_task_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_code ON public.task USING btree (task_code);


--
-- TOC entry 5142 (class 1259 OID 22630)
-- Name: idx_task_comment_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_parent ON public.task_comment USING btree (parent_comment_id);


--
-- TOC entry 5143 (class 1259 OID 22631)
-- Name: idx_task_comment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_task ON public.task_comment USING btree (task_id);


--
-- TOC entry 5146 (class 1259 OID 22632)
-- Name: idx_task_link_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_source ON public.task_link USING btree (source_task_id);


--
-- TOC entry 5147 (class 1259 OID 22633)
-- Name: idx_task_link_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_target ON public.task_link USING btree (target_task_id);


--
-- TOC entry 5135 (class 1259 OID 22634)
-- Name: idx_task_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_org ON public.task USING btree (org_id);


--
-- TOC entry 5136 (class 1259 OID 22635)
-- Name: idx_task_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_project ON public.task USING btree (project_id);


--
-- TOC entry 5137 (class 1259 OID 22636)
-- Name: idx_task_sprint; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_sprint ON public.task USING btree (sprint_id);


--
-- TOC entry 5152 (class 1259 OID 22637)
-- Name: idx_task_tag_mapping_tag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_tag ON public.task_tag_mapping USING btree (tag_id);


--
-- TOC entry 5153 (class 1259 OID 22638)
-- Name: idx_task_tag_mapping_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_task ON public.task_tag_mapping USING btree (task_id);


--
-- TOC entry 5156 (class 1259 OID 22639)
-- Name: idx_time_log_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_date ON public.time_log USING btree (log_date);


--
-- TOC entry 5157 (class 1259 OID 22640)
-- Name: idx_time_log_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_task ON public.time_log USING btree (task_id);


--
-- TOC entry 5158 (class 1259 OID 22641)
-- Name: idx_time_log_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user ON public.time_log USING btree (user_id);


--
-- TOC entry 5159 (class 1259 OID 22642)
-- Name: idx_time_log_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user_date ON public.time_log USING btree (user_id, log_date);


--
-- TOC entry 5162 (class 1259 OID 22643)
-- Name: idx_timesheet_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_org ON public.timesheet USING btree (org_id);


--
-- TOC entry 5163 (class 1259 OID 22644)
-- Name: idx_timesheet_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user ON public.timesheet USING btree (user_id);


--
-- TOC entry 5164 (class 1259 OID 22645)
-- Name: idx_timesheet_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user_date ON public.timesheet USING btree (user_id, entry_date);


--
-- TOC entry 5167 (class 1259 OID 22646)
-- Name: idx_user_daily_summary_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_date ON public.user_daily_summary USING btree (summary_date);


--
-- TOC entry 5168 (class 1259 OID 22647)
-- Name: idx_user_daily_summary_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_user ON public.user_daily_summary USING btree (user_id);


--
-- TOC entry 5173 (class 1259 OID 22648)
-- Name: idx_user_permission_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_permission_user_id ON public.user_permission USING btree (user_id);


--
-- TOC entry 5178 (class 1259 OID 22649)
-- Name: idx_user_project_mapping_approval_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_approval_status ON public.user_project_mapping USING btree (approval_status);


--
-- TOC entry 5179 (class 1259 OID 22650)
-- Name: idx_user_project_mapping_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project ON public.user_project_mapping USING btree (project_id);


--
-- TOC entry 5180 (class 1259 OID 22651)
-- Name: idx_user_project_mapping_project_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project_approval ON public.user_project_mapping USING btree (project_id, approval_status);


--
-- TOC entry 5181 (class 1259 OID 22652)
-- Name: idx_user_project_mapping_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user ON public.user_project_mapping USING btree (user_id);


--
-- TOC entry 5182 (class 1259 OID 22653)
-- Name: idx_user_project_mapping_user_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user_approval ON public.user_project_mapping USING btree (user_id, approval_status);


--
-- TOC entry 5105 (class 1259 OID 22654)
-- Name: uq_project_org_finance_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_project_org_finance_code ON public.project USING btree (org_id, finance_code) WHERE (finance_code IS NOT NULL);


--
-- TOC entry 5259 (class 2606 OID 23006)
-- Name: activity_log activity_log_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5260 (class 2606 OID 23001)
-- Name: activity_log activity_log_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5204 (class 2606 OID 22655)
-- Name: app_user app_user_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5205 (class 2606 OID 22660)
-- Name: attachment attachment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5206 (class 2606 OID 22665)
-- Name: attachment attachment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5207 (class 2606 OID 22670)
-- Name: attachment attachment_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.app_user(id);


--
-- TOC entry 5208 (class 2606 OID 22675)
-- Name: business_unit business_unit_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5258 (class 2606 OID 22976)
-- Name: chat_message chat_message_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.chat_session(id) ON DELETE CASCADE;


--
-- TOC entry 5256 (class 2606 OID 22952)
-- Name: chat_session chat_session_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5257 (class 2606 OID 22957)
-- Name: chat_session chat_session_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5209 (class 2606 OID 22933)
-- Name: project fk_project_finance_member; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT fk_project_finance_member FOREIGN KEY (finance_member_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5248 (class 2606 OID 22680)
-- Name: user_permission fk_user_permission_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT fk_user_permission_user FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- TOC entry 5254 (class 2606 OID 22921)
-- Name: notification notification_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.app_user(id);


--
-- TOC entry 5255 (class 2606 OID 22926)
-- Name: notification notification_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id);


--
-- TOC entry 5210 (class 2606 OID 22685)
-- Name: project project_approved_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_approved_by_id_fkey FOREIGN KEY (approved_by_id) REFERENCES public.app_user(id);


--
-- TOC entry 5216 (class 2606 OID 22690)
-- Name: project_cost project_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5217 (class 2606 OID 22695)
-- Name: project_cost project_cost_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5211 (class 2606 OID 22700)
-- Name: project project_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.app_user(id);


--
-- TOC entry 5212 (class 2606 OID 22705)
-- Name: project project_delivery_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_delivery_manager_id_fkey FOREIGN KEY (delivery_manager_id) REFERENCES public.app_user(id);


--
-- TOC entry 5218 (class 2606 OID 22710)
-- Name: project_link project_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5219 (class 2606 OID 22715)
-- Name: project_link project_link_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5213 (class 2606 OID 22720)
-- Name: project project_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.app_user(id);


--
-- TOC entry 5214 (class 2606 OID 22725)
-- Name: project project_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5215 (class 2606 OID 22730)
-- Name: project project_sponsor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_sponsor_id_fkey FOREIGN KEY (sponsor_id) REFERENCES public.app_user(id);


--
-- TOC entry 5220 (class 2606 OID 22735)
-- Name: project_task_sequence project_task_sequence_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5221 (class 2606 OID 22740)
-- Name: resource_cost resource_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5222 (class 2606 OID 22745)
-- Name: resource_cost resource_cost_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5223 (class 2606 OID 22750)
-- Name: sprint sprint_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5224 (class 2606 OID 22755)
-- Name: tag tag_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5225 (class 2606 OID 22760)
-- Name: task task_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.app_user(id);


--
-- TOC entry 5230 (class 2606 OID 22765)
-- Name: task_comment task_comment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5231 (class 2606 OID 22770)
-- Name: task_comment task_comment_parent_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.task_comment(id);


--
-- TOC entry 5232 (class 2606 OID 22775)
-- Name: task_comment task_comment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5233 (class 2606 OID 22780)
-- Name: task_comment task_comment_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5226 (class 2606 OID 22785)
-- Name: task task_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- TOC entry 5234 (class 2606 OID 22790)
-- Name: task_link task_link_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- TOC entry 5235 (class 2606 OID 22795)
-- Name: task_link task_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5236 (class 2606 OID 22800)
-- Name: task_link task_link_source_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_fkey FOREIGN KEY (source_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5237 (class 2606 OID 22805)
-- Name: task_link task_link_target_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_target_task_id_fkey FOREIGN KEY (target_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5227 (class 2606 OID 22810)
-- Name: task task_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5228 (class 2606 OID 22815)
-- Name: task task_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5229 (class 2606 OID 22820)
-- Name: task task_sprint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_sprint_id_fkey FOREIGN KEY (sprint_id) REFERENCES public.sprint(id);


--
-- TOC entry 5238 (class 2606 OID 22825)
-- Name: task_tag_mapping task_tag_mapping_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id) ON DELETE CASCADE;


--
-- TOC entry 5239 (class 2606 OID 22830)
-- Name: task_tag_mapping task_tag_mapping_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5240 (class 2606 OID 22835)
-- Name: time_log time_log_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5241 (class 2606 OID 22840)
-- Name: time_log time_log_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5242 (class 2606 OID 22845)
-- Name: time_log time_log_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5243 (class 2606 OID 22850)
-- Name: time_log time_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5244 (class 2606 OID 22855)
-- Name: timesheet timesheet_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5245 (class 2606 OID 22860)
-- Name: timesheet timesheet_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5246 (class 2606 OID 22865)
-- Name: user_daily_summary user_daily_summary_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5247 (class 2606 OID 22870)
-- Name: user_daily_summary user_daily_summary_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5249 (class 2606 OID 22875)
-- Name: user_project_mapping user_project_mapping_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5250 (class 2606 OID 22880)
-- Name: user_project_mapping user_project_mapping_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5251 (class 2606 OID 22885)
-- Name: user_project_mapping user_project_mapping_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5252 (class 2606 OID 22890)
-- Name: user_project_mapping user_project_mapping_requested_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_requested_by_user_id_fkey FOREIGN KEY (requested_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5253 (class 2606 OID 22895)
-- Name: user_project_mapping user_project_mapping_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


-- Completed on 2026-04-20 16:27:54

--
-- PostgreSQL database dump complete
--

\unrestrict cgkuKzLnN57rMQJpBNdadzdNHbk33TR2Mwm5mqC95TpqCPQxQndUvC85AQfzDgm

