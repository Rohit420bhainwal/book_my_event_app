import 'package:bookmyevent/controllers/dashboard/provider_dashboard_controller.dart';
import 'package:bookmyevent/views/menulist/menu_list_screen.dart';
import 'package:bookmyevent/views/provider/provider_add_venue_screen.dart';
import 'package:bookmyevent/views/provider/provider_home_screen.dart';
import 'package:bookmyevent/views/provider/provider_orders.dart';
import 'package:bookmyevent/views/provider/provider_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderDashboardController());

    final args = Get.arguments ?? {};
    final String token = args["token"] ?? "";
    final String roleName = args["roleName"] ?? "User";
    final String userId = args["userId"] ?? "userId";

    print("Provider token: $token");

    final List<Widget> pages = [
      ProviderHomeScreen(token: token, roleName: roleName),
      ProviderOrders(),                     // My Orders tab
      MenuListScreen(token: token, userId:userId,roleName: roleName), // Venue/Menu
      ProviderProfileScreen(),
    ];

    return Obx(() => Scaffold(
      body: pages[controller.selectedIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // important to show colors correctly
        currentIndex: controller.selectedIndex.value,
        onTap: controller.changeTab,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF3F51B5),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: "My Orders"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_business), label: "Venue"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    ));
  }
}
