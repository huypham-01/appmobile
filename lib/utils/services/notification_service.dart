import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MaintenanceNotificationService {
  static const MethodChannel _channel = MethodChannel("maintenance/alarm");

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _dataKey = "maintenance_data";
  static const _messageKey = "maintenance_message";
  static const _titleKey = "maintenance_title";
  static const _localeKey = "current_locale";

  // ============================================================
  // 1. INIT (gọi trong main)
  // ============================================================
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _notifications.initialize(settings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        "maintenance_channel",
        "Maintenance",
        importance: Importance.max,
      ),
    );

    print("✅ MaintenanceNotificationService.init() completed");
  }

  // ============================================================
  // 2. LƯU NGÔN NGỮ HIỆN TẠI
  // ============================================================
  static Future<void> saveCurrentLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, langCode);
    print("🌐 Saved locale = $langCode");
  }

  // ============================================================
  // 3. FETCH API + XÂY DỰNG MESSAGE THEO NGÔN NGỮ
  // ============================================================
  static Future<void> fetchAndSaveMaintenanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString(_localeKey) ?? "en";
      final now = DateTime.now();

      // API 1
      final res1 = await http.get(
        Uri.parse(
          "http://192.168.110.2/web_develop/cmms/cip3/index.php"
          "?c=MaintenanceController&m=getMachineWithMaintenancePlan",
        ),
      );

      final decoded1 = jsonDecode(res1.body);
      final List machines = decoded1["data"] ?? [];

      final List<Map<String, dynamic>> out = [];
      final buffer = StringBuffer();

      for (final item in machines) {
        final id = item["uuid"];
        final machine = item["machine_id"];

        if (id == null || machine == null) continue;

        // API 2
        final res2 = await http.get(
          Uri.parse(
            "http://192.168.110.2/web_develop/cmms/cip3/index.php"
            "?c=MaintenanceController&m=getNextCountAndEstDate"
            "&equipment_id=$id",
          ),
        );

        final detail = jsonDecode(res2.body);
        final startStr = detail["date_start"];
        if (startStr == null) continue;

        final startDate = DateTime.tryParse(startStr);
        if (startDate == null) continue;

        final diff = startDate.difference(now).inDays;
        final line = _translateLine(lang, machine, diff);

        buffer.writeln(line);

        out.add({
          "machine": machine,
          "date_start": startStr,
          "diff_days": diff,
          "message": line,
        });
      }

      final summary = buffer.isEmpty
          ? _translateNoData(prefs.getString(_localeKey) ?? "en")
          : buffer.toString().trimRight();
      final title = translateTitle(lang);

      await prefs.setString(_dataKey, jsonEncode(out));
      await prefs.setString(_messageKey, summary);
      await prefs.setString(_titleKey, title);

      print("💾 Saved maintenance message:\n$summary");
    } catch (e) {
      print("❌ fetchAndSaveMaintenanceData error: $e");
    }
  }

  // ============================================================
  // 3A. HÀM DỊCH NGÔN NGỮ
  // ============================================================
  static String _translateLine(String lang, String machine, int diff) {
    switch (lang) {
      case "vi":
        if (diff < 0) return "$machine: đã quá hạn ${diff.abs()} ngày!";
        if (diff == 0) return "$machine: cần bảo trì HÔM NAY!";
        return "$machine: còn $diff ngày đến bảo trì";

      case "zh":
        if (diff < 0) return "$machine：超期 ${diff.abs()} 天！";
        if (diff == 0) return "$machine：今天需要维护！";
        return "$machine：还剩 $diff 天维护";

      case "en":
      default:
        if (diff < 0) return "$machine: overdue by ${diff.abs()} days!";
        if (diff == 0) return "$machine: maintenance TODAY!";
        return "$machine: $diff days remaining";
    }
  }

  static String _translateNoData(String lang) {
    switch (lang) {
      case "vi":
        return "Không có thiết bị cần bảo trì.";
      case "zh":
        return "今天没有维护设备。";
      default:
        return "No maintenance required.";
    }
  }

  static String translateTitle(String lang) {
    switch (lang) {
      case "vi":
        return "Nhắc nhở bảo trì máy";
      case "zh":
        return "设备维护提醒";
      case "zh-TW":
        return "設備維護提醒";
      default:
        return "Maintenance Reminder";
    }
  }

  // ============================================================
  // 4. ĐỌC MESSAGE
  // ============================================================
  static Future<String> _getSummaryMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_messageKey) ??
        _translateNoData(prefs.getString(_localeKey) ?? "en");
  }

  // ============================================================
  // 5. SCHEDULE ALARM HẰNG NGÀY 7:00 & 19:00
  // ============================================================
  static Future<void> scheduleDailyAlarms() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod("scheduleAlarm", {"hour": 11, "minute": 0});
        await _channel.invokeMethod("scheduleAlarm", {"hour": 19, "minute": 0});

        print("⏰ Android: scheduled alarms for 7:00 & 19:00");
      } catch (e) {
        print("❌ Android schedule error: $e");
      }
    }

    if (Platform.isIOS) {
      final msg = await _getSummaryMessage();
      await _iosSchedule(700, 7, 0, msg);
      await _iosSchedule(1900, 19, 0, msg);
    }
  }

  // ============================================================
  // 5A. iOS LOCAL SCHEDULE
  // ============================================================
  static Future<void> _iosSchedule(
    int id,
    int hour,
    int minute,
    String body,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (target.isBefore(now)) target = target.add(const Duration(days: 1));

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        "maintenance_channel",
        "Maintenance",
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      id,
      "Maintenance Reminder",
      body,
      target,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ============================================================
  // 6. HIỂN THỊ THÔNG BÁO NGAY (TEST)
  // ============================================================
  static Future<void> testNow() async {
    final msg = await _getSummaryMessage();
    print(msg);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        "maintenance_channel",
        "Maintenance",
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(888, "🔔 Test Notification", msg, details);
  }

  // ============================================================
  // 7. TEST ALARM NATIVE ANDROID (15 GIÂY)
  // ============================================================
  static Future<void> testAfterSeconds(int seconds) async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod("scheduleAlarmInSeconds", {
        "seconds": seconds,
      });
      print("⏰ Native Alarm scheduled ($seconds s)");
    } catch (e) {
      print("❌ scheduleAlarmInSeconds error: $e");
    }
  }
}
