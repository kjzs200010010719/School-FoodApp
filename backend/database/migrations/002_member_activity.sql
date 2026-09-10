USE shan_jie_ren_yi;

-- Apply once, after backing up. Nullable fields preserve existing orders.
ALTER TABLE purchase_orders
  ADD COLUMN client_request_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  ADD COLUMN request_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL,
  ADD UNIQUE KEY purchase_orders_request_unique (user_id, client_request_id);

ALTER TABLE purchase_order_items ADD COLUMN food_snapshot JSON NULL;
