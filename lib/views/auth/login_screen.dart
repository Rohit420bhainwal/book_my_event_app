// login_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth/login_controller.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Icon(Icons.event, size: 80, color: Colors.deepPurple),
                const SizedBox(height: 16),
                const Text(
                  "BookMyEvent",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                Obx(() => controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: controller.signInWithGoogle,
                )),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: controller.skipLogin,
                  child: const Text("Skip for now"),
                ),

                const Spacer(),
                const Text(
                  "By continuing, you agree to our Terms & Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
