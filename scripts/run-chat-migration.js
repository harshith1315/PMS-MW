const fs = require("fs");
const path = require("path");
const { Client } = require("pg");

function parseEnv(envPath) {
  const envText = fs.readFileSync(envPath, "utf8");
  const env = {};

  for (const raw of envText.split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith("#")) continue;

    const index = line.indexOf("=");
    if (index < 0) continue;

    const key = line.slice(0, index).trim();
    const value = line.slice(index + 1).trim();
    env[key] = value;
  }

  return env;
}

async function main() {
  const root = process.cwd();
  const env = parseEnv(path.join(root, ".env"));
  const migrationSql = fs.readFileSync(
    path.join(root, "database", "migration_chat_persistence.sql"),
    "utf8",
  );

  const client = new Client({
    host: env.DATABASE_HOST || "localhost",
    port: Number(env.DATABASE_PORT || 5432),
    database: env.DATABASE_NAME || "onelign_pms",
    user: env.DATABASE_USERNAME || "postgres",
    password: env.DATABASE_PASSWORD || "postgres",
    ssl: env.DATABASE_SSL === "true" ? { rejectUnauthorized: false } : false,
  });

  await client.connect();
  await client.query(migrationSql);

  const result = await client.query(
    "SELECT to_regclass('public.chat_session') AS chat_session, to_regclass('public.chat_message') AS chat_message",
  );

  console.log("Chat migration applied successfully.");
  console.log(result.rows[0]);

  await client.end();
}

main().catch((error) => {
  console.error("Chat migration failed:", error.message);
  process.exit(1);
});
