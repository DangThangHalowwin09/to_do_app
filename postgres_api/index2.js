const express = require("express");
const fs = require("fs");
const path = require("path");
const xml2js = require("xml2js");

const app = express();
const PORT = 3000;

// ⚠️ Đổi đường dẫn này cho đúng folder chứa file XML
const folderPath = "/Volumes/xml_database";

app.get("/latest-xml", async (req, res) => {
  try {
    const files = fs.readdirSync(folderPath).filter(f => f.endsWith(".xml"));
    if (files.length === 0) {
      return res.status(404).json({ error: "Không có file XML nào" });
    }

    // Chọn file mới nhất
    const latestFile = files
      .map(f => {
        const fullPath = path.join(folderPath, f);
        return { name: f, time: fs.statSync(fullPath).mtime.getTime(), fullPath };
      })
      .sort((a, b) => b.time - a.time)[0];

    // Đọc và parse file XML
    const xmlData = fs.readFileSync(latestFile.fullPath, "utf8");
    const parser = new xml2js.Parser({ explicitArray: false, trim: true });
    const result = await parser.parseStringPromise(xmlData);

    // Truy cập phần TONG_HOP trong cấu trúc XML

const danhSachHoSo = result?.GIAMDINHHS?.THONGTINHOSO?.DANHSACHHOSO;
    if (!danhSachHoSo) {
      return res.status(404).json({ error: "Không tìm thấy DANHSACHHOSO" });
    }

    const hoSo = danhSachHoSo?.HOSO;
    if (!hoSo) {
      return res.status(404).json({ error: "Không tìm thấy HOSO" });
    }

    let tongHop;
    if (Array.isArray(hoSo?.FILEHOSO)) {
      const fileHoSo = hoSo.FILEHOSO.find(f => f?.LOAIHOSO === "XML1" && f?.NOIDUNGFILE?.TONG_HOP);
      tongHop = fileHoSo?.NOIDUNGFILE?.TONG_HOP;
    } else {
      tongHop = hoSo?.FILEHOSO?.NOIDUNGFILE?.TONG_HOP;
    }

    if (!tongHop) {
      return res.status(404).json({ error: "Không tìm thấy TONG_HOP trong file XML" });
    }
    // Lấy thông tin họ tên, giới tính và địa chỉ
    const patientData = {
      HoTenBN: tongHop?.HO_TEN || "N/A",
      GioiTinh: tongHop?.GIOI_TINH === "2" ? "Nữ" : tongHop?.GIOI_TINH === "1" ? "Nam" : "N/A",
      DiaChi: tongHop?.DIA_CHI || "N/A",
    };

    res.json({

      filename: latestFile.name,
      patient: patientData,
    });
  } catch (err) {
    console.error("❌ Lỗi parse XML:", err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`✅ Server chạy tại http://localhost:${PORT}`);
});