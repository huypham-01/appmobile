// form_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobile/utils/constants.dart';
import '../models/form_item.dart';
import 'api_service.dart';

class FormService {
  static String _geturl(String keyW) {
    if (keyW == "daily") {
      return "$baseUrl/cip3/index.php?c=DailyTaskController&m=getWiById&id=";
    } else if (keyW == "maintenance") {
      return "$baseUrl/cip3/index.php?c=MaintenanceController&m=getWIMaintenance&uuid=";
    } else {
      return "";
    }
  }

  static Future<FormResponse> loadFormById(String keyW, String uuid) async {
    try {
      final response = await http.get(Uri.parse("${_geturl(keyW)}$uuid"));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['status'] == 'success' &&
            body['data'] != null &&
            body['data'].isNotEmpty) {
          final detail = body['data'][0];

          // ⚡ schema là một string JSON => phải decode thêm lần nữa
          final schemaString = detail['schema'];
          final schemaJson = jsonDecode(schemaString);
          // parse ra list FormStepModel
          final steps = (schemaJson as List)
              .map((json) => FormStepModel.fromJson(json))
              .toList();

          final wiCode = detail['code'] ?? '';
          final formUuid = detail['uuid'] ?? '';

          return FormResponse.success(
            steps: steps,
            wiCode: wiCode,
            uuid: formUuid,
          );
        } else {
          return FormResponse.empty();
        }
      } else {
        throw Exception("Failed to load form");
      }
    } catch (e) {
      debugPrint("Error loading form: $e");
      return FormResponse.error(e.toString());
    }
  }

  static String _postUrl(String keyW) {
    if (keyW == "daily") {
      return "$baseUrl/cip3/index.php?c=DailyTaskController&m=doDailyTask";
    } else {
      return "$baseUrl/cip3/index.php?c=MaintenanceController&m=doDailyTask";
    }
  }

  static Future<bool> submitForm(
    String keyW,
    Map<String, dynamic> formData,
  ) async {
    try {
      final token = await ApiService.getToken();
      final inspectorId = await ApiService.getUserIdFromToken();
      formData['inspectorId'] = inspectorId;
      final response = await http
          .post(
            Uri.parse(_postUrl(keyW)),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(formData),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Submit Form Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);

        if (jsonRes["success"] == true ||
            jsonRes["success"].toString() == "true") {
          return true;
        } else {
          debugPrint("API Error: ${jsonRes}");
          return false;
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("SubmitForm Exception: $e");
      return false;
    }
  }
  // static Future<bool> submitForm(Map<String, dynamic> formData) async {
  //   try {
  //     final inspectorId = await ApiService.getUserIdFromToken();
  //     formData['inspectorId'] = inspectorId;

  //     final response = await http.post(
  //       Uri.parse(
  //         "$baseUrl/cip3/index.php?c=DailyTaskController&m=doDailyTask",
  //       ),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(formData),
  //     );

  //     if (response.statusCode == 200) {
  //       debugPrint('Form submitted successfully: ${response.body}');
  //       return true;
  //     } else {
  //       debugPrint('Submit failed: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     debugPrint('Error submitting form: $e');
  //     return false;
  //   }
  // }
}

class FormResponse {
  final bool isSuccess;
  final bool isEmpty;
  final List<FormStepModel>? steps;
  final String? wiCode;
  final String? uuid;
  final String? errorMessage;

  FormResponse._({
    required this.isSuccess,
    required this.isEmpty,
    this.steps,
    this.wiCode,
    this.uuid,
    this.errorMessage,
  });

  factory FormResponse.success({
    required List<FormStepModel> steps,
    required String wiCode,
    required String uuid,
  }) {
    return FormResponse._(
      isSuccess: true,
      isEmpty: false,
      steps: steps,
      wiCode: wiCode,
      uuid: uuid,
    );
  }

  factory FormResponse.empty() {
    return FormResponse._(isSuccess: false, isEmpty: true);
  }

  factory FormResponse.error(String message) {
    return FormResponse._(
      isSuccess: false,
      isEmpty: false,
      errorMessage: message,
    );
  }
}
