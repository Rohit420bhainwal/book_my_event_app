import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard/home/provider_home_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/full_image_view_screen.dart';

class ProviderHomeScreen extends StatelessWidget {
  final String token;
  final String roleName;

  const ProviderHomeScreen({
    Key? key,
    required this.token,
    required this.roleName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderHomeController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Services"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.services.isEmpty) {
          return Center(
            child: Text(
              "No services found.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        final allServices = controller.services;
        print("allServices: $allServices");

        return RefreshIndicator(
          onRefresh: controller.fetchProviderServices,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allServices.length,
            itemBuilder: (context, index) {
              final service = allServices[index];
              final serviceType = service['serviceType'] ?? '-';
              final description = service['description'] ?? '-';
              final price = service['price']?.toString() ?? '-';
              final images = (service['images'] as List?) ?? [];

              return Card(
                elevation: 4,
                color: Colors.white,
                shadowColor: Colors.black.withOpacity(0.08),
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            radius: 26,
                            child: Icon(
                              _getCategoryIcon(serviceType),
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              serviceType.toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),

                      // ✅ Images
                      if (images.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                            itemBuilder: (context, imgIndex) {
                              final imgUrl =
                                  "${controller.apiService.imageUrl}${images[imgIndex]}";

                              return GestureDetector(
                                onTap: () {
                                  final imageUrls = images
                                      .map((img) =>
                                  "${controller.apiService.imageUrl}$img")
                                      .toList();
                                  Get.to(() => FullImageViewScreen(
                                    imageUrls: imageUrls,
                                    initialIndex: imgIndex,
                                  ));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imgUrl,
                                    width: 120,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, _, __) => Container(
                                      width: 120,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 12),

                      _buildDetailRow(
                        theme,
                        icon: Icons.currency_rupee,
                        label: "Price",
                        value: price,
                      ),
                      _buildDetailRow(
                        theme,
                        icon: Icons.description_outlined,
                        label: "Description",
                        value: description,
                        isPreview: true,
                      ),

                      const SizedBox(height: 12),

                      // ✅ Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 🔴 Delete button with confirmation dialog
                          OutlinedButton.icon(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Service"),
                                  content: const Text(
                                      "Are you sure you want to delete this service?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                controller.deleteService(service['_id']);
                              }
                            },
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.white),
                            label: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 🟢 Edit Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final result = await Get.toNamed(
                                Routes.editService,
                                arguments: {
                                  "userId": controller.userId,
                                  "serviceId": service["_id"],
                                  "initialType": service["serviceType"],
                                  "initialDescription": service["description"],
                                  "initialPrice": service["price"].toString(),
                                  "initialImages": service["images"],
                                  "initialFilledFields": service["filledFields"],
                                  "initialSelectedServiceId":service["selectedServiceId"],
                                },
                              );

                              if (result == true) {
                                controller.fetchProviderServices();
                              }
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              "Edit",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'catering':
        return Icons.restaurant;
      case 'dj':
        return Icons.music_note;
      case 'decoration':
        return Icons.celebration;
      case 'photography':
        return Icons.camera_alt;
      case 'sound':
      case 'lighting':
        return Icons.volume_up;
      case 'venue':
        return Icons.home_work;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  Widget _buildDetailRow(
      ThemeData theme, {
        required IconData icon,
        required String label,
        required String value,
        bool isPreview = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: isPreview ? 2 : null,
                  overflow:
                  isPreview ? TextOverflow.ellipsis : TextOverflow.visible,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
