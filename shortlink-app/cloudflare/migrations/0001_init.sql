-- ============================================================
-- TABEL USERS
-- role: 'user' | 'admin' | 'super_admin'
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id          TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  email       TEXT NOT NULL UNIQUE,
  name        TEXT,
  role        TEXT NOT NULL DEFAULT 'user'
                CHECK(role IN ('user','admin','super_admin')),
  created_at  TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ============================================================
-- TABEL LINKS
-- user_id → siapa yang buat
-- slug harus unik (UNIQUE constraint)
-- ============================================================
CREATE TABLE IF NOT EXISTS links (
  id          TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  slug        TEXT NOT NULL UNIQUE,
  original_url TEXT NOT NULL,
  user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  click_count INTEGER NOT NULL DEFAULT 0,
  created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_links_slug    ON links(slug);
CREATE INDEX IF NOT EXISTS idx_links_user_id ON links(user_id);

-- ============================================================
-- TABEL CLICKS (analitik per-klik)
-- ============================================================
CREATE TABLE IF NOT EXISTS clicks (
  id         TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  link_id    TEXT NOT NULL REFERENCES links(id) ON DELETE CASCADE,
  ip         TEXT,
  user_agent TEXT,
  referer    TEXT,
  clicked_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_clicks_link_id ON clicks(link_id);

-- ============================================================
-- TABEL ACTIVITY LOGS
-- Setiap pembuatan link, penghapusan, dan perubahan role dicatat
-- Hanya bisa diakses super_admin
-- ============================================================
CREATE TABLE IF NOT EXISTS activity_logs (
  id           TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  actor_id     TEXT REFERENCES users(id) ON DELETE SET NULL,
  actor_email  TEXT NOT NULL,
  actor_role   TEXT NOT NULL,
  action       TEXT NOT NULL
                 CHECK(action IN (
                   'create_link',
                   'delete_link',
                   'role_upgrade',
                   'role_downgrade'
                 )),
  target_type  TEXT NOT NULL CHECK(target_type IN ('link','user')),
  target_id    TEXT,
  target_label TEXT,
  detail       TEXT,
  created_at   TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_logs_actor_id  ON activity_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_logs_action    ON activity_logs(action);
CREATE INDEX IF NOT EXISTS idx_logs_created   ON activity_logs(created_at DESC);

-- ============================================================
-- TABEL AUTH TOKENS (magic link email)
-- ============================================================
CREATE TABLE IF NOT EXISTS auth_tokens (
  id         TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  email      TEXT NOT NULL,
  token      TEXT NOT NULL UNIQUE,
  expires_at TEXT NOT NULL,
  used       INTEGER NOT NULL DEFAULT 0
);

-- ============================================================
-- SEED: Super admin awal
-- Ganti email sesuai kebutuhanmu!
-- ============================================================
INSERT OR IGNORE INTO users (id, email, name, role)
VALUES (
  'super-admin-seed-id-001',
  'superadmin@yourdomain.com',
  'Super Admin',
  'super_admin'
);
