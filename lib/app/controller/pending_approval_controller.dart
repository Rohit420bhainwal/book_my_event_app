import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/app_routes.dart';
import '../../app/services/api_service.dart';
import 'package:dio/dio.dart' as dio;

class PendingApprovalController extends GetxController {
  final box = GetStorage();
  final ApiService apiService = ApiService();
  final dio.Dio _dio = dio.Dio();

  var userName = "".obs;
  var status = "pending".obs;
  var isRefreshing = false.obs;
  var token = "";
  late String userId;

  @override
  void onInit() {
    super.onInit();
    final userData = box.read("userData");
    if (userData != null) {
      userName.value = userData["user"]["name"] ?? "User";
      token = userData["token"];
      userId = userData["user"]["id"];
      status.value = userData["providerInfo"]?["status"] ?? "pending";
    }
  }

  /// 🔄 Pull-to-refresh → Check provider status from backend
  Future<void> refreshStatus() async {
    try {
      isRefreshing.value = true;

      final response = await _dio.get(
        "${apiService.baseUrl1}/auth/check-provider-status/$userId",
        options: dio.Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      final data = response.data;

      if (data["success"] == true) {
        final newStatus = data["status"] ?? "pending";
        status.value = newStatus;

        // Update local storage
        final userData = box.read("userData");
        userData["providerInfo"] = data["providerInfo"];
        box.write("userData", userData);

        // 🚀 If approved → navigate to Provider Dashboard
        if (newStatus == "approved") {
          Get.offAllNamed(Routes.providerDashboard);
        } else {
          Get.snackbar("Status", "Your profile is still under review ($newStatus).");
        }
      } else {
        Get.snackbar("Error", data["message"] ?? "Unable to check status");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to refresh: $e");
    } finally {
      isRefreshing.value = false;
    }
  }

  /// 🚪 Logout user and clear data
  void logout() {
    box.erase();
    Get.offAllNamed(Routes.login);
  }
}
