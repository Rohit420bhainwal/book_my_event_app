import 'package:get/get.dart';
import '../../../app/services/api_service.dart';
import '../model/time_slot.dart';

class AvailabilityController extends GetxController {
  final String serviceId;
  AvailabilityController(this.serviceId);

  final ApiService api = ApiService();

  var selectedDays = <int>[].obs;
  var isLoading = false.obs;
  var hasAvailability = false.obs; // 👈 NEW

  @override
  void onInit() {
    super.onInit();
    print("serviceId: $serviceId");
    fetchAvailability();
  }

  /// TOGGLE WORKING DAY
  void toggleDay(int day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  /// FETCH EXISTING AVAILABILITY
  Future<void> fetchAvailability() async {
    try {
      isLoading.value = true;

      final res = await api.get(
        "provider/availability/$serviceId",
        withAuth: true,
      );

      print("AvailabilityRes: $res");

      selectedDays.assignAll(
        List<int>.from(res['data']['workingDays']),
      );

      hasAvailability.value = true; // 👈 EXISTING CONFIG FOUND
    } catch (_) {
      hasAvailability.value = false; // 👈 NO CONFIG YET
    } finally {
      isLoading.value = false;
    }
  }

  /// STATIC SLOTS (PHASE-1)
  List<TimeSlot> getStaticSlots() {
    return [
      TimeSlot(start: "10:00", end: "12:00", capacity: 2),
      TimeSlot(start: "14:00", end: "16:00", capacity: 1),
    ];
  }

  /// SAVE / UPDATE AVAILABILITY
  Future<void> saveAvailability() async {
    if (selectedDays.isEmpty) {
      Get.snackbar("Error", "Please select at least one working day");
      return;
    }

    isLoading.value = true;

    await api.post(
      "provider/availability",
      {
        "serviceId": serviceId,
        "workingDays": selectedDays,
        "slots": getStaticSlots().map((e) => e.toJson()).toList(),
      },
      withAuth: true,
    );

    isLoading.value = false;
    hasAvailability.value = true;

    Get.back();
    Get.snackbar(
      "Success",
      "Availability ${hasAvailability.value ? "updated" : "saved"} successfully",
    );
  }
}
