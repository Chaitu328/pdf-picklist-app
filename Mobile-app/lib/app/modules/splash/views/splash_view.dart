import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app_utils/color_constants.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  final splashController = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              width: screenWidth,
              color: AppColor.cAppBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: AnimatedOpacity(
                      opacity: 1.0, // Fully opaque after animation
                      duration: Duration(seconds: 1), // 1 second fade-in animation
                      child: Image.asset(
                        'assets/images/app_icon.png', // Your logo image here
                        width: 200,  // Adjust the width of the logo
                        height: 200, // Adjust the height of the logo
                        fit: BoxFit.cover, // Ensures the image fits properly
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
