import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard/bookings/my_bookings_controller.dart';
import '../../routes/app_routes.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyBookingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.bookings.isEmpty) {
          return const Center(
            child: Text(
              "No bookings yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchBookings,
          color: const Color(0xFF3F51B5),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.bookings.length,
            itemBuilder: (context, index) {
              final booking = controller.bookings[index];

              Color statusColor;
              switch (booking["status"]) {
                case "confirmed":
                  statusColor = Colors.green;
                  break;
                case "canceled":
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.orange;
              }

              final List images = booking["serviceImages"] ?? [];
              final imageUrl = images.isNotEmpty ? images.first : null;

              final user = booking["user"] ?? {};

              return InkWell(
                onTap: () {
                  Get.toNamed(Routes.bookingDetails, arguments: {
                    "bookingId": booking["id"]
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🖼 Service Image or Placeholder
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: imageUrl != null && imageUrl.toString().isNotEmpty
                            ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                            : _buildPlaceholderImage(),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service Name + Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    booking["serviceName"] ?? "Unknown Service",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3F51B5),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    booking["status"].toString().toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: statusColor,
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Category: ${booking["categoryName"] ?? "N/A"}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(Icons.date_range,
                                    size: 18, color: Color(0xFF3F51B5)),
                                const SizedBox(width: 6),
                                Text(
                                  booking["date"] ?? "",
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black87),
                                ),
                              ],
                            ),

                            const Divider(height: 28),

                            // ✅ Provider Info
                            Text(
                              "Provider: ${booking["providerName"]} (${booking["providerEmail"]})",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),

                            const SizedBox(height: 4),

                            // ✅ User Info
                            Text(
                              "Booked By: ${user["name"] ?? "N/A"} (${user["phone"] ?? ""})",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Booking ID: ${booking["id"]}",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  /// 🔹 Placeholder image widget for when no service image is available
  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 160,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
}
