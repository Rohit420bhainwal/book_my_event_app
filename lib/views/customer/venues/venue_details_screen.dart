import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/venues/venue_details_controller.dart';
import '../../../routes/app_routes.dart';

class VenueDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> venue;
  const VenueDetailsScreen({super.key,required this.venue});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments ?? {}) as Map<String, dynamic>;
   // final Map<String, dynamic> venueData = args["venue"] ?? {};
    final Map<String, dynamic> venueData = venue;
    final controller = Get.put(VenueDetailsController(venue: venueData));
    print("venue: ${venueData}");
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.venue.isEmpty) {
            return const Center(child: Text("Venue not found"));
          }

          final venue = controller.venue;
          print("venue $venue");

          final List images = (venue["images"] ?? []) as List;
          final String location = venue["address"] ?? "Unknown Address";
          final String city = venue["city"] ?? "Unknown City";
          final String description =
              venue["description"] ?? "No description available.";
          final String category = venue["category"] is Map
              ? (venue["category"]["name"] ?? "N/A")
              : (venue["category"] ?? "N/A");
          final String providerName = venue["providerName"] ?? "N/A";
          final String providerEmail = venue["providerEmail"] ?? "N/A";
          final String providerPhone = venue["providerPhone"] ?? "N/A";
          final String businessName = venue["businessName"] ?? "N/A";
          final String price = venue["price"] ?? "0";
          final String createdAt = venue["createdAt"] ?? "";
          final String updatedAt = venue["updatedAt"] ?? "";
          final String rating = venue['rating']?.toString() ?? "0";
          final double ratingValue = double.tryParse(rating) ?? 0.0;


          final formattedCreated = createdAt.isNotEmpty
              ? DateFormat('dd MMM yyyy, hh:mm a')
              .format(DateTime.parse(createdAt))
              : "";
          final formattedUpdated = updatedAt.isNotEmpty
              ? DateFormat('dd MMM yyyy, hh:mm a')
              .format(DateTime.parse(updatedAt))
              : "";

          return Column(
            children: [
              // 📸 Image Carousel
              Stack(
                children: [
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: images.isNotEmpty
                        ? PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) => Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                ],
              ),

              // 📝 Venue Details
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // 🏢 Business Name & Category
                        Row(
                          children: [
                            buildStarRating(ratingValue, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              ratingValue.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                businessName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: Color(0xFF3F51B5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 📍 Location
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.grey, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // 🏙️ City
                        _infoRow(Icons.location_city_outlined, "City", city),
                        const SizedBox(height: 10),

                        // 💰 Price
                        _infoRow(Icons.currency_rupee, "Price", "₹$price"),

                        const Divider(height: 30),

                        // 🧑‍💼 Provider Info
                        const Text(
                          "Provider Details",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _infoRow(Icons.person_outline, "Provider Name",
                            providerName),
                        _infoRowTap(Icons.email_outlined, "Email", providerEmail,
                                () {
                              controller.launchURL("mailto:$providerEmail");
                            }),
                        _infoRowTap(Icons.phone_outlined, "Phone", providerPhone,
                                () {
                              controller.openDialer(providerPhone);
                            }),

                        const Divider(height: 30),

                        // 📝 Description
                        const Text(
                          "About this venue",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: Colors.black87),
                        ),

                        const Divider(height: 30),

                        // 🕒 Meta Info
                        if (formattedCreated.isNotEmpty)
                          _infoRow(Icons.calendar_today_outlined, "Created",
                              formattedCreated),
                        if (formattedUpdated.isNotEmpty)
                          _infoRow(Icons.update, "Updated", formattedUpdated),
                      ],
                    ),
                  ),
                ),
              ),

              // 📞 Chat / Call / Book Button Row
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // 📞 Call Button
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: () {
                          controller.openDialer(providerPhone);
                        },
                        icon: const Icon(Icons.call),
                        tooltip: 'Call Provider',
                      ),
                      const SizedBox(width: 12),

                      // 💬 Chat Button
                      // 💬 Chat Button
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: () {
                          final customerId = controller.currentUserId.value;

                          final providerId = venue["providerId"]?.toString() ?? "";
                          final serviceId = venue["id"]?.toString() ?? "";

                          print("providerId: $providerId");
                          print("serviceId: $serviceId");
                          if (providerId.isEmpty || serviceId.isEmpty) {
                            Get.snackbar("Error", "Chat data missing");
                            return;
                          }

                          Get.toNamed(
                            Routes.chatScreen,
                            arguments: {
                              "providerId": providerId,
                              "customerId": customerId,
                              "serviceId": serviceId,
                              "serviceName": businessName.toString(),
                              "providerName": providerName.toString(),
                              "loggedInUserId":customerId,
                            },
                          );
                        },

                        icon: const Icon(Icons.chat_bubble_outline),
                        tooltip: 'Chat with Provider',
                      ),

                      const SizedBox(width: 12),

                      // 📅 Book Now Button (Expanded)
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_month_outlined),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Get.toNamed(Routes.bookingForm,
                                arguments: {"venue": venue});
                          },
                          label: const Text(
                            "Book Now",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget buildStarRating(double rating,
      {int maxStars = 5, double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        if (index < rating.floor()) {
          // Full star
          return Icon(Icons.star,
              color: Colors.amber, size: size);
        } else if (index < rating && rating - index >= 0.5) {
          // Half star
          return Icon(Icons.star_half,
              color: Colors.amber, size: size);
        } else {
          // Empty star
          return Icon(Icons.star_border,
              color: Colors.grey.shade400, size: size);
        }
      }),
    );
  }


  // 🔹 Reusable info row widget
  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: $value",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Clickable info row for email/phone
  Widget _infoRowTap(
      IconData icon, String title, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$title: $value",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
