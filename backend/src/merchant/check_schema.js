module.exports = async function checkMerchantSchema(pool) {
  await pool.query('SELECT token_hash, merchant_id, expires_at FROM merchant_sessions LIMIT 0');
  await pool.query('SELECT merchant_id, request_id, request_hash, food_id FROM merchant_product_requests LIMIT 0');
  await pool.query('SELECT merchant_revision FROM foods LIMIT 0');
};
