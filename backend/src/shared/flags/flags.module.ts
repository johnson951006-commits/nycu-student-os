import { Global, Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { FeatureFlagService } from './feature-flag.service';
import { FlagsController } from './flags.controller';

/**
 * Feature-flag framework (BIS §12.4): global evaluation service + the
 * `/v1/config` remote-config endpoint. Imports PrismaModule so the module is
 * self-sufficient in any profile graph; storage is `system_settings` `flag:*`
 * rows (no new infra).
 */
@Global()
@Module({
  imports: [PrismaModule],
  controllers: [FlagsController],
  providers: [FeatureFlagService],
  exports: [FeatureFlagService],
})
export class FlagsModule {}
