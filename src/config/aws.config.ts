import { registerAs } from '@nestjs/config';

export const awsConfig = registerAs('aws', () => ({
  region: process.env.AWS_REGION || 'us-east-1',
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  s3: {
    bucket: process.env.AWS_S3_BUCKET,
    signedUrlExpires:
      Number.parseInt(process.env.AWS_S3_SIGNED_URL_EXPIRES ?? '3600', 10) || 3600,
  },
}));
