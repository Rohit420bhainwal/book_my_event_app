import 'package:bookmyevent/views/customer/my_bookings_screen.dart';
import 'package:bookmyevent/views/customer/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard/customer_dashboard_controller.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';



class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  final List<Widget> pages = const [
    HomeScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerDashboardController());

    return Obx(() => Scaffold(
      body: pages[controller.selectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          backgroundColor: const Color(0xFF3F51B5),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: "Bookings"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),

    ));
  }
}
