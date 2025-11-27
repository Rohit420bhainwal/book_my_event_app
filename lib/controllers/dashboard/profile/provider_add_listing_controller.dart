// provider_add_listing_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProviderAddListingController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var providerType = "venue".obs;
  var venueName = "".obs;
  var capacity = "".obs;
  var price = "".obs;

  var providerName = "".obs;
  var cateringEnabled = false.obs;
  var cateringPrice = "".obs;
  var djEnabled = false.obs;
  var djPrice = "".obs;
  var decorationEnabled = false.obs;
  var decorationPrice = "".obs;
  var discountPercent = "".obs;
  var serviceRadius = "".obs;
  var address = "".obs;

  var isLoading = false.obs;

  final List<String> defaultVenueImages = [
    "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80",
    "https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=600&q=80",
    "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=600&q=80",
  ];

  final List<String> defaultServiceImages = [
    "https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=600&q=80",
    "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=600&q=80",
    "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=600&q=80",
  ];

  void clearForm() {
    providerType.value = "venue";
    venueName.value = "";
    capacity.value = "";
    price.value = "";
    providerName.value = "";
    cateringEnabled.value = false;
    cateringPrice.value = "";
    djEnabled.value = false;
    djPrice.value = "";
    decorationEnabled.value = false;
    decorationPrice.value = "";
    discountPercent.value = "";
    serviceRadius.value = "";
    address.value = "";
  }

  Future<void> saveListing() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      Map<String, dynamic> data = {
        "type": providerType.value,
        "createdAt": DateTime.now().toIso8601String(),
        "approved": "pending", // <-- Changed from boolean to string
      };

      if (providerType.value == "venue") {
        data.addAll({
          "venueName": venueName.value,
          "capacity": int.tryParse(capacity.value) ?? 0,
          "price": double.tryParse(price.value) ?? 0.0,
          "address": address.value,
          "images": defaultVenueImages,
        });
      } else {
        data.addAll({
          "providerName": providerName.value,
          "services": {
            "catering": {
              "enabled": cateringEnabled.value,
              "price": double.tryParse(cateringPrice.value) ?? 0.0
            },
            "dj": {
              "enabled": djEnabled.value,
              "price": double.tryParse(djPrice.value) ?? 0.0
            },
            "decoration": {
              "enabled": decorationEnabled.value,
              "price": double.tryParse(decorationPrice.value) ?? 0.0
            },
          },
          "discountPercent": int.tryParse(discountPercent.value) ?? 0,
          "baseAddress": address.value,
          "serviceRadius": int.tryParse(serviceRadius.value) ?? 0,
          "images": defaultServiceImages,
        });
      }

      await _db
          .collection("providers")
          .doc(user.uid)
          .collection("listings")
          .add(data);

      Get.snackbar("Success", "Listing added successfully! Awaiting approval.");
      clearForm();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool get isVenueFormValid =>
      venueName.value.trim().isNotEmpty &&
      capacity.value.trim().isNotEmpty &&
      price.value.trim().isNotEmpty &&
      address.value.trim().isNotEmpty;

  bool get isServiceFormValid {
    bool hasService = false;
    if (cateringEnabled.value && cateringPrice.value.trim().isNotEmpty) hasService = true;
    if (djEnabled.value && djPrice.value.trim().isNotEmpty) hasService = true;
    if (decorationEnabled.value && decorationPrice.value.trim().isNotEmpty) hasService = true;
    return providerName.value.trim().isNotEmpty &&
        hasService &&
        address.value.trim().isNotEmpty &&
        serviceRadius.value.trim().isNotEmpty;
  }

  bool get isFormValid =>
      (providerType.value == "venue" && isVenueFormValid) ||
      (providerType.value == "service" && isServiceFormValid);
}
