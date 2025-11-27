import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../routes/app_routes.dart';
import '../services/api_service.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ApiService _apiService = ApiService();
  var isLoading = false.obs;
  var token = "".obs;
  var roleName = "".obs;
  var onboardingComplete = false;
  var status = "";

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    final response = await _apiService.loginUser(
      username: username,
      password: password,
    );
    isLoading.value = false;

    if (response != null) {

      token.value = response["token"] ?? "";

      var userId = response["user"]["id"];
      final role =response["user"]["role"]??"";
      roleName.value  = response["user"]["role"]??"";

      final providerInfo = response["providerInfo"]??"";
      status = providerInfo["status"]??"";
      onboardingComplete = providerInfo["onboardingComplete"]??false;


      final box = GetStorage();
      await box.write("userData", response);
      final providerIncomplete = box.read("providerOnboardingIncomplete") ?? true;

      token.value = (response["token"] ?? "").toString();
      List<dynamic> menuList = response["menuList"] as List<dynamic>? ?? [];

     if (role == null || role.isEmpty) {
        print("response_2: HERE");
        Get.offAllNamed(Routes.roleSelection,
            arguments: {"userId": userId, "token": token});
      }else if (role == "provider" && status =="pending"&& !onboardingComplete) {
        print("response_3: HERE");
        Get.offAllNamed(Routes.providerOnboarding,
            arguments: {"userId": userId});
      } else if(role == "provider" && status =="pending"&& onboardingComplete){
        print("response_4: HERE");
        Get.offAllNamed(Routes.pendingApprovalScreen, arguments: {"userId": userId});
      }else if (role == "provider" && status =="approved") {
        print("response_5: HERE");

        Get.offAllNamed(Routes.providerDashboard, arguments: {
          "menuList": menuList,
          "userId": userId,
          "roleName": role,
          "token": token.value,
        });

        /*Get.offAllNamed(Routes.providerDashboard, arguments: {
          "menuList": menuList,
          "userId": userId,
          "roleName": role,
          "token": token,
        });*/
      } else if (role == "customer") {
        print("response_6: HERE");
        Get.offAllNamed(Routes.customerDashboard, arguments: {
          "menuList": menuList,
          "userId": userId,
          "roleName": role,
          "token": token.value,
        });
      }
      Get.snackbar("Success", "Logged in as ${roleName.value}");
    } else {
      Get.snackbar("Error", "Invalid username or password");
    }
  }

  void navigateToNextScreen(String dashboard, Map<String, dynamic> response){
    List<dynamic> menuList = response["menuList"] as List<dynamic>? ?? [];

    Get.offAllNamed(
      dashboard,
      arguments: {
        "menuList": menuList,
        "userId": response["userId"],
        "roleName": response["roleName"],
        "token":response["token"],
      },
    );
  }

  void navigateToRegistrationScreen(){
    Get.offAllNamed(
      Routes.registrationScreen
      /*Routes.emailPhoneSignup,*/
    );
  }






  var user = Rxn<User>();
  var isLoggedIn = false.obs;

  // Getter for current user
  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user, _handleAuthChanged);
  }

  void _handleAuthChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      isLoggedIn.value = true;
      // ✅ Create customer document if not exists
      await _createCustomerDocument(firebaseUser);
     // Get.offAllNamed("/home");
    } else {
      isLoggedIn.value = false;
     // Get.offAllNamed("/login");
    }
  }

  Future<void> _createCustomerDocument(User firebaseUser) async {
    final docRef = _firestore.collection('customers').doc(firebaseUser.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // Create a new customer document
      await docRef.set({
        "name": firebaseUser.displayName ?? "User",
        "email": firebaseUser.email ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ✅ Facebook Sign-In
  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final credential = FacebookAuthProvider.credential(accessToken.tokenString);

        await _auth.signInWithCredential(credential);

        Get.snackbar("Success", "Signed in with Facebook!");
      } else if (result.status == LoginStatus.cancelled) {
        Get.snackbar("Cancelled", "Facebook login cancelled");
      } else {
        Get.snackbar("Error", result.message ?? "Facebook login failed");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
