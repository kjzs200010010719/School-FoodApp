require('dotenv').config();
const { createDatabasePool } = require('../src/config/database');
const { hashPassword } = require('../src/auth/passwords');
const { credentials, text, fail } = require('../src/merchant/validation');

// Local maintenance only. Read the secret from stdin, never command arguments or a file.
async function main() {
  let input = '';
  for await (const chunk of process.stdin) {
    input += chunk;
    if (input.length > 16384) throw fail(400, 'Input too large');
  }
  const data = JSON.parse(input.replace(/^\uFEFF/, ''));
  const { email, password } = credentials(data);
  const businessName = text(data.businessName, '商家名稱', 120);
  const storeName = text(data.storeName, '門市名稱', 120);
  const address = text(data.address, '地址', 255);
  const hours = text(data.businessHours, '營業時間', 80);
  const phone = text(data.contactPhone, '電話', 40, true);
  if (!Array.isArray(data.businessWeekdays) || !data.businessWeekdays.length ||
      data.businessWeekdays.some((day) => !Number.isInteger(day) || day < 1 || day > 7)) {
    throw fail(400, '營業日須為 1 至 7');
  }
  const passwordHash = await hashPassword(password);
  const pool = createDatabasePool();
  try {
    await require('../src/merchant/check_schema')(pool);
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();
      const [merchant] = await connection.execute(`INSERT INTO merchants
        (business_name, email, password_hash, contact_phone, status) VALUES (?, ?, ?, ?, 'active')`,
      [businessName, email, passwordHash, phone]);
      const [store] = await connection.execute(`INSERT INTO stores
        (merchant_id, name, address, business_hours, contact_phone) VALUES (?, ?, ?, ?, ?)`,
      [merchant.insertId, storeName, address, hours, phone]);
      for (const day of new Set(data.businessWeekdays)) {
        await connection.execute('INSERT INTO store_business_weekdays VALUES (?, ?)', [store.insertId, day]);
      }
      await connection.commit();
      console.log(JSON.stringify({ merchantId: String(merchant.insertId), storeId: String(store.insertId), status: 'active' }));
    } catch (error) { await connection.rollback(); throw error; }
    finally { connection.release(); }
  } finally { await pool.end(); }
}
main().catch((error) => {
  console.error('Merchant provisioning failed:', error.code || (error.statusCode === 400 ? error.message : 'Check input and database settings'));
  process.exitCode = 1;
});
