// index.js
const { Pool } = require("pg");

// Thông tin kết nối PostgreSQL từ hình bạn gửi
const pool = new Pool({
  user: "it_ubna_test",      // username
  host: "192.168.1.99",      // địa chỉ server trong LAN
  database: "postgres",      // database name (trong hình là postgres)
  password: "cnttbvub",      // mật khẩu
  port: 5997,                // cổng PostgreSQL (không mặc định)
});

// Hàm test kết nối
async function testConnection() {
  try {
    const res = await pool.query("SELECT NOW()");
    console.log("✅ Connected to PostgreSQL");
    console.log("Current time on DB:", res.rows[0]);
  } catch (err) {
    console.error("❌ Connection error:", err.message);
  } finally {
    pool.end();
  }
}

testConnection();
