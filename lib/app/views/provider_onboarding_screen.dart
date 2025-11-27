import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/provider_onboarding_controller.dart';

class ProviderOnboardingScreen extends StatelessWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderOnboardingController());
    final args = Get.arguments ?? {};
    final String userId = args["userId"] ?? "";
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        title: const Text(
          "Provider Onboarding",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(
            () => Stepper(
          type: StepperType.vertical,
          currentStep: controller.currentStep.value,
          onStepContinue: () {
            if (controller.currentStep.value < 2) {
              controller.nextStep();
            } else {
              controller.submitProviderInfo(userId);
            }
          },
          onStepCancel: controller.previousStep,
          controlsBuilder: (context, details) {
            final isLast = controller.currentStep.value == 2;
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        isLast ? "Submit" : "Next",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (controller.currentStep.value > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Back",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text("Basic Information"),
              isActive: controller.currentStep.value >= 0,
              state: controller.currentStep.value > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildBasicInfoStep(controller),
            ),
            Step(
              title: const Text("Service Details"),
              isActive: controller.currentStep.value >= 1,
              state: controller.currentStep.value > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildServiceInfoStep(controller),
            ),
            Step(
              title: const Text("Upload Images"),
              isActive: controller.currentStep.value >= 2,
              state: StepState.indexed,
              content: _buildImageUploadStep(controller),
            ),
          ],
        ),
      ),
    );
  }

  // Basic Info
  Widget _buildBasicInfoStep(ProviderOnboardingController controller) {
    return _buildCard(
      children: [
        _inputField(controller.businessNameController, "Business Name"),
        _inputField(controller.contactPersonController, "Contact Person"),
        _inputField(controller.phoneController, "Phone Number",
            keyboardType: TextInputType.phone),
        _inputField(controller.emailController, "Email Address",
            keyboardType: TextInputType.emailAddress),
        _inputField(controller.addressController, "Business Address", maxLines: 2),
        _inputField(controller.cityController, "City", maxLines: 1),
      ],
    );
  }

  // Service Info
  Widget _buildServiceInfoStep(ProviderOnboardingController controller) {
    return _buildCard(
      children: [
        DropdownButtonFormField<String>(
          value: controller.selectedServiceType,
          items: const [
            DropdownMenuItem(value: "catering", child: Text("Catering")),
            DropdownMenuItem(value: "decoration", child: Text("Decoration")),
            DropdownMenuItem(value: "photography", child: Text("Photography")),
            DropdownMenuItem(value: "venue", child: Text("Venue")),
          ],
          onChanged: (v) => controller.selectedServiceType = v!,
          decoration: InputDecoration(
            labelText: "Service Type",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _inputField(controller.descriptionController, "Service Description",
            maxLines: 3),
        _inputField(controller.priceController, "Starting Price",
            keyboardType: TextInputType.number),
      ],
    );
  }

  // Upload Images
  Widget _buildImageUploadStep(ProviderOnboardingController controller) {
    return _buildCard(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 22,color: Colors.white,),
          label: const Text("Pick Images (Max 5)",style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.indigo.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: controller.pickImages,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final images = <Widget>[];

          images.addAll(controller.existingImages.map((img) => _buildImageTile(
            image: Image.network(
              "${controller.apiService.imageUrl}$img",
              fit: BoxFit.cover,
              width: 90,
              height: 90,
            ),
            onRemove: () => controller.existingImages.remove(img),
          )));

          images.addAll(controller.selectedImages.map((file) => _buildImageTile(
            image: Image.file(file, fit: BoxFit.cover, width: 90, height: 90),
            onRemove: () => controller.selectedImages.remove(file),
          )));

          return images.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(8),
            child: Text("No images selected yet.",
                style: TextStyle(color: Colors.grey)),
          )
              : Wrap(spacing: 10, runSpacing: 10, children: images);
        }),
      ],
    );
  }

  // Helpers
  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
            const BorderSide(color: Colors.indigo, width: 1.8),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildImageTile({required Widget image, required VoidCallback onRemove}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: image,
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
