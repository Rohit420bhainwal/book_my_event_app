import 'package:get/get.dart';
import '../../../app/services/api_service.dart';

class CustomerHomeController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;
  var searchQuery = ''.obs;

  var featuredVenues = <Map<String, dynamic>>[].obs;
  var recommendedVenues = <Map<String, dynamic>>[].obs;

  // 🔍 Filtered lists (these will be displayed on UI)
  var filteredFeaturedVenues = <Map<String, dynamic>>[].obs;
  var filteredRecommendedVenues = <Map<String, dynamic>>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await fetchAvailableServices();
    await fetchRecommendedVenues();

    // Listen to search changes
    ever(searchQuery, (_) => applySearchFilter());
  }

  Future<void> fetchAvailableServices() async {
    try {
      isLoading.value = true;

      final response = await _apiService.get(
        "auth/services-by-city",
        withAuth: true,
      );

      if (response["success"] == true && response["data"] != null) {
        final services = response["data"]["services"] as List<dynamic>;

        featuredVenues.value = services.map((service) {
          final List<String> imageList = (service["images"] != null)
              ? List<String>.from(service["images"])
              : [];

          String displayImage = imageList.isNotEmpty
              ? imageList.first
              : "assets/images/service_image_placeholder.png";

          return {
            "id": service["serviceId"] ?? "",
            "businessName": service["businessName"] ?? "",
            "providerName": service["providerName"] ?? "",
            "providerEmail": service["providerEmail"] ?? "",
            "providerPhone": service["phone"] ?? "",
            "image": displayImage,
            "images": imageList,
            "description": service["description"] ?? "",
            "category": service["serviceType"] ?? "",
            "price": service["price"] ?? "0",
            "city": service["city"] ?? "",
            "address": service["address"] ?? "",
            "providerId": service["providerId"] ?? "",
          };
        }).toList();

        filteredFeaturedVenues.assignAll(featuredVenues);
      } else {
        Get.snackbar("Error", "Failed to fetch services");
      }
    } catch (e) {
      print("Error fetching services: $e");
      Get.snackbar("Error", "Something went wrong while fetching services");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecommendedVenues() async {
    try {
      isLoading.value = true;

      final response = await _apiService.get(
        "auth/services-by-city",
        withAuth: true,
      );

      if (response["success"] == true && response["data"] != null) {
        final services = response["data"]["services"] as List<dynamic>;

        recommendedVenues.value = services.map((service) {
          final List<String> imageList = (service["images"] != null)
              ? List<String>.from(service["images"])
              : [];

          String displayImage = imageList.isNotEmpty
              ? imageList.first
              : "assets/images/service_image_placeholder.png";

          return {
            "id": service["serviceId"] ?? "",
            "businessName": service["businessName"] ?? "",
            "providerImage": service["providerImage"] ?? "",
            "image": displayImage,
            "images": imageList,
            "description": service["description"] ?? "",
            "category": service["serviceType"] ?? "",
            "price": service["price"] ?? "0",
            "city": service["city"] ?? "",
            "address": service["address"] ?? "",
            "providerId": service["providerId"] ?? "",
          };
        }).toList();

        filteredRecommendedVenues.assignAll(recommendedVenues);
      } else {
        Get.snackbar("Error", "Failed to fetch services");
      }
    } catch (e) {
      print("Error fetching services: $e");
      Get.snackbar("Error", "Something went wrong while fetching services");
    } finally {
      isLoading.value = false;
    }
  }

  // 🔍 Update search
  void updateSearch(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  // 🧩 Apply filter
  void applySearchFilter() {
    if (searchQuery.value.isEmpty) {
      filteredFeaturedVenues.assignAll(featuredVenues);
      filteredRecommendedVenues.assignAll(recommendedVenues);
    } else {
      filteredFeaturedVenues.assignAll(featuredVenues.where((venue) {
        return (venue["businessName"] ?? "")
            .toString()
            .toLowerCase()
            .contains(searchQuery.value) ||
            (venue["category"] ?? "")
                .toString()
                .toLowerCase()
                .contains(searchQuery.value) ||
            (venue["city"] ?? "")
                .toString()
                .toLowerCase()
                .contains(searchQuery.value);
      }).toList());

      filteredRecommendedVenues.assignAll(recommendedVenues.where((venue) {
        return (venue["businessName"] ?? "")
            .toString()
            .toLowerCase()
            .contains(searchQuery.value) ||
            (venue["category"] ?? "")
                .toString()
                .toLowerCase()
                .contains(searchQuery.value) ||
            (venue["city"] ?? "")
                .toString()
                .toLowerCase()
                .contains(searchQuery.value);
      }).toList());
    }
  }
}
