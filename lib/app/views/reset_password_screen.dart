import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_text_styles.dart';
import '../controller/reset_password_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResetPasswordController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text("Reset Password", style: AppTextStyles.subHeading),
        backgroundColor: theme.primaryColor,
        elevation: 1,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------------- STEP INDICATOR ----------------
              _stepIndicator(controller),

              const SizedBox(height: 25),

              // ---------------- CARD WRAPPER ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: _buildCurrentStep(controller),
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- BUTTON ----------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => controller.nextStep(),
                  child: Text(
                    controller.buttonText(),
                    style: AppTextStyles.bodyBold.copyWith(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ---------------- STEP UI HANDLER ----------------
  Widget _buildCurrentStep(ResetPasswordController controller) {
    if (controller.step.value == 1) return _emailStep(controller);
    if (controller.step.value == 2) return _otpStep(controller);
    return _newPasswordStep(controller);
  }

  // ---------------- STEP INDICATOR ----------------
  Widget _stepIndicator(ResetPasswordController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(controller.titleText(), style: AppTextStyles.heading),
        const SizedBox(height: 10),

        LinearProgressIndicator(
          value: controller.step.value / 3,
          color: Colors.blue,
          backgroundColor: Colors.blue.withOpacity(0.15),
          minHeight: 5,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  // ---------------- EMAIL STEP ----------------
  Widget _emailStep(ResetPasswordController controller) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Enter your registered email", style: AppTextStyles.body),
        const SizedBox(height: 12),

        TextField(
          controller: controller.emailController,
          decoration: _inputDecoration("Email", Icons.email_outlined),
        ),
      ],
    );
  }

  // ---------------- OTP STEP ----------------
  Widget _otpStep(ResetPasswordController controller) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Enter the OTP sent to your email", style: AppTextStyles.body),
        const SizedBox(height: 12),

        TextField(
          controller: controller.otpController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration("OTP", Icons.lock_clock_outlined),
        ),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => controller.resendOtp(),
            child: Text("Resend OTP", style: AppTextStyles.bodyBold),
          ),
        ),
      ],
    );
  }

  // ---------------- NEW PASSWORD STEP ----------------
  Widget _newPasswordStep(ResetPasswordController controller) {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Set your new password", style: AppTextStyles.body),
        const SizedBox(height: 12),

        Obx(() {
          return TextField(
            controller: controller.newPassword,
            obscureText: controller.hideNewPassword.value,
            decoration: _passwordDecoration(
              "New Password",
              Icons.lock_outline,
              controller.hideNewPassword.value,
                  () => controller.hideNewPassword.toggle(),
            ),
          );
        }),

        const SizedBox(height: 16),

        Obx(() {
          return TextField(
            controller: controller.confirmPassword,
            obscureText: controller.hideConfirmPassword.value,
            decoration: _passwordDecoration(
              "Confirm Password",
              Icons.lock_person_outlined,
              controller.hideConfirmPassword.value,
                  () => controller.hideConfirmPassword.toggle(),
            ),
          );
        }),
      ],
    );
  }

  // ---------------- INPUT DECORATORS ----------------

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _passwordDecoration(
      String label, IconData icon, bool hidden, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
        onPressed: toggle,
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
