import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/menu_list_controller.dart';

class MenuListScreen extends StatelessWidget {
  final String token;
  final String userId; // ✅ Add userId for API
  final String roleName;

  const MenuListScreen({
    Key? key,
    required this.token,
    required this.userId,
    required this.roleName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MenuListController());
    final theme = Theme.of(context);

    // Fetch service categories
    controller.fetchServiceCategory(token);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Service"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.menuItems.isEmpty) {
          return const Center(child: Text("No service categories found"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selector
              DropdownButtonFormField<int>(
                value: controller.selectedIndex.value,
                decoration: InputDecoration(
                  labelText: "Select Service Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: List.generate(
                  controller.menuItems.length,
                      (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text(controller.menuItems[index].name),
                  ),
                ),
                onChanged: (index) {
                  controller.selectedIndex.value = index!;
                },
              ),
              const SizedBox(height: 20),

              _buildTextField(
                theme,
                controller: controller.descriptionController,
                label: "Description",
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              _buildTextField(
                theme,
                controller: controller.priceController,
                label: "Price",
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),
              Text(
                "Select Images (max 5)",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.selectedImages.length) {
                      return GestureDetector(
                        onTap: controller.pickImages,
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color:
                            theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: theme.colorScheme.primary, width: 2),
                          ),
                          child: const Icon(Icons.add_a_photo,
                              size: 40, color: Colors.black54),
                        ),
                      );
                    } else {
                      final file = controller.selectedImages[index];
                      return Stack(
                        children: [
                          Container(
                            width: 80,
                            margin:
                            const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(file.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: -5,
                            child: GestureDetector(
                              onTap: () => controller.removeImage(index),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              )),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    "Save Service",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () async {
                    final selectedCategory =
                    controller.menuItems[controller.selectedIndex.value];
                    await controller.uploadProviderService(
                      token: token,
                      userId: userId,
                      serviceType: selectedCategory.name,
                      description:
                      controller.descriptionController.text.trim(),
                      price: controller.priceController.text.trim(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField(
      ThemeData theme, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        int maxLines = 1,
        TextInputType? keyboardType,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: theme.colorScheme.primary),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: theme.colorScheme.primary.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
