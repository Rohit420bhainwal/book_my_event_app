import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard/customer_dashboard_controller.dart';

class ChatInboxController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String userId;

  @override
  void onInit() {
    super.onInit();
    //userId = Get.arguments["userId"];
    userId = Get.find<CustomerDashboardController>().currentUserId;
    print("userId: $userId");
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> inboxStream() {
    return _firestore
        .collection("chat_rooms")
        .where("participants", arrayContains: userId)
        .orderBy("lastMessageTime", descending: true)
        .snapshots();
  }
}
