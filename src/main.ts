import { NestFactory } from "@nestjs/core";
import { ValidationPipe, Logger } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { AppModule } from "./app.module";

async function bootstrap() {
  const logger = new Logger("Bootstrap");
  const app = await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);
  const port = configService.get<number>("PORT", 3000);
  const nodeEnv =
    configService.get<string>("app.nodeEnv") ||
    process.env.NODE_ENV ||
    "development";
  const isProduction = nodeEnv === "production";

  // Global prefix
  app.setGlobalPrefix("api/v1");

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // CORS
  app.enableCors({
    origin: true,
    credentials: true,
  });

  if (!isProduction) {
    // Swagger is available for local/dev/staging API testing.
    const swaggerConfig = new DocumentBuilder()
      .setTitle("OneLign PMS API")
      .setDescription("Multi-tenant Agile Project Management System API")
      .setVersion("1.0")
      .addBearerAuth(
        {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
          name: "Authorization",
          description: "Enter application JWT access token",
          in: "header",
        },
        "bearer",
      )
      .addTag("Auth", "Authentication endpoints")
      .addTag("Organizations", "Organization management (Super Admin)")
      .addTag("Projects", "Project management")
      .addTag("Tasks", "Task management")
      .addTag("Sprints", "Sprint management")
      .addTag("Time Logs", "Time tracking")
      .addTag("Comments", "Task comments")
      .addTag("Attachments", "File attachments")
      .addTag("Task Links", "Task relationships")
      .build();

    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup("api/docs", app, document, {
      swaggerOptions: {
        persistAuthorization: true,
      },
    });
  }

  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}`);
  if (!isProduction) {
    console.log(`Swagger documentation: http://localhost:${port}/api/docs`);
  }
}

bootstrap();
