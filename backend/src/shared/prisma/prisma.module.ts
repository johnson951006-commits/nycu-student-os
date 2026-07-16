import { Global, Module } from '@nestjs/common';
import { PrismaDirectService } from './prisma-direct.service';
import { PrismaService } from './prisma.service';

/**
 * Global provider for the two Prisma clients (DB §10.2 / BIS §6.1): the pooled
 * [PrismaService] (PgBouncer) and the [PrismaDirectService] (direct).
 */
@Global()
@Module({
  providers: [PrismaService, PrismaDirectService],
  exports: [PrismaService, PrismaDirectService],
})
export class PrismaModule {}
