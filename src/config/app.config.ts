import { registerAs } from "@nestjs/config";

export const appConfig = registerAs("app", () => ({
  nodeEnv: process.env.NODE_ENV || "development",
  port: Number.parseInt(process.env.PORT ?? "3000", 10) || 3000,
  logLevel: process.env.LOG_LEVEL || "debug",
  openAiApiKey: process.env.OPENAI_API_KEY || "",
  openAiModel: process.env.OPENAI_MODEL || "gpt-4o-mini",
  openAiBaseUrl: process.env.OPENAI_BASE_URL || "",
  openAiMaxTokens:
    Number.parseInt(process.env.OPENAI_MAX_TOKENS ?? "320", 10) || 320,
  openAiTemperature: Number.isFinite(Number(process.env.OPENAI_TEMPERATURE))
    ? Number(process.env.OPENAI_TEMPERATURE)
    : 0.1,
}));
