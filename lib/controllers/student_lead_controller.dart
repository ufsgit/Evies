import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_lead_model.dart';
import '../network/student_lead_repository.dart';

class StudentLeadController extends GetxController {
  final StudentLeadRepository _repository = StudentLeadRepository();
  
  var isLoading = true.obs;
  var isError = false.obs;
  var leads = <StudentLead>[].obs;
  var filteredLeads = <StudentLead>[].obs;
  var totalLeads = 0.obs;
  var currentPage = 1.obs;
  var itemsPerPage = 10.obs; // Based on your response showing 10 items

  @override
  void onInit() {
    super.onInit();
    fetchStudentLeads();
  }

  void fetchStudentLeads() async {
    try {
      isLoading(true);
      isError(false);
      
      final response = await _repository.fetchStudentLeads(page: currentPage.value);
      if (response != null) {
        leads.assignAll(response.leads);
        filteredLeads.assignAll(response.leads);
        totalLeads.value = response.totalCount;
      } else {
        isError(true);
      }
    } finally {
      isLoading(false);
    }
  }

  void nextPage() {
    if (currentPage.value * itemsPerPage.value < totalLeads.value) {
      currentPage.value++;
      fetchStudentLeads();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      fetchStudentLeads();
    }
  }

  void goToPage(int page) {
    currentPage.value = page;
    fetchStudentLeads();
  }

  void filterLeads(String query) {
    if (query.isEmpty) {
      filteredLeads.assignAll(leads);
    } else {
      filteredLeads.assignAll(
        leads.where((lead) =>
          lead.firstName.toLowerCase().contains(query.toLowerCase()) ||
          lead.lastName.toLowerCase().contains(query.toLowerCase()) ||
          lead.phoneNumber.contains(query)
        ).toList()
      );
    }
  }
}
