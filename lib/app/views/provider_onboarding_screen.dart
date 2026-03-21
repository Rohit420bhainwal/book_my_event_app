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
                      onPressed: controller.isSubmitting.value
                          ? null
                          : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: controller.isSubmitting.value
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
              content: Obx(() {
                if (controller.isFetchingCategories.value &&
                    controller.serviceCategories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _buildServiceInfoStep(controller);
              }),
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

  // Basic Info Widget
  Widget _buildBasicInfoStep(ProviderOnboardingController controller) {
    return _buildCard(children: [
      _inputField(controller.businessNameController, "Business Name"),
      _inputField(controller.contactPersonController, "Contact Person"),
      _inputField(controller.phoneController, "Phone Number",
          keyboardType: TextInputType.phone),
      _inputField(controller.emailController, "Email Address",
          keyboardType: TextInputType.emailAddress),
      _inputField(controller.addressController, "Business Address",
          maxLines: 2),
     // _inputField(controller.cityController, "City"),
// inside _buildBasicInfoStep()

      Obx(() => DropdownButtonFormField<String>(
        value: controller.selectedCity.value.isEmpty
            ? null
            : controller.selectedCity.value,
        items: controller.uaeCities
            .map(
              (city) => DropdownMenuItem(
            value: city,
            child: Text(city),
          ),
        )
            .toList(),
        onChanged: (value) {
          controller.selectedCity.value = value ?? "";
        },
        decoration: InputDecoration(
          labelText: "City",
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.indigo, width: 1.8),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      )),

      const SizedBox(height: 8),

      // Government ID Dropdown
      DropdownButtonFormField<String>(
        value: controller.idType.value == "" ? null : controller.idType.value,
        items: controller.idTypeOptions
            .map((e) => DropdownMenuItem(value: e["value"], child: Text(e["label"]!)))
            .toList(),
        onChanged: (v) {
          controller.idType.value = v ?? "";
          // reset id files when changing type
          controller.idFrontFile.value = null;
          controller.idBackFile.value = null;
          // persist selected idType
          controller.box.write("idType", v ?? "");
        },
        decoration: InputDecoration(
          labelText: "Government ID Type",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      const SizedBox(height: 12),

      // ID Upload Controls
      Obx(() {
        final requiresTwo = controller.idType.value == "aadhaar" ||
            controller.idType.value == "voterId" ||
            controller.idType.value == "license";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              requiresTwo ? "Upload Front and Back of ID" : "Upload ID Image",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                // Front
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt, size: 18,color: Colors.white,),
                        label: Text(controller.idFrontFile.value == null ? "Front Image" : "Change Front",style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => controller.pickIdImage(isFront: true),
                      ),
                      const SizedBox(height: 8,),
                      if (controller.idFrontFile.value != null)
                        _buildIdPreview(controller.idFrontFile.value!, onRemove: () => controller.removeIdImage(isFront: true)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Back (if required)
                if (requiresTwo)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt, size: 18,color: Colors.white,),
                          label: Text(controller.idBackFile.value == null ? "Back Image" : "Change Back",style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => controller.pickIdImage(isFront: false),
                        ),
                        const SizedBox(height: 8),
                        if (controller.idBackFile.value != null)
                          _buildIdPreview(controller.idBackFile.value!, onRemove: () => controller.removeIdImage(isFront: false)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    ]);
  }

  // Service Info Widget (dynamic fields + price + description)
  Widget _buildServiceInfoStep(ProviderOnboardingController controller) {
    // safe-guards
    if (controller.serviceCategories.isEmpty ||
        controller.selectedServiceIndex.value == null) {
      return const SizedBox.shrink();
    }

    final selected = controller.serviceCategories[controller.selectedServiceIndex.value!];
    final fields = selected["fields"] as List<dynamic>? ?? [];

    return _buildCard(children: [
      DropdownButtonFormField<int>(
        value: controller.selectedServiceIndex.value,
        items: controller.serviceCategories
            .asMap()
            .entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value["name"])))
            .toList(),
        onChanged: (v) => controller.selectedServiceIndex.value = v,
        decoration: InputDecoration(
          labelText: "Service Type",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      const SizedBox(height: 12),

      // dynamic fields
      ...fields.map<Widget>((f) {
        final key = f["key"]?.toString() ?? "";
        final label = f["label"]?.toString() ?? key;
        final type = f["type"]?.toString() ?? "text";

        if (type == "dropdown") {
          final options = (f["options"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
          final current = controller.dynamicFields[key]?.value == "" ? null : controller.dynamicFields[key]?.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              value: current,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) => controller.dynamicFields[key]?.value = v,
            ),
          );
        }

        // number / multiline / text fields
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            keyboardType: type == "number" ? TextInputType.number : TextInputType.text,
            maxLines: type == "multiline" ? 3 : 1,
            onChanged: (v) => controller.dynamicFields[key]?.value = v,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        );
      }).toList(),

      // price
      TextField(
        keyboardType: TextInputType.number,
        controller: controller.priceController,
        decoration: InputDecoration(
          labelText: "Price",
          prefixText: "₹ ",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      const SizedBox(height: 12),

      // description
      TextField(
        maxLines: 3,
        controller: controller.descriptionController,
        decoration: InputDecoration(
          labelText: "Description",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ]);
  }

  // Upload Images Step
  Widget _buildImageUploadStep(ProviderOnboardingController controller) {
    return _buildCard(children: [
      ElevatedButton.icon(
        icon: const Icon(Icons.add_photo_alternate_outlined, size: 22, color: Colors.white),
        label: const Text("Pick Images (Max 5)", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.indigo.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: controller.pickImages,
      ),
      const SizedBox(height: 16),
      Obx(() {
        final tiles = <Widget>[];

        tiles.addAll(controller.existingImages.map((img) => _buildImageTile(
          image: Image.network("${controller.apiService.imageUrl}$img", fit: BoxFit.cover, width: 90, height: 90),
          onRemove: () => controller.existingImages.remove(img),
        )));

        tiles.addAll(controller.selectedImages.map((file) => _buildImageTile(
          image: Image.file(file, fit: BoxFit.cover, width: 90, height: 90),
          onRemove: () => controller.selectedImages.remove(file),
        )));

        return tiles.isEmpty
            ? const Padding(padding: EdgeInsets.all(8), child: Text("No images selected", style: TextStyle(color: Colors.grey)))
            : Wrap(spacing: 10, runSpacing: 10, children: tiles);
      }),
    ]);
  }

  // Helpers
  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: children)),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.indigo, width: 1.8), borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildImageTile({required Widget image, required VoidCallback onRemove}) {
    return Stack(children: [
      ClipRRect(borderRadius: BorderRadius.circular(10), child: image),
      Positioned(
        right: 4,
        top: 4,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            padding: const EdgeInsets.all(3),
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ),
      ),
    ]);
  }

  Widget _buildIdPreview(File file, {required VoidCallback onRemove}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(file, height: 100, width: 160, fit: BoxFit.cover),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
