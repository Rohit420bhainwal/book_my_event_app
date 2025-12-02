import 'package:bookmyevent/app/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProviderProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();
  var displayName = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var city = "".obs;
  var photoUrl = "".obs;
  var available = "".obs;

  ApiService apiService = ApiService();
  var isLoading = true.obs;
  var role = "".obs;

  final String baseUrl = "http://192.168.222.85:5000/uploads/"; // change as per your server

  @override
  void onInit()async {
    super.onInit();
    final userData = box.read("userData");
    if (userData != null) {
      role.value = userData["user"]["role"] ?? "";
    }
    await fetchUserProfile();
    fetchTotalEarning();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      final response = await apiService.get("profile", withAuth: true);
      print("fetchUserProfile $response");
      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['user'] != null) {
        final user = response['data']['user'];

        displayName.value = user['name'] ?? "";
        email.value = user['email'] ?? "";
        phone.value = user['phone'] ?? "";
        city.value = user['city'] ?? "";
        if(role.value == "provider"){
          city.value = user["providerInfo"] ["city"]?? "";
        }


        if (user['profileImage'] != null && user['profileImage'].isNotEmpty) {
          photoUrl.value = user['profileImage'].startsWith("http")
              ? user['profileImage']
              : "$baseUrl${user['profileImage']}";
        } else {
          photoUrl.value = "";
        }

      } else {
        Get.snackbar("Error", "Unable to get profile details");
      }
    } catch (e) {
      print("Error loading profile details: $e");
      Get.snackbar("Error", "Failed to load profile details: $e");
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> fetchTotalEarning() async{
    try {
      isLoading.value = true;
      final response = await apiService.get("withdraw/me",withAuth: true);
      print("fetchTotalEarning $response");
      if(response['success']==true){
        final earnings = response['data']['earnings'];
        available.value = earnings['available'].toString();
      }else{
        Get.snackbar("Error", "Unable to get total earning");
      }
      
    }catch (e){
      print("Failed to load total earning: $e");
      Get.snackbar("Error", "Failed to load total earning: $e");
    }finally{
     isLoading.value = false ;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed("/login");
  }
}
