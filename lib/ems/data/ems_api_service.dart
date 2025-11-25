import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/machine_model.dart';

class EmsApiService {
  static const String baseUrl = "http://192.168.110.2/web_develop/ems/api.php";
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<List<Machine>> fetchMachine(String key) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl?action=get_machine_details&process=$key"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Machine.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load molds: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  static Future<List<IssueModel>> fetchIssues(String deviceId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.110.2/web_develop/ems/api.php?action=list_device_actions_v2&device_id=$deviceId',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Kiểm tra cấu trúc JSON
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          final List<dynamic> items = data['items'] ?? [];

          // Map từng item trong danh sách sang model
          return items.map((item) => IssueModel.fromJson(item)).toList();
        } else {
          throw Exception('API không trả về dữ liệu hợp lệ');
        }
      } else {
        throw Exception(
          'Failed to load issues. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching issues: $e');
    }
  }

  static Future<List<ActionPlann>> fetchActionPlans(int issueId) async {
    try {
      // 🔹 Endpoint ví dụ: /api/issues/{id}/plans
      final response = await http.get(
        Uri.parse(
          'http://192.168.110.2/web_develop/ems/api.php?action=list_action_plans&action_id=$issueId',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        return jsonData.map((e) => ActionPlann.fromJson(e)).toList();
      } else {
        throw Exception(
          'Failed to load action plans (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error fetching action plans: $e');
    }
  }

  static Future<EfficiencySummary> fetchEfficiencySummary() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.110.2/web_develop/ems/api.php?action=get_hourly_report&device_id=AC230802&report_date=2025-10-09',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return EfficiencySummary.fromJson(data);
      } else {
        throw Exception(
          'Failed to load efficiency data (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error fetching efficiency summary: $e');
    }
  }

  static Future<List<MachineRecord>> fetchMachineRecords({
    required String from,
    required String to,
    required String deviceId,
  }) async {
    final fromStr = Uri.encodeComponent(from.toString());
    final toStr = Uri.encodeComponent(to.toString());

    final url =
        'http://192.168.110.2/web_develop/ems/api.php?action=search_device&device_id=$deviceId&from=$fromStr&to=$toStr&limit=1000';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => MachineRecord.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load production records (status: ${response.statusCode})',
      );
    }
  }

  static Future<NextActionModel?> fetchNextAction() async {
    final url = Uri.parse(
      'http://192.168.110.2/web_develop/ems/api.php?action=preview_next_codes',
    ); // endpoint của bạn

    try {
      final token = await _getToken();
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // thêm token ở đây
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NextActionModel.fromJson(data);
      } else {
        print('API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Fetch NextAction error: $e');
      return null;
    }
  }

  static Future<SummaryReport?> fetchSummaryReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      // Encode ngày giờ cho URL
      final String fromStr = Uri.encodeComponent(
        from.toIso8601String().replaceFirst('T', ' ').split('.').first,
      );
      final String toStr = Uri.encodeComponent(
        to.toIso8601String().replaceFirst('T', ' ').split('.').first,
      );

      final url =
          '$baseUrl?action=get_summary_report&from=$fromStr&to=$toStr&_=${DateTime.now().millisecondsSinceEpoch}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SummaryReport.fromJson(data);
      } else {
        print('Failed to load summary report. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching summary report: $e');
      return null;
    }
  }

  static Future<List<Machine>> fetchMachineStatus(
    String processName,
    String status,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl?action=get_machine_details&process=$processName&status=$status",
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Machine.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load molds: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  static Future<DetailMachineResponse?> fetchMachineEfficiency(
    DateTime fromDate,
    DateTime toDate,
    String processName,
  ) async {
    // Format datetime thành kiểu backend PHP hiểu được: yyyy-MM-dd HH:mm:ss
    String formatDate(DateTime date) {
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
    }

    final from = formatDate(fromDate);
    final to = formatDate(toDate);

    final uri = Uri.parse('http://192.168.110.2/web_develop/ems/api.php')
        .replace(
          queryParameters: {
            'action': 'get_efficiency_report_data',
            'process': processName,
            'from': from,
            'to': to,
            'sort_by': 'machine_id',
            'sort_order': 'ASC',
          },
        );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return DetailMachineResponse.fromJson(jsonData);
      } else {
        print('Failed to load machine report: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching machine report: $e');
      return null;
    }
  }

  static Future<DetailMachineOutput?> fetchDetailMachineOutput({
    required DateTime fromDate,
    required DateTime toDate,
    required String processName,
    required String family,
  }) async {
    // Định dạng thời gian đúng như API PHP yêu cầu: yyyy-MM-dd HH:mm:ss
    String formatDate(DateTime date) {
      return "${date.year}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}:"
          "${date.second.toString().padLeft(2, '0')}";
    }

    final from = Uri.encodeComponent(formatDate(fromDate));
    final to = Uri.encodeComponent(formatDate(toDate));

    final url = Uri.parse(
      'http://192.168.110.2/web_develop/ems/api.php'
      '?action=get_output_report'
      '&process=$processName'
      '&from=$from'
      '&to=$to'
      '&family=$family',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return DetailMachineOutput.fromJson(jsonData);
      } else {
        print('❌ Failed to load output report: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error fetching output report: $e');
      return null;
    }
  }

  static Future<FamilyListResponse?> fetchFamilyList(String processName) async {
    final token = await _getToken();
    final url = Uri.parse(
      'http://192.168.110.2/web_develop/ems/api.php?action=get_families&process=$processName',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // thêm token ở đây
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return FamilyListResponse.fromJson(jsonData);
      } else {
        print('❌ Failed to load family list: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error fetching family list: $e');
      return null;
    }
  }

  static Future<DeviceResponse?> fetchDevices() async {
    final url = Uri.parse(
      'http://192.168.110.2/web_develop/ems/backend/backend.php?action=get_devices',
    );

    try {
      final token = await _getToken();
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // thêm token ở đây
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return DeviceResponse.fromJson(jsonData);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  /// create action
  static Future<Map<String, dynamic>> createActionWithPlans({
    required String deviceId,
    required String title,
    String? issueType,
    int? assignedTo,
    required List<Map<String, dynamic>> plans,
  }) async {
    final token = await _getToken();
    final url = Uri.parse(
      "http://192.168.110.2/web_develop/ems/api.php?action=create_action_public",
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['device_id'] = deviceId
      ..fields['title'] = title
      ..fields['issue_type'] = issueType ?? ''
      ..fields['assigned_to_user_id'] = assignedTo?.toString() ?? ''
      ..fields['short_form'] = jsonEncode(plans);

    // Có thể thêm cookie/session header nếu cần xác thực
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
      // hoặc nếu PHP backend đọc custom header:
      // request.headers['X-Access-Token'] = token;
    }
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to create action');
    }
  }

  static Future<Map<String, dynamic>> updateActionPlanStatus({
    required int planId,
  }) async {
    final url = Uri.parse("http://192.168.110.2/web_develop/ems/api.php");
    final token = await _getToken();
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "action": "update_action_plan_status",
        "plan_id": planId.toString(),
        "status": "done", // todo | in_progress | done | cancelled
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> addDevice(
    Map<String, String?> newData,
  ) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse("http://192.168.110.2/web_develop/ems/backend/backend.php"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: newData,
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
      final token = await _getToken();
      final response = await http.post(
        Uri.parse("http://192.168.110.2/web_develop/ems/backend/backend.php"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: newData,
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

  static Future<Map<String, dynamic>> deleteDevice(String id) async {
    try {
      final token =
          await _getToken(); // Nếu bạn đang dùng token giống các API khác
      final response = await http.post(
        Uri.parse("http://192.168.110.2/web_develop/ems/backend/backend.php"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {"action": "delete", "id": id},
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
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<List<ActionItemEms>> fetchActionItemEmss() async {
    final url = Uri.parse(
      'http://192.168.110.2/web_develop/ems/api.php?action=list_backend_issues',
    );
    final token = await _getToken();

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => ActionItemEms.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching issue actions: $e');
    }
  }

  static Future<Map<String, dynamic>> setActionApproval({
    required int actionId,
  }) async {
    final url = Uri.parse(
      "http://192.168.110.2/web_develop/ems/backend/backend.php",
    );
    final token = await _getToken();
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {"action": "approve_action", "action_id": actionId.toString()},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  static Future<List<ActionPlann>> fetchPlans(int actionId) async {
    final url = Uri.parse(
      "http://192.168.110.2/web_develop/ems/api.php?action=list_action_plans&action_id=$actionId",
    );
    final token = await _getToken();

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map((e) => ActionPlann.fromJson(e)).toList();
      }
    }

    return [];
  }

  static Future<bool> approveAction({
    required int actionId,
    required String reason,
  }) async {
    final url = Uri.parse(
      "http://192.168.110.2/web_develop/ems/backend/backend.php",
    );

    final token = await _getToken();

    final body = {
      "action": "approve_action",
      "action_id": actionId.toString(),
      "reason": reason,
    };

    final response = await http.post(
      url,
      body: body, // ⚠️ Không jsonEncode – backend dùng x-www-form-urlencoded
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"] == "success";
    } else {
      throw Exception("Approve failed: ${response.body}");
    }
  }

  static Future<bool> rejectedAction({
    required int actionId,
    required String reason,
  }) async {
    final url = Uri.parse(
      "http://192.168.110.2/web_develop/ems/backend/backend.php",
    );

    final token = await _getToken();

    final body = {
      "action": "reject_action",
      "action_id": actionId.toString(),
      "reason": reason,
    };

    final response = await http.post(
      url,
      body: body, // ⚠️ Không jsonEncode – backend dùng x-www-form-urlencoded
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"] == "success";
    } else {
      throw Exception("Approve failed: ${response.body}");
    }
  }

  static Future<bool> deleteAction({
    required int actionId,
    required String reason,
  }) async {
    final url = Uri.parse(
      "http://192.168.110.2/web_develop/ems/backend/backend.php",
    );

    final token = await _getToken();

    final body = {
      "action": "action_delete",
      "action_id": actionId.toString(), // phải là string
      "reason": reason,
    };

    final response = await http.post(
      url,
      body: body, // KHÔNG jsonEncode
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"] == "success";
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }
}

class ProductionApiService {
  final String baseUrl;

  ProductionApiService({required this.baseUrl});

  // Fetch production data from API
  Future<ProductionResponse> getProductionData({
    required DateTime fromDate,
    required DateTime toDate,
    String? family,
  }) async {
    try {
      String formatDate(DateTime date) {
        return "${date.year}-"
            "${date.month.toString().padLeft(2, '0')}-"
            "${date.day.toString().padLeft(2, '0')} "
            "${date.hour.toString().padLeft(2, '0')}:"
            "${date.minute.toString().padLeft(2, '0')}:"
            "${date.second.toString().padLeft(2, '0')}";
      }

      final from = Uri.encodeComponent(formatDate(fromDate));
      final to = Uri.encodeComponent(formatDate(toDate));
      final uri = Uri.parse(
        "http://192.168.110.2/web_develop/ems/api.php?action=get_output_report_bulk&from=$from&to=$to&proc=blister&families=$family",
      );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductionResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load production data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching production data: $e');
    }
  }

  // Convert ProductionResponse to list of ProductionData for Output tab
  List<ProductionData> getOutputDataList(ProductionResponse response) {
    List<ProductionData> result = [];

    response.matrix.forEach((familyName, familyData) {
      result.add(ProductionData.fromFamilyData(familyName, familyData));
    });

    // Sort by family name
    result.sort((a, b) => a.family.compareTo(b.family));

    return result;
  }

  // Convert ProductionResponse to list of EfficiencyData for Efficiency tab
  List<EfficiencyDataa> getEfficiencyDataList(ProductionResponse response) {
    List<EfficiencyDataa> result = [];

    response.matrix.forEach((familyName, familyData) {
      result.add(EfficiencyDataa.fromFamilyData(familyName, familyData));
    });

    // Sort by family name
    result.sort((a, b) => a.family.compareTo(b.family));

    return result;
  }

  // Get list of all families for dropdown
  List<String> getFamilyList(ProductionResponse response) {
    List<String> families = ['ALL'];
    families.addAll(response.matrix.keys);
    families.sort();
    return families;
  }

  ///
}
