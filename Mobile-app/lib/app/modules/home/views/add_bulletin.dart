import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import '../../../../app_utils/color_constants.dart';
import '../../login/controllers/login_controller.dart';
import '../controllers/home_controller.dart';

class AddBulletin extends GetView<HomeController> {
  final TextEditingController _descriptionController =
      TextEditingController(); // Controller for description
  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.colorAccent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColor.colorAccent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        ),
        title: Text(
          "Add",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
            color: AppColor.whiteColor,
          ),
        ),
        backgroundColor: AppColor.bottomNavBarBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),

            // Container for the image (conditionally shows the image or an empty box)
            GestureDetector(
              onTap: () {
                controller
                    .getBottomSheet(); // Open the bottom sheet for image selection
              },
              child: Obx(() {
                if (controller.imageFile.value != null) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(controller.imageFile.value!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                } else {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(Icons.add_a_photo_outlined,
                          color: Colors.grey[600], size: 40),
                    ),
                  );
                }
              }),
            ),
            SizedBox(height: 20),

            // Description TextField
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: AppColor.cPrimaryButtonColor),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColor.cPrimaryButtonColor,
                      width: 2.0), // Highlight color set to green
                ),
              ),
              maxLines: 4,
            ),

            SizedBox(height: 20),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  if (_descriptionController.value.text.isEmpty) {
                    // loginController.showSnackBar(context, "Fill all the fields",
                    //     Colors.red, AppColor.whiteColor);
                  } else {
                    // loginController.showSnackBar(context, "Bulletin added successfully",
                    //     Colors.green, AppColor.whiteColor);
                  }

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
