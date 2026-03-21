import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../routes/app_routes.dart';
import '../controller/chat_inbox_controller.dart';


class ChatInboxScreen extends StatelessWidget {
  ChatInboxScreen({super.key});

  final ChatInboxController controller =
  Get.put(ChatInboxController());



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.inboxStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No conversations yet"));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = docs[index].data();
              final chatId = docs[index].id;
              final unread =
              (chat["unreadCounts"]?[controller.userId] ?? 0) as int;


              final otherUserId =
              chat["customerId"] == controller.userId
                  ? chat["providerId"]
                  : chat["customerId"];

              return ListTile(
                leading: Stack(
                  children: [
                    const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: Colors.red,
                          child: Text(
                            unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                title: Text(
                  chat["serviceName"] ?? "Service",
                  style: TextStyle(
                    fontWeight:
                    unread > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),

                subtitle: Text(
                  chat["lastMessage"]?.isEmpty ?? true
                      ? "Say hi 👋"
                      : chat["lastMessage"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight:
                    unread > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),

                trailing: Text(
                  _formatTime(chat["lastMessageTime"]),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    unread > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),

                onTap: () {
                  Get.toNamed(
                    Routes.chatScreen,
                    arguments: {
                      "providerId": chat["providerId"],
                      "customerId": chat["customerId"],
                      "serviceId": chat["serviceId"],
                      "serviceName": chat["serviceName"],
                      "loggedInUserId": controller.userId,
                    },
                  );
                },
              );

            },
          );
        },
      ),
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (now.difference(date).inDays == 0) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day}/${date.month}/${date.year}";
  }
}
