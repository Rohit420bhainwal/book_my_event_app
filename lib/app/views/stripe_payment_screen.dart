import 'package:bookmyevent/app/controller/stripe_payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class StripePaymentScreen extends StatelessWidget {
  StripePaymentScreen({super.key});

  final StripePaymentController controller = Get.put(StripePaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stripe Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Amount (₹)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Obx(
                  () => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                  controller.isLoading.value ? null : controller.payNow,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Pay Now"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
