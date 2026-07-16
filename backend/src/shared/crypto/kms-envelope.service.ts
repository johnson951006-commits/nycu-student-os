import {
  createCipheriv,
  createDecipheriv,
  randomBytes,
} from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';

/** DI token for the Cloud KMS client (BIS §7). */
export const KMS_CLIENT = Symbol('KMS_CLIENT');

/**
 * Minimal surface of the Cloud KMS client we depend on. Depending on the shape
 * rather than the concrete `KeyManagementServiceClient` keeps the service unit
 * testable with a fake wrapper (the KMS round-trip is exercised in CI/integration).
 */
export interface KmsClient {
  encrypt(request: {
    name: string;
    plaintext: Buffer;
  }): Promise<[{ ciphertext?: Uint8Array | string | null }]>;
  decrypt(request: {
    name: string;
    ciphertext: Buffer;
  }): Promise<[{ plaintext?: Uint8Array | string | null }]>;
}

/** Self-describing envelope produced by [KmsEnvelopeService.encrypt]. */
export interface Envelope {
  v: 1;
  wrappedDek: string;
  iv: string;
  authTag: string;
  ciphertext: string;
}

const ALGORITHM = 'aes-256-gcm';
const DEK_BYTES = 32;
const IV_BYTES = 12;

/**
 * Envelope encryption (BIS §2.2 / §7): each secret is sealed under a fresh
 * AES-256-GCM data-encryption key (DEK); the DEK itself is wrapped by a Cloud KMS
 * key-encryption key. Only the wrapped DEK is stored, so the raw key never leaves
 * KMS. Used for the Portal session cookie vault — NYCU passwords are never stored
 * (IRR A1 / B-1).
 */
@Injectable()
export class KmsEnvelopeService {
  private readonly keyName: string;

  constructor(@Inject(KMS_CLIENT) private readonly kms: KmsClient) {
    this.keyName = process.env.KMS_KEY_NAME ?? '';
  }

  async encrypt(plaintext: string | Buffer): Promise<Envelope> {
    const data = Buffer.isBuffer(plaintext) ? plaintext : Buffer.from(plaintext, 'utf8');
    const dek = randomBytes(DEK_BYTES);
    const iv = randomBytes(IV_BYTES);

    const cipher = createCipheriv(ALGORITHM, dek, iv);
    const ciphertext = Buffer.concat([cipher.update(data), cipher.final()]);
    const authTag = cipher.getAuthTag();

    const [wrapResponse] = await this.kms.encrypt({ name: this.keyName, plaintext: dek });
    const wrappedDek = toBuffer(wrapResponse.ciphertext);

    return {
      v: 1,
      wrappedDek: wrappedDek.toString('base64'),
      iv: iv.toString('base64'),
      authTag: authTag.toString('base64'),
      ciphertext: ciphertext.toString('base64'),
    };
  }

  async decrypt(envelope: Envelope): Promise<Buffer> {
    const [unwrapResponse] = await this.kms.decrypt({
      name: this.keyName,
      ciphertext: Buffer.from(envelope.wrappedDek, 'base64'),
    });
    const dek = toBuffer(unwrapResponse.plaintext);

    const decipher = createDecipheriv(ALGORITHM, dek, Buffer.from(envelope.iv, 'base64'));
    decipher.setAuthTag(Buffer.from(envelope.authTag, 'base64'));
    return Buffer.concat([
      decipher.update(Buffer.from(envelope.ciphertext, 'base64')),
      decipher.final(),
    ]);
  }

  async decryptToString(envelope: Envelope): Promise<string> {
    return (await this.decrypt(envelope)).toString('utf8');
  }
}

function toBuffer(value: Uint8Array | string | null | undefined): Buffer {
  if (value == null) {
    throw new Error('KMS returned an empty payload');
  }
  return typeof value === 'string' ? Buffer.from(value, 'base64') : Buffer.from(value);
}
