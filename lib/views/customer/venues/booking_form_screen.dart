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

    /// ✅ SET SERVICE ID CORRECTLY
    controller.serviceId.value = venue['id'];

    /// ❗ Allow booking only from tomorrow
    final DateTime today = DateTime.now();
    final DateTime tomorrow =
    DateTime(today.year, today.month, today.day + 1);

    if (controller.selectedDate.value.isBefore(tomorrow)) {
      controller.selectedDate.value = tomorrow;
    }

    /// 🔥 LOAD CURRENT MONTH
    controller.fetchMonthAvailability(month: controller.selectedDate.value);

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
                return const Center(child: CircularProgressIndicator());
              }

              return TableCalendar(
                firstDay: tomorrow,
                lastDay: DateTime(2100),
                focusedDay: controller.selectedDate.value,
                calendarFormat: CalendarFormat.month,
                availableGestures: AvailableGestures.horizontalSwipe,

                /// 🔥 FIXES

                sixWeekMonthsEnforced: false,
                rowHeight: 44,

                selectedDayPredicate: (day) =>
                    DateUtils.isSameDay(day, controller.selectedDate.value),

                onDaySelected: (selectedDay, focusedDay) {
                  final normalizedDate = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  );

                  final key =
                  DateFormat("yyyy-MM-dd").format(normalizedDate);
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

                  controller.selectedDate.value = normalizedDate;
                },

                /// 🔥 LOAD MONTH ON SWIPE
                onPageChanged: (focusedDay) {
                  controller.fetchMonthAvailability(month: focusedDay);
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

            /// 👥 GUESTS
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

            /// 📝 NOTES
            TextField(
              decoration: const InputDecoration(
                labelText: "Additional Notes",
                prefixIcon: Icon(Icons.note),
              ),
              onChanged: controller.updateNotes,
            ),

            const SizedBox(height: 24),

            /// 💳 PAYMENT
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment Option",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _paymentOptionTile(
                    title: "Pay 25% Advance",
                    subtitle: "Book now, pay remaining later",
                    value: PaymentChoice.advance,
                    groupValue: controller.paymentChoice.value,
                    onChanged: (val) =>
                    controller.paymentChoice.value = val!,
                  ),

                  const SizedBox(height: 8),

                  _paymentOptionTile(
                    title: "Pay Full Amount",
                    subtitle: "Pay 100% and confirm faster",
                    value: PaymentChoice.full,
                    groupValue: controller.paymentChoice.value,
                    onChanged: (val) =>
                    controller.paymentChoice.value = val!,
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),

            /// ✅ SUBMIT
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
    /// 🔥 IGNORE OUTSIDE MONTH
    if (day.month != controller.selectedDate.value.month) {
      return const SizedBox.shrink();
    }

    final key = DateFormat("yyyy-MM-dd")
        .format(DateTime(day.year, day.month, day.day));
    final status = controller.monthAvailability[key];

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

  Widget _paymentOptionTile({
    required String title,
    required String subtitle,
    required PaymentChoice value,
    required PaymentChoice groupValue,
    required ValueChanged<PaymentChoice?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
            isSelected ? const Color(0xFF3F51B5) : Colors.grey.shade300,
            width: 1.5,
          ),
          color: isSelected
              ? const Color(0xFF3F51B5).withOpacity(0.08)
              : Colors.white,
        ),
        child: Row(
          children: [
            Radio<PaymentChoice>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFF3F51B5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
