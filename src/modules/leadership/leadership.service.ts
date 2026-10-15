import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { AppUser } from "../../entities/app-user.entity";
import { Project } from "../../entities/project.entity";
import { UserProjectMapping } from "../../entities/user-project-mapping.entity";
import {
  CreateLeaderDto,
  UpdateLeaderDto,
  LeaderResponseDto,
} from "./dto/leadership.dto";

@Injectable()
export class LeadershipService {
  constructor(
    @InjectRepository(AppUser)
    private readonly userRepository: Repository<AppUser>,
    @InjectRepository(Project)
    private readonly projectRepository: Repository<Project>,
    @InjectRepository(UserProjectMapping)
    private readonly userProjectMappingRepository: Repository<UserProjectMapping>,
  ) {}

  /**
   * Get all leaders in an organization
   */
  async getLeaders(orgId: string): Promise<LeaderResponseDto[]> {
    const leaders = await this.userRepository
      .createQueryBuilder("user")
      .where("user.org_id = :orgId", { orgId })
      .andWhere("user.isLeader = :isLeader", { isLeader: true })
      .andWhere("user.status = :status", { status: "ACTIVE" })
      .orderBy("user.name", "ASC")
      .getMany();

    // Fetch project count for each leader
    const leadersWithCount = await Promise.all(
      leaders.map(async (leader) => {
        const projectCount = await this.projectRepository.count({
          where: { managerId: leader.id },
        });
        const teamSize = await this.getLeaderTeamSize(orgId, leader.id);
        return this.mapToResponseDto(leader, projectCount, teamSize);
      }),
    );

    return leadersWithCount;
  }

  /**
   * Get a specific leader's details
   */
  async getLeaderById(
    orgId: string,
    leaderId: string,
  ): Promise<LeaderResponseDto> {
    const leader = await this.userRepository.findOne({
      where: { id: leaderId, orgId, isLeader: true },
    });

    if (!leader) {
      throw new NotFoundException("Leader not found");
    }

    const projectCount = await this.projectRepository.count({
      where: { managerId: leaderId },
    });

    const teamSize = await this.getLeaderTeamSize(orgId, leaderId);

    return this.mapToResponseDto(leader, projectCount, teamSize);
  }

  /**
   * Get projects managed by a leader
   */
  async getLeaderProjects(orgId: string, leaderId: string) {
    const leader = await this.userRepository.findOne({
      where: { id: leaderId, orgId, isLeader: true },
    });

    if (!leader) {
      throw new NotFoundException("Leader not found");
    }

    const projects = await this.projectRepository
      .createQueryBuilder("project")
      .where("project.org_id = :orgId", { orgId })
      .andWhere("project.manager_id = :managerId", { managerId: leaderId })
      .orderBy("project.name", "ASC")
      .getMany();

    return projects;
  }

  /**
   * Create a new leader
   */
  async createLeader(
    orgId: string,
    createLeaderDto: CreateLeaderDto,
  ): Promise<LeaderResponseDto> {
    const { email, name } = createLeaderDto;

    // Check if user already exists in org
    const existingUser = await this.userRepository.findOne({
      where: { email, orgId },
    });

    if (existingUser && existingUser.isLeader) {
      throw new BadRequestException(
        "User is already a leader in this organization",
      );
    }

    let user: AppUser;

    if (existingUser) {
      // Update existing user with leader flags
      existingUser.isLeader = true;
      existingUser.isManager = true;
      if (existingUser.role !== "ORG_ADMIN") {
        existingUser.role = "MANAGER";
      }
      user = await this.userRepository.save(existingUser);
    } else {
      // Create new user
      user = this.userRepository.create({
        orgId,
        email,
        name,
        role: "MANAGER",
        isLeader: true,
        isManager: true,
        status: "ACTIVE",
      });
      user = await this.userRepository.save(user);
    }

    return this.mapToResponseDto(user, 0, 0);
  }

  /**
   * Update a leader
   */
  async updateLeader(
    orgId: string,
    leaderId: string,
    updateLeaderDto: UpdateLeaderDto,
  ): Promise<LeaderResponseDto> {
    const leader = await this.userRepository.findOne({
      where: { id: leaderId, orgId, isLeader: true },
    });

    if (!leader) {
      throw new NotFoundException("Leader not found");
    }

    if (updateLeaderDto.name) {
      leader.name = updateLeaderDto.name;
    }

    if (updateLeaderDto.isManager !== undefined) {
      leader.isManager = updateLeaderDto.isManager;
    }

    // Enforce invariant: leader users must always carry manager access.
    leader.isManager = true;
    if (leader.role !== "ORG_ADMIN") {
      leader.role = "MANAGER";
    }

    const updated = await this.userRepository.save(leader);

    const projectCount = await this.projectRepository.count({
      where: { managerId: leaderId },
    });

    const teamSize = await this.getLeaderTeamSize(orgId, leaderId);

    return this.mapToResponseDto(updated, projectCount, teamSize);
  }

  /**
   * Count unique active users mapped to the leader's managed projects.
   */
  private async getLeaderTeamSize(
    orgId: string,
    leaderId: string,
  ): Promise<number> {
    const result = await this.userProjectMappingRepository
      .createQueryBuilder("mapping")
      .innerJoin(Project, "project", "project.id = mapping.project_id")
      .innerJoin(AppUser, "member", "member.id = mapping.user_id")
      .where("project.org_id = :orgId", { orgId })
      .andWhere("project.manager_id = :leaderId", { leaderId })
      .andWhere("mapping.org_id = :orgId", { orgId })
      .andWhere("mapping.status = :activeStatus", { activeStatus: "ACTIVE" })
      .andWhere("member.status = :memberStatus", { memberStatus: "ACTIVE" })
      .andWhere("member.id != :leaderId", { leaderId })
      .select("COUNT(DISTINCT mapping.user_id)", "teamSize")
      .getRawOne<{ teamSize: string }>();

    return Number(result?.teamSize ?? 0);
  }

  /**
   * Delete/deactivate a leader
   */
  async deleteLeader(orgId: string, leaderId: string): Promise<void> {
    const leader = await this.userRepository.findOne({
      where: { id: leaderId, orgId, isLeader: true },
    });

    if (!leader) {
      throw new NotFoundException("Leader not found");
    }

    leader.isLeader = false;
    leader.isManager = false;
    if (leader.role === "MANAGER") {
      leader.role = "USER";
    }
    await this.userRepository.save(leader);
  }

  /**
   * Helper: map user to response DTO
   */
  private mapToResponseDto(
    user: AppUser,
    projectCount: number,
    teamSize: number,
  ): LeaderResponseDto {
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      isManager: user.isManager,
      projectCount,
      teamSize,
      status: user.status,
      createdAt: user.createdAt,
    };
  }
}
