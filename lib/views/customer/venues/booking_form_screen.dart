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
    final BookingController controller = Get.put(BookingController());
    final venueName = venue["businessName"] ?? "Venue";

    /// ✅ SET SERVICE ID
    controller.serviceId.value = venue['id'];

    /// ❗ Allow booking only from tomorrow
    final DateTime today = DateTime.now();
    final DateTime tomorrow =
    DateTime(today.year, today.month, today.day + 1);

    if (controller.selectedDate.value.isBefore(tomorrow)) {
      controller.selectedDate.value = tomorrow;
    }

    /// 🔥 LOAD CURRENT MONTH AVAILABILITY
    controller.fetchMonthAvailability(
        month: controller.selectedDate.value);

    return Scaffold(
      appBar: AppBar(
        title: Text("Book $venueName"),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// 📅 CALENDAR
            Obx(() {
              if (controller.isLoadingCalendar.value) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              return TableCalendar(
                firstDay: tomorrow,
                lastDay: DateTime(2100),
                focusedDay: controller.selectedDate.value,
                calendarFormat: CalendarFormat.month,
                availableGestures:
                AvailableGestures.horizontalSwipe,
                sixWeekMonthsEnforced: false,
                rowHeight: 44,

                selectedDayPredicate: (day) =>
                    DateUtils.isSameDay(
                        day, controller.selectedDate.value),

                onDaySelected: (selectedDay, focusedDay) {
                  final normalizedDate = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  );

                  final key = DateFormat("yyyy-MM-dd")
                      .format(normalizedDate);

                  final status =
                  controller.monthAvailability[key];

                  if (status == "FULL") {
                    Get.snackbar(
                      "Already Booked",
                      "This date is already booked.",
                      backgroundColor: Colors.red.shade100,
                    );
                    return;
                  }

                  controller.selectedDate.value =
                      normalizedDate;
                },

                onPageChanged: (focusedDay) {
                  controller.fetchMonthAvailability(
                      month: focusedDay);
                },

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) =>
                      _dayCell(controller, day),
                  todayBuilder: (context, day, _) =>
                      _dayCell(controller, day,
                          isToday: true),
                  selectedBuilder: (context, day, _) =>
                      _dayCell(controller, day,
                          isSelected: true),
                ),
              );
            }),

            const SizedBox(height: 24),

            /// 👥 GUESTS
            TextField(
              decoration: const InputDecoration(
                labelText: "Number of Guests",
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  controller.updateGuests(
                      int.tryParse(v) ?? 1),
            ),

            const SizedBox(height: 16),

            /// 📝 NOTES
            TextField(
              decoration: const InputDecoration(
                labelText: "Additional Notes",
                prefixIcon: Icon(Icons.note),
              ),
              onChanged: controller.updateNotes,
            ),

            const SizedBox(height: 24),

            /// ℹ️ PAYMENT INFO (Offline)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Payment will be collected offline. "
                    "Commission is automatically calculated by the system.",
                style: TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 24),

            /// ✅ SUBMIT BUTTON
            ElevatedButton(
              onPressed: () {
                controller.bookVenue(
                  venue,
                  onMessage: (msg) {
                    Get.snackbar(
                      "Booking",
                      msg,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF3F51B5),
                padding:
                const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Confirm Booking",
                style: TextStyle(
                    fontSize: 18, color: Colors.white),
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
    if (day.month !=
        controller.selectedDate.value.month) {
      return const SizedBox.shrink();
    }

    final key = DateFormat("yyyy-MM-dd")
        .format(DateTime(day.year, day.month, day.day));

    final status =
    controller.monthAvailability[key];

    Color bgColor = Colors.transparent;
    Color textColor = Colors.black;

    if (status == "FULL") {
      bgColor = Colors.red;
      textColor = Colors.white;
    } else if (status == "AVAILABLE") {
      bgColor = Colors.green;
      textColor = Colors.white;
    }

    if (isSelected) {
      bgColor = const Color(0xFF3F51B5);
      textColor = Colors.white;
    }

    if (isToday &&
        bgColor == Colors.transparent) {
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