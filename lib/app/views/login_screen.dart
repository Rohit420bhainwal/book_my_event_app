import 'package:bookmyevent/app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Make sure this is added in pubspec.yaml

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔹 App Logo
                  Center(
                    child: CircleAvatar(
                      radius: 72,
                      backgroundColor:
                      theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: const AssetImage(
                        'assets/images/book_my_event_logo.jpg',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 🔹 Title
                  Text(
                    "BookMyEvent",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 🔹 Username Field
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: "Email or Phone",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔹 Password Field
                  Obx(
                        () => TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible.value,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            isPasswordVisible.value =
                            !isPasswordVisible.value;
                          },
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Login Button
                  authController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final username = usernameController.text.trim();
                      final password = passwordController.text.trim();

                      if (username.isEmpty || password.isEmpty) {
                        Get.snackbar(
                          "Validation Error",
                          "Username and password cannot be empty",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor:
                          Colors.redAccent.withOpacity(0.8),
                          colorText: Colors.white,
                        );
                        return;
                      }

                      authController.login(username, password);
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔹 Forgot Password / Create Account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          authController.navigateToResetPasswordScreen();
                          // TODO: Forgot Password
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          authController.navigateToRegistrationScreen();
                        },
                        child: Text(
                          "Create New Account",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🔹 OR Divider
                  // Row(
                  //   children: [
                  //     const Expanded(child: Divider(thickness: 1)),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 8),
                  //       child: Text(
                  //         "OR",
                  //         style: TextStyle(
                  //           color: theme.colorScheme.onSurface.withOpacity(0.6),
                  //         ),
                  //       ),
                  //     ),
                  //     const Expanded(child: Divider(thickness: 1)),
                  //   ],
                  // ),
                  //
                  // const SizedBox(height: 20),
                  //
                  // // 🔹 Google & Facebook Login Buttons
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     _socialIconButton(
                  //       icon: FontAwesomeIcons.google,
                  //       color: Colors.redAccent,
                  //       onTap: () => authController.signInWithGoogle(),
                  //     ),
                  //     const SizedBox(width: 24),
                  //     _socialIconButton(
                  //       icon: FontAwesomeIcons.facebookF,
                  //       color: Colors.blueAccent,
                  //       onTap: () => authController.signInWithFacebook(),
                  //     ),
                  //   ],
                  // ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // 🔹 Social Icon Button Widget
  Widget _socialIconButton({
    required FaIconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: FaIcon(
          icon,
          color: color,
          size: 26,
        ),
      ),
    );
  }
}
