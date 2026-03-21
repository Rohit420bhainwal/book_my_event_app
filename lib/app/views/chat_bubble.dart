import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final Timestamp? time;
  final String? status;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.time,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.greenAccent.shade100//.withValues(alpha: 0.65)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            /// MESSAGE TEXT
            Text(
              message,
              style: TextStyle(
                color: isMe
                    ? Colors.blueGrey.shade900 // 🔵 bluish sender text
                    : Colors.black87,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 4),

            /// TIME + STATUS
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (time != null)
                  Text(
                    DateFormat.Hm().format(time!.toDate()),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _statusIcon(status),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(String? status) {
    switch (status) {
      case "sent":
        return const Icon(Icons.check, size: 14, color: Colors.grey);
      case "delivered":
        return const Icon(Icons.done_all, size: 14, color: Colors.grey);
      case "seen":
        return const Icon(Icons.done_all, size: 14, color: Colors.blue);
      default:
        return const SizedBox();
    }
  }
}
