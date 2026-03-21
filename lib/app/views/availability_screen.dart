import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/availability_controller.dart';

class AvailabilityScreen extends StatelessWidget {
  final String serviceId;

  const AvailabilityScreen({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.put(AvailabilityController(serviceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Availability"),
      ),
      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// STATUS BANNER
              if (controller.hasAvailability.value)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    "Availability already set. You can update it.",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    "No availability found. Please set your availability.",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              /// WORKING DAYS
              const Text(
                "Working Days",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  return ChoiceChip(
                    label: Text(_dayName(index)),
                    selected:
                    controller.selectedDays.contains(index),
                    selectedColor: Colors.blue.shade200,
                    onSelected: (_) =>
                        controller.toggleDay(index),
                  );
                }),
              ),

              const Spacer(),

              /// SAVE / UPDATE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.selectedDays.isEmpty
                      ? null
                      : controller.saveAvailability,
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    disabledBackgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    controller.hasAvailability.value
                        ? "Update Availability"
                        : "Save Availability",
                    style: const TextStyle(color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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

  String _dayName(int index) {
    const days = [
      "Sun",
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
    ];
    return days[index];
  }
}
