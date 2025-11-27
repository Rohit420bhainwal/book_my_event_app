import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/venues/booking_controller.dart';

class BookingFormScreen extends StatelessWidget {
  final Map<String, dynamic> venue;

  const BookingFormScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingController(), permanent: true);
    final venueName = venue['businessName'] ?? "Unknown Venue";
    final venueId = venue["_id"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text("Book $venueName"),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(venue["description"] ?? "No description available"),
            const SizedBox(height: 20),

            // 📅 Date Picker
            Obx(() => ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(
                "Date: ${DateFormat('dd MMM yyyy').format(controller.selectedDate.value)}",
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: controller.selectedDate.value,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  controller.updateDate(picked, venueId);
                }
              },
            )),
            const SizedBox(height: 20),

            // ⏰ Slot Selection
            Obx(() {
              final booked = controller.bookedSlots;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Slot",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildSlotButton("morning", "9 AM – 4 PM",
                          booked.contains("morning"), controller),
                      _buildSlotButton("evening", "5 PM – 12 AM",
                          booked.contains("evening"), controller),
                      _buildSlotButton("full_day", "9 AM – 10 PM",
                          booked.contains("full_day"), controller),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),

            // 👥 Guests
            TextField(
              decoration: const InputDecoration(
                labelText: "Number of Guests",
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) =>
                  controller.updateGuests(int.tryParse(val) ?? 50),
            ),
            const SizedBox(height: 16),

            // 📝 Notes
            TextField(
              decoration: const InputDecoration(
                labelText: "Additional Notes",
                prefixIcon: Icon(Icons.note),
              ),
              onChanged: controller.updateNotes,
            ),
            const SizedBox(height: 24),

            // 📌 Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => controller.bookVenue(venue),
              child: const Text(
                "Confirm Booking",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotButton(
      String slot, String time, bool isBooked, BookingController controller) {
    final isSelected = controller.selectedSlot.value == slot;
    return ElevatedButton(
      onPressed: isBooked ? null : () => controller.selectSlot(slot),
      style: ElevatedButton.styleFrom(
        backgroundColor: isBooked
            ? Colors.grey
            : isSelected
            ? Colors.deepPurple
            : Colors.blue,
      ),
      child: Column(
        children: [
          Text(slot.replaceAll("_", " ").toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Text(time, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
