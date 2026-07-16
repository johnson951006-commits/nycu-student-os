-- 0001_init — canonical schema (INFRA-005 / D-1).
-- Transcribed verbatim from Database Design §7 (the canonical DDL). Contains the
-- objects Prisma cannot express (triggers, RLS, partitions, partial/expression/
-- GIN/BRIN indexes, generated columns, BIT). NO portal_credentials (IRR A1 / B-1).
-- Includes IRR Part 13 deltas: portal_page_health, sync_jobs.category_state.
-- offline_cache_metadata RLS is device-scoped per the ratified Option-A amendment.

-- ============================================================
-- 0. Preamble
-- ============================================================
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE OR REPLACE FUNCTION trg_touch_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END $$;

-- ============================================================
-- 1. Identity & sessions
-- ============================================================
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id      TEXT NOT NULL,
  display_name    TEXT,
  email           TEXT,
  locale          TEXT NOT NULL DEFAULT 'zh-TW'
                    CHECK (locale IN ('zh-TW','en')),
  role_preference TEXT CHECK (role_preference IN ('student','ta')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);
CREATE UNIQUE INDEX users_student_id_key ON users (student_id) WHERE deleted_at IS NULL;
CREATE TRIGGER users_touch BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE user_settings (
  user_id                  UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  theme                    TEXT NOT NULL DEFAULT 'auto' CHECK (theme IN ('auto','light','dark')),
  week_display             TEXT NOT NULL DEFAULT 'mon-fri' CHECK (week_display IN ('mon-fri','mon-sun')),
  background_sync_enabled  BOOLEAN NOT NULL DEFAULT true,
  wifi_only_sync           BOOLEAN NOT NULL DEFAULT false,
  show_hidden_assignments  BOOLEAN NOT NULL DEFAULT false,
  dashboard_layout         JSONB NOT NULL DEFAULT '[]',
  created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at               TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER user_settings_touch BEFORE UPDATE ON user_settings
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE portal_sessions (
  user_id           UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  enc_cookie_jar    BYTEA NOT NULL,
  dek_wrapped       BYTEA NOT NULL,
  status            TEXT NOT NULL DEFAULT 'ACTIVE'
                      CHECK (status IN ('ACTIVE','STALE','EXPIRED','REAUTH_REQUIRED')),
  last_validated_at TIMESTAMPTZ,
  fail_count        SMALLINT NOT NULL DEFAULT 0 CHECK (fail_count >= 0),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER portal_sessions_touch BEFORE UPDATE ON portal_sessions
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();
-- NOTE: no credentials table exists anywhere in this schema (IRR A1 / B-1).

CREATE TABLE app_sessions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  refresh_hash  TEXT NOT NULL,
  rotated_from  UUID REFERENCES app_sessions(id),
  device_label  TEXT,
  expires_at    TIMESTAMPTZ NOT NULL,
  revoked_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX app_sessions_refresh_key ON app_sessions (refresh_hash);
CREATE INDEX app_sessions_live_idx ON app_sessions (user_id) WHERE revoked_at IS NULL;

CREATE TABLE devices (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform      TEXT NOT NULL CHECK (platform IN ('ios','android','web')),
  push_token    TEXT NOT NULL,
  push_enabled  BOOLEAN NOT NULL DEFAULT true,
  app_version   TEXT,
  last_seen_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (platform, push_token)
);
CREATE INDEX devices_user_idx ON devices (user_id);
CREATE TRIGGER devices_touch BEFORE UPDATE ON devices
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

-- ============================================================
-- 2. Academic domain (single writer: sync worker role)
-- ============================================================
CREATE TABLE semesters (
  id          TEXT PRIMARY KEY,
  starts_on   DATE NOT NULL,
  ends_on     DATE NOT NULL CHECK (ends_on > starts_on),
  milestones  JSONB NOT NULL DEFAULT '[]',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER semesters_touch BEFORE UPDATE ON semesters
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE academic_calendar_exceptions (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  semester_id  TEXT NOT NULL REFERENCES semesters(id) ON DELETE RESTRICT,
  date         DATE NOT NULL,
  kind         TEXT NOT NULL CHECK (kind IN ('holiday','makeup','suspension')),
  label        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (semester_id, date, kind)
);

CREATE TABLE courses (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  semester_id   TEXT NOT NULL REFERENCES semesters(id) ON DELETE RESTRICT,
  portal_id     TEXT NOT NULL,
  code          TEXT NOT NULL,
  title_zh      TEXT,
  title_en      TEXT,
  instructor    TEXT,
  content_hash  TEXT NOT NULL,
  raw           JSONB,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (semester_id, portal_id)
);
CREATE INDEX courses_semester_idx ON courses (semester_id);
CREATE TRIGGER courses_touch BEFORE UPDATE ON courses
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE course_schedules (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id     UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  weekday       SMALLINT NOT NULL CHECK (weekday BETWEEN 1 AND 7),
  starts_at     TIME NOT NULL,
  ends_at       TIME NOT NULL,
  room          TEXT,
  building      TEXT,
  week_pattern  TEXT NOT NULL DEFAULT 'ALL' CHECK (week_pattern IN ('ALL','ODD','EVEN','CUSTOM')),
  week_bitmask  BIT(18),
  changed_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (ends_at > starts_at),
  CHECK (week_pattern <> 'CUSTOM' OR week_bitmask IS NOT NULL)
);
CREATE INDEX course_schedules_course_idx ON course_schedules (course_id, weekday);
CREATE TRIGGER course_schedules_touch BEFORE UPDATE ON course_schedules
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE enrollments (
  user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id    UUID NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
  color_index  SMALLINT NOT NULL DEFAULT 0 CHECK (color_index BETWEEN 0 AND 9),
  hidden       BOOLEAN NOT NULL DEFAULT false,
  dropped_at   TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, course_id)
);
CREATE INDEX enrollments_course_idx ON enrollments (course_id);
CREATE TRIGGER enrollments_touch BEFORE UPDATE ON enrollments
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE assignments (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id        UUID NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
  portal_id        TEXT,
  title            TEXT NOT NULL,
  description      TEXT,
  due_at           TIMESTAMPTZ,
  due_confidence   TEXT NOT NULL DEFAULT 'confirmed'
                     CHECK (due_confidence IN ('confirmed','parsed','missing')),
  source           TEXT NOT NULL DEFAULT 'portal' CHECK (source IN ('portal','manual')),
  status           TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','archived')),
  absent_run_count SMALLINT NOT NULL DEFAULT 0,
  content_hash     TEXT NOT NULL,
  raw              JSONB,
  search_tsv       tsvector GENERATED ALWAYS AS (
                     to_tsvector('simple', coalesce(title,'') || ' ' || coalesce(description,''))
                   ) STORED,
  first_seen_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at       TIMESTAMPTZ,
  CHECK (source = 'manual' OR portal_id IS NOT NULL),
  CHECK (due_confidence <> 'missing' OR due_at IS NULL)
);
CREATE UNIQUE INDEX assignments_portal_key ON assignments (course_id, portal_id)
  WHERE portal_id IS NOT NULL;
CREATE INDEX assignments_course_status_idx ON assignments (course_id, status);
CREATE INDEX assignments_due_idx ON assignments (due_at)
  WHERE status = 'active' AND deleted_at IS NULL;
CREATE INDEX assignments_search_idx ON assignments USING GIN (search_tsv);
CREATE TRIGGER assignments_touch BEFORE UPDATE ON assignments
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE assignment_attachments (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  portal_key    TEXT NOT NULL,
  filename      TEXT NOT NULL,
  url           TEXT,
  first_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  removed_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (assignment_id, portal_key)
);

CREATE TABLE assignment_grades (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE RESTRICT,
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  grade         TEXT NOT NULL,
  observed_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (assignment_id, user_id, observed_at)
);
CREATE INDEX assignment_grades_latest_idx
  ON assignment_grades (user_id, assignment_id, observed_at DESC);

CREATE TABLE exams (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id     UUID NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
  kind          TEXT NOT NULL CHECK (kind IN ('midterm','final','quiz')),
  starts_at     TIMESTAMPTZ,
  duration_min  SMALLINT,
  location      TEXT,
  source        TEXT NOT NULL DEFAULT 'portal' CHECK (source IN ('portal','manual')),
  content_hash  TEXT NOT NULL,
  changed_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX exams_course_idx ON exams (course_id);
CREATE INDEX exams_upcoming_idx ON exams (starts_at) WHERE starts_at IS NOT NULL;
CREATE TRIGGER exams_touch BEFORE UPDATE ON exams
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE assignment_overrides (
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  overrides     JSONB NOT NULL DEFAULT '{}',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, assignment_id)
);
CREATE TRIGGER assignment_overrides_touch BEFORE UPDATE ON assignment_overrides
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

-- ============================================================
-- 3. User productivity (Tier A soft delete; client-suppliable UUIDs)
-- ============================================================
CREATE TABLE todos (
  id            UUID PRIMARY KEY,
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  assignment_id UUID REFERENCES assignments(id) ON DELETE RESTRICT,
  course_id     UUID REFERENCES courses(id) ON DELETE SET NULL,
  title         TEXT NOT NULL,
  due_at        TIMESTAMPTZ,
  priority      SMALLINT NOT NULL DEFAULT 3 CHECK (priority BETWEEN 1 AND 3),
  completed_at  TIMESTAMPTZ,
  hidden_at     TIMESTAMPTZ,
  sort_order    DOUBLE PRECISION NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);
CREATE UNIQUE INDEX todos_auto_key ON todos (user_id, assignment_id)
  WHERE assignment_id IS NOT NULL AND deleted_at IS NULL;
CREATE INDEX todos_live_idx ON todos (user_id, due_at)
  WHERE completed_at IS NULL AND hidden_at IS NULL AND deleted_at IS NULL;
CREATE INDEX todos_assignment_idx ON todos (assignment_id);
CREATE TRIGGER todos_touch BEFORE UPDATE ON todos
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE sticky_notes (
  id                UUID PRIMARY KEY,
  user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  body              TEXT NOT NULL,
  color             TEXT NOT NULL DEFAULT 'yellow'
                      CHECK (color IN ('yellow','pink','blue','green','purple','gray')),
  pinned_date       DATE,
  pinned_dashboard  BOOLEAN NOT NULL DEFAULT true,
  archived_at       TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at        TIMESTAMPTZ
);
CREATE INDEX sticky_notes_board_idx ON sticky_notes (user_id)
  WHERE deleted_at IS NULL AND archived_at IS NULL;
CREATE INDEX sticky_notes_dated_idx ON sticky_notes (user_id, pinned_date)
  WHERE pinned_date IS NOT NULL AND deleted_at IS NULL;
CREATE TRIGGER sticky_notes_touch BEFORE UPDATE ON sticky_notes
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE calendar_events (
  id          UUID PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id   UUID REFERENCES courses(id) ON DELETE SET NULL,
  title       TEXT NOT NULL,
  starts_at   TIMESTAMPTZ NOT NULL,
  ends_at     TIMESTAMPTZ,
  all_day     BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ,
  CHECK (ends_at IS NULL OR ends_at > starts_at)
);
CREATE INDEX calendar_events_range_idx ON calendar_events (user_id, starts_at)
  WHERE deleted_at IS NULL;
CREATE TRIGGER calendar_events_touch BEFORE UPDATE ON calendar_events
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

-- ============================================================
-- 4. Notifications
-- ============================================================
CREATE TABLE notification_prefs (
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  scope       TEXT NOT NULL CHECK (scope IN ('global','course','assignment')),
  scope_id    UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
  enabled     BOOLEAN,
  offsets     JSONB,
  quiet_hours JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, scope, scope_id),
  CHECK (scope <> 'global' OR scope_id = '00000000-0000-0000-0000-000000000000'),
  CHECK (scope = 'global' OR quiet_hours IS NULL)
);
CREATE TRIGGER notification_prefs_touch BEFORE UPDATE ON notification_prefs
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE notification_schedules (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  subject_type  TEXT NOT NULL CHECK (subject_type IN ('assignment','exam')),
  subject_id    UUID NOT NULL,
  fire_at       TIMESTAMPTZ NOT NULL,
  offset_label  TEXT NOT NULL,
  kind          TEXT NOT NULL DEFAULT 'offset' CHECK (kind IN ('offset','snooze')),
  status        TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','sending','sent','canceled','superseded')),
  generation    INT NOT NULL DEFAULT 1 CHECK (generation >= 1),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, subject_type, subject_id, offset_label, generation)
);
CREATE INDEX notif_sched_due_idx ON notification_schedules (fire_at)
  WHERE status = 'pending';
CREATE TRIGGER notif_sched_touch BEFORE UPDATE ON notification_schedules
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

-- Partitioned append-only delivery log (monthly partitions managed by pg_partman
-- in prod, DB §10.1; a DEFAULT partition keeps a fresh DB immediately insertable).
CREATE TABLE push_deliveries (
  id           BIGINT GENERATED ALWAYS AS IDENTITY,
  schedule_id  UUID REFERENCES notification_schedules(id) ON DELETE RESTRICT,
  device_id    UUID REFERENCES devices(id) ON DELETE CASCADE,
  digest_key   TEXT,
  result       TEXT NOT NULL CHECK (result IN ('ok','token_invalid','throttled','error')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);
CREATE TABLE push_deliveries_default PARTITION OF push_deliveries DEFAULT;
CREATE INDEX push_deliveries_sched_idx ON push_deliveries (schedule_id);
CREATE INDEX push_deliveries_brin ON push_deliveries USING BRIN (created_at);

CREATE TABLE notification_history (
  id           UUID NOT NULL DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  kind         TEXT NOT NULL CHECK (kind IN
                 ('deadline_changed','new_assignment','room_changed','exam_changed',
                  'grade_posted','reminder_sent','sync_issue','restored','assignment_updated',
                  'assignment_archived','attachment_updated')),
  subject_type TEXT CHECK (subject_type IN ('assignment','exam','course','sync')),
  subject_id   UUID,
  payload      JSONB NOT NULL,
  read_at      TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);
CREATE TABLE notification_history_default PARTITION OF notification_history DEFAULT;
CREATE INDEX notif_hist_feed_idx ON notification_history (user_id, created_at DESC);
CREATE INDEX notif_hist_unread_idx ON notification_history (user_id) WHERE read_at IS NULL;

CREATE OR REPLACE FUNCTION trg_history_readonly() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF (to_jsonb(NEW) - 'read_at') IS DISTINCT FROM (to_jsonb(OLD) - 'read_at') THEN
    RAISE EXCEPTION 'notification_history is append-only (read_at excepted)';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER notif_hist_guard BEFORE UPDATE ON notification_history
  FOR EACH ROW EXECUTE FUNCTION trg_history_readonly();

-- ============================================================
-- 5. Synchronization & operations
-- ============================================================
CREATE TABLE sync_jobs (
  user_id              UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  tier                 TEXT NOT NULL DEFAULT 'warm' CHECK (tier IN ('hot','warm','cold','paused')),
  next_sync_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  claimed_at           TIMESTAMPTZ,
  claimed_by           TEXT,
  consecutive_failures SMALLINT NOT NULL DEFAULT 0,
  category_state       JSONB NOT NULL DEFAULT '{}',
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX sync_jobs_due_idx ON sync_jobs (next_sync_at) WHERE claimed_at IS NULL;
CREATE TRIGGER sync_jobs_touch BEFORE UPDATE ON sync_jobs
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE sync_runs (
  id                BIGINT GENERATED ALWAYS AS IDENTITY,
  user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  trigger           TEXT NOT NULL CHECK (trigger IN
                      ('scheduled','manual','initial','retry','backfill')),
  status            TEXT NOT NULL DEFAULT 'running' CHECK (status IN
                      ('running','ok','partial','failed','cancelled')),
  categories        JSONB,
  error_code        TEXT,
  portal_version_id TEXT,
  started_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  finished_at       TIMESTAMPTZ,
  duration_ms       INT,
  PRIMARY KEY (id, started_at)
) PARTITION BY RANGE (started_at);
CREATE TABLE sync_runs_default PARTITION OF sync_runs DEFAULT;
CREATE INDEX sync_runs_user_idx ON sync_runs (user_id, started_at DESC);
CREATE INDEX sync_runs_brin ON sync_runs USING BRIN (started_at);

CREATE TABLE offline_cache_metadata (
  device_id             UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  category              TEXT NOT NULL CHECK (category IN
                          ('courses','schedules','assignments','exams','todos','notes',
                           'calendar','notification_history')),
  last_delta_cursor     TEXT,
  last_full_sync_at     TIMESTAMPTZ,
  client_schema_version INT NOT NULL DEFAULT 1,
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (device_id, category)
);
CREATE TRIGGER offline_cache_touch BEFORE UPDATE ON offline_cache_metadata
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE portal_versions (
  id           TEXT NOT NULL,
  page_type    TEXT NOT NULL,
  dom_version  INT NOT NULL,
  signatures   TEXT[] NOT NULL,
  parser_range TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','deprecated','safe_mode')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (id, page_type)
);
CREATE TRIGGER portal_versions_touch BEFORE UPDATE ON portal_versions
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

-- IRR Part 13 delta: per-page portal health.
CREATE TABLE portal_page_health (
  page_type        TEXT PRIMARY KEY
                     CHECK (page_type IN ('course','assignment','exam','grade',
                                          'announcement','calendar')),
  parser_version   TEXT NOT NULL,
  dom_version      INT,
  last_signature   TEXT,
  signature_known  BOOLEAN NOT NULL DEFAULT true,
  last_success_at  TIMESTAMPTZ,
  failure_count    INT NOT NULL DEFAULT 0,
  state            TEXT NOT NULL DEFAULT 'active'
                     CHECK (state IN ('active','safe_mode','disabled')),
  state_reason     TEXT,
  state_since      TIMESTAMPTZ,
  recovery         TEXT CHECK (recovery IN ('auto','parser-deploy','ops')),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER portal_page_health_touch BEFORE UPDATE ON portal_page_health
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

CREATE TABLE system_settings (
  key         TEXT PRIMARY KEY,
  value       JSONB NOT NULL,
  updated_by  TEXT NOT NULL,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 6. Statistics
-- ============================================================
CREATE TABLE weekly_statistics (
  user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  week_start       DATE NOT NULL,
  total_tasks      INT NOT NULL DEFAULT 0 CHECK (total_tasks >= 0),
  completed_tasks  INT NOT NULL DEFAULT 0 CHECK (completed_tasks >= 0),
  recalculated_at  TIMESTAMPTZ,
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, week_start),
  CHECK (completed_tasks <= total_tasks)
);
CREATE TRIGGER weekly_stats_touch BEFORE UPDATE ON weekly_statistics
  FOR EACH ROW EXECUTE FUNCTION trg_touch_updated_at();

-- ============================================================
-- 7. Row-Level Security (defense in depth — §11)
-- ============================================================
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;
CREATE POLICY todos_owner ON todos
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE sticky_notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY sticky_notes_owner ON sticky_notes
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY calendar_events_owner ON calendar_events
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE notification_prefs ENABLE ROW LEVEL SECURITY;
CREATE POLICY notification_prefs_owner ON notification_prefs
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE notification_schedules ENABLE ROW LEVEL SECURITY;
CREATE POLICY notification_schedules_owner ON notification_schedules
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE notification_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY notification_history_owner ON notification_history
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE assignment_overrides ENABLE ROW LEVEL SECURITY;
CREATE POLICY assignment_overrides_owner ON assignment_overrides
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE assignment_grades ENABLE ROW LEVEL SECURITY;
CREATE POLICY assignment_grades_owner ON assignment_grades
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE weekly_statistics ENABLE ROW LEVEL SECURITY;
CREATE POLICY weekly_statistics_owner ON weekly_statistics
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE devices ENABLE ROW LEVEL SECURITY;
CREATE POLICY devices_owner ON devices
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE app_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY app_sessions_owner ON app_sessions
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_settings_owner ON user_settings
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE portal_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY portal_sessions_owner ON portal_sessions
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
CREATE POLICY enrollments_owner ON enrollments
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE sync_runs ENABLE ROW LEVEL SECURITY;
CREATE POLICY sync_runs_owner ON sync_runs
  USING (user_id = current_setting('app.user_id', true)::uuid);

ALTER TABLE sync_jobs ENABLE ROW LEVEL SECURITY;
CREATE POLICY sync_jobs_owner ON sync_jobs
  USING (user_id = current_setting('app.user_id', true)::uuid);

-- offline_cache_metadata is device-keyed (no user_id); isolation via device
-- ownership (ratified Option-A amendment — DB §7 Revision Log v1.1).
ALTER TABLE offline_cache_metadata ENABLE ROW LEVEL SECURITY;
CREATE POLICY offline_cache_metadata_owner ON offline_cache_metadata
  USING (device_id IN (
    SELECT id FROM devices
    WHERE user_id = current_setting('app.user_id', true)::uuid
  ));
