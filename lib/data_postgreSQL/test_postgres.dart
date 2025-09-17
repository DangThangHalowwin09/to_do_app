import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/data_postgreSQL/patient.dart';
import 'patient_service.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final PatientService _service = PatientService();
  late Future<List<Patient>> _patients;

  @override
  void initState() {
    super.initState();
    _patients = _service.fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách bệnh nhân")),
      body: FutureBuilder<List<Patient>>(
        future: _patients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có dữ liệu"));
          }

          final patients = snapshot.data!;
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final p = patients[index];
              return ListTile(
                title: Text(p.patientName),
                subtitle: Text("ID: ${p.patientId}"),
              );
            },
          );
        },
      ),
    );
  }
}
