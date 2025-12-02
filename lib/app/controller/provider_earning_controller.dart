import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api_service.dart';

class ProviderEarningController extends GetxController {
  ApiService apiService = ApiService();

  var isLoading = true.obs;

  var totalEarned = 0.obs;
  var totalWithdrawn = 0.obs;
  var available = 0.obs;

  var withdrawList = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadEarnings();
  }

  Future<void> loadEarnings() async {
    try {
      isLoading.value = true;

      final response = await apiService.get("withdraw/me", withAuth: true);

      final data = response["data"];

      totalEarned.value = data["earnings"]["totalEarned"];
      totalWithdrawn.value = data["earnings"]["totalWithdrawn"];
      available.value = data["earnings"]["available"];

      withdrawList.value = data["withdraws"];

    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestWithdraw(int amount, String upiId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final body = {
        "amount": amount,
        "upiId": upiId,
      };

      final response = await apiService.post("withdraw", body, withAuth: true);

      Get.back();

      if (response["success"] == true) {
        Get.snackbar("Success", "Withdrawal request submitted");
        loadEarnings();
      } else {
        Get.snackbar("Error", response["message"]);
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString());
    }
  }
}
