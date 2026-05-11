import 'student_lead_model.dart';

class OutstandingFeesSummary {
  final int totalRecords;
  final String outstandingAmount;
  final String totalPaidAmount;
  final String totalAmount;

  OutstandingFeesSummary({
    required this.totalRecords,
    required this.outstandingAmount,
    required this.totalPaidAmount,
    required this.totalAmount,
  });

  factory OutstandingFeesSummary.fromJson(Map<String, dynamic> json) {
    return OutstandingFeesSummary(
      totalRecords: json['totalRecords'] ?? 0,
      outstandingAmount: json['Outstanding_Amount']?.toString() ?? '0.00',
      totalPaidAmount: json['Total_Paid_Amount']?.toString() ?? '0.00',
      totalAmount: json['Total_Amount']?.toString() ?? '0.00',
    );
  }
}

class OutstandingFeesResponseModel {
  final OutstandingFeesSummary summary;
  final List<StudentLead> students;

  OutstandingFeesResponseModel({
    required this.summary,
    required this.students,
  });

  factory OutstandingFeesResponseModel.fromJson(List<dynamic> json) {
    OutstandingFeesSummary summary = OutstandingFeesSummary(
      totalRecords: 0,
      outstandingAmount: '0.00',
      totalPaidAmount: '0.00',
      totalAmount: '0.00',
    );

    List<StudentLead> students = [];

    if (json.isNotEmpty && json[0] is List && (json[0] as List).isNotEmpty) {
      summary = OutstandingFeesSummary.fromJson(json[0][0]);
    }

    if (json.length > 1 && json[1] is List) {
      students = (json[1] as List)
          .map((i) => StudentLead.fromJson(i))
          .toList();
    }

    return OutstandingFeesResponseModel(
      summary: summary,
      students: students,
    );
  }
}
