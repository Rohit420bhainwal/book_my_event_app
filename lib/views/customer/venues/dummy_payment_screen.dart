import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/venues/booking_controller.dart';

class DummyPaymentScreen extends StatelessWidget {
  const DummyPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final venueId = args["venueId"];      // 🔹 Added
    final venueName = args["venueName"];
    final venueImage = args["venueImage"];
    final amount = args["amount"];
    final providerId = args["providerId"];

    final BookingController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Gateway"),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Booking: $venueName", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("Amount: ₹$amount",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                ),
                onPressed: () async {
                  // Show loading dialog
                  Get.dialog(const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false);

                  // Simulate payment delay
                  await Future.delayed(const Duration(seconds: 2));

                  // Close loader
                  Get.back();

                  // 🔹 Generate dummy txnId
                  final txnId = DateTime.now().millisecondsSinceEpoch.toString();

                  // Call booking controller with venueId
                  controller.bookVenue(
                    args
                   /* venueId: venueId,
                    venueName: venueName,
                    venueImage: venueImage,
                    txnId: txnId,
                    providerId: providerId,*/
                  );
                },
                child: const Text("Pay Now",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Get.back(result: false); // cancel
                },
                child: const Text("Cancel Payment",
                    style: TextStyle(color: Colors.red)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
