import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/otp_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String email;
  final String password;

  OtpVerificationScreen({super.key, required this.email, required this.password});

  @override
  Widget build(BuildContext context) {
    // Initialize controller and pass email/password
    final otpController = Get.put(OtpController());
    otpController.initData(email: email, password: password);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the OTP sent to your email",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController.otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
              onPressed: otpController.isLoading.value ? null : otpController.verifyOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: otpController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify OTP"),
            )),
            const SizedBox(height: 20),
            TextButton(
              onPressed: otpController.isLoading.value ? null : otpController.resendOtp,
              child: const Text("Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
