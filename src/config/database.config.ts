import { registerAs } from '@nestjs/config';

export const databaseConfig = registerAs('database', () => ({
  host: process.env.DATABASE_HOST || 'localhost',
  port: Number.parseInt(process.env.DATABASE_PORT ?? '5432', 10) || 5432,
  name: process.env.DATABASE_NAME || 'onelign_pms',
  username: process.env.DATABASE_USERNAME || 'postgres',
  password: process.env.DATABASE_PASSWORD || 'postgres',
  ssl: process.env.DATABASE_SSL === 'true',
}));
