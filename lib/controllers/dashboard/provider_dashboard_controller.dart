import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../app/services/api_service.dart';
import '../../app/services/fcm_service.dart';
import '../../app/services/presence_service.dart';


class ProviderDashboardController extends GetxController {
  var selectedIndex = 0.obs;
  final box = GetStorage();
  var stripeOnboardingCompleted = false.obs;
  var stripeAccountId = "".obs;
  final ApiService _apiService = ApiService();
  var isLoading = true.obs;
  late final String currentUserId;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
  @override
  void onInit() async {
    final userData = box.read("userData");
    currentUserId = userData["user"]["id"].toString();
    final presenceService = PresenceService(currentUserId);
    presenceService.start();
    stripeOnboardingCompleted.value = userData["providerInfo"]?['stripeOnboardingCompleted'];
    stripeAccountId.value = userData["providerInfo"]?['stripeAccountId'];
    if(stripeAccountId.value.isEmpty){
      updateStripeAccountId();
    }
    super.onInit();

    await FCMService.init();

  }

  Future<void> updateStripeAccountId() async{
    try {
      isLoading.value = true;
      final response = await _apiService.post("provider/stripe/create-account", {}, withAuth: true);
      if (response["success"] == true) {
        final stripeAccountId = response['data']['stripeAccountId'];
        final userData = box.read("userData");
        userData["providerInfo"]["stripeAccountId"] = stripeAccountId;
        box.write("userData", userData);
      }else{
        Get.snackbar("Error", "Something went wrong");
      }
    }catch (e) {
      print("Error : $e");
      Get.snackbar("Error", ": $e");
    } finally {
      isLoading.value = false;
    }

  }
}