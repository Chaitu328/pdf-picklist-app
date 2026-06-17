// LoginView.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../../app_utils/color_constants.dart';
import '../../../../common_widgets/common_buttons/elevated_button_common.dart';
import '../../../../common_widgets/common_textfields/text_field_common.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(LoginController());

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.cAppPrimaryColor,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColor.cAppPrimaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    final ValueNotifier<bool> isChecked = ValueNotifier<bool>(false);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColor.cAppBackgroundColor.withOpacity(0.85),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Image.asset(
                    "assets/images/app_icon.png",
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 40),

                  // Email Field
                  Obx(
                    () => TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'email',
                        errorText: controller.emailError.value.isNotEmpty
                            ? controller.emailError.value
                            : null,
                        labelStyle:
                            TextStyle(color: AppColor.cPrimaryButtonColor),
                        prefixIcon: Icon(Icons.email,
                            color: AppColor.cPrimaryButtonColor),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColor.cPrimaryButtonColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  Obx(
                    () => TextField(
                      controller: controller.passwordController,
                      obscureText: !controller.isPasswordVisible.value,
                      decoration: InputDecoration(
                        labelText: 'password',
                        errorText: controller.passwordError.value.isNotEmpty
                            ? controller.passwordError.value
                            : null,
                        labelStyle:
                            TextStyle(color: AppColor.cPrimaryButtonColor),
                        prefixIcon: Icon(Icons.lock,
                            color: AppColor.cPrimaryButtonColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColor.cPrimaryButtonColor,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColor.cPrimaryButtonColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ MOVED TERMS & CONDITIONS HERE
                  ValueListenableBuilder<bool>(
                    valueListenable: isChecked,
                    builder: (context, checked, child) {
                      return Row(
                        children: [
                          Checkbox(
                            value: checked,
                            onChanged: (bool? value) {
                              isChecked.value = value ?? false;
                            },
                            checkColor: AppColor.whiteColor,
                            activeColor: AppColor.cPrimaryButtonColor,
                          ),
                          SizedBox(width: 7),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                ),
                                children: [
                                  TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Login Button
                  Obx(
                    () => ElevatedButtonCommon(
                      onTap: controller.isLoading.value
                          ? null
                          : () {
                              if (!isChecked.value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please accept the terms and conditions'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                if (controller.emailController.value.text
                                        .isNotEmpty &&
                                    controller.passwordController.value.text
                                        .isNotEmpty) {
                                  controller.verifyEmailPassword(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill all fields'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      buttonColor: AppColor.cPrimaryButtonColor,
                      buttonText: "Login",
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.goToRegister();
                        },
                        child: Text(
                          "Register here",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
