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
  final String branchName;
  final int? departmentId;
  final String departmentName;
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
    this.branchName = '',
    this.departmentId,
    this.departmentName = '',
    this.enquirySourceId,
  });


  String get fullName => '$firstName $lastName';

  factory StudentLead.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return StudentLead(
      studentId: toInt(json['Student_ID']) ?? 0,
      firstName: json['First_Name'] ?? '',
      lastName: json['Last_Name'] ?? '',
      email: json['Email'] ?? '',
      phoneNumber: json['Phone_Number'] ?? '',
      countryCode: json['Country_Code'] ?? '+91',
      countryCodeName: json['Country_Code_Name'] ?? 'India',
      followUpDate: json['Next_Follow_Up_Date'] ?? json['Follow_Up_Date'],
      statusName: json['Status_Name'] ?? 'Unknown',
      statusId: toInt(json['Status_Id'] ?? json['Status_ID'] ?? json['Follow_Up_Status_ID']),
      assignedStaffName: json['Assigned_Staff_Name'] ?? json['To_User_Name'] ?? '',
      assignedStaffId: toInt(json['Assigned_Staff_ID'] ?? json['To_User_Id']),
      remark: json['Remark'] ?? '',
      address: json['Address'] ?? json['Place'] ?? '',
      age: toInt(json['Age']),
      qualification: json['Qualification'] ?? '',
      branchId: toInt(json['Branch_Id'] ?? json['Branch_ID'] ?? json['BranchID'] ?? json['branch_id']),
      branchName: json['Branch_Name'] ?? json['Branch'] ?? json['branch_name'] ?? '',
      departmentId: toInt(json['Department_Id'] ?? json['Department_ID'] ?? json['DepartmentID'] ?? json['Dept_ID'] ?? json['DeptId'] ?? json['dept_id'] ?? json['Department_Id_'] ?? json['department_id']),
      departmentName: json['Department_Name'] ?? json['Department'] ?? json['Dept_Name'] ?? json['dept_name'] ?? json['DepartmentName'] ?? json['dept'] ?? json['Department_Name_'] ?? json['department_name'] ?? '',
      enquirySourceId: toInt(json['Enquiry_Source_Id'] ?? json['Enquiry_Source_ID'] ?? json['Source_ID']),
    );
  }

}
