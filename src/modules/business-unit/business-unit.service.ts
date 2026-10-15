import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { BusinessUnit } from "../../entities/business-unit.entity";
import { AppUser } from "../../entities/app-user.entity";
import {
  CreateBusinessUnitDto,
  UpdateBusinessUnitDto,
} from "./dto/business-unit.dto";

@Injectable()
export class BusinessUnitService {
  constructor(
    @InjectRepository(BusinessUnit)
    private readonly repo: Repository<BusinessUnit>,
    @InjectRepository(AppUser)
    private readonly appUserRepo: Repository<AppUser>,
  ) {}

  async list(orgId: string, includeInactive = false): Promise<BusinessUnit[]> {
    return this.repo.find({
      where: includeInactive ? { orgId } : { orgId, status: "ACTIVE" },
      relations: ["owner"],
      order: { name: "ASC" },
    });
  }

  async create(
    orgId: string,
    dto: CreateBusinessUnitDto,
  ): Promise<BusinessUnit> {
    const name = dto.name.trim();
    const existing = await this.repo.findOne({ where: { orgId, name } });
    if (existing) {
      if (existing.status === "ACTIVE") {
        throw new ConflictException(`Business unit '${name}' already exists`);
      }
      // Reactivate soft-deleted unit
      existing.status = "ACTIVE";
      if (dto.ownerId !== undefined) {
        await this.validateOwner(orgId, dto.ownerId);
        existing.ownerId = dto.ownerId || undefined;
      }
      await this.repo.save(existing);
      const reloaded = await this.repo.findOne({
        where: { id: existing.id },
        relations: ["owner"],
      });
      if (!reloaded) {
        throw new NotFoundException("Business unit not found");
      }
      return reloaded;
    }

    if (dto.ownerId) {
      await this.validateOwner(orgId, dto.ownerId);
    }

    const entity = this.repo.create({
      orgId,
      name,
      status: "ACTIVE",
      ownerId: dto.ownerId || undefined,
    });
    const saved = await this.repo.save(entity);
    const reloaded = await this.repo.findOne({
      where: { id: saved.id },
      relations: ["owner"],
    });
    if (!reloaded) {
      throw new NotFoundException("Business unit not found");
    }
    return reloaded;
  }

  async update(
    orgId: string,
    id: string,
    dto: UpdateBusinessUnitDto,
  ): Promise<BusinessUnit> {
    const unit = await this.findActive(orgId, id);
    if (dto.name) {
      const name = dto.name.trim();
      const conflict = await this.repo.findOne({ where: { orgId, name } });
      if (conflict && conflict.id !== id) {
        throw new ConflictException(`Business unit '${name}' already exists`);
      }
      unit.name = name;
    }
    if (dto.ownerId !== undefined) {
      if (dto.ownerId) {
        await this.validateOwner(orgId, dto.ownerId);
      }
      unit.ownerId = dto.ownerId || undefined;
    }
    await this.repo.save(unit);
    const reloaded = await this.repo.findOne({
      where: { id: unit.id },
      relations: ["owner"],
    });
    if (!reloaded) {
      throw new NotFoundException("Business unit not found");
    }
    return reloaded;
  }

  async remove(orgId: string, id: string): Promise<void> {
    const unit = await this.findActive(orgId, id);
    unit.status = "INACTIVE";
    await this.repo.save(unit);
  }

  private async validateOwner(orgId: string, ownerId: string): Promise<void> {
    if (!ownerId) return;
    const user = await this.appUserRepo.findOne({
      where: { id: ownerId, orgId, status: "ACTIVE" },
    });
    if (!user) {
      throw new BadRequestException("Owner user not found in organization");
    }
  }

  private async findActive(orgId: string, id: string): Promise<BusinessUnit> {
    const unit = await this.repo.findOne({
      where: { id, orgId, status: "ACTIVE" },
    });
    if (!unit) throw new NotFoundException("Business unit not found");
    return unit;
  }
}
