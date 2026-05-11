class EnquiryConversionSummary {
  final int sourceId;
  final String enquirySource;
  final int totalLead;
  final int conversionCount;
  final double conversionPercentage;

  EnquiryConversionSummary({
    required this.sourceId,
    required this.enquirySource,
    required this.totalLead,
    required this.conversionCount,
    required this.conversionPercentage,
  });

  factory EnquiryConversionSummary.fromJson(Map<String, dynamic> json) {
    // Parse percentage safely as double
    double parsedPercentage = 0.0;
    var rawPercentage = json['Conversion_Percentage'] ?? json['ConversionPercentage'] ?? json['conversion_percentage'] ?? json['conversionPercentage'];
    if (rawPercentage != null) {
      if (rawPercentage is num) {
        parsedPercentage = rawPercentage.toDouble();
      } else if (rawPercentage is String) {
        // Strip out the '%' sign if it's there
        parsedPercentage = double.tryParse(rawPercentage.replaceAll('%', '').trim()) ?? 0.0;
      }
    }

    return EnquiryConversionSummary(
      sourceId: json['Enquiry_Source_Id'] ?? json['Source_ID'] ?? json['SourceId'] ?? json['source_id'] ?? json['sourceId'] ?? json['Enquiry_Source_ID'] ?? 0,
      enquirySource: json['Enquiry_Source_Name'] ?? json['Enquiry_Source'] ?? json['EnquirySource'] ?? json['enquiry_source'] ?? json['enquirySource'] ?? json['Source_Name'] ?? 'Unknown',
      totalLead: json['Total_Leads_Count'] ?? json['Total_Lead'] ?? json['TotalLead'] ?? json['total_lead'] ?? json['totalLead'] ?? 0,
      conversionCount: json['Conversion_Count'] ?? json['ConversionCount'] ?? json['conversion_count'] ?? json['conversionCount'] ?? 0,
      conversionPercentage: parsedPercentage,
    );
  }
}

class EnquiryConversionDetail {
  final int studentId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String createdOn;
  final String statusName;
  final String branchName;
  final String remark;

  EnquiryConversionDetail({
    required this.studentId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.createdOn,
    required this.statusName,
    required this.branchName,
    required this.remark,
  });

  factory EnquiryConversionDetail.fromJson(Map<String, dynamic> json) {
    return EnquiryConversionDetail(
      studentId: json['Student_ID'] ?? json['StudentId'] ?? json['student_id'] ?? json['studentId'] ?? json['Id'] ?? 0,
      fullName: json['Full_Name'] ?? json['FullName'] ?? json['full_name'] ?? json['fullName'] ?? json['Student_Name'] ?? json['Name'] ?? 'Unknown',
      phoneNumber: json['Phone_Number'] ?? json['PhoneNumber'] ?? json['phone_number'] ?? json['phoneNumber'] ?? json['Mobile'] ?? json['Mobile_Number'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      createdOn: json['Created_On'] ?? json['CreatedOn'] ?? json['created_on'] ?? json['createdOn'] ?? json['Enquiry_Date'] ?? json['Entry_Date'] ?? '',
      statusName: json['Status_Name'] ?? json['StatusName'] ?? json['status_name'] ?? json['statusName'] ?? json['Status'] ?? 'N/A',
      branchName: json['Branch_Name'] ?? json['BranchName'] ?? json['branch_name'] ?? json['branchName'] ?? json['Branch'] ?? '',
      remark: json['Remark'] ?? json['remark'] ?? json['Remarks'] ?? '',
    );
  }
}
