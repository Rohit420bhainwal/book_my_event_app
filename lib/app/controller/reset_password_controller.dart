import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';


class ResetPasswordController extends GetxController {
  var step = 1.obs;

  // Text controllers
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  // Password hiding
  var hideNewPassword = true.obs;
  var hideConfirmPassword = true.obs;

  final ApiService api = ApiService();

  /// ------------------------------------------------
  /// UI Titles
  /// ------------------------------------------------
  String titleText() {
    if (step.value == 1) return "Forgot Password?";
    if (step.value == 2) return "Verify OTP";
    return "Create New Password";
  }

  String buttonText() {
    if (step.value == 1) return "Send OTP";
    if (step.value == 2) return "Verify OTP";
    return "Reset Password";
  }

  /// ------------------------------------------------
  /// SEND OTP API
  /// ------------------------------------------------
  Future<void> sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter your email");
      return;
    }

    Get.snackbar("Please wait", "Sending OTP...");

    final response = await api.post(
      "auth/reset-password/send-otp",
      {"email": email},
      withAuth: false,
    );

    if (response["success"] == true) {
      Get.snackbar("OTP Sent", "Check your email for the OTP");
      step.value = 2;
    } else {
      Get.snackbar("Error", response["message"] ?? "Failed to send OTP");
    }
  }

  /// ------------------------------------------------
  /// VERIFY OTP API
  /// ------------------------------------------------
  Future<void> verifyOtp() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      Get.snackbar("Error", "Please enter OTP");
      return;
    }

    Get.snackbar("Please wait", "Verifying OTP...");

    final response = await api.post(
      "auth/reset-password/verify-otp",
      {
        "email": email,
        "otp": otp,
      },
      withAuth: false,
    );

    if (response["success"] == true) {
      Get.snackbar("Verified", "OTP verified successfully");
      step.value = 3;
    } else {
      Get.snackbar("Invalid OTP", response["message"] ?? "OTP verification failed");
    }
  }

  /// ------------------------------------------------
  /// SET NEW PASSWORD API
  /// ------------------------------------------------
  Future<void> setNewPassword() async {
    final email = emailController.text.trim();
    final pass = newPassword.text.trim();
    final confirm = confirmPassword.text.trim();

    if (pass.isEmpty || confirm.isEmpty) {
      Get.snackbar("Error", "Please enter both passwords");
      return;
    }

    if (pass != confirm) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    Get.snackbar("Please wait", "Updating password...");

    final response = await api.post(
      "auth/reset-password/set-new-password",
      {
        "email": email,
        "newPassword": pass,
      },
      withAuth: false,
    );

    if (response["success"] == true) {
      Get.snackbar("Success", "Password reset successfully");
      Future.delayed(const Duration(seconds: 1), () => Get.back());
      Get.offAllNamed("/login");
    } else {
      Get.snackbar("Error", response["message"] ?? "Failed to reset password");
    }
  }

  /// ------------------------------------------------
  /// NEXT BUTTON HANDLER
  /// ------------------------------------------------
  void nextStep() {
    if (step.value == 1) {
      sendOtp();
    } else if (step.value == 2) {
      verifyOtp();
    } else {
      setNewPassword();
    }
  }

  /// ------------------------------------------------
  /// RESEND OTP
  /// ------------------------------------------------
  void resendOtp() {
    sendOtp();
  }
}
