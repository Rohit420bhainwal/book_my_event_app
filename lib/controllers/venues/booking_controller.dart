import 'package:bookmyevent/app/services/api_service.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/views/payment_screen.dart';
import '../../routes/app_routes.dart';

class BookingController extends GetxController {
  var selectedDate = DateTime.now().obs;
  var selectedSlot = "".obs; // morning, evening, full_day
  var guests = 50.obs;
  var notes = "".obs;

  ApiService api = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var bookedSlots = <String>[].obs; // already taken slots for a date

  // Fetch existing bookings for a venue on a specific date
  Future<void> fetchAvailability(String venueId, DateTime date) async {
    if (venueId.isEmpty) return;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection("bookings")
        .where("venueId", isEqualTo: venueId)
        .where("date", isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where("date", isLessThanOrEqualTo: endOfDay.toIso8601String())
        .get();

    final slots = snapshot.docs.map((doc) => doc["slot"] as String).toList();

    final conflicts = <String>{};
    for (final slot in slots) {
      if (slot == "full_day") {
        conflicts.addAll(["morning", "evening", "full_day"]);
      } else if (slot == "morning") {
        conflicts.addAll(["morning", "full_day"]);
      } else if (slot == "evening") {
        conflicts.addAll(["evening", "full_day"]);
      }
    }

    bookedSlots.value = conflicts.toList();
  }

  void updateDate(DateTime date, String venueId) {
    selectedDate.value = date;
    print("Selected Date Updated: $date");
    if (venueId.isNotEmpty) fetchAvailability(venueId, date);
  }

  void updateGuests(int value) => guests.value = value;
  void updateNotes(String value) => notes.value = value;
  void selectSlot(String slot) => selectedSlot.value = slot;

  Future<void> bookVenue(Map<String, dynamic> venue) async {
    if (selectedSlot.value.isEmpty) {
      Get.snackbar("Error", "Please select a slot.");
      return;
    }

    int amount = int.tryParse(venue["price"].toString()) ?? 1000; // Add venue price

    // 🔥 Navigate to Payment Screen
    Get.to(() => PaymentScreen(venue: venue, amount: amount));
  }


/*Future<void> bookVenue(Map<String, dynamic> venue) async {
    if (selectedSlot.value.isEmpty) {
      Get.snackbar("Error", "Please select a slot.");
      return;
    }

    // Store only the date (start of day) to match API
    final localDate = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final body = {
      "providerId": venue["providerId"],
      "serviceId": venue["id"],
      "date": localDate.toIso8601String(), // start-of-day local
      "category": venue['category'] ?? "General",
    };

    try {
      final response = await api.post("bookings", body, withAuth: true);
      if (response["success"] == true) {
        Get.snackbar("Success", "Booking request sent successfully");
      } else {
        Get.snackbar("Error", "Failed to book");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to submit booking: $e");
      print(e);
    }
  }*/

  Future<void> saveFinalBooking(Map<String, dynamic> venue, String? paymentId,{
  required Function(String) onMessage,
  }) async {
    /*
    final localDate = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final data = {
      "venueId": venue["_id"],
      "providerId": venue["providerId"],
      "slot": selectedSlot.value,
      "date": localDate.toIso8601String(),
      "guests": guests.value,
      "notes": notes.value,
      "paymentId": paymentId,
      "status": "confirmed",
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      await _firestore.collection("bookings").add(data);

      Get.snackbar("Success", "Booking completed!");
      Get.offAllNamed("/home");
    } catch (e) {
      Get.snackbar("Error", "Unable to save booking");
    }

    if (selectedSlot.value.isEmpty) {
      Get.snackbar("Error", "Please select a slot.");
      return;
    }
    */

    // Store only the date (start of day) to match API
    final localDate = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final body = {
      "providerId": venue["providerId"],
      "serviceId": venue["id"],
      "date": localDate.toIso8601String(), // start-of-day local
      "category": venue['category'] ?? "General",
      "paymentId": paymentId,
    };

    try {
      final response = await api.post("bookings", body, withAuth: true);
      if (response["success"] == true) {
        onMessage("Booking request sent successfully");
        await Future.delayed(const Duration(seconds: 2));
       // Get.snackbar("Success", "Booking request sent successfully");

     /*   try {
          PaymentScreenState.bookingMessage.value = "Booking request sent successfully";
        } catch (_) {}*/
      //  await Future.delayed(const Duration(milliseconds: 800));
        Get.offAllNamed(Routes.customerDashboard);
      } else {
        Get.snackbar("Error", "Failed to book");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to submit booking: $e");
      print(e);
    }
  }

}
