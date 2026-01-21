import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VenueDetailsController extends GetxController {
  final RxMap<String, dynamic> venue;

  VenueDetailsController({required Map<String, dynamic> venue}) : venue = venue.obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var isLoading = true.obs;
  final box = GetStorage();
  var currentUserId = "".obs;

  @override
  void onInit() {
    final userData = box.read("userData");
    if (userData != null) {
      currentUserId.value = userData["user"]["id"] ?? "";
    }
    super.onInit();
  }

  Future<void> openDialer(String phoneNumber) async {
    final Uri launchUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not open dialer for $phoneNumber');
    }
  }


  /// 🔹 Launch URL safely (tel: or mailto:)
  Future<void> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        print('No app available to open this link');
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to open link: $e");
    }
  }
}
