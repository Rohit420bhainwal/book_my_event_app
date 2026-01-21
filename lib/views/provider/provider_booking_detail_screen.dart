import 'package:bookmyevent/utils/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/provider_booking_detail_controller.dart';

class ProviderBookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const ProviderBookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderBookingDetailController());
    controller.fetchBookingDetail(bookingId);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("Booking Details",style: AppTextStyles.heading,),
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.booking.isEmpty) {
          return const Center(child: Text("Booking not found"));
        }

        final booking = controller.booking;
        final customer = booking['user'] ?? {};
        final service = booking['service'] ?? {};
        final status = booking['status'] ?? 'pending';
        final List<dynamic> images = service['images'] ?? [];

        final dateStr = booking['date'];
        final formattedDate = dateStr != null
            ? DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr))
            : '';

        Color statusColor;
        switch (status) {
          case 'confirmed':
            statusColor = Colors.green;
            break;
          case 'canceled':
            statusColor = Colors.red;
            break;
          case 'completed':
            statusColor = Colors.blueAccent;
            break;
          default:
            statusColor = Colors.orange;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (images.isNotEmpty) _buildImageCarousel(images),
              const SizedBox(height: 20),

              /// Title + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service['name'] ?? 'Service',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// Customer Info Card
              buildCard(
                title: "Customer Details",
                icon: Icons.person,
                iconColor: Colors.teal,
                children: [
                  _infoRow(Icons.account_circle, "Name", customer['name'] ?? '-'),
                  _infoRow(Icons.email, "Email", customer['email'] ?? '-'),
                  _infoRow(Icons.phone, "Phone", customer['phone'] ?? '-'),
                ],
              ),

              const SizedBox(height: 16),

              /// Service Info Card
              buildCard(
                title: "Service Details",
                icon: Icons.room_service,
                iconColor : Colors.orange,
                children: [
                  _infoRow(Icons.calendar_today, "Date", formattedDate),
                  _infoRow(Icons.location_city, "City",
                      booking['provider']['city'] ?? '-'),
                  _infoRow(Icons.currency_rupee, "Price",
                      service['price']?.toString() ?? '-'),
                ],
              ),

              const SizedBox(height: 16),

              /// ⭐ RECEIPT CARD
              /// ⭐ RECEIPT CARD
              paymentReceiptCard(booking),

              const SizedBox(height: 20),

              /// ✅ COMPLETE BOOKING BUTTON
              if (booking['status'] == 'confirmed' &&
                  booking['paymentStatus'] == 'fully_paid')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await controller.completeBooking(booking['_id']);
                      if(controller.apiMessage.value.isNotEmpty){
                        Get.dialog(
                          Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // <-- important
                                children: [
                                  Text(
                                    controller.apiMessage.value,
                                    style: AppTextStyles.bodyBold,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity, // makes button take full width
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF3F51B5), // professional primary color
                                        padding: const EdgeInsets.symmetric(vertical: 14), // taller for tap target
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12), // smooth corners
                                        ),
                                        elevation: 2, // subtle shadow
                                      ),
                                      child: Text(
                                        "OK",
                                        style: AppTextStyles.bodyBoldWhite,
                                        // style: TextStyle(
                                        //   color: Colors.white,
                                        //   fontWeight: FontWeight.bold,
                                        //   fontSize: 16,
                                        // ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                          barrierDismissible: false, // optional: prevent dismiss on outside tap
                        );

                      }
                    },
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text(
                      "Complete Booking",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              /// 💰 PAYOUT SECTION (ONLY AFTER COMPLETION)
              if (booking['status'] == 'completed') ...[
                const SizedBox(height: 16),
                payoutSection(booking, controller),
              ],


              /// 💰 PAYOUT SECTION (NEW – NON-BREAKING)
            //  payoutSection(booking, controller),

              const SizedBox(height: 30),


              /// Action Buttons
              if (status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.updateBookingStatus(
                            bookingId, 'confirmed'),
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.white),
                        label: const Text(
                          "Accept",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.cancelBooking(bookingId, 'canceled'),
                        icon: const Icon(Icons.cancel_outlined,
                            color: Colors.white),
                        label: const Text(
                          "Reject",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }


  Widget payoutSection(Map booking, ProviderBookingDetailController controller) {
    final payoutStatus = booking['payoutStatus']; // pending | available | requested | withdrawn
    final payoutReleaseDateStr = booking['payoutReleaseDate'];
    final status = booking['status'];

    DateTime? payoutReleaseDate;
    if (payoutReleaseDateStr != null) {
      payoutReleaseDate = DateTime.parse(payoutReleaseDateStr).toLocal();
    }

    final bool canWithdraw =
        status == 'completed' &&
            payoutStatus == 'available' &&
            payoutReleaseDate != null &&
            (DateTime.now().isAfter(payoutReleaseDate) ||
                DateTime.now().isAtSameMomentAs(payoutReleaseDate));

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.account_balance_wallet, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Payout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ✅ Withdrawn
            if (payoutStatus == 'withdrawn')
              const Text(
                "✅ Payment withdrawn successfully",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              )

            /// 🕒 Requested
            else if (payoutStatus == 'requested')
              const Text(
                "🕒 Withdrawal request submitted.\nYou will receive payment shortly.",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              )

            /// 🟢 Withdraw Button
            else if (canWithdraw)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.withdrawPayout(booking['_id']),
                    icon: const Icon(Icons.payments, color: Colors.white),
                    label: const Text(
                      "Withdraw Amount",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )

              /// 🔒 Locked
              else
                Text(
                  payoutReleaseDate != null
                      ? "🔒 Payout will be available on ${DateFormat('dd MMM yyyy').format(payoutReleaseDate)}"
                      : "🔒 Payout not available yet",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
          ],
        ),
      ),
    );
  }


  // ------------------------
  // IMAGE CAROUSEL
  // ------------------------
  Widget _buildImageCarousel(List<dynamic> images) {
    final pageController = PageController();
    final currentPage = ValueNotifier<int>(0);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: pageController,
            itemCount: images.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 60),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        ValueListenableBuilder<int>(
          valueListenable: currentPage,
          builder: (_, value, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                bool isActive = index == value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            );
          },
        )
      ],
    );
  }

  // ------------------------
  // GENERIC INFO ROW
  // ------------------------
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------
  // GENERIC CARD BUILDER
  // ------------------------
  Widget buildCard(
      {required String title,
        required IconData icon,
        Color iconColor = Colors.black,
        required List<Widget> children}) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  // ------------------------
  // PROFESSIONAL RECEIPT CARD
  // ------------------------
  Widget paymentReceiptCard(Map booking) {
    final totalAmount =
        (booking['totalAmount'] as num?)?.toDouble() ?? 0;
    final paidAmount =
        (booking['paidAmount'] as num?)?.toDouble() ?? 0;
    final remainingAmount =
        (booking['remainingAmount'] as num?)?.toDouble() ?? 0;

    final commissionAmount =
        (booking['commissionAmount'] as num?)?.toDouble() ?? 0;
    final providerEarning =
        (booking['providerEarning'] as num?)?.toDouble() ?? 0;

    final commissionType = booking['commissionType'] ?? 'percentage';
    final commissionValue = booking['commissionValue'] ?? 0;
    final paymentStatus = booking['paymentStatus'] ?? 'pending';

    Color statusColor;
    String statusText;

    if (paymentStatus == 'fully_paid') {
      statusColor = Colors.green;
      statusText = "Fully Paid";
    } else if (paymentStatus == 'partially_paid') {
      statusColor = Colors.orange;
      statusText = "Advance Paid";
    } else {
      statusColor = Colors.red;
      statusText = "Payment Pending";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.receipt_long,
                      color: Colors.deepPurple, size: 26),
                  SizedBox(width: 10),
                  Text(
                    "Payment Receipt",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          buildDashedDivider(),
          const SizedBox(height: 14),

          /// PAYMENT SUMMARY
          receiptRow("Total Amount",
              "₹${totalAmount.toStringAsFixed(2)}"),

          receiptRow(
            "Amount Paid",
            "₹${paidAmount.toStringAsFixed(2)}",
            isBold: true,
          ),

          receiptRow(
            "Remaining Amount",
            "₹${remainingAmount.toStringAsFixed(2)}",
            isBold: true,
            valueColor:
            remainingAmount == 0 ? Colors.green : Colors.redAccent,
          ),

          const SizedBox(height: 14),
          buildDashedDivider(),
          const SizedBox(height: 14),

          /// COMMISSION SECTION
          Row(
            children: const [
              Icon(Icons.account_balance,
                  size: 18, color: Colors.orange),
              SizedBox(width: 6),
              Text(
                "Commission Breakdown",
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 8),

          receiptRow(
            "Platform Commission (${commissionType == 'percentage' ? '$commissionValue%' : 'Fixed'})",
            "- ₹${commissionAmount.toStringAsFixed(2)}",
            valueColor: Colors.redAccent,
          ),

          receiptRow(
            "Provider Will Receive",
            "₹${providerEarning.toStringAsFixed(2)}",
            isBold: true,
            valueColor: Colors.green,
          ),

          const SizedBox(height: 14),
          buildDashedDivider(),
          const SizedBox(height: 10),

          /// FOOTER NOTE
          Center(
            child: Text(
              remainingAmount == 0
                  ? "Payment completed. Payout will be processed as per policy."
                  : "Remaining amount must be collected before service date.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }



  // Receipt Row
  Widget receiptRow(
      String label,
      String value, {
        bool isBold = false,
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }


  // Dashed Divider
  Widget buildDashedDivider() {
    return LayoutBuilder(builder: (context, constraints) {
      final dashWidth = 6.0;
      final dashHeight = 1.5;
      final dashCount = (constraints.maxWidth / (dashWidth * 2)).floor();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(dashCount, (_) {
          return Container(
            width: dashWidth,
            height: dashHeight,
            color: Colors.grey.shade400,
          );
        }),
      );
    });
  }
}
