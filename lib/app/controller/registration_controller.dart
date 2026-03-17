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

  var fullPhoneNumber = "".obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

 /* Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = fullPhoneNumber.value;

    print("Name: $name");
    print("Email: $email");
    print("Password: $password");
    print("Phone: $phone");

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields");
      return;
    }

    isLoading.value = true;

    try {
      /// 1️⃣ Call Backend API
      final response = await _apiService.post("auth/send-otp", {
        "input": phone,
        "email": email,
        "method": "phone",
        "phone": phone,
        "password": password,
        "name": name
      });

      print("response $response");

      if (response["success"] == true) {

        /// 2️⃣ Create Firebase User
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        /// 3️⃣ Send Email Verification
        await userCredential.user!.sendEmailVerification();

        isLoading.value = false;

        Get.snackbar(
          "Verification Email Sent",
          "Please check your email to verify your account.",
        );

        /// 4️⃣ Navigate to verification screen
        Get.to(() => OtpVerificationScreen(
          email: email,
          password: password,
        ));

      } else {
        isLoading.value = false;
        Get.snackbar("Error", response["message"] ?? "Registration failed");
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar("Firebase Error", e.message ?? "Something went wrong");
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString());
    }
  }*/

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = fullPhoneNumber.value;


    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields");
      return;
    }

    isLoading.value = true;

    final response = await _apiService.post("auth/send-otp", {
      "input": phone,
      "email": email,
      "method": "phone",
      "phone": phone,
      "password": password,
      "name": name
    });

    print("response $response");

    isLoading.value = false;

    if (response["success"] == true) {

      Get.offAllNamed("/login");
     // Get.to(() => OtpVerificationScreen(email: email, password: password));
    } else {
      Get.snackbar("Error", response["message"] ?? "Failed to send OTP");
    }
  }
}