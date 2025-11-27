import 'package:bookmyevent/views/customer/venues/venue_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard/home/customer_home_controller.dart';
import '../../routes/app_routes.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerHomeController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔵 Header with Search
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF3F51B5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome to BookMyEvent 🎉",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: controller.updateSearch,
                      decoration: InputDecoration(
                        hintText: "Search venues or services...",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🌟 Featured Venues
              _sectionTitle("Featured Venues"),
              SizedBox(
                height: 220,
                child: Obx(() {
                  if (controller.filteredFeaturedVenues.isEmpty) {
                    return const Center(child: Text("No venues available"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.filteredFeaturedVenues.length,
                    itemBuilder: (context, index) {
                      final venue = controller.filteredFeaturedVenues[index];
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            Routes.venueDetails,
                            arguments: {"venue": venue},
                          );
                        }
                        ,
                        child: Container(
                          width: 220,
                          margin: const EdgeInsets.only(right: 12, bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Image(
                                  image: (venue["image"] != null &&
                                      venue["image"].toString().startsWith("http"))
                                      ? NetworkImage(venue["image"])
                                      : AssetImage(
                                      "assets/images/service_image_placeholder.png")
                                  as ImageProvider,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      venue["category"] ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      venue["businessName"] ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),

              // 📌 Categories
              _sectionTitle("Categories"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: const [
                    _CategoryCard(icon: Icons.favorite, label: "Wedding"),
                    _CategoryCard(icon: Icons.cake, label: "Birthday"),
                    _CategoryCard(icon: Icons.business, label: "Corporate"),
                    _CategoryCard(icon: Icons.music_note, label: "Concert"),
                    _CategoryCard(icon: Icons.festival, label: "Festival"),
                    _CategoryCard(icon: Icons.more_horiz, label: "More"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ⭐ Recommended
              _sectionTitle("Recommended for You"),
              Obx(() {
                if (controller.filteredRecommendedVenues.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No recommendations available"),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredRecommendedVenues.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final venue = controller.filteredRecommendedVenues[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image(
                            image: (venue["image"] != null &&
                                venue["image"].toString().startsWith("http"))
                                ? NetworkImage(venue["image"])
                                : AssetImage(
                                "assets/images/service_image_placeholder.png")
                            as ImageProvider,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(venue["category"] ?? ""),
                        subtitle: Text(venue["address"] ?? ""),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Get.toNamed(
                              Routes.venueDetails,
                              arguments: {"venue": venue},
                            );
                          }
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF3F51B5)),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF212121))),
            ],
          ),
        ),
      ),
    );
  }
}
