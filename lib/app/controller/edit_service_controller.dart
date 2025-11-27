import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../../app/services/api_service.dart';

class EditServiceController extends GetxController {
  final ApiService apiService = ApiService();

  final String userId;
  final String serviceId;
  final String initialType;
  final String initialDescription;
  final String initialPrice;
  final List<dynamic> initialImages;

  EditServiceController({
    required this.userId,
    required this.serviceId,
    required this.initialType,
    required this.initialDescription,
    required this.initialPrice,
    required this.initialImages,
  });

  var serviceType = ''.obs;
  var description = ''.obs;
  var price = ''.obs;

  // Text controllers
  late TextEditingController typeController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;

  // Image handling
  var selectedImages = <File>[].obs;
  var existingImages = <String>[].obs;
  var deletedImages = <String>[].obs;

  var isLoading = false.obs;
  final ImagePicker picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    serviceType.value = initialType;
    description.value = initialDescription;
    price.value = initialPrice;
    existingImages.assignAll(initialImages.map((e) => e.toString()).toList());

    // Initialize text controllers
    typeController = TextEditingController(text: initialType);
    descriptionController = TextEditingController(text: initialDescription);
    priceController = TextEditingController(text: initialPrice);

    // Keep reactive values in sync
    typeController.addListener(() => serviceType.value = typeController.text);
    descriptionController.addListener(() => description.value = descriptionController.text);
    priceController.addListener(() => price.value = priceController.text);
  }

  @override
  void onClose() {
    typeController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> pickImages() async {
    final List<XFile>? pickedFiles = await picker.pickMultiImage(
      imageQuality: 100,
      maxWidth: 4000,
      maxHeight: 4000,
    );
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      selectedImages.assignAll(pickedFiles.map((xfile) => File(xfile.path)));
    }
  }

  void removeExistingImage(String imageName) {
    existingImages.remove(imageName);
    deletedImages.add(imageName);
  }

  Future<void> saveService() async {
    isLoading.value = true;

    try {
      List<http.MultipartFile> files = [];
      for (var file in selectedImages) {
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final typeParts = mimeType.split('/');
        files.add(await http.MultipartFile.fromPath(
          "images",
          file.path,
          contentType: MediaType(typeParts[0], typeParts[1]),
        ));
      }

      final body = {
        "userId": userId,
        "action": "edit",
        "serviceId": serviceId,
        "serviceType": serviceType.value,
        "description": description.value,
        "price": price.value,
        "existingImages": jsonEncode(existingImages),
        "deletedImages": jsonEncode(deletedImages),
      };

      final result = await apiService.postMultipart(
        endpoint: "auth/provider-service",
        body: body,
        files: files,
        token: "", // Token handled automatically in ApiService
      );

      if (result["success"] == true) {
        Get.back(result: true);
        Get.snackbar("Success", "Service updated successfully!");
      } else {
        Get.snackbar("Error", result["message"] ?? "Failed to update");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
