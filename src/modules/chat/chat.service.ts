import {
  BadRequestException,
  InternalServerErrorException,
  Injectable,
  Logger,
  NotFoundException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { InjectRepository } from "@nestjs/typeorm";
import { randomUUID } from "crypto";
import { Repository } from "typeorm";
import {
  ChatMessage as ChatMessageEntity,
  ChatMessageRole,
  ChatSession,
  Task,
  Project,
  TaskComment,
  AppUser,
  BusinessUnit,
} from "../../entities";
import {
  ContextBuilderService,
  ChatContextData,
  TaskSummaryContextData,
} from "./context-builder.service";
import { LlmService } from "./llm.service";
import { AccessControlService } from "../access-control/access-control.service";
import { UserContext } from "../auth/auth.service";

export type ChatRole = "user" | "assistant";

export interface ChatMessage {
  id: string;
  role: ChatRole;
  text: string;
  createdAt: string;
}

@Injectable()
export class ChatService {
  private readonly logger = new Logger(ChatService.name);
  private static readonly MAX_HISTORY_SESSIONS = 10;
  private static readonly MAX_TASKS_CONTEXT = 3; // 5→3: fewer task lines in prompt
  private static readonly MAX_HISTORY_CONTEXT = 4; // 8→4 turns: ~half the history tokens
  private static readonly MAX_HISTORY_CONTEXT_FACTUAL = 2; // 4→2: factual queries need almost no history
  private static readonly MAX_COMMENTS_CONTEXT = 5;
  private static readonly MAX_LEADERS_CONTEXT = 20;
  private static readonly MAX_USERS_CONTEXT = 30;
  private static readonly USER_DIRECTORY_QUERY_PATTERN =
    /\b(user|users|employee|employees|staff|directory|team members?|member list|employee list|people in the team|profiles?)\b|\b(show|list|give|tell|find|fetch|get)\b.{0,40}\b(users?|employees?|staff|people|profiles?)\b|\b(details?|info|information|email|emails|contact|contacts)\b.{0,40}\b(users?|employees?|staff|people|profiles?)\b/i;

  constructor(
    @InjectRepository(ChatSession)
    private readonly sessionRepository: Repository<ChatSession>,
    @InjectRepository(ChatMessageEntity)
    private readonly messageRepository: Repository<ChatMessageEntity>,
    @InjectRepository(Task)
    private readonly taskRepository: Repository<Task>,
    @InjectRepository(Project)
    private readonly projectRepository: Repository<Project>,
    @InjectRepository(TaskComment)
    private readonly commentRepository: Repository<TaskComment>,
    @InjectRepository(AppUser)
    private readonly userRepository: Repository<AppUser>,
    @InjectRepository(BusinessUnit)
    private readonly businessUnitRepository: Repository<BusinessUnit>,
    private readonly contextBuilder: ContextBuilderService,
    private readonly configService: ConfigService,
    private readonly llmService: LlmService,
    private readonly accessControlService: AccessControlService,
  ) {}

  async createSession(
    orgId: string,
    userId: string,
  ): Promise<{ sessionId: string; startedAt: string }> {
    const activeSession = await this.sessionRepository
      .createQueryBuilder("session")
      .where("session.org_id = :orgId", { orgId })
      .andWhere("session.user_id = :userId", { userId })
      .andWhere("session.ended_at IS NULL")
      .orderBy("session.started_at", "DESC")
      .getOne();

    if (activeSession) {
      return {
        sessionId: activeSession.id,
        startedAt: activeSession.startedAt.toISOString(),
      };
    }

    const created = this.sessionRepository.create({
      id: randomUUID(),
      orgId,
      userId,
      title: "New conversation",
      endedAt: null,
    });

    const saved = await this.sessionRepository.save(created);

    return {
      sessionId: saved.id,
      startedAt: saved.startedAt.toISOString(),
    };
  }

  async listHistory(orgId: string, userId: string) {
    const sessions = await this.sessionRepository
      .createQueryBuilder("session")
      .where("session.org_id = :orgId", { orgId })
      .andWhere("session.user_id = :userId", { userId })
      .andWhere("session.ended_at IS NOT NULL")
      .orderBy("session.ended_at", "DESC")
      .addOrderBy("session.started_at", "DESC")
      .take(ChatService.MAX_HISTORY_SESSIONS)
      .getMany();

    if (sessions.length === 0) {
      return [];
    }

    const sessionIds = sessions.map((session) => session.id);

    const [messageCountsRaw, lastMessagesRaw] = await Promise.all([
      this.messageRepository
        .createQueryBuilder("message")
        .select("message.session_id", "sessionId")
        .addSelect("COUNT(1)", "messageCount")
        .where("message.session_id IN (:...sessionIds)", { sessionIds })
        .groupBy("message.session_id")
        .getRawMany<{ sessionId: string; messageCount: string }>(),
      this.messageRepository
        .createQueryBuilder("message")
        .distinctOn(["message.session_id"])
        .select("message.session_id", "sessionId")
        .addSelect("message.text", "lastMessageText")
        .where("message.session_id IN (:...sessionIds)", { sessionIds })
        .orderBy("message.session_id", "ASC")
        .addOrderBy("message.created_at", "DESC")
        .getRawMany<{ sessionId: string; lastMessageText: string }>(),
    ]);

    const messageCountBySessionId = new Map<string, number>(
      messageCountsRaw.map((row) => [row.sessionId, Number(row.messageCount)]),
    );
    const lastMessageTextBySessionId = new Map<string, string>(
      lastMessagesRaw.map((row) => [row.sessionId, row.lastMessageText]),
    );

    return sessions.map((session) => ({
      id: session.id,
      title: session.title,
      startedAt: session.startedAt.toISOString(),
      endedAt: (session.endedAt || session.startedAt).toISOString(),
      messageCount: messageCountBySessionId.get(session.id) ?? 0,
      lastMessagePreview: lastMessageTextBySessionId.get(session.id) ?? "",
    }));
  }

  async getSessionMessages(
    orgId: string,
    userId: string,
    sessionId: string,
  ): Promise<ChatMessage[]> {
    await this.assertSessionOwnedByUser(orgId, userId, sessionId);

    const messages = await this.messageRepository.find({
      where: { sessionId },
      order: { createdAt: "ASC" },
    });

    return messages.map((message) => this.mapMessage(message));
  }

  async sendMessage(
    orgId: string,
    userId: string,
    sessionId: string,
    text: string,
    res?: any,
  ) {
    const activeSession = await this.sessionRepository
      .createQueryBuilder("session")
      .where("session.id = :sessionId", { sessionId })
      .andWhere("session.org_id = :orgId", { orgId })
      .andWhere("session.user_id = :userId", { userId })
      .andWhere("session.ended_at IS NULL")
      .getOne();

    if (!activeSession) {
      throw new BadRequestException(
        "Active chat session not found. Start a new session first.",
      );
    }

    const userText = text.trim();
    if (!userText) {
      if (res) {
        res.status(400).send("Message cannot be empty");
        return;
      }
      throw new BadRequestException("Message cannot be empty");
    }

    if (res) {
      res.setHeader("Content-Type", "text/event-stream");
      res.setHeader("Cache-Control", "no-cache, no-transform");
      res.setHeader("Connection", "keep-alive");
      res.setHeader("X-Accel-Buffering", "no");
      res.flushHeaders?.();
      res.write(
        `data: ${JSON.stringify({ type: "status", message: "Analyzing query intent..." })}\n\n`,
      );
      if (typeof res.flush === "function") res.flush();
    }

    const userData = await this.userRepository.findOne({
      where: { id: userId, orgId },
    });
    if (!userData) {
      if (res) {
        res.write(
          `data: ${JSON.stringify({ type: "error", message: "User not found" })}\n\n`,
        );
        if (typeof res.flush === "function") res.flush();
        res.end();
        return;
      }
      throw new NotFoundException("User not found");
    }

    const lowerText = userText.toLowerCase();
    const currentUserContext: UserContext = {
      userId,
      orgId,
      email: userData.email,
      name: userData.name || "",
      role: userData.role || "USER",
      externalId: userData.id,
    };
    const effectivePermissions = new Set<string>(
      await this.accessControlService.getEffectivePermissions(
        currentUserContext,
      ),
    );
    const hasPermission = (permissionKey: string): boolean =>
      effectivePermissions.has(permissionKey);

    const greetings = [
      "hi",
      "hello",
      "hey",
      "good morning",
      "good afternoon",
      "good evening",
    ];
    const farewells = [
      "bye",
      "goodbye",
      "see you",
      "see ya",
      "take care",
      "thanks",
      "thank you",
    ];
    const isGreeting =
      greetings.some((g) => lowerText.startsWith(g)) ||
      lowerText === "hi" ||
      lowerText === "hello" ||
      /\bwho are you\b|\btell me about yourself\b|\bwhat is myra\b|\bintroduce yourself\b|\bwhat can you do\b|what's your name\b/i.test(
        lowerText,
      );
    const isFarewell =
      farewells.some((f) => lowerText.startsWith(f)) || lowerText === "bye";

    // Agentic Intent Classification
    let fetchProjects = false;
    let fetchAnalytics = false;
    let fetchTasks = false;
    let fetchLeadership = false;
    let fetchUsers = false;

    const isLeadershipQuery =
      /\bleader(ship)?\b|\bteam lead\b|\bwho leads\b|\bwho manages\b|\bmanagement team\b|\bleadership team\b/i.test(
        lowerText,
      );
    const isUsersQuery = this.isUserDirectoryQuery(lowerText);
    const isFactualIntent =
      isLeadershipQuery ||
      isUsersQuery ||
      lowerText.includes("business unit") ||
      lowerText === "bu";

    if (isGreeting || isFarewell) {
      if (res) {
        res.write(
          `data: ${JSON.stringify({ type: "status", message: "Composing response..." })}\n\n`,
        );
        if (typeof res.flush === "function") res.flush();
      }
    } else if (isLeadershipQuery) {
      if (res) {
        res.write(
          `data: ${JSON.stringify({ type: "status", message: "Looking up leadership team members..." })}\n\n`,
        );
        if (typeof res.flush === "function") res.flush();
      }
      fetchLeadership = true;
    } else if (isUsersQuery) {
      if (res) {
        res.write(
          `data: ${JSON.stringify({ type: "status", message: "Fetching active users list..." })}\n\n`,
        );
        if (typeof res.flush === "function") res.flush();
      }
      fetchUsers = true;
    } else if (
      lowerText.includes("project") ||
      lowerText.includes("progress")
    ) {
      if (res) {
        res.write(
          `data: ${JSON.stringify({ type: "status", message: "Verifying project access control..." })}\n\n`,
        );
        if (typeof res.flush === "function") res.flush();
      }
      fetchProjects = true;
    } else if (
      lowerText.includes("finance") ||
      lowerText.includes("budget") ||
      lowerText.includes("analytic") ||
      lowerText.includes("cost") ||
      lowerText.includes("business unit") ||
      lowerText.includes("bussniess unit") ||
      lowerText.includes("bussiness unit") ||
      lowerText.includes("performance") ||
      lowerText.includes("stat") ||
      lowerText.includes("portfolio") ||
      lowerText.includes("ownership") ||
      lowerText.includes("bu ") ||
      lowerText === "bu"
    ) {
      if (res) {
        res.write(
          `data: ${JSON.stringify({ type: "status", message: "Gleaning organization structure..." })}\n\n`,
        );
        if (typeof res.flush === "function") res.flush();
      }
      fetchAnalytics = true;
    } else {
      if (res) {
        res.write(
          `data: ${JSON.stringify({ type: "status", message: "Aligning task queue..." })}\n\n`,
        );
        if (typeof res.flush === "function") res.flush();
      }
      fetchTasks = true;
    }

    let activeProjects: Project[] = [];
    let tasks: Task[] = [];
    let leaders: Array<{
      name: string;
      email: string;
      role: string;
      projectCount: number;
    }> = [];
    let users: Array<{
      name: string;
      email: string;
      role: string;
      status: string;
      isLeader: boolean;
      isManager: boolean;
    }> = [];
    let accessDeniedMsg = "";

    let currentIntent: any = "GENERAL";
    if (isGreeting) {
      currentIntent = "GREETING";
    } else if (isFarewell) {
      currentIntent = "FAREWELL";
    } else if (fetchLeadership) {
      currentIntent = "LEADERSHIP";
    } else if (fetchUsers) {
      currentIntent = "USERS";
    } else if (fetchAnalytics) {
      currentIntent = "ANALYTICS";
    } else if (fetchProjects) {
      currentIntent = "PROJECTS";
    } else if (fetchTasks) {
      currentIntent = "TASKS";
    }

    // Role-Based Access Control Evaluation
    const userRole = userData.role?.toUpperCase() || "";
    const isAdmin =
      userRole === "ADMIN" ||
      userRole === "ORG_ADMIN" ||
      userRole === "ORG ADMIN";

    // Concurrent Data Fetching
    const fetchPromises: Promise<any>[] = [];

    // Project Fetching
    if (fetchProjects) {
      if (!hasPermission("VIEW_PROJECT")) {
        if (res) {
          res.write(
            `data: ${JSON.stringify({ type: "status", message: "Access denied to Projects by permission policy." })}\n\n`,
          );
          if (typeof res.flush === "function") res.flush();
        }
        accessDeniedMsg =
          "The user is not authorized to access this information. Politely state they do not have access.";
      } else if (userData.isManager || userData.isLeader || isAdmin) {
        if (res) {
          res.write(
            `data: ${JSON.stringify({ type: "status", message: "Reading projects screens..." })}\n\n`,
          );
          if (typeof res.flush === "function") res.flush();
        }
        fetchPromises.push(
          this.projectRepository
            .find({
              where: { orgId, status: "ACTIVE" },
              relations: ["manager"],
              take: 10,
            })
            .then((data) => (activeProjects = data)),
        );
      } else {
        if (res) {
          res.write(
            `data: ${JSON.stringify({ type: "status", message: "Access denied to Projects block." })}\n\n`,
          );
          if (typeof res.flush === "function") res.flush();
        }
        accessDeniedMsg =
          "The user is not authorized to access this information. Politely state they do not have access.";
      }
    }

    let analyticsData = undefined;
    if (fetchAnalytics) {
      if (!hasPermission("VIEW_FINANCE")) {
        if (res) {
          res.write(
            `data: ${JSON.stringify({ type: "status", message: "Access denied to Analytics by permission policy." })}\n\n`,
          );
          if (typeof res.flush === "function") res.flush();
        }
        accessDeniedMsg =
          "The user is not authorized to access this information. Politely state they do not have access.";
      } else {
        if (res) {
          res.write(
            `data: ${JSON.stringify({ type: "status", message: "Discovering business units and owners..." })}\n\n`,
          );
          if (typeof res.flush === "function") res.flush();
        }

        fetchPromises.push(
          Promise.all([
            this.projectRepository.count({ where: { orgId } }),
            this.projectRepository
              .createQueryBuilder("p")
              .select("p.status", "status")
              .addSelect("COUNT(*)", "count")
              .where("p.org_id = :orgId", { orgId })
              .groupBy("p.status")
              .getRawMany(),
            this.projectRepository
              .createQueryBuilder("p")
              .select("p.businessUnit", "bu")
              .addSelect("COUNT(*)", "count")
              .where("p.org_id = :orgId", { orgId })
              .groupBy("p.businessUnit")
              .getRawMany(),
            this.taskRepository
              .createQueryBuilder("t")
              .select("COUNT(*)", "total")
              .addSelect(
                "SUM(CASE WHEN t.status = 'DONE' THEN 1 ELSE 0 END)",
                "completed",
              )
              .where("t.org_id = :orgId", { orgId })
              .getRawOne(),
            this.businessUnitRepository.find({
              where: { orgId, status: "ACTIVE" },
              relations: ["owner"],
              take: 20,
            }),
          ]).then(([totalProjects, statusDist, buDist, taskCounts, bus]) => {
            analyticsData = {
              totalProjects,
              projectStatusDistribution: statusDist.map((s) => ({
                status: s.status,
                count: Number.parseInt(s.count),
              })),
              businessUnitDistribution: buDist.map((b) => ({
                bu: b.bu || "Unassigned",
                count: Number.parseInt(b.count),
              })),
              businessUnitDetails: bus.map((bu) => ({
                name: bu.name,
                ownerName: bu.owner?.name || "Unassigned",
                status: bu.status,
              })),
              taskStats: {
                total: Number.parseInt(taskCounts.total),
                completed: Number.parseInt(taskCounts.completed || "0"),
                completionRate:
                  taskCounts.total > 0
                    ? Math.round(
                        (Number.parseInt(taskCounts.completed || "0") /
                          Number.parseInt(taskCounts.total)) *
                          100,
                      )
                    : 0,
              },
            };
          }),
        );
      }
    }

    if (fetchLeadership) {
      if (!hasPermission("MANAGE_LEADERSHIP")) {
        if (res) {
          res.write(
            `data: ${JSON.stringify({ type: "status", message: "Access denied to Leadership by permission policy." })}\n\n`,
          );
          if (typeof res.flush === "function") res.flush();
        }
        accessDeniedMsg =
          "The user is not authorized to access this information. Politely state they do not have access.";
      } else {
        fetchPromises.push(
          this.userRepository
            .find({
              where: { orgId, isLeader: true, status: "ACTIVE" },
              order: { name: "ASC" },
              take: ChatService.MAX_LEADERS_CONTEXT,
            })
            .then(async (leadersFromDb) => {
              if (leadersFromDb.length > 0) {
                const leaderIds = leadersFromDb.map((leader) => leader.id);
                const projectCountsRaw = await this.projectRepository
                  .createQueryBuilder("project")
                  .select("project.manager_id", "leaderId")
                  .addSelect("COUNT(1)", "projectCount")
                  .where("project.org_id = :orgId", { orgId })
                  .andWhere("project.manager_id IN (:...leaderIds)", {
                    leaderIds,
                  })
                  .groupBy("project.manager_id")
                  .getRawMany<{ leaderId: string; projectCount: string }>();

                const projectCountByLeaderId = new Map<string, number>(
                  projectCountsRaw.map((row) => [
                    row.leaderId,
                    Number(row.projectCount),
                  ]),
                );

                leaders = leadersFromDb.map((leader) => ({
                  name: leader.name || "Unknown",
                  email: leader.email,
                  role: leader.role || "USER",
                  projectCount: projectCountByLeaderId.get(leader.id) ?? 0,
                }));
              }
            }),
        );
      }
    }

    if (fetchUsers) {
      if (!hasPermission("VIEW_USER") && !hasPermission("MANAGE_USERS")) {
        if (res) {
          res.write(
            `data: ${JSON.stringify({ type: "status", message: "Access denied to Users by permission policy." })}\n\n`,
          );
          if (typeof res.flush === "function") res.flush();
        }
        accessDeniedMsg =
          "The user is not authorized to access this information. Politely state they do not have access.";
      } else {
        fetchPromises.push(
          this.userRepository
            .find({
              where: { orgId, status: "ACTIVE" },
              order: { name: "ASC" },
              take: ChatService.MAX_USERS_CONTEXT,
            })
            .then((usersFromDb) => {
              users = usersFromDb.map((user) => ({
                name: user.name || "Unknown",
                email: user.email,
                role: user.role || "USER",
                status: user.status,
                isLeader: user.isLeader,
                isManager: user.isManager,
              }));
            }),
        );
      }
    }

    // Only default to tasks if it's not a simple greeting or farewell
    if (
      fetchTasks ||
      (!fetchProjects &&
        !fetchAnalytics &&
        !fetchLeadership &&
        !fetchUsers &&
        !currentIntent.includes("GREETING") &&
        !currentIntent.includes("FAREWELL"))
    ) {
      fetchPromises.push(
        this.taskRepository
          .find({
            where: { orgId, assignedTo: userId },
            order: { dueDate: "ASC" },
            take: ChatService.MAX_TASKS_CONTEXT,
          })
          .then((data) => (tasks = data)),
      );
    }

    // Await all data fetching in parallel
    await Promise.all(fetchPromises);

    const shouldInjectHistory = !isGreeting && !isFarewell;
    const history = await this.messageRepository.find({
      where: { sessionId },
      order: { createdAt: "DESC" },
      take: shouldInjectHistory
        ? isFactualIntent
          ? ChatService.MAX_HISTORY_CONTEXT_FACTUAL
          : ChatService.MAX_HISTORY_CONTEXT
        : 0,
    });
    const hasAssistantHistory = history.some((h) => h.role === "assistant");

    // Build context data (reverse history for chronological order)
    const firstName = userData.name ? userData.name.split(" ")[0] : "User";

    const contextData: ChatContextData = {
      intent: currentIntent,
      user: {
        name: userData.name || "User",
        firstName: firstName,
        role: userData.role || "Team Member",
        email: userData.email,
      },
      projects: activeProjects.map((p) => ({
        name: p.name,
        projectCode: p.projectCode,
        status: p.status,
        description: p.purpose || "",
        managerName: p.manager?.name,
        businessUnit: p.businessUnit,
      })),
      tasks: tasks.map((t) => ({
        title: t.title,
        status: t.status || "OPEN",
        priority: t.priority || "MEDIUM",
        dueDate: t.dueDate
          ? new Date(t.dueDate as any).toISOString().split("T")[0]
          : null,
      })),
      leaders,
      users,
      history: history.reverse().map((h) => ({
        role: h.role as "user" | "assistant",
        content: h.text,
      })),
      analytics: analyticsData,
      message: accessDeniedMsg
        ? `[SYSTEM: ${accessDeniedMsg}] User query: ${userText}`
        : userText,
    };

    // Build rich context prompt
    const contextPrompt = this.contextBuilder.buildChatContext(contextData);

    if (res) {
      res.write(
        `data: ${JSON.stringify({ type: "status", message: "Generating response..." })}\n\n`,
      );
      if (typeof res.flush === "function") res.flush();
    }
    const rawAssistantText = await this.generateReply(
      contextPrompt,
      (chunk) => {
        if (res) {
          res.write(
            `data: ${JSON.stringify({ type: "chunk", text: chunk })}\n\n`,
          );
          if (typeof res.flush === "function") res.flush();
        }
      },
    );
    const assistantText =
      currentIntent === "GREETING"
        ? this.normalizeAssistantGreeting(
            rawAssistantText,
            firstName,
            hasAssistantHistory,
          )
        : rawAssistantText;

    if (activeSession.title === "New conversation") {
      activeSession.title = this.toTitle(userText);
      await this.sessionRepository.save(activeSession);
    }

    const [savedUserMessage, savedAssistantMessage] =
      await this.messageRepository.save([
        this.messageRepository.create({
          id: randomUUID(),
          sessionId,
          role: "user",
          text: userText,
        }),
        this.messageRepository.create({
          id: randomUUID(),
          sessionId,
          role: "assistant",
          text: assistantText,
        }),
      ]);

    const payload = {
      sessionId,
      userMessage: this.mapMessage(savedUserMessage),
      assistantMessage: this.mapMessage(savedAssistantMessage),
    };

    if (res) {
      res.write(
        `data: ${JSON.stringify({ type: "result", data: payload })}\n\n`,
      );
      res.end();
    }

    return payload;
  }

  async endSession(orgId: string, userId: string, sessionId: string) {
    const activeSession = await this.sessionRepository
      .createQueryBuilder("session")
      .where("session.id = :sessionId", { sessionId })
      .andWhere("session.org_id = :orgId", { orgId })
      .andWhere("session.user_id = :userId", { userId })
      .andWhere("session.ended_at IS NULL")
      .getOne();

    if (!activeSession) {
      throw new NotFoundException("Active chat session not found");
    }

    activeSession.endedAt = new Date();
    await this.sessionRepository.save(activeSession);

    const [messageCount, lastMessage] = await Promise.all([
      this.messageRepository.count({ where: { sessionId: activeSession.id } }),
      this.messageRepository.findOne({
        where: { sessionId: activeSession.id },
        order: { createdAt: "DESC" },
      }),
    ]);

    await this.cleanupOldHistory(orgId, userId);

    return {
      session: {
        id: activeSession.id,
        title: activeSession.title,
        startedAt: activeSession.startedAt.toISOString(),
        endedAt: (
          activeSession.endedAt || activeSession.startedAt
        ).toISOString(),
        messageCount,
        lastMessagePreview: lastMessage?.text || "",
      },
    };
  }

  async deleteSession(
    orgId: string,
    userId: string,
    sessionId: string,
  ): Promise<void> {
    const session = await this.sessionRepository.findOne({
      where: { id: sessionId, orgId, userId },
      select: ["id", "endedAt"],
    });

    if (!session) {
      throw new NotFoundException("Chat session not found");
    }

    await this.sessionRepository.delete({ id: sessionId, orgId, userId });
  }

  /**
   * Generates AI summary for a specific task
   * Fetches task details and recent comments, builds context, calls model
   */
  async generateTaskSummary(orgId: string, taskId: string): Promise<string> {
    const task = await this.taskRepository.findOne({
      where: { id: taskId, orgId },
    });

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    const comments = await this.commentRepository.find({
      where: { taskId, orgId },
      relations: ["user"],
      order: { createdAt: "DESC" },
      take: ChatService.MAX_COMMENTS_CONTEXT,
    });

    // Build context data
    const contextData: TaskSummaryContextData = {
      task: {
        title: task.title,
        status: task.status || "OPEN",
        priority: task.priority || "MEDIUM",
        dueDate: task.dueDate
          ? new Date(task.dueDate as any).toISOString().split("T")[0]
          : null,
        description: task.description,
      },
      comments: comments.reverse().map((c) => ({
        userName: c.user?.name || "Unknown",
        text: c.comment,
      })),
    };

    const contextPrompt =
      this.contextBuilder.buildTaskSummaryContext(contextData);

    return await this.generateReply(contextPrompt);
  }

  private async cleanupOldHistory(
    orgId: string,
    userId: string,
  ): Promise<void> {
    const sessionsToDelete = await this.sessionRepository
      .createQueryBuilder("session")
      .where("session.org_id = :orgId", { orgId })
      .andWhere("session.user_id = :userId", { userId })
      .andWhere("session.ended_at IS NOT NULL")
      .orderBy("session.ended_at", "DESC")
      .addOrderBy("session.started_at", "DESC")
      .offset(ChatService.MAX_HISTORY_SESSIONS)
      .getMany();

    if (sessionsToDelete.length === 0) {
      return;
    }

    await this.sessionRepository.remove(sessionsToDelete);
  }

  private async assertSessionOwnedByUser(
    orgId: string,
    userId: string,
    sessionId: string,
  ): Promise<void> {
    const match = await this.sessionRepository.findOne({
      where: {
        id: sessionId,
        orgId,
        userId,
      },
      select: ["id"],
    });

    if (!match) {
      throw new NotFoundException("Chat session not found");
    }
  }

  private mapMessage(message: ChatMessageEntity): ChatMessage {
    return {
      id: message.id,
      role: message.role as ChatRole,
      text: message.text,
      createdAt: message.createdAt.toISOString(),
    };
  }

  private toTitle(text: string): string {
    const cleaned = text.trim();
    if (cleaned.length <= 48) return cleaned;
    return `${cleaned.slice(0, 48).trim()}...`;
  }

  private async generateReply(
    text: string,
    onTextChunk?: (chunk: string) => void,
  ): Promise<string> {
    try {
      const response = await this.llmService.generate(text, onTextChunk);
      if (!response || response.trim().length === 0) {
        throw new InternalServerErrorException(
          "Model response did not contain reply text.",
        );
      }
      return response.trim();
    } catch (error) {
      if (error instanceof InternalServerErrorException) {
        throw error;
      }
      this.logger.error(
        "Failed to call AI provider service",
        error instanceof Error ? error.stack : undefined,
      );
      throw new InternalServerErrorException(
        "AI service is currently unavailable.",
      );
    }
  }

  private normalizeAssistantGreeting(
    text: string,
    firstName: string,
    hasAssistantHistory: boolean,
  ): string {
    const trimmed = text.trim();

    if (!hasAssistantHistory) {
      return trimmed;
    }

    const escapedName = this.escapeRegExp(firstName || "");
    const greetingPatterns: RegExp[] = [
      /^\s*(?:hi|hello|hey)(?:\s*,|\s+)(?:there|team|all)\s*[,!]?\s*/i,
      /^\s*(?:hi|hello|hey)\s*[,!]?\s*/i,
    ];

    if (escapedName) {
      greetingPatterns.unshift(
        new RegExp(
          `^\\s*(?:hi|hello|hey)(?:\\s*,|\\s+)${escapedName}\\s*[,!]?\\s*`,
          "i",
        ),
      );
    }

    let normalized = trimmed;
    for (const pattern of greetingPatterns) {
      const flags = pattern.flags.includes("g")
        ? pattern.flags
        : `${pattern.flags}g`;
      normalized = normalized.replaceAll(new RegExp(pattern.source, flags), "");
    }

    return normalized.trim() || trimmed;
  }

  private escapeRegExp(value: string): string {
    return value.replaceAll(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  private isUserDirectoryQuery(text: string): boolean {
    return ChatService.USER_DIRECTORY_QUERY_PATTERN.test(text);
  }
}
