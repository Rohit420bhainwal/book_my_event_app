import 'package:bookmyevent/app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/app_routes.dart';

class RoleController extends GetxController {
  final ApiService _apiService = ApiService();
  final box = GetStorage();

  var isLoading = false.obs;

  /// Save user role via API and navigate accordingly
  Future<void> saveRole(String role) async {
    final userData = box.read("userData");
    final user = userData["user"];
    final userId = user["id"];
    try {
      isLoading.value = true;

      final response = await _apiService.post("auth/set-role", {
        "userId": userId,
        "role": role,
      });

      print("response##: ${response}");

      if (response["success"] == true) {
        user["role"] = role;
        box.write("userData", userData);
        // Navigate based on role
        if (role == "customer") {

          Get.offAllNamed(
            Routes.selectCustomerCity,
            arguments: {
              "userId": response["userId"],
            },
          );
        /*  Get.offAllNamed(
            Routes.customerDashboard,
            arguments: {
              "userId": response["userId"],
            },
          );*/
        } else if (role == "provider") {
          box.write("providerOnboardingIncomplete", true);
          Get.offAllNamed(
            Routes.providerOnboarding,
            arguments: {  "userId": userId},
          );

          /*Get.offAllNamed(
            *//*Routes.providerDashboard,*//*
            Routes.providerOnboarding,
            arguments: {
              "userId": response["userId"],
            },
          );*/
        }
      } else {
        Get.snackbar("Error", response["message"] ?? "Failed to update role");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
