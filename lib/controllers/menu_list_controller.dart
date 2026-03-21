import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import '../../../app/services/api_service.dart';
import '../../../app/model/menu_item.dart';

class MenuListController extends GetxController {
  var menuItems = <MenuItem>[].obs;
  var selectedIndex = RxnInt();
  var isLoading = false.obs;
  RxString description = "".obs;

  final ApiService _api = ApiService();

  var dynamicFields = <String, Rx<dynamic>>{}.obs;
  var price = "".obs;

  var selectedImages = <XFile>[].obs;
  final ImagePicker _picker = ImagePicker();

  /// -----------------------------
  /// 🔥 NEW: Disable Save Button Logic
  /// -----------------------------
  bool get isSaveDisabled =>
      isLoading.value ||
          selectedIndex.value == null ||
          price.value.trim().isEmpty||description.value.trim().isEmpty;
  /// -----------------------------

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images != null) {
      if (images.length + selectedImages.length > 5) {
        Get.snackbar("❌ Error", "Max 5 images allowed");
        return;
      }
      selectedImages.addAll(images);
    }
  }

  void removeImage(int index) => selectedImages.removeAt(index);

  Future<void> fetchServiceCategory(String token) async {
    try {
      isLoading.value = true;
      final response = await _api.get("categories", withAuth: true);

      if (response["success"] == true) {
        menuItems.assignAll(
          (response["data"] as List).map((e) => MenuItem.fromJson(e)).toList(),
        );

        if (menuItems.isNotEmpty) {
          selectedIndex.value = 0;
          setupDynamicFields();
        }
      } else {
        Get.snackbar("Error", "Failed to load categories");
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setupDynamicFields() {
    dynamicFields.clear();
    price.value = "";

    if (selectedIndex.value == null) return;

    final selected = menuItems[selectedIndex.value!];

    for (var f in selected.fields) {
      dynamicFields[f.key] = "".obs;
    }
  }

  void onCategoryChange(int? index) {
    if (index == null) return;
    selectedIndex.value = index;
    setupDynamicFields();
  }

  String getFilledFieldsJson() {
    Map<String, dynamic> map = {};
    dynamicFields.forEach((key, value) {
      map[key] = value.value;
    });
    return jsonEncode(map);
  }

  String generateDescription() {
    return dynamicFields.entries
        .map((e) => "${e.key}: ${e.value.value}")
        .join(", ");
  }

  Future<void> uploadProviderService({
    required String token,
    required String userId,
    required String action,
    required String selectedServiceId,
    required String selectedServiceType,
    String? serviceId,
    required String filledFields,
    required String description,
    required String price,
  }) async {
    try {
      final uri = Uri.parse("${_api.baseUrl1}/auth/provider-service");

      var request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields["userId"] = userId;
      request.fields["action"] = action;
      request.fields["selectedServiceId"] = selectedServiceId;
      request.fields["filledFields"] = filledFields;
      request.fields["description"] = description;
      request.fields["price"] = price;
      request.fields["serviceType"] = selectedServiceType;

      if (serviceId != null) {
        request.fields["serviceId"] = serviceId;
      }

      for (var img in selectedImages) {
        File file = File(img.path);
        final ext = path.extension(file.path).replaceAll(".", "");
        request.files.add(await http.MultipartFile.fromPath(
          "images",
          file.path,
          filename: path.basename(file.path),
          contentType: MediaType("image", ext),
        ));
      }

      isLoading.value = true;

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        Get.snackbar("✅ Success", data["message"]);
        clearForm();
      } else {
        Get.snackbar("❌ Error", data["message"]);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    selectedImages.clear();
    setupDynamicFields();
  }
}
