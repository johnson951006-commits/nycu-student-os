import type { ArgumentsHost } from '@nestjs/common';
import { HttpException } from '@nestjs/common';
import { z } from 'zod';
import {
  ERROR_CODES,
  IRR_MATRIX_CODES,
  isErrorCode,
} from '../src/shared/errors/error-codes';
import { AppException } from '../src/shared/errors/app-exception';
import { GlobalExceptionFilter } from '../src/shared/errors/global-exception.filter';

/**
 * INFRA-006 Required Test: error-registry completeness vs IRR §7, and the edge
 * translator's classification of every throwable into a registered code.
 */
describe('error-code registry (BIS §1.9 / IRR §7)', () => {
  it('contains every IRR §7 matrix code', () => {
    for (const code of IRR_MATRIX_CODES) {
      expect(ERROR_CODES[code]).toBeDefined();
    }
  });

  it('gives every code a status and both en + zh-TW messages', () => {
    for (const [code, def] of Object.entries(ERROR_CODES)) {
      expect(typeof def.status).toBe('number');
      expect(def.messages.en.length).toBeGreaterThan(0);
      expect(def.messages['zh-TW'].length).toBeGreaterThan(0);
      // No leaking of the code/jargon into the user-facing English string.
      expect(def.messages.en).not.toContain(code);
    }
  });

  it('recognises registered codes and rejects unknown ones', () => {
    expect(isErrorCode('E-PORTAL-DOWN')).toBe(true);
    expect(isErrorCode('NOT-A-CODE')).toBe(false);
  });
});

describe('GlobalExceptionFilter', () => {
  function run(exception: unknown): { status?: number; body?: Record<string, unknown> } {
    let status: number | undefined;
    let body: Record<string, unknown> | undefined;
    const res = {
      status(code: number) {
        status = code;
        return this;
      },
      json(payload: Record<string, unknown>) {
        body = payload;
        return this;
      },
    };
    const host = {
      switchToHttp: () => ({ getResponse: () => res }),
    } as unknown as ArgumentsHost;
    new GlobalExceptionFilter().catch(exception, host);
    return { status, body };
  }

  it('maps an AppException to its registered status and code', () => {
    const { status, body } = run(new AppException('SYNC_COOLDOWN', 'too soon'));
    expect(status).toBe(429);
    expect(body?.code).toBe('SYNC_COOLDOWN');
    // developer detail must never be serialised to the client
    expect(JSON.stringify(body)).not.toContain('too soon');
  });

  it('maps a ZodError to VALIDATION_FAILED (400)', () => {
    const err = z.object({ id: z.string() }).safeParse({ id: 1 });
    expect(err.success).toBe(false);
    const { status, body } = run((err as { error: unknown }).error);
    expect(status).toBe(400);
    expect(body?.code).toBe('VALIDATION_FAILED');
  });

  it('collapses an unknown throwable to E-UNEXPECTED (500)', () => {
    const { status, body } = run(new Error('kaboom internal detail'));
    expect(status).toBe(500);
    expect(body?.code).toBe('E-UNEXPECTED');
    expect(JSON.stringify(body)).not.toContain('kaboom internal detail');
  });

  it('treats a 400 HttpException as VALIDATION_FAILED', () => {
    const { status, body } = run(new HttpException('bad', 400));
    expect(status).toBe(400);
    expect(body?.code).toBe('VALIDATION_FAILED');
  });
});
