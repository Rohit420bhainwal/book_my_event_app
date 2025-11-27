import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ProviderAddVenueController extends GetxController {
  var providerType = "venue".obs; // "venue" or "service"
  var venueName = "".obs;
  var providerName = "".obs; // <-- Add this line
  var capacity = "".obs;
  var price = "".obs;

  var serviceRadius = "".obs;

  // Services with charges
  var cateringEnabled = false.obs;
  var cateringPrice = "".obs;

  var djEnabled = false.obs;
  var djPrice = "".obs;

  var decorationEnabled = false.obs;
  var decorationPrice = "".obs;

  // Discount for multiple services
  var discountPercent = "".obs;

  // Location
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var address = ''.obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      Position pos = await _determinePosition();
      latitude.value = pos.latitude;
      longitude.value = pos.longitude;

      List<Placemark> placemarks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);
      Placemark place = placemarks.first;
      address.value =
      "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      address.value = "Location error: $e";
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Location services are disabled.';

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> saveData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;

      Map<String, dynamic> data = {
        "userId": user.uid,
        "type": providerType.value,
        "createdAt": DateTime.now().toIso8601String(),
        "location": {"lat": latitude.value, "lng": longitude.value},
        "approved": false, // <-- Add this line
      };

      if (providerType.value == "venue") {
        data.addAll({
          "venueName": venueName.value,
          "capacity": int.tryParse(capacity.value) ?? 0,
          "price": double.tryParse(price.value) ?? 0.0,
          "address": address.value,
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
        });
      }

      await _db.collection("providers").add(data);

      Get.snackbar("Success", "Details saved successfully! Awaiting admin approval.");
    } catch (e) {
      Get.snackbar("Error", "Failed to save: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setLocation(double lat, double lng) {
    latitude.value = lat;
    longitude.value = lng;
  }
}
