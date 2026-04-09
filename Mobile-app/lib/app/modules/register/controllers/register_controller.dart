import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/app_data/api_url.dart';
import '../../../routes/app_routes.dart';
import 'package:inventory/app_data/base_api_service.dart';

class RegisterController extends GetxController {
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final confirmPasswordController = TextEditingController().obs;
  final selectedRole = "manager".obs;

  // Reactive variables for error messages
  final emailError = RxString("");
  final passwordError = RxString("");
  final confirmPasswordError = RxString("");

  // Loading state
  final isLoading = false.obs;

  void validate() {
    // Resetting error messages
    emailError.value = "";
    passwordError.value = "";
    confirmPasswordError.value = "";

    // Email validation
    if (!GetUtils.isEmail(emailController.value.text)) {
      emailError.value = 'Invalid email address';
    }

    // Password validation
    final password = passwordController.value.text;
    if (password.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (password.length < 8) {
      passwordError.value = 'Password must be at least 8 characters long';
    }

    // Confirm password validation
    final confirmPassword = confirmPasswordController.value.text;
    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = 'Please re-enter your password';
    } else if (confirmPassword != password) {
      confirmPasswordError.value = 'Passwords do not match';
    }

    // Check if all errors are empty
    if (emailError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmPasswordError.value.isEmpty) {
      register();
    }
  }

  @override
  void onClose() {
    // Clean up the controllers when the controller is disposed
    emailController.value.dispose();
    passwordController.value.dispose();
    confirmPasswordController.value.dispose();
    super.onClose();
  }

  Future<void> register() async {
    isLoading.value = true;
    try {
      final apiService = ApiService();
      final response =
          await apiService.postWithoutAuth(ApiConstants.registrationEndPoint, {
        "email": emailController.value.text,
        "password": passwordController.value.text,
        "role": selectedRole.value
      });
      if (response == null) {
        _showSnackBar(
          Get.context!,
          ' Already existed or Network error: Unable to connect to server',
          Colors.red,
          Colors.white,
        );
      } else if (response.statusCode == 201) {
        print('Registration successful: ${response.data}');
        _showSnackBar(
          Get.context!,
          'Registered successfully',
          Colors.green,
          Colors.white,
        );
        Get.toNamed(AppRoutes.login);
      } else {
        _showSnackBar(
          Get.context!,
          'Registration failed: ${response.statusCode} - ${response.statusMessage ?? 'Unknown error'}',
          Colors.red,
          Colors.white,
        );
      }
    } catch (e) {
      _showSnackBar(
        Get.context!,
        'An error occurred: ${e.toString()}',
        Colors.red,
        Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackBar(BuildContext context, String message,
      Color backgroundColor, Color textColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
