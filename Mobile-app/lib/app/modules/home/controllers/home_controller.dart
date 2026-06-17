import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../app_data/api_url.dart';
import '../../../../app_data/base_api_service.dart';
import '../../../../app_utils/color_constants.dart';

class UploadedDocument {
  final String fileName;
  final String filePath;
  final String fileType; // pdf, image, video, etc.
  final DateTime uploadedAt;
  final double fileSize; // in MB
  final String? extractedText; // for PDF text extraction

  UploadedDocument({
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.uploadedAt,
    required this.fileSize,
    this.extractedText,
  });
}

class PickListItem {
  final String id; // 🔥 ADD THIS
  final String partNumber;
  final String orderedBy;
  final String allocatedBy;
  final int requiredQty;

  PickListItem({
    required this.id,
    required this.partNumber,
    required this.orderedBy,
    required this.allocatedBy,
    required this.requiredQty,
  });
}

final RxList<PickListItem> pickList = <PickListItem>[].obs;

class HomeController extends GetxController {
  Rx<File?> imageFile =
      Rx<File?>(null); // Reactive variable to store the picked image
  final searchController = TextEditingController().obs;
  final searchFiledError = RxString("");
  var isInterested = false.obs;
  late MobileScannerController mobileScannerController;
  RxBool isPickListUploadLoading = false.obs;
  // Upload progress tracking
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool isUploading = false.obs;
  final RxList<UploadedDocument> uploadedDocuments = RxList<UploadedDocument>();
  final apiService = ApiService();
  var scanStatus = ''.obs; // Completed / Shortage / Excess
  var scanMessage = ''.obs; // Full message
  var showResultCard = false.obs;
  @override
  void onInit() {
    super.onInit();
    mobileScannerController = MobileScannerController();

    fetchPickList(); // 🔥 load from backend
  }

  @override
  void onClose() {
    mobileScannerController.dispose();
    super.onClose();
  }

  // Future<void> uploadItemToPickList(BuildContext context) async {
  //   isPickListUploadLoading.value = true;
  //   try {
  //
  //
  //     // Validate inputs
  //
  //     // If validation passes, proceed to login
  //     if (emailError.value.isEmpty && passwordError.value.isEmpty) {
  //
  //       final response = await apiService.postWithoutAuth(ApiConstants.loginEndPoint, {
  //         "email": email,
  //         "password": password
  //       });
  //       if (response == null) {
  //         showSnackBar(
  //           context,
  //           'Network error: Unable to connect to server',
  //           Colors.red,
  //           Colors.white,
  //         );
  //       } else if (response.statusCode == 200) {
  //         // Assuming response.data is a map with 'token'
  //         final data = response.data;
  //         if (data != null && data['token'] != null) {
  //           box.write("user_token", data['token']);
  //           Get.offAllNamed(AppRoutes.bottomMain);
  //           showSnackBar(
  //             context,
  //             'Login successful',
  //             Colors.green,
  //             Colors.white,
  //           );
  //         } else {
  //           showSnackBar(
  //             context,
  //             'Invalid response: no token received',
  //             Colors.red,
  //             Colors.white,
  //           );
  //         }
  //       } else {
  //         showSnackBar(
  //           context,
  //           'Login failed: ${response.statusCode} - ${response.statusMessage ?? 'Unknown error'}',
  //           Colors.red,
  //           Colors.white,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     showSnackBar(
  //       context,
  //       'An error occurred: ${e.toString()}',
  //       Colors.red,
  //       Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

Future<void> fetchPickList() async {
  try {
    final response = await apiService.getRaw(
      ApiConstants.getPickList,
    );

    if (response != null && response.statusCode == 200) {
      final List data = response.data;

      pickList.value = data.map((item) => PickListItem(
        id: item['_id'],
        partNumber: item['partNumber'],
        orderedBy: item['orderedBy'],
        allocatedBy: item['allocatedBy'],
        requiredQty: item['requiredQty'],
      )).toList();
    }
  } catch (e) {
    print("Error fetching pick list: $e");
  }
}
  Future<void> handleQRScan(String qrData) async {
    try {
      final data = jsonDecode(qrData);

      String partNumber = data['partNumber'];
      String orderedBy = data['orderedBy'];
      String allocatedBy = data['allocatedBy'];
      int scannedQty = data['scannedQty'];

      final matchedItem = pickList.firstWhereOrNull((item) =>
          item.partNumber == partNumber &&
          item.orderedBy == orderedBy &&
          item.allocatedBy == allocatedBy);

      if (matchedItem == null) {
        scanStatus.value = "❌ Invalid";
        scanMessage.value = "No matching item";
        showResultCard.value = true;
        return;
      }

      // ✅ STEP 1: Get ID
      String id = matchedItem.id;

      // ✅ STEP 2: Call backend API using ID
      final response = await apiService
          .getRaw(ApiConstants.scanPickList(id), // 🔥 correct usage
              );

      print("Scan API response: ${response?.data}");

      // ✅ STEP 3: Compare quantity (your logic)
      String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

      if (scannedQty == matchedItem.requiredQty) {
        scanStatus.value = "Completed";
        Get.snackbar("Success", "Completed ✅",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else if (scannedQty < matchedItem.requiredQty) {
        scanStatus.value = "Shortage";
        Get.snackbar("Warning", "Shortage ⚠️",
            backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        scanStatus.value = "Excess";
        Get.snackbar("Info", "Excess ℹ️",
            backgroundColor: Colors.blue, colorText: Colors.white);
      }

      scanMessage.value =
          "ID: $uniqueId\n$scannedQty / ${matchedItem.requiredQty}";
      showResultCard.value = true;
    } catch (e) {
      scanStatus.value = "❌ Error";
      scanMessage.value = "Invalid QR";
      showResultCard.value = true;
    }
  }

  // Pick image from camera or gallery
  Future<void> onSelectedPhotoPicker(String value) async {
    ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: value == "Camera" ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      imageFile.value =
          File(pickedFile.path); // Update the reactive image variable
    }
  }

  // Simulate file upload with progress
  Future<void> uploadFile(File file) async {
    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      // Get file info
      String fileName = file.path.split('/').last;
      String fileType = fileName.split('.').last.toLowerCase();
      double fileSize = file.lengthSync() / (1024 * 1024); // Convert to MB

      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 300));
        uploadProgress.value = i / 100;
      }

      // Extract text if it's a PDF
      String? extractedText;
      if (fileType.toLowerCase() == 'pdf') {
        extractedText = await extractTextFromPDF(file.path);
      }

      // Add to uploaded documents list
      uploadedDocuments.add(
        UploadedDocument(
          fileName: fileName,
          filePath: file.path,
          fileType: fileType,
          uploadedAt: DateTime.now(),
          fileSize: fileSize,
          extractedText: extractedText,
        ),
      );

      uploadProgress.value = 0.0;
      isUploading.value = false;
    } catch (e) {
      print('Upload error: $e');
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // Extract text from PDF file
  Future<String?> extractTextFromPDF(String filePath) async {
    try {
      final document = await PdfDocument.openFile(filePath);
      StringBuffer extractedText = StringBuffer();

      // Extract text from each page
      for (int i = 1; i <= document.pagesCount; i++) {
        try {
          final page = await document.getPage(i);
          final text = await page.document.sourceName;
          if (text.isNotEmpty) {
            extractedText.writeln(text);
          }
        } catch (e) {
          print('Error extracting text from page $i: $e');
        }
      }

      document.close();

      if (extractedText.isEmpty) {
        return null;
      }

      return extractedText.toString().trim();
    } catch (e) {
      print('PDF extraction error: $e');
      return null;
    }
  }

  // ...existing code...

  // Get file icon based on file type
  IconData getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.videocam;
      default:
        return Icons.file_present;
    }
  }

  // Delete uploaded document
  void deleteDocument(int index) {
    uploadedDocuments.removeAt(index);
  }

  // Display bottom sheet to choose source (Camera or Gallery)
  void getBottomSheet() {
    Get.bottomSheet(
      Container(
        height: 260,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select file from",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: HexColor.fromHex("#231F20"),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await onSelectedPhotoPicker("Camera");
                      Get.back();
                    },
                    child: const Column(
                      children: [
                        SizedBox(height: 20),
                        Icon(
                          Icons.camera_alt,
                          size: 40,
                        ),
                        Text(
                          "Camera",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 50),
                  GestureDetector(
                    onTap: () async {
                      await onSelectedPhotoPicker("Gallery");
                      Get.back();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Icon(
                            Icons.photo,
                            size: 40,
                          ),
                          Text(
                            "Gallery",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
