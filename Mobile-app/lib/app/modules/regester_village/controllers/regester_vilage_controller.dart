import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../app_data/api_url.dart';
import '../../../../app_data/base_api_service.dart';
import '../../login/controllers/login_controller.dart';
import '../models/get_pick_list_model.dart';

class RegisterVillageController extends GetxController {
  final _apiService = ApiService();
  final loginController = Get.put(LoginController());

  final villageName = TextEditingController().obs;
  final aboutController = TextEditingController().obs;
  final localityController = TextEditingController().obs;
  final stateController = TextEditingController().obs;
  final villagePin = TextEditingController().obs;
  final villageLocalityController = TextEditingController().obs;

  // Error text variables
  final villageNameError = RxString("");
  final aboutError = RxString("");
  final villagePinError = RxString("");
  final villageLocalityError = RxString("");
  final stateError = RxString("");
  final villageState = RxString("");

  // Pick lists
  final pickLists = <PickListModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxString("");

  // ── Tracks permanently deleted IDs so refresh never brings them back ──
  final _deletedIds = <String>{};

  @override
  void onInit() {
    super.onInit();
    fetchPickLists();
  }

  // ════════════════════════════════════════════════════════
  // FETCH PICK LISTS
  // ════════════════════════════════════════════════════════
  Future<void> fetchPickLists() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await _apiService.getRaw(ApiConstants.getPickList);

      if (response != null && response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final all = data
            .map((item) => PickListModel.fromJson(item as Map<String, dynamic>))
            .toList();
        print("API CALLED");
        print(response.data);

        // ── Filter out permanently deleted IDs ──
        // Even after pull-to-refresh, deleted items never come back
        pickLists.value =
            all.where((item) => !_deletedIds.contains(item.id)).toList();
      } else {
        errorMessage.value = "Failed to load pick lists.";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════════
  // DELETE PICK LIST
  // Calls PickListModel.delete() → DELETE /api/picklist/{id}/delete
  // On success: adds to _deletedIds + removes from UI instantly
  // On refresh: _deletedIds filter blocks it from ever coming back
  // ════════════════════════════════════════════════════════
// 2. Perform the server-side deletion
Future<void> deletePickList(int index) async {
  try {
    // 1. Get the item from the list using the index
    final item = pickLists[index];
    final String pNo = item.pickListNo; // The "code" the API wants
    final String internalId = item.id;   // The "_id" we use for UI logic

    final token = loginController.token.value;

    if (token.isEmpty) {
      Get.snackbar("Error", "No token found");
      return;
    }

    // 2. Call API using pick_list_no
    final success = await PickListModel.delete(pNo, token);

    if (success) {
      // 3. Remove from UI list using the internal ID
      pickLists.removeWhere((element) => element.id == internalId);
      Get.snackbar("Success", "Pick List $pNo deleted");
    } else {
      Get.snackbar("Error", "Failed to delete $pNo. Check if it exists.");
    }
  } catch (e) {
    print("Error: $e");
  }
}
  
  // ════════════════════════════════════════════════════════
  // VALIDATE & REGISTER
  // ════════════════════════════════════════════════════════

  bool validate() {
    bool isValid = true;

    villageNameError.value = '';
    villageLocalityError.value = '';
    villagePinError.value = '';
    stateError.value = '';
    aboutError.value = '';

    if (villageName.value.text.isEmpty) {
      villageNameError.value = 'Village name cannot be empty';
      isValid = false;
    }
    if (stateController.value.text.isEmpty) {
      stateError.value = 'State cannot be empty';
      isValid = false;
    }
    if (aboutController.value.text.isEmpty) {
      aboutError.value = 'About cannot be empty';
      isValid = false;
    }
    if (villageLocalityController.value.text.isEmpty) {
      villageLocalityError.value = 'Locality cannot be empty';
      isValid = false;
    }
    if (villagePin.value.text.isEmpty) {
      villagePinError.value = 'Pin cannot be empty';
      isValid = false;
    }

    if (isValid) registerVillage();
    return isValid;
  }

  void registerVillage() {
    villageName.value.text = "";
    villagePin.value.text = "";
    villageLocalityController.value.text = "";
    aboutController.value.text = "";
    stateController.value.text = "";
  }

  // ════════════════════════════════════════════════════════
  // DISPOSE
  // ════════════════════════════════════════════════════════
  @override
  void onClose() {
    villageName.value.dispose();
    aboutController.value.dispose();
    localityController.value.dispose();
    stateController.value.dispose();
    villagePin.value.dispose();
    villageLocalityController.value.dispose();
    super.onClose();
  }
}
