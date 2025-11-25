import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceAuth {
  static const Duration _timeout = Duration(seconds: 30);
  static Future<List<String>> getPermissions(String username) async {
    final url =
        "http://192.168.110.2/web_develop/iam/cip3/?c=PermissionController&m=getPermissionByUsername";

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"username": username}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body.map<String>((p) => p.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Login API
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
    String otp,
  ) async {
    ///////fmcs
    final url = Uri.parse(
      "http://192.168.110.2/web_develop/fmcs/Backend/login.php",
    );

    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {"username": username, "password": password, "otp": otp},
    );

    final body = jsonDecode(response.body);
    // print("test");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["status"] == "ok") {
        // Lưu token + user vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", data["token"]);
        await prefs.setString("user", jsonEncode(data["user"]));
        Map<String, dynamic> payload = Jwt.parseJwt(data["token"]);
        final usernameDecoded = payload["username"] ?? username;
        final permissions = await getPermissions(usernameDecoded);
        await prefs.setStringList("permissions", permissions);

        return {"success": true, "user": data["user"]};
      } else {
        return {"success": false, "message": data["message"] ?? "Login failed"};
      }
    } else {
      return {
        "success": false,
        "message": body["error"] ?? body["message"] ?? "Đăng nhập thất bại",
      };
    }
  }

  /// Lấy token từ SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  /// Lấy thông tin user từ SharedPreferences
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString("user");
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user");
    await prefs.remove("permissions");
  }

  /// Check login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
