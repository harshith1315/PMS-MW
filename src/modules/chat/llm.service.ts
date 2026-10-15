import { Injectable, Logger, OnModuleInit } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import OpenAI from "openai";

const OPENAI_REQUEST_TIMEOUT_MS = 60_000;

@Injectable()
export class LlmService implements OnModuleInit {
  private readonly logger = new Logger(LlmService.name);
  private readonly openAiApiKey: string;
  private readonly openAiModel: string;
  private readonly openAiBaseUrl?: string;
  private readonly openAiMaxTokens: number;
  private readonly openAiTemperature: number;
  private readonly openai: OpenAI;

  constructor(private readonly configService: ConfigService) {
    this.openAiApiKey = this.configService.get<string>("app.openAiApiKey", "");
    this.openAiModel = this.configService.get<string>(
      "app.openAiModel",
      "gpt-4o-mini",
    );
    this.openAiBaseUrl =
      this.configService.get<string>("app.openAiBaseUrl") || undefined;
    this.openAiMaxTokens = this.configService.get<number>(
      "app.openAiMaxTokens",
      320,
    );
    this.openAiTemperature = this.configService.get<number>(
      "app.openAiTemperature",
      0.1,
    );

    this.openai = new OpenAI({
      apiKey: this.openAiApiKey || "missing-key",
      baseURL: this.openAiBaseUrl,
    });
  }

  async onModuleInit() {
    if (!this.openAiApiKey) {
      this.logger.warn(
        "OPENAI_API_KEY is not configured. AI endpoints will return configuration errors until it is set.",
      );
      return;
    }

    this.logger.log(
      `AI provider configured. Using model '${this.openAiModel}'${this.openAiBaseUrl ? " with custom base URL." : "."}`,
    );
  }

  async generate(
    prompt: string,
    onTextChunk?: (chunk: string) => void,
  ): Promise<string> {
    if (!this.openAiApiKey) {
      throw new Error(
        "AI provider is not configured on the server. Set OPENAI_API_KEY and retry.",
      );
    }

    const trimmedPrompt = prompt.trim();
    if (!trimmedPrompt) {
      throw new Error("Prompt cannot be empty.");
    }

    const abortController = new AbortController();
    const timeoutHandle = setTimeout(() => {
      abortController.abort();
    }, OPENAI_REQUEST_TIMEOUT_MS);

    try {
      if (onTextChunk) {
        return await this.generateStreaming(
          trimmedPrompt,
          onTextChunk,
          abortController.signal,
        );
      }

      return await this.generateSingle(trimmedPrompt, abortController.signal);
    } catch (error) {
      const normalized = this.normalizeProviderError(error);
      this.logger.error(normalized.logMessage);
      throw new Error(normalized.clientMessage);
    } finally {
      clearTimeout(timeoutHandle);
    }
  }

  private async generateSingle(
    prompt: string,
    signal: AbortSignal,
  ): Promise<string> {
    const response = await this.openai.chat.completions.create(
      {
        model: this.openAiModel,
        messages: [{ role: "user", content: prompt }],
        max_tokens: this.openAiMaxTokens,
        temperature: this.openAiTemperature,
      },
      { signal },
    );

    return response.choices[0]?.message?.content?.trim() || "";
  }

  private async generateStreaming(
    prompt: string,
    onTextChunk: (chunk: string) => void,
    signal: AbortSignal,
  ): Promise<string> {
    const stream = await this.openai.chat.completions.create(
      {
        model: this.openAiModel,
        messages: [{ role: "user", content: prompt }],
        max_tokens: this.openAiMaxTokens,
        temperature: this.openAiTemperature,
        stream: true,
      },
      { signal },
    );

    let fullText = "";
    for await (const part of stream) {
      const chunk = part.choices[0]?.delta?.content || "";
      if (!chunk) continue;
      fullText += chunk;
      onTextChunk(chunk);
    }

    return fullText.trim();
  }

  private normalizeProviderError(error: unknown): {
    clientMessage: string;
    logMessage: string;
  } {
    const err = error as {
      name?: string;
      message?: string;
      status?: number;
      code?: string;
      type?: string;
    };

    const status = err?.status;
    const code = err?.code || "unknown";
    const reason = err?.message || "Unknown provider error";
    const aborted = err?.name === "AbortError";

    if (aborted) {
      return {
        clientMessage: "AI request timed out. Please try again.",
        logMessage: "OpenAI request timed out.",
      };
    }

    if (status === 401 || status === 403) {
      return {
        clientMessage:
          "AI provider authentication failed. Verify backend OpenAI credentials.",
        logMessage: `OpenAI auth failure (status=${status}, code=${code}).`,
      };
    }

    if (status === 429) {
      return {
        clientMessage:
          "AI provider rate limit reached. Please wait a moment and retry.",
        logMessage: `OpenAI rate limit (status=429, code=${code}).`,
      };
    }

    if (typeof status === "number" && status >= 500) {
      return {
        clientMessage:
          "AI provider is temporarily unavailable. Please try again shortly.",
        logMessage: `OpenAI upstream error (status=${status}, code=${code}).`,
      };
    }

    return {
      clientMessage: "Failed to generate AI response. Please try again later.",
      logMessage: `OpenAI request failed (status=${status ?? "n/a"}, code=${code}): ${reason}`,
    };
  }
}
