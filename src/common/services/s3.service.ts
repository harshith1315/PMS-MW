import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  S3Client,
  PutObjectCommand,
  DeleteObjectCommand,
  GetObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { v4 as uuidv4 } from 'uuid';

export interface UploadResult {
  key: string;
  url: string;
  fileName: string;
}

/**
 * S3 Service - AWS S3 file storage operations
 */
@Injectable()
export class S3Service {
  private readonly logger = new Logger(S3Service.name);
  private readonly s3Client: S3Client;
  private readonly bucket: string;
  private readonly signedUrlExpires: number;

  constructor(private readonly configService: ConfigService) {
    this.bucket = this.configService.get<string>('AWS_S3_BUCKET') ?? '';
    this.signedUrlExpires =
      this.configService.get<number>('AWS_S3_SIGNED_URL_EXPIRES') || 3600;

    this.s3Client = new S3Client({
      region: this.configService.get<string>('AWS_REGION') || 'us-east-1',
      credentials: {
        accessKeyId: this.configService.get<string>('AWS_ACCESS_KEY_ID') ?? '',
        secretAccessKey: this.configService.get<string>('AWS_SECRET_ACCESS_KEY') ?? '',
      },
    });

    this.logger.log(`S3 Service initialized for bucket: ${this.bucket}`);
  }

  /**
   * Upload a file to S3
   * @param file - File buffer or Express.Multer.File
   * @param folder - Folder path in S3 bucket
   * @param originalFileName - Original file name
   * @returns Upload result with key and URL
   */
  async uploadFile(
    file: Buffer | Express.Multer.File,
    folder: string,
    originalFileName?: string,
  ): Promise<UploadResult> {
    try {
      const buffer = Buffer.isBuffer(file) ? file : file.buffer;
      const fileName = originalFileName || (file as Express.Multer.File).originalname;
      const extension = fileName.split('.').pop();
      const uniqueFileName = `${uuidv4()}.${extension}`;
      const key = `${folder}/${uniqueFileName}`;

      const contentType = this.getContentType(extension ?? '');

      const command = new PutObjectCommand({
        Bucket: this.bucket,
        Key: key,
        Body: buffer,
        ContentType: contentType,
        Metadata: {
          originalFileName: fileName,
        },
      });

      await this.s3Client.send(command);

      const url = `https://${this.bucket}.s3.amazonaws.com/${key}`;

      this.logger.log(`File uploaded: ${key}`);

      return {
        key,
        url,
        fileName,
      };
    } catch (error) {
      this.logger.error(`Failed to upload file: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to upload file');
    }
  }

  /**
   * Delete a file from S3
   * @param key - S3 object key
   */
  async deleteFile(key: string): Promise<void> {
    try {
      const command = new DeleteObjectCommand({
        Bucket: this.bucket,
        Key: key,
      });

      await this.s3Client.send(command);
      this.logger.log(`File deleted: ${key}`);
    } catch (error) {
      this.logger.error(`Failed to delete file: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to delete file');
    }
  }

  /**
   * Get a pre-signed URL for downloading a file
   * @param key - S3 object key
   * @param expiresIn - URL expiration time in seconds (optional)
   * @returns Pre-signed URL
   */
  async getSignedUrl(key: string, expiresIn?: number): Promise<string> {
    try {
      const command = new GetObjectCommand({
        Bucket: this.bucket,
        Key: key,
      });

      const url = await getSignedUrl(this.s3Client, command, {
        expiresIn: expiresIn || this.signedUrlExpires,
      });

      return url;
    } catch (error) {
      this.logger.error(`Failed to generate signed URL: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to generate download URL');
    }
  }

  /**
   * Get a pre-signed URL for uploading a file directly to S3
   * @param folder - Folder path in S3 bucket
   * @param fileName - File name
   * @param contentType - MIME type
   * @returns Pre-signed upload URL and key
   */
  async getUploadSignedUrl(
    folder: string,
    fileName: string,
    contentType: string,
  ): Promise<{ uploadUrl: string; key: string }> {
    try {
      const extension = fileName.split('.').pop();
      const uniqueFileName = `${uuidv4()}.${extension}`;
      const key = `${folder}/${uniqueFileName}`;

      const command = new PutObjectCommand({
        Bucket: this.bucket,
        Key: key,
        ContentType: contentType,
      });

      const uploadUrl = await getSignedUrl(this.s3Client, command, {
        expiresIn: this.signedUrlExpires,
      });

      return { uploadUrl, key };
    } catch (error) {
      this.logger.error(`Failed to generate upload URL: ${error.message}`, error.stack);
      throw new InternalServerErrorException('Failed to generate upload URL');
    }
  }

  /**
   * Get content type based on file extension
   */
  private getContentType(extension: string): string {
    const contentTypes: Record<string, string> = {
      jpg: 'image/jpeg',
      jpeg: 'image/jpeg',
      png: 'image/png',
      gif: 'image/gif',
      pdf: 'application/pdf',
      doc: 'application/msword',
      docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      xls: 'application/vnd.ms-excel',
      xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      txt: 'text/plain',
      csv: 'text/csv',
      zip: 'application/zip',
      json: 'application/json',
    };

    return contentTypes[extension?.toLowerCase()] || 'application/octet-stream';
  }
}
