import {
  Injectable,
  Logger,
  type OnModuleDestroy,
  type OnModuleInit,
} from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

/**
 * Direct Prisma client (DB §10.2 / BIS §6.1). Bypasses PgBouncer via
 * env("DATABASE_DIRECT_URL") for the interactive-transaction path (sync
 * ChangeSets) and for migrations, keeping the pooled path latency-clean. Uses a
 * small dedicated pool per instance (connection_limit configured on the URL).
 */
@Injectable()
export class PrismaDirectService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaDirectService.name);

  constructor() {
    super({ datasourceUrl: process.env.DATABASE_DIRECT_URL });
  }

  async onModuleInit(): Promise<void> {
    await this.$connect();
    this.logger.log('Prisma (direct) connected');
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }
}
