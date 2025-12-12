import 'dart:io';
import 'dart:convert';
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

  // Government ID
  var idType = "".obs;
  Rxn<File> idFrontFile = Rxn<File>();
  Rxn<File> idBackFile = Rxn<File>(); // optional depending on idType

  // Categories (full objects including fields)
  RxList<Map<String, dynamic>> serviceCategories = <Map<String, dynamic>>[].obs;
  RxnInt selectedServiceIndex = RxnInt();

  // Dynamic fields (key -> Rx<String>)
  var dynamicFields = <String, Rx<dynamic>>{}.obs;

  // Description + Price
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  // Images
  RxList<File> selectedImages = <File>[].obs;
  RxList<String> existingImages = <String>[].obs;
  final int maxImages = 5;

  // Loading States
  var isSubmitting = false.obs; // for final submit
  var isFetchingCategories = false.obs; // while loading categories

  var token = "";

  // ID types list (display -> value)
  final List<Map<String, String>> idTypeOptions = [
    {"label": "Aadhaar Card", "value": "aadhaar"},
    {"label": "PAN Card", "value": "pan"},
    {"label": "Voter ID", "value": "voterId"},
    {"label": "Driving License", "value": "license"},
    {"label": "Passport", "value": "passport"},
    {"label": "Other", "value": "other"},
  ];

  @override
  void onInit() {
    super.onInit();

    final userData = box.read("userData");
    if (userData != null) {
      token = userData["token"] ?? "";
      setupUI(userData);
      _restoreSavedImages();
      _restoreSavedIdFiles();
    }

    // fetch categories (with fields)
    fetchServiceCategories();

    // observe selectedServiceIndex to setup dynamic fields when user changes category
    ever<int?>(selectedServiceIndex, (_) {
      setupDynamicFields();
    });
  }

  // Fetch categories including fields
  Future<void> fetchServiceCategories() async {
    try {
      isFetchingCategories.value = true;
      final response = await apiService.get("categories", withAuth: true);

      if (response["success"] == true) {
        // keep whole object including fields (if provided by API)
        serviceCategories.assignAll((response["data"] as List).map((e) {
          return {
            "id": e["_id"],
            "name": e["name"],
            "fields": e["fields"] ?? <dynamic>[],
          };
        }).toList());

        if (serviceCategories.isNotEmpty) {
          selectedServiceIndex.value = 0;
        }
      } else {
        Get.snackbar("Error", "Failed to load categories");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isFetchingCategories.value = false;
    }
  }

  // Setup UI values from stored userData / providerInfo
  void setupUI(userData) {
    final user = userData["user"];
    final providerInfo = userData["providerInfo"] ?? {};

    phoneController.text = user?["phone"] ?? "";
    emailController.text = user?["email"] ?? "";
    businessNameController.text = providerInfo["businessName"] ?? "";
    contactPersonController.text = providerInfo["contactPerson"] ?? "";
    descriptionController.text = providerInfo["description"] ?? "";
    priceController.text = providerInfo["price"]?.toString() ?? "";
    addressController.text = providerInfo["address"] ?? "";
    cityController.text = providerInfo["city"] ?? "";

    if (providerInfo["images"] != null && providerInfo["images"] is List) {
      existingImages.assignAll(List<String>.from(providerInfo["images"]));
    }

    // restore governmentIdProof if present in providerInfo
    if (providerInfo["governmentIdProof"] != null && providerInfo["governmentIdProof"] is Map) {
      final gov = providerInfo["governmentIdProof"] as Map;
      final idTypeVal = gov["idType"] ?? "";
      idType.value = idTypeVal;
      // We don't have local file paths for stored images (they are URLs). Keep this for display if you need.
      box.write("existingGovernmentId", gov); // optional
    }
  }

  // Restore saved image paths (if any)
  void _restoreSavedImages() {
    try {
      final savedExisting = box.read("existingImages");
      if (savedExisting is List) {
        existingImages.assignAll(List<String>.from(savedExisting));
      }

      final savedSelected = box.read("selectedImages");
      if (savedSelected is List) {
        selectedImages.assignAll(
          savedSelected
              .whereType<String>()
              .map((path) => File(path))
              .where((f) => f.existsSync())
              .toList(),
        );
      }
    } catch (e) {
      selectedImages.clear();
      existingImages.clear();
    }
  }

  // Restore saved ID file paths (if user navigated away)
  void _restoreSavedIdFiles() {
    try {
      final savedIdFront = box.read("idFrontPath");
      final savedIdBack = box.read("idBackPath");
      final savedIdType = box.read("idType");
      if (savedIdFront is String && File(savedIdFront).existsSync()) {
        idFrontFile.value = File(savedIdFront);
      }
      if (savedIdBack is String && File(savedIdBack).existsSync()) {
        idBackFile.value = File(savedIdBack);
      }
      if (savedIdType is String) {
        idType.value = savedIdType;
      }
    } catch (e) {
      // ignore
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

        // validate government id selection
        if (idType.value.trim().isEmpty) {
          Get.snackbar("Error", "Please select Government ID type");
          return false;
        }

        if (_requiresTwoImages(idType.value)) {
          if (idFrontFile.value == null || idBackFile.value == null) {
            Get.snackbar("Error", "Please upload both front and back images of the ID");
            return false;
          }
        } else {
          if (idFrontFile.value == null) {
            Get.snackbar("Error", "Please upload ID image");
            return false;
          }
        }

        return true;

      case 1:
        if (selectedServiceIndex.value == null) {
          Get.snackbar("Error", "Please select service type");
          return false;
        }

        // also validate dynamic required fields if API provides 'required' flag
        final fields = serviceCategories[selectedServiceIndex.value!]["fields"] as List<dynamic>;
        for (var f in fields) {
          final key = f["key"]?.toString() ?? "";
          final required = f["required"] == true;
          if (required) {
            final val = dynamicFields[key]?.value?.toString() ?? "";
            if (val.trim().isEmpty) {
              Get.snackbar("Error", "Please fill ${f["label"] ?? key}");
              return false;
            }
          }
        }

        if (descriptionController.text.trim().isEmpty ||
            priceController.text.trim().isEmpty) {
          Get.snackbar("Error", "Please fill service description and price");
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

  bool _requiresTwoImages(String idTypeVal) {
    final twoImageIds = ["aadhaar", "voterId", "license"];
    return twoImageIds.contains(idTypeVal);
  }

  /// Pick multiple images (maxImages)
  Future<void> pickImages() async {
    if (selectedImages.length + existingImages.length >= maxImages) {
      Get.snackbar("Limit reached", "You can upload max $maxImages images");
      return;
    }

    final ImagePicker picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images != null) {
      for (var img in images) {
        if (selectedImages.length + existingImages.length < maxImages) {
          selectedImages.add(File(img.path));
        } else {
          break;
        }
      }
      box.write("selectedImages", selectedImages.map((f) => f.path).toList());
    }
  }

  /// pick single image for ID front or back
  Future<void> pickIdImage({required bool isFront}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final file = File(picked.path);
      if (isFront) {
        idFrontFile.value = file;
        box.write("idFrontPath", file.path);
      } else {
        idBackFile.value = file;
        box.write("idBackPath", file.path);
      }
    }
  }

  /// remove picked ID image
  void removeIdImage({required bool isFront}) {
    if (isFront) {
      idFrontFile.value = null;
      box.remove("idFrontPath");
    } else {
      idBackFile.value = null;
      box.remove("idBackPath");
    }
  }

  /// Setup dynamicFields map based on selected category fields
  void setupDynamicFields() {
    dynamicFields.clear();

    if (selectedServiceIndex.value == null) return;

    final selected = serviceCategories[selectedServiceIndex.value!];
    final fields = selected["fields"] as List<dynamic>? ?? [];

    for (var f in fields) {
      final key = f["key"]?.toString() ?? "";
      // if providerInfo existed with values, you could prefill here
      dynamicFields[key] = "".obs;
    }
  }

  /// Convert dynamicFields to JSON string
  String getFilledFieldsJson() {
    Map<String, dynamic> map = {};
    dynamicFields.forEach((k, v) {
      map[k] = v.value;
    });
    return jsonEncode(map);
  }

  /// For description preview if needed
  String generateDescription() {
    return dynamicFields.entries.map((e) => "${e.key}: ${e.value.value}").join(", ");
  }

  // ------------------------------------------------------------
  // SUBMIT PROVIDER INFO + SERVICE (uses isSubmitting for submit button)
  // ------------------------------------------------------------
  Future<void> submitProviderInfo(String userId) async {
    if (!_validateStep(0) || !_validateStep(1) || !_validateStep(2)) return;

    try {
      isSubmitting.value = true;

      // prepare images (service images)
      List<dio.MultipartFile> imageFiles = [];
      for (var img in selectedImages) {
        imageFiles.add(await dio.MultipartFile.fromFile(
          img.path,
          filename: img.path.split("/").last,
        ));
      }

      // Prepare ID multipart files (must match multer fields)
      dio.MultipartFile? govFrontMultipart;
      dio.MultipartFile? govBackMultipart;

      if (idFrontFile.value != null) {
        govFrontMultipart = await dio.MultipartFile.fromFile(
          idFrontFile.value!.path,
          filename: idFrontFile.value!.path.split("/").last,
        );
      }

      if (idBackFile.value != null) {
        govBackMultipart = await dio.MultipartFile.fromFile(
          idBackFile.value!.path,
          filename: idBackFile.value!.path.split("/").last,
        );
      }

      // FORM DATA
      final Map<String, dynamic> formMap = {
        "userId": userId,
        "businessName": businessNameController.text.trim(),
        "contactPerson": contactPersonController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "address": addressController.text.trim(),
        "city": cityController.text.trim(),
        "images": imageFiles,
        "status": "pending",
        "idType": idType.value ?? "",
      };

      // ADD GOVERNMENT ID USING CORRECT FIELD NAMES
      if (govFrontMultipart != null) formMap["govFront"] = govFrontMultipart;
      if (govBackMultipart != null) formMap["govBack"] = govBackMultipart;

      final formData = dio.FormData.fromMap(formMap);

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

      if (response.data["success"] != true) {
        Get.snackbar("Error", response.data["message"] ?? "Failed to submit provider");
        return;
      }

      // 2) Submit service details
      List<dio.MultipartFile> imageFiles2 = [];
      for (var img in selectedImages) {
        imageFiles2.add(await dio.MultipartFile.fromFile(
          img.path,
          filename: img.path.split("/").last,
        ));
      }

      final selectedCat = serviceCategories[selectedServiceIndex.value!];
      final serviceFormData = dio.FormData.fromMap({
        "userId": userId,
        "action": "add",
        "selectedServiceId": selectedCat["id"],
        "serviceType": selectedCat["name"],
        "filledFields": getFilledFieldsJson(),
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
        Get.offAllNamed(Routes.pendingApprovalScreen, arguments: {"userId": userId});
      } else {
        Get.snackbar("Error", serviceResponse.data["message"] ?? "Failed to submit service");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

}
