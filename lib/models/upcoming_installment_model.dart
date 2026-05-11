import 'student_lead_model.dart';

class UpcomingInstallmentSummary {
  final int totalRecords;
  final String totalAmount;
  final String totalPaidAmount;
  final String outstandingAmount;

  UpcomingInstallmentSummary({
    required this.totalRecords,
    required this.totalAmount,
    required this.totalPaidAmount,
    required this.outstandingAmount,
  });

  factory UpcomingInstallmentSummary.fromJson(Map<String, dynamic> json) {
    return UpcomingInstallmentSummary(
      totalRecords: json['totalRecords'] ?? 0,
      totalAmount: json['Total_Amount']?.toString() ?? '0.00',
      totalPaidAmount: json['Total_Paid_Amount']?.toString() ?? '0.00',
      outstandingAmount: json['Outstanding_Amount']?.toString() ?? '0.00',
    );
  }
}

class UpcomingInstallmentResponseModel {
  final UpcomingInstallmentSummary summary;
  final List<StudentLead> installments;

  UpcomingInstallmentResponseModel({
    required this.summary,
    required this.installments,
  });

  factory UpcomingInstallmentResponseModel.fromJson(List<dynamic> json) {
    UpcomingInstallmentSummary summary = UpcomingInstallmentSummary(
      totalRecords: 0,
      totalAmount: '0.00',
      totalPaidAmount: '0.00',
      outstandingAmount: '0.00',
    );

    List<StudentLead> installments = [];

    if (json.isNotEmpty && json[0] is List && (json[0] as List).isNotEmpty) {
      summary = UpcomingInstallmentSummary.fromJson(json[0][0]);
    }

    if (json.length > 1 && json[1] is List) {
      installments = (json[1] as List)
          .map((i) => StudentLead.fromJson(i))
          .toList();
    }

    return UpcomingInstallmentResponseModel(
      summary: summary,
      installments: installments,
    );
  }
}
