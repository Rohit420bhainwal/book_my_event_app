import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  static String? _activeChatUserId;

  static void setActiveChat(String userId) {
    _activeChatUserId = userId;
  }

  static void clearActiveChat() {
    _activeChatUserId = null;
  }

  static bool isChatOpenWith(String senderId) {
    return _activeChatUserId == senderId;
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    providerId = args["providerId"].toString();
    customerId = args["customerId"].toString();
    serviceId = args["serviceId"].toString();
    serviceName = args["serviceName"].toString();
    loggedInUserId = args["loggedInUserId"];

    print("Firebase UID: ${FirebaseAuth.instance.currentUser?.uid}");
    print("loggedInUserId: $loggedInUserId");

    _createOrGetChatRoom();
  }

  // ================= CHAT ROOM =================

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

  // ================= SEEN / DELIVERED =================

  /// 🔥 MARK SEEN — SAFE TO CALL MULTIPLE TIMES
  Future<void> markChatAsSeen() async {
    if (!isChatReady.value) return;

    final roomRef =
    _firestore.collection("chat_rooms").doc(chatId.value);

    final messagesRef = roomRef.collection("messages");

    final snapshot = await messagesRef
        .where("senderId", isNotEqualTo: loggedInUserId)
        .where("status", whereIn: ["sent", "delivered"])
        .get();

    if (snapshot.docs.isEmpty) return;

    for (final doc in snapshot.docs) {
      await doc.reference.update({"status": "seen"});
    }

    await roomRef.update({
      "unreadCounts.$loggedInUserId": 0,
    });
  }

  /// 🔥 MARK DELIVERED
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

  // ================= STREAM =================

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream() {
    return _firestore
        .collection("chat_rooms")
        .doc(chatId.value)
        .collection("messages")
        .orderBy("createdAt")
        .snapshots();
  }

  // ================= SEND MESSAGE =================

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
      "status": "sent",
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

  // ================= ONLINE STATUS =================

  String get otherUserId {
    return loggedInUserId == customerId ? providerId : customerId;
  }
}
