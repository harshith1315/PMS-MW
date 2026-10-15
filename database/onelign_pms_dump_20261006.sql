--
-- PostgreSQL database dump
--

\restrict SIKdg97zV6vtoJdL9W8b8ezQXumKSQ815VQ7qZG2rg0QBE5KJP9CsOAShdKiI0I

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

-- Started on 2026-10-06 13:12:27

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
-- TOC entry 2 (class 3079 OID 49166)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5356 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 49177)
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
-- TOC entry 221 (class 1259 OID 49192)
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    role_id uuid,
    password_hash character varying(255),
    password_setup_token_hash character varying(64),
    password_setup_expires_at timestamp with time zone
);


ALTER TABLE public.app_user OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 49207)
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
-- TOC entry 223 (class 1259 OID 49220)
-- Name: business_unit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.business_unit (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    org_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    status character varying(50) DEFAULT 'ACTIVE'::character varying NOT NULL,
    owner_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.business_unit OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 49230)
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
-- TOC entry 225 (class 1259 OID 49242)
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
-- TOC entry 226 (class 1259 OID 49253)
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
-- TOC entry 227 (class 1259 OID 49271)
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
-- TOC entry 228 (class 1259 OID 49281)
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
-- TOC entry 229 (class 1259 OID 49292)
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
    project_summary text,
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
-- TOC entry 230 (class 1259 OID 49323)
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
-- TOC entry 231 (class 1259 OID 49337)
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
-- TOC entry 232 (class 1259 OID 49350)
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
-- TOC entry 233 (class 1259 OID 49358)
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
-- TOC entry 234 (class 1259 OID 49369)
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    permissions jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_system boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.role OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 49388)
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
-- TOC entry 236 (class 1259 OID 49398)
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
-- TOC entry 237 (class 1259 OID 49407)
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
    epic_id uuid,
    story_id uuid,
    updated_at timestamp without time zone
);


ALTER TABLE public.task OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 49420)
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
-- TOC entry 239 (class 1259 OID 49433)
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
-- TOC entry 240 (class 1259 OID 49443)
-- Name: task_tag_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_tag_mapping (
    task_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.task_tag_mapping OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 49448)
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
-- TOC entry 242 (class 1259 OID 49464)
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
-- TOC entry 243 (class 1259 OID 49479)
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
-- TOC entry 244 (class 1259 OID 49490)
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
-- TOC entry 245 (class 1259 OID 49503)
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
    resource_type character varying(20) DEFAULT 'DEDICATED'::character varying NOT NULL,
    CONSTRAINT user_project_mapping_allocated_bandwidth_check CHECK (((allocated_bandwidth >= 0) AND (allocated_bandwidth <= 100))),
    CONSTRAINT user_project_mapping_resource_type_check CHECK (((resource_type)::text = ANY (ARRAY[('SHARED'::character varying)::text, ('DEDICATED'::character varying)::text])))
);


ALTER TABLE public.user_project_mapping OWNER TO postgres;

--
-- TOC entry 5325 (class 0 OID 49177)
-- Dependencies: 220
-- Data for Name: activity_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_log (id, org_id, actor_user_id, actor_name, actor_email, method, resource_type, resource_id, action_type, message, request_path, ip_address, user_agent, metadata, created_at) FROM stdin;
d544f5f1-f331-42e5-aec2-e82a409309b8	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 16:24:28.71736
f3d84349-4fff-4349-9fe8-d4ac39c22d3b	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 16:35:37.543018
cd927343-ce9e-40f7-b7f8-3de61b44b338	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:16:03.93265
bc029791-b55d-4ab9-9f4c-56fbb9b83317	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:16:45.306928
eadaea4e-de5d-42c0-a167-50e3e9de08e2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:17:03.587694
0fddba48-f4d4-4830-8838-0371ffc2b486	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:26:30.626488
ba3cb013-5a66-42f9-94a0-e949e0ad70c0	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:31:27.763758
8ab6584f-96a7-4559-b060-512c7a4bd30e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:35:42.20321
58775753-f4df-4aae-a862-fbab2e69f1bd	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:37:44.850531
95feeb3f-7920-4664-8314-302e576d9af7	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:41:18.687248
1c23cf90-4e13-47db-96c7-dcab0a207c75	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:21:08.305217
556161e9-00f1-4085-86c0-23b6dcaad5e6	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:22:59.701589
10ca2d4b-1c1b-4e0b-9427-f73073c6cfb2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:24:27.424733
6e268f34-eb55-444e-93f6-16963eb756cb	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	POST	task	687a4cb9-0753-4285-9e0b-05c38eee759e	TASK_CREATED	Task 'R&D Login Page' (PROJ-1237-7) created	/tasks	\N	\N	{}	2026-04-20 22:30:20.182797
6519a784-04d3-445e-b7f3-421881401e72	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	tasks	687a4cb9-0753-4285-9e0b-05c38eee759e	TASKS_UPDATED	Harshith Kanumuri updated tags for Task ID 687a4cb9-0753-4285-9e0b-05c38eee759e.	/api/v1/tasks/687a4cb9-0753-4285-9e0b-05c38eee759e/tags	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "687a4cb9-0753-4285-9e0b-05c38eee759e"}}	2026-04-20 22:30:20.412136
19bebdcf-cd92-4f0d-a392-957241a33f89	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	POST	task	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_CREATED	Task 'Tenant Configuration' (PROJ-1237-8) created	/tasks	\N	\N	{}	2026-04-20 22:31:22.68067
b6045355-c5e5-4298-bdad-7ba176260773	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	tasks	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASKS_UPDATED	Harshith Kanumuri updated tags for Task ID 15f999f2-dd27-4857-bb4d-ad75aa7d5ff5.	/api/v1/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/tags	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "15f999f2-dd27-4857-bb4d-ad75aa7d5ff5"}}	2026-04-20 22:31:22.885739
c6a44ae5-a685-47c4-b915-b06fc1e8b852	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:37:03.770538
b8cb0b08-c318-4d7c-b087-4a7272d59f65	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_OUT	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged out	/auth/logout	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 16:24:34.455094
23186987-1ea4-4a53-a520-379d3476e5d8	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:10:02.739366
669df94a-5e36-4f6c-8fe4-b38e4cf0c667	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:16:11.026789
61623d0b-9091-49e2-8888-767f8338cdc4	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:17:07.468506
3b2c784e-3c1c-4666-b4f7-4cd79ba80796	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:29:06.3349
1b93e7f5-ce26-4c07-87ec-c32cfa5b08e1	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:34:30.843965
e5be3241-4813-46ac-971d-cdb01dae7fe9	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:35:47.405864
fd46e8e8-5bb7-40ce-a424-d3134635f1de	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 18:37:50.943057
a04bc4f5-a19d-4566-8e8a-4951b4e62f4f	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:15:30.384557
41c98e99-16f5-4439-9e99-f6d7e1ed22f2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:22:07.024133
5adbada2-5f71-41bd-be08-40b76812c1b3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:23:52.422337
80dfd8a4-8e3b-4df4-a5d4-3a01809ee00d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:23:55.615913
62ff0d77-1250-4195-a792-f3b1a953fd07	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:27:20.050913
1d98fe28-00fc-4e9c-ac1b-d129d2ff6fa4	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	tasks	687a4cb9-0753-4285-9e0b-05c38eee759e	TASKS_CREATED	Harshith Kanumuri changed status of Task ID 687a4cb9-0753-4285-9e0b-05c38eee759e to TODO.	/api/v1/tasks	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-20 22:30:20.308815
51ca9e30-e29f-48d5-82ca-6651324bbba3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	tasks	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASKS_CREATED	Harshith Kanumuri changed status of Task ID 15f999f2-dd27-4857-bb4d-ad75aa7d5ff5 to TODO.	/api/v1/tasks	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-20 22:31:22.780325
4eedb6f7-5577-4b00-a8b2-e085d2949e8b	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:32:43.042721
aa646c04-4309-4451-a8c2-7ad32f73a45f	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:37:23.036524
19b7aecf-3aa9-47a4-a41f-2f049ee9d69b	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	task	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_ASSIGNED	Task 'Tenant Configuration' (PROJ-1237-8) assigned to user edb1541e-efee-435d-a4cd-6e7da392464a	/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/assign	\N	\N	{"assigneeId": "edb1541e-efee-435d-a4cd-6e7da392464a"}	2026-04-20 22:55:37.140299
d7f5f98e-3208-4686-a492-e4de5fd2dcce	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	tasks	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_ASSIGNEE_UPDATED	Harshith Kanumuri updated assignee for Task ID 15f999f2-dd27-4857-bb4d-ad75aa7d5ff5.	/api/v1/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/assign	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "15f999f2-dd27-4857-bb4d-ad75aa7d5ff5"}}	2026-04-20 22:55:37.140581
959610e4-8329-4757-b5b6-5056c1db4ae3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	task	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_STATUS_UPDATED	Task 'Tenant Configuration' (PROJ-1237-8) status changed to IN_PROGRESS	/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/status	\N	\N	{"status": "IN_PROGRESS"}	2026-04-20 22:55:41.324884
b63cf976-3b07-4978-b162-54b3b2f3c712	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	tasks	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_STATUS_UPDATED	Harshith Kanumuri changed status of Task ID 15f999f2-dd27-4857-bb4d-ad75aa7d5ff5 to IN_PROGRESS.	/api/v1/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/status	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "15f999f2-dd27-4857-bb4d-ad75aa7d5ff5"}}	2026-04-20 22:55:41.362747
7a02f7f4-29f7-455f-8752-a8978d3b84e9	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	attachments	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	ATTACHMENTS_CREATED	Harshith Kanumuri created Attachment ID 15f999f2-dd27-4857-bb4d-ad75aa7d5ff5.	/api/v1/attachments/upload/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"taskId": "15f999f2-dd27-4857-bb4d-ad75aa7d5ff5"}}	2026-04-20 22:56:05.245442
9a9bc2a0-65e0-4836-9a12-31755fe79443	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	comments	8b7fff7f-6b54-47be-8ef1-4a0fb2f1e919	COMMENTS_CREATED	Harshith Kanumuri created Comment ID 8b7fff7f-6b54-47be-8ef1-4a0fb2f1e919.	/api/v1/comments	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-20 22:56:22.077971
9b7969e0-326b-445f-8fb0-4fe672a00608	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:57:12.025317
a17478e2-fe9c-4490-b68e-fc0ab3527161	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 22:59:34.430124
10405266-74f9-45f9-90fb-88ca90b7fbb5	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:03:36.894964
cd364935-4eb8-4bbb-82b7-c7d7995def2b	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	edb1541e-efee-435d-a4cd-6e7da392464a	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID edb1541e-efee-435d-a4cd-6e7da392464a.	/api/v1/access-control/users/edb1541e-efee-435d-a4cd-6e7da392464a/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"userId": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:04:33.046408
448331d8-61be-4742-8154-faeaeab8aabb	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	edb1541e-efee-435d-a4cd-6e7da392464a	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID edb1541e-efee-435d-a4cd-6e7da392464a.	/api/v1/access-control/users/edb1541e-efee-435d-a4cd-6e7da392464a/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"userId": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:04:42.235083
8b0a3973-a2da-4bc2-82cb-1505a739bde1	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:09:07.699221
869dfef3-7ab8-49d8-a6cd-e7ccbc2a88bc	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	2e745634-fcc5-46db-9651-a6cfe30aa537	USERS_UPDATED	Harshith Kanumuri updated profile details for ganthikugan.jaipal.	/api/v1/users/2e745634-fcc5-46db-9651-a6cfe30aa537	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "2e745634-fcc5-46db-9651-a6cfe30aa537"}}	2026-04-20 23:10:03.27605
944b787b-f18a-47dc-8137-7e654b9c597c	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	user	2e745634-fcc5-46db-9651-a6cfe30aa537	USER_ROLE_UPDATED	User 'ganthikugan.jaipal@bonbloc.com' role changed to MANAGER	/users/2e745634-fcc5-46db-9651-a6cfe30aa537/role	\N	\N	{"newRole": "MANAGER", "newRoleId": "c4d1b86c-c54e-4724-805e-c1326bb968f0"}	2026-04-20 23:10:03.406237
d2fe4182-8006-48b4-8871-1ae36e7f326b	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	2e745634-fcc5-46db-9651-a6cfe30aa537	USER_ROLE_UPDATED	Harshith Kanumuri changed role for User ID 2e745634-fcc5-46db-9651-a6cfe30aa537 to MANAGER.	/api/v1/users/2e745634-fcc5-46db-9651-a6cfe30aa537/role	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "2e745634-fcc5-46db-9651-a6cfe30aa537"}}	2026-04-20 23:10:03.406985
41163996-e885-46e5-a075-deadc8a73855	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	542ed024-dfa4-4247-8794-5f47f996fd2a	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID 542ed024-dfa4-4247-8794-5f47f996fd2a.	/api/v1/access-control/roles/id/542ed024-dfa4-4247-8794-5f47f996fd2a/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "542ed024-dfa4-4247-8794-5f47f996fd2a"}}	2026-04-20 23:11:06.312451
eebf7a90-c0ad-4fd8-aaae-93f9596c47af	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:11:32.491561
5f1810f5-d635-41a5-96e4-0e75816d18d6	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:11:48.588957
d3bb3055-489a-4ee3-b393-07928a9b6eea	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:12:11.76318
2e17b740-8a1f-4425-9a50-e22e19f22fa3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:12:55.582347
e53fb97b-424c-4640-8a05-a29199a9d28d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	542ed024-dfa4-4247-8794-5f47f996fd2a	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID 542ed024-dfa4-4247-8794-5f47f996fd2a.	/api/v1/access-control/roles/id/542ed024-dfa4-4247-8794-5f47f996fd2a/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "542ed024-dfa4-4247-8794-5f47f996fd2a"}}	2026-04-20 23:13:22.291737
912d1215-8f6c-4cac-8ceb-d376aba8409e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	edb1541e-efee-435d-a4cd-6e7da392464a	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID edb1541e-efee-435d-a4cd-6e7da392464a.	/api/v1/access-control/users/edb1541e-efee-435d-a4cd-6e7da392464a/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"userId": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:13:43.211358
a4740590-197d-4451-9e8e-0665d700229c	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:13:53.663269
fcfeeb81-0e8e-43ac-b3a8-5fd5ece5e321	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	edb1541e-efee-435d-a4cd-6e7da392464a	USERS_UPDATED	Harshith Kanumuri updated profile details for Harshith Kanumuri.	/api/v1/users/edb1541e-efee-435d-a4cd-6e7da392464a	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:14:23.307307
372c60a5-ec9c-4919-9c08-8d4235c8d7ae	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	user	edb1541e-efee-435d-a4cd-6e7da392464a	USER_ROLE_UPDATED	User 'harshith.kanumuri@bonbloc.com' role changed to DEVELOPER	/users/edb1541e-efee-435d-a4cd-6e7da392464a/role	\N	\N	{"newRole": "DEVELOPER", "newRoleId": "542ed024-dfa4-4247-8794-5f47f996fd2a"}	2026-04-20 23:14:23.413971
c347c2e2-1382-48a1-b327-a403551f2cda	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	edb1541e-efee-435d-a4cd-6e7da392464a	USER_ROLE_UPDATED	Harshith Kanumuri changed role for User ID edb1541e-efee-435d-a4cd-6e7da392464a to DEVELOPER.	/api/v1/users/edb1541e-efee-435d-a4cd-6e7da392464a/role	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:14:23.414153
cae08bbe-673a-4d06-b7b7-5faf9dd6be27	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:14:26.088308
a4ebedde-140c-41b7-9ea5-0bb80720dbe3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	edb1541e-efee-435d-a4cd-6e7da392464a	USERS_UPDATED	Harshith Kanumuri updated profile details for Harshith Kanumuri.	/api/v1/users/edb1541e-efee-435d-a4cd-6e7da392464a	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:14:49.8501
9a576fc5-1d32-4573-8fb2-914fde39d841	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:18:49.486403
7140d822-68c0-4972-abfb-dc6bd227039e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	edb1541e-efee-435d-a4cd-6e7da392464a	USERS_UPDATED	Harshith Kanumuri updated profile details for Harshith Kanumuri.	/api/v1/users/edb1541e-efee-435d-a4cd-6e7da392464a	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:19:06.422133
7efdf939-8de3-4032-9ac6-8f2b7726eca8	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	user	edb1541e-efee-435d-a4cd-6e7da392464a	USER_ROLE_UPDATED	User 'harshith.kanumuri@bonbloc.com' role changed to DEVELOPER	/users/edb1541e-efee-435d-a4cd-6e7da392464a/role	\N	\N	{"newRole": "DEVELOPER", "newRoleId": "542ed024-dfa4-4247-8794-5f47f996fd2a"}	2026-04-20 23:19:06.542261
a1e5d6f7-3ea2-4d50-8b1c-2a249e1bc89f	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	edb1541e-efee-435d-a4cd-6e7da392464a	USER_ROLE_UPDATED	Harshith Kanumuri changed role for User ID edb1541e-efee-435d-a4cd-6e7da392464a to DEVELOPER.	/api/v1/users/edb1541e-efee-435d-a4cd-6e7da392464a/role	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:19:06.542631
cceac944-070f-436d-96c6-0b822b0c3892	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:19:09.290445
5ae3b63b-9354-4172-80c7-df9e6d928e46	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:19:43.25933
9749322b-ba71-4344-9f2b-0adc935109fa	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:22:26.94483
a7130668-b67a-41a8-862f-ebc74b307dc0	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	access-control	b3fcf94a-40cd-4a56-be8e-c92f44e427ca	ACCESS_CONTROL_CREATED	Harshith Kanumuri created Access Control ID b3fcf94a-40cd-4a56-be8e-c92f44e427ca.	/api/v1/access-control/roles	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-20 23:22:54.409506
3a38002e-dced-4051-a6fe-58d2db40e5ad	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	b3fcf94a-40cd-4a56-be8e-c92f44e427ca	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID b3fcf94a-40cd-4a56-be8e-c92f44e427ca.	/api/v1/access-control/roles/id/b3fcf94a-40cd-4a56-be8e-c92f44e427ca/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "b3fcf94a-40cd-4a56-be8e-c92f44e427ca"}}	2026-04-20 23:23:53.950789
b4a4a5b9-07dd-4104-ad1b-05b814033a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	edb1541e-efee-435d-a4cd-6e7da392464a	USERS_UPDATED	Harshith Kanumuri updated profile details for Harshith Kanumuri.	/api/v1/users/edb1541e-efee-435d-a4cd-6e7da392464a	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:24:25.174332
901b7e28-305c-4beb-82e1-6363945df3b7	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	user	edb1541e-efee-435d-a4cd-6e7da392464a	USER_ROLE_UPDATED	User 'harshith.kanumuri@bonbloc.com' role changed to BA	/users/edb1541e-efee-435d-a4cd-6e7da392464a/role	\N	\N	{"newRole": "BA", "newRoleId": "b3fcf94a-40cd-4a56-be8e-c92f44e427ca"}	2026-04-20 23:24:25.238571
c3ab4713-c2f2-439c-85c3-6ccc011f8672	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	edb1541e-efee-435d-a4cd-6e7da392464a	USER_ROLE_UPDATED	Harshith Kanumuri changed role for User ID edb1541e-efee-435d-a4cd-6e7da392464a to BA.	/api/v1/users/edb1541e-efee-435d-a4cd-6e7da392464a/role	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:24:25.238706
05f9d7fe-5f01-4cb8-b6de-02574061fbc3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:24:27.724371
2f6c9ede-8ebf-44f1-9b1a-27e1f6895178	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:25:33.904159
213663b0-9930-4cd4-bade-3fa29e5a152a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:27:43.975558
4fc73ad5-921a-4717-97f4-af2cbccdf667	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:28:22.033887
597aab6d-9962-4f8d-9d86-a3c1a9f29755	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	DELETE	business-units	0dd406a2-707c-4e50-9d44-1b6404cf6aa4	BUSINESS_UNITS_DELETED	Harshith Kanumuri deleted Business Unit ID 0dd406a2-707c-4e50-9d44-1b6404cf6aa4.	/api/v1/business-units/0dd406a2-707c-4e50-9d44-1b6404cf6aa4	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "0dd406a2-707c-4e50-9d44-1b6404cf6aa4"}}	2026-04-20 23:31:12.856023
9a022109-eb41-4c88-a7b4-6da2e5da23f2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	DELETE	business-units	827c6fcb-8c8a-410c-9609-98d25ad213de	BUSINESS_UNITS_DELETED	Harshith Kanumuri deleted Business Unit ID 827c6fcb-8c8a-410c-9609-98d25ad213de.	/api/v1/business-units/827c6fcb-8c8a-410c-9609-98d25ad213de	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "827c6fcb-8c8a-410c-9609-98d25ad213de"}}	2026-04-20 23:31:16.982461
19f4f831-1304-4996-badd-ac586e57f327	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	DELETE	business-units	8b3dd1fc-a42b-4cc7-b531-f62246d96ccb	BUSINESS_UNITS_DELETED	Harshith Kanumuri deleted Business Unit ID 8b3dd1fc-a42b-4cc7-b531-f62246d96ccb.	/api/v1/business-units/8b3dd1fc-a42b-4cc7-b531-f62246d96ccb	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "8b3dd1fc-a42b-4cc7-b531-f62246d96ccb"}}	2026-04-20 23:31:19.564958
ec55546c-c896-461b-864e-00c81fe2505e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	business-units	2e3a99b6-18d5-4963-a961-7709a16fb343	BUSINESS_UNITS_CREATED	Harshith Kanumuri created Business Unit ID 2e3a99b6-18d5-4963-a961-7709a16fb343.	/api/v1/business-units	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-20 23:31:40.026732
e1550e76-2d92-4bd4-ac85-16392244ef3e	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	PUT	project	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	PROJECT_UPDATED	Project 'LMS-PH' (PROJ-1237) updated	/projects/10ac6760-95d0-4f5d-acb5-52126ff0c7e1	\N	\N	{}	2026-04-20 23:32:05.41907
b5e96821-7bbc-4e37-a6e7-509ae77044cc	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	projects	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	PROJECTS_UPDATED	Harshith Kanumuri updated Project ID 10ac6760-95d0-4f5d-acb5-52126ff0c7e1.	/api/v1/projects/10ac6760-95d0-4f5d-acb5-52126ff0c7e1	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "10ac6760-95d0-4f5d-acb5-52126ff0c7e1"}}	2026-04-20 23:32:05.419288
e2aa92bd-1dcb-432f-8082-ef7a10883d90	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:32:10.450518
504de4a2-f0e3-4988-89b2-8d14105ad5ec	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:34:42.454611
fe26c579-30f7-4fba-aaf5-3bcb41630ca1	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:35:03.716747
e8889563-5c90-41fb-9c53-a22fb8a3accc	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:38:05.136629
799cffdf-4411-421b-a959-d27ab24400ac	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:39:38.163741
8d895db5-f349-45bc-94d2-1ae5d75490c7	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	task	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	TASK_STATUS_UPDATED	Task 'R&D Animation for login page' (PROJ-1237-3) status changed to IN_PROGRESS	/tasks/c5b77141-3868-4b1b-849a-e9ffd1e5b4a4/status	\N	\N	{"status": "IN_PROGRESS"}	2026-04-20 23:41:24.511942
feb2e5e6-6c91-4fed-8c33-4fecf930f505	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	tasks	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	TASK_STATUS_UPDATED	Harshith Kanumuri changed status of Task ID c5b77141-3868-4b1b-849a-e9ffd1e5b4a4 to IN_PROGRESS.	/api/v1/tasks/c5b77141-3868-4b1b-849a-e9ffd1e5b4a4/status	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "c5b77141-3868-4b1b-849a-e9ffd1e5b4a4"}}	2026-04-20 23:41:24.55077
9e751c24-232f-4cd9-91ce-09028335185a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	task	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	TASK_STATUS_UPDATED	Task 'R&D Animation for login page' (PROJ-1237-3) status changed to BLOCKED	/tasks/c5b77141-3868-4b1b-849a-e9ffd1e5b4a4/status	\N	\N	{"status": "BLOCKED"}	2026-04-20 23:41:28.009905
bb125aba-2bd1-474b-a1ca-46552a1d8997	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	POST	user	26e46ea9-fd64-466f-ae5c-235c2b75727f	USER_INVITED	User 'dharani.mattakapu@bonbloc.com' invited to organization with role USER	/users/invite	\N	\N	{"role": "USER", "email": "dharani.mattakapu@bonbloc.com", "roleId": "da6ea245-5025-46f4-a718-4e552cc8d8fc"}	2026-04-23 14:16:29.765276
ecacd100-7ce7-4cd7-ac1d-343347c73c41	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	tasks	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	TASK_STATUS_UPDATED	Harshith Kanumuri changed status of Task ID c5b77141-3868-4b1b-849a-e9ffd1e5b4a4 to BLOCKED.	/api/v1/tasks/c5b77141-3868-4b1b-849a-e9ffd1e5b4a4/status	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "c5b77141-3868-4b1b-849a-e9ffd1e5b4a4"}}	2026-04-20 23:41:28.041174
3191a5e9-11a7-4260-ba41-f79a6e57dbe4	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	notifications	bb8e9457-0703-427b-a004-48a44e36b1d0	NOTIFICATIONS_UPDATED	Harshith Kanumuri updated Notification ID bb8e9457-0703-427b-a004-48a44e36b1d0.	/api/v1/notifications/bb8e9457-0703-427b-a004-48a44e36b1d0/read	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "bb8e9457-0703-427b-a004-48a44e36b1d0"}}	2026-04-20 23:41:37.964417
23b336c7-3436-4f05-bd39-6cf237210065	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	task	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	TASK_STATUS_UPDATED	Task 'R&D Animation for login page' (PROJ-1237-3) status changed to IN_PROGRESS	/tasks/c5b77141-3868-4b1b-849a-e9ffd1e5b4a4/status	\N	\N	{"status": "IN_PROGRESS"}	2026-04-20 23:41:43.430379
b27f5a13-53ea-4a45-b8d8-8ae4dd89adc1	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	tasks	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	TASK_STATUS_UPDATED	Harshith Kanumuri changed status of Task ID c5b77141-3868-4b1b-849a-e9ffd1e5b4a4 to IN_PROGRESS.	/api/v1/tasks/c5b77141-3868-4b1b-849a-e9ffd1e5b4a4/status	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "c5b77141-3868-4b1b-849a-e9ffd1e5b4a4"}}	2026-04-20 23:41:43.469217
1bf2eff7-b76a-49c6-92d3-3c951e2f0cc1	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:47:05.709611
f9185805-86d5-44cc-9b5c-151686168892	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	access-control	231ef88c-a2f1-4f9c-bc63-e164cbc83119	ACCESS_CONTROL_CREATED	Harshith Kanumuri created Access Control ID 231ef88c-a2f1-4f9c-bc63-e164cbc83119.	/api/v1/access-control/roles	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-20 23:47:20.88174
c0622d53-7546-4af3-a000-cdfa811afcc4	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	231ef88c-a2f1-4f9c-bc63-e164cbc83119	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID 231ef88c-a2f1-4f9c-bc63-e164cbc83119.	/api/v1/access-control/roles/id/231ef88c-a2f1-4f9c-bc63-e164cbc83119/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "231ef88c-a2f1-4f9c-bc63-e164cbc83119"}}	2026-04-20 23:47:57.465656
774672e1-fc0e-4720-9997-e4eb1483e7b5	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	edb1541e-efee-435d-a4cd-6e7da392464a	USERS_UPDATED	Harshith Kanumuri updated profile details for Harshith Kanumuri.	/api/v1/users/edb1541e-efee-435d-a4cd-6e7da392464a	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:48:11.415856
f1571642-3c54-45b6-808c-34a90e46e6bb	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	user	edb1541e-efee-435d-a4cd-6e7da392464a	USER_ROLE_UPDATED	User 'harshith.kanumuri@bonbloc.com' role changed to TEST	/users/edb1541e-efee-435d-a4cd-6e7da392464a/role	\N	\N	{"newRole": "TEST", "newRoleId": "231ef88c-a2f1-4f9c-bc63-e164cbc83119"}	2026-04-20 23:48:11.491738
c046f72c-6089-461b-bc18-3370266864c5	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	edb1541e-efee-435d-a4cd-6e7da392464a	USER_ROLE_UPDATED	Harshith Kanumuri changed role for User ID edb1541e-efee-435d-a4cd-6e7da392464a to TEST.	/api/v1/users/edb1541e-efee-435d-a4cd-6e7da392464a/role	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "edb1541e-efee-435d-a4cd-6e7da392464a"}}	2026-04-20 23:48:11.492068
1fccdb91-c758-4fcb-aff0-3d921fc2a386	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:48:16.906229
0b87ef58-3553-408e-84a5-f8de9d99b5d9	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:48:54.767547
de9a127d-9b82-4eec-a953-360c87ecbb61	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	POST	project	419181cd-9863-4d81-843c-4644a4d31faa	PROJECT_CREATED	Project 'ERP' (ERPS694) created	/projects	\N	\N	{}	2026-04-20 23:52:58.780464
d90ce97f-4f4f-436f-8eca-83ee9d29e4ee	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	projects	419181cd-9863-4d81-843c-4644a4d31faa	PROJECTS_CREATED	Harshith Kanumuri created Project ID 419181cd-9863-4d81-843c-4644a4d31faa.	/api/v1/projects	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-20 23:52:58.835009
fb583ca5-edee-4dbf-9923-01399fa34fb9	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	PUT	project	419181cd-9863-4d81-843c-4644a4d31faa	PROJECT_UPDATED	Project 'ERP' (ERPS694) updated	/projects/419181cd-9863-4d81-843c-4644a4d31faa	\N	\N	{}	2026-04-20 23:53:28.230039
77823411-38a4-4891-8d43-4448ac501107	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	projects	419181cd-9863-4d81-843c-4644a4d31faa	PROJECTS_UPDATED	Harshith Kanumuri updated Project ID 419181cd-9863-4d81-843c-4644a4d31faa.	/api/v1/projects/419181cd-9863-4d81-843c-4644a4d31faa	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "419181cd-9863-4d81-843c-4644a4d31faa"}}	2026-04-20 23:53:28.230413
f6807469-f587-40c4-ab86-17a8d1155eb8	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:55:57.494106
cbed525e-f8de-4975-b088-e389b629f253	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	PUT	project	419181cd-9863-4d81-843c-4644a4d31faa	PROJECT_UPDATED	Project 'ERP' (ERPS694) updated	/projects/419181cd-9863-4d81-843c-4644a4d31faa	\N	\N	{}	2026-04-20 23:56:33.940443
324b65f6-b41b-4c98-9303-d3c49bce1b5e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	projects	419181cd-9863-4d81-843c-4644a4d31faa	PROJECTS_UPDATED	Harshith Kanumuri updated Project ID 419181cd-9863-4d81-843c-4644a4d31faa.	/api/v1/projects/419181cd-9863-4d81-843c-4644a4d31faa	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "419181cd-9863-4d81-843c-4644a4d31faa"}}	2026-04-20 23:56:33.940708
7c09416c-edaa-4121-848f-cce7dbbe5483	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:56:59.610401
7658abb9-923e-40f2-aedd-99b2762d9ecc	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	PUT	project	419181cd-9863-4d81-843c-4644a4d31faa	PROJECT_UPDATED	Project 'ERP' (ERPS694) updated	/projects/419181cd-9863-4d81-843c-4644a4d31faa	\N	\N	{}	2026-04-20 23:57:07.047379
c89c7c46-73d3-4d7e-9aaa-5817cec2fc65	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	projects	419181cd-9863-4d81-843c-4644a4d31faa	PROJECTS_UPDATED	Harshith Kanumuri updated Project ID 419181cd-9863-4d81-843c-4644a4d31faa.	/api/v1/projects/419181cd-9863-4d81-843c-4644a4d31faa	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "419181cd-9863-4d81-843c-4644a4d31faa"}}	2026-04-20 23:57:07.047484
b9bd6045-60b3-4fc8-8a4b-90a3fa3ed658	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-20 23:57:09.077809
c831569f-bc7c-4747-8817-a01aadac28d9	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 09:38:56.806254
02e69fc2-ba57-4147-88bb-d838aae2c1f2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 09:43:34.915883
7a3f8c3f-fd4e-436a-9db0-6f41c128f685	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 09:53:08.876489
fe755c72-a6ec-4004-9d5b-32fd19791316	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	tasks	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASKS_CREATED	Harshith Kanumuri created Task ID 15f999f2-dd27-4857-bb4d-ad75aa7d5ff5.	/api/v1/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "15f999f2-dd27-4857-bb4d-ad75aa7d5ff5"}}	2026-04-21 09:53:20.661992
a37fa655-9c93-4508-92d0-2a569f34a012	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	\N	CHAT_CREATED	Harshith Kanumuri created chat unknown.	/api/v1/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-21 09:53:33.271141
b1272458-1911-4fc8-adfe-c1b57091f7d0	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59	CHAT_CREATED	Harshith Kanumuri created chat 4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59.	/api/v1/chat/sessions/4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59"}}	2026-04-21 09:53:34.72582
b2812bf2-c279-46ba-915b-125f12450a99	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59	CHAT_CREATED	Harshith Kanumuri created chat 4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59.	/api/v1/chat/sessions/4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59"}}	2026-04-21 09:53:54.229032
8b29bada-a437-48e6-a501-fec8cd2aea18	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59	CHAT_CREATED	Harshith Kanumuri created chat 4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59.	/api/v1/chat/sessions/4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59"}}	2026-04-21 09:53:58.431523
cfd7d65e-78bf-4128-b870-e24bb71ac575	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 09:54:42.300263
c2b5f4db-338c-444e-9517-ac55ed684147	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	\N	CHAT_CREATED	Harshith Kanumuri created chat unknown.	/api/v1/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-21 09:54:56.128425
271a0863-4c35-4cc7-bce2-e86ef63ec90d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	CHAT_CREATED	Harshith Kanumuri created chat 1f8c4299-ba1b-47d4-9a27-5caeae69b7ce.	/api/v1/chat/sessions/1f8c4299-ba1b-47d4-9a27-5caeae69b7ce/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "1f8c4299-ba1b-47d4-9a27-5caeae69b7ce"}}	2026-04-21 09:54:57.543378
6fc88e55-9447-4ac8-9a6c-cf0660fa5fd4	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	CHAT_CREATED	Harshith Kanumuri created chat 1f8c4299-ba1b-47d4-9a27-5caeae69b7ce.	/api/v1/chat/sessions/1f8c4299-ba1b-47d4-9a27-5caeae69b7ce/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "1f8c4299-ba1b-47d4-9a27-5caeae69b7ce"}}	2026-04-21 09:55:12.750265
068b938f-75e1-4252-9d23-ac0a13f9ec67	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	CHAT_CREATED	Harshith Kanumuri created chat 1f8c4299-ba1b-47d4-9a27-5caeae69b7ce.	/api/v1/chat/sessions/1f8c4299-ba1b-47d4-9a27-5caeae69b7ce/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "1f8c4299-ba1b-47d4-9a27-5caeae69b7ce"}}	2026-04-21 09:55:36.922791
2410b91a-1dda-43c2-ac4c-6b282b05512d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	CHAT_CREATED	Harshith Kanumuri created chat 1f8c4299-ba1b-47d4-9a27-5caeae69b7ce.	/api/v1/chat/sessions/1f8c4299-ba1b-47d4-9a27-5caeae69b7ce/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "1f8c4299-ba1b-47d4-9a27-5caeae69b7ce"}}	2026-04-21 09:57:06.391429
114e3e3e-fe0f-4506-ba31-8534db8af293	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	\N	CHAT_CREATED	Harshith Kanumuri created chat unknown.	/api/v1/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-21 10:38:07.844671
5bf6d385-ccc8-497e-b2c6-fb94d04cce70	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	2559dd2c-acb2-4b77-bce9-9410ccc95632	CHAT_CREATED	Harshith Kanumuri created chat 2559dd2c-acb2-4b77-bce9-9410ccc95632.	/api/v1/chat/sessions/2559dd2c-acb2-4b77-bce9-9410ccc95632/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "2559dd2c-acb2-4b77-bce9-9410ccc95632"}}	2026-04-21 10:38:10.884001
940abef5-f233-4795-8d37-fbb36973b868	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 10:39:04.044046
721f9f3d-1446-4fe5-9762-754d98d18386	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	\N	CHAT_CREATED	Harshith Kanumuri created chat unknown.	/api/v1/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-21 10:39:25.295564
a3eb210b-aca2-4bdf-b450-d827641d3d47	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	2559dd2c-acb2-4b77-bce9-9410ccc95632	CHAT_CREATED	Harshith Kanumuri created chat 2559dd2c-acb2-4b77-bce9-9410ccc95632.	/api/v1/chat/sessions/2559dd2c-acb2-4b77-bce9-9410ccc95632/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "2559dd2c-acb2-4b77-bce9-9410ccc95632"}}	2026-04-21 10:39:26.858303
6568b857-563d-4806-863e-690727499283	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	2559dd2c-acb2-4b77-bce9-9410ccc95632	CHAT_CREATED	Harshith Kanumuri created chat 2559dd2c-acb2-4b77-bce9-9410ccc95632.	/api/v1/chat/sessions/2559dd2c-acb2-4b77-bce9-9410ccc95632/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "2559dd2c-acb2-4b77-bce9-9410ccc95632"}}	2026-04-21 10:39:41.617154
643adccb-d24a-45e7-a41c-78be38c3ae80	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 10:40:02.720148
cd1ecac7-55b5-4667-8494-caaf974b51a8	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	business-units	af75275a-c25e-4dff-99e4-ce5a9c6c379b	BUSINESS_UNITS_UPDATED	Harshith Kanumuri updated Business Unit ID af75275a-c25e-4dff-99e4-ce5a9c6c379b.	/api/v1/business-units/af75275a-c25e-4dff-99e4-ce5a9c6c379b	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "af75275a-c25e-4dff-99e4-ce5a9c6c379b"}}	2026-04-21 10:44:48.785083
d64af69e-ee58-439b-aea2-0c85d4bef151	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	user	8a00286c-b21d-46f7-816f-b9be2a66b62f	USER_ACTIVATED	User 'abcd@bonbloc.com' activated	/users/8a00286c-b21d-46f7-816f-b9be2a66b62f/status	\N	\N	{"status": "ACTIVE"}	2026-04-21 10:52:52.770257
7fcbd791-d2c2-41ae-97f9-c681b364a100	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	8a00286c-b21d-46f7-816f-b9be2a66b62f	USER_ACTIVATED	Harshith Kanumuri activated User ID 8a00286c-b21d-46f7-816f-b9be2a66b62f.	/api/v1/users/8a00286c-b21d-46f7-816f-b9be2a66b62f/status	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "8a00286c-b21d-46f7-816f-b9be2a66b62f"}}	2026-04-21 10:52:52.770491
64354b0a-e477-4cb3-a197-d3d20082045f	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 10:52:58.080961
e26645c2-ea3e-45f0-b87d-6c11cb3555ea	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 10:55:42.873919
41d5f0d9-ccaa-44cc-bd35-673da11f469a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 10:59:52.491697
d9c84cab-2c84-40c5-85c7-870b28cc16a5	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 11:06:49.556502
916f0747-4174-41d0-ad9f-45b846c72dbc	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 11:11:14.860515
1cba2c06-ebcf-452b-aa28-8975e667894e	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	POST	user	3b243937-e1a4-4e5a-9db8-a92baccd5915	USER_INVITED	User 'saieswarkumar.anupoju@bonbloc.com' invited to organization with role USER	/users/invite	\N	\N	{"role": "USER", "email": "saieswarkumar.anupoju@bonbloc.com", "roleId": "da6ea245-5025-46f4-a718-4e552cc8d8fc"}	2026-04-21 11:11:20.358312
1f7d7a80-2a5e-403e-9534-9c5fd7271912	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	users	3b243937-e1a4-4e5a-9db8-a92baccd5915	USERS_CREATED	Harshith Kanumuri created/invited saieswarkumar.anupoju@bonbloc.com.	/api/v1/users/invite	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-21 11:11:20.359138
6bb15137-8539-4a6e-b058-6798c183d2fb	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 11:59:51.225847
8bd87df4-4ff3-492d-9045-01def02e8631	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	\N	CHAT_CREATED	Harshith Kanumuri created chat unknown.	/api/v1/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-21 12:00:02.599312
f279cc4d-1d26-4fc6-8da7-cb6f3b96dcb7	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 14:23:47.70906
d5f7977c-d9b0-4787-bbcd-15fd7cccbaac	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	a14309c0-0845-4c76-a10b-c35ffaffeba7	CHAT_CREATED	Harshith Kanumuri created chat a14309c0-0845-4c76-a10b-c35ffaffeba7.	/api/v1/chat/sessions/a14309c0-0845-4c76-a10b-c35ffaffeba7/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "a14309c0-0845-4c76-a10b-c35ffaffeba7"}}	2026-04-21 12:00:05.509543
2ffc13c2-785f-4955-b6f3-792f9e7be13d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	a14309c0-0845-4c76-a10b-c35ffaffeba7	CHAT_CREATED	Harshith Kanumuri created chat a14309c0-0845-4c76-a10b-c35ffaffeba7.	/api/v1/chat/sessions/a14309c0-0845-4c76-a10b-c35ffaffeba7/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"sessionId": "a14309c0-0845-4c76-a10b-c35ffaffeba7"}}	2026-04-21 12:00:16.391075
0d322c27-0184-42cb-8851-55d957246074	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:04:49.101226
48da3ac3-aa0f-4dab-b2f3-833d249ce095	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_OUT	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged out	/auth/logout	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:08:55.151684
6edf7833-3c30-4893-9c37-13d1e65eba20	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:11:54.292046
a2f19b90-cf3b-4c17-8d9b-740e75bb26a5	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:20:08.78979
959ad0ce-84b4-4fe4-988d-0378afe7834d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:20:57.967016
9355d113-c24e-414d-b58c-eeb957c94f43	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:22:05.196795
487a4332-84d3-4c17-8263-9f2ad98a1ab2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:22:34.303082
7a9ede45-bed2-4eb3-b149-8ba3f063f3d9	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:22:57.438409
d4191154-1870-40ee-be4d-d0e93b4a5654	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:24:02.685566
8b85ed91-8651-479b-8918-7ca701b76dc7	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:27:02.325589
32857c4f-e2a5-4552-9bef-f49aafe344f8	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:32:28.434674
69e0fb4a-283e-493a-a453-4e34a7aa7048	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:32:49.832027
ad8b3557-92e8-404b-b8d8-68d2c4564cb6	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 12:33:21.438319
f9fa97b7-b41f-48d6-811e-c13d5c9c06bb	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 14:05:04.158803
6946b2c9-8899-4c28-ac3b-6bd4efe37f55	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 14:08:37.791367
96f630fd-db61-47f1-abbb-2a001d24185e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 14:09:35.647104
9a557959-369d-4c35-bfe8-d3122416bae3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 14:11:23.121054
9b33e7b2-ec25-4c75-badc-59492e90f173	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 14:19:22.427601
cac74b8c-e8be-42d7-9e72-8c85ef7d0c7d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 14:23:03.618601
9b47d8b9-018f-4f6e-81bb-51fe206c02fb	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 14:24:34.958125
1655b1ce-a8cd-4ab3-835d-cd36e3efa1b6	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 14:25:02.538814
24aa33c4-cda8-4d29-a207-dddc020229b2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 16:06:16.036929
45b8402b-da5d-43c2-859b-0c6dce6114d2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_OUT	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged out	/auth/logout	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 16:06:20.721084
17cc092d-28bc-4d8b-97df-38e0ec26428b	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 16:16:35.647478
55ff56c4-63ba-4189-99ab-0c3cf7088423	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 16:17:53.625321
61c8c30c-06cf-4c35-9314-51086d2ef8a4	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 16:44:38.679441
1b841fb2-426f-4a8c-af8d-863c9fc1da84	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 16:44:55.104719
fe513345-530d-4d59-832d-6634853e5bbf	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 16:56:46.793758
62378a0f-e812-43a9-9658-0234b00d5b3e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 16:57:40.324579
352cb380-ac49-4800-8cf9-8df188506e1d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 16:59:14.837109
bb6a3417-142d-4fcb-b10e-002acb715678	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 17:00:02.574517
968e2457-5234-46ca-beb6-6098f189cbd2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 17:01:13.037529
bd573655-174b-47e0-81ac-078baafde6b8	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 17:02:04.572909
8a93ff8a-b9cd-4ef1-b7cd-b4e0e79bea5b	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 17:03:52.589834
cacaace5-27cd-4a08-b54f-4c255533ea84	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 17:22:02.022723
9bc59743-c45e-4851-9a5a-6d29e169c4c0	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	DELETE	business-units	29c2753d-3981-4e1f-baa4-961cd8fddb8e	BUSINESS_UNITS_DELETED	Harshith Kanumuri deleted Business Unit ID 29c2753d-3981-4e1f-baa4-961cd8fddb8e.	/api/v1/business-units/29c2753d-3981-4e1f-baa4-961cd8fddb8e	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "29c2753d-3981-4e1f-baa4-961cd8fddb8e"}}	2026-04-21 17:46:32.808019
70961843-e7b9-434b-b1e1-0537242c4619	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	business-units	4bdd010e-c338-4150-9fd9-e63ace646125	BUSINESS_UNITS_CREATED	Harshith Kanumuri created Business Unit ID 4bdd010e-c338-4150-9fd9-e63ace646125.	/api/v1/business-units	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-21 17:46:56.320145
0d61ef50-fc53-4ca3-8596-936383280327	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	business-units	23cedb72-5ebd-4e7f-9c03-e881bb413628	BUSINESS_UNITS_CREATED	Harshith Kanumuri created Business Unit ID 23cedb72-5ebd-4e7f-9c03-e881bb413628.	/api/v1/business-units	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-21 17:47:21.196615
f983e364-19c4-4632-9664-96115f7d8f3e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	DELETE	business-units	23cedb72-5ebd-4e7f-9c03-e881bb413628	BUSINESS_UNITS_DELETED	Harshith Kanumuri deleted Business Unit ID 23cedb72-5ebd-4e7f-9c03-e881bb413628.	/api/v1/business-units/23cedb72-5ebd-4e7f-9c03-e881bb413628	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "23cedb72-5ebd-4e7f-9c03-e881bb413628"}}	2026-04-21 17:48:50.538496
0418dca4-c43d-4d86-a50d-0cd6e4d0c7f2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	DELETE	business-units	4bdd010e-c338-4150-9fd9-e63ace646125	BUSINESS_UNITS_DELETED	Harshith Kanumuri deleted Business Unit ID 4bdd010e-c338-4150-9fd9-e63ace646125.	/api/v1/business-units/4bdd010e-c338-4150-9fd9-e63ace646125	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "4bdd010e-c338-4150-9fd9-e63ace646125"}}	2026-04-21 17:48:53.817407
9534d1e6-b5b1-4d6b-9268-d09d538dea39	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	leadership	b55795af-72bd-4147-9e4a-996b7641116b	LEADERSHIP_CREATED	Harshith Kanumuri created leadership b55795af-72bd-4147-9e4a-996b7641116b.	/api/v1/leadership	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-21 18:09:22.575275
0122b0ef-774d-48dd-9dc4-7592654a8808	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-21 18:17:56.598234
b9ae7aab-b082-4fb7-9ee3-32b5fdb68fdd	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:15:54.642296
3cf1fd71-41f1-4ce8-aafd-b08e3c13f3cc	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:22:28.16509
f742cb38-777e-4048-be1a-e1f95572a306	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:28:09.096456
ab8cbf34-f4b0-4b21-b5d2-0a93be14f9d3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:30:24.620958
99cea23c-86ee-4a5d-ac71-6bedd15e119d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:31:17.18289
5c3400da-7117-4dd8-9327-4c9159d06f38	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6.	/api/v1/access-control/roles/id/c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6"}}	2026-04-22 10:31:50.289023
83973cfc-a0fb-4582-8b2a-9742da9de48e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:32:02.42112
adf215a8-9edf-46f5-97de-9062fbc0eaed	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:36:50.909731
ddab0f14-130c-4c05-b844-9f795ff47244	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	da6ea245-5025-46f4-a718-4e552cc8d8fc	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID da6ea245-5025-46f4-a718-4e552cc8d8fc.	/api/v1/access-control/roles/id/da6ea245-5025-46f4-a718-4e552cc8d8fc/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "da6ea245-5025-46f4-a718-4e552cc8d8fc"}}	2026-04-22 10:37:38.520326
d87233e6-01e2-4478-bf16-0cae3a362bbf	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:39:17.29611
ca41c530-0921-455c-bdba-3b9be0b8120a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6.	/api/v1/access-control/roles/id/c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6"}}	2026-04-22 10:39:34.216279
da54f982-67d5-4e17-9e2d-38f87cae89b0	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:39:48.485126
6f6dabb7-75e9-4602-8b20-aee624805e19	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:41:04.47344
b8525267-c181-4c14-96e9-fb0ff3e7dbf9	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:42:45.515255
192ea15f-09b6-4d12-83d0-fd6461518362	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6.	/api/v1/access-control/roles/id/c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6/permissions	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6"}}	2026-04-22 10:43:30.730342
bfb76f77-87ba-471d-82be-778c466f95cc	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:43:55.296463
a7d79b2f-bc00-404a-8d8e-ddfc060fb2a8	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:47:45.223485
3256dd2d-b952-4163-acf7-72162cbb1948	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:50:04.280208
9e8b5647-f8a6-4a64-9319-130f625981f6	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:50:11.528097
ca4bb19e-41f4-4785-9463-4e79e08dd5d0	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:51:16.473751
30c8c710-72b5-4770-a83b-e17c610ca8fa	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:56:15.617554
174d6699-59cf-4aff-9514-f147b17de53e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:57:22.132303
87a32e96-4770-466e-85c1-16104fc802b3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6.	/api/v1/access-control/roles/id/c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6"}}	2026-04-22 10:57:40.460432
d0088b1a-eee1-4526-8397-ce4585996326	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 10:58:17.588991
13769b88-4c3e-4557-ab28-f67f0e50864a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_OUT	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged out	/auth/logout	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 11:02:00.419869
3a216aa1-8a61-4c12-913d-a463a1968313	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-22 11:02:05.821475
a0a8ab73-87e6-4ba3-b7a3-33cfa9fa7056	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:23:21.119394
eb902861-ad66-414f-a08f-f6e450eacad8	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6.	/api/v1/access-control/roles/id/c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6"}}	2026-04-23 10:26:10.223381
ac282fc7-31ac-4135-a581-91f274d25c3d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:27:04.864848
3f119f09-7c10-4718-8eea-c3fc62e30558	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:36:21.515031
3ce95dfc-a9b0-44d5-916d-457a3e0af039	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:36:51.782928
38c07da2-a96f-4335-adf4-a9a0890a3e57	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:36:56.67858
fbb529aa-a16c-456a-b140-1ee4bd4fb536	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:37:12.188789
1876eaa3-9dbb-46fd-8516-52acb1510fd2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:43:54.428735
95e7970a-0080-408a-8393-572add59ae04	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:45:43.273773
3060c193-f54c-48f3-b5ed-9f12f5242d07	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:47:22.494146
62a89c07-50a3-4151-9f67-2348fd02243c	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:52:49.562468
2b1c1ac0-28e6-432c-9252-2bf434dbcb3a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PUT	access-control	c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6	ACCESS_CONTROL_UPDATED	Harshith Kanumuri updated Access Control ID c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6.	/api/v1/access-control/roles/id/c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6/permissions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"roleId": "c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6"}}	2026-04-23 10:53:04.871323
5837ef7c-daa6-43be-9b6f-4f67fb3fc656	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:53:16.237465
7c840204-1b51-44d5-adf5-5a3fba36ba99	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 10:53:41.156766
f84a61ad-2eef-41e7-ae31-f03b29e2abcb	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 11:01:54.44772
de658540-e095-4872-8003-97e3c1ba44b3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 11:02:17.14914
3d352325-ebb1-4ae3-a1de-8580da51fafa	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 11:06:52.443845
904fa5f3-8371-47a0-9516-3d89f9bef9a9	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 11:07:36.62015
3431af95-3926-46ee-950d-45b67ee51465	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 11:10:29.236306
94cf0543-a505-4da6-a411-8ccb3f6cbf6c	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	b55795af-72bd-4147-9e4a-996b7641116b	USERS_UPDATED	Harshith Kanumuri updated profile details for Test.	/api/v1/users/b55795af-72bd-4147-9e4a-996b7641116b	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "b55795af-72bd-4147-9e4a-996b7641116b"}}	2026-04-23 11:10:39.093459
149533b8-b8cd-4aac-9117-bbc1887b1a23	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	user	b55795af-72bd-4147-9e4a-996b7641116b	USER_ROLE_UPDATED	User 'test@gmail.com' role changed to BA	/users/b55795af-72bd-4147-9e4a-996b7641116b/role	\N	\N	{"newRole": "BA", "newRoleId": "b3fcf94a-40cd-4a56-be8e-c92f44e427ca"}	2026-04-23 11:10:39.233216
40c6431c-5a09-4d2c-9f6c-69fb8242a983	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	b55795af-72bd-4147-9e4a-996b7641116b	USER_ROLE_UPDATED	Harshith Kanumuri changed role for User ID b55795af-72bd-4147-9e4a-996b7641116b to BA.	/api/v1/users/b55795af-72bd-4147-9e4a-996b7641116b/role	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "b55795af-72bd-4147-9e4a-996b7641116b"}}	2026-04-23 11:10:39.2336
038a0d83-3152-4204-af7c-3249c05c2f00	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 11:14:45.236096
cbaf0f40-5b19-4a11-b922-c3a1558c7ce3	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 11:19:14.277446
0053c377-9926-42dc-8e9a-6b9bedde14bf	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 11:19:44.267983
50199d1b-1d22-4a55-8fb3-2f82552e4994	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 13:53:23.266124
0d1e420c-53c4-4883-a01a-e8bd8f11d403	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 13:55:23.963288
c4b62a67-a33f-41bf-9aaa-02d554dc895b	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	POST	user	838291f9-7c9c-4199-a522-0095b61d0f7a	USER_INVITED	User 'ramcharan.kondareddy@bonbloc.com' invited to organization with role USER	/users/invite	\N	\N	{"role": "USER", "email": "ramcharan.kondareddy@bonbloc.com", "roleId": "da6ea245-5025-46f4-a718-4e552cc8d8fc"}	2026-04-23 14:16:29.71315
6fed1295-22cd-460f-8199-f63c8e8b6466	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	POST	user	b14cedda-e3e3-48ea-9b5f-a2ec5c826243	USER_INVITED	User 'pavankumar.pattipu@bonbloc.com' invited to organization with role USER	/users/invite	\N	\N	{"role": "USER", "email": "pavankumar.pattipu@bonbloc.com", "roleId": "da6ea245-5025-46f4-a718-4e552cc8d8fc"}	2026-04-23 14:16:29.739711
990842aa-5e30-4fe6-9a53-9a94dbc29d74	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	users	\N	USERS_CREATED	Harshith Kanumuri created/invited User ID unknown user.	/api/v1/users/invite/bulk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-23 14:16:29.749558
de00c401-1c3b-4396-a1ea-f706138c0725	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	POST	user	d5aaf52f-6b61-44b5-af88-75d3fd4b583f	USER_INVITED	User 'subrahmanyam.kodavatiganti@bonbloc.com' invited to organization with role USER	/users/invite	\N	\N	{"role": "USER", "email": "subrahmanyam.kodavatiganti@bonbloc.com", "roleId": "da6ea245-5025-46f4-a718-4e552cc8d8fc"}	2026-04-23 14:16:29.741621
98065794-b24b-4616-a8e9-0e29931ec50e	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	POST	user	0f2a9e2e-2291-4aa2-8f32-aa9806e20fed	USER_INVITED	User 'meenuprudhvija.immaneni@bonbloc.com' invited to organization with role USER	/users/invite	\N	\N	{"role": "USER", "email": "meenuprudhvija.immaneni@bonbloc.com", "roleId": "da6ea245-5025-46f4-a718-4e552cc8d8fc"}	2026-04-23 14:16:29.772598
06b6db87-e6a0-4da4-a56c-f5ddaedee01f	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_OUT	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged out	/auth/logout	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 14:17:26.989282
c1a2718f-25cc-474e-b532-360eabf45403	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 14:17:31.854893
7bc66819-faba-49e4-bf76-c28356a70c74	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	business-units	b47cb6ff-4731-4a96-8e73-617bbd7b50f7	BUSINESS_UNITS_CREATED	Harshith Kanumuri created Business Unit ID b47cb6ff-4731-4a96-8e73-617bbd7b50f7.	/api/v1/business-units	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-23 14:18:09.920419
e70f1b62-20c4-43ed-8cbe-3d77b56f9ba2	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	POST	project	a0be3ee4-a3b1-4e66-871f-8db5f9db1163	PROJECT_CREATED	Project 'Utility Network' (UNPS321) created	/projects	\N	\N	{}	2026-04-23 14:21:13.997288
ec73a4d5-bd49-4636-8309-60ad2f0bf3f4	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	projects	a0be3ee4-a3b1-4e66-871f-8db5f9db1163	PROJECTS_CREATED	Harshith Kanumuri created Project ID a0be3ee4-a3b1-4e66-871f-8db5f9db1163.	/api/v1/projects	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-23 14:21:14.053435
e41c7d07-c5db-4f78-aaa2-36952f776933	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 14:38:23.142106
470a93bf-b272-4ea2-9481-7f9117611f3a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_OUT	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged out	/auth/logout	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 14:38:39.469336
5d8f4378-fe8e-439b-872c-e2839c9a38ef	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 14:38:46.962283
dc7e268f-647c-449c-b09a-74dc80001b44	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	tasks	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_STATUS_UPDATED	Harshith Kanumuri changed status of Task ID 15f999f2-dd27-4857-bb4d-ad75aa7d5ff5 to QA.	/api/v1/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/status	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "15f999f2-dd27-4857-bb4d-ad75aa7d5ff5"}}	2026-04-23 14:55:20.517994
026d3637-8e3b-4638-8cda-36e7310ca9ea	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	task	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_STATUS_UPDATED	Task 'Tenant Configuration' (PROJ-1237-8) status changed to QA	/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/status	\N	\N	{"status": "QA"}	2026-04-23 14:55:20.561885
119858c2-161f-46d3-b653-59176ce209d1	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	tasks	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_STATUS_UPDATED	Harshith Kanumuri changed status of Task ID 15f999f2-dd27-4857-bb4d-ad75aa7d5ff5 to BLOCKED.	/api/v1/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/status	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "15f999f2-dd27-4857-bb4d-ad75aa7d5ff5"}}	2026-04-23 14:56:21.960705
329e6f56-a9f3-4d63-a78d-e171882a4b9e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	task	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_STATUS_UPDATED	Task 'Tenant Configuration' (PROJ-1237-8) status changed to BLOCKED	/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/status	\N	\N	{"status": "BLOCKED"}	2026-04-23 14:56:22.00318
106222f3-5b1e-46d8-bf1c-d4973b9aa531	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	\N	\N	PATCH	task	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_STATUS_UPDATED	Task 'Tenant Configuration' (PROJ-1237-8) status changed to DONE	/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/status	\N	\N	{"status": "DONE"}	2026-04-23 14:56:26.679446
015aaf1c-f306-47a2-afbf-7c6fdf9aab3b	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	tasks	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_STATUS_UPDATED	Harshith Kanumuri changed status of Task ID 15f999f2-dd27-4857-bb4d-ad75aa7d5ff5 to DONE.	/api/v1/tasks/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/status	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "15f999f2-dd27-4857-bb4d-ad75aa7d5ff5"}}	2026-04-23 14:56:26.715645
88e9c678-581e-4ece-89d2-ff3b33e79bab	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	notifications	8d0b2cd1-3ea5-4be2-8c84-88d56dcf45fe	NOTIFICATIONS_UPDATED	Harshith Kanumuri updated Notification ID 8d0b2cd1-3ea5-4be2-8c84-88d56dcf45fe.	/api/v1/notifications/8d0b2cd1-3ea5-4be2-8c84-88d56dcf45fe/read	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "8d0b2cd1-3ea5-4be2-8c84-88d56dcf45fe"}}	2026-04-23 14:56:32.669545
01d72f28-64d1-46c2-9b21-2116d059e0bb	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	users	\N	USERS_CREATED	Harshith Kanumuri created/invited User ID unknown user.	/api/v1/users/invite/bulk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-23 15:35:03.623664
1d92e3f0-37bc-43d5-82ae-9e3a52cfd68d	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	users	\N	USERS_CREATED	Harshith Kanumuri created/invited User ID unknown user.	/api/v1/users/invite/bulk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-23 15:35:43.910223
3ba8047f-9933-4a39-83c4-689c241c8565	1d105d8b-95d8-411e-9844-b6683e8b7f51	\N	\N	\N	POST	user	c9fe58c6-d0f4-4722-b1ba-ca752c3c321c	USER_INVITED	User 'komali.avirneni@bonblac.com' invited to organization with role USER	/users/invite	\N	\N	{"role": "USER", "email": "komali.avirneni@bonblac.com", "roleId": "da6ea245-5025-46f4-a718-4e552cc8d8fc"}	2026-04-23 15:36:59.187479
18decf9e-c28a-4257-8013-38d904dde8f9	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	users	\N	USERS_CREATED	Harshith Kanumuri created/invited User ID unknown user.	/api/v1/users/invite/bulk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {}}	2026-04-23 15:36:59.270702
e510ef54-2851-4f27-b22b-b5047608d266	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 15:38:51.452047
f1075f33-045c-4c98-a920-befe7176ba23	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 15:40:52.561512
8c1794e7-9435-4e29-ba8d-71b666103635	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 16:45:48.619571
bd1b1528-3850-4706-a552-24258aca891c	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{}	2026-04-23 16:46:43.145842
b5c1524c-dd8d-4bb0-aa0f-ef3132800cb6	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	projects	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	PROJECT_TEAM_ADDED	Harshith Kanumuri added a team member to Project ID 10ac6760-95d0-4f5d-acb5-52126ff0c7e1.	/api/v1/projects/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/team	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "10ac6760-95d0-4f5d-acb5-52126ff0c7e1"}}	2026-04-23 16:50:43.742593
3a42f0e9-228f-469e-8f18-364b873ad304	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	projects	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	PROJECT_TEAM_ADDED	Harshith Kanumuri added a team member to Project ID 10ac6760-95d0-4f5d-acb5-52126ff0c7e1.	/api/v1/projects/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/team/8dda0ff5-4e29-4034-b7e3-a7481e98c4de/approve-bandwidth	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	{"params": {"id": "10ac6760-95d0-4f5d-acb5-52126ff0c7e1", "mappingId": "8dda0ff5-4e29-4034-b7e3-a7481e98c4de"}}	2026-04-23 16:50:54.236492
a84f05af-dd4a-4005-b741-d0843ba75fbe	23614f2d-0da4-481c-9cb7-8c7b620f1957	7806c99a-9a84-4994-8297-1114ac35d72c	PMS Admin	admin.pms@gmail.com	POST	auth	\N	USER_LOGGED_IN	PMS Admin (admin.pms@gmail.com) logged in	/auth/record-login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36	{}	2026-10-06 13:10:52.95547
\.


--
-- TOC entry 5326 (class 0 OID 49192)
-- Dependencies: 221
-- Data for Name: app_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_user (id, org_id, email, name, role, designation, is_leader, is_manager, status, created_at, role_id, password_hash, password_setup_token_hash, password_setup_expires_at) FROM stdin;
b55795af-72bd-4147-9e4a-996b7641116b	1d105d8b-95d8-411e-9844-b6683e8b7f51	test@gmail.com	Test	BA	\N	t	t	ACTIVE	2026-04-21 18:09:22.530887	b3fcf94a-40cd-4a56-be8e-c92f44e427ca	\N	\N	\N
b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	developer1@acme.com	Alice	USER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	developer2@acme.com	Bob	USER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	qa@acme.com	Charlie	USER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
65b2f9f4-a049-4766-b6f6-4ecca8fb8de7	1d105d8b-95d8-411e-9844-b6683e8b7f51	santhosh.sankar@bonbloc.com	Santhosh	USER	\N	f	f	ACTIVE	2026-03-19 17:57:36.529875	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
838291f9-7c9c-4199-a522-0095b61d0f7a	1d105d8b-95d8-411e-9844-b6683e8b7f51	ramcharan.kondareddy@bonbloc.com	Ramcharan Kondareddy	USER	\N	f	f	ACTIVE	2026-04-23 14:16:29.617239	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
d5aaf52f-6b61-44b5-af88-75d3fd4b583f	1d105d8b-95d8-411e-9844-b6683e8b7f51	subrahmanyam.kodavatiganti@bonbloc.com	Subrahmanyam Kodavatiganti	USER	\N	f	f	ACTIVE	2026-04-23 14:16:29.663181	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
fbfbe066-9918-412c-835d-f92a30ac44e4	1d105d8b-95d8-411e-9844-b6683e8b7f51	narayanareddy.mallidi@bonbloc.com	Narayana Reddy Mallidi	ORG_ADMIN	DEV	t	t	ACTIVE	2026-03-27 10:02:54.511576	044f1cc6-660e-4d3c-a369-ccbde5e25a02	\N	\N	\N
8710daee-65e4-4ffb-96d7-d19a6fccc3a8	1d105d8b-95d8-411e-9844-b6683e8b7f51	rahul.ravi@bonbloc.com	Rahul Ravi	USER	\N	f	f	ACTIVE	2026-04-02 06:20:52.533434	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
9f249425-c274-4eaa-b142-108b074503bd	1d105d8b-95d8-411e-9844-b6683e8b7f51	veluprasath.durai@bonbloc.com	Velu Prasath Durai	USER	\N	f	f	ACTIVE	2026-04-02 06:30:26.711782	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
47a94aa7-e849-40f1-9602-f08b894bdc5b	1d105d8b-95d8-411e-9844-b6683e8b7f51	krishnapranathi.dande@bonbloc.com	Krishna Pranathi Dande	USER	\N	f	f	ACTIVE	2026-04-02 06:55:21.209343	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
01a59c21-81cf-4931-9986-66a01a4f77d1	1d105d8b-95d8-411e-9844-b6683e8b7f51	sriram.pupathy@bonbloc.com	Sriram Pupathy	USER	\N	f	f	ACTIVE	2026-04-02 07:13:04.386918	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
701adbb8-edd0-409a-a040-d20f70d60edd	1d105d8b-95d8-411e-9844-b6683e8b7f51	manikiran.chegondi@bonbloc.com	Mani Kiran Chegondi	ORG_ADMIN	\N	f	f	ACTIVE	2026-04-01 15:45:05.032557	044f1cc6-660e-4d3c-a369-ccbde5e25a02	\N	\N	\N
26e46ea9-fd64-466f-ae5c-235c2b75727f	1d105d8b-95d8-411e-9844-b6683e8b7f51	dharani.mattakapu@bonbloc.com	Dharani Mattakapu	USER	\N	f	f	ACTIVE	2026-04-23 14:16:29.681542	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
0f2a9e2e-2291-4aa2-8f32-aa9806e20fed	1d105d8b-95d8-411e-9844-b6683e8b7f51	meenuprudhvija.immaneni@bonbloc.com	Meenuprudhvija Immaneni	USER	\N	f	f	ACTIVE	2026-04-23 14:16:29.705338	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
b14cedda-e3e3-48ea-9b5f-a2ec5c826243	1d105d8b-95d8-411e-9844-b6683e8b7f51	pavankumar.pattipu@bonbloc.com	Pavankumar Pattipu	USER	\N	f	f	ACTIVE	2026-04-23 14:16:29.729762	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
c9fe58c6-d0f4-4722-b1ba-ca752c3c321c	1d105d8b-95d8-411e-9844-b6683e8b7f51	komali.avirneni@bonblac.com	Komali Avirneni	USER	\N	f	f	ACTIVE	2026-04-23 15:36:59.154471	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
1400ccae-fcaa-452d-9d61-30afb052b604	1d105d8b-95d8-411e-9844-b6683e8b7f51	komali.avirneni@bonbloc.com	Komali Avirneni	USER	\N	f	f	ACTIVE	2026-04-01 11:45:59.188686	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
08eb8d8d-46cf-4c92-a210-2d09cf7a550f	1d105d8b-95d8-411e-9844-b6683e8b7f51	durai.appadurai@bonbloc.com	Durai Appadurai	ORG_ADMIN	\N	f	f	ACTIVE	2026-04-03 07:11:04.719542	044f1cc6-660e-4d3c-a369-ccbde5e25a02	\N	\N	\N
edb1541e-efee-435d-a4cd-6e7da392464a	1d105d8b-95d8-411e-9844-b6683e8b7f51	harshith.kanumuri@bonbloc.com	Harshith Kanumuri	ORG_ADMIN	DEV	t	t	ACTIVE	2026-03-26 22:48:28.989947	044f1cc6-660e-4d3c-a369-ccbde5e25a02	\N	\N	\N
0b6ad5c0-f1b4-4865-8643-634eedf36d60	1d105d8b-95d8-411e-9844-b6683e8b7f51	sairam.mathi@bonbloc.com	Sairam Mathi	ORG_ADMIN	\N	f	f	ACTIVE	2026-04-03 07:12:13.073759	044f1cc6-660e-4d3c-a369-ccbde5e25a02	\N	\N	\N
55d1bcf6-7a5f-4cf5-8c49-ab0051846bfa	1d105d8b-95d8-411e-9844-b6683e8b7f51	swaminathan.rajagopalan@bonbloc.com	Swaminathan Rajagopalan	ORG_ADMIN	\N	f	f	ACTIVE	2026-04-10 16:52:59.283057	044f1cc6-660e-4d3c-a369-ccbde5e25a02	\N	\N	\N
2e745634-fcc5-46db-9651-a6cfe30aa537	1d105d8b-95d8-411e-9844-b6683e8b7f51	ganthikugan.jaipal@bonbloc.com	Ganthikugan Jaipal	MANAGER	\N	f	f	ACTIVE	2026-04-10 16:48:35.336614	c4d1b86c-c54e-4724-805e-c1326bb968f0	\N	\N	\N
3b243937-e1a4-4e5a-9db8-a92baccd5915	1d105d8b-95d8-411e-9844-b6683e8b7f51	saieswarkumar.anupoju@bonbloc.com	Saieswarkumar Anupoju	USER	\N	f	f	ACTIVE	2026-04-21 11:11:20.281467	da6ea245-5025-46f4-a718-4e552cc8d8fc	\N	\N	\N
b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	alicia.antony@bonbloc.com	Alicia Antony	MANAGER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231	044f1cc6-660e-4d3c-a369-ccbde5e25a02	\N	\N	\N
b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	manager@acme.com	Jane	MANAGER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231	044f1cc6-660e-4d3c-a369-ccbde5e25a02	\N	\N	\N
b762cce3-dac1-4aa0-bc38-a8488eaf994f	1d105d8b-95d8-411e-9844-b6683e8b7f51	princy.joseph@bonbloc.com	princy	MANAGER	\N	f	f	ACTIVE	2026-03-19 14:23:34.808615	044f1cc6-660e-4d3c-a369-ccbde5e25a02	\N	\N	\N
7806c99a-9a84-4994-8297-1114ac35d72c	23614f2d-0da4-481c-9cb7-8c7b620f1957	admin.pms@gmail.com	PMS Admin	ORG_ADMIN	\N	f	f	ACTIVE	2026-10-06 13:09:49.260931	044f1cc6-660e-4d3c-a369-ccbde5e25a02	scrypt$7815ec5f8e25d6c5db1fa64c8e7b113a$a1bd7882de1d5cd5560258d93752e10cd8614162d770b5f138ccce8bbcc11c64b98e5a9b341a597e7c29e677bcf649ac67ce6c104128d6f652acde7d5c4b100a	\N	\N
\.


--
-- TOC entry 5327 (class 0 OID 49207)
-- Dependencies: 222
-- Data for Name: attachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attachment (id, org_id, task_id, file_name, file_type, file_size, s3_key, uploaded_by, status, created_at) FROM stdin;
0b432db8-80e5-4f85-a370-609448813852	1d105d8b-95d8-411e-9844-b6683e8b7f51	86d4af01-800a-435d-ac7c-d4594c1f495b	Screenshot 2026-03-28 135646.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/86d4af01-800a-435d-ac7c-d4594c1f495b/83071b02-a25f-4221-bd47-b11516a8e4da.png	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-28 14:11:59.09885
90bc8b6e-5c99-4d10-abdc-c9e330aa7f0d	1d105d8b-95d8-411e-9844-b6683e8b7f51	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	Screenshot 2026-03-28 135646.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/c5b77141-3868-4b1b-849a-e9ffd1e5b4a4/4ef832b5-7d99-4620-93fc-3ea3e7329368.png	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-04-07 05:01:24.509587
3928966c-bec6-4df6-9856-58e0028e1d93	1d105d8b-95d8-411e-9844-b6683e8b7f51	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	Screenshot 2025-08-28 144154.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/c5b77141-3868-4b1b-849a-e9ffd1e5b4a4/c185d150-10cd-4f87-a169-78070c276455.png	1400ccae-fcaa-452d-9d61-30afb052b604	ACTIVE	2026-04-07 08:51:39.529558
046b0fa3-84f0-44b9-b076-69a77647f42e	1d105d8b-95d8-411e-9844-b6683e8b7f51	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	Screenshot 2026-03-30 144447.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/15f999f2-dd27-4857-bb4d-ad75aa7d5ff5/6b89b8e1-6e36-4a38-8f23-9ceae0d3546c.png	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-04-20 22:56:05.191973
\.


--
-- TOC entry 5328 (class 0 OID 49220)
-- Dependencies: 223
-- Data for Name: business_unit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.business_unit (id, org_id, name, status, owner_id, created_at) FROM stdin;
2e3a99b6-18d5-4963-a961-7709a16fb343	1d105d8b-95d8-411e-9844-b6683e8b7f51	Public Sector	ACTIVE	0b6ad5c0-f1b4-4865-8643-634eedf36d60	2026-04-20 23:31:39.987482
4bdd010e-c338-4150-9fd9-e63ace646125	1d105d8b-95d8-411e-9844-b6683e8b7f51	Sales	INACTIVE	1400ccae-fcaa-452d-9d61-30afb052b604	2026-04-21 17:46:56.255026
b47cb6ff-4731-4a96-8e73-617bbd7b50f7	1d105d8b-95d8-411e-9844-b6683e8b7f51	Private Sector	ACTIVE	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-04-23 14:18:09.88905
\.


--
-- TOC entry 5329 (class 0 OID 49230)
-- Dependencies: 224
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
75232e1c-8fd7-47aa-96ed-bee7e3c97a6d	4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59	user	who many user are there	2026-04-21 09:53:34.706407
4ee3e112-c4b2-4726-9282-256eecd62ce7	4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59	assistant	There are 30 users in the list.	2026-04-21 09:53:34.706407
e96a1d36-57da-429e-b839-1ea8feb109bd	4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59	user	how many leader are there	2026-04-21 09:53:54.206104
6115fba7-8d86-445f-9aed-25c49f45c09a	4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59	assistant	There are 4 leaders in the leadership team.	2026-04-21 09:53:54.206104
b7df05c7-37e7-444c-90da-4b8c237cbde6	1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	user	how many leader are there	2026-04-21 09:54:57.529751
6366dabb-827d-4c6e-8f67-3789b0d580c4	1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	assistant	Harshith, you do not have access to information about the number of leaders.	2026-04-21 09:54:57.529751
ff88b00f-631a-4ac0-85dc-e8d597a28abc	1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	user	how many users are there	2026-04-21 09:55:12.728605
733c33ed-a309-4de1-9288-50bb177e1f13	1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	assistant	Harshith, there are no active users found in the system.	2026-04-21 09:55:12.728605
0c3c96c7-72a8-4908-9719-c5679fefbcf9	1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	user	how many tasks do i have	2026-04-21 09:55:36.898648
58c74381-fb51-4dfd-9df1-3e33e1f7d829	1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	assistant	Harshith, you have three assigned tasks:\n\n1. Registration Page - IN_REVIEW, Medium priority, deadline: 2026-03-31\n2. R&D Animation for login page - IN_PROGRESS, High priority, deadline: 2026-03-31\n3. Tenant Configuration - IN_PROGRESS, Medium priority, deadline: 2026-04-25	2026-04-21 09:55:36.898648
5b3d147d-62e0-45fe-8844-0f4f1f22ad3a	2559dd2c-acb2-4b77-bce9-9410ccc95632	user	what are my tasks	2026-04-21 10:38:10.870211
76987576-7b37-47ad-a53f-266abbe28552	2559dd2c-acb2-4b77-bce9-9410ccc95632	assistant	Harshith, here are your assigned tasks:\n\n- Registration Page: IN_REVIEW, priority MEDIUM, deadline 2026-03-31\n- R&D Animation for login page: IN_PROGRESS, priority HIGH, deadline 2026-03-31\n- Tenant Configuration: IN_PROGRESS, priority MEDIUM, deadline 2026-04-25	2026-04-21 10:38:10.870211
50f2add7-3df8-4992-a01e-e47997e29362	2559dd2c-acb2-4b77-bce9-9410ccc95632	user	how many user are present in the application	2026-04-21 10:39:26.840528
6dcd9ca3-a53e-4516-b2ec-a269ce603049	2559dd2c-acb2-4b77-bce9-9410ccc95632	assistant	Harshith, you do not have access to information regarding the number of users present in the application.	2026-04-21 10:39:26.840528
616dd43b-fb80-4601-a870-28d865634874	a14309c0-0845-4c76-a10b-c35ffaffeba7	user	what are my tasks this week	2026-04-21 12:00:05.491269
94592a2f-0e54-41b3-b8f9-50ef1ff65219	a14309c0-0845-4c76-a10b-c35ffaffeba7	assistant	Harshith, you have the following tasks assigned:\n\n- R&D Animation for login page (status: IN_PROGRESS, priority: HIGH, deadline: 2026-03-31)\n- Tenant Configuration (status: IN_PROGRESS, priority: MEDIUM, deadline: 2026-04-25)\n\nThe Registration Page is currently in review and does not require immediate action this week.	2026-04-21 12:00:05.491269
\.


--
-- TOC entry 5330 (class 0 OID 49242)
-- Dependencies: 225
-- Data for Name: chat_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_session (id, org_id, user_id, title, started_at, ended_at) FROM stdin;
504dc540-f8df-4cd9-a10b-853cae1c67da	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	New conversation	2026-04-20 14:30:50.421256	2026-04-20 14:30:59.406+05:30
673e875b-2728-49ba-8073-51da72ea24cf	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	New conversation	2026-04-20 14:31:08.137283	2026-04-20 14:37:28.338+05:30
341a36d2-6826-4a85-8938-c155e7094f2c	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	New conversation	2026-04-20 14:39:36.073908	2026-04-20 14:39:50.015+05:30
26000b9d-19c7-467d-a87e-a66242d8bbaa	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	New conversation	2026-04-20 14:45:56.175672	2026-04-20 14:46:05.635+05:30
90584828-75d3-4716-810d-65fa5603e5cf	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	hii	2026-04-20 14:52:43.973409	2026-04-20 14:52:48.604+05:30
7e92e8ba-d2fd-4f0b-960a-d02268f2c76f	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	hi	2026-04-20 15:09:37.31353	2026-04-20 15:19:55.012+05:30
4b6a8232-eaf7-47e0-90d0-c8f57b7c4f59	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	who many user are there	2026-04-21 09:53:33.254853	2026-04-21 09:53:58.286+05:30
1f8c4299-ba1b-47d4-9a27-5caeae69b7ce	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	how many leader are there	2026-04-21 09:54:56.10424	2026-04-21 09:57:06.276+05:30
2559dd2c-acb2-4b77-bce9-9410ccc95632	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	what are my tasks	2026-04-21 10:38:07.826772	2026-04-21 10:39:41.573+05:30
a14309c0-0845-4c76-a10b-c35ffaffeba7	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	what are my tasks this week	2026-04-21 12:00:02.577184	2026-04-21 12:00:16.264+05:30
\.


--
-- TOC entry 5331 (class 0 OID 49253)
-- Dependencies: 226
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, recipient_id, task_id, type, title, message, metadata, is_read, created_at, updated_at) FROM stdin;
bb8e9457-0703-427b-a004-48a44e36b1d0	edb1541e-efee-435d-a4cd-6e7da392464a	c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	TASK_BLOCKED	Task Blocked	Task "R&D Animation for login page" has been blocked by Harshith Kanumuri	{"blockedBy":"edb1541e-efee-435d-a4cd-6e7da392464a","taskCode":"PROJ-1237-3","taskTitle":"R&D Animation for login page","blockerName":"Harshith Kanumuri"}	t	2026-04-20 23:41:27.941161	2026-04-20 23:41:37.912986
8d0b2cd1-3ea5-4be2-8c84-88d56dcf45fe	edb1541e-efee-435d-a4cd-6e7da392464a	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	TASK_BLOCKED	Task Blocked	Task "Tenant Configuration" has been blocked by Harshith Kanumuri	{"blockedBy":"edb1541e-efee-435d-a4cd-6e7da392464a","taskCode":"PROJ-1237-8","taskTitle":"Tenant Configuration","blockerName":"Harshith Kanumuri"}	t	2026-04-23 14:56:21.838788	2026-04-23 14:56:32.647673
\.


--
-- TOC entry 5332 (class 0 OID 49271)
-- Dependencies: 227
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization (id, name, azure_tenant_id, status, created_at) FROM stdin;
1d105d8b-95d8-411e-9844-b6683e8b7f51	BONbLOC Technologies	7915d0a8-0a13-4824-ba52-43a1ad694c42	ACTIVE	2026-03-19 14:23:34.808615
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Acme Corporation	null	ACTIVE	2026-03-18 20:14:20.339403
23614f2d-0da4-481c-9cb7-8c7b620f1957	Tech ECS	\N	ACTIVE	2026-10-06 13:09:49.260931
\.


--
-- TOC entry 5333 (class 0 OID 49281)
-- Dependencies: 228
-- Data for Name: platform_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.platform_user (id, email, name, role, status, created_at) FROM stdin;
d2c3a954-c0f7-4718-92be-e97449206874	oviiyadominic@gmail.com	Oviiya Dominic	ADMIN	ACTIVE	2026-03-19 14:28:31.763376
\.


--
-- TOC entry 5334 (class 0 OID 49292)
-- Dependencies: 229
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project (id, org_id, name, project_code, business_unit, manager_id, status, created_at, finance_code, budget, kickoff_date, start_date, end_date, project_type, client_name, client_location, purpose, cost_management, tech_stack, dependencies, deliverable_type, execution_model, delivery_manager_id, sponsor_id, created_by_id, approved_by_id, priority, risk_level, actual_start_date, actual_end_date, milestone_template, budget_approved, currency, cost_center_id, billing_type, contract_type, revenue, sprint_duration, iteration_start_day, estimation_unit, velocity_tracking, wip_limits, continuous_flow, phase_template, stage_gates, document_repository, client_spoc, contract_start_date, contract_end_date, comments, description, finance_member_id, project_summary) FROM stdin;
c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Mobile App Development	MOB	Engineering	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N
c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Website Redesign	WEB	Marketing	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N
c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	API Integration	API	Engineering	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N
6564025c-356b-4e87-96e6-44360bde99f0	1d105d8b-95d8-411e-9844-b6683e8b7f51	FPO	FPO-101	Onelign Software Applications	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-19 18:10:00.907041	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N
cc556634-367e-4ff9-a331-a000d92c89e3	1d105d8b-95d8-411e-9844-b6683e8b7f51	COld Chain	PROJ-123	Onelign Software Applications	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-19 18:31:10.938558	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N
eeb797e6-385c-4376-a607-9663e4313e60	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS	PROJ-1236	Onelign Software Applications	fbfbe066-9918-412c-835d-f92a30ac44e4	ACTIVE	2026-03-27 10:03:20.826154	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N
71bb0f85-cdde-469a-900d-e8761da76e45	1d105d8b-95d8-411e-9844-b6683e8b7f51	ERP	PROJ-1235	Public Sector	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-26 23:02:59.560141	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N
a3f75871-11e5-49ba-9fb7-2659f7283f2a	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS	PROJ_101	Onelign Software Applications	b762cce3-dac1-4aa0-bc38-a8488eaf994f	ARCHIVED	2026-03-19 17:48:25.948931	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	[]	[]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N
10ac6760-95d0-4f5d-acb5-52126ff0c7e1	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS-PH	PROJ-1237	Public Sector	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-27 12:19:05.01159	FIN1234	1000000.00	2026-04-01	2026-04-01	2027-04-01	\N	PH	PH	\N	\N	["React JS"]	["SMS Gate way", "SMTP"]	\N	\N	\N	\N	\N	\N	MEDIUM	LOW	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N
419181cd-9863-4d81-843c-4644a4d31faa	1d105d8b-95d8-411e-9844-b6683e8b7f51	ERP	ERPS694	Public Sector	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-04-20 23:52:58.726208	FIN-2026-010	\N	\N	\N	\N	CLIENT	\N	\N	\N	\N	[]	[]	SERVICE	AGILE	2e745634-fcc5-46db-9651-a6cfe30aa537	0b6ad5c0-f1b4-4865-8643-634eedf36d60	edb1541e-efee-435d-a4cd-6e7da392464a	\N	MEDIUM	MEDIUM	\N	\N	\N	\N	INR	\N	TIME_AND_MATERIAL	ONGOING	\N	\N	\N	STORY_POINTS	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N
0a6d9f1d-67f1-4f8d-b9fc-314b302e69ba	1d105d8b-95d8-411e-9844-b6683e8b7f51	FPO Marketplace	FMAA884	Onelign Software Applications	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-04-10 17:05:19.652321	\N	\N	2026-03-02	2026-03-02	2026-05-31	INTERNAL	\N	\N	\N	\N	[]	[]	PRODUCT	AGILE	2e745634-fcc5-46db-9651-a6cfe30aa537	08eb8d8d-46cf-4c92-a210-2d09cf7a550f	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	MEDIUM	MEDIUM	\N	\N	Web Application	\N	USD	\N	\N	\N	\N	\N	MONDAY	HOURS	t	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N
a0be3ee4-a3b1-4e66-871f-8db5f9db1163	1d105d8b-95d8-411e-9844-b6683e8b7f51	Utility Network	UNPS321	b47cb6ff-4731-4a96-8e73-617bbd7b50f7	b14cedda-e3e3-48ea-9b5f-a2ec5c826243	DRAFT	2026-04-23 14:21:13.938781	FIN-2026-011	\N	\N	\N	\N	CLIENT	\N	\N	\N	\N	[]	[]	SERVICE	AGILE	0f2a9e2e-2291-4aa2-8f32-aa9806e20fed	26e46ea9-fd64-466f-ae5c-235c2b75727f	edb1541e-efee-435d-a4cd-6e7da392464a	\N	MEDIUM	MEDIUM	\N	\N	\N	\N	INR	\N	\N	\N	\N	\N	\N	STORY_POINTS	f	\N	f	\N	[]	\N	\N	\N	\N	\N	\N	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N
\.


--
-- TOC entry 5335 (class 0 OID 49323)
-- Dependencies: 230
-- Data for Name: project_cost; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_cost (id, org_id, project_id, cost_type, amount, description, cost_date, status, created_at) FROM stdin;
\.


--
-- TOC entry 5336 (class 0 OID 49337)
-- Dependencies: 231
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
-- TOC entry 5337 (class 0 OID 49350)
-- Dependencies: 232
-- Data for Name: project_task_sequence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_task_sequence (id, project_id, last_sequence, created_at) FROM stdin;
d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	5	2026-03-18 20:14:20.362464
d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	3	2026-03-18 20:14:20.362464
d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2	2026-03-18 20:14:20.362464
a5e71526-3737-49dc-b526-bf387e79775d	a3f75871-11e5-49ba-9fb7-2659f7283f2a	0	2026-03-19 17:48:25.948931
91c798db-b385-4277-a57c-860e1bcf4919	6564025c-356b-4e87-96e6-44360bde99f0	0	2026-03-19 18:10:00.907041
62a04d0e-faca-41ab-89d0-cf8a94b4980c	cc556634-367e-4ff9-a331-a000d92c89e3	1	2026-03-19 18:31:10.938558
79f7343b-516b-4e49-8fda-490079c1d6e5	71bb0f85-cdde-469a-900d-e8761da76e45	0	2026-03-26 23:02:59.560141
cd3557cb-7581-473f-b0c3-396eea5c9434	eeb797e6-385c-4376-a607-9663e4313e60	0	2026-03-27 10:03:20.826154
47728cde-8c52-43c0-8e8e-1838a93f53ce	0a6d9f1d-67f1-4f8d-b9fc-314b302e69ba	1	2026-04-10 17:05:19.652321
207a9436-a4b3-48d3-82d1-61b42740693b	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	8	2026-03-27 12:19:05.01159
fe14bc63-daf0-46d9-a7ea-f28ca8f86eb5	419181cd-9863-4d81-843c-4644a4d31faa	0	2026-04-20 23:52:58.726208
407fef50-14ec-4db5-a564-1048e864410d	a0be3ee4-a3b1-4e66-871f-8db5f9db1163	0	2026-04-23 14:21:13.938781
\.


--
-- TOC entry 5338 (class 0 OID 49358)
-- Dependencies: 233
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
-- TOC entry 5339 (class 0 OID 49369)
-- Dependencies: 234
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role (id, key, name, description, permissions, is_system, is_active, created_at, updated_at) FROM stdin;
98ef6064-7e4c-4915-a1f5-1d6be9b51387	ADMIN	Administrator	Global administrator role	{"LOG_TIME": true, "EDIT_TASK": true, "EDIT_USER": true, "VIEW_TASK": true, "VIEW_USER": true, "VIEW_BOARD": true, "CREATE_TASK": true, "DELETE_TASK": true, "VIEW_BUDGET": true, "VIEW_SPRINT": true, "ASSIGN_USERS": true, "EDIT_COMMENT": true, "EDIT_PROJECT": true, "MANAGE_LINKS": true, "MANAGE_USERS": true, "VIEW_BACKLOG": true, "VIEW_FINANCE": true, "VIEW_PROJECT": true, "VIEW_REPORTS": true, "MANAGE_SPRINT": true, "CREATE_COMMENT": true, "CREATE_PROJECT": true, "DELETE_COMMENT": true, "DELETE_PROJECT": true, "EDIT_USER_ROLE": true, "EDIT_TECH_STACK": true, "VIEW_ATTACHMENT": true, "VIEW_TECH_STACK": true, "EDIT_USER_STATUS": true, "CREATE_ATTACHMENT": true, "DELETE_ATTACHMENT": true, "EDIT_DEPENDENCIES": true, "EDIT_ORGANIZATION": true, "MANAGE_LEADERSHIP": true, "VIEW_DEPENDENCIES": true, "VIEW_FINANCE_CODE": true, "VIEW_ORGANIZATION": true, "EDIT_BUSINESS_UNIT": true, "VIEW_ACTIVITY_LOGS": true, "VIEW_BUSINESS_UNIT": true, "DELETE_ORGANIZATION": true, "CREATE_BUSINESS_UNIT": true, "DELETE_BUSINESS_UNIT": true, "EDIT_PROJECT_DETAILS": true, "VIEW_PROJECT_DETAILS": true, "VIEW_TEAM_TIMESHEETS": true, "MANAGE_BUSINESS_UNITS": true}	t	t	2026-04-20 17:59:30.572702	2026-04-22 11:14:35.617516
c4d1b86c-c54e-4724-805e-c1326bb968f0	MANAGER	Manager	Default manager role	{"LOG_TIME": true, "EDIT_TASK": true, "EDIT_USER": false, "VIEW_TASK": true, "VIEW_USER": true, "VIEW_BOARD": true, "CREATE_TASK": true, "DELETE_TASK": false, "VIEW_BUDGET": true, "VIEW_SPRINT": true, "ASSIGN_USERS": true, "EDIT_COMMENT": true, "EDIT_PROJECT": true, "MANAGE_LINKS": false, "MANAGE_USERS": false, "VIEW_BACKLOG": true, "VIEW_FINANCE": true, "VIEW_PROJECT": true, "VIEW_REPORTS": true, "MANAGE_SPRINT": true, "CREATE_COMMENT": true, "CREATE_PROJECT": false, "DELETE_COMMENT": false, "DELETE_PROJECT": false, "EDIT_USER_ROLE": false, "EDIT_TECH_STACK": true, "VIEW_ATTACHMENT": true, "VIEW_TECH_STACK": true, "EDIT_USER_STATUS": false, "CREATE_ATTACHMENT": true, "DELETE_ATTACHMENT": false, "EDIT_DEPENDENCIES": true, "EDIT_ORGANIZATION": false, "MANAGE_LEADERSHIP": false, "VIEW_DEPENDENCIES": true, "VIEW_FINANCE_CODE": true, "VIEW_ORGANIZATION": false, "EDIT_BUSINESS_UNIT": false, "VIEW_ACTIVITY_LOGS": false, "VIEW_BUSINESS_UNIT": true, "DELETE_ORGANIZATION": false, "CREATE_BUSINESS_UNIT": false, "DELETE_BUSINESS_UNIT": false, "EDIT_PROJECT_DETAILS": true, "VIEW_PROJECT_DETAILS": true, "VIEW_TEAM_TIMESHEETS": false, "MANAGE_BUSINESS_UNITS": false}	t	t	2026-04-20 17:59:30.572702	2026-04-22 11:14:35.617516
044f1cc6-660e-4d3c-a369-ccbde5e25a02	ORG_ADMIN	Organization Admin	Organization administrator role	{"LOG_TIME": true, "EDIT_TASK": true, "EDIT_USER": true, "VIEW_TASK": true, "VIEW_USER": true, "VIEW_BOARD": true, "CREATE_TASK": true, "DELETE_TASK": true, "VIEW_BUDGET": true, "VIEW_SPRINT": true, "ASSIGN_USERS": true, "EDIT_COMMENT": true, "EDIT_PROJECT": true, "MANAGE_LINKS": true, "MANAGE_USERS": true, "VIEW_BACKLOG": true, "VIEW_FINANCE": true, "VIEW_PROJECT": true, "VIEW_REPORTS": true, "MANAGE_SPRINT": true, "CREATE_COMMENT": true, "CREATE_PROJECT": true, "DELETE_COMMENT": true, "DELETE_PROJECT": true, "EDIT_USER_ROLE": true, "EDIT_TECH_STACK": true, "VIEW_ATTACHMENT": true, "VIEW_TECH_STACK": true, "EDIT_USER_STATUS": true, "CREATE_ATTACHMENT": true, "DELETE_ATTACHMENT": true, "EDIT_DEPENDENCIES": true, "EDIT_ORGANIZATION": true, "MANAGE_LEADERSHIP": true, "VIEW_DEPENDENCIES": true, "VIEW_FINANCE_CODE": true, "VIEW_ORGANIZATION": true, "EDIT_BUSINESS_UNIT": true, "VIEW_ACTIVITY_LOGS": true, "VIEW_BUSINESS_UNIT": true, "DELETE_ORGANIZATION": true, "CREATE_BUSINESS_UNIT": true, "DELETE_BUSINESS_UNIT": true, "EDIT_PROJECT_DETAILS": true, "VIEW_PROJECT_DETAILS": true, "VIEW_TEAM_TIMESHEETS": true, "MANAGE_BUSINESS_UNITS": true}	t	t	2026-04-20 17:59:30.572702	2026-04-22 11:14:35.617516
542ed024-dfa4-4247-8794-5f47f996fd2a	DEVELOPER	Developer	Default developer role	{"LOG_TIME": true, "EDIT_TASK": true, "EDIT_USER": false, "VIEW_TASK": true, "VIEW_USER": false, "VIEW_BOARD": true, "CREATE_TASK": true, "DELETE_TASK": false, "VIEW_BUDGET": false, "VIEW_SPRINT": true, "ASSIGN_USERS": false, "EDIT_COMMENT": true, "EDIT_PROJECT": false, "MANAGE_LINKS": false, "MANAGE_USERS": false, "VIEW_BACKLOG": true, "VIEW_FINANCE": false, "VIEW_PROJECT": true, "VIEW_REPORTS": false, "MANAGE_SPRINT": false, "CREATE_COMMENT": true, "CREATE_PROJECT": false, "DELETE_COMMENT": false, "DELETE_PROJECT": false, "EDIT_USER_ROLE": false, "EDIT_TECH_STACK": true, "VIEW_ATTACHMENT": true, "VIEW_TECH_STACK": true, "EDIT_USER_STATUS": false, "CREATE_ATTACHMENT": true, "DELETE_ATTACHMENT": false, "EDIT_DEPENDENCIES": false, "EDIT_ORGANIZATION": false, "MANAGE_LEADERSHIP": false, "VIEW_DEPENDENCIES": true, "VIEW_FINANCE_CODE": false, "VIEW_ORGANIZATION": false, "EDIT_BUSINESS_UNIT": false, "VIEW_ACTIVITY_LOGS": false, "VIEW_BUSINESS_UNIT": false, "DELETE_ORGANIZATION": false, "CREATE_BUSINESS_UNIT": false, "DELETE_BUSINESS_UNIT": false, "EDIT_PROJECT_DETAILS": false, "VIEW_PROJECT_DETAILS": false, "VIEW_TEAM_TIMESHEETS": false, "MANAGE_BUSINESS_UNITS": false}	t	t	2026-04-20 17:59:30.572702	2026-04-22 11:14:35.617516
da6ea245-5025-46f4-a718-4e552cc8d8fc	USER	User	Default user role	{"LOG_TIME": true, "EDIT_TASK": false, "EDIT_USER": false, "VIEW_TASK": true, "VIEW_USER": true, "VIEW_BOARD": true, "CREATE_TASK": true, "DELETE_TASK": false, "VIEW_BUDGET": false, "VIEW_SPRINT": true, "ASSIGN_USERS": false, "EDIT_COMMENT": true, "EDIT_PROJECT": false, "MANAGE_LINKS": false, "MANAGE_USERS": false, "VIEW_BACKLOG": true, "VIEW_FINANCE": false, "VIEW_PROJECT": true, "VIEW_REPORTS": false, "MANAGE_SPRINT": false, "CREATE_COMMENT": true, "CREATE_PROJECT": false, "DELETE_COMMENT": false, "DELETE_PROJECT": false, "EDIT_USER_ROLE": false, "EDIT_TECH_STACK": false, "VIEW_ATTACHMENT": true, "VIEW_TECH_STACK": true, "EDIT_USER_STATUS": false, "CREATE_ATTACHMENT": true, "DELETE_ATTACHMENT": false, "EDIT_DEPENDENCIES": false, "EDIT_ORGANIZATION": false, "MANAGE_LEADERSHIP": false, "VIEW_DEPENDENCIES": true, "VIEW_FINANCE_CODE": false, "VIEW_ORGANIZATION": false, "EDIT_BUSINESS_UNIT": false, "VIEW_ACTIVITY_LOGS": false, "VIEW_BUSINESS_UNIT": true, "DELETE_ORGANIZATION": false, "CREATE_BUSINESS_UNIT": false, "DELETE_BUSINESS_UNIT": false, "EDIT_PROJECT_DETAILS": false, "VIEW_PROJECT_DETAILS": true, "VIEW_TEAM_TIMESHEETS": false, "MANAGE_BUSINESS_UNITS": false}	t	t	2026-04-20 17:59:30.572702	2026-04-22 11:14:35.617516
b3fcf94a-40cd-4a56-be8e-c92f44e427ca	BA	BA	Business Analyst	{"LOG_TIME": true, "EDIT_TASK": true, "EDIT_USER": false, "VIEW_TASK": true, "VIEW_USER": false, "VIEW_BOARD": true, "CREATE_TASK": true, "DELETE_TASK": true, "VIEW_BUDGET": true, "VIEW_SPRINT": true, "ASSIGN_USERS": true, "EDIT_COMMENT": true, "EDIT_PROJECT": true, "MANAGE_LINKS": true, "MANAGE_USERS": true, "VIEW_BACKLOG": true, "VIEW_FINANCE": false, "VIEW_PROJECT": true, "VIEW_REPORTS": true, "MANAGE_SPRINT": true, "CREATE_COMMENT": true, "CREATE_PROJECT": true, "DELETE_COMMENT": true, "DELETE_PROJECT": false, "EDIT_USER_ROLE": true, "EDIT_TECH_STACK": true, "VIEW_ATTACHMENT": true, "VIEW_TECH_STACK": true, "EDIT_USER_STATUS": true, "CREATE_ATTACHMENT": true, "DELETE_ATTACHMENT": true, "EDIT_DEPENDENCIES": true, "EDIT_ORGANIZATION": false, "MANAGE_LEADERSHIP": false, "VIEW_DEPENDENCIES": true, "VIEW_FINANCE_CODE": true, "VIEW_ORGANIZATION": false, "EDIT_BUSINESS_UNIT": false, "VIEW_ACTIVITY_LOGS": false, "VIEW_BUSINESS_UNIT": false, "DELETE_ORGANIZATION": false, "CREATE_BUSINESS_UNIT": false, "DELETE_BUSINESS_UNIT": false, "EDIT_PROJECT_DETAILS": true, "VIEW_PROJECT_DETAILS": true, "VIEW_TEAM_TIMESHEETS": true, "MANAGE_BUSINESS_UNITS": false}	f	t	2026-04-20 23:22:54.384081	2026-04-22 11:14:35.617516
231ef88c-a2f1-4f9c-bc63-e164cbc83119	TEST	test	\N	{"LOG_TIME": true, "EDIT_TASK": false, "EDIT_USER": false, "VIEW_TASK": false, "VIEW_USER": true, "VIEW_BOARD": false, "CREATE_TASK": false, "DELETE_TASK": false, "VIEW_BUDGET": true, "VIEW_SPRINT": false, "ASSIGN_USERS": true, "EDIT_COMMENT": false, "EDIT_PROJECT": true, "MANAGE_LINKS": false, "MANAGE_USERS": true, "VIEW_BACKLOG": false, "VIEW_FINANCE": true, "VIEW_PROJECT": true, "VIEW_REPORTS": false, "MANAGE_SPRINT": false, "CREATE_COMMENT": false, "CREATE_PROJECT": true, "DELETE_COMMENT": false, "DELETE_PROJECT": true, "EDIT_USER_ROLE": true, "EDIT_TECH_STACK": true, "VIEW_ATTACHMENT": true, "VIEW_TECH_STACK": true, "EDIT_USER_STATUS": true, "CREATE_ATTACHMENT": false, "DELETE_ATTACHMENT": false, "EDIT_DEPENDENCIES": true, "EDIT_ORGANIZATION": false, "MANAGE_LEADERSHIP": false, "VIEW_DEPENDENCIES": true, "VIEW_FINANCE_CODE": true, "VIEW_ORGANIZATION": true, "EDIT_BUSINESS_UNIT": false, "VIEW_ACTIVITY_LOGS": true, "VIEW_BUSINESS_UNIT": true, "DELETE_ORGANIZATION": false, "CREATE_BUSINESS_UNIT": false, "DELETE_BUSINESS_UNIT": false, "EDIT_PROJECT_DETAILS": false, "VIEW_PROJECT_DETAILS": false, "VIEW_TEAM_TIMESHEETS": false, "MANAGE_BUSINESS_UNITS": true}	f	t	2026-04-20 23:47:20.842067	2026-04-22 11:14:35.617516
c5c24a5a-b1fa-4d8c-8f5a-cfc81a5134e6	CEO	Chief Executive Officer	Executive read-only role. Full visibility into projects, finance, reports and leadership. No access to board task management.	{"LOG_TIME": false, "EDIT_TASK": false, "EDIT_USER": false, "VIEW_TASK": false, "VIEW_USER": false, "VIEW_BOARD": false, "CREATE_TASK": false, "DELETE_TASK": false, "VIEW_BUDGET": true, "VIEW_SPRINT": false, "ASSIGN_USERS": false, "EDIT_COMMENT": false, "EDIT_PROJECT": false, "MANAGE_LINKS": false, "MANAGE_USERS": false, "VIEW_BACKLOG": false, "VIEW_FINANCE": false, "VIEW_PROJECT": true, "VIEW_REPORTS": true, "MANAGE_SPRINT": false, "CREATE_COMMENT": false, "CREATE_PROJECT": false, "DELETE_COMMENT": false, "DELETE_PROJECT": false, "EDIT_USER_ROLE": false, "EDIT_TECH_STACK": false, "VIEW_ATTACHMENT": false, "VIEW_TECH_STACK": false, "EDIT_USER_STATUS": false, "CREATE_ATTACHMENT": false, "DELETE_ATTACHMENT": false, "EDIT_DEPENDENCIES": false, "EDIT_ORGANIZATION": false, "MANAGE_LEADERSHIP": true, "VIEW_DEPENDENCIES": false, "VIEW_FINANCE_CODE": true, "VIEW_ORGANIZATION": false, "EDIT_BUSINESS_UNIT": false, "VIEW_ACTIVITY_LOGS": true, "VIEW_BUSINESS_UNIT": true, "DELETE_ORGANIZATION": false, "CREATE_BUSINESS_UNIT": false, "DELETE_BUSINESS_UNIT": false, "EDIT_PROJECT_DETAILS": false, "VIEW_PROJECT_DETAILS": true, "VIEW_TEAM_TIMESHEETS": false, "MANAGE_BUSINESS_UNITS": true}	t	t	2026-04-22 10:28:03.991079	2026-04-23 10:53:04.842358
\.


--
-- TOC entry 5340 (class 0 OID 49388)
-- Dependencies: 235
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
72fa7535-4dbb-4d7d-97b3-05019f572520	0a6d9f1d-67f1-4f8d-b9fc-314b302e69ba	Sprint-1	2026-03-02	2026-03-27	ACTIVE	2026-04-10 18:08:26.106287	\N	\N
\.


--
-- TOC entry 5341 (class 0 OID 49398)
-- Dependencies: 236
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
-- TOC entry 5342 (class 0 OID 49407)
-- Dependencies: 237
-- Data for Name: task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task (id, org_id, project_id, sprint_id, task_code, title, description, task_type, status, priority, assigned_to, created_by, due_date, created_at, output_description, blocked_by, epic_id, story_id, updated_at) FROM stdin;
81eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-1	Setup project structure	Initialize React Native project with TypeScript	STORY	DONE	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-10	2026-03-18 20:14:20.370886	\N	\N	\N	\N	\N
82eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-2	Configure CI/CD pipeline	Setup GitHub Actions for automated builds	STORY	DONE	MEDIUM	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-12	2026-03-18 20:14:20.370886	\N	\N	\N	\N	\N
83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-3	Implement login screen	Create login UI with email and password fields	STORY	IN_PROGRESS	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-20	2026-03-18 20:14:20.370886	\N	\N	\N	\N	\N
84eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-4	Integrate Azure AD auth	Implement Microsoft authentication	STORY	TODO	HIGH	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-25	2026-03-18 20:14:20.370886	\N	\N	\N	\N	\N
85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MOB-5	Login button not responsive on iOS	Touch event not firing consistently	BUG	TODO	CRITICAL	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-22	2026-03-18 20:14:20.370886	\N	\N	\N	\N	\N
86eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	WEB-1	Design homepage mockup	Create Figma designs for new homepage	STORY	DONE	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-08	2026-03-18 20:14:20.370886	\N	\N	\N	\N	\N
87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	WEB-2	Implement hero section	Build responsive hero component	STORY	IN_PROGRESS	HIGH	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-12	2026-03-18 20:14:20.370886	\N	\N	\N	\N	\N
88eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	WEB-3	Add SEO meta tags	Implement dynamic meta tags for all pages	STORY	TODO	MEDIUM	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-15	2026-03-18 20:14:20.370886	\N	\N	\N	\N	\N
89eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	API-1	Design REST API endpoints	Document all API endpoints in OpenAPI spec	STORY	DONE	HIGH	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-15	2026-03-18 20:14:20.370886	\N	\N	\N	\N	\N
8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	API-2	Implement rate limiting	Add rate limiting middleware	STORY	IN_PROGRESS	MEDIUM	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-20	2026-03-18 20:14:20.370886	\N	\N	\N	\N	\N
f0e9f76c-8905-4f8c-9667-aa2a202bf4a0	1d105d8b-95d8-411e-9844-b6683e8b7f51	cc556634-367e-4ff9-a331-a000d92c89e3	1caa5563-3120-430a-a398-dacffb2123f9	PROJ-123-1	Login Page	Login Page	STORY	IN_REVIEW	MEDIUM	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-03-28	2026-03-20 10:25:16.159343	\N	\N	\N	\N	\N
f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-1	Login Page	\N	TASK	TODO	MEDIUM	b762cce3-dac1-4aa0-bc38-a8488eaf994f	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-30	2026-03-27 16:54:46.380157	\N	\N	\N	\N	\N
86d4af01-800a-435d-ac7c-d4594c1f495b	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-2	Registration Page	\N	TASK	IN_REVIEW	MEDIUM	edb1541e-efee-435d-a4cd-6e7da392464a	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-31	2026-03-27 16:55:49.638554	LOGIN PAGE	\N	\N	\N	\N
85850f79-5d93-4b84-8c82-833ab4ccf4b0	1d105d8b-95d8-411e-9844-b6683e8b7f51	0a6d9f1d-67f1-4f8d-b9fc-314b302e69ba	72fa7535-4dbb-4d7d-97b3-05019f572520	FMAA884-1	Base Code	Develop Base Code	TASK	TODO	MEDIUM	\N	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-05-18	2026-04-10 18:02:55.828561	\N	\N	\N	\N	\N
687a4cb9-0753-4285-9e0b-05c38eee759e	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-7	R&D Login Page	\N	TASK	TODO	MEDIUM	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-23	2026-04-20 22:30:20.109136	\N	\N	\N	\N	\N
c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	\N	PROJ-1237-3	R&D Animation for login page	Search for animations	SUB_TASK	IN_PROGRESS	HIGH	edb1541e-efee-435d-a4cd-6e7da392464a	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-31	2026-03-28 14:10:32.206133	\N	\N	\N	\N	2026-04-20 23:41:43.410358
15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-8	Tenant Configuration	\N	EPIC	DONE	MEDIUM	edb1541e-efee-435d-a4cd-6e7da392464a	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-25	2026-04-20 22:31:22.623148	\N	\N	\N	\N	2026-04-23 14:56:26.648567
\.


--
-- TOC entry 5343 (class 0 OID 49420)
-- Dependencies: 238
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
8b7fff7f-6b54-47be-8ef1-4a0fb2f1e919	1d105d8b-95d8-411e-9844-b6683e8b7f51	15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	edb1541e-efee-435d-a4cd-6e7da392464a	\N	first comment	ACTIVE	2026-04-20 22:56:22.019711	\N
\.


--
-- TOC entry 5344 (class 0 OID 49433)
-- Dependencies: 239
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
-- TOC entry 5345 (class 0 OID 49443)
-- Dependencies: 240
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
687a4cb9-0753-4285-9e0b-05c38eee759e	a67cc96e-c7b8-4cf7-833a-59698ea78902
15f999f2-dd27-4857-bb4d-ad75aa7d5ff5	a67cc96e-c7b8-4cf7-833a-59698ea78902
\.


--
-- TOC entry 5346 (class 0 OID 49448)
-- Dependencies: 241
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
-- TOC entry 5347 (class 0 OID 49464)
-- Dependencies: 242
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
\.


--
-- TOC entry 5348 (class 0 OID 49479)
-- Dependencies: 243
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
-- TOC entry 5349 (class 0 OID 49490)
-- Dependencies: 244
-- Data for Name: user_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_permission (id, user_id, permission_key, is_granted, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5350 (class 0 OID 49503)
-- Dependencies: 245
-- Data for Name: user_project_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_project_mapping (id, org_id, user_id, project_id, project_role, status, created_at, allocated_bandwidth, approval_status, requested_by_user_id, approved_by_user_id, approved_at, resource_type) FROM stdin;
e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MANAGER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N	DEDICATED
e2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEVELOPER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N	DEDICATED
e3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEVELOPER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N	DEDICATED
e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	QA	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N	DEDICATED
e5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MANAGER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N	DEDICATED
e6eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEVELOPER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N	DEDICATED
e7eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	MANAGER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N	DEDICATED
e8eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	DEVELOPER	ACTIVE	2026-03-18 20:14:20.363996	0	PENDING	\N	\N	\N	DEDICATED
a8249a6a-f2e0-477a-8751-b1b961ea8096	1d105d8b-95d8-411e-9844-b6683e8b7f51	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	71bb0f85-cdde-469a-900d-e8761da76e45	MANAGER	ACTIVE	2026-03-27 00:03:11.641963	0	REJECTED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:04:00.384	DEDICATED
4669f46e-3526-449e-b5bd-e4811f73017c	1d105d8b-95d8-411e-9844-b6683e8b7f51	b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	71bb0f85-cdde-469a-900d-e8761da76e45	DEV	ACTIVE	2026-03-27 00:03:18.341318	0	REJECTED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:04:03.561	DEDICATED
990bfa40-f689-4c86-b889-c94fac44bb5d	1d105d8b-95d8-411e-9844-b6683e8b7f51	b762cce3-dac1-4aa0-bc38-a8488eaf994f	71bb0f85-cdde-469a-900d-e8761da76e45	QA	ACTIVE	2026-03-27 12:16:26.351317	50	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:17:59.381	DEDICATED
b0f86c88-daa5-4db2-95eb-e3853e1076b5	1d105d8b-95d8-411e-9844-b6683e8b7f51	b762cce3-dac1-4aa0-bc38-a8488eaf994f	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-03-27 12:19:21.433172	50	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:19:30.431	DEDICATED
690f4d4c-7363-4fd7-9870-3e1876f75feb	1d105d8b-95d8-411e-9844-b6683e8b7f51	fbfbe066-9918-412c-835d-f92a30ac44e4	eeb797e6-385c-4376-a607-9663e4313e60	DEV	ACTIVE	2026-03-27 11:48:45.554344	60	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:21:58.008	DEDICATED
c2bb69e7-aaf2-407c-ac56-525ffc71643c	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	71bb0f85-cdde-469a-900d-e8761da76e45	DEV	ACTIVE	2026-03-27 12:35:42.529365	60	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 12:35:46.957	DEDICATED
74c845ad-3beb-4289-be4f-e565eb5a3ccc	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-03-27 14:59:45.637328	40	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 14:59:50.019	DEDICATED
6544a869-d2fe-41d8-8f59-cd6e90245479	1d105d8b-95d8-411e-9844-b6683e8b7f51	fbfbe066-9918-412c-835d-f92a30ac44e4	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-03-27 16:11:07.351416	40	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-27 16:11:15.047	DEDICATED
56264c7f-dc8f-4bac-9000-6328eee1168b	1d105d8b-95d8-411e-9844-b6683e8b7f51	1400ccae-fcaa-452d-9d61-30afb052b604	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	SCRUM_MASTER	ACTIVE	2026-04-07 08:45:53.556718	50	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-07 08:46:08.463	DEDICATED
f57de93d-1d7f-483c-ace8-a06c8777717d	1d105d8b-95d8-411e-9844-b6683e8b7f51	65b2f9f4-a049-4766-b6f6-4ecca8fb8de7	cc556634-367e-4ff9-a331-a000d92c89e3	DEV	ACTIVE	2026-03-20 14:15:31.492414	0	APPROVED	\N	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-04-09 12:45:30.833	DEDICATED
892c9d61-da2c-457b-9fa5-3f46a52605e8	1d105d8b-95d8-411e-9844-b6683e8b7f51	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	cc556634-367e-4ff9-a331-a000d92c89e3	MANAGER	ACTIVE	2026-03-20 15:26:56.929039	0	APPROVED	\N	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-04-09 12:45:32.359	DEDICATED
8dda0ff5-4e29-4034-b7e3-a7481e98c4de	1d105d8b-95d8-411e-9844-b6683e8b7f51	b14cedda-e3e3-48ea-9b5f-a2ec5c826243	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	DEV	ACTIVE	2026-04-23 16:50:43.680023	50	APPROVED	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-23 16:50:54.174	SHARED
\.


--
-- TOC entry 4975 (class 2606 OID 49522)
-- Name: activity_log activity_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_pkey PRIMARY KEY (id);


--
-- TOC entry 4981 (class 2606 OID 49524)
-- Name: app_user app_user_org_id_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_email_key UNIQUE (org_id, email);


--
-- TOC entry 4983 (class 2606 OID 49526)
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- TOC entry 4989 (class 2606 OID 49528)
-- Name: attachment attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- TOC entry 4993 (class 2606 OID 49530)
-- Name: business_unit business_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_pkey PRIMARY KEY (id);


--
-- TOC entry 4999 (class 2606 OID 49532)
-- Name: chat_message chat_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_pkey PRIMARY KEY (id);


--
-- TOC entry 5002 (class 2606 OID 49534)
-- Name: chat_session chat_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_pkey PRIMARY KEY (id);


--
-- TOC entry 5008 (class 2606 OID 49536)
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- TOC entry 5011 (class 2606 OID 49538)
-- Name: organization organization_azure_tenant_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_azure_tenant_id_key UNIQUE (azure_tenant_id);


--
-- TOC entry 5013 (class 2606 OID 49540)
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- TOC entry 5015 (class 2606 OID 49542)
-- Name: platform_user platform_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_email_key UNIQUE (email);


--
-- TOC entry 5017 (class 2606 OID 49544)
-- Name: platform_user platform_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_pkey PRIMARY KEY (id);


--
-- TOC entry 5032 (class 2606 OID 49546)
-- Name: project_cost project_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_pkey PRIMARY KEY (id);


--
-- TOC entry 5035 (class 2606 OID 49548)
-- Name: project_link project_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5026 (class 2606 OID 49550)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- TOC entry 5028 (class 2606 OID 49552)
-- Name: project project_project_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_project_code_key UNIQUE (project_code);


--
-- TOC entry 5038 (class 2606 OID 49554)
-- Name: project_task_sequence project_task_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_pkey PRIMARY KEY (id);


--
-- TOC entry 5040 (class 2606 OID 49556)
-- Name: project_task_sequence project_task_sequence_project_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_key UNIQUE (project_id);


--
-- TOC entry 5043 (class 2606 OID 49558)
-- Name: resource_cost resource_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_pkey PRIMARY KEY (id);


--
-- TOC entry 5045 (class 2606 OID 49560)
-- Name: resource_cost resource_cost_user_id_effective_from_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_effective_from_key UNIQUE (user_id, effective_from);


--
-- TOC entry 5049 (class 2606 OID 49562)
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- TOC entry 5054 (class 2606 OID 49564)
-- Name: sprint sprint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_pkey PRIMARY KEY (id);


--
-- TOC entry 5057 (class 2606 OID 49566)
-- Name: tag tag_org_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_name_key UNIQUE (org_id, name);


--
-- TOC entry 5059 (class 2606 OID 49568)
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- TOC entry 5075 (class 2606 OID 49570)
-- Name: task_comment task_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_pkey PRIMARY KEY (id);


--
-- TOC entry 5079 (class 2606 OID 49572)
-- Name: task_link task_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5081 (class 2606 OID 49574)
-- Name: task_link task_link_source_task_id_target_task_id_link_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_target_task_id_link_type_key UNIQUE (source_task_id, target_task_id, link_type);


--
-- TOC entry 5069 (class 2606 OID 49576)
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- TOC entry 5085 (class 2606 OID 49578)
-- Name: task_tag_mapping task_tag_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_pkey PRIMARY KEY (task_id, tag_id);


--
-- TOC entry 5071 (class 2606 OID 49580)
-- Name: task task_task_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_task_code_key UNIQUE (task_code);


--
-- TOC entry 5091 (class 2606 OID 49582)
-- Name: time_log time_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5096 (class 2606 OID 49584)
-- Name: timesheet timesheet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_pkey PRIMARY KEY (id);


--
-- TOC entry 4997 (class 2606 OID 49586)
-- Name: business_unit uq_business_unit_org_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT uq_business_unit_org_name UNIQUE (org_id, name);


--
-- TOC entry 5051 (class 2606 OID 49588)
-- Name: role uq_role_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT uq_role_key UNIQUE (key);


--
-- TOC entry 5105 (class 2606 OID 49590)
-- Name: user_permission uq_user_permission; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT uq_user_permission UNIQUE (user_id, permission_key);


--
-- TOC entry 5114 (class 2606 OID 49592)
-- Name: user_project_mapping uq_user_project_mapping_user_project_role; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT uq_user_project_mapping_user_project_role UNIQUE (user_id, project_id, project_role);


--
-- TOC entry 5100 (class 2606 OID 49594)
-- Name: user_daily_summary user_daily_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_pkey PRIMARY KEY (id);


--
-- TOC entry 5102 (class 2606 OID 49596)
-- Name: user_daily_summary user_daily_summary_user_id_summary_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_summary_date_key UNIQUE (user_id, summary_date);


--
-- TOC entry 5107 (class 2606 OID 49598)
-- Name: user_permission user_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT user_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 5116 (class 2606 OID 49600)
-- Name: user_project_mapping user_project_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_pkey PRIMARY KEY (id);


--
-- TOC entry 4976 (class 1259 OID 49601)
-- Name: idx_activity_log_action_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_action_type ON public.activity_log USING btree (action_type);


--
-- TOC entry 4977 (class 1259 OID 49602)
-- Name: idx_activity_log_actor_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_actor_user_id ON public.activity_log USING btree (actor_user_id);


--
-- TOC entry 4978 (class 1259 OID 49603)
-- Name: idx_activity_log_org_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_org_created_at ON public.activity_log USING btree (org_id, created_at DESC);


--
-- TOC entry 4979 (class 1259 OID 49604)
-- Name: idx_activity_log_resource_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_resource_type ON public.activity_log USING btree (resource_type);


--
-- TOC entry 4984 (class 1259 OID 49605)
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- TOC entry 4985 (class 1259 OID 49606)
-- Name: idx_app_user_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_org ON public.app_user USING btree (org_id);


--
-- TOC entry 4986 (class 1259 OID 49968)
-- Name: idx_app_user_password_setup_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_password_setup_token_hash ON public.app_user USING btree (password_setup_token_hash) WHERE (password_setup_token_hash IS NOT NULL);


--
-- TOC entry 4987 (class 1259 OID 49607)
-- Name: idx_app_user_role_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_role_id ON public.app_user USING btree (role_id);


--
-- TOC entry 4990 (class 1259 OID 49608)
-- Name: idx_attachment_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_org ON public.attachment USING btree (org_id);


--
-- TOC entry 4991 (class 1259 OID 49609)
-- Name: idx_attachment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_task ON public.attachment USING btree (task_id);


--
-- TOC entry 4994 (class 1259 OID 49610)
-- Name: idx_business_unit_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_business_unit_org ON public.business_unit USING btree (org_id);


--
-- TOC entry 4995 (class 1259 OID 49611)
-- Name: idx_business_unit_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_business_unit_owner ON public.business_unit USING btree (owner_id);


--
-- TOC entry 5000 (class 1259 OID 49612)
-- Name: idx_chat_message_session_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_message_session_created ON public.chat_message USING btree (session_id, created_at);


--
-- TOC entry 5003 (class 1259 OID 49613)
-- Name: idx_chat_session_org_user_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_session_org_user_active ON public.chat_session USING btree (org_id, user_id, ended_at);


--
-- TOC entry 5004 (class 1259 OID 49614)
-- Name: idx_chat_session_org_user_started; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_session_org_user_started ON public.chat_session USING btree (org_id, user_id, started_at);


--
-- TOC entry 5005 (class 1259 OID 49615)
-- Name: idx_notification_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_created_at ON public.notification USING btree (created_at);


--
-- TOC entry 5006 (class 1259 OID 49616)
-- Name: idx_notification_recipient_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_recipient_is_read ON public.notification USING btree (recipient_id, is_read);


--
-- TOC entry 5009 (class 1259 OID 49617)
-- Name: idx_organization_azure_tenant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_organization_azure_tenant ON public.organization USING btree (azure_tenant_id);


--
-- TOC entry 5018 (class 1259 OID 49618)
-- Name: idx_project_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_code ON public.project USING btree (project_code);


--
-- TOC entry 5030 (class 1259 OID 49619)
-- Name: idx_project_cost_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_cost_project ON public.project_cost USING btree (project_id);


--
-- TOC entry 5019 (class 1259 OID 49620)
-- Name: idx_project_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_created_by ON public.project USING btree (created_by_id);


--
-- TOC entry 5020 (class 1259 OID 49621)
-- Name: idx_project_delivery_manager; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_delivery_manager ON public.project USING btree (delivery_manager_id);


--
-- TOC entry 5021 (class 1259 OID 49622)
-- Name: idx_project_finance_member; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_finance_member ON public.project USING btree (finance_member_id);


--
-- TOC entry 5033 (class 1259 OID 49623)
-- Name: idx_project_link_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_link_project ON public.project_link USING btree (project_id);


--
-- TOC entry 5022 (class 1259 OID 49624)
-- Name: idx_project_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_org ON public.project USING btree (org_id);


--
-- TOC entry 5023 (class 1259 OID 49625)
-- Name: idx_project_sponsor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_sponsor ON public.project USING btree (sponsor_id);


--
-- TOC entry 5036 (class 1259 OID 49626)
-- Name: idx_project_task_sequence_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_task_sequence_project ON public.project_task_sequence USING btree (project_id);


--
-- TOC entry 5024 (class 1259 OID 49627)
-- Name: idx_project_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_type ON public.project USING btree (project_type);


--
-- TOC entry 5041 (class 1259 OID 49628)
-- Name: idx_resource_cost_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_resource_cost_user ON public.resource_cost USING btree (user_id);


--
-- TOC entry 5046 (class 1259 OID 49629)
-- Name: idx_role_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_role_active ON public.role USING btree (is_active);


--
-- TOC entry 5047 (class 1259 OID 49630)
-- Name: idx_role_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_role_key ON public.role USING btree (key);


--
-- TOC entry 5052 (class 1259 OID 49631)
-- Name: idx_sprint_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sprint_project ON public.sprint USING btree (project_id);


--
-- TOC entry 5055 (class 1259 OID 49632)
-- Name: idx_tag_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tag_org ON public.tag USING btree (org_id);


--
-- TOC entry 5060 (class 1259 OID 49633)
-- Name: idx_task_assignee; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_assignee ON public.task USING btree (assigned_to);


--
-- TOC entry 5061 (class 1259 OID 49634)
-- Name: idx_task_blocked_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_blocked_by ON public.task USING btree (blocked_by);


--
-- TOC entry 5062 (class 1259 OID 49635)
-- Name: idx_task_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_code ON public.task USING btree (task_code);


--
-- TOC entry 5072 (class 1259 OID 49636)
-- Name: idx_task_comment_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_parent ON public.task_comment USING btree (parent_comment_id);


--
-- TOC entry 5073 (class 1259 OID 49637)
-- Name: idx_task_comment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_task ON public.task_comment USING btree (task_id);


--
-- TOC entry 5063 (class 1259 OID 49638)
-- Name: idx_task_epic_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_epic_id ON public.task USING btree (epic_id);


--
-- TOC entry 5076 (class 1259 OID 49639)
-- Name: idx_task_link_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_source ON public.task_link USING btree (source_task_id);


--
-- TOC entry 5077 (class 1259 OID 49640)
-- Name: idx_task_link_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_target ON public.task_link USING btree (target_task_id);


--
-- TOC entry 5064 (class 1259 OID 49641)
-- Name: idx_task_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_org ON public.task USING btree (org_id);


--
-- TOC entry 5065 (class 1259 OID 49642)
-- Name: idx_task_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_project ON public.task USING btree (project_id);


--
-- TOC entry 5066 (class 1259 OID 49643)
-- Name: idx_task_sprint; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_sprint ON public.task USING btree (sprint_id);


--
-- TOC entry 5067 (class 1259 OID 49644)
-- Name: idx_task_story_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_story_id ON public.task USING btree (story_id);


--
-- TOC entry 5082 (class 1259 OID 49645)
-- Name: idx_task_tag_mapping_tag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_tag ON public.task_tag_mapping USING btree (tag_id);


--
-- TOC entry 5083 (class 1259 OID 49646)
-- Name: idx_task_tag_mapping_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_task ON public.task_tag_mapping USING btree (task_id);


--
-- TOC entry 5086 (class 1259 OID 49647)
-- Name: idx_time_log_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_date ON public.time_log USING btree (log_date);


--
-- TOC entry 5087 (class 1259 OID 49648)
-- Name: idx_time_log_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_task ON public.time_log USING btree (task_id);


--
-- TOC entry 5088 (class 1259 OID 49649)
-- Name: idx_time_log_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user ON public.time_log USING btree (user_id);


--
-- TOC entry 5089 (class 1259 OID 49650)
-- Name: idx_time_log_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user_date ON public.time_log USING btree (user_id, log_date);


--
-- TOC entry 5092 (class 1259 OID 49651)
-- Name: idx_timesheet_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_org ON public.timesheet USING btree (org_id);


--
-- TOC entry 5093 (class 1259 OID 49652)
-- Name: idx_timesheet_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user ON public.timesheet USING btree (user_id);


--
-- TOC entry 5094 (class 1259 OID 49653)
-- Name: idx_timesheet_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user_date ON public.timesheet USING btree (user_id, entry_date);


--
-- TOC entry 5097 (class 1259 OID 49654)
-- Name: idx_user_daily_summary_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_date ON public.user_daily_summary USING btree (summary_date);


--
-- TOC entry 5098 (class 1259 OID 49655)
-- Name: idx_user_daily_summary_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_user ON public.user_daily_summary USING btree (user_id);


--
-- TOC entry 5103 (class 1259 OID 49656)
-- Name: idx_user_permission_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_permission_user_id ON public.user_permission USING btree (user_id);


--
-- TOC entry 5108 (class 1259 OID 49657)
-- Name: idx_user_project_mapping_approval_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_approval_status ON public.user_project_mapping USING btree (approval_status);


--
-- TOC entry 5109 (class 1259 OID 49658)
-- Name: idx_user_project_mapping_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project ON public.user_project_mapping USING btree (project_id);


--
-- TOC entry 5110 (class 1259 OID 49659)
-- Name: idx_user_project_mapping_project_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project_approval ON public.user_project_mapping USING btree (project_id, approval_status);


--
-- TOC entry 5111 (class 1259 OID 49660)
-- Name: idx_user_project_mapping_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user ON public.user_project_mapping USING btree (user_id);


--
-- TOC entry 5112 (class 1259 OID 49661)
-- Name: idx_user_project_mapping_user_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user_approval ON public.user_project_mapping USING btree (user_id, approval_status);


--
-- TOC entry 5029 (class 1259 OID 49662)
-- Name: uq_project_org_finance_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_project_org_finance_code ON public.project USING btree (org_id, finance_code) WHERE (finance_code IS NOT NULL);


--
-- TOC entry 5117 (class 2606 OID 49663)
-- Name: activity_log activity_log_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5118 (class 2606 OID 49668)
-- Name: activity_log activity_log_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5119 (class 2606 OID 49673)
-- Name: app_user app_user_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5120 (class 2606 OID 49678)
-- Name: attachment attachment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5121 (class 2606 OID 49683)
-- Name: attachment attachment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5122 (class 2606 OID 49688)
-- Name: attachment attachment_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.app_user(id);


--
-- TOC entry 5123 (class 2606 OID 49693)
-- Name: business_unit business_unit_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5124 (class 2606 OID 49698)
-- Name: business_unit business_unit_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5125 (class 2606 OID 49703)
-- Name: chat_message chat_message_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.chat_session(id) ON DELETE CASCADE;


--
-- TOC entry 5126 (class 2606 OID 49708)
-- Name: chat_session chat_session_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5127 (class 2606 OID 49713)
-- Name: chat_session chat_session_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5130 (class 2606 OID 49718)
-- Name: project fk_project_finance_member; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT fk_project_finance_member FOREIGN KEY (finance_member_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5146 (class 2606 OID 49723)
-- Name: task fk_task_blocked_by_app_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT fk_task_blocked_by_app_user FOREIGN KEY (blocked_by) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5147 (class 2606 OID 49728)
-- Name: task fk_task_epic_id_task; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT fk_task_epic_id_task FOREIGN KEY (epic_id) REFERENCES public.task(id) ON DELETE SET NULL;


--
-- TOC entry 5148 (class 2606 OID 49733)
-- Name: task fk_task_story_id_task; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT fk_task_story_id_task FOREIGN KEY (story_id) REFERENCES public.task(id) ON DELETE SET NULL;


--
-- TOC entry 5172 (class 2606 OID 49738)
-- Name: user_permission fk_user_permission_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT fk_user_permission_user FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- TOC entry 5128 (class 2606 OID 49743)
-- Name: notification notification_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.app_user(id);


--
-- TOC entry 5129 (class 2606 OID 49748)
-- Name: notification notification_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id);


--
-- TOC entry 5131 (class 2606 OID 49753)
-- Name: project project_approved_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_approved_by_id_fkey FOREIGN KEY (approved_by_id) REFERENCES public.app_user(id);


--
-- TOC entry 5137 (class 2606 OID 49758)
-- Name: project_cost project_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5138 (class 2606 OID 49763)
-- Name: project_cost project_cost_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5132 (class 2606 OID 49768)
-- Name: project project_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.app_user(id);


--
-- TOC entry 5133 (class 2606 OID 49773)
-- Name: project project_delivery_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_delivery_manager_id_fkey FOREIGN KEY (delivery_manager_id) REFERENCES public.app_user(id);


--
-- TOC entry 5139 (class 2606 OID 49778)
-- Name: project_link project_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5140 (class 2606 OID 49783)
-- Name: project_link project_link_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5134 (class 2606 OID 49788)
-- Name: project project_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.app_user(id);


--
-- TOC entry 5135 (class 2606 OID 49793)
-- Name: project project_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5136 (class 2606 OID 49798)
-- Name: project project_sponsor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_sponsor_id_fkey FOREIGN KEY (sponsor_id) REFERENCES public.app_user(id);


--
-- TOC entry 5141 (class 2606 OID 49803)
-- Name: project_task_sequence project_task_sequence_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5142 (class 2606 OID 49808)
-- Name: resource_cost resource_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5143 (class 2606 OID 49813)
-- Name: resource_cost resource_cost_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5144 (class 2606 OID 49818)
-- Name: sprint sprint_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5145 (class 2606 OID 49823)
-- Name: tag tag_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5149 (class 2606 OID 49828)
-- Name: task task_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.app_user(id);


--
-- TOC entry 5154 (class 2606 OID 49833)
-- Name: task_comment task_comment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5155 (class 2606 OID 49838)
-- Name: task_comment task_comment_parent_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.task_comment(id);


--
-- TOC entry 5156 (class 2606 OID 49843)
-- Name: task_comment task_comment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5157 (class 2606 OID 49848)
-- Name: task_comment task_comment_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5150 (class 2606 OID 49853)
-- Name: task task_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- TOC entry 5158 (class 2606 OID 49858)
-- Name: task_link task_link_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- TOC entry 5159 (class 2606 OID 49863)
-- Name: task_link task_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5160 (class 2606 OID 49868)
-- Name: task_link task_link_source_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_fkey FOREIGN KEY (source_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5161 (class 2606 OID 49873)
-- Name: task_link task_link_target_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_target_task_id_fkey FOREIGN KEY (target_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5151 (class 2606 OID 49878)
-- Name: task task_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5152 (class 2606 OID 49883)
-- Name: task task_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5153 (class 2606 OID 49888)
-- Name: task task_sprint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_sprint_id_fkey FOREIGN KEY (sprint_id) REFERENCES public.sprint(id);


--
-- TOC entry 5162 (class 2606 OID 49893)
-- Name: task_tag_mapping task_tag_mapping_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id) ON DELETE CASCADE;


--
-- TOC entry 5163 (class 2606 OID 49898)
-- Name: task_tag_mapping task_tag_mapping_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5164 (class 2606 OID 49903)
-- Name: time_log time_log_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5165 (class 2606 OID 49908)
-- Name: time_log time_log_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5166 (class 2606 OID 49913)
-- Name: time_log time_log_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5167 (class 2606 OID 49918)
-- Name: time_log time_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5168 (class 2606 OID 49923)
-- Name: timesheet timesheet_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5169 (class 2606 OID 49928)
-- Name: timesheet timesheet_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5170 (class 2606 OID 49933)
-- Name: user_daily_summary user_daily_summary_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5171 (class 2606 OID 49938)
-- Name: user_daily_summary user_daily_summary_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5173 (class 2606 OID 49943)
-- Name: user_project_mapping user_project_mapping_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5174 (class 2606 OID 49948)
-- Name: user_project_mapping user_project_mapping_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5175 (class 2606 OID 49953)
-- Name: user_project_mapping user_project_mapping_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5176 (class 2606 OID 49958)
-- Name: user_project_mapping user_project_mapping_requested_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_requested_by_user_id_fkey FOREIGN KEY (requested_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5177 (class 2606 OID 49963)
-- Name: user_project_mapping user_project_mapping_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


-- Completed on 2026-10-06 13:12:28

--
-- PostgreSQL database dump complete
--

\unrestrict SIKdg97zV6vtoJdL9W8b8ezQXumKSQ815VQ7qZG2rg0QBE5KJP9CsOAShdKiI0I

