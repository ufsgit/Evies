import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/enquiry_conversion_model.dart';
import '../network/enquiry_conversion_repository.dart';

class EnquiryConversionController extends GetxController {
  final EnquiryConversionRepository _repository = EnquiryConversionRepository();

  // Summary State
  var isLoadingSummary = false.obs;
  var isErrorSummary = false.obs;
  var summaryList = <EnquiryConversionSummary>[].obs;

  // View Toggle (true = Table, false = Graph)
  var isTableView = true.obs;

  // Date Filters
  var useCreatedOn = true.obs; // The checkbox
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();

  // Totals
  var grandTotalLead = 0.obs;
  var grandTotalConversion = 0.obs;
  var grandTotalPercentage = 0.0.obs;

  // Details State
  var isLoadingDetails = false.obs;
  var isErrorDetails = false.obs;
  var currentDetailsList = <EnquiryConversionDetail>[].obs;
  var currentSourceTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Default to today
    fromDate.value = DateTime.now();
    toDate.value = DateTime.now();
    fetchSummary();
  }

  void setFromDate(DateTime date) {
    fromDate.value = date;
  }

  void setToDate(DateTime date) {
    toDate.value = date;
  }

  void toggleViewMode(bool isTable) {
    isTableView.value = isTable;
  }

  Future<void> fetchSummary() async {
    isLoadingSummary.value = true;
    isErrorSummary.value = false;

    try {
      String? fromDateStr;
      String? toDateStr;

      if (useCreatedOn.value) {
        if (fromDate.value != null) {
          fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate.value!);
        }
        if (toDate.value != null) {
          toDateStr = DateFormat('yyyy-MM-dd').format(toDate.value!);
        }
      }

      final data = await _repository.fetchSummary(fromDateStr, toDateStr);
      summaryList.value = data;
      _calculateTotals();
    } catch (e) {
      isErrorSummary.value = true;
      print('Error fetching enquiry conversion summary: $e');
    } finally {
      isLoadingSummary.value = false;
    }
  }

  void _calculateTotals() {
    int totalLeads = 0;
    int totalConversions = 0;

    for (var item in summaryList) {
      totalLeads += item.totalLead;
      totalConversions += item.conversionCount;
    }

    grandTotalLead.value = totalLeads;
    grandTotalConversion.value = totalConversions;
    if (totalLeads > 0) {
      grandTotalPercentage.value = (totalConversions / totalLeads) * 100;
    } else {
      grandTotalPercentage.value = 0.0;
    }
  }

  Future<void> fetchDetails(int sourceId, String sourceTitle) async {
    isLoadingDetails.value = true;
    isErrorDetails.value = false;
    currentSourceTitle.value = sourceTitle;
    currentDetailsList.clear();

    try {
      String? fromDateStr;
      String? toDateStr;

      if (useCreatedOn.value) {
        if (fromDate.value != null) {
          fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate.value!);
        }
        if (toDate.value != null) {
          toDateStr = DateFormat('yyyy-MM-dd').format(toDate.value!);
        }
      }

      final data = await _repository.fetchDetails(sourceId, fromDateStr, toDateStr);
      currentDetailsList.value = data;
    } catch (e) {
      isErrorDetails.value = true;
      print('Error fetching enquiry conversion details: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }
}
