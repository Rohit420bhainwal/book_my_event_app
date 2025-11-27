import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../controllers/venues/booking_controller.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> venue;
  final int amount;

  const PaymentScreen({super.key, required this.venue, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay razorpay;
  final controller = Get.find<BookingController>();

  var paymentStatus = 0.obs; // 0=processing,1=success,2=failed
  var bookingMessage = "".obs;

  @override
  void initState() {
    super.initState();

    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    Future.delayed(const Duration(milliseconds: 300), openCheckout);
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_icz3AXfa29RYVn",
      "amount": widget.amount * 100,
      "name": widget.venue['businessName'],
      "description": "Venue Booking",
      "prefill": {"contact": "9876543210", "email": "user@example.com"},
      "theme": {"color": "#3F51B5"}
    };
    razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    paymentStatus.value = 1;

    await Future.delayed(const Duration(seconds: 1));
    await controller.saveFinalBooking(widget.venue, response.paymentId,onMessage: (msg) {
      bookingMessage.value = msg;   // <-- update UI
    },);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    paymentStatus.value = 2;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar("Wallet Selected", response.walletName!);
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
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
        if (paymentStatus.value == 0) return _processingUI();
        if (paymentStatus.value == 1) return _successUI();
        return _failedUI();
      }),
    );
  }

  // -------------------- PROFESSIONAL UI -------------------- //

  Widget _processingUI() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: const Color(0xFF3F51B5),
              strokeWidth: 4,
            ),
            const SizedBox(height: 20),
            const Text(
              "Processing Payment...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Please wait while we securely process your payment",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _successUI() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 130, color: Colors.green.shade600),
            const SizedBox(height: 20),

            const Text(
              "Payment Successful!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 👇 NEW MESSAGE BELOW PAYMENT STATUS
            Obx(() => Text(
              bookingMessage.value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            )),
          ],
        ),
      ),
    );
  }

  Widget _failedUI() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_rounded, size: 130, color: Colors.red.shade700),
            const SizedBox(height: 20),
            const Text(
              "Payment Failed",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Something went wrong. Please try again.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                paymentStatus.value = 0;
                openCheckout();
              },
              child: const Text("Retry Payment", style: TextStyle(fontSize: 16,color: Colors.white)),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
