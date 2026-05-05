import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_lead_model.dart';
import '../models/dropdown_models.dart';
import '../network/student_lead_repository.dart';

class StudentLeadController extends GetxController {
  final StudentLeadRepository _repository = StudentLeadRepository();
  
  var isLoading = true.obs;
  var isError = false.obs;
  var leads = <StudentLead>[].obs;
  var filteredLeads = <StudentLead>[].obs;
  var totalLeads = 0.obs;
  var currentPage = 1.obs;
  var itemsPerPage = 20.obs;

  // Dropdown Data
  var branches = <BranchModel>[].obs;
  var staff = <StaffModel>[].obs;
  var statuses = <FollowupStatusModel>[].obs;

  // Selected Filters
  var searchTerm = ''.obs;
  var selectedStaffId = Rxn<int>();
  var selectedBranchId = Rxn<int>();
  var selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDropdowns();
    fetchStudentLeads();
  }

  void loadDropdowns() async {
    branches.value = await _repository.fetchBranches();
    staff.value = await _repository.fetchStaff();
    statuses.value = await _repository.fetchFollowupStatuses();
  }

  void onSearchChange() {
    currentPage.value = 1;
    fetchStudentLeads();
  }

  void fetchStudentLeads() async {
    try {
      isLoading(true);
      isError(false);
      
      final response = await _repository.fetchStudentLeads(
        page: currentPage.value,
        searchTerm: searchTerm.value,
        staffId: selectedStaffId.value,
        branchId: selectedBranchId.value,
        status: selectedStatus.value,
      );
      
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
