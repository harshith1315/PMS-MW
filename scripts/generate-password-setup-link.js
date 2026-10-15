const { createHash, randomBytes } = require("crypto");
const path = require("path");
const dotenv = require("dotenv");
const { Pool } = require("pg");

dotenv.config({ path: path.resolve(__dirname, "..", ".env") });

async function main() {
  const [orgId, email] = process.argv.slice(2);
  if (!orgId || !email) {
    throw new Error("Usage: node scripts/generate-password-setup-link.js <org-id> <email>");
  }

  const token = randomBytes(32).toString("hex");
  const tokenHash = createHash("sha256").update(token).digest("hex");
  const pool = new Pool({
    host: process.env.DATABASE_HOST,
    port: Number(process.env.DATABASE_PORT || 5432),
    database: process.env.DATABASE_NAME,
    user: process.env.DATABASE_USERNAME,
    password: process.env.DATABASE_PASSWORD,
    ssl: process.env.DATABASE_SSL === "true" ? { rejectUnauthorized: false } : false,
  });

  try {
    const result = await pool.query(
      `UPDATE app_user
       SET password_setup_token_hash = $1,
           password_setup_expires_at = NOW() + INTERVAL '48 hours'
       WHERE org_id = $2::uuid
         AND LOWER(email) = LOWER($3)
         AND status = 'ACTIVE'
       RETURNING id`,
      [tokenHash, orgId, email.trim()],
    );
    if (result.rowCount !== 1) {
      throw new Error("Expected one active user matching that organization and email");
    }

    const baseUrl = (process.env.FRONTEND_BASE_URL || "http://localhost:5173").replace(/\/$/, "");
    console.log(`${baseUrl}/set-password?token=${encodeURIComponent(token)}`);
  } finally {
    await pool.end();
  }
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
