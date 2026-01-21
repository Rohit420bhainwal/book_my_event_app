import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../services/api_service.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();

  late String providerId;
  late String customerId;
  late String serviceId;
  late String serviceName;
  late String loggedInUserId;

  final chatId = "".obs;
  final isChatReady = false.obs;

  bool _hasMarkedSeen = false; // 🔥 IMPORTANT

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    providerId = args["providerId"].toString();
    customerId = args["customerId"].toString();
    serviceId = args["serviceId"].toString();
    serviceName = args["serviceName"].toString();
    loggedInUserId = args["loggedInUserId"];

    _createOrGetChatRoom();
  }

  /// ================= CHAT ROOM =================

  String _generateChatId() {
    return "${serviceId}_${customerId}_${providerId}";
  }

  Future<void> _createOrGetChatRoom() async {
    final id = _generateChatId();
    chatId.value = id;

    final ref = _firestore.collection("chat_rooms").doc(id);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      await ref.set({
        "customerId": customerId,
        "providerId": providerId,
        "serviceId": serviceId,
        "serviceName": serviceName,
        "participants": [customerId, providerId],
        "createdAt": FieldValue.serverTimestamp(),
        "unreadCounts": {
          customerId: 0,
          providerId: 0,
        }
      });
    }

    isChatReady.value = true;
  }

  /// ================= READ / DELIVERED / SEEN =================

  /// ✅ Called ONCE when chat screen opens
  Future<void> markChatAsSeen() async {
    if (_hasMarkedSeen) return;
    _hasMarkedSeen = true;

    final roomRef =
    _firestore.collection("chat_rooms").doc(chatId.value);

    // 1️⃣ Mark messages as SEEN
    final messagesRef = roomRef.collection("messages");
    final snapshot = await messagesRef
        .where("senderId", isNotEqualTo: loggedInUserId)
        .where("status", whereIn: ["sent", "delivered"])
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({"status": "seen"});
    }

    // 2️⃣ Reset unread ONLY for me
    await roomRef.update({
      "unreadCounts.$loggedInUserId": 0,
    });
  }

  /// ✅ Called when messages arrive on receiver device
  Future<void> markMessagesAsDelivered() async {
    final messagesRef = _firestore
        .collection("chat_rooms")
        .doc(chatId.value)
        .collection("messages");

    final snapshot = await messagesRef
        .where("senderId", isNotEqualTo: loggedInUserId)
        .where("status", isEqualTo: "sent")
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({"status": "delivered"});
    }
  }

  /// ================= STREAM =================

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream() {
    return _firestore
        .collection("chat_rooms")
        .doc(chatId.value)
        .collection("messages")
        .orderBy("createdAt")
        .snapshots();
  }

  /// ================= SEND MESSAGE =================

  Future<void> sendMessage(String text, String senderId) async {
    if (text.trim().isEmpty) return;

    final roomRef =
    _firestore.collection("chat_rooms").doc(chatId.value);

    final messageRef = roomRef.collection("messages").doc();

    final receiverId =
    senderId == customerId ? providerId : customerId;

    await messageRef.set({
      "senderId": senderId,
      "text": text,
      "createdAt": FieldValue.serverTimestamp(),
      "status": "sent", // ✅ SENT
    });

    await roomRef.update({
      "lastMessage": text,
      "lastMessageTime": FieldValue.serverTimestamp(),
      "unreadCounts.$receiverId": FieldValue.increment(1),
    });

    await _apiService.sendChatNotification(
      senderId: senderId,
      receiverId: receiverId,
      message: text,
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> otherUserStatusStream() {
    final otherUserId =
    loggedInUserId == customerId ? providerId : customerId;

    return _firestore
        .collection("users")
        .doc(otherUserId)
        .snapshots();
  }

  String get otherUserId {
    return loggedInUserId == customerId ? providerId : customerId;
  }

  bool isUserOnline(Timestamp? lastSeen) {
    if (lastSeen == null) return false;

    final last = lastSeen.toDate();
    final now = DateTime.now();

    return now.difference(last).inSeconds < 30;
  }


}
