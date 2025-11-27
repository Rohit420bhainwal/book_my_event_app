import 'package:bookmyevent/app/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProviderProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService apiService = ApiService();

  var isLoading = true.obs;

  var name = "".obs;
  var username = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var role = "".obs;
  var userId = "".obs;
  var profileImage = "".obs;


  @override
  void onInit() {
    super.onInit();
    fetchProviderProfile();
  }

  Future<void> fetchProviderProfile() async {
    try {
      isLoading.value = true;
      final response = await apiService.get("profile", withAuth: true);

      if (response['success'] == true && response['data']?['user'] != null) {
        final user = response['data']['user'];

        name.value = user['name'] ?? "";
        username.value = user['username'] ?? "";
        email.value = user['email'] ?? "";
        phone.value = user['phone'] ?? "";
        role.value = user['role'] ?? "";
        userId.value = user['_id'] ?? "";

        if (user['profileImage'] != null && user['profileImage'].isNotEmpty) {
          profileImage.value = user['profileImage'].startsWith("http")
              ? user['profileImage']
              : "${apiService.imageUrl}${user['profileImage']}";
        } else {
          profileImage.value = "";
        }
      } else {
        Get.snackbar("Error", "Unable to fetch profile details");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed("/login");
  }
}
