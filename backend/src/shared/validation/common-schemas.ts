import { z } from 'zod';

/**
 * Reusable primitive schemas shared across module contracts (BIS §1.11). Feature
 * modules compose these so validation of common shapes — ids, cursors, timestamps —
 * stays consistent with the API contract.
 */
export const uuidSchema = z.string().uuid();

export const isoDateTimeSchema = z.string().datetime({ offset: true });

/** Opaque cursor for keyset pagination (BIS §5): base64url, bounded length. */
export const cursorSchema = z
  .string()
  .regex(/^[A-Za-z0-9_-]+$/)
  .max(512);

/** Standard forward-pagination query (cursor + bounded page size). */
export const paginationSchema = z.object({
  cursor: cursorSchema.optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export type Pagination = z.infer<typeof paginationSchema>;
