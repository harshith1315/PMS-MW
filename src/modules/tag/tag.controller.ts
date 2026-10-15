import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
  ApiParam,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { TenantGuard } from '../../common/guards/tenant.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserContext } from '../auth/auth.service';
import { TagService } from './tag.service';
import {
  CreateTagDto,
  UpdateTagDto,
  UpdateTagStatusDto,
  TagQueryDto,
  TagResponseDto,
} from './dto/tag.dto';

@ApiTags('Tags')
@Controller('tags')
@UseGuards(JwtAuthGuard, TenantGuard)
@ApiBearerAuth('bearer')
export class TagController {
  constructor(private readonly tagService: TagService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles('ORG_ADMIN', 'MANAGER')
  @ApiOperation({ summary: 'Create a new tag' })
  @ApiResponse({
    status: 201,
    description: 'Tag created successfully',
    type: TagResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin/Manager only' })
  @ApiResponse({ status: 409, description: 'Tag name already exists' })
  async create(
    @CurrentUser() user: UserContext,
    @Body() createTagDto: CreateTagDto,
  ) {
    return this.tagService.create(user.orgId, createTagDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all tags' })
  @ApiResponse({
    status: 200,
    description: 'List of tags',
    type: [TagResponseDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(@CurrentUser() user: UserContext, @Query() query: TagQueryDto) {
    // Ensure predefined tags exist for this organization
    await this.tagService.ensurePredefinedTags(user.orgId);
    return this.tagService.findAll(user.orgId, query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get tag by ID' })
  @ApiParam({ name: 'id', description: 'Tag ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Tag details',
    type: TagResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Tag not found' })
  async findOne(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.tagService.findOne(user.orgId, id);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles('ORG_ADMIN', 'MANAGER')
  @ApiOperation({ summary: 'Update tag' })
  @ApiParam({ name: 'id', description: 'Tag ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Tag updated successfully',
    type: TagResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin/Manager only' })
  @ApiResponse({ status: 404, description: 'Tag not found' })
  @ApiResponse({ status: 409, description: 'Tag name already exists' })
  async update(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateTagDto: UpdateTagDto,
  ) {
    return this.tagService.update(user.orgId, id, updateTagDto);
  }

  @Patch(':id/status')
  @UseGuards(RolesGuard)
  @Roles('ORG_ADMIN', 'MANAGER')
  @ApiOperation({ summary: 'Update tag status (Archive/Activate)' })
  @ApiParam({ name: 'id', description: 'Tag ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'Tag status updated successfully',
    type: TagResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin/Manager only' })
  @ApiResponse({ status: 404, description: 'Tag not found' })
  async updateStatus(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateStatusDto: UpdateTagStatusDto,
  ) {
    return this.tagService.updateStatus(user.orgId, id, updateStatusDto);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles('ORG_ADMIN')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete tag (ORG_ADMIN only)' })
  @ApiParam({ name: 'id', description: 'Tag ID', format: 'uuid' })
  @ApiResponse({ status: 204, description: 'Tag deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin only' })
  @ApiResponse({ status: 404, description: 'Tag not found' })
  @ApiResponse({ status: 409, description: 'Tag is in use by tasks' })
  async remove(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.tagService.remove(user.orgId, id);
  }

  @Get(':id/tasks')
  @ApiOperation({ summary: 'Get all tasks with this tag' })
  @ApiParam({ name: 'id', description: 'Tag ID', format: 'uuid' })
  @ApiResponse({
    status: 200,
    description: 'List of tasks with this tag',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Tag not found' })
  async getTasksWithTag(
    @CurrentUser() user: UserContext,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.tagService.getTasksWithTag(user.orgId, id);
  }
}
