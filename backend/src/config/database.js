const mysql = require('mysql2/promise');

function createDatabasePool() {
  return mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'shan_jie_ren_yi',
    waitForConnections: true,
    connectionLimit: 10,
  });
}

module.exports = {
  createDatabasePool,
};
