import 'package:bookmyevent/app/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProviderBookingDetailController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var booking = <String, dynamic>{}.obs;

  Future<void> fetchBookingDetail(String bookingId) async {
    try {
      isLoading.value = true;
      final response = await _apiService.get("bookings/$bookingId", withAuth: true);

      print("response: $response");
      if (response['success'] == true) {
        final data = Map<String, dynamic>.from(response['data']);

        // ✅ Fix: prepend base URL to images if they exist
        final images = data["service"]?["images"];
        if (images != null && images is List && images.isNotEmpty) {
          data["service"]["images"] = images.map((img) {
            return "${_apiService.imageUrl}${img.toString().replaceAll("\\", "/").replaceFirst(RegExp(r"^/"), "")}";
          }).toList();

          // Optional: Precache all images for smoother display
          for (var imgUrl in data["service"]["images"]) {
            precacheImage(CachedNetworkImageProvider(imgUrl), Get.context!);
          }
        }

        booking.value = data;
      } else {
        Get.snackbar("Error", "Booking not found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch booking: $e");
      print("Error in fetchBookingDetail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      isLoading.value = true;
      final response = await _apiService.put(
        "bookings/$bookingId/status",
        {"status": status},
        withAuth: true,
      );

      if (response['success'] == true || response['booking'] != null) {
        booking['status'] = status;
        booking.refresh();
        Get.snackbar(
          "Success",
          "Booking ${status == 'confirmed' ? 'accepted' : 'rejected'} successfully",
        );
      } else {
        Get.snackbar("Error", "Failed to update status");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update booking: $e");
      print("Error in updateBookingStatus: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
