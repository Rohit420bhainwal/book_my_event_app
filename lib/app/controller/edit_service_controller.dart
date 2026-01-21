import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../app/services/api_service.dart';


class EditServiceController extends GetxController {
  final String userId;
  final String serviceId;
  final String initialType;
  final String initialDescription;
  final String initialPrice;
  final String initialSelectedServiceId;
  final List<dynamic> initialImages;
  final Map<String, dynamic> initialFilledFields;

  EditServiceController({
    required this.userId,
    required this.serviceId,
    required this.initialType,
    required this.initialDescription,
    required this.initialPrice,
    required this.initialImages,
    required this.initialFilledFields,
    required this.initialSelectedServiceId,
  });

  final ApiService apiService = ApiService();
  final ImagePicker picker = ImagePicker();

  // Reactive state
  var isLoading = false.obs;
  RxString serviceType = "".obs;
  RxBool isSaving = false.obs;

  // Existing fields
  RxList<String> existingImages = <String>[].obs;
  RxList<String> deletedImages = <String>[].obs;
  RxList<XFile> selectedImages = <XFile>[].obs;

  // Persistent controllers
  late TextEditingController descriptionController;
  late TextEditingController priceController;

  // Dynamic Fields controllers
  Map<String, TextEditingController> dynamicControllers = {};

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  void loadInitialData() {
    serviceType.value = initialType;

    /// FIX: Persistent controllers
    descriptionController = TextEditingController(text: initialDescription);
    priceController = TextEditingController(text: initialPrice);

    /// Existing images
    existingImages.assignAll(initialImages.map((e) => e.toString()).toList());

    /// Dynamic fields
    dynamicControllers.clear();
    initialFilledFields.forEach((key, value) {
      dynamicControllers[key] = TextEditingController(text: value.toString());
    });
  }

  Future<void> pickImages() async {
    final images = await picker.pickMultiImage();
    if (images != null) {
      if (images.length + selectedImages.length > 5) {
        Get.snackbar("❌ Error", "Max 5 images allowed");
        return;
      }
      selectedImages.addAll(images);
    }
  }

  void deleteExistingImage(String img) {
    deletedImages.add(img);
    existingImages.remove(img);
  }

  void removeNewImage(int index) {
    selectedImages.removeAt(index);
  }

  String getFilledFieldsJson() {
    Map<String, dynamic> map = {};
    dynamicControllers.forEach((key, ctrl) {
      map[key] = ctrl.text;
    });
    return jsonEncode(map);
  }

  /// YOUR EXACT WORKING CODE + added fields
  Future<void> saveService() async {
    isLoading.value = true;

    try {
      isSaving.value = true;
      List<http.MultipartFile> files = [];
      for (var file in selectedImages) {
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final parts = mimeType.split('/');

        files.add(
          await http.MultipartFile.fromPath(
            "images",
            file.path,
            contentType: MediaType(parts[0], parts[1]),
          ),
        );
      }

      final body = {
        "userId": userId,
        "action": "edit",
        "serviceId": serviceId,
        "serviceType": serviceType.value,
        "description": descriptionController.text,
        "price": priceController.text,
        "selectedServiceId": initialSelectedServiceId,

        "filledFields": getFilledFieldsJson(),
        "existingImages": jsonEncode(existingImages),
        "deletedImages": jsonEncode(deletedImages),
      };

      final result = await apiService.postMultipart(
        endpoint: "auth/provider-service",
        body: body,
        files: files,
        token: "",
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
      isSaving.value = false;
      isLoading.value = false;
    }
  }
}
