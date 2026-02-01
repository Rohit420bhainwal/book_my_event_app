import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../app/services/fcm_service.dart';
import '../../app/services/presence_service.dart';


class CustomerDashboardController extends GetxController {
  var selectedIndex = 0.obs;
  late final String currentUserId;
  late final String role;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() async{
    super.onInit();

    final box = GetStorage();
    final userData = box.read("userData");

    if (userData == null || userData["user"] == null) {
      throw Exception("User data not found in storage");
    }

    currentUserId = userData["user"]["id"].toString();
    print("currentUserId: $currentUserId");
    role = userData["user"]["role"].toString();
    final presenceService = PresenceService(currentUserId);
    presenceService.start();

    await FCMService.init();


  }
}