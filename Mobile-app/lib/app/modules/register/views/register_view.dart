import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app_utils/color_constants.dart';
import '../../../../common_widgets/common_buttons/elevated_button_common.dart';
import '../../../../common_widgets/common_textfields/text_field_common.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.colorAccent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColor.colorAccent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColor.bottomNavBarBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ---- Logo ----
            Image.asset(
              'assets/images/app_icon.png',
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 24),

            // ✅ ---- NAME FIELD ADDED HERE ----
            Obx(() => CommonTextField(
                  textFieldController: controller.nameController.value,
                  labelText: "name",
                  errorText:
                      null, // keeping UI unchanged (no extra validation UI)
                  obscureText: false,
                  keyType: 'text',
                )),
            const SizedBox(height: 16),
            // --------------------------------

            Obx(() => CommonTextField(
                  textFieldController: controller.emailController.value,
                  labelText: "email",
                  errorText: controller.emailError.value.isNotEmpty
                      ? controller.emailError.value
                      : null,
                  obscureText: false,
                  keyType: 'email',
                )),
            const SizedBox(height: 16),

            Obx(() => CommonTextField(
                  textFieldController: controller.passwordController.value,
                  labelText: 'password',
                  errorText: controller.passwordError.value.isNotEmpty
                      ? controller.passwordError.value
                      : null,
                  obscureText: true,
                  keyType: 'text',
                )),
            const SizedBox(height: 16),

            Obx(() => CommonTextField(
                  textFieldController:
                      controller.confirmPasswordController.value,
                  labelText: 'confirmpassword',
                  errorText: controller.confirmPasswordError.value.isNotEmpty
                      ? controller.confirmPasswordError.value
                      : null,
                  obscureText: true,
                  keyType: 'text',
                )),
            const SizedBox(height: 16),

            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedRole.value,
                  style: TextStyle(color: Colors.green.shade700),
                  decoration: InputDecoration(
                    labelText: 'role',
                    labelStyle: TextStyle(color: Colors.green.shade700),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.green.shade700, width: 2),
                    ),
                  ),
                  items: ['worker', 'manager']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              role[0].toUpperCase() + role.substring(1),
                              style: TextStyle(color: Colors.green.shade700),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedRole.value = value;
                    }
                  },
                )),

            const SizedBox(height: 32),

            Obx(() => ElevatedButtonCommon(
                  onTap: controller.isLoading.value
                      ? null
                      : () => controller.validate(),
                  buttonColor: AppColor.bottomNavBarBackground,
                  buttonText: 'Register',
                )),
          ],
        ),
      ),
    );
  }
}
