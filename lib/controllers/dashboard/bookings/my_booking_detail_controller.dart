import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/services/api_service.dart';
import '../../../utils/date_utils.dart';

class MyBookingDetailsController extends GetxController {
  final String bookingId;
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;
  var booking = {}.obs; // whole booking data
  var serviceImages = <String>[].obs;

  MyBookingDetailsController({required this.bookingId});

  @override
  void onInit() {
    super.onInit();
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    try {
      isLoading.value = true;
      final response = await _apiService.get("bookings/$bookingId");
      print("my_response: $response");

      if (response['success'] == true && response['data'] != null) {
        booking.value = response['data'];

        final images = booking["service"]?["images"];
        if (images != null && images is List) {
          // Convert filenames to full URLs
          serviceImages.value = List<String>.from(images.map((img) {
            if (img.toString().startsWith("http")) {
              return img;
            } else {
              return "${_apiService.imageUrl}$img";
            }
          }));

          // Precache all images for smoother scrolling
          for (var url in serviceImages) {
            if (Get.context != null) {
              precacheImage(CachedNetworkImageProvider(url), Get.context!);
            }
          }
        }
      } else {
        Get.snackbar("Error", "Booking not found");
      }
    } catch (e) {
      print("Error loading booking details: $e");
      Get.snackbar("Error", "Failed to load booking details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------
  // GETTERS FOR UI
  // ----------------------
  String get serviceName => booking["service"]?["serviceType"] ?? "Unknown Service";
  String get categoryName => booking["service"]?["category"]?["name"] ?? "";
  String get providerName => booking["provider"]?["name"] ?? "Unknown Provider";
  String get providerEmail => booking["provider"]?["email"] ?? "";
/*  String get userName => booking["user"]?["name"] ?? "N/A";
  String get userEmail => booking["user"]?["email"] ?? "";
  String get userPhone => booking["user"]?["phone"] ?? "";*/

  String get date => AppDateUtils.formatToDDMMYY(booking["date"]);
  String get status => booking["status"] ?? "pending";
  String get description => booking["service"]?["description"] ?? "";
  String get price => booking["service"]?["price"]?.toString() ?? "0";


}
