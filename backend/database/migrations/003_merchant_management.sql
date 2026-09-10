USE shan_jie_ren_yi;

ALTER TABLE foods ADD COLUMN merchant_revision INT UNSIGNED NOT NULL DEFAULT 0;

CREATE TABLE merchant_sessions (
  token_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  merchant_id BIGINT UNSIGNED NOT NULL,
  expires_at DATETIME NOT NULL,
  PRIMARY KEY (token_hash),
  KEY merchant_sessions_expiry (merchant_id, expires_at),
  CONSTRAINT merchant_sessions_merchant_fk FOREIGN KEY (merchant_id) REFERENCES merchants(id) ON DELETE CASCADE
);

CREATE TABLE merchant_product_requests (
  merchant_id BIGINT UNSIGNED NOT NULL,
  request_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  request_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  food_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (merchant_id, request_id),
  CONSTRAINT merchant_requests_merchant_fk FOREIGN KEY (merchant_id) REFERENCES merchants(id) ON DELETE CASCADE,
  CONSTRAINT merchant_requests_food_fk FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
);
