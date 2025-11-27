import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/provider_booking_detail_controller.dart';

class ProviderBookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const ProviderBookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderBookingDetailController());
    controller.fetchBookingDetail(bookingId);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.booking.isEmpty) {
          return const Center(child: Text("Booking not found"));
        }

        final booking = controller.booking;
        final customer = booking['user'] ?? {};
        final service = booking['service'] ?? {};
        final status = booking['status'] ?? 'pending';
        final dateStr = booking['date'];
        final formattedDate = dateStr != null
            ? DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr))
            : '';

        // Choose color for status badge
        Color statusColor;
        switch (status) {
          case 'confirmed':
            statusColor = Colors.green;
            break;
          case 'canceled':
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.orange;
        }

        final List<dynamic> images = service['images'] ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Image Carousel (if multiple images)
              if (images.isNotEmpty)
                _buildImageCarousel(images),
              const SizedBox(height: 20),

              // ✅ Service title + status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service['name'] ?? 'Service',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ✅ Customer Info Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.person, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Customer Details",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                      const Divider(height: 20),
                      _infoRow(Icons.account_circle, "Name",
                          customer['name'] ?? '-'),
                      _infoRow(Icons.email, "Email",
                          customer['email'] ?? '-'),
                      _infoRow(Icons.phone, "Phone",
                          customer['phone'] ?? '-'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Service Info Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.room_service, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text("Service Details",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                      const Divider(height: 20),
                      _infoRow(Icons.calendar_today, "Date", formattedDate),
                      _infoRow(Icons.location_city, "City",
                          service['city'] ?? '-'),
                      _infoRow(Icons.currency_rupee, "Price",
                          service['price']?.toString() ?? '-'),
                      if (service['description'] != null)
                        _infoRow(Icons.description, "Description",
                            service['description']),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ✅ Action Buttons
              if (status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            controller.updateBookingStatus(bookingId, 'confirmed'),
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                        label: const Text(
                          "Accept",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            controller.updateBookingStatus(bookingId, 'canceled'),
                        icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                        label: const Text(
                          "Reject",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

            ],
          ),
        );
      }),
    );
  }

  Widget _buildImageCarousel(List<dynamic> images) {
    final pageController = PageController();
    final currentPage = ValueNotifier<int>(0);

    if (images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: pageController,
            itemCount: images.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // ✅ Page Indicator Dots
        ValueListenableBuilder<int>(
          valueListenable: currentPage,
          builder: (context, value, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = value == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isActive ? 20 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blueAccent : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
