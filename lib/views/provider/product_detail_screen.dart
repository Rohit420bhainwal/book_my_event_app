// views/customer/product_detail_screen.dart
import 'package:bookmyevent/app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard/home/product_detail_controller.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductDetailController>();
    final theme = Theme.of(context);
    final product = controller.product;

    // ✅ Extract category info
    final category = product['category'] ?? {};
    final categoryName = category['name'] ?? "Uncategorized";

    // Extract other fields
    final price = product['price']?.toString() ?? "-";
    final address = product['address'] ?? "-";
    final description = product['description'] ?? "-";
    final peopleCapacity = product['peopleCapacity']?.toString() ?? "-";

    // ✅ Check if this is a venue (you can modify this logic as per your API)
    final isVenue = categoryName.toLowerCase().contains("venue") ||
        categoryName.toLowerCase().contains("hall");

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          product['name'] ?? "Product Details",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            color: Colors.white,
            shadowColor: theme.shadowColor.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.dividerColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product['name'] ?? "Unnamed Product",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Category Chip
                  Chip(
                    label: Text(
                      categoryName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),

                  // Details
                  _buildDetail(theme, Icons.currency_rupee, "Price", price),
                  _buildDetail(
                      theme, Icons.location_on_outlined, "Address", address),

                  // ✅ Show people capacity only if it’s a venue
                  if (isVenue)
                    _buildDetail(theme, Icons.people_alt_outlined,
                        "People Capacity", peopleCapacity),

                  _buildDetail(theme, Icons.description_outlined, "Description",
                      description),

                  // ✅ Show images if present
                  if (product['images'] != null &&
                      (product['images'] as List).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      "Images",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (product['images'] as List).length,
                        itemBuilder: (context, index) {
                          final img = product['images'][index];
                          print("img: $img");
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                controller.apiService.imageUrl +img,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(
      ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  value,
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
