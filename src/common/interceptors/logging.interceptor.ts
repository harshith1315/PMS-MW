import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from "@nestjs/common";
import { Observable } from "rxjs";
import { tap } from "rxjs/operators";
import { ActivityLogService } from "../../modules/activity-log/activity-log.service";

/**
 * Logging Interceptor - Logs all incoming requests and response times
 */
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger("HTTP");

  constructor(private readonly activityLogService: ActivityLogService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest<{
      method: string;
      originalUrl?: string;
      url: string;
      body?: Record<string, unknown>;
      user?: {
        userId?: string;
        orgId?: string;
        name?: string;
        email?: string;
      };
      params?: Record<string, string>;
      headers?: Record<string, unknown>;
      ip?: string;
      connection?: { remoteAddress?: string };
    }>();
    const { method, url, body, user } = request;
    const now = Date.now();
    const requestPath = request.originalUrl ?? request.url;
    const shouldPersistActivity = this.shouldPersistActivity(
      method,
      requestPath,
    );

    const userInfo = user ? `User: ${user.userId}` : "Anonymous";
    const orgInfo = user?.orgId ? `Org: ${user.orgId}` : "";

    this.logger.log(`[${method}] ${url} - ${userInfo} ${orgInfo}`.trim());

    // Log request body for non-GET requests (exclude sensitive data)
    if (method !== "GET" && body && Object.keys(body).length > 0) {
      const sanitizedBody = this.sanitizeBody(body);
      this.logger.debug(`Request body: ${JSON.stringify(sanitizedBody)}`);
    }

    return next.handle().pipe(
      tap({
        next: (data) => {
          const responseTime = Date.now() - now;
          this.logger.log(`[${method}] ${url} - ${responseTime}ms`);

          if (shouldPersistActivity && user?.orgId) {
            void this.activityLogService.create({
              orgId: user.orgId,
              actorUserId: user.userId,
              actorName: user.name,
              actorEmail: user.email,
              method,
              ...this.extractResourceInfo(request, data),
              actionType: this.deriveActionType(method, requestPath, body),
              message: this.generateFriendlyMessage(
                method,
                requestPath,
                request,
                data,
              ),
              requestPath,
              ipAddress: this.getIpAddress(request),
              userAgent: this.getUserAgent(request),
              metadata: this.getSafeMetadata(request.params),
            });
          }
        },
        error: (error) => {
          const responseTime = Date.now() - now;
          this.logger.error(
            `[${method}] ${url} - ${error.status || 500} - ${responseTime}ms - ${error.message}`,
          );
        },
      }),
    );
  }

  private shouldPersistActivity(method: string, requestPath: string): boolean {
    const isMutatingMethod = ["POST", "PUT", "PATCH", "DELETE"].includes(
      method,
    );
    if (!isMutatingMethod) {
      return false;
    }

    return (
      !requestPath.includes("/activity-logs") && !requestPath.includes("/auth")
    );
  }

  private sanitizeBody(body: unknown): unknown {
    if (Array.isArray(body)) {
      return body.map((item) => this.sanitizeBody(item));
    }

    if (!body || typeof body !== "object") {
      return body;
    }

    const sanitized: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(
      body as Record<string, unknown>,
    )) {
      if (this.isSensitiveField(key)) {
        sanitized[key] = "[REDACTED]";
      } else {
        sanitized[key] = this.sanitizeBody(value);
      }
    }

    return sanitized;
  }

  private isSensitiveField(fieldName: string): boolean {
    const normalized = fieldName.toLowerCase();
    const sensitiveFragments = [
      "password",
      "token",
      "secret",
      "authorization",
      "cookie",
      "api_key",
      "apikey",
      "refresh",
    ];
    return sensitiveFragments.some((fragment) => normalized.includes(fragment));
  }

  private extractResourceInfo(
    request: {
      originalUrl?: string;
      url: string;
      params?: Record<string, string>;
    },
    responseData: unknown,
  ): { resourceType?: string; resourceId?: string } {
    const requestPath = request.originalUrl ?? request.url;
    const resourceType = this.extractResourceTypeFromPath(requestPath);

    const params = request.params ?? {};
    const priorityKeys = [
      "id",
      "taskId",
      "projectId",
      "sprintId",
      "userId",
      "mappingId",
    ];

    let resourceId: string | undefined;
    for (const key of priorityKeys) {
      if (params[key]) {
        resourceId = params[key];
        break;
      }
    }

    if (!resourceId) {
      resourceId = Object.values(params)[0];
    }

    if (!resourceId && responseData && typeof responseData === "object") {
      const data = responseData as Record<string, unknown>;
      if (typeof data.id === "string") {
        resourceId = data.id;
      } else if (
        data.data &&
        typeof data.data === "object" &&
        typeof (data.data as Record<string, unknown>).id === "string"
      ) {
        resourceId = (data.data as Record<string, unknown>).id as string;
      }
    }

    return { resourceType, resourceId };
  }

  private extractResourceTypeFromPath(requestPath: string): string | undefined {
    const cleanPath = requestPath.split("?")[0];
    const parts = cleanPath.split("/").filter(Boolean);
    const apiIndex = parts.findIndex((p) => p === "api");
    const startIndex = apiIndex >= 0 ? apiIndex + 2 : 0;
    const resourceSegment = parts[startIndex];
    if (!resourceSegment) {
      return undefined;
    }

    return resourceSegment;
  }

  private deriveActionType(
    method: string,
    requestPath: string,
    body?: Record<string, unknown>,
  ): string {
    const resource = (
      this.extractResourceTypeFromPath(requestPath) ?? "RESOURCE"
    )
      .replaceAll("-", "_")
      .toUpperCase();

    if (requestPath.includes("/users/") && requestPath.includes("/status")) {
      const status = String(body?.status ?? "").toUpperCase();
      return status === "ACTIVE" ? "USER_ACTIVATED" : "USER_DEACTIVATED";
    }
    if (requestPath.includes("/users/") && requestPath.includes("/role")) {
      return "USER_ROLE_UPDATED";
    }
    if (requestPath.includes("/tasks/") && requestPath.includes("/status")) {
      return "TASK_STATUS_UPDATED";
    }
    if (requestPath.includes("/tasks/") && requestPath.includes("/assign")) {
      return "TASK_ASSIGNEE_UPDATED";
    }
    if (requestPath.includes("/tasks/") && requestPath.includes("/sprint")) {
      return "TASK_SPRINT_UPDATED";
    }
    if (requestPath.includes("/projects/") && requestPath.includes("/team")) {
      return method === "DELETE"
        ? "PROJECT_TEAM_REMOVED"
        : "PROJECT_TEAM_ADDED";
    }
    if (requestPath.includes("/projects/") && requestPath.includes("/links")) {
      return method === "DELETE"
        ? "PROJECT_LINK_REMOVED"
        : "PROJECT_LINK_ADDED";
    }
    if (
      requestPath.includes("/projects/") &&
      requestPath.includes("bandwidth")
    ) {
      return "PROJECT_BANDWIDTH_UPDATED";
    }
    if (requestPath.includes("/sprints/") && requestPath.includes("/start")) {
      return "SPRINT_STARTED";
    }
    if (
      requestPath.includes("/sprints/") &&
      requestPath.includes("/complete")
    ) {
      return "SPRINT_COMPLETED";
    }

    const verb =
      method === "POST"
        ? "CREATED"
        : method === "PUT" || method === "PATCH"
          ? "UPDATED"
          : "DELETED";

    return `${resource}_${verb}`;
  }

  private generateFriendlyMessage(
    method: string,
    requestPath: string,
    request: {
      body?: Record<string, unknown>;
      params?: Record<string, string>;
      user?: { name?: string; email?: string };
    },
    responseData: unknown,
  ): string {
    const resourceInfo = this.extractResourceInfo(
      { originalUrl: requestPath, url: requestPath, params: request.params },
      responseData,
    );
    const resourceType = resourceInfo.resourceType ?? "resource";
    const resourceId = resourceInfo.resourceId;
    const body = request.body ?? {};
    const actor = request.user?.name || request.user?.email || "A user";
    const label = this.resourceDisplayLabel(resourceType, resourceId);

    if (resourceType === "users") {
      const target = (
        request.params?.id ||
        resourceId ||
        "unknown user"
      ).toString();
      const targetIdentity =
        (typeof body.email === "string" && body.email) ||
        (typeof body.name === "string" && body.name) ||
        `User ID ${target}`;

      if (requestPath.includes("/status")) {
        const status = String(body.status ?? "").toUpperCase();
        return status === "ACTIVE"
          ? `${actor} activated ${targetIdentity}.`
          : `${actor} deactivated ${targetIdentity}.`;
      }
      if (requestPath.includes("/role")) {
        return `${actor} changed role for ${targetIdentity} to ${String(body.role ?? "new role")}.`;
      }
      if (method === "PATCH" || method === "PUT") {
        return `${actor} updated profile details for ${targetIdentity}.`;
      }
      if (method === "POST") {
        return `${actor} created/invited ${targetIdentity}.`;
      }
    }

    if (resourceType === "tasks") {
      if (requestPath.includes("/status") || typeof body.status === "string") {
        return `${actor} changed status of ${label} to ${String(body.status ?? "updated status")}.`;
      }
      if (
        requestPath.includes("/assign") ||
        typeof body.assigneeId === "string"
      ) {
        return `${actor} updated assignee for ${label}.`;
      }
      if (
        requestPath.includes("/sprint") ||
        typeof body.sprintId === "string"
      ) {
        return `${actor} moved ${label} to a sprint.`;
      }
      if (
        requestPath.includes("/tags") ||
        Array.isArray(body.tags) ||
        Array.isArray(body.tagIds)
      ) {
        return `${actor} updated tags for ${label}.`;
      }
      if (method === "PATCH" || method === "PUT") {
        const changed = this.summarizeUpdatedFields(body);
        return changed
          ? `${actor} updated ${label}: ${changed}.`
          : `${actor} updated ${label}.`;
      }
      if (method === "POST") {
        return `${actor} created ${label}.`;
      }
      if (method === "DELETE") {
        return `${actor} deleted ${label}.`;
      }
    }

    if (resourceType === "projects") {
      if (requestPath.includes("/team") && method === "POST") {
        return `${actor} added a team member to ${label}.`;
      }
      if (requestPath.includes("/team") && method === "DELETE") {
        return `${actor} removed a team member from ${label}.`;
      }
      if (requestPath.includes("/links") && method === "POST") {
        return `${actor} added a project link to ${label}.`;
      }
      if (requestPath.includes("/links") && method === "DELETE") {
        return `${actor} removed a project link from ${label}.`;
      }
      if (requestPath.includes("bandwidth")) {
        return `${actor} updated bandwidth allocation in ${label}.`;
      }
      if (method === "POST") {
        return `${actor} created ${label}.`;
      }
      if (method === "DELETE") {
        return `${actor} deleted ${label}.`;
      }
      return `${actor} updated ${label}.`;
    }

    if (resourceType === "sprints") {
      if (requestPath.includes("/start")) {
        return `${actor} started ${label}.`;
      }
      if (requestPath.includes("/complete")) {
        return `${actor} completed ${label}.`;
      }
      if (method === "POST") {
        return `${actor} created ${label}.`;
      }
      if (method === "DELETE") {
        return `${actor} deleted ${label}.`;
      }
      return `${actor} updated ${label}.`;
    }

    if (
      [
        "comments",
        "business-units",
        "time-logs",
        "tags",
        "organizations",
        "access-control",
        "attachments",
        "notifications",
      ].includes(resourceType)
    ) {
      const verb =
        method === "POST"
          ? "created"
          : method === "DELETE"
            ? "deleted"
            : "updated";
      return `${actor} ${verb} ${label}.`;
    }

    const fallbackVerb =
      method === "POST"
        ? "created"
        : method === "DELETE"
          ? "deleted"
          : "updated";
    return `${actor} ${fallbackVerb} ${label}.`;
  }

  private summarizeUpdatedFields(body: Record<string, unknown>): string {
    const keys = Object.keys(body).filter(
      (key) =>
        !["password", "token", "secret", "authorization"].includes(
          key.toLowerCase(),
        ),
    );
    if (keys.length === 0) {
      return "";
    }
    return `fields ${keys.join(", ")}`;
  }

  private resourceDisplayLabel(
    resourceType: string,
    resourceId?: string,
  ): string {
    const id = resourceId ?? "unknown";
    switch (resourceType) {
      case "users":
        return `User ID ${id}`;
      case "tasks":
        return `Task ID ${id}`;
      case "projects":
        return `Project ID ${id}`;
      case "sprints":
        return `Sprint ID ${id}`;
      case "comments":
        return `Comment ID ${id}`;
      case "business-units":
        return `Business Unit ID ${id}`;
      case "time-logs":
        return `Time Log ID ${id}`;
      case "tags":
        return `Tag ID ${id}`;
      case "organizations":
        return `Organization ID ${id}`;
      case "access-control":
        return `Access Control ID ${id}`;
      case "attachments":
        return `Attachment ID ${id}`;
      case "notifications":
        return `Notification ID ${id}`;
      default:
        return `${resourceType} ${id}`;
    }
  }

  private getIpAddress(request: {
    headers?: Record<string, unknown>;
    ip?: string;
    connection?: { remoteAddress?: string };
  }): string | undefined {
    const forwardedFor = request.headers?.["x-forwarded-for"];
    if (typeof forwardedFor === "string" && forwardedFor.length > 0) {
      return forwardedFor.split(",")[0].trim();
    }

    return request.ip ?? request.connection?.remoteAddress;
  }

  private getUserAgent(request: {
    headers?: Record<string, unknown>;
  }): string | undefined {
    const userAgent = request.headers?.["user-agent"];
    return typeof userAgent === "string" ? userAgent : undefined;
  }

  private getSafeMetadata(
    params?: Record<string, string>,
  ): Record<string, unknown> {
    return {
      params: params ?? {},
    };
  }
}
