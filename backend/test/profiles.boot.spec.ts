import { Test, TestingModuleBuilder } from '@nestjs/testing';
import { AppModule } from '../src/app.module';
import { APP_PROFILES, type AppProfile } from '../src/config/app-profile';
import { FlagsController } from '../src/shared/flags/flags.controller';
import { FLAG_REGISTRY } from '../src/shared/flags/registry';
import { PrismaService } from '../src/shared/prisma/prisma.service';

/**
 * Per-profile boot test (INFRA-004 Required Test): each APP_PROFILE assembles
 * and initializes without error, then shuts down cleanly (BIS §1.1/§1.2).
 *
 * Backing stores are stubbed at the DI seam — boot tests prove graph wiring,
 * not connectivity (that is the integration suite's job).
 */
describe('AppModule profile bootstrap', () => {
  const savedEnv = process.env;

  // Connection-free PrismaService stand-in: modules mounted in a profile may
  // inject it, but booting must not reach for a database.
  const prismaStub = {
    systemSetting: { findMany: async () => [] },
  };

  function buildProfile(profile: AppProfile): TestingModuleBuilder {
    return Test.createTestingModule({
      imports: [AppModule.register(profile)],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaStub);
  }

  beforeEach(() => {
    process.env = { ...savedEnv, NODE_ENV: 'test', PORT: '0', LOG_LEVEL: 'error' };
  });

  afterEach(() => {
    process.env = savedEnv;
  });

  it.each(APP_PROFILES)('boots the "%s" profile', async (profile) => {
    process.env.APP_PROFILE = profile;

    const moduleRef = await buildProfile(profile).compile();

    const app = moduleRef.createNestApplication();
    await app.init();
    expect(app).toBeDefined();
    await app.close();
  });

  it('api profile mounts the /v1/config endpoint (INFRA-010 gate regression)', async () => {
    process.env.APP_PROFILE = 'api';

    const moduleRef = await buildProfile('api').compile();
    const app = moduleRef.createNestApplication();
    await app.init();

    // The controller resolves from the REAL api graph (not a synthetic test
    // module) — proving the route is registered in the running application.
    const controller = app.get(FlagsController);
    const body = await controller.getConfig();

    expect(Object.keys(body.flags).sort()).toEqual(
      FLAG_REGISTRY.map((f) => f.key).sort(),
    );

    await app.close();
  });
});
