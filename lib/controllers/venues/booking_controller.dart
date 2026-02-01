import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/services/api_service.dart';
import '../../app/views/payment_screen.dart';
import '../../routes/app_routes.dart';

enum PaymentChoice { advance, full }

class BookingController extends GetxController {
  var selectedDate = DateTime.now().obs;
  var guests = 50.obs;
  var notes = "".obs;
  var paymentChoice = PaymentChoice.advance.obs;

  /// 📅 CALENDAR
  var monthAvailability = <String, String>{}.obs;
  var isLoadingCalendar = false.obs;

  final ApiService api = ApiService();

  final String hardcodedSlot = "10:00-12:00";
  var serviceId = "".obs;

  // ===============================
  // 📅 MONTH AVAILABILITY
  // ===============================
  Future<void> fetchMonthAvailability({required DateTime month}) async {
    final monthKey = DateFormat("yyyy-MM").format(month);
    isLoadingCalendar.value = true;

    try {
      final response = await api.get(
        "availability/month?serviceId=${serviceId.value}&month=$monthKey",
        withAuth: true,
      );

      final Map<String, dynamic> days =
      Map<String, dynamic>.from(response["data"]["days"]);

      monthAvailability.clear();
      days.forEach((key, value) {
        monthAvailability[key] = value.toString();
      });
    } finally {
      isLoadingCalendar.value = false;
    }
  }

  // ===============================
  // 🧾 BOOKING
  // ===============================
  void updateGuests(int value) => guests.value = value;
  void updateNotes(String value) => notes.value = value;

  Future<void> bookVenue(Map<String, dynamic> venue) async {
    int amount = int.tryParse(venue["price"].toString()) ?? 1000;

    Get.to(() => PaymentScreen(
      venue: venue,
      amount: amount,
      selectedDate: selectedDate.value,
      selectedSlot: hardcodedSlot,
      paymentChoice: paymentChoice.value,
    ));
  }

  Future<void> saveFinalBooking(
      Map<String, dynamic> venue,
      String? paymentId, {
        required Function(String) onMessage,
      }) async {
    final safeDate = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final body = {
      "providerId": venue["providerId"],
      "serviceId": venue["_id"],
      "date": DateFormat("yyyy-MM-dd").format(safeDate),
      "slot": hardcodedSlot,
      "paymentIntentId": paymentId,
    };

    final response =
    await api.post("bookings/confirm", body, withAuth: true);

    if (response["success"] == true) {
      onMessage("Booking request sent successfully");
      Get.offAllNamed(Routes.customerDashboard);
    }
  }
}
