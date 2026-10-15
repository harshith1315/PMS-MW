import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { APP_GUARD, APP_INTERCEPTOR } from "@nestjs/core";

// Configuration
import { databaseConfig } from "./config/database.config";
import { appConfig } from "./config/app.config";

// Modules
import { AuthModule } from "./modules/auth/auth.module";
import { OrganizationModule } from "./modules/organization/organization.module";
import { ProjectModule } from "./modules/project/project.module";
import { TaskModule } from "./modules/task/task.module";
import { SprintModule } from "./modules/sprint/sprint.module";
import { TimeLogModule } from "./modules/time-log/time-log.module";
import { TimesheetModule } from "./modules/timesheet/timesheet.module";
import { CommentModule } from "./modules/comment/comment.module";
import { AttachmentModule } from "./modules/attachment/attachment.module";
import { TaskLinkModule } from "./modules/task-link/task-link.module";
import { UserModule } from "./modules/user/user.module";
import { TagModule } from "./modules/tag/tag.module";
import { LeadershipModule } from "./modules/leadership/leadership.module";
import { ReportModule } from "./modules/report/report.module";
import { AccessControlModule } from "./modules/access-control/access-control.module";
import { BusinessUnitModule } from "./modules/business-unit/business-unit.module";
import { ActivityLogModule } from "./modules/activity-log/activity-log.module";
import { ChatModule } from "./modules/chat/chat.module";
import { NotificationModule } from "./modules/notification/notification.module";

// Common
import { LoggingInterceptor } from "./common/interceptors/logging.interceptor";

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig, databaseConfig],
      envFilePath: [".env", ".env.local"],
    }),

    // Database
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: "postgres",
        host: configService.get<string>("database.host"),
        port: configService.get<number>("database.port"),
        username: configService.get<string>("database.username"),
        password: configService.get<string>("database.password"),
        database: configService.get<string>("database.name"),
        ssl: configService.get<boolean>("database.ssl")
          ? { rejectUnauthorized: false }
          : false,
        entities: [__dirname + "/entities/**/*.entity{.ts,.js}"],
        synchronize: false, // NEVER use synchronize in production
        logging: configService.get<string>("app.nodeEnv") === "development",
      }),
      inject: [ConfigService],
    }),

    // Feature Modules
    AuthModule,
    OrganizationModule,
    ProjectModule,
    TaskModule,
    SprintModule,
    TimeLogModule,
    TimesheetModule,
    CommentModule,
    AttachmentModule,
    TaskLinkModule,
    UserModule,
    TagModule,
    LeadershipModule,
    ReportModule,
    AccessControlModule,
    BusinessUnitModule,
    ActivityLogModule,
    ChatModule,
    NotificationModule,
  ],
  providers: [
    {
      provide: APP_INTERCEPTOR,
      useClass: LoggingInterceptor,
    },
  ],
})
export class AppModule {}
