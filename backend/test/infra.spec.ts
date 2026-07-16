import { Writable } from 'node:stream';
import { Test } from '@nestjs/testing';
import pino from 'pino';
import { z } from 'zod';
import { RedisModule } from '../src/shared/redis/redis.module';
import {
  DistributedLock,
  SlidingWindowLimiter,
} from '../src/shared/redis/redis.primitives';
import {
  REDACTED_PATHS,
  REDACTION_CENSOR,
} from '../src/shared/logging/logger';
import {
  KmsEnvelopeService,
  type KmsClient,
} from '../src/shared/crypto/kms-envelope.service';
import { ZodValidationPipe } from '../src/shared/validation/zod-validation.pipe';
import { uuidSchema } from '../src/shared/validation/common-schemas';
import { AppException } from '../src/shared/errors/app-exception';
import {
  ConfigHealthIndicator,
  DatabaseHealthIndicator,
  RedisHealthIndicator,
} from '../src/shared/health/health.indicators';
import type { PrismaService } from '../src/shared/prisma/prisma.service';
import { RedisService } from '../src/shared/redis/redis.service';

/**
 * INFRA-006 Required Test: redaction proves no sensitive field reaches a log sink;
 * plus round-trip / injectability smoke of the remaining primitives (crypto, zod
 * pipe, health indicators) so every primitive is unit-tested (Acceptance Criteria).
 */
describe('logger redaction (BIS §1.6)', () => {
  it('never emits sensitive values, keeping safe fields', () => {
    let output = '';
    const sink = new Writable({
      write(chunk, _enc, cb) {
        output += chunk.toString();
        cb();
      },
    });
    const log = pino(
      { redact: { paths: [...REDACTED_PATHS], censor: REDACTION_CENSOR } },
      sink,
    );

    log.info(
      {
        password: 'hunter2',
        portalCookie: 'ASP.NET_SessionId=SECRETCOOKIE',
        refreshToken: 'rt-SECRET',
        user: { token: 'jwt-SECRET', name: 'Wei' },
      },
      'auth attempt',
    );

    for (const secret of [
      'hunter2',
      'SECRETCOOKIE',
      'rt-SECRET',
      'jwt-SECRET',
    ]) {
      expect(output).not.toContain(secret);
    }
    expect(output).toContain(REDACTION_CENSOR);
    expect(output).toContain('Wei'); // non-sensitive field survives
  });
});

describe('KmsEnvelopeService (BIS §2.2/§7)', () => {
  // Fake KMS: wraps the DEK by prefixing, unwraps by stripping — reversible, so the
  // envelope round-trip is exercised without a live KMS.
  const fakeKms: KmsClient = {
    encrypt: async ({ plaintext }) => [
      { ciphertext: Buffer.concat([Buffer.from('WRAP'), plaintext]) },
    ],
    decrypt: async ({ ciphertext }) => [{ plaintext: Buffer.from(ciphertext).subarray(4) }],
  };

  it('round-trips a secret and never stores it in the clear', async () => {
    const svc = new KmsEnvelopeService(fakeKms);
    const secret = 'ASP.NET_SessionId=portal-cookie';

    const envelope = await svc.encrypt(secret);
    expect(envelope.ciphertext).not.toContain('portal-cookie');
    expect(Buffer.from(envelope.ciphertext, 'base64').toString('utf8')).not.toContain(
      'portal-cookie',
    );

    expect(await svc.decryptToString(envelope)).toBe(secret);
  });
});

describe('ZodValidationPipe (BIS §1.11)', () => {
  const pipe = new ZodValidationPipe(z.object({ id: uuidSchema }));

  it('passes valid payloads through, typed', () => {
    const id = '11111111-1111-1111-1111-111111111111';
    expect(pipe.transform({ id })).toEqual({ id });
  });

  it('rejects invalid payloads as VALIDATION_FAILED', () => {
    expect(() => pipe.transform({ id: 'nope' })).toThrow(AppException);
    try {
      pipe.transform({ id: 'nope' });
    } catch (error) {
      expect((error as AppException).code).toBe('VALIDATION_FAILED');
    }
  });
});

describe('health indicators (BIS §1.13)', () => {
  it('reports the database up when a probe query succeeds', async () => {
    const prisma = { $queryRaw: async () => [{ ok: 1 }] } as unknown as PrismaService;
    const result = await new DatabaseHealthIndicator(prisma).check();
    expect(result.database?.status).toBe('up');
  });

  it('reports redis up when ping returns PONG', async () => {
    const redis = { ping: async () => true } as unknown as RedisService;
    const result = await new RedisHealthIndicator(redis).check();
    expect(result.redis?.status).toBe('up');
  });

  it('fails config readiness when required env is missing', () => {
    const indicator = new ConfigHealthIndicator();
    delete process.env.KMS_KEY_NAME;
    expect(() => indicator.check('kms', ['KMS_KEY_NAME'])).toThrow();
    process.env.KMS_KEY_NAME = 'projects/p/locations/l/keyRings/r/cryptoKeys/k';
    expect(indicator.check('kms', ['KMS_KEY_NAME']).kms?.status).toBe('up');
  });
});

describe('DI wiring (DoD: shared services injectable)', () => {
  it('resolves the redis primitives through the module graph', async () => {
    // lazyConnect means constructing the client opens no socket, so .compile()
    // instantiates every provider without a live Redis.
    const moduleRef = await Test.createTestingModule({
      imports: [RedisModule],
    }).compile();

    expect(moduleRef.get(RedisService)).toBeInstanceOf(RedisService);
    expect(moduleRef.get(DistributedLock)).toBeInstanceOf(DistributedLock);
    expect(moduleRef.get(SlidingWindowLimiter)).toBeInstanceOf(SlidingWindowLimiter);

    await moduleRef.close();
  });
});
