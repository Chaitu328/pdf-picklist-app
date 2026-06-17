import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventory/app_data/api_url.dart';
import '../../../../app_utils/color_constants.dart';
import '../../../routes/app_routes.dart';
import 'package:inventory/app_data/base_api_service.dart';
import '../../../../main.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailError = RxString("");
  final passwordError = RxString("");
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final token = "".obs;

  // get token => null;

  @override
  void onInit() {
    super.onInit();
    // Load the token from storage when the controller starts
    String? storedToken = box.read("user_token");
    if (storedToken != null) {
      token.value = storedToken;
    }
  }

  @override
  void onClose() {
    // Access directly
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }

  

  void validate() {
    emailError.value = "";
    passwordError.value = "";

    if (!GetUtils.isEmail(emailController.value.text)) {
      emailError.value = 'Invalid email address';
    }
    if (passwordController.value.text.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (passwordController.value.text.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  Future<void> verifyEmailPassword(BuildContext context) async {
    isLoading.value = true;
    try {
      String email = emailController.value.text.trim();
      String password = passwordController.value.text.trim();

      validate();

      if (emailError.value.isEmpty && passwordError.value.isEmpty) {
        final apiService = ApiService();
        final response =
            await apiService.postWithoutAuth(ApiConstants.loginEndPoint, {
          "email": email,
          "password": password,
        });

        if (response == null) {
          _showSnackBar(context, 'Network error: Unable to connect to server',
              Colors.red, Colors.white);
        } else if (response.statusCode == 200) {
          final data = response.data;
          if (data != null && data['token'] != null) {
            String newToken = data['token'];
            FocusManager.instance.primaryFocus?.unfocus();
            // Save token, role, and user id for role-based routing
            box.write("user_token", data['token']);
            box.write("user_role", data['user']['role']);
            box.write("user_id", data["user"]["id"]);
            box.write("user_email", data["user"]["email"]);
            box.write("user_token", newToken);
            Get.offAllNamed(AppRoutes.bottomMain);
            print("ROLE: ${data['user']['role']}");
            token.value = newToken;
          } else {
            _showSnackBar(context, 'Invalid response: no token received',
                Colors.red, Colors.white);
          }
        } else {
          _showSnackBar(
            context,
            'Login failed: ${response.statusCode} - ${response.statusMessage ?? 'Unknown error'}',
            Colors.red,
            Colors.white,
          );
        }
      }
    } catch (e) {
      _showSnackBar(context, 'An error occurred: ${e.toString()}', Colors.red,
          Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackBar(BuildContext context, String message,
      Color backgroundColor, Color textColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(message,
            style: TextStyle(
                color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
      ),
    );
  }


}
