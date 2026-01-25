import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../controller/chat_controller.dart';
import '../services/presence_service.dart';
import 'chat_bubble.dart';
import 'chat_input_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();
  late PresenceService presence;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    presence = PresenceService(controller.loggedInUserId);
  }


  @override
  Widget build(BuildContext context) {
    final loggedInUserId = controller.loggedInUserId;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.serviceName,
                style: const TextStyle(color: Colors.white)),

            /// 🔥 ONLINE / LAST SEEN
            StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref("presence")
                  .child(controller.otherUserId)
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Text(
                    "Offline",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  );
                }

                final data =
                Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map);

                final isOnline = data["online"] == true;
                final lastSeenMillis = data["lastSeen"] as int?;

                final lastSeen = lastSeenMillis != null
                    ? DateTime.fromMillisecondsSinceEpoch(lastSeenMillis)
                    : null;

                return Text(
                  isOnline
                      ? "Online"
                      : lastSeen != null
                      ? "Last seen ${DateFormat('hh:mm a').format(lastSeen)}"
                      : "Offline",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (!controller.isChatReady.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.messagesStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("Say hi 👋"));
                  }

                  // 🔥 MARK DELIVERED
                  controller.markMessagesAsDelivered();

                  // 🔥 MARK SEEN (THIS FIXES BLUE TICK)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    presence.setActiveChat(controller.chatId.value);
                    controller.markChatAsSeen();
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final msg = docs[index].data();
                      final isMe =
                          msg["senderId"] == loggedInUserId;

                      return ChatBubble(
                        message: msg["text"],
                        isMe: isMe,
                        time: msg["createdAt"],
                        status: msg["status"],
                      );
                    },
                  );
                },
              );
            }),
          ),

          ChatInputBar(
            onSend: (text) {
              controller.sendMessage(text, loggedInUserId);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    presence.clearActiveChat();
    super.dispose();
  }
}
