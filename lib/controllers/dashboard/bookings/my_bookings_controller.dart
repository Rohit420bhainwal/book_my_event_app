import 'package:get/get.dart';
import '../../../app/services/api_service.dart';
import '../../../utils/date_utils.dart';

class MyBookingsController extends GetxController {
  var bookings = [].obs;
  var isLoading = false.obs;

  final ApiService api = ApiService();

  // ✅ Base URL for uploaded images
 // final String baseImageUrl = "http://192.168.222.85:5000/uploads/";

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;

      final response = await api.get("bookings/me", withAuth: true);
      print("response_my: $response");

      if (response != null && response["data"] != null) {
        final List bookingList = response["data"];

        bookings.value = bookingList.map((b) {
          final formattedDate = AppDateUtils.formatToDDMMYY(b["date"]);

          final service = b["service"] ?? {};
          final category = service["category"] ?? {};

          // ✅ Handle image filenames and build full URLs
          final List<String> imageList = (service["images"] != null)
              ? List<String>.from(service["images"])
              : [];

          // ✅ Display image only if available
          String displayImage = imageList.isNotEmpty
              ? "${imageList.first}"
              : "assets/images/service_image_placeholder.png";

          return {
            "id": b["_id"] ?? "",
            "providerName": b["provider"]?["name"] ?? "Unknown Provider",
            "providerEmail": b["provider"]?["email"] ?? "",
            "serviceName": b["provider"]?["businessName"] ?? "Unknown Service",
            "categoryName": service["serviceType"] ?? "",
            "serviceImage": displayImage,
            "serviceImages":
            imageList.map((img) => "$img").toList(),
            "date": formattedDate,
            "status": b["status"] ?? "pending",
          };
        }).toList();
      } else {
        bookings.clear();
      }
    } catch (e) {
      print("Error fetching bookings: $e");
      Get.snackbar("Error", "Failed to load bookings");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchBookings1() async {
    try {
      isLoading.value = true;

      final response = await api.get("bookings/me", withAuth: true);
      print("response_my: $response");

      if (response != null && response["data"] != null) {
        final List bookingList = response["data"];

        bookings.value = bookingList.map((b) {
          final formattedDate = AppDateUtils.formatToDDMMYY(b["date"]);

          final service = b["service"] ?? {};
          final category = service["category"] ?? {};

          // ✅ Handle image filenames and build full URLs
          final List<String> imageList = (service["images"] != null)
              ? List<String>.from(service["images"])
              : [];

          // ✅ Display image only if available
          String displayImage = imageList.isNotEmpty
              ? "${api.imageUrl}${imageList.first}"
              : "assets/images/service_image_placeholder.png";

          return {
            "id": b["_id"] ?? "",
            "providerName": b["provider"]?["name"] ?? "Unknown Provider",
            "providerEmail": b["provider"]?["email"] ?? "",
            "serviceName": service["name"] ?? "Unknown Service",
            "categoryName": category["name"] ?? "",
            "serviceImage": displayImage,
            "serviceImages":
            imageList.map((img) => "${api.imageUrl}$img").toList(),
            "date": formattedDate,
            "status": b["status"] ?? "pending",
          };
        }).toList();
      } else {
        bookings.clear();
      }
    } catch (e) {
      print("Error fetching bookings: $e");
      Get.snackbar("Error", "Failed to load bookings");
    } finally {
      isLoading.value = false;
    }
  }
}
