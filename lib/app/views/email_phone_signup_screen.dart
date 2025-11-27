import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import 'otp_verification_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmailPhoneSignupScreen extends StatefulWidget {
  const EmailPhoneSignupScreen({super.key});

  @override
  State<EmailPhoneSignupScreen> createState() => _EmailPhoneSignupScreenState();
}

class _EmailPhoneSignupScreenState extends State<EmailPhoneSignupScreen> {
  final ApiService apiService = ApiService();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isEmail = true; // toggle email/phone

  void _toggleInput(bool useEmail) {
    setState(() => isEmail = useEmail);
  }

  Future<void> _sendOtp() async {
    String input = isEmail ? emailController.text.trim() : phoneController.text.trim();
    String? password = isEmail ? passwordController.text.trim() : null;

    if (input.isEmpty) {
      Get.snackbar("Error", "Enter ${isEmail ? 'email' : 'phone number'}");
      return;
    }

    if (isEmail && (password == null || password.length < 6)) {
      Get.snackbar("Error", "Password must be at least 6 characters");
      return;
    }

    final body = {
      "input": input,
      "method": isEmail ? "email" : "phone",
      if (password != null) "password": password,
    };

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    final response = await apiService.post("auth/send-otp", body);
    print("response: ${response}");
    Get.back();

    if (response["success"] == true) {
     /* Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            input: input,
            method: isEmail ? "email" : "phone",
            password: password,
          ),
        ),
      );*/
    } else {
      Get.snackbar("Error", response["message"] ?? "Failed to send OTP");
    }
  }

  void _googleSignIn() {
    // TODO: Integrate Google Sign-In
  }

  void _facebookSignIn() {
    // TODO: Integrate Facebook Sign-In
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle Email / Phone
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Email"),
                  selected: isEmail,
                  onSelected: (_) => _toggleInput(true),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Phone"),
                  selected: !isEmail,
                  onSelected: (_) => _toggleInput(false),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Email / Phone Input
            if (isEmail)
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
            if (!isEmail)
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 15),

            // Password only for email signup
            if (isEmail)
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 20),

            // Send OTP Button
            ElevatedButton(
              onPressed: _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Send OTP",  style: TextStyle(fontSize: 16, color: Colors.white),)
            ),

            const SizedBox(height: 20),
            const Center(child: Text("Or sign up with")),
            const SizedBox(height: 10),

            // Google / Facebook
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(FontAwesomeIcons.google, color: Colors.red, size: 30),
                  onPressed: _googleSignIn,
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.facebook, color: Colors.blue, size: 30),
                  onPressed: _facebookSignIn,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
