const express = require("express");
const fs = require("fs");
const path = require("path");
const xml2js = require("xml2js");

const app = express();
const PORT = 3000;

// Đường dẫn SMB (trên Windows)
// Nếu NodeJS chạy trên Mac/Linux thì đổi thành đường dẫn mount
const folderPath = '\\\\10.1.5.174\\xml_database';

// API: lấy file XML mới nhất
app.get("/latest-xml", async (req, res) => {
  try {
    const files = fs.readdirSync(folderPath).filter(f => f.endsWith(".xml"));

    if (files.length === 0) {
      return res.status(404).json({ error: "Không có file XML nào" });
    }

    // Lấy file mới nhất theo thời gian sửa đổi
    const latestFile = files.map(f => {
      const fullPath = path.join(folderPath, f);
      return {
        name: f,
        time: fs.statSync(fullPath).mtime.getTime(),
        fullPath
      };
    }).sort((a, b) => b.time - a.time)[0];

    // Đọc và parse XML thành JSON
    const xmlData = fs.readFileSync(latestFile.fullPath, "utf8");
    const parser = new xml2js.Parser();
    const result = await parser.parseStringPromise(xmlData);

    res.json({
      filename: latestFile.name,
      data: result
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server chạy tại http://localhost:${PORT}`);
});
