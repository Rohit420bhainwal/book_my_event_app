import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/select_customer_city_controller.dart';

class SelectCustomerCityScreen extends StatelessWidget {
  const SelectCustomerCityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SelectCustomerCityController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select City'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter or Select City",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.cityController,
              decoration: InputDecoration(
                hintText: "Type your city name...",
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.filteredCities.isEmpty) {
                  return Center(
                    child: Text(
                      "No cities found",
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = controller.filteredCities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(
                          city,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        onTap: () => controller.selectCity(city),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            // ✅ Bottom Update City Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text("Update City"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: controller.updateCityOnServer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
