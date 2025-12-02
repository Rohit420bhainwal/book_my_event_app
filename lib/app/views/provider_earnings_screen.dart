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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () => _openWithdrawBottomSheet(context, controller),
        label: const Text("Withdraw", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
      ),
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
                  color: Colors.white,
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
                                style: AppTextStyles.subHeading
                                    .copyWith(color: theme.colorScheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _earningRow(
                            "Total Earned",
                            controller.totalEarned.value,
                            theme.colorScheme.primary),
                        _earningRow(
                            "Total Withdrawn", controller.totalWithdrawn.value, Colors.red),
                        _earningRow(
                          "Available Balance",
                          controller.available.value,
                          Colors.green,
                          isBold: true,
                          biggerText: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Text("Withdrawal History",
                    style: AppTextStyles.subHeading.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                /// ---------- Withdrawal List -----------
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

                    Color statusColor = w['status'] == "approved"
                        ? Colors.green
                        : w['status'] == "pending"
                        ? Colors.orange
                        : Colors.red;

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.15),
                          child: Icon(Icons.payments, color: statusColor),
                        ),
                        title: Text("₹${w['amount']}",
                            style: AppTextStyles.bodyBold),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("UPI ID: ${w['upiId']}", style: AppTextStyles.body),
                            const SizedBox(height: 4),
                            Text(
                              AppDateUtils.formatToDDMMYY(w['createdAt']),
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
                            w['status'].toString().toUpperCase(),
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

  /// ---------- Earnings Row Widget -----------
  Widget _earningRow(String title, int amount, Color color,
      {bool isBold = false, bool biggerText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body),
          Text(
            "₹$amount",
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

  /// ---------- Withdraw Bottom Sheet -----------
  void _openWithdrawBottomSheet(
      BuildContext context, ProviderEarningController controller) {
    final amountController = TextEditingController();
    final upiController = TextEditingController();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 20),
              Text("Request Withdraw",
                  style: AppTextStyles.subHeading
                      .copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: upiController,
                decoration: InputDecoration(
                  labelText: "UPI ID",
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    int amount = int.tryParse(amountController.text) ?? 0;

                    if (amount <= 0) {
                      Get.snackbar("Error", "Enter a valid amount");
                      return;
                    }
                    if (amount > controller.available.value) {
                      Get.snackbar("Error", "Amount exceeds available balance");
                      return;
                    }
                    if (upiController.text.trim().isEmpty) {
                      Get.snackbar("Error", "Enter UPI ID");
                      return;
                    }

                    Navigator.pop(context);
                    await controller.requestWithdraw(
                        amount, upiController.text.trim());
                  },
                  child: const Text("Submit Request",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
