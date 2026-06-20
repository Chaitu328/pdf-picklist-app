import 'package:get/get.dart';
import '../../../../app_data/api_url.dart';
import '../../../../app_data/base_api_service.dart';

class AuditController extends GetxController {
  final _apiService = ApiService();

  final selectedDate = DateTime.now().obs;
  final isLoading = false.obs;
  final errorMessage = RxString("");

  final userEvents = RxMap<String, dynamic>();
  final routeEvents = RxMap<String, dynamic>();
  final managerProgress = RxMap<String, dynamic>();
  final workerProgress = RxMap<String, dynamic>();

  String get dateString => 
      "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";

  @override
  void onInit() {
    super.onInit();
    // Auto-refetch when date changes
    ever(selectedDate, (_) => fetchAllAudits());
    fetchAllAudits();
  }

  Future<void> fetchAllAudits() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final dateParam = dateString;

      final responses = await Future.wait([
        _apiService.getRaw("${ApiConstants.auditUserEvents}?date=$dateParam"),
        _apiService.getRaw("${ApiConstants.auditRouteEvents}?date=$dateParam"),
        _apiService.getRaw("${ApiConstants.auditManagerProgress}?date=$dateParam"),
        _apiService.getRaw("${ApiConstants.auditWorkerProgress}?date=$dateParam"),
      ]);

      final userRes = responses[0];
      final routeRes = responses[1];
      final managerRes = responses[2];
      final workerRes = responses[3];

      if (userRes != null && userRes.statusCode == 200) {
        userEvents.value = userRes.data as Map<String, dynamic>;
      }
      if (routeRes != null && routeRes.statusCode == 200) {
        routeEvents.value = routeRes.data as Map<String, dynamic>;
      }
      if (managerRes != null && managerRes.statusCode == 200) {
        managerProgress.value = managerRes.data as Map<String, dynamic>;
      }
      if (workerRes != null && workerRes.statusCode == 200) {
        workerProgress.value = workerRes.data as Map<String, dynamic>;
      }

    } catch (e) {
      errorMessage.value = "Failed to fetch audits: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void changeDate(DateTime date) {
    selectedDate.value = date;
  }
}
