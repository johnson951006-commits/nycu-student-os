import { validateEnv } from '../src/config/config.schema';

/**
 * Config-validation reject test (INFRA-004 Required Test) — fail-fast (BIS §1.4).
 */
describe('validateEnv (fail-fast config validation)', () => {
  it('accepts a valid api env', () => {
    expect(() =>
      validateEnv({ APP_PROFILE: 'api', NODE_ENV: 'test', PORT: '8080' }),
    ).not.toThrow();
  });

  it('rejects a missing APP_PROFILE', () => {
    expect(() => validateEnv({ NODE_ENV: 'test' })).toThrow(/APP_PROFILE/);
  });

  it('rejects an invalid APP_PROFILE', () => {
    expect(() => validateEnv({ APP_PROFILE: 'nope' })).toThrow();
  });

  it('rejects a non-numeric PORT', () => {
    expect(() => validateEnv({ APP_PROFILE: 'api', PORT: 'abc' })).toThrow();
  });

  it('rejects an out-of-range PORT', () => {
    expect(() => validateEnv({ APP_PROFILE: 'api', PORT: '70000' })).toThrow();
  });

  it('applies defaults for NODE_ENV, PORT, LOG_LEVEL', () => {
    const config = validateEnv({ APP_PROFILE: 'jobs' });
    expect(config.NODE_ENV).toBe('development');
    expect(config.PORT).toBe(8080);
    expect(config.LOG_LEVEL).toBe('info');
  });

  it('coerces PORT to a number', () => {
    const config = validateEnv({ APP_PROFILE: 'api', PORT: '9090' });
    expect(config.PORT).toBe(9090);
  });
});
