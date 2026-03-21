import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/edit_service_controller.dart';
import 'availability_screen.dart';

class EditServiceScreen extends StatelessWidget {
  final String userId;
  final String serviceId;
  final String initialType;
  final String initialDescription;
  final String initialPrice;
  final String initialSelectedServiceId;
  final List<dynamic> initialImages;
  final Map<String, dynamic> initialFilledFields;

  const EditServiceScreen({
    super.key,
    required this.userId,
    required this.serviceId,
    required this.initialType,
    required this.initialDescription,
    required this.initialPrice,
    required this.initialImages,
    required this.initialFilledFields,
    required this.initialSelectedServiceId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      EditServiceController(
        userId: userId,
        serviceId: serviceId,
        initialType: initialType,
        initialDescription: initialDescription,
        initialPrice: initialPrice,
        initialImages: initialImages,
        initialFilledFields: initialFilledFields,
        initialSelectedServiceId: initialSelectedServiceId,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Service")),
      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// DESCRIPTION
              TextField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration:
                const InputDecoration(labelText: "Description"),
              ),

              const SizedBox(height: 15),

              /// PRICE
              TextField(
                controller: controller.priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              /// Dynamic fields
              const Text("Dynamic Fields",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ...controller.dynamicControllers.entries.map(
                    (entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          hintText: "Enter ${entry.key}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              /// Existing Images
              if (controller.existingImages.isNotEmpty)
                const Text("Existing Images",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.existingImages.map((img) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          "${controller.apiService.imageUrl}$img",
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () =>
                              controller.deleteExistingImage(img),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// New Images
              const Text("New Images",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...controller.selectedImages.map((file) {
                    final index =
                    controller.selectedImages.indexOf(file);
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(file.path),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () =>
                                controller.removeNewImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  GestureDetector(
                    onTap: controller.pickImages,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade300,
                      ),
                      child: const Icon(Icons.add_a_photo),
                    ),
                  )
                ],
              ),



              const SizedBox(height: 20),

              /// AVAILABILITY CARD (PROFESSIONAL)
              GestureDetector(
                onTap: () {
                  Get.to(
                        () => AvailabilityScreen(
                      serviceId: serviceId,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ICON
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.schedule,
                          color: Colors.blue.shade700,
                          size: 26,
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// TEXT CONTENT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Availability",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Set working days and time slots for this service",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      /// STATUS + ARROW
                      Column(
                        children: const [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              /// SAVE BUTTON
              /// SAVE BUTTON (PROFESSIONAL PRIMARY CTA)
              Obx(
                    () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.saveService,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isSaving.value
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 14),
                        Text(
                          "Saving...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.save_rounded, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Save Service",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
