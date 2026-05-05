import 'dart:convert';

class StudentLeadResponseModel {
  final List<StudentLead> leads;
  final int totalCount;

  StudentLeadResponseModel({required this.leads, required this.totalCount});

  factory StudentLeadResponseModel.fromJson(List<dynamic> json) {
    List<StudentLead> leadList = [];
    int total = 0;

    if (json.isNotEmpty && json[0] is List && (json[0] as List).isNotEmpty) {
      total = json[0][0]['total_count'] ?? 0;
    }

    if (json.length > 1 && json[1] is List) {
      leadList = (json[1] as List)
          .map((i) => StudentLead.fromJson(i))
          .toList();
    }
    return StudentLeadResponseModel(leads: leadList, totalCount: total);
  }
}

class StudentLead {
  final int studentId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? followUpDate;
  final String statusName;
  final String assignedStaffName;
  final String remark;

  StudentLead({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.followUpDate,
    required this.statusName,
    required this.assignedStaffName,
    required this.remark,
  });

  String get fullName => '$firstName $lastName';

  factory StudentLead.fromJson(Map<String, dynamic> json) {
    return StudentLead(
      studentId: json['Student_ID'] ?? 0,
      firstName: json['First_Name'] ?? '',
      lastName: json['Last_Name'] ?? '',
      email: json['Email'] ?? '',
      phoneNumber: json['Phone_Number'] ?? '',
      followUpDate: json['Next_Follow_Up_Date'] ?? json['Follow_Up_Date'],
      statusName: json['Status_Name'] ?? 'Unknown',
      assignedStaffName: json['Assigned_Staff_Name'] ?? json['To_User_Name'] ?? '',
      remark: json['Remark'] ?? '',
    );
  }
}
