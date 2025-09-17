class Patient {
  final int patientId;
  final String patientName;

  Patient({required this.patientId, required this.patientName});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patientid'],
      patientName: json['patientname'] ?? "Không rõ tên",
    );
  }
}
