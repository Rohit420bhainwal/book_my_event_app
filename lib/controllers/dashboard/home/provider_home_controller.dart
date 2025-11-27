import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/services/api_service.dart';

class ProviderHomeController extends GetxController {
  final ApiService apiService = ApiService();
  final box = GetStorage();

  var isLoading = true.obs;
  var services = <Map<String, dynamic>>[].obs;
  var userId = "";

  @override
  void onInit() {
    super.onInit();
    fetchProviderServices();
  }

  Future<void> fetchProviderServices() async {
    try {
      isLoading.value = true;

      final userData = box.read("userData");
      userId = userData["user"]["id"];

      final response = await apiService.get(
        "auth/provider-services/$userId",
        withAuth: true,
      );

      print("response: $response");

      if (response["success"] == true) {
        final data = response["data"] ?? {};
        final List<dynamic> serviceList = data["services"] ?? [];

        services.value = List<Map<String, dynamic>>.from(serviceList);
        print("✅ Loaded ${services.length} services");
      } else {
        Get.snackbar("Error", "Failed to fetch your services");
      }
    } catch (e) {
      print("❌ Error fetching provider services: $e");
      Get.snackbar("Error", "Unable to fetch services");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      final userData = box.read("userData");
      userId = userData["user"]["id"];

      // Prepare the body according to your backend structure
      final body = {
        "userId": userId,
        "action": "delete",
        "serviceId": serviceId,
      };

      // Send POST request
      final response = await apiService.post(
        "auth/provider-service", // ✅ use the same endpoint as your backend
        body,
        withAuth: true,
      );

      print("delete response: $response");

      if (response["success"] == true) {
        // remove locally from list
        services.removeWhere((s) => s["_id"] == serviceId);

        Get.snackbar(
          "Success",
          "Service deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Error",
          response["message"] ?? "Failed to delete service",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("❌ deleteService error: $e");
      Get.snackbar("Error", "Unable to delete service");
    }
  }

}
