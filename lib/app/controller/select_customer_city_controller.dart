import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../routes/app_routes.dart';
import '../services/api_service.dart';

class SelectCustomerCityController extends GetxController {
  final TextEditingController cityController = TextEditingController();
  late final String userId;
  final ApiService _apiService = ApiService();
  final box = GetStorage();

  final List<String> allCities = [
    'Mumbai',
    'Pune',
    'Delhi',
    'Bengaluru',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Ahmedabad',
    'Surat',
    'Jaipur',
    'Nagpur',
    'Indore',
    'Bhopal',
    'Nashik',
    'Lucknow',
    'Chandigarh',
    'Goa',
  ];

  var filteredCities = <String>[].obs;
  var isLoading = false.obs;

  // 🔐 You may store the base URL in constants/env file
  final String baseUrl = "https://your-backend-domain.com/api/auth"; // ⬅️ change this

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    userId = args != null && args['userId'] != null ? args['userId'] : '';
    filteredCities.assignAll(allCities);
    cityController.addListener(_filterCities);
  }

  void _filterCities() {
    final query = cityController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredCities.assignAll(allCities);
    } else {
      filteredCities.assignAll(
        allCities.where((city) => city.toLowerCase().contains(query)).toList(),
      );
    }
  }

  void selectCity(String city) {
    cityController.text = city;
    filteredCities.clear();
  }

  // ✅ API Integration for updating city
  Future<void> updateCityOnServer() async {
    final city = cityController.text.trim();
    if (city.isEmpty) {
      Get.snackbar("Error", "Please select or enter a city before updating",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade50);
      return;
    }

    try {
      isLoading.value = true;

      final body = {
        "city": city.trim()
      };

      final response = await _apiService.post("auth/update-city", body, withAuth: true);
      if (response["success"] == true) {
        final box = GetStorage();
        final userData = box.read("userData");

        if (userData != null) {
          userData["user"]["city"] = city;
          box.write("userData", userData);
        }

        Get.offAllNamed(
          Routes.customerDashboard,
          arguments: {
            "userId": response["userId"],
          },
        );
      } else {
        Get.snackbar("Error", response["message"] ?? "Failed to update role");
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.black87,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔐 Replace this with your actual local storage method (e.g. GetStorage, SharedPreferences)
  Future<String> _getTokenFromStorage() async {
    // Example placeholder (update as per your app’s auth logic)
    // final storage = GetStorage();
    // return storage.read('token') ?? '';
    return "YOUR_JWT_TOKEN_HERE";
  }

  @override
  void onClose() {
    cityController.dispose();
    super.onClose();
  }
}
