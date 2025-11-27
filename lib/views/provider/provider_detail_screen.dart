import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard/home/provider_detail_controller.dart';

class ProviderDetailScreen extends StatelessWidget {
  final String listingId;
  const ProviderDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderDetailController(listingId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Listing Details"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = controller.listing;
        final type = data['type'] ?? 'service';
        final images = (data['images'] as List?)?.cast<String>() ?? [];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (images.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const Center(child: CircularProgressIndicator()),
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: type == "venue"
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondary,
                              child: Icon(
                                type == "venue"
                                    ? Icons.location_city
                                    : Icons.business_center,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                type == "venue"
                                    ? (data['venueName'] ?? "Venue")
                                    : (data['providerName'] ?? "Provider"),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (data['approved'] == true)
                          Row(
                            children: const [
                              Icon(Icons.verified, color: Colors.green, size: 20),
                              SizedBox(width: 6),
                              Text(
                                "Approved",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(Icons.hourglass_top, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 6),
                              const Text(
                                "Pending Approval",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        const Divider(height: 32, thickness: 1.2),
                        if (type == "venue") ...[
                          _infoRow(Icons.people, "Capacity", "${data['capacity'] ?? '-'}"),
                          _infoRow(Icons.attach_money, "Price", "₹${data['price'] ?? '-'}"),
                          _infoRow(Icons.location_on, "Address", data['address'] ?? '-'),
                        ] else ...[
                          _infoRow(Icons.location_on, "Base Address", data['baseAddress'] ?? '-'),
                          _infoRow(Icons.map, "Service Radius", "${data['serviceRadius'] ?? '-'} km"),
                          _infoRow(Icons.discount, "Discount", "${data['discountPercent'] ?? '0'}%"),
                          const SizedBox(height: 10),
                          Text(
                            "Services Offered:",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ..._buildServices(data['services'] ?? {}, theme),
                        ],
                        const SizedBox(height: 18),
                        _infoRow(Icons.calendar_today, "Created At",
                            data['createdAt']?.toString().split('T').first ?? '-'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  static Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 22),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _buildServices(Map services, ThemeData theme) {
    List<Widget> widgets = [];
    services.forEach((key, value) {
      if (value['enabled'] == true) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.secondary, size: 18),
                const SizedBox(width: 6),
                Text(
                  "$key: ₹${value['price']}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
    if (widgets.isEmpty) {
      widgets.add(const Padding(
        padding: EdgeInsets.only(left: 8, bottom: 4),
        child: Text("No services selected."),
      ));
    }
    return widgets;
  }
}
