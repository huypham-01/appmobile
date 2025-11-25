import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSchedule {
  static Future<void> saveSchedule(List schedule) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("local_schedule", jsonEncode(schedule));
  }

  static Future<List<dynamic>> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString("local_schedule");
    if (jsonStr == null) return [];
    return jsonDecode(jsonStr);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("local_schedule");
  }
}