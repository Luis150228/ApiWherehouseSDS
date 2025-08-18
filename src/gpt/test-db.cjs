const mysql = require('mysql2/promise');

(async () => {
  try {
    const pool = mysql.createPool({
      host: '127.0.0.1',
      port: 3306,
      user: 'lrangel',
      password: 'F3nixFree15',
      database: 'eut_reportesbk',
      waitForConnections: true,
      connectionLimit: 5,
      connectTimeout: 15000,
      // ssl: { rejectUnauthorized: false },
      // allowPublicKeyRetrieval: true,
    });
    const [rows] = await pool.query('SELECT VERSION() AS v, NOW() AS n');
    console.log('OK:', rows[0]);
    await pool.end();
    process.exit(0);
  } catch (e) {
    console.error('TEST ERROR >>>', e);
    process.exit(1);
  }
})();
