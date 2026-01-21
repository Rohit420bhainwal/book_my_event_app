import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String generateChatId(
      String customerId, String providerId) {
    return customerId.compareTo(providerId) < 0
        ? "${customerId}_$providerId"
        : "${providerId}_$customerId";
  }

  Future<String> createOrGetChatRoom({
    required String customerId,
    required String providerId,
    required String serviceId,
    required String serviceName,
  }) async {
    final chatId =
    generateChatId(customerId, providerId);

    final chatRef =
    _firestore.collection("chat_rooms").doc(chatId);

    final snapshot = await chatRef.get();

    if (!snapshot.exists) {
      await chatRef.set({
        "chatId": chatId,
        "customerId": customerId,
        "providerId": providerId,
        "serviceId": serviceId,
        "serviceName": serviceName,
        "participants": [customerId, providerId],
        "lastMessage": "",
        "lastMessageTime": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }
}
