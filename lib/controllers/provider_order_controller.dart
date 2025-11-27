import 'package:bookmyevent/app/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProviderOrderController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs; // list of bookings
  var serviceImages = <String>[].obs;

  // Fetch all bookings for the provider
  Future<void> fetchProviderBookings() async {
    try {
      isLoading.value = true;
      final response = await _apiService.get("bookings/provider", withAuth: true);
      print("response_provider $response");

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as List<dynamic>;

        // Convert to proper list of maps
        bookings.value = List<Map<String, dynamic>>.from(data);

        // ✅ Fix image URLs inside bookings
        for (var booking in bookings) {
          final images = booking["service"]?["images"];
          if (images != null && images is List && images.isNotEmpty) {
            // Map each image name to full URL
            booking["service"]["images"] = images.map((img) {
              return "${_apiService.imageUrl}${img.toString().replaceAll("\\", "/").replaceFirst(RegExp(r"^/"), "")}";
            }).toList();

            // Precache first image
            final firstImage = booking["service"]["images"][0];
            precacheImage(CachedNetworkImageProvider(firstImage), Get.context!);
          }
        }
      } else {
        Get.snackbar("Error", "No bookings found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load bookings: $e");
      print("Error fetching bookings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch single booking details
  Future<void> fetchBookingDetails(String bookingId) async {
    try {
      isLoading.value = true;
      final response = await _apiService.get("bookings/$bookingId");
      print("my_response: $response");

      if (response['success'] == true) {
        final booking = response['data'] ?? {};
        final images = booking["service"]?["images"];

        if (images != null && images is List) {
          // ✅ Convert all image names to full URLs
          serviceImages.value = images.map((img) {
            return "${_apiService.imageUrl}${img.toString().replaceAll("\\", "/").replaceFirst(RegExp(r"^/"), "")}";
          }).toList();

          // Precache all images
          for (var url in serviceImages) {
            precacheImage(CachedNetworkImageProvider(url), Get.context!);
          }
        }
      } else {
        Get.snackbar("Error", "Booking not found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load booking details: $e");
      print("Error fetching booking details: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
