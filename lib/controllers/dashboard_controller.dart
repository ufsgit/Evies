import 'package:get/get.dart';
import '../models/dashboard_model.dart';
import '../network/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();

  var isLoading = true.obs;
  var isError = false.obs;
  var dashboardData = Rxn<DashboardResponseModel>();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    isError.value = false;
    
    final data = await _repository.getDashboardData();
    
    if (data != null) {
      dashboardData.value = data;
    } else {
      isError.value = true;
    }
    
    isLoading.value = false;
  }
}
