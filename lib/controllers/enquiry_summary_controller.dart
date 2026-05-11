import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/enquiry_summary_model.dart';
import '../network/student_lead_repository.dart';

class EnquirySummaryController extends GetxController {
  final StudentLeadRepository _repository = StudentLeadRepository();

  var isLoading = true.obs;
  var isError = false.obs;
  var summaryData = Rxn<EnquirySummaryResponse>();

  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();

  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    isLoading.value = true;
    isError.value = false;

    String? fromStr;
    String? toStr;

    if (fromDate.value != null && toDate.value != null) {
      fromStr = _apiFormat.format(fromDate.value!);
      toStr = _apiFormat.format(toDate.value!);
    }

    final data = await _repository.getEnquirySummary(
      fromDate: fromStr,
      toDate: toStr,
    );

    if (data != null) {
      summaryData.value = data;
    } else {
      isError.value = true;
    }

    isLoading.value = false;
  }

  void setFromDate(DateTime date) {
    fromDate.value = date;
  }

  void setToDate(DateTime date) {
    toDate.value = date;
  }

  int getCount(int sourceId, int statusId) {
    if (summaryData.value == null) return 0;
    
    try {
      return summaryData.value!.data.firstWhere(
        (d) => d.sourceId == sourceId && d.statusId == statusId,
        orElse: () => EnquirySummaryData(sourceId: sourceId, statusId: statusId, count: 0),
      ).count;
    } catch (e) {
      return 0;
    }
  }

  int getRowTotal(int sourceId) {
    if (summaryData.value == null) return 0;
    int total = 0;
    for (var status in summaryData.value!.statuses) {
      total += getCount(sourceId, status.id);
    }
    return total;
  }

  int getColumnTotal(int statusId) {
    if (summaryData.value == null) return 0;
    int total = 0;
    for (var source in summaryData.value!.sources) {
      total += getCount(source.id, statusId);
    }
    return total;
  }

  int getGrandTotal() {
    if (summaryData.value == null) return 0;
    int total = 0;
    for (var d in summaryData.value!.data) {
      total += d.count;
    }
    return total;
  }
}
