import 'package:bookmyevent/app/views/chat_inbox_screen.dart';
import 'package:bookmyevent/views/customer/my_bookings_screen.dart';
import 'package:bookmyevent/views/customer/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/views/stripe_payment_screen.dart';
import '../../controllers/dashboard/customer_dashboard_controller.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';



class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});



  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerDashboardController());



    final List<Widget> pages =  [
      HomeScreen(),
      MyBookingsScreen(),
      ProfileScreen(),
      ChatInboxScreen(),
      /*StripePaymentScreen(),*/
    ];

    return Obx(() => Scaffold(
      body: pages[controller.selectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          backgroundColor: const Color(0xFF3F51B5),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: "Bookings"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: "Chat"),
            /*BottomNavigationBarItem(icon: Icon(Icons.person), label: "Payment"),*/
          ],
        ),

    ));
  }
}
