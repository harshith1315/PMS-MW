export const ACCESS_CONTROL_PERMISSIONS = [
  // Organization
  "VIEW_ORGANIZATION",
  "EDIT_ORGANIZATION",
  "DELETE_ORGANIZATION",
  "MANAGE_USERS",
  "MANAGE_BUSINESS_UNITS",

  // Business Unit
  "VIEW_BUSINESS_UNIT",
  "CREATE_BUSINESS_UNIT",
  "EDIT_BUSINESS_UNIT",
  "DELETE_BUSINESS_UNIT",

  // User
  "VIEW_USER",
  "EDIT_USER",
  "EDIT_USER_ROLE",
  "EDIT_USER_STATUS",

  // Project
  "CREATE_PROJECT",
  "VIEW_PROJECT",
  "EDIT_PROJECT",
  "DELETE_PROJECT",
  "EDIT_PROJECT_DETAILS",
  "VIEW_PROJECT_DETAILS",
  "VIEW_TECH_STACK",
  "EDIT_TECH_STACK",
  "VIEW_DEPENDENCIES",
  "EDIT_DEPENDENCIES",
  "VIEW_BUDGET",
  "VIEW_FINANCE",
  "VIEW_FINANCE_CODE",

  // Task
  "CREATE_TASK",
  "EDIT_TASK",
  "DELETE_TASK",

  // Comment
  "CREATE_COMMENT",
  "EDIT_COMMENT",
  "DELETE_COMMENT",

  // Attachment
  "VIEW_ATTACHMENT",
  "CREATE_ATTACHMENT",
  "DELETE_ATTACHMENT",

  // Sprint
  "VIEW_SPRINT",
  "MANAGE_SPRINT",

  // Link
  "MANAGE_LINKS",

  // Leadership
  "MANAGE_LEADERSHIP",

  // User Assignment
  "ASSIGN_USERS",

  // Reports
  "VIEW_REPORTS",
  "VIEW_TEAM_TIMESHEETS",

  // Time Tracking
  "LOG_TIME",

  // Activity Logs
  "VIEW_ACTIVITY_LOGS",

  // Board & Tasks
  "VIEW_BOARD",
  "VIEW_TASK",
  "VIEW_BACKLOG",
] as const;

export type AccessControlPermission =
  (typeof ACCESS_CONTROL_PERMISSIONS)[number];

export const SYSTEM_ROLE_KEYS = [
  "ADMIN",
  "ORG_ADMIN",
  "CEO",
  "MANAGER",
  "DEVELOPER",
  "USER",
] as const;

export type SystemRoleKey = (typeof SYSTEM_ROLE_KEYS)[number];
