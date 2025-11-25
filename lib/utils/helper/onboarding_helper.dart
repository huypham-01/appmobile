import 'package:shared_preferences/shared_preferences.dart';

class OnboardingHelper {
  static const String _key = 'isFirstTime';

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true; // mặc định lần đầu là true
  }

  static Future<void> setFirstTimeFalse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
  }
}