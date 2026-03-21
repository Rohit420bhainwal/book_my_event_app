import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/dashboard/bookings/my_booking_detail_controller.dart';

class MyBookingDetailsScreen extends StatelessWidget {
  MyBookingDetailsScreen({super.key});

  final PageController pageController = PageController(keepPage: true);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final bookingId = args["bookingId"] ?? "";

    final controller = Get.put(MyBookingDetailsController(bookingId: bookingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildImageCarousel(controller),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      controller.serviceName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F51B5),
                        height: 1.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildStatusChip(controller.status),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoCard(controller),
              _buildProviderCard(controller),
              if (controller.description.isNotEmpty)
                _buildDescriptionCard(controller),
              if (controller.booking['paymentStatus'] == 'advance_paid' &&
                  controller.booking['status'] != 'cancelled')
                _buildAdvancePaidCard(context, controller),
              const Divider(height: 30, thickness: 0.6),
              if(controller.booking['status']=="completed")
                _buildReviewCard(context, controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewCard(
      BuildContext context, MyBookingDetailsController controller) {

    final rating = 0.obs;
    final reviewController = TextEditingController();
    final isSubmitting = false.obs;

    return Obx(() {
      final reviewStatus = controller.reviewStatus.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: reviewStatus == "submitted"
            ? _buildSubmittedReview(controller)
            : _buildPendingReview(
          controller,
          rating,
          reviewController,
          isSubmitting,
        ),
      );
    });

  }

  Widget _buildSubmittedReview(MyBookingDetailsController controller) {
    if (controller.isReviewLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Review",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3F51B5),
          ),
        ),
        const SizedBox(height: 12),

        /// STARS
        Row(
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 28,
              color: controller.submittedRating.value > index
                  ? Colors.amber
                  : Colors.grey.shade300,
            );
          }),
        ),

        const SizedBox(height: 12),

        /// REVIEW TEXT
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            controller.submittedReview.value.isEmpty
                ? "No written review"
                : controller.submittedReview.value,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingReview(
      MyBookingDetailsController controller,
      RxInt rating,
      TextEditingController reviewController,
      RxBool isSubmitting,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rate & Review",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3F51B5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Your feedback helps us improve our service",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),

        const SizedBox(height: 16),

        /// STAR SELECTION
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => rating.value = starIndex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.star,
                  size: 36,
                  color: rating.value >= starIndex
                      ? Colors.amber
                      : Colors.grey.shade300,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        /// REVIEW INPUT
        TextField(
          controller: reviewController,
          maxLines: 4,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: "Write your experience (optional)",
            filled: true,
            fillColor: const Color(0xFFF7F8FC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// SUBMIT BUTTON
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: rating.value == 0
                  ? Colors.grey.shade400
                  : const Color(0xFF3F51B5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: rating.value == 0 || isSubmitting.value
                ? null
                : () async {
              isSubmitting.value = true;
              try {
                await controller.submitReview(
                  rating: rating.value,
                  review: reviewController.text.trim(),
                  bookingId : controller.booking['_id'],
                );
              } finally {
                isSubmitting.value = false;
              }
            },
            child: isSubmitting.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "SUBMIT REVIEW",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(MyBookingDetailsController controller) {
    final pageController = PageController();
    final currentPage = ValueNotifier<int>(0);
    final images = controller.serviceImages;

    if (images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: pageController,
            itemCount: images.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              return AnimatedBuilder(
                animation: pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (pageController.position.haveDimensions) {
                    value = pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0);
                  }
                  return Transform.scale(
                    scale: value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<int>(
          valueListenable: currentPage,
          builder: (context, value, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = value == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isActive ? 20 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blueAccent : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------
  // STATUS CHIP
  // ---------------------------
  Widget _buildStatusChip(String status) {
    Color start, end;
    switch (status) {
      case "confirmed":
        start = Colors.greenAccent;
        end = Colors.green;
        break;
      case "canceled":
        start = Colors.redAccent;
        end = Colors.red;
        break;
      case "completed":
        start = Colors.blue.shade300;
        end = Colors.blueAccent;
      default:
        start = Colors.orangeAccent;
        end = Colors.deepOrange;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // ---------------------------
  // BOOKING INFO CARD
  // ---------------------------
  Widget _buildInfoCard(MyBookingDetailsController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F6FA), Color(0xFFE9EBF3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6, offset: const Offset(2, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.category_outlined, "Category", controller.categoryName),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.currency_rupee, "Price", "₹${controller.price}"),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.date_range_outlined, "Date", controller.date),
        ],
      ),
    );
  }

  // ---------------------------
  // PROVIDER CARD
  // ---------------------------
  Widget _buildProviderCard(MyBookingDetailsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 4, offset: const Offset(2, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF3F51B5), Color(0xFF5A65E0)]),
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.person, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.providerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text(controller.providerEmail,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // DESCRIPTION CARD
  // ---------------------------
  Widget _buildDescriptionCard(MyBookingDetailsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6, offset: const Offset(2, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5))),
          const SizedBox(height: 8),
          Text(controller.description,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }

  // ---------------------------
  // GENERIC DETAIL ROW
  // ---------------------------
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: "$title: ",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black87),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  // ---------------------------
  // ADVANCE PAID CARD
  // ---------------------------
  Widget _buildAdvancePaidCard(BuildContext context, MyBookingDetailsController controller) {
    final remaining = controller.booking['remainingAmount'] ?? 0;
    final isProcessing = false.obs;

    return Obx(() => _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment Details",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F51B5)),
          ),
          const SizedBox(height: 12),
          _row("Total", "₹${controller.booking['totalAmount']}"),
          _row("Advance Paid",
              "₹${controller.booking['advanceAmount']}"),
          const Divider(),
          _row(
            "Remaining",
            "₹$remaining",
            valueColor: Colors.redAccent,
            valueSize: 18,
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: remaining > 0 && !isProcessing.value
                  ? () async {
                try {
                  isProcessing.value = true;
                  await controller.startPayment();

                  // ✅ SHOW SUCCESS UI FROM SCREEN
                  _showPaymentSuccessSheet(
                    context: context,
                    amount: remaining,
                    bookingId: controller.booking['_id'],
                  );
                } catch (e) {
                  Get.snackbar("Payment Failed", e.toString());
                } finally {
                  isProcessing.value = false;
                }
              }
                  : null,
              child: isProcessing.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "PAY REMAINING AMOUNT",
                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // ---------------- SUCCESS BOTTOM SHEET ----------------
  void _showPaymentSuccessSheet({
    required BuildContext context,
    required int amount,
    required String bookingId,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  color: Colors.green, size: 72),
              const SizedBox(height: 12),
              const Text(
                "Payment Successful",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("₹$amount paid successfully",
                  style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 12),
              _row("Booking ID", bookingId),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                  ),
                  child: const Text("DONE",style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- COMMON WIDGETS ----------------
  Widget _row(String title, String value,
      {Color? valueColor, double valueSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: valueSize,
                color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: child,
    );
  }

}
/*Widget _buildPaymentRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}*/
