class WorkReportSummary {
  final int staffId;
  final String staffName;
  final int followUpCount;

  WorkReportSummary({
    required this.staffId,
    required this.staffName,
    required this.followUpCount,
  });

  factory WorkReportSummary.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return WorkReportSummary(
      staffId: toInt(json['To_User_Id'] ?? json['Staff_ID']) ?? 0,
      staffName: json['To_User_Name'] ?? json['Staff_Name'] ?? 'Unknown',
      followUpCount: toInt(json['Follow_Up_Count'] ?? json['Count']) ?? 0,
    );
  }
}

class WorkReportDetail {
  final int studentId;
  final String studentName;
  final String email;
  final String phoneNumber;
  final String remark;
  final String followUpDate;
  final String statusName;
  final String entryDate;
  final String departmentName;
  final String assignedTo;
  final String followUpBy;

  WorkReportDetail({
    required this.studentId,
    required this.studentName,
    required this.email,
    required this.phoneNumber,
    required this.remark,
    required this.followUpDate,
    required this.statusName,
    required this.entryDate,
    this.departmentName = '',
    this.assignedTo = '',
    this.followUpBy = '',
  });

  factory WorkReportDetail.fromJson(Map<String, dynamic> json) {
    String parseName() {
      if (json['Student_Name'] != null) return json['Student_Name'];
      if (json['student_name'] != null) return json['student_name'];
      if (json['Name'] != null) return json['Name'];
      if (json['Student'] != null) return json['Student'];
      if (json['First_Name'] != null || json['Last_Name'] != null) {
        return '${json['First_Name'] ?? ''} ${json['Last_Name'] ?? ''}'.trim();
      }
      return '';
    }

    return WorkReportDetail(
      studentId: json['Student_ID'] ?? json['Student_Id'] ?? json['student_id'] ?? json['ID'] ?? json['id'] ?? 0,
      studentName: parseName(),
      email: json['Email'] ?? json['email'] ?? '',
      phoneNumber: json['Phone_Number'] ?? json['Mobile_Number'] ?? json['Mobile'] ?? json['phone_number'] ?? json['mobile'] ?? json['Phone'] ?? '',
      remark: json['Remark'] ?? json['remark'] ?? json['Remarks'] ?? '',
      followUpDate: json['Next_Follow_Up_Date'] ?? json['Follow_Up_Date'] ?? json['Follow_up_Date'] ?? json['follow_up_date'] ?? json['Follow_Up'] ?? json['follow_up'] ?? json['Next_Followup_Date'] ?? '',
      statusName: json['Status_Name'] ?? json['Status'] ?? json['status'] ?? json['Follow_Up_Status'] ?? json['Followup_Status'] ?? json['Active_Status'] ?? json['StatusName'] ?? '',
      entryDate: json['Entry_Date'] ?? json['Created_Date'] ?? json['entry_date'] ?? json['Entry_date'] ?? json['Created_On'] ?? '',
      departmentName: json['Department_Name'] ?? json['Department'] ?? json['department'] ?? json['DepartmentName'] ?? '',
      assignedTo: json['Assigned_To'] ?? json['Assigned_Staff_Name'] ?? json['Assigned_to'] ?? json['AssignedTo'] ?? '',
      followUpBy: json['Follow_Up_By'] ?? json['Follow_up_by'] ?? json['Staff_Name'] ?? json['FollowUpBy'] ?? json['Follow_Up_By_Name'] ?? json['Followup_By'] ?? '',
    );
  }
}
