import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProviderDetailController extends GetxController {
  final String listingId;
  ProviderDetailController(this.listingId);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var listing = <String, dynamic>{}.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchListingDetail();
  }

  void fetchListingDetail() {
    final user = _auth.currentUser;
    if (user == null) return;

    _db
        .collection("providers")
        .doc(user.uid)
        .collection("listings")
        .doc(listingId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        listing.value = doc.data() as Map<String, dynamic>;
      }
      isLoading.value = false;
    });
  }
}
