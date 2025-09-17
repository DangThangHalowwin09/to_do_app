const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// PostgreSQL pool
const pool = new Pool({
  user: "it_ubna_test",
  host: "192.168.1.99",
  database: "bvubna",
  password: "cnttbvub",
  port: 5997,
});

// API ví dụ: lấy 100 bệnh nhân đầu
app.get("/patients", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT patientid, patientname FROM public.tb_patient ORDER BY patientid ASC LIMIT 100"
);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
app.get("/", (req, res) => {
  res.send("✅ API Server is running. Try /patients to get data.");
});

app.listen(port, () => {
  console.log(`🚀 API server is running at http://localhost:${port}`);
});
