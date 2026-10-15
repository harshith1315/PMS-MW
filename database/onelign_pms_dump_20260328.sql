--
-- PostgreSQL database dump
--

\restrict YlnmuBXTuJdb3i2SVxHoZH3vfnJTSjHfRIOr2WlvCsJloearJD7mOedO1a5SrFj

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.project OWNER TO postgres;

--
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
-- Name: task_tag_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_tag_mapping (
    task_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.task_tag_mapping OWNER TO postgres;

--
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
-- Data for Name: app_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_user (id, org_id, email, name, role, designation, is_leader, is_manager, status, created_at) FROM stdin;
b762cce3-dac1-4aa0-bc38-a8488eaf994f	1d105d8b-95d8-411e-9844-b6683e8b7f51	princy.joseph@bonbloc.com	princy	ORG_ADMIN	\N	f	f	ACTIVE	2026-03-19 14:23:34.808615
b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	manager@acme.com	Jane	ORG_ADMIN	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231
b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	developer1@acme.com	Alice	USER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231
b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	developer2@acme.com	Bob	USER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231
b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	qa@acme.com	Charlie	USER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231
65b2f9f4-a049-4766-b6f6-4ecca8fb8de7	1d105d8b-95d8-411e-9844-b6683e8b7f51	santhosh.sankar@bonbloc.com	Santhosh	USER	\N	f	f	ACTIVE	2026-03-19 17:57:36.529875
b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	alicia.antony@bonbloc.com	Alicia	USER	\N	f	f	ACTIVE	2026-03-18 20:14:20.348231
6d7b3010-5f27-4495-b7b1-85d6f734657f	1d105d8b-95d8-411e-9844-b6683e8b7f51	pranathi@bonbloc.com	Pranathi	USER	Manager	t	t	ACTIVE	2026-03-26 23:01:27.496598
d4c27066-b249-42ef-ac9d-bccbd7cced4e	1d105d8b-95d8-411e-9844-b6683e8b7f51	test@gmail.com	sai ram	MANAGER	director	t	t	ACTIVE	2026-03-26 23:56:13.01749
fbfbe066-9918-412c-835d-f92a30ac44e4	1d105d8b-95d8-411e-9844-b6683e8b7f51	narayanareddy.mallidi@bonbloc.com	Narayana	MANAGER	DEV	t	t	ACTIVE	2026-03-27 10:02:54.511576
edb1541e-efee-435d-a4cd-6e7da392464a	1d105d8b-95d8-411e-9844-b6683e8b7f51	harshith.kanumuri@bonbloc.com	Harshith Kanumuri	ORG_ADMIN	DEV	t	t	ACTIVE	2026-03-26 22:48:28.989947
\.


--
-- Data for Name: attachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attachment (id, org_id, task_id, file_name, file_type, file_size, s3_key, uploaded_by, status, created_at) FROM stdin;
0b432db8-80e5-4f85-a370-609448813852	1d105d8b-95d8-411e-9844-b6683e8b7f51	86d4af01-800a-435d-ac7c-d4594c1f495b	Screenshot 2026-03-28 135646.png	\N	\N	attachments/1d105d8b-95d8-411e-9844-b6683e8b7f51/10ac6760-95d0-4f5d-acb5-52126ff0c7e1/86d4af01-800a-435d-ac7c-d4594c1f495b/83071b02-a25f-4221-bd47-b11516a8e4da.png	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-28 14:11:59.09885
\.


--
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization (id, name, azure_tenant_id, status, created_at) FROM stdin;
1d105d8b-95d8-411e-9844-b6683e8b7f51	BONbLOC Technologies	7915d0a8-0a13-4824-ba52-43a1ad694c42	ACTIVE	2026-03-19 14:23:34.808615
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Acme Corporation	null	ACTIVE	2026-03-18 20:14:20.339403
\.


--
-- Data for Name: platform_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.platform_user (id, email, name, role, status, created_at) FROM stdin;
d2c3a954-c0f7-4718-92be-e97449206874	oviiyadominic@gmail.com	Oviiya Dominic	ADMIN	ACTIVE	2026-03-19 14:28:31.763376
\.


--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project (id, org_id, name, project_code, business_unit, manager_id, status, created_at) FROM stdin;
c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Mobile App Development	MOB	Engineering	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586
c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	Website Redesign	WEB	Marketing	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586
c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	1d105d8b-95d8-411e-9844-b6683e8b7f51	API Integration	API	Engineering	b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-18 20:14:20.360586
a3f75871-11e5-49ba-9fb7-2659f7283f2a	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS	PROJ_101	Onelign Software Applications	b762cce3-dac1-4aa0-bc38-a8488eaf994f	ACTIVE	2026-03-19 17:48:25.948931
6564025c-356b-4e87-96e6-44360bde99f0	1d105d8b-95d8-411e-9844-b6683e8b7f51	FPO	FPO-101	Onelign Software Applications	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-19 18:10:00.907041
cc556634-367e-4ff9-a331-a000d92c89e3	1d105d8b-95d8-411e-9844-b6683e8b7f51	COld Chain	PROJ-123	Onelign Software Applications	b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	ACTIVE	2026-03-19 18:31:10.938558
d901321d-b502-4a26-8cb7-483ca57ba66d	1d105d8b-95d8-411e-9844-b6683e8b7f51	CEL	PROJ-1234	Onelign Software Applications	6d7b3010-5f27-4495-b7b1-85d6f734657f	ACTIVE	2026-03-26 23:01:53.185218
71bb0f85-cdde-469a-900d-e8761da76e45	1d105d8b-95d8-411e-9844-b6683e8b7f51	test	PROJ-1235	Onelign Software Applications	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-26 23:02:59.560141
eeb797e6-385c-4376-a607-9663e4313e60	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS	PROJ-1236	Onelign Software Applications	fbfbe066-9918-412c-835d-f92a30ac44e4	ACTIVE	2026-03-27 10:03:20.826154
10ac6760-95d0-4f5d-acb5-52126ff0c7e1	1d105d8b-95d8-411e-9844-b6683e8b7f51	LMS-PH	PROJ-1237	Onelign Software Applications	edb1541e-efee-435d-a4cd-6e7da392464a	ACTIVE	2026-03-27 12:19:05.01159
\.


--
-- Data for Name: project_cost; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_cost (id, org_id, project_id, cost_type, amount, description, cost_date, status, created_at) FROM stdin;
\.


--
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
-- Name: app_user app_user_org_id_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_email_key UNIQUE (org_id, email);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- Name: attachment attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- Name: organization organization_azure_tenant_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_azure_tenant_id_key UNIQUE (azure_tenant_id);


--
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- Name: platform_user platform_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_email_key UNIQUE (email);


--
-- Name: platform_user platform_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.platform_user
    ADD CONSTRAINT platform_user_pkey PRIMARY KEY (id);


--
-- Name: project_cost project_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_pkey PRIMARY KEY (id);


--
-- Name: project_link project_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_pkey PRIMARY KEY (id);


--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- Name: project project_project_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_project_code_key UNIQUE (project_code);


--
-- Name: project_task_sequence project_task_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_pkey PRIMARY KEY (id);


--
-- Name: project_task_sequence project_task_sequence_project_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_key UNIQUE (project_id);


--
-- Name: resource_cost resource_cost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_pkey PRIMARY KEY (id);


--
-- Name: resource_cost resource_cost_user_id_effective_from_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_effective_from_key UNIQUE (user_id, effective_from);


--
-- Name: sprint sprint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_pkey PRIMARY KEY (id);


--
-- Name: tag tag_org_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_name_key UNIQUE (org_id, name);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: task_comment task_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_pkey PRIMARY KEY (id);


--
-- Name: task_link task_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_pkey PRIMARY KEY (id);


--
-- Name: task_link task_link_source_task_id_target_task_id_link_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_target_task_id_link_type_key UNIQUE (source_task_id, target_task_id, link_type);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (id);


--
-- Name: task_tag_mapping task_tag_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_pkey PRIMARY KEY (task_id, tag_id);


--
-- Name: task task_task_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_task_code_key UNIQUE (task_code);


--
-- Name: time_log time_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_pkey PRIMARY KEY (id);


--
-- Name: timesheet timesheet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_pkey PRIMARY KEY (id);


--
-- Name: user_project_mapping uq_user_project_mapping_user_project_role; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT uq_user_project_mapping_user_project_role UNIQUE (user_id, project_id, project_role);


--
-- Name: user_daily_summary user_daily_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_pkey PRIMARY KEY (id);


--
-- Name: user_daily_summary user_daily_summary_user_id_summary_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_summary_date_key UNIQUE (user_id, summary_date);


--
-- Name: user_project_mapping user_project_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_pkey PRIMARY KEY (id);


--
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- Name: idx_app_user_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_user_org ON public.app_user USING btree (org_id);


--
-- Name: idx_attachment_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_org ON public.attachment USING btree (org_id);


--
-- Name: idx_attachment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_task ON public.attachment USING btree (task_id);


--
-- Name: idx_organization_azure_tenant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_organization_azure_tenant ON public.organization USING btree (azure_tenant_id);


--
-- Name: idx_project_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_code ON public.project USING btree (project_code);


--
-- Name: idx_project_cost_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_cost_project ON public.project_cost USING btree (project_id);


--
-- Name: idx_project_link_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_link_project ON public.project_link USING btree (project_id);


--
-- Name: idx_project_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_org ON public.project USING btree (org_id);


--
-- Name: idx_project_task_sequence_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_project_task_sequence_project ON public.project_task_sequence USING btree (project_id);


--
-- Name: idx_resource_cost_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_resource_cost_user ON public.resource_cost USING btree (user_id);


--
-- Name: idx_sprint_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sprint_project ON public.sprint USING btree (project_id);


--
-- Name: idx_tag_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tag_org ON public.tag USING btree (org_id);


--
-- Name: idx_task_assignee; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_assignee ON public.task USING btree (assigned_to);


--
-- Name: idx_task_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_code ON public.task USING btree (task_code);


--
-- Name: idx_task_comment_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_parent ON public.task_comment USING btree (parent_comment_id);


--
-- Name: idx_task_comment_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_comment_task ON public.task_comment USING btree (task_id);


--
-- Name: idx_task_link_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_source ON public.task_link USING btree (source_task_id);


--
-- Name: idx_task_link_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_link_target ON public.task_link USING btree (target_task_id);


--
-- Name: idx_task_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_org ON public.task USING btree (org_id);


--
-- Name: idx_task_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_project ON public.task USING btree (project_id);


--
-- Name: idx_task_sprint; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_sprint ON public.task USING btree (sprint_id);


--
-- Name: idx_task_tag_mapping_tag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_tag ON public.task_tag_mapping USING btree (tag_id);


--
-- Name: idx_task_tag_mapping_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_tag_mapping_task ON public.task_tag_mapping USING btree (task_id);


--
-- Name: idx_time_log_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_date ON public.time_log USING btree (log_date);


--
-- Name: idx_time_log_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_task ON public.time_log USING btree (task_id);


--
-- Name: idx_time_log_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user ON public.time_log USING btree (user_id);


--
-- Name: idx_time_log_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_time_log_user_date ON public.time_log USING btree (user_id, log_date);


--
-- Name: idx_timesheet_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_org ON public.timesheet USING btree (org_id);


--
-- Name: idx_timesheet_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user ON public.timesheet USING btree (user_id);


--
-- Name: idx_timesheet_user_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_timesheet_user_date ON public.timesheet USING btree (user_id, entry_date);


--
-- Name: idx_user_daily_summary_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_date ON public.user_daily_summary USING btree (summary_date);


--
-- Name: idx_user_daily_summary_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_daily_summary_user ON public.user_daily_summary USING btree (user_id);


--
-- Name: idx_user_project_mapping_approval_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_approval_status ON public.user_project_mapping USING btree (approval_status);


--
-- Name: idx_user_project_mapping_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project ON public.user_project_mapping USING btree (project_id);


--
-- Name: idx_user_project_mapping_project_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_project_approval ON public.user_project_mapping USING btree (project_id, approval_status);


--
-- Name: idx_user_project_mapping_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user ON public.user_project_mapping USING btree (user_id);


--
-- Name: idx_user_project_mapping_user_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_project_mapping_user_approval ON public.user_project_mapping USING btree (user_id, approval_status);


--
-- Name: app_user app_user_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: attachment attachment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: attachment attachment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: attachment attachment_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.app_user(id);


--
-- Name: project_cost project_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: project_cost project_cost_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_cost
    ADD CONSTRAINT project_cost_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- Name: project_link project_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: project_link project_link_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_link
    ADD CONSTRAINT project_link_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- Name: project project_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.app_user(id);


--
-- Name: project project_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: project_task_sequence project_task_sequence_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_task_sequence
    ADD CONSTRAINT project_task_sequence_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- Name: resource_cost resource_cost_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: resource_cost resource_cost_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_cost
    ADD CONSTRAINT resource_cost_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: sprint sprint_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sprint
    ADD CONSTRAINT sprint_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- Name: tag tag_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: task task_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.app_user(id);


--
-- Name: task_comment task_comment_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: task_comment task_comment_parent_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.task_comment(id);


--
-- Name: task_comment task_comment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: task_comment task_comment_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_comment
    ADD CONSTRAINT task_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: task task_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- Name: task_link task_link_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.app_user(id);


--
-- Name: task_link task_link_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: task_link task_link_source_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_source_task_id_fkey FOREIGN KEY (source_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: task_link task_link_target_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_link
    ADD CONSTRAINT task_link_target_task_id_fkey FOREIGN KEY (target_task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: task task_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: task task_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- Name: task task_sprint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_sprint_id_fkey FOREIGN KEY (sprint_id) REFERENCES public.sprint(id);


--
-- Name: task_tag_mapping task_tag_mapping_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id) ON DELETE CASCADE;


--
-- Name: task_tag_mapping task_tag_mapping_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_tag_mapping
    ADD CONSTRAINT task_tag_mapping_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: time_log time_log_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: time_log time_log_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- Name: time_log time_log_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id) ON DELETE CASCADE;


--
-- Name: time_log time_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_log
    ADD CONSTRAINT time_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: timesheet timesheet_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: timesheet timesheet_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timesheet
    ADD CONSTRAINT timesheet_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: user_daily_summary user_daily_summary_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: user_daily_summary user_daily_summary_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_daily_summary
    ADD CONSTRAINT user_daily_summary_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: user_project_mapping user_project_mapping_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- Name: user_project_mapping user_project_mapping_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.organization(id);


--
-- Name: user_project_mapping user_project_mapping_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(id);


--
-- Name: user_project_mapping user_project_mapping_requested_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_requested_by_user_id_fkey FOREIGN KEY (requested_by_user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- Name: user_project_mapping user_project_mapping_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_project_mapping
    ADD CONSTRAINT user_project_mapping_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- PostgreSQL database dump complete
--

\unrestrict YlnmuBXTuJdb3i2SVxHoZH3vfnJTSjHfRIOr2WlvCsJloearJD7mOedO1a5SrFj

