USE shan_jie_ren_yi;

CREATE TABLE IF NOT EXISTS user_sessions (
  token_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (token_hash),
  KEY user_sessions_expiry (expires_at),
  CONSTRAINT user_sessions_user_fk FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
);
