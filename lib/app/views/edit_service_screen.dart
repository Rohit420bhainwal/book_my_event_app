import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/edit_service_controller.dart';

class EditServiceScreen extends StatelessWidget {
  final String userId;
  final String serviceId;
  final String initialType;
  final String initialDescription;
  final String initialPrice;
  final List<dynamic> initialImages;

  const EditServiceScreen({
    super.key,
    required this.userId,
    required this.serviceId,
    required this.initialType,
    required this.initialDescription,
    required this.initialPrice,
    required this.initialImages,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditServiceController(
      userId: userId,
      serviceId: serviceId,
      initialType: initialType,
      initialDescription: initialDescription,
      initialPrice: initialPrice,
      initialImages: initialImages,
    ));

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Service"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
              () => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Service Type"),
                  controller: controller.typeController,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: "Description"),
                  controller: controller.descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  controller: controller.priceController,
                ),
                const SizedBox(height: 20),

                // ✅ Existing Images with Delete Option
                if (controller.existingImages.isNotEmpty) ...[
                  const Text(
                    "Existing Images",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.existingImages.length,
                      itemBuilder: (context, index) {
                        final imageName = controller.existingImages[index];
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  "${controller.apiService.imageUrl}$imageName",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 60),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 4,
                              child: GestureDetector(
                                onTap: () =>
                                    controller.removeExistingImage(imageName),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ✅ Newly Picked Images
                if (controller.selectedImages.isNotEmpty) ...[
                  const Text(
                    "New Images",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.selectedImages.length,
                      itemBuilder: (context, index) {
                        final file = controller.selectedImages[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              file,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ✅ Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: controller.pickImages,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text("Pick Images"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.saveService,
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
