import 'package:bookmyevent/app/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProviderBookingDetailController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var booking = <String, dynamic>{}.obs;
  var successStatus = false.obs;
  var apiMessage = "".obs;

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

  Future<void> cancelBooking(String bookingId, String status) async{
    try {
      isLoading.value = true;
      final response = await _apiService.post("bookings/provider/$bookingId/cancel", {}, withAuth: true,);
      if (response['success'] == true) {
        booking['status'] = status;
        booking.refresh();
        Get.snackbar("Success", "Booking ${status == 'Cancelled'} successfully");
      }

    }catch (e) {
      Get.snackbar("Error", "Failed to update booking: $e");
      print("Error in updateBookingStatus: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> withdrawPayout(String bookingId) async {
    final double providerEarning =
    (booking['providerEarning'] as num).toDouble();

    print("providerEarning $providerEarning");
    print("bookingId $bookingId");

    try {
      isLoading.value = true;

      final body = {
        "bookingId":bookingId,
        "upiId":'provider@upi',
      };

      final response = await _apiService.post(
        "bookings/requestWithdraw",
        body,
        withAuth: true,
      );

      print("response $response");

      if (response['success'] == true) {
        booking['payoutStatus'] = 'requested';
        booking.refresh();

        Get.snackbar(
          "Success",
          "Payment withdrawn successfully",
        );
      } else {
        Get.snackbar("Error", "Unable to withdraw payment");
      }
    } catch (e) {
      Get.snackbar("Error", "Withdrawal failed");
      print("Withdraw error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeBooking(String bookingId) async {
    try {
      isLoading.value = true;

      final res = await _apiService.post('bookings/$bookingId/complete',{},withAuth: true,);
      print("res $res");

      if (res['success'] == true) {
        apiMessage.value = res['data']['message'];
        fetchBookingDetail(bookingId);

        // Get.snackbar(
        //   "Success",
        //   "Booking marked as completed",
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
      }else{
        apiMessage.value = res['message'];
        // Get.snackbar(
        //     "Fail",
        //     "${res['message']}",
        //     backgroundColor: Colors.green,
        //     colorText: Colors.white,);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to complete booking");
    } finally {
      isLoading.value = false;
    }
  }


}
