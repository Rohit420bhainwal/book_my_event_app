import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard/profile/provider_profile_controller.dart';
import '../../utils/profile_common_widget.dart';


class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderProfileController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CommonProfileLayout(
        isLoading: controller.isLoading,
        photoUrl: controller.photoUrl,
        displayName: controller.displayName,
        email: controller.email,
        phone: controller.phone,
        city: controller.city,
        onLogout: controller.logout,
      ),
    );
  }
}
