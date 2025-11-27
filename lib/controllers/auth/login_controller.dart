import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../routes/app_routes.dart';



class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;

      if (user != null) {
        // Save user to users collection
        await _firestore.collection("users").doc(user.uid).set({
          "email": user.email,
          "name": user.displayName ?? "",
          "roles": ["customer", "provider"],
          "createdAt": DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        // Navigate to role/profile setup
        Get.offAllNamed(Routes.roleSelection);
      }
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void skipLogin() {
    Get.offAllNamed(Routes.roleSelection);
  }
}
