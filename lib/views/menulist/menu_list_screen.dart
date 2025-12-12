import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/menu_list_controller.dart';

class MenuListScreen extends StatelessWidget {
  final String token;
  final String userId;
  final String roleName;

  const MenuListScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.roleName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MenuListController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isLoading.value && controller.menuItems.isEmpty) {
        controller.fetchServiceCategory(token);
      }
    });

    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(12);

    return Scaffold(
      backgroundColor: theme.cardColor,
      appBar: AppBar(
        title: const Text("Add Service"),
        centerTitle: true,
        elevation: 1,
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Obx(() {
          final disabled = controller.isSaveDisabled;

          return SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: disabled
                  ? null
                  : () async {
                if (controller.selectedIndex.value == null) {
                  Get.snackbar("Validation", "Please choose a category");
                  return;
                }

                final selected = controller.menuItems[
                controller.selectedIndex.value!];

                await controller.uploadProviderService(
                  token: token,
                  userId: userId,
                  action: "add",
                  selectedServiceId: selected.id,
                  selectedServiceType: selected.name,
                  filledFields: controller.getFilledFieldsJson(),
                  description: controller.description.value,
                  price: controller.price.value,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                disabledBackgroundColor:
                theme.primaryColor.withOpacity(0.4),
                shape:
                RoundedRectangleBorder(borderRadius: borderRadius),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                "Save Service",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),

      body: Obx(() {
        return Stack(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildContent(controller, theme, borderRadius),
            ),

            if (controller.isLoading.value)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }


  /// -------------------------------
  /// MAIN CONTENT WITH SAFE GUARDS
  /// -------------------------------
  Widget _buildContent(MenuListController controller, ThemeData theme,
      BorderRadius borderRadius) {

    /// 1️⃣ API LOADING → show loader
    if (controller.isLoading.value && controller.menuItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    /// 2️⃣ API DONE BUT EMPTY → show retry
    if (controller.menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category, size: 48, color: theme.hintColor),
            const SizedBox(height: 8),
            const Text("No categories found", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => controller.fetchServiceCategory(token),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    /// 3️⃣ Guard: If selectedIndex is null OR out of range
    if (controller.selectedIndex.value == null ||
        controller.selectedIndex.value! >= controller.menuItems.length) {
      return const Center(child: Text("Select a category"));
    }

    /// Now it is safe to access menuItems[index]
    final selectedIndex = controller.selectedIndex.value!;
    final selectedCategory = controller.menuItems[selectedIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// Category Dropdown
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<int>(
                value: controller.selectedIndex.value,
                decoration: InputDecoration(
                  labelText: "Service Category",
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                items: List.generate(
                  controller.menuItems.length,
                      (i) => DropdownMenuItem(
                    value: i,
                    child: Text(controller.menuItems[i].name),
                  ),
                ),
                onChanged: controller.onCategoryChange,
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// Dynamic Fields
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Details",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),

                  ...selectedCategory.fields.map((f) {
                    if (f.type == "dropdown") {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<String>(
                          value: controller.dynamicFields[f.key]?.value == ""
                              ? null
                              : controller.dynamicFields[f.key]?.value,
                          decoration: InputDecoration(
                            labelText: f.label,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                          items: f.options
                              .map((o) =>
                              DropdownMenuItem(value: o, child: Text(o)))
                              .toList(),
                          onChanged: (v) =>
                          controller.dynamicFields[f.key]?.value = v,
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        keyboardType: f.type == "number"
                            ? TextInputType.number
                            : TextInputType.text,
                        maxLines: f.type == "multiline" ? 3 : 1,
                        onChanged: (v) =>
                        controller.dynamicFields[f.key]?.value = v,
                        decoration: InputDecoration(
                          labelText: f.label,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    );
                  }),

                  /// Price
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (v) => controller.price.value = v,
                    decoration: InputDecoration(
                      labelText: "Price",
                      prefixText: "₹ ",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Description
                  TextField(
                    maxLines: 3,
                    onChanged: (v) => controller.description.value = v,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// Images card
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Images",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                    "Add up to 5 images. Tap to preview. Long press to remove.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 110,
                    child: Obx(() {
                      final images = controller.selectedImages;
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          if (index == images.length) {
                            return InkWell(
                              onTap: controller.pickImages,
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                  Border.all(color: Colors.grey.shade300),
                                  color: Colors.grey.shade100,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        size: 28,
                                        color: Colors.grey.shade700),
                                    const SizedBox(height: 6),
                                    Text("Add",
                                        style: TextStyle(
                                            color: Colors.grey.shade700)),
                                  ],
                                ),
                              ),
                            );
                          }

                          final file = images[index];

                          return GestureDetector(
                            onTap: () {
                              Get.dialog(
                                Dialog(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(File(file.path),
                                        fit: BoxFit.contain),
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              Get.defaultDialog(
                                title: "Remove image?",
                                textConfirm: "Yes",
                                textCancel: "No",
                                onConfirm: () {
                                  controller.removeImage(index);
                                  Get.back();
                                },
                                middleText:
                                "Do you want to remove this image?",
                              );
                            },
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(File(file.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 6),
                        itemCount: images.length + 1,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
