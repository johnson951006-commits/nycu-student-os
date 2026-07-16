import { Test } from '@nestjs/testing';
import { AppModule } from '../src/app.module';
import { APP_PROFILES } from '../src/config/app-profile';

/**
 * Per-profile boot test (INFRA-004 Required Test): each APP_PROFILE assembles and
 * initializes without error, then shuts down cleanly (BIS §1.1/§1.2).
 */
describe('AppModule profile bootstrap', () => {
  const savedEnv = process.env;

  beforeEach(() => {
    process.env = { ...savedEnv, NODE_ENV: 'test', PORT: '0', LOG_LEVEL: 'error' };
  });

  afterEach(() => {
    process.env = savedEnv;
  });

  it.each(APP_PROFILES)('boots the "%s" profile', async (profile) => {
    process.env.APP_PROFILE = profile;

    const moduleRef = await Test.createTestingModule({
      imports: [AppModule.register(profile)],
    }).compile();

    const app = moduleRef.createNestApplication();
    await app.init();
    expect(app).toBeDefined();
    await app.close();
  });
});
