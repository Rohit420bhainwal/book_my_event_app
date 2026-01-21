import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../controllers/venues/booking_controller.dart';

class BookingFormScreen extends StatelessWidget {
  final Map<String, dynamic> venue;

  const BookingFormScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingController());
    final venueName = venue["businessName"] ?? "Venue";

    controller.serviceId.value = venue['id'];
    /// ❗ Disable today → allow only tomorrow onwards
    final DateTime today = DateTime.now();
    final DateTime tomorrow =
    DateTime(today.year, today.month, today.day + 1);

    if (controller.selectedDate.value.isBefore(tomorrow)) {
      controller.selectedDate.value = tomorrow;
    }

    controller.fetchMonthAvailability(month: DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text("Book $venueName"),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// 📅 Calendar
            Obx(() {
              if (controller.isLoadingCalendar.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return TableCalendar(
                firstDay: tomorrow,
                lastDay: DateTime(2100),
                focusedDay: controller.selectedDate.value,
                calendarFormat: CalendarFormat.month,
                availableGestures: AvailableGestures.horizontalSwipe,

                selectedDayPredicate: (day) =>
                    DateUtils.isSameDay(day, controller.selectedDate.value),

                onDaySelected: (selectedDay, focusedDay) {
                  /// ✅ HARD NORMALIZATION (FIX)
                  final normalizedDate = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  );

                  final key =
                  DateFormat("yyyy-MM-dd").format(normalizedDate);
                  final status = controller.monthAvailability[key];

                  if (status == "FULL") {
                    Get.snackbar(
                      "Already Booked",
                      "This date is already booked.",
                      backgroundColor: Colors.red.shade100,
                    );
                    return;
                  }

                  controller.selectedDate.value = normalizedDate;
                },

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) =>
                      _dayCell(controller, day),
                  todayBuilder: (context, day, _) =>
                      _dayCell(controller, day, isToday: true),
                  selectedBuilder: (context, day, _) =>
                      _dayCell(controller, day, isSelected: true),
                ),
              );
            }),

            const SizedBox(height: 24),

            /// Guests
            TextField(
              decoration: const InputDecoration(
                labelText: "Number of Guests",
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  controller.updateGuests(int.tryParse(v) ?? 1),
            ),

            const SizedBox(height: 16),

            /// Notes
            TextField(
              decoration: const InputDecoration(
                labelText: "Additional Notes",
                prefixIcon: Icon(Icons.note),
              ),
              onChanged: controller.updateNotes,
            ),

            const SizedBox(height: 24),

            /// Submit
            ElevatedButton(
              onPressed: () => controller.bookVenue(venue),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
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

  /// 🎨 DAY CELL UI
  Widget _dayCell(
      BookingController controller,
      DateTime day, {
        bool isSelected = false,
        bool isToday = false,
      }) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final key = DateFormat("yyyy-MM-dd").format(normalizedDay);
    final status = controller.monthAvailability[key];

    Color bgColor = Colors.transparent;
    Color textColor = Colors.black;

    if (status == "FULL") {
      bgColor = Colors.red;
      textColor = Colors.white;
    } else if (status == "AVAILABLE") {
      bgColor = Colors.green;
      textColor = Colors.white;
    } else if (status == "UNAVAILABLE") {
      textColor = Colors.grey;
    }

    if (isSelected) {
      bgColor = const Color(0xFF3F51B5);
      textColor = Colors.white;
    }

    if (isToday && bgColor == Colors.transparent) {
      bgColor = Colors.blue.shade100;
    }

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          day.day.toString(),
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
