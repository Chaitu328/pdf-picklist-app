import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app_utils/color_constants.dart';
import '../../../../common_widgets/common_image_card.dart';
import '../../../../common_widgets/common_textfields/text_field_common.dart';
import '../../../../common_widgets/media_picker_bottom_sheet.dart';
import '../controllers/home_controller.dart';
import 'add_bulletin.dart';
import 'qr_scanner_view.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.cAppPrimaryColor, // Set the status bar color
      statusBarIconBrightness:
      Brightness.light, // Light icons for dark backgrounds
      systemNavigationBarColor:
      AppColor.cAppPrimaryColor, // Custom navigation bar color
      systemNavigationBarIconBrightness:
      Brightness.light, // Light icons for navigation bar
    ));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.cPrimaryButtonColor,
        child: Icon(
          Icons.add,
          color: AppColor.whiteColor,
        ),
        onPressed: () {
          Get.to(AddBulletin());
        },
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.bottomNavBarBackground, // Custom AppBar color
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
            color: AppColor.whiteColor,
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Upload Media Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    MediaPickerBottomSheet.show(
                      context,
                      onCameraPicked: (file) {
                        // Handle camera image
                        print('Camera image picked: ${file.path}');
                        homeController.uploadFile(File(file.path));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Uploading: ${file.name}')),
                        );
                      },
                      onGalleryPicked: (file) {
                        // Handle gallery image
                        print('Gallery image picked: ${file.path}');
                        homeController.uploadFile(File(file.path));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Uploading: ${file.name}')),
                        );
                      },
                      onFilePicked: (file) {
                        // Handle file
                        print('File picked: ${file.path}');
                        homeController.uploadFile(File(file.path));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Uploading: ${file.name}')),
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.add_a_photo,
                    color: AppColor.whiteColor,
                  ),
                  label: const Text(
                    'Upload File',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // QR Scanner Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QRScannerView(),
                      ),
                    );
                    if (result != null) {
                      print('QR Code Result: $result');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('QR: $result')),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.qr_code_2,
                    color: AppColor.whiteColor,
                  ),
                  label: const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Upload Progress Indicator
                Obx(
                      () => homeController.isUploading.value
                      ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: homeController.uploadProgress.value,
                          minHeight: 8,
                          backgroundColor: AppColor.lightGreyColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.cPrimaryButtonColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(homeController.uploadProgress.value * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.blackColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),
                // Uploaded Documents List
                Obx(
                      () => homeController.uploadedDocuments.isNotEmpty
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Uploaded Documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.blackColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: homeController.uploadedDocuments.length,
                        itemBuilder: (context, index) {
                          final doc = homeController.uploadedDocuments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColor.lightGreyColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.cAppPrimaryColor
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  homeController
                                      .getFileIcon(doc.fileType),
                                  color:
                                  AppColor.cAppPrimaryColor,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                doc.fileName,
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w500,
                                  color:
                                  AppColor.blackColor,
                                ),
                              ),
                              subtitle: Text(
                                '${doc.fileSize.toStringAsFixed(2)} MB • ${doc.uploadedAt.day}/${doc.uploadedAt.month}/${doc.uploadedAt.year}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColor.secondaryTextColor,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AlertDialog(
                                          title: const Text(
                                            'Delete Document',
                                          ),
                                          content: const Text(
                                            'Are you sure you want to delete this document?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                    context);
                                              },
                                              child: const Text(
                                                'Cancel',
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton
                                                  .styleFrom(
                                                backgroundColor:
                                                Colors.red,
                                              ),
                                              onPressed: () {
                                                homeController
                                                    .deleteDocument(
                                                    index);
                                                Navigator.pop(
                                                    context);
                                                ScaffoldMessenger.of(
                                                    context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Document deleted',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: AppColor
                                                      .whiteColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      // Display extracted text if available
                      if (homeController.uploadedDocuments
                          .where((doc) => doc.extractedText != null && doc.extractedText!.isNotEmpty)
                          .isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              'Extracted Text from PDFs',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColor.blackColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...homeController.uploadedDocuments
                                .asMap()
                                .entries
                                .where((entry) =>
                            entry.value.extractedText != null &&
                                entry.value.extractedText!.isNotEmpty)
                                .map((entry) {
                              final index = entry.key;
                              final doc = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColor.lightGreyColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColor.whiteColor,
                                  ),
                                  child: ExpansionTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColor.cAppPrimaryColor
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.description,
                                            color: AppColor.cAppPrimaryColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doc.fileName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColor.blackColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Text extracted • ${doc.extractedText!.length} characters',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColor.secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppColor.lightGreyColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                SelectableText(
                                                  doc.extractedText!,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    height: 1.6,
                                                    color: AppColor.blackColor,
                                                    fontFamily: 'Courier',
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  children: [
                                                    ElevatedButton.icon(
                                                      onPressed: () {
                                                        // Copy to clipboard
                                                        Clipboard.setData(
                                                          ClipboardData(
                                                            text: doc.extractedText!,
                                                          ),
                                                        );
                                                        ScaffoldMessenger.of(
                                                            context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Text copied to clipboard',
                                                            ),
                                                            duration: Duration(
                                                              seconds: 2,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons.content_copy,
                                                        size: 18,
                                                      ),
                                                      label: const Text('Copy'),
                                                      style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                        AppColor
                                                            .cPrimaryButtonColor,
                                                        foregroundColor:
                                                        AppColor.whiteColor,
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}