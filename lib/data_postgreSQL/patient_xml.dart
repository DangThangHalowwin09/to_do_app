import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class XMLPatientScreen extends StatefulWidget {
  const XMLPatientScreen({super.key});

  @override
  State<XMLPatientScreen> createState() => _XMLPatientScreenState();
}

class _XMLPatientScreenState extends State<XMLPatientScreen> {
  String? fileName;
  String? hoTen;
  String? gioiTinh;
  String? diaChi;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:3000/latest-xml"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          fileName = data["filename"];
          hoTen = data["patient"]["HoTenBN"];
          gioiTinh = data["patient"]["GioiTinh"];
          diaChi = data["patient"]["DiaChi"];
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Lỗi: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Không kết nối được server: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin bệnh nhân"),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : error != null
            ? Text(error!, style: const TextStyle(color: Colors.red))
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fileName != null)
              Text("📄 File: $fileName", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("👤 Họ tên: ${hoTen ?? "N/A"}"),
            Text("⚧ Giới tính: ${gioiTinh ?? "N/A"}"),
            Text("🏠 Địa chỉ: ${diaChi ?? "N/A"}"),
          ],
        ),
      ),
    );
  }
}
