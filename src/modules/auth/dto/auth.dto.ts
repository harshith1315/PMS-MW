import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({ example: 'jane@company.com' })
  @IsEmail()
  @MaxLength(255)
  email: string;

  @ApiProperty({ minLength: 12, maxLength: 128 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  password: string;
}

export class SetPasswordDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(256)
  token: string;

  @ApiProperty({ minLength: 12, maxLength: 128 })
  @IsString()
  @MinLength(12)
  @MaxLength(128)
  password: string;
}
