import 'package:bookmyevent/views/provider/provider_booking_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/provider_order_controller.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/date_utils.dart';

class ProviderOrders extends StatelessWidget {
  const ProviderOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderOrderController());

    // Fetch bookings when the screen is built
    controller.fetchProviderBookings();

    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders",style: AppTextStyles.heading,),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.bookings.isEmpty) {
          return const Center(child: Text("No bookings found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.bookings.length,
          itemBuilder: (context, index) {
            final booking = controller.bookings[index];
            final service = booking["service"] ?? {};
            final images = service["images"] ?? [];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: images[0],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image),
                      )
                    : const Icon(Icons.image, size: 60),
                title: Text(service["name"] ?? "Service"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Status: ${booking["status"] ?? "pending"}"),
                    Text("Date: ${AppDateUtils.formatToDDMMYY(booking["date"])}",),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.to(() => ProviderBookingDetailScreen(bookingId: booking["_id"]));

                  // Optionally navigate to a booking details page
                  // Get.to(() => BookingDetailScreen(bookingId: booking["_id"]));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
