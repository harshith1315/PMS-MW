--
-- PostgreSQL database dump
--

\restrict LkbQgrqJgusoGp9E2Vte7rL5MuAWCDwGvSrEqF9iJ5Apx8VguH6Z6MubKe0Ia2R

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-04-16 11:26:27

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
-- TOC entry 2 (class 3079 OID 28061)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5426 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 245 (class 1259 OID 36252)
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

--
-- TOC entry 220 (class 1259 OID 28072)
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
-- TOC entry 221 (class 1259 OID 28086)
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
-- TOC entry 222 (class 1259 OID 28099)
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
-- TOC entry 244 (class 1259 OID 28755)
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
-- TOC entry 243 (class 1259 OID 28741)
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
-- TOC entry 223 (class 1259 OID 28109)
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
-- TOC entry 224 (class 1259 OID 28127)
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
-- TOC entry 225 (class 1259 OID 28137)
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
-- TOC entry 226 (class 1259 OID 28148)
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
-- TOC entry 227 (class 1259 OID 28166)
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
-- TOC entry 228 (class 1259 OID 28180)
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
-- TOC entry 229 (class 1259 OID 28193)
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
-- TOC entry 230 (class 1259 OID 28201)
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
-- TOC entry 231 (class 1259 OID 28212)
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
-- TOC entry 232 (class 1259 OID 28223)
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
-- TOC entry 233 (class 1259 OID 28233)
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
-- TOC entry 234 (class 1259 OID 28242)
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
-- TOC entry 235 (class 1259 OID 28256)
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
-- TOC entry 236 (class 1259 OID 28269)
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
-- TOC entry 237 (class 1259 OID 28279)
-- Name: task_tag_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_tag_mapping (
    task_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.task_tag_mapping OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 28284)
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
-- TOC entry 239 (class 1259 OID 28300)
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
-- TOC entry 240 (class 1259 OID 28315)
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
-- TOC entry 241 (class 1259 OID 28326)
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
-- TOC entry 242 (class 1259 OID 28339)
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
-- TOC entry 5420 (class 0 OID 36252)
-- Dependencies: 245
-- Data for Name: activity_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_log (id, org_id, actor_user_id, actor_name, actor_email, method, resource_type, resource_id, action_type, message, request_path, ip_address, user_agent, metadata, created_at) FROM stdin;
ea438029-c49d-4d32-a7d4-72fa7445690e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	a6909bd5-59bb-480a-b0a2-d5e33775d45e	USER_PROFILE_UPDATED	Harshith Kanumuri updated profile details for user Sai Eswar Kumar Anupoju (saieswarkumar.anupoju@bonbloc.com).	/users/a6909bd5-59bb-480a-b0a2-d5e33775d45e	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0	{"params": {"id": "a6909bd5-59bb-480a-b0a2-d5e33775d45e"}}	2026-04-14 12:28:38.276265
be773154-e900-434a-94cb-8d859cf1975a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	\N	TASK_CREATED	Harshith Kanumuri created Chat.	/chat/sessions/a45b137a-4017-4921-8fbf-dcea890d67ab/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0	{"params": {"sessionId": "a45b137a-4017-4921-8fbf-dcea890d67ab"}}	2026-04-14 12:30:07.79669
1b36a2d0-86ec-4d18-a0ad-0f6a0f460d0a	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	PATCH	users	a6909bd5-59bb-480a-b0a2-d5e33775d45e	USER_ROLE_UPDATED	Harshith Kanumuri changed role for user Sai Eswar Kumar Anupoju (saieswarkumar.anupoju@bonbloc.com) to MANAGER.	/users/a6909bd5-59bb-480a-b0a2-d5e33775d45e/role	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0	{"params": {"id": "a6909bd5-59bb-480a-b0a2-d5e33775d45e"}}	2026-04-14 12:28:38.490735
72f8b6d0-f044-400b-b4ce-87cb61a2ddaa	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	\N	TASK_CREATED	Harshith Kanumuri created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0	{"params": {}}	2026-04-14 12:29:51.569556
7351b51a-7eb7-4a6d-94a8-9e4b2b7cf1be	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	chat	\N	TASK_CREATED	Harshith Kanumuri created Chat.	/chat/sessions/a45b137a-4017-4921-8fbf-dcea890d67ab/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0	{"params": {"sessionId": "a45b137a-4017-4921-8fbf-dcea890d67ab"}}	2026-04-14 12:30:41.70386
8e6605ed-21a7-42b6-b34e-d78235cb4d3e	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_OUT	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged out.	/auth/logout	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0	\N	2026-04-14 12:27:28.763307
3fc6ad35-5967-4d1a-ba97-23cd39b6c2e0	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_OUT	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged out.	/auth/logout	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0	\N	2026-04-14 12:32:37.609067
96c5fb7b-4e05-4aaf-b9b0-ba69498e4fae	1d105d8b-95d8-411e-9844-b6683e8b7f51	edb1541e-efee-435d-a4cd-6e7da392464a	Harshith Kanumuri	harshith.kanumuri@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Harshith Kanumuri (harshith.kanumuri@bonbloc.com) logged in.	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0	\N	2026-04-14 12:27:46.499405
60d806b8-d14c-4fc6-bfef-ac35f3134ab4	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	auth	\N	USER_LOGGED_IN	Sai Eswar Kumar Anupoju (saieswarkumar.anupoju@bonbloc.com) logged in.	/auth/login	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-04-16 10:40:28.683919
090afd06-ae24-4c32-bb65-4b43ba0744d7	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 10:40:35.380505
1af9205b-884e-49a6-96f1-1ee5647ecc37	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/c0b7e1a4-3052-4917-a164-ab116fb5917d/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "c0b7e1a4-3052-4917-a164-ab116fb5917d"}}	2026-04-16 10:40:38.013245
c4cbcd24-160a-41f2-80f4-f32ac6a84e3b	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/c0b7e1a4-3052-4917-a164-ab116fb5917d/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "c0b7e1a4-3052-4917-a164-ab116fb5917d"}}	2026-04-16 10:40:55.190352
135f39c0-4fe4-4d08-afa1-97994ce84434	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/c0b7e1a4-3052-4917-a164-ab116fb5917d/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "c0b7e1a4-3052-4917-a164-ab116fb5917d"}}	2026-04-16 10:42:27.657227
68d1c6f6-fe3b-4b8a-b89b-6b9ef0827485	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 10:44:29.297227
143a253e-d6f1-4924-b3ed-4eb5b344929e	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/c0b7e1a4-3052-4917-a164-ab116fb5917d/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "c0b7e1a4-3052-4917-a164-ab116fb5917d"}}	2026-04-16 10:44:31.057675
707d83fc-8a4f-4783-8977-3067ebc93b68	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/c0b7e1a4-3052-4917-a164-ab116fb5917d/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "c0b7e1a4-3052-4917-a164-ab116fb5917d"}}	2026-04-16 10:44:40.386709
d8aedbf7-a9c2-4199-9828-b6e6e1d90980	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/c0b7e1a4-3052-4917-a164-ab116fb5917d/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "c0b7e1a4-3052-4917-a164-ab116fb5917d"}}	2026-04-16 10:44:56.180819
59315527-8ea0-4f2d-894a-4bd022d25f55	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/c0b7e1a4-3052-4917-a164-ab116fb5917d/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "c0b7e1a4-3052-4917-a164-ab116fb5917d"}}	2026-04-16 10:45:11.614451
e98ad7ec-66de-46fb-ab51-4e4cfef7802d	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/c0b7e1a4-3052-4917-a164-ab116fb5917d/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "c0b7e1a4-3052-4917-a164-ab116fb5917d"}}	2026-04-16 10:45:25.323193
2261464b-d7c0-4972-8283-1e6be7d8b4ba	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/c0b7e1a4-3052-4917-a164-ab116fb5917d/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "c0b7e1a4-3052-4917-a164-ab116fb5917d"}}	2026-04-16 10:45:43.434079
5d3bbb7d-933d-4f26-9e78-fb6082cf7474	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/c0b7e1a4-3052-4917-a164-ab116fb5917d/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "c0b7e1a4-3052-4917-a164-ab116fb5917d"}}	2026-04-16 10:46:55.785936
317a336f-e4c4-421e-92af-83dc448a5127	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	tasks	594fbc67-ea13-439b-9e47-e1b7cfd64a96	TASK_CREATED	Sai Eswar Kumar Anupoju created "R&D Validation rules".	/tasks/594fbc67-ea13-439b-9e47-e1b7cfd64a96/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"id": "594fbc67-ea13-439b-9e47-e1b7cfd64a96"}}	2026-04-16 10:47:06.370073
5fc5ec90-4d6f-418a-95c8-45a0c0f7e6eb	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	tasks	594fbc67-ea13-439b-9e47-e1b7cfd64a96	TASK_CREATED	Sai Eswar Kumar Anupoju created "R&D Validation rules".	/tasks/594fbc67-ea13-439b-9e47-e1b7cfd64a96/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"id": "594fbc67-ea13-439b-9e47-e1b7cfd64a96"}}	2026-04-16 10:50:54.003384
9432df7b-181c-447b-854e-e7e5da9071d0	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	tasks	594fbc67-ea13-439b-9e47-e1b7cfd64a96	TASK_CREATED	Sai Eswar Kumar Anupoju created "R&D Validation rules".	/tasks/594fbc67-ea13-439b-9e47-e1b7cfd64a96/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"id": "594fbc67-ea13-439b-9e47-e1b7cfd64a96"}}	2026-04-16 10:51:07.002796
13e5494c-7e51-4f43-8c17-0c1203858b78	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	tasks	594fbc67-ea13-439b-9e47-e1b7cfd64a96	TASK_CREATED	Sai Eswar Kumar Anupoju created "R&D Validation rules".	/tasks/594fbc67-ea13-439b-9e47-e1b7cfd64a96/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"id": "594fbc67-ea13-439b-9e47-e1b7cfd64a96"}}	2026-04-16 10:53:30.078153
178f6e63-54a2-4494-a6fe-7364953d21e1	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	tasks	594fbc67-ea13-439b-9e47-e1b7cfd64a96	TASK_CREATED	Sai Eswar Kumar Anupoju created "R&D Validation rules".	/tasks/594fbc67-ea13-439b-9e47-e1b7cfd64a96/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"id": "594fbc67-ea13-439b-9e47-e1b7cfd64a96"}}	2026-04-16 10:55:34.89056
881e8fb1-7f67-40c4-b2f0-fd5877b4c775	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 10:55:41.976055
6bca58fd-1771-4135-bfba-8eaf6f9bcbec	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/058e5373-1bc6-4e0e-a98b-446deebad9e5/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "058e5373-1bc6-4e0e-a98b-446deebad9e5"}}	2026-04-16 10:55:43.393093
c0bb35b3-e4bb-4bb5-acc6-7c7167216225	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/058e5373-1bc6-4e0e-a98b-446deebad9e5/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "058e5373-1bc6-4e0e-a98b-446deebad9e5"}}	2026-04-16 10:55:47.710856
961f90ca-c86f-4d47-91e4-98a774398bb0	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/058e5373-1bc6-4e0e-a98b-446deebad9e5/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "058e5373-1bc6-4e0e-a98b-446deebad9e5"}}	2026-04-16 10:56:04.268286
b0b774fb-af9f-4b5d-9e05-53dc5c3cd269	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/058e5373-1bc6-4e0e-a98b-446deebad9e5/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "058e5373-1bc6-4e0e-a98b-446deebad9e5"}}	2026-04-16 10:56:29.891893
0bd1d1b8-06a6-4e56-9d42-e92f93a3e1d7	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	tasks	594fbc67-ea13-439b-9e47-e1b7cfd64a96	TASK_CREATED	Sai Eswar Kumar Anupoju created "R&D Validation rules".	/tasks/594fbc67-ea13-439b-9e47-e1b7cfd64a96/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"id": "594fbc67-ea13-439b-9e47-e1b7cfd64a96"}}	2026-04-16 10:56:37.140279
57bd6244-963a-4b9b-aa36-fbb0bb93acd3	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	tasks	594fbc67-ea13-439b-9e47-e1b7cfd64a96	TASK_CREATED	Sai Eswar Kumar Anupoju created "R&D Validation rules".	/tasks/594fbc67-ea13-439b-9e47-e1b7cfd64a96/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"id": "594fbc67-ea13-439b-9e47-e1b7cfd64a96"}}	2026-04-16 10:56:48.99531
0d7ebdc8-37f7-4aa3-b576-a80ec35276a0	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 10:57:43.485141
0ab48d8c-6fc0-4b4c-bc16-e7360081235c	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/61cce3b4-1c95-4b68-b822-211c4b9f0961/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "61cce3b4-1c95-4b68-b822-211c4b9f0961"}}	2026-04-16 10:57:45.903235
0bd0e89a-7f12-4b29-a9c0-fe0770e4e55d	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/61cce3b4-1c95-4b68-b822-211c4b9f0961/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "61cce3b4-1c95-4b68-b822-211c4b9f0961"}}	2026-04-16 10:58:05.286496
31cc866a-022c-4086-b147-91a784fc621b	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	tasks	594fbc67-ea13-439b-9e47-e1b7cfd64a96	TASK_CREATED	Sai Eswar Kumar Anupoju created "R&D Validation rules".	/tasks/594fbc67-ea13-439b-9e47-e1b7cfd64a96/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"id": "594fbc67-ea13-439b-9e47-e1b7cfd64a96"}}	2026-04-16 10:58:30.323209
66fba12c-d46d-40ef-bfd5-e58e4efc0a3b	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	tasks	594fbc67-ea13-439b-9e47-e1b7cfd64a96	TASK_CREATED	Sai Eswar Kumar Anupoju created "R&D Validation rules".	/tasks/594fbc67-ea13-439b-9e47-e1b7cfd64a96/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"id": "594fbc67-ea13-439b-9e47-e1b7cfd64a96"}}	2026-04-16 10:58:46.79641
410def9f-c270-4229-834b-e8de2aca7a78	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 11:01:22.361705
6e6a38c7-d6d8-483d-9545-b3db3351e136	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/46138416-5910-4cf9-adf7-1111a1c03994/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "46138416-5910-4cf9-adf7-1111a1c03994"}}	2026-04-16 11:01:24.343539
7e600a41-47b3-49eb-9840-7eb215e11129	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 11:06:42.591319
67f3bca1-3169-4cbd-894f-b5a4eadb3223	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/46138416-5910-4cf9-adf7-1111a1c03994/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "46138416-5910-4cf9-adf7-1111a1c03994"}}	2026-04-16 11:06:44.637794
311b3df5-42a6-4ab8-afea-eb238715be35	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/46138416-5910-4cf9-adf7-1111a1c03994/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "46138416-5910-4cf9-adf7-1111a1c03994"}}	2026-04-16 11:07:36.058231
34887958-a8ac-4996-8613-52d007a815bc	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 11:07:54.729081
2c60aaac-bfa7-440c-95e8-fd68ad6cfcb1	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/cf340bea-3351-4567-9c3d-f9d4c6daf44f/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "cf340bea-3351-4567-9c3d-f9d4c6daf44f"}}	2026-04-16 11:07:58.794643
429b2f9d-f24b-4b09-9d6c-7caa80875b2e	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/cf340bea-3351-4567-9c3d-f9d4c6daf44f/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "cf340bea-3351-4567-9c3d-f9d4c6daf44f"}}	2026-04-16 11:08:22.556044
5b97acff-50d0-4f7f-a3be-1a37eaeda991	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 11:12:32.117644
827a3ac4-4663-4f7b-a894-772d4162873c	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/183604d9-7036-41fd-9d76-ea35d8746bc9/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "183604d9-7036-41fd-9d76-ea35d8746bc9"}}	2026-04-16 11:12:34.332556
6461cbc2-2540-4476-b3a1-90d522936ca4	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/183604d9-7036-41fd-9d76-ea35d8746bc9/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "183604d9-7036-41fd-9d76-ea35d8746bc9"}}	2026-04-16 11:12:50.502023
c592348c-2367-45e0-a0e8-5f8383627f3e	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/183604d9-7036-41fd-9d76-ea35d8746bc9/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "183604d9-7036-41fd-9d76-ea35d8746bc9"}}	2026-04-16 11:14:07.155976
19c1287f-58f4-40a1-865e-4b21b1b0ce64	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/183604d9-7036-41fd-9d76-ea35d8746bc9/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "183604d9-7036-41fd-9d76-ea35d8746bc9"}}	2026-04-16 11:14:32.445039
e68c3133-4ce9-4e11-89cb-9fedb7d3608b	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/183604d9-7036-41fd-9d76-ea35d8746bc9/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "183604d9-7036-41fd-9d76-ea35d8746bc9"}}	2026-04-16 11:14:54.669118
16e3415d-083d-46e8-b14a-d87a072d30b0	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/183604d9-7036-41fd-9d76-ea35d8746bc9/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "183604d9-7036-41fd-9d76-ea35d8746bc9"}}	2026-04-16 11:15:05.888313
21047dcd-5ea9-4c44-924c-74defbe82c4d	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/183604d9-7036-41fd-9d76-ea35d8746bc9/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "183604d9-7036-41fd-9d76-ea35d8746bc9"}}	2026-04-16 11:15:20.616209
cf204bf8-b5da-4b33-a40b-a32c2b68b4a2	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 11:15:46.366926
86cf4190-7c98-469e-aa33-62034d90b74a	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/437d0111-fbb3-4570-aea1-3cd3ed9f0fdb/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "437d0111-fbb3-4570-aea1-3cd3ed9f0fdb"}}	2026-04-16 11:15:47.630844
9a75635b-83a4-4362-bc1a-2973dcd6cda9	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/437d0111-fbb3-4570-aea1-3cd3ed9f0fdb/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "437d0111-fbb3-4570-aea1-3cd3ed9f0fdb"}}	2026-04-16 11:15:53.105058
fc356031-0b3d-4bcd-90b1-5e4adcc09bfb	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/437d0111-fbb3-4570-aea1-3cd3ed9f0fdb/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "437d0111-fbb3-4570-aea1-3cd3ed9f0fdb"}}	2026-04-16 11:15:55.700638
bd6d66c8-ec15-40f6-9243-bbcaf4abee34	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 11:16:12.829487
394d0e4d-a80c-4e9a-b4c2-3dfcdebb5359	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/b78d3a9f-ee0d-453c-85d1-f6757c452222/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "b78d3a9f-ee0d-453c-85d1-f6757c452222"}}	2026-04-16 11:16:15.217309
4813686c-9ba3-4929-ba9a-62f1170bf85f	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/b78d3a9f-ee0d-453c-85d1-f6757c452222/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "b78d3a9f-ee0d-453c-85d1-f6757c452222"}}	2026-04-16 11:16:30.405451
af460e41-be7a-435c-8911-2f9fa9edc6ac	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/b78d3a9f-ee0d-453c-85d1-f6757c452222/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "b78d3a9f-ee0d-453c-85d1-f6757c452222"}}	2026-04-16 11:16:55.437833
10247845-0b9d-4ade-afce-bbd370e28ee1	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/b78d3a9f-ee0d-453c-85d1-f6757c452222/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "b78d3a9f-ee0d-453c-85d1-f6757c452222"}}	2026-04-16 11:17:10.707061
e35731c5-a7a5-484f-abdf-c88b9b8ac842	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 11:17:40.787807
b9170fb7-4956-4d42-bd66-3d38dc78a0f8	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/6fb1552c-7ca8-41f6-9224-2bcc8a454d1f/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "6fb1552c-7ca8-41f6-9224-2bcc8a454d1f"}}	2026-04-16 11:17:42.626944
b28aa426-cbf0-49e0-942e-9d9451edac2d	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/6fb1552c-7ca8-41f6-9224-2bcc8a454d1f/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "6fb1552c-7ca8-41f6-9224-2bcc8a454d1f"}}	2026-04-16 11:18:24.432949
54c568ac-b692-4119-82f0-1c94aee00e95	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/6fb1552c-7ca8-41f6-9224-2bcc8a454d1f/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "6fb1552c-7ca8-41f6-9224-2bcc8a454d1f"}}	2026-04-16 11:18:57.121251
b4e1e9cb-443a-45a8-89cb-9969fa342e79	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/6fb1552c-7ca8-41f6-9224-2bcc8a454d1f/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "6fb1552c-7ca8-41f6-9224-2bcc8a454d1f"}}	2026-04-16 11:19:56.783017
f8959f28-9d67-4d6f-9622-98e8a43a7c9b	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/6fb1552c-7ca8-41f6-9224-2bcc8a454d1f/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "6fb1552c-7ca8-41f6-9224-2bcc8a454d1f"}}	2026-04-16 11:20:23.59985
134c38a0-49fc-4c18-8a77-0ed6bdab0896	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/6fb1552c-7ca8-41f6-9224-2bcc8a454d1f/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "6fb1552c-7ca8-41f6-9224-2bcc8a454d1f"}}	2026-04-16 11:20:33.512009
4cd4df64-1278-41a3-99f8-f6efbd7d046e	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	tasks	594fbc67-ea13-439b-9e47-e1b7cfd64a96	TASK_CREATED	Sai Eswar Kumar Anupoju created "R&D Validation rules".	/tasks/594fbc67-ea13-439b-9e47-e1b7cfd64a96/summarize	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"id": "594fbc67-ea13-439b-9e47-e1b7cfd64a96"}}	2026-04-16 11:20:52.480092
baf46f78-6f96-4224-9463-8a7af1e95fa7	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 11:22:38.741913
a93bae02-bbc5-487a-b9ad-de9dab250085	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/93798317-c754-4076-b26c-55518aec8b94/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "93798317-c754-4076-b26c-55518aec8b94"}}	2026-04-16 11:22:40.309322
b8d70951-05c1-4c6a-aebd-e69554bdd13b	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/93798317-c754-4076-b26c-55518aec8b94/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "93798317-c754-4076-b26c-55518aec8b94"}}	2026-04-16 11:22:47.406789
7d6b5305-a165-49e1-b641-a2d707d48b3e	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/93798317-c754-4076-b26c-55518aec8b94/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "93798317-c754-4076-b26c-55518aec8b94"}}	2026-04-16 11:23:47.786898
66cb84a2-2495-4f5f-bb38-9d5959760f97	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 11:23:53.640642
bd6da1c2-5ecb-43b9-b6fc-3b23361b05aa	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/f223591c-9a40-4f4f-a596-7c1d69f0c5a7/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "f223591c-9a40-4f4f-a596-7c1d69f0c5a7"}}	2026-04-16 11:23:55.542534
1a0ea071-a78c-4e01-8db7-1a40e2499b36	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/f223591c-9a40-4f4f-a596-7c1d69f0c5a7/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "f223591c-9a40-4f4f-a596-7c1d69f0c5a7"}}	2026-04-16 11:23:58.976808
a0bd811b-9854-4922-8840-617c51f0a099	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/f223591c-9a40-4f4f-a596-7c1d69f0c5a7/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "f223591c-9a40-4f4f-a596-7c1d69f0c5a7"}}	2026-04-16 11:24:34.823899
b9dc371a-cc19-4f43-9d8b-c903876ca621	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/f223591c-9a40-4f4f-a596-7c1d69f0c5a7/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "f223591c-9a40-4f4f-a596-7c1d69f0c5a7"}}	2026-04-16 11:24:37.952437
4f08fc22-1c03-4543-a9c7-0e83cc2bfd74	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {}}	2026-04-16 11:24:41.558551
4e15250e-c483-4d2b-9dce-e5dc2d87fd73	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/e6ab7151-42df-4c0b-86bb-83402e7ee736/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "e6ab7151-42df-4c0b-86bb-83402e7ee736"}}	2026-04-16 11:24:42.642546
dcb271ee-1f4c-483f-b811-44e461b4ca0c	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/e6ab7151-42df-4c0b-86bb-83402e7ee736/messages	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "e6ab7151-42df-4c0b-86bb-83402e7ee736"}}	2026-04-16 11:24:45.85324
57c7d7f1-7296-4538-8851-6a031a583df8	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Sai Eswar Kumar Anupoju	saieswarkumar.anupoju@bonbloc.com	POST	chat	\N	TASK_CREATED	Sai Eswar Kumar Anupoju created Chat.	/chat/sessions/e6ab7151-42df-4c0b-86bb-83402e7ee736/end	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"params": {"sessionId": "e6ab7151-42df-4c0b-86bb-83402e7ee736"}}	2026-04-16 11:24:53.48882
\.


--
-- TOC entry 5395 (class 0 OID 28072)
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
edb1541e-efee-435d-a4cd-6e7da392464a	1d105d8b-95d8-411e-9844-b6683e8b7f51	harshith.kanumuri@bonbloc.com	Harshith Kanumuri	ORG_ADMIN	t	t	ACTIVE	2026-03-26 22:48:28.989947
1400ccae-fcaa-452d-9d61-30afb052b604	1d105d8b-95d8-411e-9844-b6683e8b7f51	komali.avirneni@bonbloc.com	komali.avirneni	MANAGER	f	f	ACTIVE	2026-04-01 11:45:59.188686
d4c27066-b249-42ef-ac9d-bccbd7cced4e	1d105d8b-95d8-411e-9844-b6683e8b7f51	test@gmail.com	sai ram	MANAGER	t	t	DEACTIVATED	2026-03-26 23:56:13.01749
e8f598e6-df54-46ee-bf25-ccadaee8681c	1d105d8b-95d8-411e-9844-b6683e8b7f51	harshith@example.com	Kanumuri Harshith	USER	t	t	DEACTIVATED	2026-04-07 18:31:21.344863
57617275-688c-4353-9faa-b561834044d8	1d105d8b-95d8-411e-9844-b6683e8b7f51	sairam.mathi@bonbloc.com	sai ram	MANAGER	t	t	ACTIVE	2026-04-09 22:16:51.949285
6d7b3010-5f27-4495-b7b1-85d6f734657f	1d105d8b-95d8-411e-9844-b6683e8b7f51	pranathi@bonbloc.com	Pranathi	USER	t	t	DEACTIVATED	2026-03-26 23:01:27.496598
011e345e-7736-44cb-82c5-f3ebac81971e	1d105d8b-95d8-411e-9844-b6683e8b7f51	krishnapranathi.dande@bonbloc.com	Krishna Pranathi	MANAGER	t	t	ACTIVE	2026-04-09 22:17:52.654766
a6909bd5-59bb-480a-b0a2-d5e33775d45e	1d105d8b-95d8-411e-9844-b6683e8b7f51	saieswarkumar.anupoju@bonbloc.com	Sai Eswar Kumar Anupoju	ORG_ADMIN	f	f	ACTIVE	2026-04-10 11:43:32.387661
fbfbe066-9918-412c-835d-f92a30ac44e4	1d105d8b-95d8-411e-9844-b6683e8b7f51	narayanareddy.mallidi@bonbloc.com	Narayana	ORG_ADMIN	t	t	ACTIVE	2026-03-27 10:02:54.511576
\.


--
-- TOC entry 5396 (class 0 OID 28086)
-- Dependencies: 221
-- Data for Name: attachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attachment (id, org_id, task_id, file_name, file_type, file_size, s3_key, uploaded_by, status, created_at) FROM stdin;
0b432db8-80e5-4f85-a370-609448813852	1d105d8b-95d8-411e-9844-b6683e8b7f51	86d4af01-800a-435d-ac7c-d4594c1f495b	Screenshot 2026-03-28 135646.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/86d4af01-800a-435d-ac7c-d4594c1f495b/83071b02-a25f-4221-bd47-b11516a8e4da.png	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-28 14:11:59.09885
\.


--
-- TOC entry 5397 (class 0 OID 28099)
-- Dependencies: 222
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
-- TOC entry 5419 (class 0 OID 28755)
-- Dependencies: 244
-- Data for Name: chat_message; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_message (id, session_id, role, text, created_at) FROM stdin;
53715cf9-5031-4e14-929f-27618a3ff141	46138416-5910-4cf9-adf7-1111a1c03994	user	How many tasks are assigned to me this week?	2026-04-16 11:01:24.318175+05:30
638e7801-16a9-4b07-9431-e97b504bad1c	46138416-5910-4cf9-adf7-1111a1c03994	assistant	Sai, you have one task assigned to you this week.	2026-04-16 11:01:24.318175+05:30
13b5402e-6731-4228-b8e5-1d41123c6103	cf340bea-3351-4567-9c3d-f9d4c6daf44f	user	List projects in progress and group by owner.	2026-04-16 11:07:58.766648+05:30
504634d5-ee6e-43b4-99bb-34fe6a05f0b4	cf340bea-3351-4567-9c3d-f9d4c6daf44f	assistant	Sai, here are the active projects grouped by manager:\n\n**Princy:**\n- LMS (PROJ_101)\n\n**Jane:**\n- API Integration (API)\n- Website Redesign (WEB)\n- Mobile App Development (MOB)\n\n**Alicia:**\n- COld Chain (PROJ-123)\n- FPO (FPO-101)\n\n**Harshith Kanumuri:**\n- LMS-PH (PROJ-1237)\n- test (PROJ-1235)\n\n**Narayana:**\n- LMS (PROJ-1236)\n\n**Pranathi:**\n- CEL (PROJ-1234)	2026-04-16 11:07:58.766648+05:30
ac7b481f-b970-4fc9-b74a-210fed7a223c	183604d9-7036-41fd-9d76-ea35d8746bc9	assistant	There is no information available regarding active users in the provided data.	2026-04-16 11:12:50.482552+05:30
94b685de-0f6a-4b63-b5f0-cbc84731910b	183604d9-7036-41fd-9d76-ea35d8746bc9	user	users list	2026-04-16 11:14:07.099918+05:30
172c534d-2349-4eb1-b8cf-8022fd981758	183604d9-7036-41fd-9d76-ea35d8746bc9	assistant	Sai, here is the list of active users on the platform:\n\n- Alice (developer1@acme.com)\n- Alicia (alicia.antony@bonbloc.com)\n- Bob (developer2@acme.com)\n- Charlie (qa@acme.com)\n- Harshith Kanumuri (harshith.kanumuri@bonbloc.com)\n- Jane (manager@acme.com)\n- komali.avirneni (komali.avirneni@bonbloc.com)\n- Krishna Pranathi (krishnapranathi.dande@bonbloc.com)\n- Narayana (narayanareddy.mallidi@bonbloc.com)\n- princy (princy.joseph@bonbloc.com)\n- Sai Eswar Kumar Anupoju (saieswarkumar.anupoju@bonbloc.com)\n- sai ram (sairam.mathi@bonbloc.com)\n- Santhosh (santhosh.sankar@bonbloc.com)	2026-04-16 11:14:07.099918+05:30
daf61bb7-b8bb-4eb8-93d0-e856e2606efa	183604d9-7036-41fd-9d76-ea35d8746bc9	user	can you tell me the their roles	2026-04-16 11:14:32.4113+05:30
a6d54b51-8078-4866-b952-5de7e4eb2339	183604d9-7036-41fd-9d76-ea35d8746bc9	assistant	Sai, here are the roles of the active users on the platform:\n\n- Alice: Developer\n- Alicia: Project Manager\n- Bob: Designer\n- Charlie: QA Tester\n- David: Business Analyst	2026-04-16 11:14:32.4113+05:30
06819da4-7fd1-4852-97dc-d99cd19b0739	183604d9-7036-41fd-9d76-ea35d8746bc9	user	reamining?	2026-04-16 11:14:54.635871+05:30
d047436d-8bcc-4d04-9e76-9040e31f7597	183604d9-7036-41fd-9d76-ea35d8746bc9	assistant	Sai, here are the roles of the remaining active users on the platform:\n\n- Bob: Designer\n- Charlie: QA Tester\n- Dana: Business Analyst	2026-04-16 11:14:54.635871+05:30
d821351f-80d8-4de8-85e7-b9ea0de64ca7	183604d9-7036-41fd-9d76-ea35d8746bc9	user	i want all	2026-04-16 11:15:05.856067+05:30
c6fb9cea-7ee6-4355-ae77-6ae975a7058d	183604d9-7036-41fd-9d76-ea35d8746bc9	assistant	Sai, here are the roles of all active users on the platform:\n\n- Alice: Developer\n- Alicia: Project Manager\n- Bob: Designer\n- Charlie: QA Tester\n- Dana: Business Analyst	2026-04-16 11:15:05.856067+05:30
16ecada9-fb2e-408a-b69d-adc09adca2d2	437d0111-fbb3-4570-aea1-3cd3ed9f0fdb	user	hi	2026-04-16 11:15:47.60535+05:30
3c14acfe-90dd-40e9-a5e5-afd4d4507176	437d0111-fbb3-4570-aea1-3cd3ed9f0fdb	assistant	Hello, Sai. How can I assist you today?	2026-04-16 11:15:47.60535+05:30
e9d75259-b2a9-4f4b-8e3b-35cae22a4a9b	437d0111-fbb3-4570-aea1-3cd3ed9f0fdb	user	byee	2026-04-16 11:15:53.089992+05:30
3c038d4f-cda8-451d-b013-6ac779aa28e1	437d0111-fbb3-4570-aea1-3cd3ed9f0fdb	assistant	Goodbye, Sai.	2026-04-16 11:15:53.089992+05:30
07ad7af6-50ab-4fd6-bf12-7612498bda5f	b78d3a9f-ee0d-453c-85d1-f6757c452222	user	i want to konw about this platfrom expalin	2026-04-16 11:16:15.199041+05:30
86588d65-0e73-49eb-a83d-0f1ac457db34	b78d3a9f-ee0d-453c-85d1-f6757c452222	assistant	Sai, this platform is designed to assist with project management tasks. Currently, you have one assigned task related to R&D Validation rules. The status of this task is "TODO," it has a medium priority, and there is no deadline set. If you need more specific information or assistance, feel free to ask.	2026-04-16 11:16:15.199041+05:30
043cfcd5-7473-412d-adcd-a014905de881	b78d3a9f-ee0d-453c-85d1-f6757c452222	user	what are the timesheets?	2026-04-16 11:16:30.37924+05:30
e9286a72-81a2-4a2c-aba0-8f4c6775a92a	b78d3a9f-ee0d-453c-85d1-f6757c452222	assistant	Sai, this platform is designed to help manage projects efficiently. Timesheets are tools used to track the amount of time spent on various tasks or projects. They help in monitoring productivity, managing resources, and ensuring that project timelines are adhered to.	2026-04-16 11:16:30.37924+05:30
2b60dddc-1bda-451c-b957-0283aa24ac85	b78d3a9f-ee0d-453c-85d1-f6757c452222	user	team timesheets?	2026-04-16 11:16:55.414375+05:30
cf877cde-b6de-4f73-8393-6d247273a8d1	b78d3a9f-ee0d-453c-85d1-f6757c452222	assistant	Timesheets are tools used to track the amount of time team members spend on various tasks or projects. They help in monitoring productivity, managing resources, and ensuring that project timelines are adhered to. Team timesheets specifically refer to the collective tracking of time for all members within a team, allowing for better coordination and accountability.	2026-04-16 11:16:55.414375+05:30
8adb717b-bcb2-4f1c-b6b8-56309919690e	6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	user	who are you	2026-04-16 11:17:42.614131+05:30
ea7a0415-de37-4ece-b3ea-3fe0bd11bee0	6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	assistant	Hello, Sai. I am Myra, your concise AI assistant for the Project Management System. \n\nYou have one assigned task:\n- R&D Validation rules \n  - Status: TODO \n  - Priority: MEDIUM \n  - Deadline: Not set	2026-04-16 11:17:42.614131+05:30
708c5140-ad2b-4992-808c-3d667fefaf19	6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	user	who can i change the role of a user	2026-04-16 11:18:24.419553+05:30
51a1226a-7643-41ad-bc03-370505f8fa59	6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	assistant	You can change the role of a user through the user management section of the Project Management System. Look for the user you want to modify, and there should be an option to edit their role. If you need further assistance, please specify the system you are using.	2026-04-16 11:18:24.419553+05:30
3a9c3911-309f-42d8-bb91-a1757f35cd05	6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	user	how to add a project	2026-04-16 11:18:57.10517+05:30
f293ce09-270e-4284-9831-c3775b469193	6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	assistant	To add a project, navigate to the project management section of the system and look for the option to create or add a new project. You will need to provide details such as the project name, business unit, status, and manager. Follow the prompts to complete the process.	2026-04-16 11:18:57.10517+05:30
de1701ad-53e8-4154-876b-dfce2c0f30c8	6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	user	can you assist for creating project step by step so it would be clear	2026-04-16 11:19:56.75704+05:30
db262abb-b738-4e54-bd04-df947596eacf	93798317-c754-4076-b26c-55518aec8b94	user	who are you	2026-04-16 11:22:40.298051+05:30
82d7cf12-1f4d-491f-aeee-46fb35cf25f8	93798317-c754-4076-b26c-55518aec8b94	assistant	Hello, Sai. I am Myra, your concise AI assistant for the Project Management System. How can I assist you today?	2026-04-16 11:22:40.298051+05:30
00b037dd-94ed-4718-94e9-668dc12bca97	93798317-c754-4076-b26c-55518aec8b94	user	bye	2026-04-16 11:22:47.377711+05:30
c9c25ab4-69eb-47e9-b4bd-1156dbd981a9	61cce3b4-1c95-4b68-b822-211c4b9f0961	user	Create a sprint summary with blockers.	2026-04-16 10:57:45.88118+05:30
855db6ff-3bb1-413d-849c-16ae856d74ae	61cce3b4-1c95-4b68-b822-211c4b9f0961	assistant	Sai, here is the sprint summary:\n\n**Assigned Task:**\n- R&D Validation rules  \n  - Status: TODO  \n  - Priority: MEDIUM  \n  - Deadline: Not set  \n\n**Blockers:**  \n- No blockers identified at this time.	2026-04-16 10:57:45.88118+05:30
90bb493a-f87c-4979-8e72-1a34a1aef8b3	46138416-5910-4cf9-adf7-1111a1c03994	user	who are the active users	2026-04-16 11:06:44.603998+05:30
9d69d8da-d1d1-4bd7-b3bd-39e6ea16119b	46138416-5910-4cf9-adf7-1111a1c03994	assistant	Sai, you have one task assigned to you this week. \n\n- R&D Validation rules \n  - Status: TODO \n  - Priority: MEDIUM \n  - Deadline: Not set	2026-04-16 11:06:44.603998+05:30
b552f10f-45fd-4069-844f-6798e5a82954	183604d9-7036-41fd-9d76-ea35d8746bc9	user	who are the active users	2026-04-16 11:12:34.317605+05:30
683f9a47-4494-407f-89ce-b57858a0d339	183604d9-7036-41fd-9d76-ea35d8746bc9	assistant	Sai, there is no information available regarding active users in the provided data.	2026-04-16 11:12:34.317605+05:30
1a8ac84a-c3d4-4d4a-84fc-67c763898e1c	183604d9-7036-41fd-9d76-ea35d8746bc9	user	active users of the this platform	2026-04-16 11:12:50.482552+05:30
048d101e-d7f8-4afa-9737-c295c0dfd8e6	6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	assistant	Sai, to create a project step by step:\n\n1. **Navigate to Project Management**: Access the project management section of the system.\n2. **Select 'Create Project'**: Look for the option to create or add a new project.\n3. **Fill in Project Details**: Enter the project name, code, business unit, status, and manager.\n4. **Set Project Parameters**: Define any additional parameters or requirements for the project.\n5. **Review and Confirm**: Check all entered information for accuracy.\n6. **Submit**: Save or submit the project to finalize its creation.\n\nFollow these steps to successfully add a new project.	2026-04-16 11:19:56.75704+05:30
d2712914-02a2-4843-94b5-6706784dcbea	6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	user	how do reports work	2026-04-16 11:20:23.579194+05:30
e3e09786-12a4-421c-942e-9173dae67959	6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	assistant	Reports in the Project Management System provide insights into project progress, resource allocation, and task completion. They typically include:\n\n- **Status Reports**: Overview of project status, including completed and pending tasks.\n- **Resource Reports**: Details on resource utilization and availability.\n- **Performance Metrics**: Key performance indicators to assess project health.\n\nYou can generate reports based on specific criteria or timeframes to analyze project performance effectively.	2026-04-16 11:20:23.579194+05:30
4dc3a8af-ca0b-41d2-91fa-26c91820b72c	93798317-c754-4076-b26c-55518aec8b94	assistant	Good to see you, Sai. How can I assist you today?	2026-04-16 11:22:47.377711+05:30
a4bd2734-657e-4675-9521-5ffa973e12cd	f223591c-9a40-4f4f-a596-7c1d69f0c5a7	user	hi	2026-04-16 11:23:55.530222+05:30
516cf3c1-384a-474a-a2d0-2f7895bc4efe	f223591c-9a40-4f4f-a596-7c1d69f0c5a7	assistant	Hello, Sai. How can I assist you today?	2026-04-16 11:23:55.530222+05:30
80859ad1-4842-4117-bd78-7476d21dae85	f223591c-9a40-4f4f-a596-7c1d69f0c5a7	user	bye	2026-04-16 11:23:58.968023+05:30
2c698909-acbc-4cf3-a01c-e564beb1acfc	f223591c-9a40-4f4f-a596-7c1d69f0c5a7	assistant	Good day, Sai. How can I assist you today?	2026-04-16 11:23:58.968023+05:30
a83910d1-35e0-4193-9250-6f2440eba146	f223591c-9a40-4f4f-a596-7c1d69f0c5a7	user	bye	2026-04-16 11:24:34.798961+05:30
e9f5011b-f488-4089-9866-d3376793697f	f223591c-9a40-4f4f-a596-7c1d69f0c5a7	assistant	Goodbye, Sai! Wishing you a productive day ahead—take care!	2026-04-16 11:24:34.798961+05:30
b898e116-1752-4dd5-97f1-1e3369f95f3e	e6ab7151-42df-4c0b-86bb-83402e7ee736	user	hi	2026-04-16 11:24:42.634426+05:30
8945ddb1-e146-4ce6-88af-549b8c2f0d1e	e6ab7151-42df-4c0b-86bb-83402e7ee736	assistant	Hello, Sai. How can I assist you today?	2026-04-16 11:24:42.634426+05:30
88c03fbb-5ece-47b3-a847-2edd7f8b101e	e6ab7151-42df-4c0b-86bb-83402e7ee736	user	bye	2026-04-16 11:24:45.844919+05:30
46d43195-d0ae-4d15-919e-0a8d9992ca3a	e6ab7151-42df-4c0b-86bb-83402e7ee736	assistant	Goodbye, Sai! Wishing you a productive day ahead. Take care!	2026-04-16 11:24:45.844919+05:30
\.


--
-- TOC entry 5418 (class 0 OID 28741)
-- Dependencies: 243
-- Data for Name: chat_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_session (id, org_id, user_id, title, started_at, ended_at) FROM stdin;
cf340bea-3351-4567-9c3d-f9d4c6daf44f	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	List projects in progress and group by owner.	2026-04-16 11:07:54.688882+05:30	2026-04-16 11:08:22.366+05:30
183604d9-7036-41fd-9d76-ea35d8746bc9	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	who are the active users	2026-04-16 11:12:32.098726+05:30	2026-04-16 11:15:20.436+05:30
437d0111-fbb3-4570-aea1-3cd3ed9f0fdb	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-16 11:15:46.337904+05:30	2026-04-16 11:15:55.621+05:30
b78d3a9f-ee0d-453c-85d1-f6757c452222	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	i want to konw about this platfrom expalin	2026-04-16 11:16:12.808182+05:30	2026-04-16 11:17:10.563+05:30
6fb1552c-7ca8-41f6-9224-2bcc8a454d1f	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	who are you	2026-04-16 11:17:40.771098+05:30	2026-04-16 11:20:33.356+05:30
61cce3b4-1c95-4b68-b822-211c4b9f0961	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	Create a sprint summary with blockers.	2026-04-16 10:57:43.456772+05:30	2026-04-16 10:58:05.096+05:30
93798317-c754-4076-b26c-55518aec8b94	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	who are you	2026-04-16 11:22:38.712104+05:30	2026-04-16 11:23:47.752+05:30
46138416-5910-4cf9-adf7-1111a1c03994	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	How many tasks are assigned to me this week?	2026-04-16 11:01:22.339253+05:30	2026-04-16 11:07:35.947+05:30
f223591c-9a40-4f4f-a596-7c1d69f0c5a7	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-16 11:23:53.632278+05:30	2026-04-16 11:24:37.841+05:30
e6ab7151-42df-4c0b-86bb-83402e7ee736	1d105d8b-95d8-411e-9844-b6683e8b7f51	a6909bd5-59bb-480a-b0a2-d5e33775d45e	hi	2026-04-16 11:24:41.510894+05:30	2026-04-16 11:24:53.427+05:30
\.


--
-- TOC entry 5398 (class 0 OID 28109)
-- Dependencies: 223
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, recipient_id, task_id, type, title, message, metadata, is_read, created_at, updated_at) FROM stdin;
7454bc41-0d36-44a3-b9e7-a2523e8bc19a	b762cce3-dac1-4aa0-bc38-a8488eaf994f	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	TASK_BLOCKED	Task Blocked	Task "Login Page" has been blocked by Harshith Kanumuri	{"taskCode": "PROJ-1237-1", "blockedBy": "edb1541e-efee-435d-a4cd-6e7da392464a", "taskTitle": "Login Page", "blockerName": "Harshith Kanumuri"}	f	2026-04-09 17:53:36.587035	2026-04-09 17:53:36.587035
9df09bb7-e20f-49b1-b783-387ea30a507e	b762cce3-dac1-4aa0-bc38-a8488eaf994f	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	TASK_BLOCKED	Task Blocked	Task "Login Page" has been blocked by Harshith Kanumuri	{"taskCode": "PROJ-1237-1", "blockedBy": "edb1541e-efee-435d-a4cd-6e7da392464a", "taskTitle": "Login Page", "blockerName": "Harshith Kanumuri"}	f	2026-04-09 22:20:04.128823	2026-04-09 22:20:04.128823
e054f494-918e-41cf-afcc-1141805901d3	b762cce3-dac1-4aa0-bc38-a8488eaf994f	f4f24c97-5673-4ffc-a5af-d7fc2d4e9aa3	TASK_BLOCKED	Task Blocked	Task "Login Page" has been blocked by Harshith Kanumuri	{"taskCode": "PROJ-1237-1", "blockedBy": "edb1541e-efee-435d-a4cd-6e7da392464a", "taskTitle": "Login Page", "blockerName": "Harshith Kanumuri"}	f	2026-04-09 22:22:00.232744	2026-04-09 22:22:00.232744
\.


--
-- TOC entry 5399 (class 0 OID 28127)
-- Dependencies: 224
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization (id, name, azure_tenant_id, status, created_at) FROM stdin;
1d105d8b-95d8-411e-9844-b6683e8b7f51	BONbLOC Technologies	7915d0a8-0a13-4824-ba52-43a1ad694c42	ACTIVE	2026-03-19 14:23:34.808615
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Acme Corporation	null	ACTIVE	2026-03-18 20:14:20.339403
\.


--
-- TOC entry 5400 (class 0 OID 28137)
-- Dependencies: 225
-- Data for Name: platform_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.platform_user (id, email, name, role, status, created_at) FROM stdin;
d2c3a954-c0f7-4718-92be-e97449206874	oviiyadominic@gmail.com	Oviiya Dominic	ADMIN	ACTIVE	2026-03-19 14:28:31.763376
\.


--
-- TOC entry 5401 (class 0 OID 28148)
-- Dependencies: 226
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
-- TOC entry 5402 (class 0 OID 28166)
-- Dependencies: 227
-- Data for Name: project_cost; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_cost (id, org_id, project_id, cost_type, amount, description, cost_date, status, created_at) FROM stdin;
\.


--
-- TOC entry 5403 (class 0 OID 28180)
-- Dependencies: 228
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
-- TOC entry 5404 (class 0 OID 28193)
-- Dependencies: 229
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
-- TOC entry 5405 (class 0 OID 28201)
-- Dependencies: 230
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
-- TOC entry 5406 (class 0 OID 28212)
-- Dependencies: 231
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
-- TOC entry 5407 (class 0 OID 28223)
-- Dependencies: 232
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
e6e582cb-6487-4bcd-a8db-a782e3de2f29	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	S3	2026-04-10	2026-04-16	PLANNED	2026-04-10 00:33:49.936718	test	\N
5a519088-1bbf-4d6e-8960-f3c62bb9e851	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	S4	2026-04-09	2026-04-10	PLANNED	2026-04-10 00:39:35.848874	test	\N
\.


--
-- TOC entry 5408 (class 0 OID 28233)
-- Dependencies: 233
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
-- TOC entry 5409 (class 0 OID 28242)
-- Dependencies: 234
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
c5b77141-3868-4b1b-849a-e9ffd1e5b4a4	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	\N	PROJ-1237-3	R&D Animation for login page	\N	SUB_TASK	IN_PROGRESS	HIGH	edb1541e-efee-435d-a4cd-6e7da392464a	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-31	2026-03-28 14:10:32.206133	\N	\N	2026-04-09 22:23:00.283604	\N	\N
1a9422aa-2e12-4253-ad11-edb74af5926e	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	\N	PROJ-1237-5	Tenant Configuration	<p>As an admin, I want to configure tenant-specific settings so that each tenant can customize their usage and limits as per requirements.&nbsp;</p><p>Tasks:&nbsp;</p><ul><li><p>Implement validation rules for configuration inputs.&nbsp;</p></li></ul><ul><li><p>Build frontend UI form for managing configuration.&nbsp;</p></li></ul><p></p>	STORY	TODO	MEDIUM	edb1541e-efee-435d-a4cd-6e7da392464a	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-14	2026-04-09 22:59:56.122202	\N	\N	2026-04-10 00:24:20.895069	e8a7a8f2-9bf5-4cfa-9f57-127667fa51ca	\N
f393b18f-a52f-47ef-96cd-76ac61dc4033	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-7	R&D	<p>R&amp;D</p>	SUB_TASK	TODO	MEDIUM	\N	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-16	2026-04-09 23:01:33.978349	\N	\N	2026-04-09 23:01:33.978349	\N	\N
86d4af01-800a-435d-ac7c-d4594c1f495b	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-2	Registration Page	\N	TASK	IN_REVIEW	MEDIUM	fbfbe066-9918-412c-835d-f92a30ac44e4	edb1541e-efee-435d-a4cd-6e7da392464a	2026-03-31	2026-03-27 16:55:49.638554	LOGIN PAGE	\N	2026-04-10 00:23:26.635659	\N	\N
e8a7a8f2-9bf5-4cfa-9f57-127667fa51ca	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-4	Tenant Management/platform	<p><span style="color: rgb(41, 42, 46);">This epic covers the implementation of multi-tenant architecture for the LMS platform. It includes tenant creation, tenant configuration, tenant switching, and database isolation to ensure each organization can securely use the system independently with its own data and settings.</span></p>	EPIC	TODO	MEDIUM	edb1541e-efee-435d-a4cd-6e7da392464a	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-16	2026-04-09 22:57:29.351302	\N	\N	2026-04-10 00:24:20.895069	\N	\N
1c71d85b-0504-4f31-9a26-14e8117ccc0f	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-6	Implement validation rules for configuration inputs	<p>Configure</p>	TASK	TODO	MEDIUM	edb1541e-efee-435d-a4cd-6e7da392464a	edb1541e-efee-435d-a4cd-6e7da392464a	2026-04-16	2026-04-09 23:00:52.207975	\N	\N	2026-04-10 00:24:20.895069	e8a7a8f2-9bf5-4cfa-9f57-127667fa51ca	1a9422aa-2e12-4253-ad11-edb74af5926e
594fbc67-ea13-439b-9e47-e1b7cfd64a96	1d105d8b-95d8-411e-9844-b6683e8b7f51	10ac6760-95d0-4f5d-acb5-52126ff0c7e1	4343a450-7655-41c0-835a-7bba93cc7aeb	PROJ-1237-8	R&D Validation rules	<p>R&amp;D</p>	SUB_TASK	TODO	MEDIUM	a6909bd5-59bb-480a-b0a2-d5e33775d45e	edb1541e-efee-435d-a4cd-6e7da392464a	\N	2026-04-09 23:12:26.30255	\N	\N	2026-04-10 12:45:10.361681	\N	\N
\.


--
-- TOC entry 5410 (class 0 OID 28256)
-- Dependencies: 235
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
-- TOC entry 5411 (class 0 OID 28269)
-- Dependencies: 236
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
-- TOC entry 5412 (class 0 OID 28279)
-- Dependencies: 237
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
\.


--
-- TOC entry 5413 (class 0 OID 28284)
-- Dependencies: 238
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
-- TOC entry 5414 (class 0 OID 28300)
-- Dependencies: 239
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
-- TOC entry 5415 (class 0 OID 28315)
-- Dependencies: 240
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
-- TOC entry 5416 (class 0 OID 28326)
-- Dependencies: 241
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
c7410d76-f191-4c36-8e6b-86175678aee5	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_ORGANIZATION	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
f237c9d3-15eb-45ed-b395-2a0f105e9b81	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_ORGANIZATION	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
b26e57ae-0131-4c0f-b20f-f813c11304a4	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_ORGANIZATION	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
39a28cd0-1b8a-48ca-b86a-a032dfd9bae7	e8f598e6-df54-46ee-bf25-ccadaee8681c	MANAGE_USERS	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
76f8e67a-de18-4e1d-8d64-a26705ff02b8	e8f598e6-df54-46ee-bf25-ccadaee8681c	MANAGE_BUSINESS_UNITS	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
20a8c8d6-370e-41a1-9ee0-7af7ad9b10bc	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_BUSINESS_UNIT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
672d3ee8-62e9-464f-8c23-29b84ed7740d	e8f598e6-df54-46ee-bf25-ccadaee8681c	CREATE_BUSINESS_UNIT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
3b62a55e-5abe-4d7c-837b-ff954dcf20b1	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_BUSINESS_UNIT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
6992e3f9-7f48-4529-9bd2-a2c75898e913	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_BUSINESS_UNIT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
683d3ab1-cd30-480b-8fdc-741e4f96f040	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_USER	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
71114ac5-a3f4-49b2-a69e-ff7924563b68	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_USER	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
6bfeb972-6b07-4c4e-9c26-0a2a95260037	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_USER_ROLE	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
3f837f3a-97b6-4454-b095-4cf46ce8a730	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_USER_STATUS	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
ad0ed61b-f3b5-4f71-b3f7-fee733263dc1	e8f598e6-df54-46ee-bf25-ccadaee8681c	CREATE_PROJECT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
0b2cc5a4-6bdc-44f7-83ce-147862f25e14	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_PROJECT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
232c4e19-70b9-43c2-836a-20360de44d21	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_PROJECT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
a9d6e4ba-cfb3-4d25-9366-a02c405a46d5	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_PROJECT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
a09d57e4-e29c-42e7-a165-cfff421b3ec2	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_PROJECT_DETAILS	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
bed4b120-19a2-4b0e-a0fe-069d85e9b996	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_PROJECT_DETAILS	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
3017c10c-da60-406a-afea-09244630ae6c	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_TECH_STACK	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
5cfc5c6a-56ab-40d5-8cc2-ef34f62d586f	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_DEPENDENCIES	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
f505861b-075a-465f-b57c-ff42c81fc1f3	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_BUDGET	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
0b165031-7a68-4e07-b97d-665d912e8e55	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_FINANCE	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
6432dccc-78cd-4d0e-90e1-65b8664078a8	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_FINANCE_CODE	f	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
93789ace-2bee-47ad-ada6-a354024729b2	e8f598e6-df54-46ee-bf25-ccadaee8681c	CREATE_TASK	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
d3049db1-c482-46fb-819a-3d948cb92dc9	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_TASK	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
0e8256d5-cd2e-4022-bf89-bfa124dce4df	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_TASK	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
bfc11813-2a21-4a39-a648-0669a2bbadf9	e8f598e6-df54-46ee-bf25-ccadaee8681c	CREATE_COMMENT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
3395b537-78fe-43d4-86b6-6fc1a4582b80	e8f598e6-df54-46ee-bf25-ccadaee8681c	EDIT_COMMENT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
f0a0b1b6-87cc-4b2d-9bda-67127521c83f	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_COMMENT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
c7a901f5-c2f9-4cde-bc4a-1a7c394b9fb0	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_ATTACHMENT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
048ef01b-e4aa-4bfe-8173-7d7664815dee	e8f598e6-df54-46ee-bf25-ccadaee8681c	CREATE_ATTACHMENT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
b20b3f3a-6150-4a24-ac39-15123776edc9	e8f598e6-df54-46ee-bf25-ccadaee8681c	DELETE_ATTACHMENT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
eca83a37-61d1-489c-a6d3-c9b7df093072	e8f598e6-df54-46ee-bf25-ccadaee8681c	MANAGE_SPRINT	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
82977cf2-45f8-44d6-aac3-215bd6656812	e8f598e6-df54-46ee-bf25-ccadaee8681c	MANAGE_LINKS	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
a2137e3f-cbf6-4b7f-9048-2a3a9b0aecab	e8f598e6-df54-46ee-bf25-ccadaee8681c	MANAGE_LEADERSHIP	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
f1221d62-9769-4a41-95a1-b311bfd84925	e8f598e6-df54-46ee-bf25-ccadaee8681c	ASSIGN_USERS	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
5351f526-e600-4f57-aa2c-c8ec94671c55	e8f598e6-df54-46ee-bf25-ccadaee8681c	VIEW_REPORTS	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
298f7862-d890-4a88-91b8-a051841b3fd2	e8f598e6-df54-46ee-bf25-ccadaee8681c	LOG_TIME	t	2026-04-09 09:50:24.821044	2026-04-09 09:50:24.821044
\.


--
-- TOC entry 5417 (class 0 OID 28339)
-- Dependencies: 242
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
-- TOC entry 5189 (class 2606 OID 36268)
-- Name: activity_log activity_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5056 (class 2606 OID 28355)
-- Name: app_user app_user_org_id_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_email_key UNIQUE (org_id, email);


--
-- TOC entry 5058 (class 2606 OID 28357)
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- TOC entry 5062 (class 2606 OID 28359)
-- Name: attachment attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- TOC entry 5066 (class 2606 OID 28361)
-- Name: business_unit business_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_pkey PRIMARY KEY (id);


--
-- TOC entry 5186 (class 2606 OID 28767)
-- Name: chat_message chat_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_pkey PRIMARY KEY (id);


--
-- TOC entry 5182 (class 2606 OID 28752)
-- Name: chat_session chat_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_pkey PRIMARY KEY (id);


--
-- TOC entry 5077 (class 2606 OID 28363)
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- TOC entry 5080 (class 2606 OID 28365)
-- Name: organization organization_azure_tenant_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_azure_tenant_id_key UNIQUE (azure_tenant_id);


--
-- TOC entry 5082 (class 2606 OID 28367)
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- TOC entry 5084 (class 2606 OID 28369)
-- Name: platform_user platform_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_email_key UNIQUE (email);


--
-- TOC entry 5086 (class 2606 OID 28371)
-- Name: platform_user platform_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_pkey PRIMARY KEY (id);


--
-- TOC entry 5097 (class 2606 OID 28373)
-- Name: project_cost project_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_pkey PRIMARY KEY (id);


--
-- TOC entry 5100 (class 2606 OID 28375)
-- Name: project_link project_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5091 (class 2606 OID 28377)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- TOC entry 5093 (class 2606 OID 28379)
-- Name: project project_project_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_project_code_key UNIQUE (project_code);


--
-- TOC entry 5103 (class 2606 OID 28381)
-- Name: project_task_sequence project_task_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_pkey PRIMARY KEY (id);


--
-- TOC entry 5105 (class 2606 OID 28383)
-- Name: project_task_sequence project_task_sequence_project_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_key UNIQUE (project_id);


--
-- TOC entry 5108 (class 2606 OID 28385)
-- Name: resource_cost resource_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_pkey PRIMARY KEY (id);


--
-- TOC entry 5110 (class 2606 OID 28387)
-- Name: resource_cost resource_cost_user_id_effective_from_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_effective_from_key UNIQUE (user_id, effective_from);


--
-- TOC entry 5113 (class 2606 OID 28389)
-- Name: role_permission role_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_pkey PRIMARY KEY (role, permission_key);


--
-- TOC entry 5117 (class 2606 OID 28391)
-- Name: sprint sprint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_pkey PRIMARY KEY (id);


--
-- TOC entry 5120 (class 2606 OID 28393)
-- Name: tag tag_org_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_name_key UNIQUE (org_id, name);


--
-- TOC entry 5122 (class 2606 OID 28395)
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- TOC entry 5139 (class 2606 OID 28397)
-- Name: task_comment task_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_pkey PRIMARY KEY (id);


--
-- TOC entry 5143 (class 2606 OID 28399)
-- Name: task_link task_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5145 (class 2606 OID 28401)
-- Name: task_link task_link_source_task_id_target_task_id_link_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_target_task_id_link_type_key UNIQUE (source_task_id, target_task_id, link_type);


--
-- TOC entry 5133 (class 2606 OID 28403)
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- TOC entry 5149 (class 2606 OID 28405)
-- Name: task_tag_mapping task_tag_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_pkey PRIMARY KEY (task_id, tag_id);


--
-- TOC entry 5135 (class 2606 OID 28407)
-- Name: task task_task_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_task_code_key UNIQUE (task_code);


--
-- TOC entry 5155 (class 2606 OID 28409)
-- Name: time_log time_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5160 (class 2606 OID 28411)
-- Name: timesheet timesheet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_pkey PRIMARY KEY (id);


--
-- TOC entry 5069 (class 2606 OID 28413)
-- Name: business_unit uq_business_unit_org_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT uq_business_unit_org_name UNIQUE (org_id, name);


--
-- TOC entry 5169 (class 2606 OID 28415)
-- Name: user_permission uq_user_permission; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT uq_user_permission UNIQUE (user_id, permission_key);


--
-- TOC entry 5178 (class 2606 OID 28417)
-- Name: user_project_mapping uq_user_project_mapping_user_project_role; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT uq_user_project_mapping_user_project_role UNIQUE (user_id, project_id, project_role);


--
-- TOC entry 5164 (class 2606 OID 28419)
-- Name: user_daily_summary user_daily_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_pkey PRIMARY KEY (id);


--
-- TOC entry 5166 (class 2606 OID 28421)
-- Name: user_daily_summary user_daily_summary_user_id_summary_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_summary_date_key UNIQUE (user_id, summary_date);


--
-- TOC entry 5171 (class 2606 OID 28423)
-- Name: user_permission user_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT user_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 5180 (class 2606 OID 28425)
-- Name: user_project_mapping user_project_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_pkey PRIMARY KEY (id);


--
-- TOC entry 5190 (class 1259 OID 36269)
-- Name: idx_activity_log_action_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_action_type ON public.activity_log USING btree (action_type);


--
-- TOC entry 5191 (class 1259 OID 36270)
-- Name: idx_activity_log_actor_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_actor_user_id ON public.activity_log USING btree (actor_user_id);


--
-- TOC entry 5192 (class 1259 OID 36271)
-- Name: idx_activity_log_org_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activity_log_org_created_at ON public.activity_log USING btree (org_id, created_at DESC);


--
-- TOC entry 5059 (class 1259 OID 28426)
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- TOC entry 5060 (class 1259 OID 28427)
-- Name: idx_app_user_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_org ON public.app_user USING btree (org_id);


--
-- TOC entry 5063 (class 1259 OID 28428)
-- Name: idx_attachment_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_org ON public.attachment USING btree (org_id);


--
-- TOC entry 5064 (class 1259 OID 28429)
-- Name: idx_attachment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_task ON public.attachment USING btree (task_id);


--
-- TOC entry 5067 (class 1259 OID 28430)
-- Name: idx_business_unit_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_business_unit_org ON public.business_unit USING btree (org_id);


--
-- TOC entry 5187 (class 1259 OID 28773)
-- Name: idx_chat_message_session_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_message_session_created ON public.chat_message USING btree (session_id, created_at);


--
-- TOC entry 5183 (class 1259 OID 28753)
-- Name: idx_chat_session_org_user_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_session_org_user_active ON public.chat_session USING btree (org_id, user_id, ended_at);


--
-- TOC entry 5184 (class 1259 OID 28754)
-- Name: idx_chat_session_org_user_started; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_session_org_user_started ON public.chat_session USING btree (org_id, user_id, started_at DESC);


--
-- TOC entry 5070 (class 1259 OID 28431)
-- Name: idx_notification_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_created_at ON public.notification USING btree (created_at DESC);


--
-- TOC entry 5071 (class 1259 OID 28432)
-- Name: idx_notification_recipient_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_recipient_created_at ON public.notification USING btree (recipient_id, created_at DESC);


--
-- TOC entry 5072 (class 1259 OID 28433)
-- Name: idx_notification_recipient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_recipient_id ON public.notification USING btree (recipient_id);


--
-- TOC entry 5073 (class 1259 OID 28434)
-- Name: idx_notification_recipient_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_recipient_is_read ON public.notification USING btree (recipient_id, is_read);


--
-- TOC entry 5074 (class 1259 OID 28435)
-- Name: idx_notification_task_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_task_id ON public.notification USING btree (task_id);


--
-- TOC entry 5075 (class 1259 OID 28436)
-- Name: idx_notification_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notification_type ON public.notification USING btree (type);


--
-- TOC entry 5078 (class 1259 OID 28437)
-- Name: idx_organization_azure_tenant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_organization_azure_tenant ON public.organization USING btree (azure_tenant_id);


--
-- TOC entry 5087 (class 1259 OID 28438)
-- Name: idx_project_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_code ON public.project USING btree (project_code);


--
-- TOC entry 5095 (class 1259 OID 28439)
-- Name: idx_project_cost_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_cost_project ON public.project_cost USING btree (project_id);


--
-- TOC entry 5098 (class 1259 OID 28440)
-- Name: idx_project_link_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_link_project ON public.project_link USING btree (project_id);


--
-- TOC entry 5088 (class 1259 OID 28441)
-- Name: idx_project_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_org ON public.project USING btree (org_id);


--
-- TOC entry 5101 (class 1259 OID 28442)
-- Name: idx_project_task_sequence_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_task_sequence_project ON public.project_task_sequence USING btree (project_id);


--
-- TOC entry 5089 (class 1259 OID 28443)
-- Name: idx_project_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_type ON public.project USING btree (project_type);


--
-- TOC entry 5106 (class 1259 OID 28444)
-- Name: idx_resource_cost_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_resource_cost_user ON public.resource_cost USING btree (user_id);


--
-- TOC entry 5111 (class 1259 OID 28445)
-- Name: idx_role_permission_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_role_permission_role ON public.role_permission USING btree (role);


--
-- TOC entry 5114 (class 1259 OID 28446)
-- Name: idx_sprint_definition; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sprint_definition ON public.sprint USING btree (id) WHERE (definition IS NOT NULL);


--
-- TOC entry 5115 (class 1259 OID 28447)
-- Name: idx_sprint_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sprint_project ON public.sprint USING btree (project_id);


--
-- TOC entry 5118 (class 1259 OID 28448)
-- Name: idx_tag_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tag_org ON public.tag USING btree (org_id);


--
-- TOC entry 5123 (class 1259 OID 28449)
-- Name: idx_task_assignee; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_assignee ON public.task USING btree (assigned_to);


--
-- TOC entry 5124 (class 1259 OID 28450)
-- Name: idx_task_blocked_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_blocked_by ON public.task USING btree (blocked_by);


--
-- TOC entry 5125 (class 1259 OID 28451)
-- Name: idx_task_blocked_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_blocked_status ON public.task USING btree (status) WHERE ((status)::text = 'BLOCKED'::text);


--
-- TOC entry 5126 (class 1259 OID 28452)
-- Name: idx_task_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_code ON public.task USING btree (task_code);


--
-- TOC entry 5136 (class 1259 OID 28453)
-- Name: idx_task_comment_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_parent ON public.task_comment USING btree (parent_comment_id);


--
-- TOC entry 5137 (class 1259 OID 28454)
-- Name: idx_task_comment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_task ON public.task_comment USING btree (task_id);


--
-- TOC entry 5127 (class 1259 OID 28455)
-- Name: idx_task_epic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_epic ON public.task USING btree (epic_id) WHERE (epic_id IS NOT NULL);


--
-- TOC entry 5140 (class 1259 OID 28456)
-- Name: idx_task_link_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_source ON public.task_link USING btree (source_task_id);


--
-- TOC entry 5141 (class 1259 OID 28457)
-- Name: idx_task_link_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_target ON public.task_link USING btree (target_task_id);


--
-- TOC entry 5128 (class 1259 OID 28458)
-- Name: idx_task_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_org ON public.task USING btree (org_id);


--
-- TOC entry 5129 (class 1259 OID 28459)
-- Name: idx_task_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_project ON public.task USING btree (project_id);


--
-- TOC entry 5130 (class 1259 OID 28460)
-- Name: idx_task_sprint; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_sprint ON public.task USING btree (sprint_id);


--
-- TOC entry 5131 (class 1259 OID 28461)
-- Name: idx_task_story; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_story ON public.task USING btree (story_id) WHERE (story_id IS NOT NULL);


--
-- TOC entry 5146 (class 1259 OID 28462)
-- Name: idx_task_tag_mapping_tag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_tag ON public.task_tag_mapping USING btree (tag_id);


--
-- TOC entry 5147 (class 1259 OID 28463)
-- Name: idx_task_tag_mapping_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_task ON public.task_tag_mapping USING btree (task_id);


--
-- TOC entry 5150 (class 1259 OID 28464)
-- Name: idx_time_log_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_date ON public.time_log USING btree (log_date);


--
-- TOC entry 5151 (class 1259 OID 28465)
-- Name: idx_time_log_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_task ON public.time_log USING btree (task_id);


--
-- TOC entry 5152 (class 1259 OID 28466)
-- Name: idx_time_log_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user ON public.time_log USING btree (user_id);


--
-- TOC entry 5153 (class 1259 OID 28467)
-- Name: idx_time_log_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user_date ON public.time_log USING btree (user_id, log_date);


--
-- TOC entry 5156 (class 1259 OID 28468)
-- Name: idx_timesheet_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_org ON public.timesheet USING btree (org_id);


--
-- TOC entry 5157 (class 1259 OID 28469)
-- Name: idx_timesheet_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user ON public.timesheet USING btree (user_id);


--
-- TOC entry 5158 (class 1259 OID 28470)
-- Name: idx_timesheet_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user_date ON public.timesheet USING btree (user_id, entry_date);


--
-- TOC entry 5161 (class 1259 OID 28471)
-- Name: idx_user_daily_summary_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_date ON public.user_daily_summary USING btree (summary_date);


--
-- TOC entry 5162 (class 1259 OID 28472)
-- Name: idx_user_daily_summary_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_user ON public.user_daily_summary USING btree (user_id);


--
-- TOC entry 5167 (class 1259 OID 28473)
-- Name: idx_user_permission_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_permission_user_id ON public.user_permission USING btree (user_id);


--
-- TOC entry 5172 (class 1259 OID 28474)
-- Name: idx_user_project_mapping_approval_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_approval_status ON public.user_project_mapping USING btree (approval_status);


--
-- TOC entry 5173 (class 1259 OID 28475)
-- Name: idx_user_project_mapping_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project ON public.user_project_mapping USING btree (project_id);


--
-- TOC entry 5174 (class 1259 OID 28476)
-- Name: idx_user_project_mapping_project_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project_approval ON public.user_project_mapping USING btree (project_id, approval_status);


--
-- TOC entry 5175 (class 1259 OID 28477)
-- Name: idx_user_project_mapping_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user ON public.user_project_mapping USING btree (user_id);


--
-- TOC entry 5176 (class 1259 OID 28478)
-- Name: idx_user_project_mapping_user_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user_approval ON public.user_project_mapping USING btree (user_id, approval_status);


--
-- TOC entry 5094 (class 1259 OID 28479)
-- Name: uq_project_org_finance_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_project_org_finance_code ON public.project USING btree (org_id, finance_code) WHERE (finance_code IS NOT NULL);


--
-- TOC entry 5246 (class 2606 OID 36272)
-- Name: activity_log activity_log_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5247 (class 2606 OID 36277)
-- Name: activity_log activity_log_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5193 (class 2606 OID 28480)
-- Name: app_user app_user_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5194 (class 2606 OID 28485)
-- Name: attachment attachment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5195 (class 2606 OID 28490)
-- Name: attachment attachment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5196 (class 2606 OID 28495)
-- Name: attachment attachment_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.app_user(id);


--
-- TOC entry 5197 (class 2606 OID 28500)
-- Name: business_unit business_unit_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5198 (class 2606 OID 28505)
-- Name: business_unit business_unit_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.app_user(id);


--
-- TOC entry 5245 (class 2606 OID 28768)
-- Name: chat_message chat_message_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_message
    ADD CONSTRAINT chat_message_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.chat_session(id) ON DELETE CASCADE;


--
-- TOC entry 5239 (class 2606 OID 28510)
-- Name: user_permission fk_user_permission_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_permission
    ADD CONSTRAINT fk_user_permission_user FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- TOC entry 5199 (class 2606 OID 28515)
-- Name: notification notification_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- TOC entry 5200 (class 2606 OID 28520)
-- Name: notification notification_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5204 (class 2606 OID 28525)
-- Name: project_cost project_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5205 (class 2606 OID 28530)
-- Name: project_cost project_cost_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5201 (class 2606 OID 28535)
-- Name: project project_finance_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_finance_member_id_fkey FOREIGN KEY (finance_member_id) REFERENCES public.app_user(id);


--
-- TOC entry 5206 (class 2606 OID 28540)
-- Name: project_link project_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5207 (class 2606 OID 28545)
-- Name: project_link project_link_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5202 (class 2606 OID 28550)
-- Name: project project_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.app_user(id);


--
-- TOC entry 5203 (class 2606 OID 28555)
-- Name: project project_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5208 (class 2606 OID 28560)
-- Name: project_task_sequence project_task_sequence_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5209 (class 2606 OID 28565)
-- Name: resource_cost resource_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5210 (class 2606 OID 28570)
-- Name: resource_cost resource_cost_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5211 (class 2606 OID 28575)
-- Name: sprint sprint_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5212 (class 2606 OID 28580)
-- Name: tag tag_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5213 (class 2606 OID 28585)
-- Name: task task_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.app_user(id);


--
-- TOC entry 5214 (class 2606 OID 28590)
-- Name: task task_blocked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_blocked_by_fkey FOREIGN KEY (blocked_by) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5221 (class 2606 OID 28595)
-- Name: task_comment task_comment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5222 (class 2606 OID 28600)
-- Name: task_comment task_comment_parent_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.task_comment(id);


--
-- TOC entry 5223 (class 2606 OID 28605)
-- Name: task_comment task_comment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5224 (class 2606 OID 28610)
-- Name: task_comment task_comment_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5215 (class 2606 OID 28615)
-- Name: task task_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- TOC entry 5216 (class 2606 OID 28620)
-- Name: task task_epic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_epic_id_fkey FOREIGN KEY (epic_id) REFERENCES public.task(id) ON DELETE SET NULL;


--
-- TOC entry 5225 (class 2606 OID 28625)
-- Name: task_link task_link_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- TOC entry 5226 (class 2606 OID 28630)
-- Name: task_link task_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5227 (class 2606 OID 28635)
-- Name: task_link task_link_source_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_fkey FOREIGN KEY (source_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5228 (class 2606 OID 28640)
-- Name: task_link task_link_target_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_target_task_id_fkey FOREIGN KEY (target_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5217 (class 2606 OID 28645)
-- Name: task task_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5218 (class 2606 OID 28650)
-- Name: task task_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5219 (class 2606 OID 28655)
-- Name: task task_sprint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_sprint_id_fkey FOREIGN KEY (sprint_id) REFERENCES public.sprint(id);


--
-- TOC entry 5220 (class 2606 OID 28660)
-- Name: task task_story_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_story_id_fkey FOREIGN KEY (story_id) REFERENCES public.task(id) ON DELETE SET NULL;


--
-- TOC entry 5229 (class 2606 OID 28665)
-- Name: task_tag_mapping task_tag_mapping_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id) ON DELETE CASCADE;


--
-- TOC entry 5230 (class 2606 OID 28670)
-- Name: task_tag_mapping task_tag_mapping_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5231 (class 2606 OID 28675)
-- Name: time_log time_log_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5232 (class 2606 OID 28680)
-- Name: time_log time_log_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5233 (class 2606 OID 28685)
-- Name: time_log time_log_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- TOC entry 5234 (class 2606 OID 28690)
-- Name: time_log time_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5235 (class 2606 OID 28695)
-- Name: timesheet timesheet_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5236 (class 2606 OID 28700)
-- Name: timesheet timesheet_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5237 (class 2606 OID 28705)
-- Name: user_daily_summary user_daily_summary_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5238 (class 2606 OID 28710)
-- Name: user_daily_summary user_daily_summary_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- TOC entry 5240 (class 2606 OID 28715)
-- Name: user_project_mapping user_project_mapping_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5241 (class 2606 OID 28720)
-- Name: user_project_mapping user_project_mapping_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- TOC entry 5242 (class 2606 OID 28725)
-- Name: user_project_mapping user_project_mapping_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- TOC entry 5243 (class 2606 OID 28730)
-- Name: user_project_mapping user_project_mapping_requested_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_requested_by_user_id_fkey FOREIGN KEY (requested_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- TOC entry 5244 (class 2606 OID 28735)
-- Name: user_project_mapping user_project_mapping_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


-- Completed on 2026-04-16 11:26:28

--
-- PostgreSQL database dump complete
--

\unrestrict LkbQgrqJgusoGp9E2Vte7rL5MuAWCDwGvSrEqF9iJ5Apx8VguH6Z6MubKe0Ia2R

