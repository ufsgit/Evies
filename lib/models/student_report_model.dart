import 'student_lead_model.dart';

class StudentReportResponseModel {
  final List<StudentLead> students;
  final int totalRecords;

  StudentReportResponseModel({required this.students, required this.totalRecords});

  factory StudentReportResponseModel.fromJson(List<dynamic> json) {
    List<StudentLead> studentList = [];
    int total = 0;

    if (json.isNotEmpty && json[0] is List && (json[0] as List).isNotEmpty) {
      total = json[0][0]['totalRecords'] ?? 0;
    }

    if (json.length > 1 && json[1] is List) {
      studentList = (json[1] as List)
          .map((i) => StudentLead.fromJson(i))
          .toList();
    }
    return StudentReportResponseModel(students: studentList, totalRecords: total);
  }
}
