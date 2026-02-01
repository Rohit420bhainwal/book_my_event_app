import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';

import '../app/services/fcm_service.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final isBusy = true.obs;
  var onboardingComplete = false;
  var status = "";

  @override
  void onInit() {
    super.onInit();
   // Future.microtask(() => FCMService.init());
    _runStartupChecks();
  }

  Future<void> _runStartupChecks() async {
    final startTime = DateTime.now(); // mark start time
    try {
      // 1️⃣ Fetch remote config
      final cfgSnap = await _db
          .collection(Constants.configCollection)
          .doc(Constants.appStatusDoc)
          .get();

      final data = cfgSnap.data() ?? {};
      final status = (data['status'] ?? {}) as Map<String, dynamic>;

      final bool downtime = (status['downtime'] ?? false) as bool;
      final String latestVersion =
          (status['latest_version'] ?? '1.0.0') as String;
      final bool mandatoryUpdate =
          (status['mandatory_update'] ?? false) as bool;
      final String updateMessage =
          (status['update_message'] ?? 'A new update is available.') as String;
      final String downtimeMessage = (status['downtime_message'] ??
          'We are under maintenance. Please try again later.') as String;

      // 2️⃣ Get app version
      final pkg = await PackageInfo.fromPlatform();
      final currentVersion = pkg.version;

      // 3️⃣ Handle downtime
      if (downtime) {
        await _ensureMinSplashTime(startTime);
        await _showDowntimeDialog(downtimeMessage);
        return;
      }

      // 4️⃣ Handle version updates
      final needsUpdate = _isRemoteNewer(latestVersion, currentVersion);
      if (needsUpdate) {
        await _ensureMinSplashTime(startTime);
        final proceed = await _showUpdateDialog(
          message:
              '$updateMessage\n\nCurrent: $currentVersion\nLatest: $latestVersion',
          mandatory: mandatoryUpdate,
        );
        if (!proceed) return;
      }

      // 5️⃣ Move to home after at least 3 seconds
      await _ensureMinSplashTime(startTime);
      _routeToHome();
    } catch (e) {
      await _ensureMinSplashTime(startTime);
      _routeToHome();
    } finally {
      isBusy.value = false;
    }
  }

  /// Ensures splash screen stays visible for at least 3 seconds
  Future<void> _ensureMinSplashTime(DateTime startTime) async {
    final elapsed = DateTime.now().difference(startTime);
    const minDuration = Duration(seconds: 3);
    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }
  }

  void _routeToHome() async {
    final box = GetStorage();
    final userData = box.read("userData");
    print("_routeToHome_userData: $userData");
    if (userData != null) {
      final token = userData["token"];
      final user = userData["user"];
      final providerInfo = userData["providerInfo"];
      final role = user["role"];
      final userId = user["id"];
      final customerCity = user["city"]??"";
      status = providerInfo["status"]??"";
      onboardingComplete = providerInfo["onboardingComplete"]??false;

      final providerIncomplete =
          box.read("providerOnboardingIncomplete") ?? false;

      List<dynamic> menuList = userData["menuList"] as List<dynamic>? ?? [];

      print("userRole: $role");
      print("providerIncomplete: $providerIncomplete");
      if (role == null || role.isEmpty) {
        Get.offAllNamed(Routes.roleSelection,
            arguments: {"userId": userId, "token": token});
      } else if (role == "provider" && status =="pending"&& !onboardingComplete) {
        Get.offAllNamed(Routes.providerOnboarding,
            arguments: {"userId": userId});
      } else if(role == "provider" && status =="pending"&& onboardingComplete){
        Get.offAllNamed(Routes.pendingApprovalScreen, arguments: {"userId": userId});
      }
      else if (role == "provider") {
        //Get.offAllNamed(Routes.transactionReceiptScreen);
        Get.offAllNamed(Routes.providerDashboard, arguments: {
          "menuList": menuList,
          "userId": userId,
          "roleName": role,
          "token": token,
        });
      } else if (role == "customer") {
        print("customerCity ");
        if(customerCity.toString().isEmpty){
          print("customerCity 1");
          Get.offAllNamed(
            Routes.selectCustomerCity,
            arguments: {
              "userId": userId,
            },
          );
        }else{
          Get.offAllNamed(Routes.customerDashboard, arguments: {
            "menuList": menuList,
            "userId": userId,
            "roleName": role,
            "token": token,
          });
        }

      }
    } else {
      print("here");
      Get.offAllNamed(Routes.login);
    }
  }

  bool _isRemoteNewer(String remote, String local) {
    List<int> parse(String v) =>
        v.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final r = parse(remote);
    final l = parse(local);
    final length = [r.length, l.length].reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < length; i++) {
      final rv = i < r.length ? r[i] : 0;
      final lv = i < l.length ? l[i] : 0;
      if (rv > lv) return true;
      if (rv < lv) return false;
    }
    return false;
  }

  Future<bool> _showUpdateDialog({
    required String message,
    required bool mandatory,
  }) async {
    bool allowProceed = !mandatory;

    await Get.defaultDialog(
      title: 'Update Available',
      content: Text(message, textAlign: TextAlign.center),
      barrierDismissible: !mandatory,
      confirm: ElevatedButton(
        onPressed: () async {
          final uri = Uri.parse(Constants.playStoreUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          if (mandatory) {
            if (Platform.isAndroid) {
              await Future.delayed(const Duration(milliseconds: 300));
              SystemNavigator.pop();
            }
          } else {
            Get.back();
          }
        },
        child: const Text('Update'),
      ),
      cancel: mandatory
          ? null
          : OutlinedButton(
              onPressed: () {
                allowProceed = true;
                Get.back();
              },
              child: const Text('Later'),
            ),
    );

    return allowProceed;
  }

  Future<void> _showDowntimeDialog(String message) async {
    await Get.defaultDialog(
      title: 'Maintenance',
      content: Text(message, textAlign: TextAlign.center),
      barrierDismissible: false,
      confirm: ElevatedButton(
        onPressed: () {
          SystemNavigator.pop();
        },
        child: const Text('Exit'),
      ),
    );
  }
}
