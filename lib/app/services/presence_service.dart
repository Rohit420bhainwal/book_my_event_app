import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';

class PresenceService with WidgetsBindingObserver {
  final String userId;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  late DatabaseReference _userStatusRef;
  late DatabaseReference _connectedRef;

  PresenceService(this.userId) {
    _userStatusRef = _db.child("presence").child(userId);
    _connectedRef = _db.child(".info/connected");
  }

  void start() {
    WidgetsBinding.instance.addObserver(this);

    _connectedRef.onValue.listen((event) {
      if (event.snapshot.value == true) {
        _setOnline();
      }
    });
  }

  /// 🔥 Call when chat screen opens
  Future<void> setActiveChat(String otherUserId) async {
    await _userStatusRef.update({
      "activeChatWith": otherUserId,
    });
  }

  /// 🔥 Call when chat screen closes
  Future<void> clearActiveChat() async {
    await _userStatusRef.child("activeChatWith").remove();
  }

  void _setOnline() {
    _userStatusRef.onDisconnect().set({
      "online": false,
      "lastSeen": ServerValue.timestamp,
    });

    _userStatusRef.update({
      "online": true,
      "lastSeen": ServerValue.timestamp,
    });
  }

  void _setOffline() {
    _userStatusRef.set({
      "online": false,
      "lastSeen": ServerValue.timestamp,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setOnline();
    } else {
      _setOffline();
    }
  }
}
