import 'package:flutter/material.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import '../../../app/services/api_service.dart';
import '../../../utils/date_utils.dart';

class MyBookingDetailsController extends GetxController {
  final String bookingId;
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;
  var booking = {}.obs; // whole booking data
  var serviceImages = <String>[].obs;

  RxString reviewStatus = 'pending'.obs;

// When submitted
  RxInt submittedRating = 0.obs;
  RxString submittedReview = ''.obs;
  RxBool isReviewLoading = true.obs;


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
      print("response: $response");
      if (response['success'] == true && response['data'] != null) {
        booking.value = response['data'];
        reviewStatus.value = booking['reviewStatus'];
        print("reviewStatus.value ${reviewStatus.value}");
        final images = booking["service"]?["images"];
        if (images != null && images is List) {
          serviceImages.value = List<String>.from(images.map((img) =>
          img.toString().startsWith("http") ? img : "${_apiService.imageUrl}$img"));
          for (var url in serviceImages) {
            if (Get.context != null) precacheImage(NetworkImage(url), Get.context!);
          }
        }
        if(reviewStatus.value == "submitted"){
          fetchReviewById(booking['reviewId']);
        }
      } else {
        Get.snackbar("Error", "Booking not found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load booking details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReviewById(String reviewId) async{
    try {
      isReviewLoading.value = true;
      final response = await _apiService.get("reviews/$reviewId");
      print("Reviewresponse $response");
      if(response['success']==true){
        submittedRating.value = response['data']['rating'];
        submittedReview.value = response['data']['comment'];

      }

    }catch (e){

    }finally{
      isReviewLoading.value = false;
    }
  }


  Future<void> startPayment() async {
    try {
      final body = {
        "paymentType": "REMAINING",
        "bookingId": booking['_id'],
        "currency": "usd",
      };

      final response = await _apiService.post("bookings/payment-intent", body, withAuth: true);

      final clientSecret = response['data']['clientSecret'];
      final paymentIntentId = response['data']['paymentIntentId'];

      // await Stripe.instance.initPaymentSheet(
      //   paymentSheetParameters: SetupPaymentSheetParameters(
      //     paymentIntentClientSecret: clientSecret,
      //     merchantDisplayName: booking['provider']['businessName'],
      //     style: ThemeMode.light,
      //   ),
      // );
      //
      // await Stripe.instance.presentPaymentSheet();
      await saveFinalBooking(paymentIntentId);
    } catch (e) {
      print("Stripe Payment Error: $e");
      rethrow;
    }
  }

  Future<void> saveFinalBooking(String? paymentId) async {
    try {
      final response = await _apiService.post("bookings/confirm", {"paymentIntentId": paymentId}, withAuth: true);
      if (response["success"] == true) {
        booking['paymentStatus'] = 'fully_paid';
      } else {
        Get.snackbar("Error", "Failed to confirm booking");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to submit booking: $e");
    }
  }

  submitReview({required int rating, required String review, required bookingId}) async {
    try {
      isLoading.value = true;
      final body = {
        "bookingId": bookingId,
        "rating": rating,
        "comment": review
      };
      final response = await _apiService.post("reviews",body,withAuth: true);
      print("response $response");
      if(response['success'] == true){
        reviewStatus.value = "submitted";

        // 🔥 Keep booking map in sync (IMPORTANT)
        booking['reviewStatus'] = 'submitted';
        booking['reviewId'] = response['data']?['reviewId'];

        submittedRating.value = rating;
        submittedReview.value = review;

        // 🔥 Optional but recommended
       // await fetchReviewById(booking['reviewId']);

        Get.snackbar("Success", "Review submitted successfully");
      }else{
        Get.snackbar("Error", "Failed to submit the review");
      }


    } catch (e) {
      Get.snackbar("Error", "Failed to load booking details: $e");
    } finally {
      isLoading.value = false;
      isReviewLoading.value = false;
    }
  }


  // ----------------------
  // GETTERS FOR UI
  // ----------------------
  String get serviceName => booking["service"]?["serviceType"] ?? "Unknown Service";
  String get categoryName => booking["service"]?["category"]?["name"] ?? "";
  String get providerName => booking["provider"]?["name"] ?? "Unknown Provider";
  String get providerEmail => booking["provider"]?["email"] ?? "";
  String get date => AppDateUtils.formatToDDMMYY(booking["date"]);
  String get status => booking["status"] ?? "pending";
  String get description => booking["service"]?["description"] ?? "";
  String get price => booking["service"]?["price"]?.toString() ?? "0";


}
