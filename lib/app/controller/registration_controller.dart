import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../views/otp_verification_screen.dart';


class RegistrationController extends GetxController {
  final ApiService _apiService = ApiService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;

  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Step 1: Send OTP to email
  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields");
      return;
    }

    isLoading.value = true;

    final response = await _apiService.post("auth/send-otp", {
      "input": email.trim(),
      "method": "email",
      "phone":phone.trim(),
      "password": password.trim(),
      "name":name.trim(),
    });

    print("response $response");

    isLoading.value = false;

    if (response["success"] == true) {
      // Navigate to OTP screen
      Get.to(() => OtpVerificationScreen(email: email, password: password));
    } else {
      Get.snackbar("Error", response["message"] ?? "Failed to send OTP");
    }
  }
}
