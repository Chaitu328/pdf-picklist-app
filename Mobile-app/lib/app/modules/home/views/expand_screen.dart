import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app_utils/color_constants.dart';
import '../controllers/home_controller.dart';
class ExpandScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    var data = Get.arguments;
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
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            )),
        title: Text(
          data[1],
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
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                data[0],
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height / 2.5,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  data[2],
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomCenter,
              child: Obx(() {
                // Listen to the isInterested state in the controller
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.isInterested.value = !controller.isInterested.value;
                    },
                    child: Text(
                      "Interested",
                      style: TextStyle(
                        color: controller.isInterested.value ? AppColor.cPrimaryButtonColor: Colors.grey,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: controller.isInterested.value ?  AppColor.cPrimaryButtonColor : Colors.grey),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
