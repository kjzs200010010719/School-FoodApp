require('dotenv').config();
const { createDatabasePool } = require('../src/config/database');
const pool = createDatabasePool();

async function main() {
  try {
    const [rows] = await pool.query('SELECT DATABASE() AS db, @@port AS port, CURRENT_USER() AS account');
    console.table(rows);
    await pool.query('SELECT token_hash FROM user_sessions LIMIT 0');
    await require('../src/activity/check_schema')(pool);
    console.log('Database, member sessions and member activity tables are ready.');
  } catch (error) {
    console.error('Database check failed:', error.code);
    console.error('Check .env and apply missing database migrations (001_user_sessions.sql, 002_member_activity.sql) as the database administrator.');
    process.exitCode = 1;
  } finally { await pool.end(); }
}
main();
