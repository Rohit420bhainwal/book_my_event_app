import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProviderChatInboxController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String providerId;
  late String role;

  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();
    final userData = box.read("userData");
    // 🔥 Get logged-in providerId (Mongo ID)
    providerId = userData["user"]["id"].toString();
    print("providerId: $providerId");
    role = userData["user"]["role"].toString();

   // providerId = Get.arguments["userId"].toString();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> chatRoomsStream() {
    return _firestore
        .collection("chat_rooms")
        .where("participants", arrayContains: providerId)
        .orderBy("lastMessageTime", descending: true)
        .snapshots();
  }
}
