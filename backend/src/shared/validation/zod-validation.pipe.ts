import { Injectable, type PipeTransform } from '@nestjs/common';
import { type ZodType, ZodError } from 'zod';
import { AppException } from '../errors/app-exception';

/**
 * Validates and narrows request payloads against a zod schema (BIS §1.11). A parse
 * failure becomes the registered VALIDATION_FAILED error (never a raw zod dump), so
 * clients get a stable code while the field-level issues stay in developer-facing
 * `detail`. Parsed output is the typed value, giving handlers compile-time safety.
 */
@Injectable()
export class ZodValidationPipe<T> implements PipeTransform<unknown, T> {
  constructor(private readonly schema: ZodType<T>) {}

  transform(value: unknown): T {
    const result = this.schema.safeParse(value);
    if (result.success) {
      return result.data;
    }
    throw new AppException(
      'VALIDATION_FAILED',
      formatIssues(result.error),
      { issues: result.error.issues },
    );
  }
}

function formatIssues(error: ZodError): string {
  return error.issues
    .map((issue) => `${issue.path.join('.') || '(root)'}: ${issue.message}`)
    .join('; ');
}
