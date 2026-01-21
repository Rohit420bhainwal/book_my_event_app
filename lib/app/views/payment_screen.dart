import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../controllers/venues/booking_controller.dart';

// 🔹 Payment choice enum (same as controller)


class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> venue;
  final int amount;
  final DateTime selectedDate;
  final String selectedSlot;
  final PaymentChoice paymentChoice;

  const PaymentScreen({
    super.key,
    required this.venue,
    required this.amount,
    required this.selectedDate,
    required this.selectedSlot,
    required this.paymentChoice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final controller = Get.find<BookingController>();

  final paymentStatus = 0.obs; // 0 = processing, 1 = success, 2 = failed
  final bookingMessage = "".obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), startPayment);
  }

  Future<void> startPayment() async {
    try {
      paymentStatus.value = 0;

      final bookingDateIso = widget.selectedDate.toUtc().toIso8601String();

      final paymentType =
      widget.paymentChoice == PaymentChoice.full ? "FULL" : "ADVANCE";
      print("paymentType: $paymentType");

      final body = {
        "paymentType": paymentType,
        "providerId": widget.venue['providerId'],
        "serviceId": widget.venue['id'],
        "date": bookingDateIso,
        "slot": widget.selectedSlot,
        "currency": "usd",
      };

      // 1️⃣ Create PaymentIntent
      final response = await controller.api.post(
        "bookings/payment-intent",
        body,
        withAuth: true,
      );

      final clientSecret = response['data']['clientSecret'];
      final paymentIntentId = response['data']['paymentIntentId'];

      // 2️⃣ Init Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: widget.venue['businessName'],
          style: ThemeMode.light,
        ),
      );

      // 3️⃣ Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      paymentStatus.value = 1;

      // 4️⃣ Confirm booking
      await controller.saveFinalBooking(
        widget.venue,
        paymentIntentId,
        onMessage: (msg) => bookingMessage.value = msg,
      );
    } catch (e) {
      debugPrint("Stripe Payment Error: $e");
      paymentStatus.value = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Payment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (paymentStatus.value == 0) {
          return Column(
            children: [
              _amountSummary(), // 👈 HERE
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }
        if (paymentStatus.value == 1) return _successUI();
        return _failedUI();
      }),
    );
  }

  // =========================
  // 💰 AMOUNT SUMMARY UI
  // =========================
  Widget _amountSummary() {
    final total = widget.amount;
    final advance = (total * 0.25).round();

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Summary",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _row("Total Amount", "₹$total"),
            const SizedBox(height: 8),
            if (widget.paymentChoice == PaymentChoice.advance)
              _row("Pay Now (25%)", "₹$advance"),
            if (widget.paymentChoice == PaymentChoice.full)
              _row("Pay Now (100%)", "₹$total"),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // =========================
  // ✅ SUCCESS UI
  // =========================
  Widget _successUI() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded,
            size: 130, color: Colors.green),
        const SizedBox(height: 20),
        const Text(
          "Payment Successful!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => Text(bookingMessage.value)),
      ],
    ),
  );

  // =========================
  // ❌ FAILED UI
  // =========================
  Widget _failedUI() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_rounded,
            size: 130, color: Colors.red),
        const SizedBox(height: 20),
        const Text(
          "Payment Failed",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: startPayment,
          child: const Text("Retry"),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel"),
        ),
      ],
    ),
  );
}
