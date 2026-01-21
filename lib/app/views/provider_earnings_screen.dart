import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/date_utils.dart';
import '../controller/provider_earning_controller.dart';

class ProviderEarningsScreen extends StatelessWidget {
  const ProviderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderEarningController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text("My Earnings", style: AppTextStyles.heading),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0.3,
        foregroundColor: Colors.white,
      ),

      /// 🔴 STRIPE-AWARE BUTTON
      floatingActionButton: Obx(() {
        return FloatingActionButton.extended(
          backgroundColor: theme.colorScheme.primary,
          onPressed: () {
            if (!controller.stripeOnboardingCompleted.value) {
              controller.startStripeOnboarding();
            } else {
              _openWithdrawBottomSheet(context, controller);
            }
          },
          label: Text(
            controller.stripeOnboardingCompleted.value
                ? "Withdraw"
                : "Complete Stripe Setup",
            style: const TextStyle(color: Colors.white),
          ),
          icon: Icon(
            controller.stripeOnboardingCompleted.value
                ? Icons.account_balance_wallet
                : Icons.link,
            color: Colors.white,
          ),
        );
      }),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadEarnings(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ---------- Earnings Summary Card -----------
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet,
                                color: theme.colorScheme.primary, size: 30),
                            const SizedBox(width: 10),
                            Text("Earnings Summary",
                                style: AppTextStyles.subHeading.copyWith(
                                    color: theme.colorScheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _earningRow("Total Earned",
                            controller.totalEarned.value,
                            theme.colorScheme.primary),
                        _earningRow("Pending To Withdraw",
                            controller.pending.value,
                            Colors.orangeAccent),
                        _earningRow("Total Withdrawn",
                            controller.totalWithdrawn.value,
                            Colors.red),
                        _earningRow("Available Balance",
                            controller.available.value,
                            Colors.green,
                            isBold: true,
                            biggerText: true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Text("Withdrawal History",
                    style: AppTextStyles.subHeading
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                controller.withdrawList.isEmpty
                    ? Center(
                    child: Text("No withdrawal requests yet",
                        style: AppTextStyles.body))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.withdrawList.length,
                  itemBuilder: (context, index) {
                    final w = controller.withdrawList[index];

                    Color statusColor =
                    w['status'] == "approved"
                        ? Colors.green
                        : w['status'] == "pending"
                        ? Colors.orange
                        : Colors.red;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          statusColor.withOpacity(0.15),
                          child:
                          Icon(Icons.payments, color: statusColor),
                        ),
                        title: Text("₹${w['amount']}",
                            style: AppTextStyles.bodyBold),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("UPI ID: ${w['upiId']}",
                                style: AppTextStyles.body),
                            const SizedBox(height: 4),
                            Text(
                              AppDateUtils.formatToDDMMYY(
                                  w['createdAt']),
                              style: AppTextStyles.bodyBold13,
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            w['status']
                                .toString()
                                .toUpperCase(),
                            style: AppTextStyles.small
                                .copyWith(color: statusColor),
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  /// ---------- Earnings Row ----------
  Widget _earningRow(String title, double amount, Color color,
      {bool isBold = false, bool biggerText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: isBold
                ? AppTextStyles.bodyBold.copyWith(
                fontSize: biggerText ? 22 : 16, color: color)
                : AppTextStyles.body.copyWith(
                fontSize: biggerText ? 20 : 16, color: color),
          ),
        ],
      ),
    );
  }

  /// ---------- Withdraw Sheet ----------
  void _openWithdrawBottomSheet(
      BuildContext context, ProviderEarningController controller) {
    final amountController = TextEditingController();
    final upiController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: upiController,
                decoration: const InputDecoration(labelText: "UPI ID"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  int amount =
                      int.tryParse(amountController.text) ?? 0;

                  if (amount <= 0 ||
                      upiController.text.trim().isEmpty) {
                    Get.snackbar("Error", "Invalid details");
                    return;
                  }

                  Navigator.pop(context);
                  await controller.requestWithdraw(
                      amount, upiController.text.trim());
                },
                child: const Text("Submit"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
