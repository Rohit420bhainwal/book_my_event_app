import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../services/api_service.dart';
import '../../routes/app_routes.dart';

class ProviderOnboardingController extends GetxController {
  final ApiService apiService = ApiService();
  final dio.Dio _dio = dio.Dio();
  final box = GetStorage();

  // Stepper
  var currentStep = 0.obs;

  // Basic Info
  final businessNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();

  // Service Info
  String selectedServiceType = "catering";
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  // 🖼 Image Handling
  RxList<File> selectedImages = <File>[].obs; // new images (local)
  RxList<String> existingImages = <String>[].obs; // old images from API
  final int maxImages = 5;

  var isLoading = false.obs;
  var token = "";

  @override
  void onInit() {
    super.onInit();

    final userData = box.read("userData");
    if (userData == null) return;

    token = userData["token"];
    setupUI(userData);

    // Restore from GetStorage if available
    _restoreSavedImages();
  }

  void setupUI(userData) {
    final user = userData["user"];
    final providerInfo = userData["providerInfo"] ?? {};

    phoneController.text = user["phone"] ?? "";
    emailController.text = user["email"] ?? "";
    businessNameController.text = providerInfo["businessName"] ?? "";
    contactPersonController.text = providerInfo["contactPerson"] ?? "";
    descriptionController.text = providerInfo["description"] ?? "";
    priceController.text = providerInfo["price"]?.toString() ?? "";
    addressController.text = providerInfo["address"] ?? "";
    cityController.text = providerInfo["city"] ?? "";

    // 🖼 Load existing images from API
    if (providerInfo["images"] != null && providerInfo["images"] is List) {
      existingImages.assignAll(List<String>.from(providerInfo["images"]));
    }
  }

  // ✅ Safely restore images from GetStorage
  void _restoreSavedImages() {
    try {
      final savedExisting = box.read("existingImages");
      if (savedExisting != null && savedExisting is List) {
        existingImages.assignAll(List<String>.from(savedExisting));
      }

      final savedSelected = box.read("selectedImages");
      if (savedSelected != null && savedSelected is List) {
        selectedImages.assignAll(
          savedSelected
              .whereType<String>()
              .map((path) => File(path))
              .where((f) => f.existsSync()) // only keep valid files
              .toList(),
        );
      }
    } catch (e) {
      print("⚠️ Error restoring saved images: $e");
      selectedImages.clear();
      existingImages.clear();
      box.remove("selectedImages");
      box.remove("existingImages");
    }
  }

  // Stepper Navigation
  void nextStep() {
    if (_validateStep(currentStep.value)) {
      if (currentStep.value < 2) currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // Step Validation
  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (businessNameController.text.trim().isEmpty ||
            contactPersonController.text.trim().isEmpty ||
            phoneController.text.trim().isEmpty ||
            emailController.text.trim().isEmpty ||
            addressController.text.trim().isEmpty ||
            cityController.text.trim().isEmpty) {
          Get.snackbar("Error", "Please fill all basic info fields");
          return false;
        }
        return true;
      case 1:
        if (descriptionController.text.trim().isEmpty ||
            priceController.text.trim().isEmpty) {
          Get.snackbar("Error", "Please fill all service info fields");
          return false;
        }
        return true;
      case 2:
        if (selectedImages.isEmpty && existingImages.isEmpty) {
          Get.snackbar("Error", "Please upload at least one image");
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  // Pick multiple images (max 5)
  Future<void> pickImages() async {
    if (selectedImages.length + existingImages.length >= maxImages) {
      Get.snackbar("Limit reached", "You can upload max $maxImages images");
      return;
    }

    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null) {
      for (var img in images) {
        if (selectedImages.length + existingImages.length < maxImages) {
          selectedImages.add(File(img.path));
        } else {
          break;
        }
      }

      // Save locally (paths only)
      box.write("selectedImages", selectedImages.map((f) => f.path).toList());
    }
  }

  // 🧾 Submit provider info
  Future<void> submitProviderInfo(String userId) async {
    if (!_validateStep(0) || !_validateStep(1) || !_validateStep(2)) return;

    try {
      isLoading.value = true;

      // Prepare image files for the first request
      List<dio.MultipartFile> imageFiles1 = [];
      for (var img in selectedImages) {
        imageFiles1.add(await dio.MultipartFile.fromFile(
          img.path,
          filename: img.path.split("/").last,
        ));
      }

      // ---------- 1️⃣ Submit Basic Provider Info ----------
      final formData = dio.FormData.fromMap({
        "userId": userId,
        "businessName": businessNameController.text.trim(),
        "contactPerson": contactPersonController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "address": addressController.text.trim(),
        "city": cityController.text.trim(),
        "images": imageFiles1,
        "status": "pending",
      });

      final response = await _dio.post(
        "${apiService.baseUrl1}/auth/provider-submit-info",
        data: formData,
        options: dio.Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      final data = response.data;
      if (data["success"] != true) {
        Get.snackbar("Error", data["message"] ?? "Failed to submit provider info");
        return;
      }

      // ---------- 2️⃣ Add Service Info ----------
      // We must re-create MultipartFiles (cannot reuse finalized ones)
      List<dio.MultipartFile> imageFiles2 = [];
      for (var img in selectedImages) {
        imageFiles2.add(await dio.MultipartFile.fromFile(
          img.path,
          filename: img.path.split("/").last,
        ));
      }

      final serviceFormData = dio.FormData.fromMap({
        "userId": userId,
        "action": "add",
        "serviceType": selectedServiceType,
        "description": descriptionController.text.trim(),
        "price": priceController.text.trim(),
        "images": imageFiles2,
      });

      final serviceResponse = await _dio.post(
        "${apiService.baseUrl1}/auth/provider-service",
        data: serviceFormData,
        options: dio.Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (serviceResponse.data["success"] == true) {
        Get.snackbar("Success", "Provider details submitted successfully");
        Get.offAllNamed(
          Routes.pendingApprovalScreen,
          arguments: {"userId": userId},
        );
      } else {
        Get.snackbar(
          "Error",
          serviceResponse.data["message"] ?? "Failed to submit service",
        );
      }

      // ---------- 3️⃣ Update local cache ----------
      final userData = box.read("userData");
      if (userData != null) {
        final updatedProviderInfo = {
          "businessName": businessNameController.text.trim(),
          "contactPerson": contactPersonController.text.trim(),
          "phone": phoneController.text.trim(),
          "email": emailController.text.trim(),
          "address": addressController.text.trim(),
          "city": cityController.text.trim(),
          "serviceType": selectedServiceType,
          "description": descriptionController.text.trim(),
          "price": priceController.text.trim(),
          "images": [
            ...existingImages,
            ...selectedImages.map((f) => f.path.split("/").last)
          ],
          "onboardingComplete": true,
          "status": "pending",
        };
        userData["providerInfo"] = updatedProviderInfo;
        box.write("userData", userData);
      }

      // ---------- 4️⃣ Cleanup ----------
      box.remove("selectedImages");
      box.remove("existingImages");
      box.write("providerOnboardingIncomplete", false);

    } catch (e) {
      print("❌ Something went wrong: $e");
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

}
