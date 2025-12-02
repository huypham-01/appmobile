// lib/fmcs/data/services/fmcs_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/fmcs/data/mock_data2.dart';
import 'package:mobile/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/device_response_model.dart';

class FmcsApiService {
  // final String baseUrl;
  final http.Client? client;

  FmcsApiService({http.Client? client}) : client = client ?? http.Client();

  /// Lấy token từ local storage
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Lấy tất cả dữ liệu thiết bị
  Future<DeviceResponseModel> getAllDevicesData() async {
    try {
      if (useMock) {
        return MockDeviceService.getAllDevicesData();
      }
      final response = await client!
          .get(
            Uri.parse('$baseUrl/fmcs/api.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return DeviceResponseModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found');
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: $e');
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, bool>> getDeviceActions(List<String> ids) async {
    final idString = ids.join(','); // gộp nhiều id
    final url =
        '$baseUrl/fmcs/api_action.php?action=count_open_actions_bulk&ids=$idString';

    final response = await client!.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final map = Map<String, dynamic>.from(jsonData['map']);
      return map.map((key, value) => MapEntry(key, value == true));
    } else {
      throw Exception('Failed to load device actions');
    }
  }

  Future<DeviceResponseModel> getAllDevicesDataWithAction() async {
    final response = await getAllDevicesData();

    // Lấy danh sách tất cả deviceId
    final ids = response.allTableData.map((d) => d.deviceId).toList();

    // Gọi API action
    final actionMap = await getDeviceActions(ids);

    // Gán action vào từng DeviceItem
    for (var device in response.allTableData) {
      device.action = actionMap[device.deviceId] ?? false;
    }

    return response;
  }

  static Future<ActionApiResponse> fetchActionData() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/fmcs/api_action.php?action=peek_codes"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return ActionApiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load action data");
    }
  }

  static Future<List<Issue>> fetchIssues(String deviceId) async {
    final url = Uri.parse(
      "$baseUrl/fmcs/api_action.php?action=list_actions&device_id=$deviceId",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Issue.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load issues");
    }
  }

  static Future<List<ActionPlan>> fetchActionPlans(int issueId) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/fmcs/api_action.php?action=list_action_plans&action_id=$issueId",
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ActionPlan.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load action plans");
    }
  }

  static Future<List<LocationItem>> fetchLocations() async {
    if (useMock) return MockLocationService.fetchLocations();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/fmcs/Backend/update_location.php?action=list_locations",
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List items = jsonData['items'];
      return items.map((e) => LocationItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load locations");
    }
  }

  static Future<List<DeviceItem>> fetchDevices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/fmcs/api.php'), // Adjust endpoint as needed
      headers: {
        'Content-Type': 'application/json',
        // Add authorization headers if needed, e.g., 'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => DeviceItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load devices: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> addDevice(
    Map<String, String> newData,
  ) async {
    try {
      if (useMock) {
        return await MockDeviceService.addDevice(newData);
      }
      final response = await http.post(
        Uri.parse("$baseUrl/fmcs/Backend/backend.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "action": "add",
          "device_id_add": newData["device_id"] ?? "",
          "system": newData["system"] ?? "",
          "location_id": newData["location"] ?? "",
          "frequency": newData["frequency"] ?? "",
          "freq_check_limit": newData["freq_check_limit"] ?? "",
          "temp_lower": newData["temp_lower"] ?? "",
          "temp_target": newData["temp_target"] ?? "",
          "temp_upper": newData["temp_upper"] ?? "",
          "humidity_lower": newData["humidity_lower"] ?? "",
          "humidity_target": newData["humidity_target"] ?? "",
          "humidity_upper": newData["humidity_upper"] ?? "",
          "pressure_lower": newData["pressure_lower"] ?? "",
          "pressure_target": newData["pressure_target"] ?? "",
          "pressure_upper": newData["pressure_upper"] ?? "",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      // throw Exception(
      //     '⚠️ Exception: $e',
      //   );
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateDevice(
    Map<String, String?> newData,
  ) async {
    try {
      if (useMock) {
        final deviceId = newData["device_id"] ?? "";
        return MockDeviceService.updateDeviceMock(deviceId, newData);
      }
      final response = await http.post(
        Uri.parse("$baseUrl/fmcs/Backend/backend.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "action": "update",
          "original_device_id": newData["device_id"] ?? "",
          "device_id_update": newData["device_id"] ?? "",
          "system": newData["system"] ?? "",
          "location_id": newData["location"] ?? "",
          "frequency": newData["frequency"] ?? "",
          "freq_check_limit": newData["freq_check_limit"] ?? "",
          "temp_lower": newData["temp_lower"] ?? "",
          "temp_target": newData["temp_target"] ?? "",
          "temp_upper": newData["temp_upper"] ?? "",
          "humidity_lower": newData["humidity_lower"] ?? "",
          "humidity_target": newData["humidity_target"] ?? "",
          "humidity_upper": newData["humidity_upper"] ?? "",
          "pressure_lower": newData["pressure_lower"] ?? "",
          "pressure_target": newData["pressure_target"] ?? "",
          "pressure_upper": newData["pressure_upper"] ?? "",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      // throw Exception(
      //     '⚠️ Exception: $e',
      //   );
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deteteDevice(
    Map<String, String> newData,
  ) async {
    try {
      if (useMock) {
        final deviceId = newData["device_id"] ?? "";
        return MockDeviceService.deleteDeviceMock(deviceId);
      }
      final response = await http.post(
        Uri.parse("$baseUrl/fmcs/Backend/backend.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "action": "delete",
          "device_id_delete": newData["device_id"] ?? "",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      // throw Exception(
      //     '⚠️ Exception: $e',
      //   );
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createActionWithPlans({
    // int? actionId,
    String? deviceId,
    String? title,
    String? issueType,
    List<Map<String, dynamic>>?
    plans, // [{plan_text:..., est_date:..., owner_name:...}]
    Map<String, dynamic>? metrics,
    Map<String, dynamic>? thresholds,
  }) async {
    if (useMock) {
      return MockDeviceService.createActionWithPlansMock(
        deviceId: deviceId ?? "",
        title: title ?? "",
        issueType: issueType,
        metrics: metrics ?? {},
        thresholds: thresholds ?? {},
        plans: plans ?? [],
      );
    }
    final token = await _getToken();
    final url = Uri.parse(
      "$baseUrl/fmcs/api_action.php?action=create_action_with_plans",
    );

    // body gửi dạng Map<String, String>
    final body = {
      // if (actionId != null) "action_id": actionId.toString(),
      if (deviceId != null) "device_id": deviceId,
      if (title != null) "title": title,
      if (issueType != null) "issue_type": issueType,
      "metrics_json": jsonEncode(metrics ?? {}),
      "thresholds_json": jsonEncode(thresholds ?? {}),
      "plans_json": jsonEncode(plans ?? []),
      "reason": "create action",
    };
    print(body);

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer $token", // bắt buộc login
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to create action with plans: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> updateActionPlanStatus({
    required int planId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/fmcs/api_action.php?action=update_action_plan_status",
    );
    final token = await _getToken();
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "plan_id": planId.toString(),
        "status": "done", // todo | in_progress | done | cancelled
        "reason": "update done action",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> deletedActionPlan({
    required int planId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/fmcs/api_action.php?action=delete_action_plan",
    );
    final token = await _getToken();
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {"plan_id": planId.toString()},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  /// Thêm location mới
  static Future<Map<String, dynamic>> addLocation({
    required String locationName,
    String? description,
  }) async {
    if (useMock) {
      return MockLocationService.addLocation(
        locationName: locationName,
        description: description,
      );
    }
    final token = await _getToken(); // nếu bạn có JWT login
    final url = Uri.parse("$baseUrl/fmcs/Backend/update_location.php");

    final body = {
      "action": "add_location",
      "location_name": locationName,
      "description": description ?? "",
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception("Invalid JSON: ${response.body}");
      }
    } else {
      throw Exception("Failed: ${response.statusCode} - ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> updateLocation({
    required int locationId,
    required String locationName,
    String? description,
  }) async {
    if (useMock) {
      return MockLocationService.updateLocation(
        id: locationId,
        locationName: locationName,
        description: description,
      );
    }
    final token = await _getToken(); // nếu bạn có login JWT
    final url = Uri.parse("$baseUrl/fmcs/Backend/update_location.php");

    final body = {
      "action": "update_location",
      "location_id": locationId.toString(),
      "location_name": locationName,
      "description": description ?? "",
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception("Invalid JSON: ${response.body}");
      }
    } else {
      throw Exception("Failed: ${response.statusCode} - ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> deleteLocation({
    required int locationId,
  }) async {
    if (useMock) {
      return MockLocationService.deleteLocation(locationId);
    }
    final token = await _getToken(); // lấy token nếu cần JWT
    final url = Uri.parse("$baseUrl/fmcs/Backend/update_location.php");

    final body = {
      "action": "delete_location",
      "location_id": locationId.toString(),
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception("Invalid JSON: ${response.body}");
      }
    } else {
      throw Exception("Failed: ${response.statusCode} - ${response.body}");
    }
  }

  static Future<List<ActionItem>> fetchActions() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/fmcs/api_action.php?action=list_actions_for_approval&approval=all",
      ),
      headers: {if (token != null) "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => ActionItem.fromJson(item)).toList();
    } else {
      throw Exception(
        "Failed to load actions ${response.statusCode} - ${response.body}",
      );
    }
  }

  static Future<List<ActionPlann>> fetchPlans(int actionId) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/fmcs/api_action.php?action=get_action_info&action_id=$actionId",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // lấy danh sách plans
      final plansJson = data['plans'] as List;

      return plansJson.map((p) => ActionPlann.fromJson(p)).toList();
    } else {
      throw Exception("Failed to load plans");
    }
  }

  static Future<Map<String, dynamic>> setActionApproval({
    required int actionId,
    required String value,
  }) async {
    final url = Uri.parse(
      "$baseUrl/fmcs/api_action.php?action=set_action_approval",
    );
    final token = await _getToken();
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {"action_id": actionId.toString(), "approval": value},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> deleteAction({
    required int actionId,
    required String reason,
  }) async {
    final url = Uri.parse("$baseUrl/fmcs/api_action.php?action=delete_action");
    final token = await _getToken();
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {"action_id": actionId.toString(), "reason": reason},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }
  /////
  ///

  /// Lấy dữ liệu theo system type
  Future<List<DeviceItem>> getDevicesBySystem(String systemType) async {
    try {
      final response = await client!
          .get(
            Uri.parse('$baseUrl/cmms/api/fmcs/devices/system/$systemType'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        return jsonData.map((e) => DeviceItem.fromJson(e)).toList();
      } else {
        throw Exception(
          'Failed to load devices by system: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting devices by system: $e');
    }
  }

  /// Lấy dữ liệu theo location
  Future<List<DeviceItem>> getDevicesByLocation(String location) async {
    try {
      final response = await client!
          .get(
            Uri.parse('$baseUrl/cmms/api/fmcs/devices/location/$location'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        return jsonData.map((e) => DeviceItem.fromJson(e)).toList();
      } else {
        throw Exception(
          'Failed to load devices by location: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting devices by location: $e');
    }
  }

  /// Lấy thông tin chi tiết một thiết bị
  Future<DeviceItem> getDeviceById(String deviceId) async {
    try {
      final response = await client!
          .get(
            Uri.parse('$baseUrl/cmms/api/fmcs/devices/$deviceId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return DeviceItem.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load device details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting device details: $e');
    }
  }

  /// Refresh data
  Future<DeviceResponseModel> refreshDevicesData() async {
    return await getAllDevicesData();
  }

  void dispose() {
    client?.close();
  }
}
