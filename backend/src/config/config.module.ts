import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { configuration } from './configuration';
import { validateEnv } from './config.schema';

/**
 * Global, typed configuration (BIS §1.4). `validate` enforces the schema at boot
 * (fail-fast); `load` exposes the namespaced typed config for injection.
 */
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      validate: validateEnv,
      load: [configuration],
    }),
  ],
})
export class AppConfigModule {}
