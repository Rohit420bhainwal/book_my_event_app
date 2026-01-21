import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';

class PresenceService with WidgetsBindingObserver {
  final String userId;

  final DatabaseReference _db =
  FirebaseDatabase.instance.ref();

  late DatabaseReference _userStatusRef;
  late DatabaseReference _connectedRef;

  PresenceService(this.userId) {
    _userStatusRef = _db.child("presence").child(userId);
    _connectedRef = _db.child(".info/connected");
  }

  void start() {
    WidgetsBinding.instance.addObserver(this);

    _connectedRef.onValue.listen((event) {
      final connected = event.snapshot.value == true;

      if (connected) {
        _setOnline();
      }
    });
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOffline();
  }

  void _setOnline() {
    _userStatusRef.onDisconnect().set({
      "online": false,
      "lastSeen": ServerValue.timestamp,
    });

    _userStatusRef.set({
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
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _setOffline();
    }
  }
}
