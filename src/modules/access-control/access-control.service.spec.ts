import { Repository } from "typeorm";
import { AppUser } from "../../entities/app-user.entity";
import { Role } from "../../entities/role.entity";
import { UserPermission } from "../../entities/user-permission.entity";
import { UserContext } from "../auth/auth.service";
import { ACCESS_CONTROL_PERMISSIONS } from "./access-control.constants";
import { AccessControlService } from "./access-control.service";

type MockRepo<T extends object> = {
  find: jest.Mock<Promise<T[]>, [unknown?]>;
  findOne: jest.Mock<Promise<T | null>, [unknown?]>;
  upsert: jest.Mock<Promise<unknown>, [unknown?, unknown?]>;
  create: jest.Mock<T, [unknown?]>;
};

const createMockRepo = <T extends object>(): MockRepo<T> => ({
  find: jest.fn(),
  findOne: jest.fn(),
  upsert: jest.fn(),
  create: jest.fn(),
});

describe("AccessControlService.getUserPermissions", () => {
  let service: AccessControlService;
  let roleRepository: MockRepo<Role>;
  let userPermissionRepository: MockRepo<UserPermission>;
  let appUserRepository: MockRepo<AppUser>;

  const currentAdmin: UserContext = {
    userId: "admin-current",
    orgId: "org-1",
    email: "admin@example.com",
    name: "Admin",
    role: "ADMIN",
    externalId: "ext-admin",
  };

  beforeEach(() => {
    roleRepository = createMockRepo<Role>();
    userPermissionRepository = createMockRepo<UserPermission>();
    appUserRepository = createMockRepo<AppUser>();

    service = new AccessControlService(
      roleRepository as unknown as Repository<Role>,
      userPermissionRepository as unknown as Repository<UserPermission>,
      appUserRepository as unknown as Repository<AppUser>,
    );
  });

  it("returns all permissions granted for ADMIN target when no overrides exist", async () => {
    appUserRepository.findOne.mockResolvedValue({
      id: "admin-target",
      orgId: "org-1",
      role: "ADMIN",
    } as AppUser);
    userPermissionRepository.find.mockResolvedValue([]);

    const result = await service.getUserPermissions(currentAdmin, "admin-target");

    expect(result).toHaveLength(ACCESS_CONTROL_PERMISSIONS.length);
    expect(result.every((state) => state.isGranted)).toBe(true);
    expect(roleRepository.findOne).not.toHaveBeenCalled();
  });

  it("keeps ORG_ADMIN baseline as granted and applies explicit user revocations", async () => {
    appUserRepository.findOne.mockResolvedValue({
      id: "org-admin-target",
      orgId: "org-1",
      role: "ORG_ADMIN",
    } as AppUser);
    userPermissionRepository.find.mockResolvedValue([
      {
        userId: "org-admin-target",
        permissionKey: "VIEW_PROJECT",
        isGranted: false,
      },
    ] as UserPermission[]);

    const result = await service.getUserPermissions(currentAdmin, "org-admin-target");
    const map = new Map(result.map((item) => [item.permissionKey, item.isGranted]));

    expect(result).toHaveLength(ACCESS_CONTROL_PERMISSIONS.length);
    expect(map.get("VIEW_PROJECT")).toBe(false);
    expect(map.get("EDIT_PROJECT")).toBe(true);
    expect(roleRepository.findOne).not.toHaveBeenCalled();
  });

  it("merges role defaults with user overrides for non-admin roles", async () => {
    appUserRepository.findOne.mockResolvedValue({
      id: "user-target",
      orgId: "org-1",
      role: "USER",
    } as AppUser);

    roleRepository.findOne.mockResolvedValue({
      id: "role-user",
      key: "USER",
      name: "User",
      description: null,
      permissions: {
        VIEW_PROJECT: true,
        EDIT_PROJECT: false,
      },
      isSystem: true,
      isActive: true,
    } as unknown as Role);

    userPermissionRepository.find.mockResolvedValue([
      {
        userId: "user-target",
        permissionKey: "EDIT_PROJECT",
        isGranted: true,
      },
      {
        userId: "user-target",
        permissionKey: "CREATE_TASK",
        isGranted: false,
      },
    ] as UserPermission[]);

    const result = await service.getUserPermissions(currentAdmin, "user-target");
    const map = new Map(result.map((item) => [item.permissionKey, item.isGranted]));

    expect(result).toHaveLength(ACCESS_CONTROL_PERMISSIONS.length);
    expect(map.get("VIEW_PROJECT")).toBe(true);
    expect(map.get("EDIT_PROJECT")).toBe(true);
    expect(map.get("CREATE_TASK")).toBe(false);
    expect(map.get("DELETE_PROJECT")).toBe(false);
    expect(roleRepository.findOne).toHaveBeenCalled();
  });
});
