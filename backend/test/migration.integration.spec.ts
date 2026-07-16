import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import {
  PostgreSqlContainer,
  type StartedPostgreSqlContainer,
} from '@testcontainers/postgresql';
import { Client } from 'pg';

/**
 * Migration integration test (INFRA-005 Required Tests): applies 0001_init to a
 * fresh Postgres and verifies the canonical schema — clean apply, RLS + triggers
 * + partitions present, NO portal_credentials (B-1), the updated_at trigger, and
 * RLS blocking cross-user reads (the DoD). Runs against a testcontainer (CI has
 * Docker per QS §13).
 */
describe('0001_init canonical migration', () => {
  jest.setTimeout(180_000);

  let container: StartedPostgreSqlContainer;
  let admin: Client;

  const migrationSql = readFileSync(
    join(__dirname, '..', 'prisma', 'migrations', '0001_init', 'migration.sql'),
    'utf8',
  );

  beforeAll(async () => {
    container = await new PostgreSqlContainer('postgres:16.4-alpine').start();
    admin = new Client({ connectionString: container.getConnectionUri() });
    await admin.connect();
    // Applies cleanly to a fresh DB (Acceptance Criterion).
    await admin.query(migrationSql);
  });

  afterAll(async () => {
    await admin?.end();
    await container?.stop();
  });

  it('has no portal_credentials table (B-1 / IRR A1)', async () => {
    const res = await admin.query(`SELECT to_regclass('portal_credentials') AS t`);
    expect(res.rows[0].t).toBeNull();
  });

  it('has RLS enabled, triggers, and partitions present', async () => {
    const rls = await admin.query(
      `SELECT relname FROM pg_class WHERE relrowsecurity = true AND relkind = 'r'`,
    );
    expect(rls.rows.map((r) => r.relname)).toEqual(
      expect.arrayContaining([
        'todos',
        'sticky_notes',
        'offline_cache_metadata',
        'notification_history',
        'sync_jobs',
      ]),
    );

    const partitioned = await admin.query(
      `SELECT relname FROM pg_class WHERE relkind = 'p'`,
    );
    expect(partitioned.rows.map((r) => r.relname)).toEqual(
      expect.arrayContaining(['push_deliveries', 'notification_history', 'sync_runs']),
    );

    const trig = await admin.query(
      `SELECT tgname FROM pg_trigger WHERE tgname = 'users_touch'`,
    );
    expect(trig.rowCount).toBe(1);
  });

  it('updated_at trigger bumps the timestamp on UPDATE', async () => {
    await admin.query(
      `INSERT INTO users (id, student_id) VALUES ('11111111-1111-1111-1111-111111111111', 'TRIG')`,
    );
    const before = await admin.query(
      `SELECT updated_at FROM users WHERE student_id = 'TRIG'`,
    );
    await new Promise((resolve) => setTimeout(resolve, 15));
    await admin.query(`UPDATE users SET display_name = 'x' WHERE student_id = 'TRIG'`);
    const after = await admin.query(
      `SELECT updated_at FROM users WHERE student_id = 'TRIG'`,
    );
    expect(new Date(after.rows[0].updated_at).getTime()).toBeGreaterThan(
      new Date(before.rows[0].updated_at).getTime(),
    );
  });

  it('RLS blocks cross-user reads on todos', async () => {
    const userA = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    const userB = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

    // Seed as the superuser admin (bypasses RLS) so both users' rows exist.
    await admin.query(
      `INSERT INTO users (id, student_id) VALUES ($1, 'A'), ($2, 'B')`,
      [userA, userB],
    );
    await admin.query(
      `INSERT INTO todos (id, user_id, title)
       VALUES (gen_random_uuid(), $1, 'A-todo'), (gen_random_uuid(), $2, 'B-todo')`,
      [userA, userB],
    );

    // A non-superuser role for which RLS is enforced.
    await admin.query(`CREATE ROLE app_api NOLOGIN`);
    await admin.query(`GRANT USAGE ON SCHEMA public TO app_api`);
    await admin.query(`GRANT SELECT ON todos TO app_api`);

    const scoped = new Client({ connectionString: container.getConnectionUri() });
    await scoped.connect();
    await scoped.query(`SET ROLE app_api`);
    await scoped.query(`SELECT set_config('app.user_id', $1, false)`, [userA]);
    const visible = await scoped.query(`SELECT title FROM todos ORDER BY title`);
    await scoped.end();

    expect(visible.rows.map((r) => r.title)).toEqual(['A-todo']);
  });
});
