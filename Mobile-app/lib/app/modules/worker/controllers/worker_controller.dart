import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app_data/api_url.dart';
import '../../../../app_data/base_api_service.dart';
import '../../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../regester_village/models/get_pick_list_model.dart';

class WorkerController extends GetxController {
  final _apiService = ApiService();

  final allLists = <PickListModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxString("");

  String get userId => box.read("user_id") ?? '';

  List<PickListModel> get availableLists =>
      allLists.where((p) => p.status == 'unassigned').toList();

  List<PickListModel> get myLists =>
      allLists.where((p) => p.workerId?.id == userId).toList();

  @override
  void onInit() {
    super.onInit();
    fetchAllLists();
  }

  Future<void> fetchAllLists() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final response = await _apiService.getRaw(ApiConstants.getPickList);
      if (response != null && response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        allLists.value = data
            .map((item) => PickListModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        errorMessage.value = "Failed to load pick lists.";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignPickList(BuildContext context, String pickListId) async {
    try {
      isLoading.value = true;
      final response = await _apiService.patchApi(ApiConstants.assignPickList(pickListId));
      if (response != null && response.statusCode == 200) {
        await fetchAllLists();
        _showSnack(context, 'Pick list claimed successfully!', Colors.green.shade700);
      } else {
        _showSnack(
          context,
          'Failed to claim: ${response?.statusCode ?? 'No response'}',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnack(context, 'Error: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitPickList(
    BuildContext context,
    String pickListId,
    List<Map<String, dynamic>> parts,
  ) async {
    try {
      isLoading.value = true;
      final response = await _apiService.patchWithBody(
        ApiConstants.scanPickList(pickListId),
        {"parts": parts},
      );
      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        await fetchAllLists();
        Get.back();
        _showSnack(context, 'Pick list submitted successfully!', Colors.green.shade700);
      } else {
        _showSnack(
          context,
          'Failed to submit: ${response?.statusCode ?? 'No response'}',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnack(context, 'Error: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
