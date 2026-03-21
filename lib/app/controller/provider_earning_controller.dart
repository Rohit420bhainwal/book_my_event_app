import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class ProviderEarningController extends GetxController {
  ApiService apiService = ApiService();

  var isLoading = true.obs;

  var totalEarned = 0.0.obs;
  var totalWithdrawn = 0.0.obs;
  var available = 0.0.obs;
  var pending = 0.0.obs;

  var withdrawList = [].obs;

  /// 🔴 STRIPE FLAG
  var stripeOnboardingCompleted = false.obs;

  @override
  void onInit() async {
    super.onInit();

    final box = GetStorage();
    final userData = box.read("userData");

    stripeOnboardingCompleted.value =
        userData?["providerInfo"]?["stripeOnboardingCompleted"] ?? false;

    await loadEarnings();
    await loadWithdrawals();
  }

  Future<void> loadEarnings() async {
    try {
      isLoading.value = true;

      final response =
      await apiService.get("bookings/provider/earnings",
          withAuth: true);

      final data = response["data"];

      totalEarned.value = (data["totalEarned"] ?? 0).toDouble();
      totalWithdrawn.value = (data["withdrawn"] ?? 0).toDouble();
      available.value = (data["available"] ?? 0).toDouble();
      pending.value = (data["pending"] ?? 0).toDouble();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWithdrawals() async {
    final response =
    await apiService.get("withdraw/me", withAuth: true);
    withdrawList.value = response["data"]["withdraws"];
  }

  /// 🔴 STRIPE ONBOARDING
  Future<void> startStripeOnboarding() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final response = await apiService.post("provider/stripe/onboarding-link", {}, withAuth: true);
      print("onboarding_response $response");
      Get.back();

      final url = response["data"]["url"];
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Stripe onboarding failed");
    }
  }

  Future<void> requestWithdraw(int amount, String upiId) async {
    final body = {"amount": amount, "upiId": upiId};
    await apiService.post("withdraw", body, withAuth: true);
    loadEarnings();
    loadWithdrawals();
  }
}
