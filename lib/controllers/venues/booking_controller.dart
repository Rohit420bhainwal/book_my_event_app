import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bookmyevent/app/services/api_service.dart';
import '../../routes/app_routes.dart';
import '../../app/views/payment_screen.dart';

enum PaymentChoice { advance, full }

class BookingController extends GetxController {
  /// Selected values
  var selectedDate = DateTime.now().obs;
  var guests = 50.obs;
  var notes = "".obs;
  var paymentChoice = PaymentChoice.advance.obs;

  /// Calendar availability
  var monthAvailability = <String, String>{}.obs;
  var isLoadingCalendar = false.obs;

  final ApiService api = ApiService();

  /// TEMP
  final String hardcodedSlot = "10:00-12:00";
  var serviceId = "".obs;

  // ===============================
  // 📅 MONTH AVAILABILITY
  // ===============================
  Future<void> fetchMonthAvailability({required DateTime month}) async {
    final monthKey = DateFormat("yyyy-MM").format(month);
    isLoadingCalendar.value = true;

    try {
      final response = await api.get("availability/month?serviceId=$serviceId&month=$monthKey",withAuth: true);

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

  /// ✅ SAFE AVAILABILITY CHECK (NO TIMEZONE)
  bool isBooked(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final key = DateFormat("yyyy-MM-dd").format(normalized);
    return monthAvailability[key] == "FULL";
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

  /// ✅ FINAL SAVE (CRITICAL FIX)
  Future<void> saveFinalBooking(
      Map<String, dynamic> venue,
      String? paymentId, {
        required Function(String) onMessage,
      }) async {
    /// 🔥 normalize BEFORE sending
    final safeDate = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final body = {
      "providerId": venue["providerId"],
      "serviceId": venue["_id"],

      /// ✅ DATE-ONLY FORMAT (NO TIMEZONE SHIFT EVER)
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
