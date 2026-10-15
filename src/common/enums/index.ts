/**
 * User roles within an organization
 */
export enum UserRole {
  ORG_ADMIN = 'ORG_ADMIN',
  USER = 'USER',
}

/**
 * Platform user roles (super admin)
 */
export enum PlatformRole {
  SUPER_ADMIN = 'SUPER_ADMIN',
}

/**
 * Project roles for user-project mapping
 */
export enum ProjectRole {
  DEV = 'DEV',
  QA = 'QA',
  SCRUM_MASTER = 'SCRUM_MASTER',
  FINANCE = 'FINANCE',
  INFRA = 'INFRA',
  MANAGER = 'MANAGER',
}

/**
 * Resource allocation type for project staffing
 */
export enum ResourceType {
  SHARED = 'SHARED',
  DEDICATED = 'DEDICATED',
}

/**
 * Entity status values
 */
export enum Status {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  DELETED = 'DELETED',
}

/**
 * Task types
 */
export enum TaskType {
  STORY = 'STORY',
  BUG = 'BUG',
  TASK = 'TASK',
  SPIKE = 'SPIKE',
  EPIC = 'EPIC',
  SUB_TASK = 'SUB_TASK',
}

/**
 * Task status
 */
export enum TaskStatus {
  TODO = 'TODO',
  IN_PROGRESS = 'IN_PROGRESS',
  IN_REVIEW = 'IN_REVIEW',
  QA = 'QA',
  DONE = 'DONE',
  BLOCKED = 'BLOCKED',
}

/**
 * Task priority
 */
export enum TaskPriority {
  CRITICAL = 'CRITICAL',
  HIGH = 'HIGH',
  MEDIUM = 'MEDIUM',
  LOW = 'LOW',
}

/**
 * Sprint status
 */
export enum SprintStatus {
  PLANNED = 'PLANNED',
  ACTIVE = 'ACTIVE',
  COMPLETED = 'COMPLETED',
}

/**
 * Task link types
 */
export enum TaskLinkType {
  BLOCKS = 'BLOCKS',
  BLOCKED_BY = 'BLOCKED_BY',
  DEPENDS_ON = 'DEPENDS_ON',
  RELATES_TO = 'RELATES_TO',
  DUPLICATES = 'DUPLICATES',
  PARENT_OF = 'PARENT_OF',
  CHILD_OF = 'CHILD_OF',
}

/**
 * Project link types
 */
export enum ProjectLinkType {
  SHAREPOINT = 'SHAREPOINT',
  APP_URL = 'APP_URL',
  GIT = 'GIT',
  CONFLUENCE = 'CONFLUENCE',
  JIRA = 'JIRA',
  OTHER = 'OTHER',
}

/**
 * Daily summary status colors
 */
export enum StatusColor {
  RED = 'RED',       // 0 hours logged
  YELLOW = 'YELLOW', // < 8 hours logged
  GREEN = 'GREEN',   // = 8 hours logged
  PURPLE = 'PURPLE', // > 8 hours logged
}
