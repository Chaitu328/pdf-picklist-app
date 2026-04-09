import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../app_utils/color_constants.dart';
import '../app_utils/Icon_contants.dart';

class MediaPickerBottomSheet {
  static void show(
    BuildContext context, {
    required Function(XFile file) onCameraPicked,
    required Function(XFile file) onGalleryPicked,
    required Function(XFile file) onFilePicked,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColor.greyColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                const Text(
                  'Choose an option',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.blackColor,
                  ),
                ),
                const SizedBox(height: 24),
                // Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Camera option
                    _buildMediaOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? image = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        if (image != null) {
                          onCameraPicked(image);
                        }
                      },
                    ),
                    // Gallery option
                    _buildMediaOption(
                      icon: Icons.image,
                      label: 'Gallery',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? image = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          onGalleryPicked(image);
                        }
                      },
                    ),
                    // Files option
                    _buildMediaOption(
                      icon: Icons.file_present,
                      label: 'Files',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? file = await ImagePicker()
                            .pickMedia();
                        if (file != null) {
                          onFilePicked(file);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.lightGreyColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.blackColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColor.cAppPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(
              icon,
              size: 32,
              color: AppColor.cAppPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}

