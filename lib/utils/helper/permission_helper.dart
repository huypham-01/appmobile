import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static const MethodChannel _channel = MethodChannel("maintenance/alarm");

  /// 🔥 Gọi khi mở app lần đầu
  static Future<void> requestAllPermissions(BuildContext context) async {
    await _requestNotificationPermission(context);
    await _requestExactAlarmPermission(context);
  }

  /// --------------------------------------------------------
  /// 1) QUYỀN THÔNG BÁO (ANDROID 13+ và iOS)
  /// --------------------------------------------------------
  static Future<void> _requestNotificationPermission(
    BuildContext context,
  ) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    var status = await Permission.notification.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.notification.request();
    }

    if (!status.isGranted) {
      _showDialog(
        context,
        title: "Enable Notifications",
        message:
            "This app needs notification permission to remind you at 7:00 and 19:00.",
        action: () => openAppSettings(),
      );
    }
  }

  /// --------------------------------------------------------
  /// 2) QUYỀN EXACT ALARM (ANDROID 12+)
  /// --------------------------------------------------------
  static Future<void> _requestExactAlarmPermission(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      final bool? canSchedule = await _channel.invokeMethod(
        "canScheduleExactAlarms",
      );

      if (canSchedule == true) return;

      _showDialog(
        context,
        title: "Allow Exact Alarm",
        message:
            "We need exact alarm permission to notify you exactly at 7:00 AM and 7:00 PM.",
        action: () => _channel.invokeMethod("openExactAlarmSettings"),
      );
    } catch (e) {
      debugPrint("Exact alarm not supported: $e");
    }
  }

  /// --------------------------------------------------------
  /// Popup reusable
  /// --------------------------------------------------------
  static void _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback action,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Open Settings"),
            onPressed: () {
              Navigator.pop(context);
              action();
            },
          ),
        ],
      ),
    );
  }
}
