import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../controller/role_controller.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RoleController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 80, color: Color(0xFF3F51B5)),
            const SizedBox(height: 20),
            const Text(
              "Continue as",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            // Customer Button
            Obx(() => ElevatedButton.icon(
              icon: controller.isLoading.value
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.person, color: Colors.white),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: const Color(0xFF3F51B5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isLoading.value ? null : () => controller.saveRole("customer"),
              label: const Text("Customer", style: TextStyle(fontSize: 18, color: Colors.white)),
            )),
            const SizedBox(height: 20),

            // Provider Button
            Obx(() => ElevatedButton.icon(
              icon: controller.isLoading.value
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.store, color: Colors.white),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isLoading.value ? null : () => controller.saveRole("provider"),
              label: const Text("Provider", style: TextStyle(fontSize: 18, color: Colors.white)),
            )),
          ],
        ),
      ),
    );
  }
}
