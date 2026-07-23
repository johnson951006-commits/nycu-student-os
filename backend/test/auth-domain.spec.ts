import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import {
  AuthTokens,
  PORTAL_SESSION_STATUSES,
  ROLE_PREFERENCES,
  USER_LOCALES,
} from '../src/modules/auth/domain';

/**
 * AUTH-001 Required Test: value-object invariants + schema parity.
 *
 * The domain models are behaviour-agnostic, so the meaningful assertions are
 * (a) the AuthTokens invariant, and (b) that every closed value domain matches
 * the canonical DDL CHECK constraints verbatim — the Acceptance Criterion
 * "fields match schema nullability exactly" has its value-domain counterpart
 * here, checked against the migration itself rather than a copy.
 */
const migrationSql = readFileSync(
  join(__dirname, '..', 'prisma', 'migrations', '0001_init', 'migration.sql'),
  'utf8',
);

describe('AuthTokens value object', () => {
  it('accepts a well-formed pair and exposes both tokens', () => {
    const tokens = AuthTokens.create('access-abc', 'refresh-xyz');
    expect(tokens.accessToken).toBe('access-abc');
    expect(tokens.refreshToken).toBe('refresh-xyz');
  });

  it('rejects an empty or blank accessToken', () => {
    expect(() => AuthTokens.create('', 'refresh-xyz')).toThrow(RangeError);
    expect(() => AuthTokens.create('   ', 'refresh-xyz')).toThrow(RangeError);
  });

  it('rejects an empty or blank refreshToken', () => {
    expect(() => AuthTokens.create('access-abc', '')).toThrow(RangeError);
    expect(() => AuthTokens.create('access-abc', '\t')).toThrow(RangeError);
  });

  it('is immutable (frozen — no field reassignment)', () => {
    const tokens = AuthTokens.create('access-abc', 'refresh-xyz');
    expect(Object.isFrozen(tokens)).toBe(true);
    expect(() => {
      (tokens as { accessToken: string }).accessToken = 'tampered';
    }).toThrow();
    expect(tokens.accessToken).toBe('access-abc');
  });

  it('compares by value', () => {
    const a = AuthTokens.create('access-abc', 'refresh-xyz');
    const b = AuthTokens.create('access-abc', 'refresh-xyz');
    const c = AuthTokens.create('access-abc', 'refresh-other');
    expect(a.equals(b)).toBe(true);
    expect(a.equals(c)).toBe(false);
  });
});

describe('closed value domains match the canonical DDL (DB §7)', () => {
  it('PortalSessionStatus matches portal_sessions.status CHECK', () => {
    for (const status of PORTAL_SESSION_STATUSES) {
      expect(migrationSql).toContain(`'${status}'`);
    }
    expect([...PORTAL_SESSION_STATUSES]).toEqual([
      'ACTIVE',
      'STALE',
      'EXPIRED',
      'REAUTH_REQUIRED',
    ]);
  });

  it('UserLocale matches users.locale CHECK', () => {
    expect([...USER_LOCALES]).toEqual(['zh-TW', 'en']);
    expect(migrationSql).toContain("locale IN ('zh-TW','en')");
  });

  it('RolePreference matches users.role_preference CHECK', () => {
    expect([...ROLE_PREFERENCES]).toEqual(['student', 'ta']);
    expect(migrationSql).toContain("role_preference IN ('student','ta')");
  });

  it('models no credential field — no password is ever stored (IRR A1/B-1)', () => {
    const domainDir = join(__dirname, '..', 'src', 'modules', 'auth', 'domain');
    for (const file of [
      'auth-user.ts',
      'app-session.ts',
      'portal-session.ts',
      'auth-tokens.ts',
    ]) {
      const source = readFileSync(join(domainDir, file), 'utf8');
      expect(source).not.toMatch(/readonly\s+password/i);
    }
  });
});
