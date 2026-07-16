import {
  Injectable,
  Logger,
  type OnModuleDestroy,
  type OnModuleInit,
} from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';

/**
 * Pooled Prisma client (DB §10.2 / BIS §6.1). Connects through PgBouncer
 * (transaction pooling) via env("DATABASE_URL") — the default datasource of the
 * generated client. Used for all short-lived API queries and transactions.
 */
@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  async onModuleInit(): Promise<void> {
    await this.$connect();
    this.logger.log('Prisma (pooled) connected');
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }

  /**
   * Runs [fn] inside a transaction with the Row-Level-Security context set
   * (BIS §6.1). The per-request user id is applied as a transaction-local setting
   * so every RLS policy (`USING user_id = current_setting('app.user_id')`) scopes
   * each statement to that user. The value is bound as a parameter via
   * `set_config` — never string-interpolated (BIS §7).
   */
  runWithUser<T>(
    userId: string,
    fn: (tx: Prisma.TransactionClient) => Promise<T>,
  ): Promise<T> {
    return this.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT set_config('app.user_id', ${userId}, true)`;
      return fn(tx);
    });
  }
}
