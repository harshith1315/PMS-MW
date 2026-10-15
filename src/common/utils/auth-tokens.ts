import { createHash, randomBytes } from "crypto";

export function createPasswordSetupToken(): {
  token: string;
  tokenHash: string;
} {
  const token = randomBytes(32).toString("hex");
  return {
    token,
    tokenHash: createHash("sha256").update(token).digest("hex"),
  };
}

export function hashPasswordSetupToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}
