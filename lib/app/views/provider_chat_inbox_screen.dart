import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../routes/app_routes.dart';
import '../controller/provider_chat_inbox_controller.dart';

class ProviderChatInboxScreen extends StatelessWidget {
  ProviderChatInboxScreen({super.key});

  final controller = Get.put(ProviderChatInboxController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chats")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.chatRoomsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("No chats yet"));
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final chat = chats[index].data();
              final unread = chat["unreadCounts"]?[controller.providerId] ?? 0;

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(chat["serviceName"] ?? ""),
                subtitle: Text(
                  chat["lastMessage"] ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: unread > 0
                    ? CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    unread.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                )
                    : null,
                onTap: () {
                  Get.toNamed(
                    Routes.chatScreen,
                    arguments: {
                      "providerId": chat["providerId"],
                      "customerId": chat["customerId"],
                      "serviceId": chat["serviceId"],
                      "serviceName": chat["serviceName"],
                      "loggedInUserId": controller.providerId,
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
}
