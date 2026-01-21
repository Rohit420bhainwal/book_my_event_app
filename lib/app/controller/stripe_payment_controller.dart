import 'package:bookmyevent/app/services/stripe_payment_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api_service.dart';


class StripePaymentController extends GetxController {
  final TextEditingController amountController = TextEditingController();
  final RxBool isLoading = false.obs;
  final ApiService apiService = ApiService();

  void payNow() async {
    if (amountController.text.isEmpty) {
      Get.snackbar("Error", "Please enter amount");
      return;
    }

    final int amount = int.parse(amountController.text) * 100;

    try {
      isLoading.value = true;
      await StripePaymentService.makePayment(amount,apiService);
      Get.snackbar("Success", "Payment completed successfully");
      amountController.clear();
    } catch (e) {
      print("Payment Failed: ${e}");
      Get.snackbar("Payment Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
