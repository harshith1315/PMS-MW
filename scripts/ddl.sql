-- Onelign PMS Database Schema
-- PostgreSQL DDL

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Organization Table
-- =====================================================
CREATE TABLE organization (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    azure_tenant_id VARCHAR(255) UNIQUE,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_organization_azure_tenant ON organization(azure_tenant_id);

-- =====================================================
-- Platform User Table (Super Admins)
-- =====================================================
CREATE TABLE platform_user (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'PLATFORM_ADMIN',
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- App User Table (Organization Users)
-- =====================================================
CREATE TABLE app_user (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'USER',
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(org_id, email)
);

CREATE INDEX idx_app_user_org ON app_user(org_id);
CREATE INDEX idx_app_user_email ON app_user(email);

-- =====================================================
-- Activity Log Table
-- =====================================================
CREATE TABLE activity_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    actor_user_id UUID REFERENCES app_user(id),
    actor_name VARCHAR(255),
    actor_email VARCHAR(255),
    method VARCHAR(10) NOT NULL,
    resource_type VARCHAR(100),
    resource_id VARCHAR(255),
    action_type VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    request_path VARCHAR(500) NOT NULL,
    ip_address VARCHAR(64),
    user_agent VARCHAR(500),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activity_log_org_id ON activity_log(org_id);
CREATE INDEX idx_activity_log_created_at ON activity_log(created_at);
CREATE INDEX idx_activity_log_action_type ON activity_log(action_type);
CREATE INDEX idx_activity_log_actor_user_id ON activity_log(actor_user_id);
CREATE INDEX idx_activity_log_resource_type ON activity_log(resource_type);

-- =====================================================
-- Project Table
-- =====================================================
CREATE TABLE project (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    name VARCHAR(255) NOT NULL,
    project_code VARCHAR(50) UNIQUE NOT NULL,
    business_unit VARCHAR(100),
    finance_code VARCHAR(50),
    budget DECIMAL(15,2),
    kickoff_date DATE,
    start_date DATE,
    end_date DATE,
    project_type VARCHAR(20),
    client_name VARCHAR(255),
    client_location VARCHAR(255),
    purpose TEXT,
    cost_management TEXT,
    tech_stack JSONB NOT NULL DEFAULT '[]'::jsonb,
    dependencies JSONB NOT NULL DEFAULT '[]'::jsonb,
    manager_id UUID REFERENCES app_user(id),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_project_type_values CHECK (project_type IN ('WEB', 'MOBILE', 'BOTH') OR project_type IS NULL),
    CONSTRAINT chk_project_budget_non_negative CHECK (budget IS NULL OR budget >= 0)
);

CREATE INDEX idx_project_org ON project(org_id);
CREATE INDEX idx_project_code ON project(project_code);
CREATE INDEX idx_project_type ON project(project_type);
CREATE UNIQUE INDEX uq_project_org_finance_code ON project(org_id, finance_code) WHERE finance_code IS NOT NULL;

-- =====================================================
-- User Project Mapping Table
-- =====================================================
CREATE TABLE user_project_mapping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    user_id UUID NOT NULL REFERENCES app_user(id),
    project_id UUID NOT NULL REFERENCES project(id),
    project_role VARCHAR(50) DEFAULT 'MEMBER',
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, project_id)
);

CREATE INDEX idx_user_project_mapping_user ON user_project_mapping(user_id);
CREATE INDEX idx_user_project_mapping_project ON user_project_mapping(project_id);

-- =====================================================
-- Sprint Table
-- =====================================================
CREATE TABLE sprint (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES project(id),
    name VARCHAR(255),
    goal TEXT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(50) DEFAULT 'PLANNED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sprint_project ON sprint(project_id);

-- =====================================================
-- Project Task Sequence Table (for task code generation)
-- =====================================================
CREATE TABLE project_task_sequence (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES project(id) UNIQUE,
    last_sequence INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_project_task_sequence_project ON project_task_sequence(project_id);

-- =====================================================
-- Tag Table
-- =====================================================
CREATE TABLE tag (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    name VARCHAR(100) NOT NULL,
    color VARCHAR(20),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(org_id, name)
);

CREATE INDEX idx_tag_org ON tag(org_id);

-- =====================================================
-- Task Table
-- =====================================================
CREATE TABLE task (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    project_id UUID NOT NULL REFERENCES project(id),
    sprint_id UUID REFERENCES sprint(id),
    task_code VARCHAR(50) UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    task_type VARCHAR(50),
    status VARCHAR(50) DEFAULT 'TODO',
    priority VARCHAR(50) DEFAULT 'MEDIUM',
    assigned_to UUID REFERENCES app_user(id),
    created_by UUID REFERENCES app_user(id),
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_task_org ON task(org_id);
CREATE INDEX idx_task_project ON task(project_id);
CREATE INDEX idx_task_sprint ON task(sprint_id);
CREATE INDEX idx_task_assignee ON task(assigned_to);
CREATE INDEX idx_task_code ON task(task_code);

-- =====================================================
-- Task Tag Mapping Table (Many-to-Many)
-- =====================================================
CREATE TABLE task_tag_mapping (
    task_id UUID NOT NULL REFERENCES task(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tag(id) ON DELETE CASCADE,
    PRIMARY KEY (task_id, tag_id)
);

CREATE INDEX idx_task_tag_mapping_task ON task_tag_mapping(task_id);
CREATE INDEX idx_task_tag_mapping_tag ON task_tag_mapping(tag_id);

-- =====================================================
-- Attachment Table
-- =====================================================
CREATE TABLE attachment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    task_id UUID NOT NULL REFERENCES task(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,
    s3_key VARCHAR(500) NOT NULL,
    uploaded_by UUID REFERENCES app_user(id),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_attachment_task ON attachment(task_id);
CREATE INDEX idx_attachment_org ON attachment(org_id);

-- =====================================================
-- Task Comment Table
-- =====================================================
CREATE TABLE task_comment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    task_id UUID NOT NULL REFERENCES task(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app_user(id),
    parent_comment_id UUID REFERENCES task_comment(id),
    comment_text TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE INDEX idx_task_comment_task ON task_comment(task_id);
CREATE INDEX idx_task_comment_parent ON task_comment(parent_comment_id);

-- =====================================================
-- Task Link Table
-- =====================================================
CREATE TABLE task_link (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    source_task_id UUID NOT NULL REFERENCES task(id) ON DELETE CASCADE,
    target_task_id UUID NOT NULL REFERENCES task(id) ON DELETE CASCADE,
    link_type VARCHAR(50) NOT NULL,
    created_by UUID REFERENCES app_user(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_task_id, target_task_id, link_type)
);

CREATE INDEX idx_task_link_source ON task_link(source_task_id);
CREATE INDEX idx_task_link_target ON task_link(target_task_id);

-- =====================================================
-- Time Log Table
-- =====================================================
CREATE TABLE time_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    user_id UUID NOT NULL REFERENCES app_user(id),
    task_id UUID NOT NULL REFERENCES task(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES project(id),
    log_date DATE NOT NULL,
    minutes INTEGER NOT NULL CHECK (minutes > 0 AND minutes <= 720),
    description TEXT,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_time_log_user ON time_log(user_id);
CREATE INDEX idx_time_log_task ON time_log(task_id);
CREATE INDEX idx_time_log_date ON time_log(log_date);
CREATE INDEX idx_time_log_user_date ON time_log(user_id, log_date);

-- =====================================================
-- Timesheet Table
-- =====================================================
CREATE TABLE timesheet (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    user_id UUID NOT NULL REFERENCES app_user(id),
    entry_date DATE NOT NULL,
    project_name VARCHAR(255) NOT NULL,
    task_details TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'IN_PROGRESS',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_timesheet_org ON timesheet(org_id);
CREATE INDEX idx_timesheet_user ON timesheet(user_id);
CREATE INDEX idx_timesheet_user_date ON timesheet(user_id, entry_date);

-- =====================================================
-- User Daily Summary Table
-- =====================================================
CREATE TABLE user_daily_summary (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    user_id UUID NOT NULL REFERENCES app_user(id),
    summary_date DATE NOT NULL,
    total_minutes INTEGER DEFAULT 0,
    color VARCHAR(20) DEFAULT 'RED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    UNIQUE(user_id, summary_date)
);

CREATE INDEX idx_user_daily_summary_user ON user_daily_summary(user_id);
CREATE INDEX idx_user_daily_summary_date ON user_daily_summary(summary_date);

-- =====================================================
-- Resource Cost Table
-- =====================================================
CREATE TABLE resource_cost (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    user_id UUID NOT NULL REFERENCES app_user(id),
    hourly_rate DECIMAL(10, 2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, effective_from)
);

CREATE INDEX idx_resource_cost_user ON resource_cost(user_id);

-- =====================================================
-- Project Cost Table
-- =====================================================
CREATE TABLE project_cost (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    project_id UUID NOT NULL REFERENCES project(id),
    cost_type VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    description TEXT,
    cost_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_project_cost_project ON project_cost(project_id);

-- =====================================================
-- Project Link Table
-- =====================================================
CREATE TABLE project_link (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES organization(id),
    project_id UUID NOT NULL REFERENCES project(id),
    link_type VARCHAR(50) NOT NULL,
    url VARCHAR(500) NOT NULL,
    title VARCHAR(255),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_project_link_project ON project_link(project_id);

-- =====================================================
-- Sample Data for Testing (Optional)
-- =====================================================

-- Insert a sample organization (replace with your Azure tenant ID)
-- INSERT INTO organization (id, name, azure_tenant_id, status)
-- VALUES (uuid_generate_v4(), 'Sample Organization', 'your-azure-tenant-id', 'ACTIVE');
