import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app_data/api_url.dart';
import '../../../../app_data/base_api_service.dart';
import '../../../../main.dart';
import '../../home/models/inward_receipt_model.dart';

class InwardController extends GetxController {
  final _apiService = ApiService();

  final allInwards = <InwardReceiptModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxString("");

  String get userId => box.read("user_id") ?? '';

  List<InwardReceiptModel> get availableInwards =>
      allInwards.where((p) => p.status == 'unassigned').toList();

  List<InwardReceiptModel> get myInwards =>
      allInwards.where((p) => p.workerId != null && p.workerId!['_id'] == userId).toList();

  @override
  void onInit() {
    super.onInit();
    fetchInwards();
  }

  Future<void> fetchInwards() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final response = await _apiService.getRaw(ApiConstants.inward);
      if (response != null && response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        allInwards.value = data
            .map((item) => InwardReceiptModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        errorMessage.value = "Failed to load inward receipts.";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignInward(BuildContext context, String inwardId) async {
    try {
      isLoading.value = true;
      final response =
          await _apiService.patchApi(ApiConstants.assignInward(inwardId));
      if (response != null && response.statusCode == 200) {
        await fetchInwards();
        _showSnack(
            context, 'Inward receipt claimed successfully!', Colors.green.shade700);
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

  Future<bool> updateScan({
    required String inwardId,
    required String partNo,
    required String qrCode,
    required String entryMethod,
    required BuildContext context,
  }) async {
    try {
      final body = {
        "partno": partNo,
        "qr_code": qrCode,
        "entry_method": entryMethod,
      };

      final response = await _apiService.patchWithBody(
        ApiConstants.scanInward(inwardId),
        body,
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        await fetchInwards();
        return true;
      } else {
        String msg = response?.data['message'] ?? "Scan failed";
        _showSnack(context, msg, Colors.red);
        return false;
      }
    } catch (e) {
      _showSnack(context, "Connection error", Colors.red);
      return false;
    }
  }

  Future<void> completeInward(BuildContext context, String inwardId) async {
    try {
      isLoading.value = true;
      final response = await _apiService.postRaw(
        ApiConstants.completeInward(inwardId),
        {},
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        await fetchInwards();
        Get.back();
        _showSnack(context, 'Inward transaction completed successfully!',
            Colors.green.shade700);
      } else {
        _showSnack(
          context,
          'Failed to complete: ${response?.statusCode ?? 'No response'}',
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
