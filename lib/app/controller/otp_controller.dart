import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class OtpController extends GetxController {
  final ApiService _apiService = ApiService();

  /// OTP input field controller
  final otpController = TextEditingController();

  /// Loading state
  var isLoading = false.obs;

  /// Email and password passed from registration
  late String email;
  late String password;

  /// Initialize controller with required data
  void initData({required String email, required String password}) {
    this.email = email;
    this.password = password;
  }

  /// Verify OTP
  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      Get.snackbar("Error", "Please enter OTP");
      return;
    }

    isLoading.value = true;

    final response = await _apiService.post("auth/verify-otp", {
      "input": email,
      "otp": otp,
      "method": "email",
      "password": password,
    });

    print("response: $response");

    isLoading.value = false;

    if (response["success"] == true) {
      Get.snackbar("Success", "OTP verified successfully");

      // Navigate to login screen
      Get.offAllNamed("/login"); // Replace with your login screen route
    } else {
      Get.snackbar("Error", response["message"] ?? "OTP verification failed");
    }
  }

  /// Optional: Resend OTP
  Future<void> resendOtp() async {
    isLoading.value = true;

    final response = await _apiService.post("/auth/send-otp", {
      "input": email,
      "method": "email",
      "password": password,
    });

    isLoading.value = false;

    if (response["success"] == true) {
      Get.snackbar("Success", "OTP resent to your email");
    } else {
      Get.snackbar("Error", response["message"] ?? "Failed to resend OTP");
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
