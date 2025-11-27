import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard/profile/provider_add_listing_controller.dart';

class ProviderAddVenueScreen extends StatelessWidget {
  const ProviderAddVenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderAddListingController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Venue / Service"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Type",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Venue", overflow: TextOverflow.ellipsis),
                          value: "venue",
                          groupValue: controller.providerType.value,
                          activeColor: theme.colorScheme.primary,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          onChanged: (val) => controller.providerType.value = val!,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Service", overflow: TextOverflow.ellipsis),
                          value: "service",
                          groupValue: controller.providerType.value,
                          activeColor: theme.colorScheme.secondary,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          onChanged: (val) => controller.providerType.value = val!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ================= Venue Flow =================
                  if (controller.providerType.value == "venue") ...[
                    _themedTextField(
                      context,
                      label: "Venue Name",
                      value: controller.venueName.value,
                      onChanged: (val) => controller.venueName.value = val,
                    ),
                    const SizedBox(height: 10),
                    _themedTextField(
                      context,
                      label: "Capacity",
                      value: controller.capacity.value,
                      onChanged: (val) => controller.capacity.value = val,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _themedTextField(
                      context,
                      label: "Price",
                      value: controller.price.value,
                      onChanged: (val) => controller.price.value = val,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _themedTextField(
                      context,
                      label: "Address",
                      value: controller.address.value,
                      onChanged: (val) => controller.address.value = val,
                    ),
                  ],

                  // ================= Service Flow =================
                  if (controller.providerType.value == "service") ...[
                    _themedTextField(
                      context,
                      label: "Provider/Brand Name",
                      value: controller.providerName.value,
                      onChanged: (val) => controller.providerName.value = val,
                    ),
                    const SizedBox(height: 10),
                    Text("Select Services with Price",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.secondary,
                        )),
                    const SizedBox(height: 8),

                    // Catering
                    Obx(() => CheckboxListTile(
                      title: Row(
                        children: [
                          const Text("Catering"),
                          const SizedBox(width: 10),
                          if (controller.cateringEnabled.value)
                            Expanded(
                              child: _themedTextField(
                                context,
                                label: "Price",
                                value: controller.cateringPrice.value,
                                onChanged: (val) => controller.cateringPrice.value = val,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                        ],
                      ),
                      value: controller.cateringEnabled.value,
                      activeColor: theme.colorScheme.secondary,
                      onChanged: (val) => controller.cateringEnabled.value = val!,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    )),

                    // DJ
                    Obx(() => CheckboxListTile(
                      title: Row(
                        children: [
                          const Text("DJ"),
                          const SizedBox(width: 10),
                          if (controller.djEnabled.value)
                            Expanded(
                              child: _themedTextField(
                                context,
                                label: "Price",
                                value: controller.djPrice.value,
                                onChanged: (val) => controller.djPrice.value = val,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                        ],
                      ),
                      value: controller.djEnabled.value,
                      activeColor: theme.colorScheme.secondary,
                      onChanged: (val) => controller.djEnabled.value = val!,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    )),

                    // Decoration
                    Obx(() => CheckboxListTile(
                      title: Row(
                        children: [
                          const Text("Decoration"),
                          const SizedBox(width: 10),
                          if (controller.decorationEnabled.value)
                            Expanded(
                              child: _themedTextField(
                                context,
                                label: "Price",
                                value: controller.decorationPrice.value,
                                onChanged: (val) => controller.decorationPrice.value = val,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                        ],
                      ),
                      value: controller.decorationEnabled.value,
                      activeColor: theme.colorScheme.secondary,
                      onChanged: (val) => controller.decorationEnabled.value = val!,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    )),

                    const SizedBox(height: 10),

                    _themedTextField(
                      context,
                      label: "Discount % for Combo",
                      value: controller.discountPercent.value,
                      onChanged: (val) => controller.discountPercent.value = val,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),

                    _themedTextField(
                      context,
                      label: "Base Address",
                      value: controller.address.value,
                      onChanged: (val) => controller.address.value = val,
                    ),
                    const SizedBox(height: 10),
                    _themedTextField(
                      context,
                      label: "Service Radius (km)",
                      value: controller.serviceRadius.value,
                      onChanged: (val) => controller.serviceRadius.value = val,
                      keyboardType: TextInputType.number,
                    ),
                  ],

                  const SizedBox(height: 30),

                  controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: controller.isFormValid
                                ? controller.saveListing
                                : null, // <-- Disable if not valid
                            child: const Text("Save", style: TextStyle(fontSize: 16)),
                          ),
                        )),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _themedTextField(
    BuildContext context, {
    required String label,
    required String value,
    required Function(String) onChanged,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      style: theme.textTheme.bodyLarge,
      keyboardType: keyboardType,
      onChanged: onChanged,
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
    );
  }
}
