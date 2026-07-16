import 'reflect-metadata';
import { Logger, type INestApplicationContext } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { validateEnv } from './config/config.schema';

/**
 * Single entry point for all four run shapes (BIS §1.1/§1.2). The APP_PROFILE env
 * var selects the shape; config is validated fail-fast before anything starts.
 *   - api          → HTTP server listening on PORT
 *   - sync-worker / notif-worker / jobs → headless application context (their
 *     runtime loops/consumers are attached by INFRA-006 and the feature tasks)
 */
async function bootstrap(): Promise<void> {
  const config = validateEnv(process.env);
  const logger = new Logger('Bootstrap');
  const module = AppModule.register(config.APP_PROFILE);

  if (config.APP_PROFILE === 'api') {
    const app = await NestFactory.create(module);
    app.enableShutdownHooks();
    await app.listen(config.PORT);
    logger.log(`api profile listening on :${config.PORT} (env=${config.NODE_ENV})`);
    return;
  }

  const context: INestApplicationContext =
    await NestFactory.createApplicationContext(module);
  context.enableShutdownHooks();
  logger.log(`${config.APP_PROFILE} profile started (env=${config.NODE_ENV})`);
}

void bootstrap().catch((error: unknown) => {
  // Fail-fast (BIS §1.4): any bootstrap/config error aborts with a non-zero exit.
  new Logger('Bootstrap').error(
    error instanceof Error ? error.message : String(error),
  );
  process.exit(1);
});
