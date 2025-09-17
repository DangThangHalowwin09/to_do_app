import 'dart:convert';
import 'package:flutter_to_do_list/data_postgreSQL/patient.dart';
import 'package:http/http.dart' as http;

class PatientService {
  final String baseUrl = "http://10.1.6.77:3000";
  Future<List<Patient>> fetchPatients() async {
    final response = await http.get(Uri.parse('$baseUrl/patients'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Patient.fromJson(e)).toList(); // ✅ ép sang List<Patient>
    } else {
      throw Exception("Failed to load patients");
    }
  }


}
