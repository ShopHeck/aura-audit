CREATE TABLE IF NOT EXISTS installs (
  id TEXT PRIMARY KEY,
  created_at TEXT NOT NULL,
  last_seen_at TEXT,
  premium_until TEXT,
  lifetime_premium INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS audits (
  id TEXT PRIMARY KEY,
  install_id TEXT NOT NULL,
  mode TEXT NOT NULL,
  aura_score INTEGER,
  main_character_energy INTEGER,
  chaos_index INTEGER,
  npc_risk INTEGER,
  group_chat_survival INTEGER,
  title TEXT,
  verdict TEXT,
  roasts_json TEXT,
  warnings_json TEXT,
  share_caption TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (install_id) REFERENCES installs(id)
);

CREATE TABLE IF NOT EXISTS daily_usage (
  id TEXT PRIMARY KEY,
  install_id TEXT NOT NULL,
  usage_date TEXT NOT NULL,
  audit_count INTEGER DEFAULT 0,
  UNIQUE(install_id, usage_date)
);

CREATE TABLE IF NOT EXISTS entitlement_events (
  id TEXT PRIMARY KEY,
  install_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  transaction_id TEXT,
  event_type TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (install_id) REFERENCES installs(id)
);

CREATE TABLE IF NOT EXISTS safety_reports (
  id TEXT PRIMARY KEY,
  audit_id TEXT,
  reason TEXT,
  message TEXT,
  created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_audits_install_created ON audits(install_id, created_at);
CREATE INDEX IF NOT EXISTS idx_daily_usage_install_date ON daily_usage(install_id, usage_date);
