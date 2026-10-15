# Onelign PMS - Multi-tenant Agile Project Management System

A NestJS backend for a multi-tenant Agile Project Management system with email/password authentication, AWS S3 file storage, and comprehensive Swagger documentation.

## Features

- **Multi-tenant Architecture**: All data is scoped by organization (tenant)
- **Email/password authentication**: scrypt password hashes, single-use setup links, and short-lived application JWTs
- **Role-based Access Control**: ADMIN, ORG_ADMIN, MANAGER, USER roles with project-level roles
- **Agile Project Management**: Projects, Sprints, Tasks (Epic, Story, Bug, Sub-task)
- **Task Code Generation**: Auto-generated codes like PROJECT-1, PROJECT-2 (transaction-safe)
- **Time Tracking**: Daily logging with validation (max 12h/day, no future dates), stored as minutes
- **Daily Summaries**: Color-coded productivity indicators (RED/YELLOW/GREEN/PURPLE)
- **File Attachments**: AWS S3 integration with direct multipart upload and pre-signed URLs
- **Task Relationships**: Links (BLOCKS, DEPENDS_ON, DUPLICATES, etc.)
- **Threaded Comments**: Nested comment system on tasks
- **User Invite**: ORG_ADMIN can invite users to the organization by email

## Tech Stack

- **Framework**: NestJS 10.3
- **Database**: PostgreSQL with TypeORM 0.3
- **Authentication**: Passport JWT with locally signed access tokens
- **Storage**: AWS S3 (SDK v3)
- **Validation**: class-validator + class-transformer
- **Documentation**: Swagger/OpenAPI

## Prerequisites

- Node.js 18+
- PostgreSQL 14+
- AWS S3 bucket

## Installation

```bash
# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
```

## Environment Variables

```env
# Application
NODE_ENV=development
PORT=3000

# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your-password
DATABASE_NAME=onelign_pms
DATABASE_SSL=false

# Generate a different random value of at least 32 bytes for each environment.
JWT_SECRET=replace-with-a-random-secret-at-least-32-bytes-long
FRONTEND_BASE_URL=http://localhost:5173

# AWS S3
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=your-bucket-name
AWS_S3_SIGNED_URL_EXPIRES=3600

# OpenAI (backend only)
OPENAI_API_KEY=your-openai-api-key
OPENAI_MODEL=gpt-4o-mini
# Optional for proxy/Azure OpenAI style endpoints
OPENAI_BASE_URL=
# Optional generation tuning
OPENAI_MAX_TOKENS=320
OPENAI_TEMPERATURE=0.1
```

## AI Provider Setup

1. Create an API key from your OpenAI account or use your organization proxy endpoint.
2. Set `OPENAI_API_KEY` and `OPENAI_MODEL` in `.env`.
3. If routing through a proxy or Azure OpenAI compatible endpoint, set `OPENAI_BASE_URL`.
4. Keep API keys in backend env only. Do not expose keys in frontend variables.

## Database Setup

The application uses TypeORM with `synchronize: false`. You must create the database schema manually using the provided DDL:

```bash
# First, create the database
createdb onelign_pms

# Run the DDL script against your PostgreSQL database
# On macOS (Homebrew PostgreSQL) - uses your system username:
psql -d onelign_pms -f scripts/ddl.sql

# On Linux/Docker with postgres user:
psql -h localhost -U postgres -d onelign_pms -f scripts/ddl.sql
```

**Note:** On macOS with Homebrew PostgreSQL, the default superuser is your system username, not `postgres`.

### Seed Data (Optional)

To populate the database with sample data for testing:

```bash
# On macOS (Homebrew PostgreSQL):
psql -d onelign_pms -f scripts/seed.sql

# On Linux/Docker:
psql -h localhost -U postgres -d onelign_pms -f scripts/seed.sql
```

**Important:** Edit `scripts/seed.sql` and replace `your-azure-tenant-id-here` with your actual Azure Tenant ID.

The seed data includes:

- 1 Organization, 5 Users (Admin, Manager, Developers, QA)
- 3 Projects with sprints and task sequences
- 10 Tasks with tags, comments, and links
- Time logs and daily summaries

## Running the Application

```bash
# Development
npm run start:dev

# Production
npm run build
npm run start:prod
```

## API Documentation

Once running, access Swagger UI at:

- **Swagger UI**: http://localhost:3000/api/docs
- **OpenAPI JSON**: http://localhost:3000/api/docs-json

## AI Migration Validation Checklist

- Boot backend with missing `OPENAI_API_KEY` and verify clear configuration warning.
- Test chat send endpoint: `POST /api/v1/chat/sessions/:sessionId/messages`.
- Test chat stream behavior from the same endpoint (SSE events: status/chunk/result).
- Test task summary endpoint: `POST /api/v1/tasks/:id/summarize` and `POST /api/v1/chat/task-summary`.
- Verify frontend chat UX remains unchanged (session/history/streaming flow).
- Run backend and frontend build/lint in CI before release.

## Rollout Notes

- Keep OpenAI credentials only in backend deployment secrets.
- Optionally roll out in stages by enabling AI features first in non-production environments.
- Monitor first-release error rate, response latency, and token usage/cost.

## Postman Collection

Import the Postman collection from `postman/onelign-pms-api.postman_collection.json`

Set the following variables:

- `base_url`: http://localhost:3000/api
- `access_token`: Your application JWT access token

## Authentication Flow

1. An organization administrator invites a user. The API returns a one-time setup token; share the generated setup link with the user through a trusted channel.
2. The user chooses a password of at least 12 characters. The setup link expires after 48 hours and can be used only once.
3. The user signs in at the frontend. The backend verifies the password hash and issues a 15-minute JWT.
4. The frontend sends that token in the `Authorization: Bearer <access_token>` header. Each request validates the token and checks that the user and organization are still active.

Apply `database/migrations/20261006_add_password_auth.sql` before starting the updated backend. Existing user accounts have no password until they complete setup. To issue a one-time setup link for an existing account before an administrator can sign in, run from the backend directory:

```bash
node scripts/generate-password-setup-link.js <org-id> <email>
```

The script updates only the matching active user and prints a link that expires after 48 hours. Deliver it privately. User invitations and organization creation also return setup links in the UI; the application does not send invitation email.

Protect `JWT_SECRET` as a deployment secret and use a different random secret in each environment. Login is limited to five attempts per minute per client IP.
## Roles

| Role        | Description                                                                        |
| ----------- | ---------------------------------------------------------------------------------- |
| `ADMIN`     | Platform-wide administrator                                                        |
| `ORG_ADMIN` | Organization administrator — can invite users, manage org settings, view dashboard |
| `MANAGER`   | Can create projects, manage team members, view all org projects and tasks          |
| `USER`      | Standard user — limited to assigned projects and tasks                             |

### Project-level Roles (per project team membership)

`DEV`, `QA`, `SCRUM_MASTER`, `FINANCE`, `INFRA`, `MANAGER`

## API Endpoints

### Auth

- `POST /api/v1/auth/login` - Sign in with `{ "email": "...", "password": "..." }`
- `POST /api/v1/auth/set-password` - Set a password using `{ "token": "...", "password": "..." }`
- `GET /api/v1/auth/me` - Get current user profile
- `GET /api/v1/auth/verify` - Verify token validity

### Users

- `GET /api/v1/users/me` - Get my profile
- `PATCH /api/v1/users/me` - Update my profile
- `GET /api/v1/users/me/projects` - Get my projects
- `GET /api/v1/users/me/daily-summaries` - Get my daily summaries
- `POST /api/v1/users/invite` - Invite a user by email `(ORG_ADMIN)` — body: `{ "email": "..." }`
- `GET /api/v1/users` - List all users `(ORG_ADMIN, MANAGER)`
- `PATCH /api/v1/users/:id/role` - Update user role `(ORG_ADMIN)`
- `PATCH /api/v1/users/:id/status` - Activate/Deactivate user `(ORG_ADMIN)`

### Organization

- `GET /api/v1/organizations/dashboard` - Get org dashboard `(ADMIN, ORG_ADMIN)`
- `GET /api/v1/organizations/current` - Get my organization
- `PATCH /api/v1/organizations/current` - Update organization `(ORG_ADMIN)`
- `GET /api/v1/organizations/current/stats` - Get organization stats

### Projects

- `POST /api/v1/projects` - Create project `(ORG_ADMIN, MANAGER)`
- `GET /api/v1/projects` - List projects
- `GET /api/v1/projects/:id` - Get project details (includes `teamSize`, `activeSprint`)
- `PATCH /api/v1/projects/:id` - Update project
- `POST /api/v1/projects/:id/team` - Add team member by email `(ORG_ADMIN, MANAGER)` — body: `{ "email": "...", "projectRole": "DEV" }`
- `GET /api/v1/projects/:id/team` - Get team members
- `DELETE /api/v1/projects/:id/team/:userId` - Remove team member `(ORG_ADMIN, MANAGER)`

### Sprints

- `POST /api/v1/sprints` - Create sprint — body: `{ "projectId", "sprintName", "goal", "startDate", "endDate" }`
- `GET /api/v1/sprints` - List sprints
- `PATCH /api/v1/sprints/:id` - Update sprint
- `PATCH /api/v1/sprints/:id/start` - Start sprint (sets status to ACTIVE)
- `PATCH /api/v1/sprints/:id/complete` - Complete sprint

### Tasks

- `POST /api/v1/tasks` - Create task (auto-generates task code)
- `GET /api/v1/tasks` - List tasks with filters
- `GET /api/v1/tasks/:id` - Get task details (includes `totalHoursLogged`, attachments, comments)
- `GET /api/v1/tasks/code/:taskCode` - Get task by code (e.g., `MOB-1`)
- `PUT /api/v1/tasks/:id` - Update task (all fields optional)
- `PATCH /api/v1/tasks/:id/status` - Update task status — body: `{ "status": "IN_PROGRESS" }`
- `PATCH /api/v1/tasks/:id/assign` - Assign task — body: `{ "userId": "uuid" }`
- `PATCH /api/v1/tasks/:id/sprint` - Move task to sprint — body: `{ "sprintId": "uuid" }`
- `DELETE /api/v1/tasks/:id` - Delete task

**Task enums:**

- `taskType`: `STORY`, `BUG`, `TASK`, `SPIKE`, `EPIC`, `SUB_TASK`
- `status`: `TODO`, `IN_PROGRESS`, `IN_REVIEW`, `QA`, `DONE`, `BLOCKED`
- `priority`: `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`

### Time Logs

- `POST /api/v1/time-logs` - Log time — body: `{ "taskId", "logDate": "YYYY-MM-DD", "hoursLogged": 8, "description": "..." }`
- `GET /api/v1/time-logs` - List time logs
- `GET /api/v1/time-logs/my-logs` - Get my time logs
- `GET /api/v1/time-logs/daily-summary` - Get daily summary with color
- `PUT /api/v1/time-logs/:id` - Update time log
- `DELETE /api/v1/time-logs/:id` - Delete time log

> Time is stored as **minutes** internally. `hoursLogged` in the request is converted automatically (e.g., `8` → `480`). Max 12 hours (720 minutes) per day. No future dates allowed.

### Comments

- `POST /api/v1/comments` - Add comment — body: `{ "taskId", "comment", "parentCommentId"? }`
- `GET /api/v1/comments/task/:taskId` - Get task comments (threaded)
- `PATCH /api/v1/comments/:id` - Update comment
- `DELETE /api/v1/comments/:id` - Delete comment

### Attachments

- `POST /api/v1/attachments/upload/:taskId` - Direct multipart upload (`multipart/form-data`, field: `file`)
- `POST /api/v1/attachments/upload-url` - Get pre-signed S3 upload URL — body: `{ "taskId", "fileName", "fileType" }`
- `POST /api/v1/attachments/confirm-upload` - Confirm S3 upload — body: `{ "taskId", "key", "fileName" }`
- `GET /api/v1/attachments/task/:taskId` - List task attachments
- `GET /api/v1/attachments/:id` - Get attachment by ID
- `GET /api/v1/attachments/:id/download` - Get pre-signed download URL
- `DELETE /api/v1/attachments/:id` - Delete attachment

### Task Links

- `POST /api/v1/task-links` - Create link
- `GET /api/v1/task-links/task/:taskId` - Get task links
- `GET /api/v1/task-links/task/:taskId/blocking` - Get blocking tasks
- `GET /api/v1/task-links/task/:taskId/dependent` - Get dependent tasks
- `DELETE /api/v1/task-links/:id` - Delete link

### Tags

- `POST /api/v1/tags` - Create tag
- `GET /api/v1/tags` - List tags
- `PATCH /api/v1/tags/:id` - Update tag
- `DELETE /api/v1/tags/:id` - Delete tag (fails if in use)

## Project Structure

```
src/
├── common/
│   ├── decorators/
│   │   ├── current-user.decorator.ts
│   │   └── roles.decorator.ts
│   ├── enums/
│   │   └── index.ts
│   ├── guards/
│   │   ├── microsoft-auth.guard.ts
│   │   ├── tenant.guard.ts
│   │   ├── roles.guard.ts
│   │   └── project-access.guard.ts
│   ├── interceptors/
│   │   └── logging.interceptor.ts
│   └── services/
│       └── s3.service.ts
├── config/
│   ├── app.config.ts
│   ├── database.config.ts
│   ├── microsoft.config.ts
│   └── aws.config.ts
├── entities/
│   ├── platform-user.entity.ts
│   ├── organization.entity.ts
│   ├── app-user.entity.ts
│   ├── project.entity.ts
│   ├── user-project-mapping.entity.ts
│   ├── sprint.entity.ts
│   ├── project-task-sequence.entity.ts
│   ├── task.entity.ts
│   ├── tag.entity.ts
│   ├── attachment.entity.ts
│   ├── task-comment.entity.ts
│   ├── task-link.entity.ts
│   ├── time-log.entity.ts
│   ├── user-daily-summary.entity.ts
│   ├── resource-cost.entity.ts
│   ├── project-cost.entity.ts
│   ├── project-link.entity.ts
│   └── index.ts
├── modules/
│   ├── auth/
│   ├── organization/
│   ├── project/
│   ├── sprint/
│   ├── task/
│   ├── time-log/
│   ├── comment/
│   ├── attachment/
│   ├── task-link/
│   ├── user/
│   └── tag/
├── app.module.ts
└── main.ts
```

## Security Features

- **Tenant Isolation**: All queries automatically filter by `org_id`
- **Role-based Access**: ADMIN, ORG_ADMIN, MANAGER, USER with decorator-based enforcement
- **Project Access Guard**: Validates user-project membership
- **JWT Validation**: Short-lived locally signed application JWTs

## Daily Summary Color Logic

| Color  | Condition               |
| ------ | ----------------------- |
| RED    | 0 minutes logged        |
| YELLOW | < 480 minutes (8 hours) |
| GREEN  | = 480 minutes (8 hours) |
| PURPLE | > 480 minutes (8 hours) |

## License

Private - All rights reserved
