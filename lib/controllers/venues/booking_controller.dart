import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/services/api_service.dart';
import '../../routes/app_routes.dart';

class BookingController extends GetxController {
  var selectedDate = DateTime.now().obs;
  var guests = 50.obs;
  var notes = "".obs;

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
  // 🧾 BOOK VENUE (DIRECT BOOKING)
  // ===============================
  Future<void> bookVenue(
      Map<String, dynamic> venue, {
        required Function(String) onMessage,
      }) async {
    try {
      final safeDate = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
      );
      print("venue: $venue");

      final body = {
        "providerId": venue["providerId"],
        "serviceId": venue["id"],
        "date": DateFormat("yyyy-MM-dd").format(safeDate),
        "slot": hardcodedSlot,
      };

      final response = await api.post("bookings", body, withAuth: true);


      print("response_my: $response");
      if (response["data"]["booking"] != null) {
        onMessage("Booking request sent successfully");
        Get.offAllNamed(Routes.customerDashboard);
      } else {
        onMessage(response["message"] ?? "Booking failed");
      }
    } catch (e) {
      onMessage("Something went wrong");
    }
  }

  void updateGuests(int value) => guests.value = value;
  void updateNotes(String value) => notes.value = value;
}