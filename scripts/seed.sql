-- Onelign PMS Seed Data
-- Run after ddl.sql to populate sample data for testing

-- =====================================================
-- Sample Organization
-- =====================================================
INSERT INTO organization (id, name, azure_tenant_id, status)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Acme Corporation',
    '7915d0a8-0a13-4824-ba52-43a1ad694c42',
    'ACTIVE'
);

-- =====================================================
-- Sample Users
-- =====================================================
INSERT INTO app_user (id, org_id, email, name, role, status) VALUES
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'admin@acme.com', 'John Admin', 'ADMIN', 'ACTIVE'),
('b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'manager@acme.com', 'Jane Manager', 'MANAGER', 'ACTIVE'),
('b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'developer1@acme.com', 'Alice Developer', 'USER', 'ACTIVE'),
('b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'developer2@acme.com', 'Bob Developer', 'USER', 'ACTIVE'),
('b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'qa@acme.com', 'Charlie QA', 'USER', 'ACTIVE');

-- =====================================================
-- Sample Projects
-- =====================================================
INSERT INTO project (id, org_id, name, project_code, business_unit, manager_id, status) VALUES
('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Mobile App Development', 'MOB', 'Engineering', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ACTIVE'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Website Redesign', 'WEB', 'Marketing', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ACTIVE'),
('c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'API Integration', 'API', 'Engineering', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ACTIVE');

-- =====================================================
-- Project Task Sequences (for task code generation)
-- =====================================================
INSERT INTO project_task_sequence (id, project_id, last_sequence) VALUES
('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 5),
('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 3),
('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 2);

-- =====================================================
-- User Project Mappings
-- =====================================================
INSERT INTO user_project_mapping (id, org_id, user_id, project_id, project_role, status) VALUES
-- Mobile App team
('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MANAGER', 'ACTIVE'),
('e2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DEVELOPER', 'ACTIVE'),
('e3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DEVELOPER', 'ACTIVE'),
('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'QA', 'ACTIVE'),
-- Website team
('e5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MANAGER', 'ACTIVE'),
('e6eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DEVELOPER', 'ACTIVE'),
-- API team
('e7eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MANAGER', 'ACTIVE'),
('e8eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DEVELOPER', 'ACTIVE');

-- =====================================================
-- Sample Sprints
-- =====================================================
INSERT INTO sprint (id, project_id, name, start_date, end_date, status) VALUES
-- Mobile App sprints
('f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sprint 1 - Foundation', '2026-03-01', '2026-03-15', 'COMPLETED'),
('f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sprint 2 - Auth Module', '2026-03-16', '2026-03-30', 'ACTIVE'),
('f3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sprint 3 - Dashboard', '2026-03-31', '2026-04-14', 'PLANNED'),
-- Website sprints
('f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sprint 1 - Homepage', '2026-03-01', '2026-03-15', 'ACTIVE'),
-- API sprints
('f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sprint 1 - Core APIs', '2026-03-10', '2026-03-24', 'ACTIVE');

-- =====================================================
-- Sample Tags
-- =====================================================
INSERT INTO tag (id, org_id, name, color, status) VALUES
('71eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Frontend', '#3498DB', 'ACTIVE'),
('72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Backend', '#2ECC71', 'ACTIVE'),
('73eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Database', '#9B59B6', 'ACTIVE'),
('74eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'UI/UX', '#E74C3C', 'ACTIVE'),
('75eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Security', '#F39C12', 'ACTIVE'),
('76eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Performance', '#1ABC9C', 'ACTIVE');

-- =====================================================
-- Sample Tasks
-- =====================================================
INSERT INTO task (id, org_id, project_id, sprint_id, task_code, title, description, task_type, status, priority, assigned_to, created_by, due_date) VALUES
-- Mobile App tasks
('81eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MOB-1', 'Setup project structure', 'Initialize React Native project with TypeScript', 'STORY', 'DONE', 'HIGH', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-10'),
('82eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MOB-2', 'Configure CI/CD pipeline', 'Setup GitHub Actions for automated builds', 'STORY', 'DONE', 'MEDIUM', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-12'),
('83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MOB-3', 'Implement login screen', 'Create login UI with email and password fields', 'STORY', 'IN_PROGRESS', 'HIGH', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-20'),
('84eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MOB-4', 'Integrate Azure AD auth', 'Implement Microsoft authentication', 'STORY', 'TODO', 'HIGH', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-25'),
('85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'MOB-5', 'Login button not responsive on iOS', 'Touch event not firing consistently', 'BUG', 'TODO', 'CRITICAL', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-22'),
-- Website tasks
('86eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'WEB-1', 'Design homepage mockup', 'Create Figma designs for new homepage', 'STORY', 'DONE', 'HIGH', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-08'),
('87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'WEB-2', 'Implement hero section', 'Build responsive hero component', 'STORY', 'IN_PROGRESS', 'HIGH', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-12'),
('88eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'WEB-3', 'Add SEO meta tags', 'Implement dynamic meta tags for all pages', 'STORY', 'TODO', 'MEDIUM', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-15'),
-- API tasks
('89eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'API-1', 'Design REST API endpoints', 'Document all API endpoints in OpenAPI spec', 'STORY', 'DONE', 'HIGH', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-15'),
('8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'API-2', 'Implement rate limiting', 'Add rate limiting middleware', 'STORY', 'IN_PROGRESS', 'MEDIUM', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-20');

-- =====================================================
-- Task Tag Mappings
-- =====================================================
INSERT INTO task_tag_mapping (task_id, tag_id) VALUES
('81eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '71eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- MOB-1: Frontend
('81eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- MOB-1: Backend
('83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '71eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- MOB-3: Frontend
('83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '74eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- MOB-3: UI/UX
('84eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '75eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- MOB-4: Security
('86eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '74eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- WEB-1: UI/UX
('87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '71eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- WEB-2: Frontend
('89eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- API-1: Backend
('8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '72eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- API-2: Backend
('8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '76eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'); -- API-2: Performance

-- =====================================================
-- Task Links
-- =====================================================
INSERT INTO task_link (id, org_id, source_task_id, target_task_id, link_type, created_by) VALUES
('91eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '84eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DEPENDS_ON', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- MOB-4 depends on MOB-3
('92eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'RELATES_TO', 'b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'), -- MOB-5 relates to MOB-3
('93eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '86eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DEPENDS_ON', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'); -- WEB-2 depends on WEB-1

-- =====================================================
-- Task Comments
-- =====================================================
INSERT INTO task_comment (id, org_id, task_id, user_id, parent_comment_id, comment_text, status) VALUES
('a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', NULL, 'Please make sure to follow our design system guidelines for the login screen.', 'ACTIVE'),
('a2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sure! I have the Figma link. Will follow the color palette and spacing guidelines.', 'ACTIVE'),
('a3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '85eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', NULL, 'Reproduced on iPhone 14 Pro with iOS 17.2. The button requires multiple taps.', 'ACTIVE'),
('a4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', NULL, 'Great progress! Lets add the animation for the CTA button.', 'ACTIVE');

-- =====================================================
-- Time Logs
-- =====================================================
INSERT INTO time_log (id, org_id, user_id, task_id, project_id, log_date, minutes, description, status) VALUES
-- Alice's time logs
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '81eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-10', 480, 'Project setup and configuration', 'ACTIVE'),
('b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-17', 360, 'Started login screen implementation', 'ACTIVE'),
('b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '83eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-18', 480, 'Login form validation and error handling', 'ACTIVE'),
('b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '87eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-11', 240, 'Hero section initial implementation', 'ACTIVE'),
-- Bob's time logs
('b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '82eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-11', 480, 'CI/CD pipeline setup with GitHub Actions', 'ACTIVE'),
('b6eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '89eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-14', 480, 'API documentation with OpenAPI', 'ACTIVE'),
('b7eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-17', 300, 'Rate limiting middleware research and implementation', 'ACTIVE'),
('b8eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '8aeebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-18', 540, 'Rate limiting testing and configuration', 'ACTIVE');

-- =====================================================
-- User Daily Summaries
-- =====================================================
INSERT INTO user_daily_summary (id, org_id, user_id, summary_date, total_minutes, color) VALUES
-- Alice's summaries
('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-10', 480, 'GREEN'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-11', 240, 'YELLOW'),
('c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-17', 360, 'YELLOW'),
('c4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-18', 480, 'GREEN'),
-- Bob's summaries
('c5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-11', 480, 'GREEN'),
('c6eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-14', 480, 'GREEN'),
('c7eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-17', 300, 'YELLOW'),
('c8eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026-03-18', 540, 'PURPLE');

-- =====================================================
-- Resource Costs
-- =====================================================
INSERT INTO resource_cost (id, org_id, user_id, hourly_rate, effective_from, effective_to, status) VALUES
('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 150.00, '2026-01-01', NULL, 'ACTIVE'),
('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 120.00, '2026-01-01', NULL, 'ACTIVE'),
('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 85.00, '2026-01-01', NULL, 'ACTIVE'),
('d4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 90.00, '2026-01-01', NULL, 'ACTIVE'),
('d5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 75.00, '2026-01-01', NULL, 'ACTIVE');

-- =====================================================
-- Project Links
-- =====================================================
INSERT INTO project_link (id, org_id, project_id, link_type, url, title, status) VALUES
('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'REPOSITORY', 'https://github.com/acme/mobile-app', 'GitHub Repository', 'ACTIVE'),
('e2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DOCUMENTATION', 'https://docs.acme.com/mobile', 'Project Documentation', 'ACTIVE'),
('e3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DESIGN', 'https://figma.com/file/xxx', 'Figma Designs', 'ACTIVE'),
('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'REPOSITORY', 'https://github.com/acme/website', 'GitHub Repository', 'ACTIVE'),
('e5eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'REPOSITORY', 'https://github.com/acme/api', 'GitHub Repository', 'ACTIVE'),
('e6eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DOCUMENTATION', 'https://api.acme.com/docs', 'API Documentation', 'ACTIVE');

-- =====================================================
-- Summary
-- =====================================================
-- This seed data includes:
-- - 1 Organization (Acme Corporation)
-- - 5 Users (1 Admin, 1 Manager, 2 Developers, 1 QA)
-- - 3 Projects (Mobile App, Website, API)
-- - 5 Sprints across projects
-- - 6 Tags for categorization
-- - 10 Tasks with various statuses
-- - Task-Tag mappings
-- - 3 Task links (dependencies)
-- - 4 Comments (including threaded reply)
-- - 8 Time logs
-- - 8 Daily summaries with color indicators
-- - 5 Resource costs
-- - 6 Project links

-- IMPORTANT: Replace 'your-azure-tenant-id-here' with your actual Azure Tenant ID
-- for the authentication to work properly.
