import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Logger,
  Inject,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserProjectMapping } from '../../entities/user-project-mapping.entity';
import { Project } from '../../entities/project.entity';

/**
 * Project Access Guard - Ensures user can only access assigned projects
 * 
 * Checks if user has a mapping to the requested project.
 * Project ID should be in request params as 'projectId' or 'id'.
 * 
 * ORG_ADMIN users bypass this check and can access all projects in their org.
 */
@Injectable()
export class ProjectAccessGuard implements CanActivate {
  private readonly logger = new Logger(ProjectAccessGuard.name);

  constructor(
    @InjectRepository(UserProjectMapping)
    private readonly userProjectMappingRepository: Repository<UserProjectMapping>,
    @InjectRepository(Project)
    private readonly projectRepository: Repository<Project>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('Authentication required');
    }

    // ORG_ADMIN can access all projects in their org
    if (user.role === 'ORG_ADMIN') {
      return true;
    }

    // Get project ID from various possible sources
    const projectId =
      request.params.projectId ||
      request.params.id ||
      request.body?.projectId ||
      request.query?.projectId;

    if (!projectId) {
      // If no project ID in request, allow (other guards may handle)
      return true;
    }

    // Verify project belongs to user's organization
    const project = await this.projectRepository.findOne({
      where: { id: projectId, orgId: user.orgId },
    });

    if (!project) {
      this.logger.warn(
        `Project ${projectId} not found or belongs to different org`,
      );
      throw new ForbiddenException('Project not found');
    }

    // Check if user is assigned to the project
    const mapping = await this.userProjectMappingRepository.findOne({
      where: {
        userId: user.userId,
        projectId: projectId,
      },
    });

    if (!mapping) {
      this.logger.warn(
        `User ${user.userId} not assigned to project ${projectId}`,
      );
      throw new ForbiddenException('You are not assigned to this project');
    }

    // Attach project role to request
    request.projectRole = mapping.projectRole;

    return true;
  }
}
