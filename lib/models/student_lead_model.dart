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
  final String? countryCode;
  final String? countryCodeName;
  final String? followUpDate;
  final String statusName;
  final int? statusId;
  final String assignedStaffName;
  final int? assignedStaffId;
  final String remark;
  final String? address;
  final int? age;
  final String? qualification;
  final int? branchId;
  final int? departmentId;
  final int? enquirySourceId;

  StudentLead({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.countryCode,
    this.countryCodeName,
    this.followUpDate,
    required this.statusName,
    this.statusId,
    required this.assignedStaffName,
    this.assignedStaffId,
    required this.remark,
    this.address,
    this.age,
    this.qualification,
    this.branchId,
    this.departmentId,
    this.enquirySourceId,
  });


  String get fullName => '$firstName $lastName';

  factory StudentLead.fromJson(Map<String, dynamic> json) {
    return StudentLead(
      studentId: json['Student_ID'] ?? 0,
      firstName: json['First_Name'] ?? '',
      lastName: json['Last_Name'] ?? '',
      email: json['Email'] ?? '',
      phoneNumber: json['Phone_Number'] ?? '',
      countryCode: json['Country_Code'] ?? '+91',
      countryCodeName: json['Country_Code_Name'] ?? 'India',
      followUpDate: json['Next_Follow_Up_Date'] ?? json['Follow_Up_Date'],
      statusName: json['Status_Name'] ?? 'Unknown',
      statusId: json['Status_Id'] ?? json['Status_ID'] ?? json['Follow_Up_Status_ID'],
      assignedStaffName: json['Assigned_Staff_Name'] ?? json['To_User_Name'] ?? '',
      assignedStaffId: json['Assigned_Staff_ID'] ?? json['To_User_Id'],
      remark: json['Remark'] ?? '',
      address: json['Address'] ?? json['Place'] ?? '',
      age: json['Age'],
      qualification: json['Qualification'] ?? '',
      branchId: json['Branch_Id'] ?? json['Branch_ID'],
      departmentId: json['Department_Id'] ?? json['Department_ID'],
      enquirySourceId: json['Enquiry_Source_Id'] ?? json['Enquiry_Source_ID'],
    );
  }

}
