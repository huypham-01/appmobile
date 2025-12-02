import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile/cmms/data/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../utils/constants.dart';
import '../../../utils/constants.dart';
import '../models/task_equipment_today.dart';
import 'api_service.dart';
// import '../repositories/task_equipment_today_repository.dart';

class InspectionService {
  // lấy dữ liệu các equipment
  static Future<List<TaskEquipmentToday>> fetchInspections({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    if (useMock) {
      final list = mockInspectionJson['data'] as List;
      return list.map((e) => TaskEquipmentToday.fromJson(e)).toList();
    }
    // Format dates to yyyy-MM-dd format
    final dateFormat = DateFormat('yyyy-MM-dd');
    final fromDate = dateFrom != null
        ? dateFormat.format(dateFrom)
        : dateFormat.format(DateTime.now());
    final toDate = dateTo != null
        ? dateFormat.format(dateTo)
        : dateFormat.format(DateTime.now());

    final url =
        "$baseUrl/cmms/cip3/index.php?c=DailyTaskController&m=get_today_equipments&date_from=$fromDate&date_to=$toDate";
    final token = await ApiService.getToken();
    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map || !decoded.containsKey('data')) {
      throw Exception("Unexpected JSON format: $decoded");
    }

    final list = (decoded['data'] as List);
    return list.map((e) => TaskEquipmentToday.fromJson(e)).toList();
  }

  // get maintenance
  static Future<List<TaskMaintenance>> fetchInspectionsMaintenance({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    if (useMock) {
      final list = (mockMaintenanceJson['data'] as List);
      return list.map((e) => TaskMaintenance.fromJson(e)).toList();
    }
    final url =
        "$baseUrl/cmms/cip3/index.php?c=MaintenanceController&m=getMachineWithMaintenancePlan";
    final token = await ApiService.getToken();
    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map || !decoded.containsKey('data')) {
      throw Exception("Unexpected JSON format: $decoded");
    }

    final list = (decoded['data'] as List);
    return list.map((e) => TaskMaintenance.fromJson(e)).toList();
  }

  // static Future<int> fetchInspectionCount() async {
  //   final token = await ApiService.getToken();
  //   final url =
  //       "$baseUrl/cmms/cip3/index.php?c=DailyTaskController&m=get_today_equipments";
  //   final res = await http.get(
  //     Uri.parse(url),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (res.statusCode != 200) {
  //     throw Exception("Failed to load inspection data");
  //   }

  //   final data = jsonDecode(res.body);
  //   return (data['data'] as List).length;
  // }
  // static Future<int> fetchMaintenanceCount() async {
  //   final token = await ApiService.getToken();
  //   final url =
  //       "$baseUrl/cmms/cip3/index.php?c=DailyTaskController&m=get_today_equipments";
  //   final res = await http.get(
  //     Uri.parse(url),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (res.statusCode != 200) {
  //     throw Exception("Failed to load inspection data");
  //   }

  //   final data = jsonDecode(res.body);
  //   return (data['data'] as List).length;
  // }

  //lấy các task trong equipment
  static Future<List<DetailTaskEquipment>> fetchEquipmentByUuid(
    String uuid,
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    // Bật mock thì trả về mock luôn
    if (useMock) {
      final list = mockEquipmentDetailJson['data'] as List;
      return list.map((e) => DetailTaskEquipment.fromJson(e)).toList();
    }
    final dateFormat = DateFormat('yyyy-MM-dd');
    final fromDate = dateFrom != null
        ? dateFormat.format(dateFrom)
        : dateFormat.format(DateTime.now());
    final toDate = dateTo != null
        ? dateFormat.format(dateTo)
        : dateFormat.format(DateTime.now());
    final token = await ApiService.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/cmms/cip3/index.php?c=DailyTaskController&m=getDailyTasksByEquipment&equipment_id=$uuid&dateFrom=$fromDate&dateTo=$toDate",
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> list = data['data']; // lấy mảng data từ API
      return list.map((e) => DetailTaskEquipment.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load DetailTaskEquipment.....");
    }
  }

  // lấy task trong maintenance
  static Future<List<DetailTaskMaintenance>> fetchMaintenanceByUuid(
    String uuid,
  ) async {
    if (useMock) {
      final list = mockMaintenanceDetailJson['data'] as List;
      return list.map((e) => DetailTaskMaintenance.fromJson(e)).toList();
    }
    final token = await ApiService.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/cmms/cip3/index.php?c=MaintenanceController&m=getMachineTaskById&equipment_id=$uuid",
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> list = data['data']; // lấy mảng data từ API
      return list.map((e) => DetailTaskMaintenance.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load DetailTaskEquipment.....");
    }
  }

  static Future<List<TaskOverDue>> fetchOverDue() async {
    if (useMock) {
      final list = mockOverdueJson['data'] as List;
      return list.map((e) => TaskOverDue.fromJson(e)).toList();
    }
    final token = await ApiService.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/cmms/cip3/index.php?c=EquipmentController&m=getMachineHaveOverdueTask",
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> list = data['data']; // lấy mảng data từ API
      return list.map((e) => TaskOverDue.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load OverDueTask.....");
    }
  }

  static Future<List<TaskOverDueDetail>> fetchOverDueDetail(String uuid) async {
    if (useMock) {
      final list = mockOverdueDetailJson['data'] as List;
      return list.map((e) => TaskOverDueDetail.fromJson(e)).toList();
    }
    final token = await ApiService.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/cmms/cip3/index.php?c=EquipmentController&m=getOverdueTasksByEquipment&equipment_id=$uuid",
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> list = data['data']; // lấy mảng data từ API
      return list.map((e) => TaskOverDueDetail.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load OverDueTaskDetail.....");
    }
  }

  // //lấy câu hỏi trong task
  // Future<List<QuestionTask>> featchQuestionTask(String uuid) async {
  //   final response = await http.get(
  //     Uri.parse("http://192.168.0.154:8000/api/forms/task/${uuid}"),
  //   );
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return QuestionTask.fromJson(data['form']);
  //   } else {
  //     throw Exception("Failed to load QuestionTask.....");
  //   }
  // }
  // static Future<Map<String, dynamic>?> fetchUpcomingMaintenance() async {
  //   try {
  //     final equipmentResponse = await http.get(
  //       Uri.parse(
  //         '$baseUrl/cmms/cip3/index.php?c=MaintenanceController&m=getMachineWithMaintenancePlan',
  //       ),
  //     );
  //     if (equipmentResponse.statusCode != 200) {
  //       print('❌ Lỗi API thiết bị: ${equipmentResponse.statusCode}');
  //       return null;
  //     }
  //     final equipmentJson = json.decode(equipmentResponse.body);
  //     final equipmentList = (equipmentJson['data'] as List)
  //         .map((e) => EquipmentData.fromJson(e))
  //         .toList();
  //     if (equipmentList.isEmpty) {
  //       print('⚠️ Không có thiết bị nào');
  //       return null;
  //     }
  //     Map<String, dynamic>? nearestMaintenance;
  //     int minDays = 999999;
  //     for (var equipment in equipmentList) {
  //       final taskResponse = await http.get(
  //         Uri.parse(
  //           '$baseUrl/cmms/cip3/index.php?c=MaintenanceController&m=getMachineTaskById&equipment_id=${equipment.uuid}',
  //         ),
  //       );
  //       if (taskResponse.statusCode != 200) continue;
  //       final taskJson = json.decode(taskResponse.body);
  //       final taskList = (taskJson['data'] as List)
  //           .map((e) => MaintenanceTask.fromJson(e))
  //           .toList();
  //       for (var task in taskList) {
  //         final remaining = task.countTarget - equipment.historyCount;
  //         if (equipment.dailyRate > 0) {
  //           final daysRemaining = (remaining / equipment.dailyRate).ceil();
  //           if (daysRemaining < minDays && daysRemaining >= 0) {
  //             minDays = daysRemaining;
  //             nearestMaintenance = {
  //               'equipmentName': equipment.machineId,
  //               'taskName': task.name,
  //               'taskType': task.type,
  //               'daysRemaining': daysRemaining,
  //               'countTarget': task.countTarget,
  //               'historyCount': equipment.historyCount,
  //               'message': buildNotificationMessage(
  //                 equipment.machineId,
  //                 task.type,
  //                 daysRemaining,
  //               ),
  //             };
  //           }
  //         }
  //       }
  //     }
  //     return nearestMaintenance;
  //   } catch (e) {
  //     print('❌ Lỗi tính toán bảo trì: $e');
  //     return null;
  //   }
  // }
}

class QuestionTaskService {
  Future<QuestionTask> fetchQuestionTask(String uuid) async {
    final token = await ApiService.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/cmms/forms/task/$uuid"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return QuestionTask.fromJson(data['form']); // 'form' là object
    } else {
      throw Exception("Failed to load QuestionTask");
    }
  }
}

class FormService {
  /// Gửi câu trả lời của inspector
  static Future<bool> submitAnswers({
    required String dailyTaskItemId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      // Lấy userId từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final inspectorId = prefs.getString("userId");

      if (inspectorId == null) {
        throw Exception("Không tìm thấy userId trong bộ nhớ");
      }

      final body = {
        "daily_task_item_id": dailyTaskItemId,
        "inspector_id": inspectorId,
        "answers": answers, // đã chuẩn bị từ controller
      };

      final response = await http.post(
        Uri.parse("$baseUrl/cmms/forms/submit"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await ApiService.getToken()}",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ Submit thành công: ${response.body}");
        return true;
      } else {
        print("❌ Submit thất bại: ${response.body}");
        return false;
      }
    } catch (e) {
      print("🔥 Lỗi submit: $e");
      return false;
    }
  }
}
