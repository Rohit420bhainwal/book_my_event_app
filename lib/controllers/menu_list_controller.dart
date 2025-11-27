import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import '../../../app/model/menu_item.dart';
import '../../../app/services/api_service.dart';

class MenuListController extends GetxController {
  var menuItems = <MenuItem>[].obs;
  var isLoading = false.obs;
  var selectedIndex = 0.obs;

  final ApiService _apiService = ApiService();

  final productNameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final documentNameController = TextEditingController();
  final capacityController = TextEditingController();

  var selectedImages = <XFile>[].obs;
  final ImagePicker _picker = ImagePicker();

  /// Pick multiple images
  Future<void> pickImages() async {
    try {
      final images = await _picker.pickMultiImage();
      if (images != null) {
        if (images.length + selectedImages.length > 5) {
          Get.snackbar("❌ Error", "You can upload a maximum of 5 images");
          return;
        }
        selectedImages.addAll(images);
      }
    } catch (e) {
      Get.snackbar("❌ Error", "Failed to pick images: $e");
    }
  }

  void removeImage(int index) => selectedImages.removeAt(index);

  /// ✅ Upload Provider Service (Add)
  Future<void> uploadProviderService({
    required String token,
    required String userId,
    required String serviceType,
    required String description,
    required String price,
  }) async {
    if (serviceType.isEmpty || description.isEmpty || price.isEmpty) {
      Get.snackbar("❌ Error", "Please fill all fields");
      return;
    }

    final uri = Uri.parse("${_apiService.baseUrl1}/auth/provider-service");
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Form fields
    request.fields['userId'] = userId;
    request.fields['action'] = 'add';
    request.fields['serviceType'] = serviceType;
    request.fields['description'] = description;
    request.fields['price'] = price;

    // Image files
    for (var img in selectedImages) {
      final file = File(img.path);
      final ext = path.extension(file.path).replaceAll('.', '');
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        file.path,
        filename: path.basename(file.path),
        contentType: MediaType('image', ext),
      ));
    }

    try {
      isLoading.value = true;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        Get.snackbar("✅ Success", data["message"] ?? "Service added successfully!");
        clearForm();
      } else {
        Get.snackbar("❌ Error", data["message"] ?? "Failed to add service");
      }
    } catch (e) {
      Get.snackbar("❌ Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all service categories
  Future<void> fetchServiceCategory(String token) async {
    try {
      isLoading.value = true;
      final response = await _apiService.get("categories", withAuth: true);
      if (response["success"] == true) {
        final List<dynamic> data = response["data"] ?? [];
        menuItems.assignAll(data.map((e) => MenuItem.fromJson(e)).toList());
      } else {
        Get.snackbar("Error", "Failed to fetch service categories");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch menu list");
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all form data
  void clearForm() {
    productNameController.clear();
    priceController.clear();
    descriptionController.clear();
    addressController.clear();
    documentNameController.clear();
    capacityController.clear();
    selectedImages.clear();
  }
}
