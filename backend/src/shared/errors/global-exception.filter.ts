import {
  type ArgumentsHost,
  Catch,
  type ExceptionFilter,
  HttpException,
} from '@nestjs/common';
import type { Response } from 'express';
import { ZodError } from 'zod';
import { getRequestId } from '../logging/request-context';
import { logger } from '../logging/logger';
import { AppException } from './app-exception';
import { ERROR_CODES, isErrorCode, type ErrorCode } from './error-codes';

interface ProblemDocument {
  type: string;
  title: string;
  status: number;
  code: ErrorCode;
  requestId: string | undefined;
  meta?: Record<string, unknown>;
}

/**
 * The single edge translator (BIS §1.9): every thrown error becomes a stable
 * problem+json body keyed by a registered [ErrorCode]. Unknown throwables collapse
 * to E-UNEXPECTED so internals never leak. The developer-facing `detail` is logged,
 * never serialised to the client.
 */
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const res = host.switchToHttp().getResponse<Response>();
    const requestId = getRequestId();

    const { code, detail } = this.classify(exception);
    const def = ERROR_CODES[code];

    if (def.status >= 500) {
      logger.error({ requestId, code, err: exception, detail }, 'request failed');
    } else {
      logger.warn({ requestId, code, detail }, 'request rejected');
    }

    const meta = exception instanceof AppException ? exception.meta : undefined;
    const body: ProblemDocument = {
      type: `https://errors.nycu-student-os.app/${code}`,
      title: def.messages.en,
      status: def.status,
      code,
      requestId,
      ...(meta ? { meta } : {}),
    };

    res.status(def.status).json(body);
  }

  private classify(exception: unknown): { code: ErrorCode; detail?: string } {
    if (exception instanceof AppException) {
      return { code: exception.code, detail: exception.detail };
    }
    if (exception instanceof ZodError) {
      return { code: 'VALIDATION_FAILED', detail: exception.message };
    }
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const mapped = status === 400 ? 'VALIDATION_FAILED' : undefined;
      return { code: mapped ?? 'E-UNEXPECTED', detail: exception.message };
    }
    if (exception instanceof Error && isErrorCode(exception.message)) {
      return { code: exception.message, detail: exception.stack };
    }
    return {
      code: 'E-UNEXPECTED',
      detail: exception instanceof Error ? exception.stack : String(exception),
    };
  }
}
