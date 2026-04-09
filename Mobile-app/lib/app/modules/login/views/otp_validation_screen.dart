import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import '../../../../app_utils/color_constants.dart';
import '../../../../app_utils/text_constants.dart';
import '../../../../common_widgets/common_buttons/elevated_button_common.dart';
import '../controllers/login_controller.dart';

class OtpValidationScreenView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.cAppPrimaryColor, // Set the status bar color
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColor.cAppPrimaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: Stack(
        children: [
          Container(
            // decoration: const BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage(
            //         'assets/images/solar_energy.png'), // Set your background image here
            //     fit: BoxFit.cover, // This makes the image fill the screen
            //   ),
            // ),
          ),
          Container(
            color: AppColor.cAppBackgroundColor.withOpacity(0.85),
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center content vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center content horizontally
                children: [
                  Spacer(),
                  Image.asset(
                    "assets/images/app_icon.png",
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  OTPTextField(
                    length: 4,
                    width: 200,
                    fieldWidth: 40,
                    style: TextStyle(fontSize: 17),
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    fieldStyle: FieldStyle.box,
                    onCompleted: (pin) {
                      //controller.otpController.value = pin;
                    },
                  ),
                  SizedBox(height: 10),
                  // Obx(() => Text(
                  //       "Resend OTP in ${controller.timerText.value}",
                  //       style: TextStyle(
                  //           fontSize: 16, color: AppColor.colorAccent),
                  //     )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: ElevatedButtonCommon(
                      buttonColor: AppColor.cPrimaryButtonColor,
                      onTap: () {
                        //controller.verifyOtp(context);
                      },
                      buttonText: TextConstants.submit,
                    ),
                  ),
                  // Show the resend button if the timer has finished
                  // Obx(() => Visibility(
                  //       visible: controller.isResendEnabled.value,
                  //       child: ElevatedButtonCommon(
                  //         buttonColor: AppColor.cPrimaryButtonColor,
                  //         onTap: () {
                  //          // controller.resendOtp(context);
                  //         },
                  //         buttonText: TextConstants.resendOtp,
                  //       ),
                  //     )),
                  Spacer()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
