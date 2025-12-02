import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard/profile/profile_controller.dart';
import '../../utils/profile_common_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CommonProfileLayout(
        isLoading: controller.isLoading,
        photoUrl: controller.photoUrl,
        displayName: controller.displayName,
        email: controller.email,
        phone: controller.phone,
        city: controller.city,
        role:controller.role,
        available:controller.available,
        onLogout: controller.logout,
      ),
    );
  }
}
