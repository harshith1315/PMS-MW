import { Injectable } from "@nestjs/common";

export type ChatIntent =
  | "GREETING"
  | "FAREWELL"
  | "ANALYTICS"
  | "PROJECTS"
  | "TASKS"
  | "LEADERSHIP"
  | "USERS"
  | "GENERAL";

export interface ChatContextData {
  intent: ChatIntent;
  user: {
    name: string;
    firstName?: string;
    role: string;
    email: string;
  };
  projects: Array<{
    name: string;
    description?: string;
    projectCode?: string;
    status?: string;
    managerName?: string;
    businessUnit?: string;
  }>;
  sprint?: {
    name: string;
    startDate: string;
    endDate: string;
  };
  tasks: Array<{
    title: string;
    status: string;
    priority: string;
    dueDate: string | null;
  }>;
  leaders?: Array<{
    name: string;
    email: string;
    role: string;
    projectCount: number;
  }>;
  users?: Array<{
    name: string;
    email: string;
    role: string;
    status: string;
    isLeader: boolean;
    isManager: boolean;
  }>;
  history: Array<{
    role: "user" | "assistant";
    content: string;
  }>;
  analytics?: {
    totalProjects: number;
    projectStatusDistribution: Array<{ status: string; count: number }>;
    businessUnitDistribution: Array<{ bu: string; count: number }>;
    taskStats: {
      total: number;
      completed: number;
      completionRate: number;
    };
    businessUnitDetails?: Array<{
      name: string;
      ownerName: string;
      status: string;
    }>;
  };
  message: string;
}

export interface TaskSummaryContextData {
  task: {
    title: string;
    status: string;
    priority: string;
    dueDate: string | null;
    description: string | null;
  };
  comments: Array<{
    userName: string;
    text: string;
  }>;
}

@Injectable()
export class ContextBuilderService {
  /**
   * Builds rich contextual prompt for chat with project/task/user data
   * Production-ready prompt template with personalization and constraints
   * Limits data to prevent token overflow (5 tasks, 10 history items)
   */
  buildChatContext(data: ChatContextData): string {
    // Extract first name for personalized greeting
    const firstName = data.user.firstName || data.user.name.split(" ")[0];

    // Format assigned tasks
    const tasksSection =
      data.tasks.length > 0
        ? data.tasks
            .map(
              (t) =>
                `- ${t.title} (status: ${t.status}, priority: ${t.priority}, deadline: ${t.dueDate || "Not set"})`,
            )
            .join("\n")
        : "- No assigned tasks";

    // Format project context (description omitted — rarely useful in chat, saves tokens)
    const projectSection =
      data.projects && data.projects.length > 0
        ? `\nACTIVE PROJECTS:\n${data.projects.map((p) => `- ${p.name} (${p.projectCode || "N/A"}), business unit: ${p.businessUnit || "N/A"}, status: ${p.status || "N/A"}, manager: ${p.managerName || "Unassigned"}`).join("\n")}`
        : "- No active projects or unable to retrieve projects.";

    // Format sprint context
    const sprintSection = data.sprint
      ? `\nSPRINT CONTEXT:\n- Sprint: ${data.sprint.name}\n- Duration: ${data.sprint.startDate} to ${data.sprint.endDate}`
      : "";

    // Format analytics context
    const analyticsSection = data.analytics
      ? `\nANALYTICS SUMMARY:\n- Total Projects: ${data.analytics.totalProjects}\n- Project Statuses: ${data.analytics.projectStatusDistribution.map((s) => `${s.status}: ${s.count}`).join(", ")}\n- Business Unit Split: ${data.analytics.businessUnitDistribution.map((b) => `${b.bu}: ${b.count}`).join(", ")}\n- Business Units & Owners: ${data.analytics.businessUnitDetails?.map((bu) => `${bu.name} (Owner: ${bu.ownerName})`).join(", ") || "N/A"}\n- Task Overview: ${data.analytics.taskStats.completed}/${data.analytics.taskStats.total} tasks completed (${data.analytics.taskStats.completionRate}%)`
      : "";

    const leadershipSection =
      data.leaders && data.leaders.length > 0
        ? `\nLEADERSHIP TEAM:\n${data.leaders
            .map(
              (leader) =>
                `- ${leader.name} (${leader.email}), role: ${leader.role}, managed projects: ${leader.projectCount}`,
            )
            .join("\n")}`
        : "";

    const usersSection =
      data.users && data.users.length > 0
        ? `\nUSERS LIST:\n${data.users
            .map(
              (user) =>
                `- ${user.name} (${user.email}), role: ${user.role}, status: ${user.status}${user.isLeader ? ", leadership" : ""}${user.isManager ? ", manager" : ""}`,
            )
            .join("\n")}`
        : "";

    // Format recent conversation history — cap each message at 120 chars to prevent
    // old long AI replies from bloating every new prompt (saves 100-300 tokens).
    const HISTORY_CONTENT_MAX = 120;
    const historySection =
      data.history.length > 0
        ? "\nCONVERSATION HISTORY (recent turns):\n" +
          data.history
            .map((h) => {
              const label = h.role === "user" ? "User" : "AI";
              const content =
                h.content.length > HISTORY_CONTENT_MAX
                  ? h.content.slice(0, HISTORY_CONTENT_MAX) + "…"
                  : h.content;
              return `${label}: ${content}`;
            })
            .join("\n")
        : "";

    // Only inject the data section that is relevant to the current intent
    let relevantDataSection = "";
    if (data.intent === "PROJECTS" && data.projects.length > 0) {
      relevantDataSection = projectSection;
    } else if (data.intent === "ANALYTICS" && data.analytics) {
      relevantDataSection = analyticsSection;
    } else if (data.intent === "TASKS" && data.tasks.length > 0) {
      relevantDataSection = `\nASSIGNED TASKS:\n${tasksSection}`;
    } else if (data.intent === "LEADERSHIP") {
      relevantDataSection =
        leadershipSection || "\nLEADERSHIP TEAM:\n- No active leaders found";
    } else if (data.intent === "USERS") {
      relevantDataSection =
        usersSection || "\nUSERS LIST:\n- No active users found";
    }
    // For GREETING, FAREWELL and GENERAL, inject no heavy data blocks

    const farewell = data.intent === "FAREWELL";
    const fareRules = farewell
      ? "Provide a brief, warm farewell message wishing the user well. Keep it to 1-2 sentences."
      : "Answer only what is asked using only the data above. No hallucination. No email greetings or sign-offs. Greet by name only on the very first message. Confidential data (budget/finance) must never be disclosed. Max 6 lines unless listing.";

    return `You are Myra, a concise AI assistant for a Project Management System.
User: ${firstName} (${data.user.role})
${relevantDataSection}
${historySection}
Q: ${data.message}
Rules: ${fareRules} Do not use pipe-delimited formatting (avoid "|"). Use polished natural language or clean bullet points. Start your answer immediately.`;
  }

  /**
   * Builds contextual prompt for task summary generation
   * Production-ready template for structured task analysis
   * Includes task details and recent comments
   */
  buildTaskSummaryContext(data: TaskSummaryContextData): string {
    const commentsSection =
      data.comments.length > 0
        ? data.comments.map((c) => `- ${c.userName}: ${c.text}`).join("\n")
        : "- No comments yet";

    return `You are an AI assistant for a Project Management System (PMS).

TASK DETAILS:
- Title: ${data.task.title}
- Status: ${data.task.status}
- Priority: ${data.task.priority}
- Deadline: ${data.task.dueDate || "Not set"}

DESCRIPTION:
${data.task.description || "No description provided"}

RECENT COMMENTS:
${commentsSection}

INSTRUCTIONS:
- Generate a structured summary
- Do NOT add information not provided
- Be concise and data-driven

OUTPUT FORMAT:

Overview:
- Current status in 1 sentence

Key Updates:
- List main points from comments

Risks / Blockers:
- Identify any issues or delays

Next Steps:
- Actionable next actions

CONSTRAINTS:
- Do NOT hallucinate data
- Use only provided context
- If unsure, respond with "Not enough information"`;
  }

  /**
   * Builds contextual prompt for sprint summary
   */
  buildSprintSummaryContext(data: any): string {
    const completedTasks = data.tasks.filter(
      (t: any) => t.status === "COMPLETED",
    ).length;
    const inProgressTasks = data.tasks.filter(
      (t: any) => t.status === "IN_PROGRESS",
    ).length;
    const blockedTasks = data.tasks.filter(
      (t: any) => t.status === "BLOCKED",
    ).length;

    const tasksBreakdown = `
Completed: ${completedTasks}
In Progress: ${inProgressTasks}
Blocked: ${blockedTasks}
Total: ${data.tasks.length}
`;

    const blockersSection =
      data.blockers.length > 0
        ? data.blockers.map((b: any) => `- ${b.title}: ${b.reason}`).join("\n")
        : "No blockers identified";

    return `You are an AI assistant for a Project Management System. Provide a sprint summary.

Sprint: ${data.sprintName}
Duration: ${data.startDate} to ${data.endDate}

Task Breakdown:
${tasksBreakdown}

Blockers:
${blockersSection}

Team Velocity: ${data.velocity}%

Provide a summary with:
1. Sprint Health (1 sentence)
2. Achievements (what's completed)
3. Risks (blockers or delays)
4. Recommendations (for next sprint)

Be strategic and data-driven.`;
  }
}
