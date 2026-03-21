import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class CommonProfileLayout extends StatelessWidget {
  final RxBool isLoading;
  final RxString photoUrl;
  final RxString displayName;
  final RxString email;
  final RxString phone;
  final RxString city;
  final RxString role;
  final RxString available;
  final VoidCallback onLogout;
  final VoidCallback? onEdit;

  const CommonProfileLayout({
    super.key,
    required this.isLoading,
    required this.photoUrl,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.city,
    required this.role,
    required this.available,
    required this.onLogout,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Obx(() {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            // Header Wave
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.8),
                          const Color(0xFF42A5F5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // Profile Info
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        backgroundImage: photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl.value)
                            : const AssetImage(
                          "assets/images/service_image_placeholder.png",
                        ) as ImageProvider,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayName.value.isNotEmpty
                            ? displayName.value
                            : "No Name",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.value.isNotEmpty ? email.value : "No Email",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 110),

            // Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoCard(context, Icons.phone, "Phone", phone.value),
                  const SizedBox(height: 10),
                  _buildInfoCard(context, Icons.location_city, "City", city.value),
                  const SizedBox(height: 10),
                  _buildInfoCard(context, Icons.email, "Email", email.value),
                  // if (role.value == "provider") ...[
                  //   const SizedBox(height: 10),
                  //   _buildInfoCard(
                  //     context,
                  //     Icons.money,
                  //     "Available Balance",
                  //     "₹ ${available.value}",
                  //     onTap: () => Get.toNamed(Routes.providerEarnings),
                  //   ),
                  // ],
                  const SizedBox(height: 20),

                  // Edit Profile
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.edit, color: primaryColor),
                      title: const Text("Edit Profile"),
                      subtitle: const Text("Update your name, photo, or info"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: onEdit ??
                              () {
                            Get.snackbar(
                              "Coming Soon",
                              "Edit profile feature will be added later.",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoCard(
      BuildContext context, IconData icon, String title, String value,{VoidCallback? onTap}) {
    final primaryColor = Theme.of(context).primaryColor;
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          value.isNotEmpty ? value : "Not Set",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

/// 🎨 Custom Wave Clipper
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 40,
    );
    path.quadraticBezierTo(
      3 / 4 * size.width,
      size.height - 80,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
