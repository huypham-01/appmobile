// File: lib/services/equipment_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/cmms/data/mock_data.dart';
import 'package:mobile/cmms/data/services/api_service.dart';
import 'package:mobile/utils/constants.dart';

import '../models/equipment.dart';

class EquipmentService {
  // Cấu hình API
  static const String baseUrll = '$baseUrl/cmms/cip3/index.php';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Headers mặc định
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers với authentication (nếu cần)
  static Map<String, String> _getAuthHeaders(String? token) {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Lấy danh sách equipment từ API
  /// [page] - Số trang (mặc định = 1)
  /// [limit] - Số lượng item per page (mặc định = 10)
  /// [search] - Từ khóa tìm kiếm (optional)
  /// [category] - Lọc theo category (optional)
  /// [status] - Lọc theo status (optional)
  /// [token] - Authentication token (optional)
  static Future<EquipmentResponse> getEquipments({
    int page = 1,
    int limit = 1000000,
    String? search,
    String? category,
    String? status,
  }) async {
    if (useMock) {
      final mockJson = await MockEquipmentService.getEquipments(
        page: page,
        limit: limit,
        search: search,
        category: category,
        status: status,
      );
      return EquipmentResponse.fromJson(mockJson);
    }
    try {
      // Tạo query parameters
      final queryParams = <String, String>{
        'c': 'EquipmentController',
        'm': 'getAllEquipments',
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Thêm search parameter nếu có
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Thêm filter parameters nếu có
      if (category != null && category != 'All' && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (status != null && status != 'All' && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      // Tạo URI với query parameters
      final uri = Uri.parse(baseUrll).replace(queryParameters: queryParams);

      print('API Request: GET $uri'); // Debug log
      final token = await ApiService.getToken();
      // Gọi API
      final response = await http
          .get(uri, headers: _getAuthHeaders(token))
          .timeout(timeoutDuration);

      print('API Response Status: ${response.statusCode}'); // Debug log
      // print('API Response Body: ${response.body}'); // Debug log

      // Xử lý response
      return _handleResponse(response);
    } on SocketException {
      throw EquipmentException(
        'No internet connection. Please check your network connection.',
        type: EquipmentExceptionType.networkError,
      );
    } on http.ClientException catch (e) {
      throw EquipmentException(
        'Connection error: ${e.message}',
        type: EquipmentExceptionType.networkError,
      );
    } on FormatException {
      throw EquipmentException(
        'The returned data is not in the correct format.',
        type: EquipmentExceptionType.dataError,
      );
    } catch (e) {
      print('Unexpected error in getEquipments: $e'); // Debug log
      throw EquipmentException(
        'Unknown error: ${e.toString()}',
        type: EquipmentExceptionType.unknown,
      );
    }
  }

  /// Lấy thông tin chi tiết một equipment theo ID
  static Future<EquipmentData> getEquipmentById(String id) async {
    try {
      final queryParams = <String, String>{
        'c': 'EquipmentController',
        'm': 'getEquipmentById',
        'id': id,
      };

      final uri = Uri.parse(baseUrll).replace(queryParameters: queryParams);
      final token = await ApiService.getToken();
      final response = await http
          .get(uri, headers: _getAuthHeaders(token))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Nếu response có format như list response
        if (jsonData['status'] == 'success' && jsonData['data'] != null) {
          return EquipmentData.fromJson(jsonData['data']);
        }

        // Nếu response trực tiếp là equipment data
        return EquipmentData.fromJson(jsonData);
      } else {
        throw EquipmentException(
          'Không tìm thấy equipment với ID: $id',
          type: EquipmentExceptionType.notFound,
        );
      }
    } catch (e) {
      if (e is EquipmentException) rethrow;
      throw EquipmentException(
        'Lỗi khi lấy thông tin equipment: ${e.toString()}',
        type: EquipmentExceptionType.unknown,
      );
    }
  }

  /// Lấy thông tin chi tiết các WI trong một equipment theo ID
  static Future<Map<String, List<WIItem>>> getWIEquipmentById(String id) async {
    try {
      final queryParams = <String, String>{
        'c': 'WorkingInstructionController',
        'm': 'getWiByMachineId',
        'equipment_id': id,
      };

      final uri = Uri.parse(baseUrll).replace(queryParameters: queryParams);
      final token = await ApiService.getToken();
      final response = await http
          .get(uri, headers: _getAuthHeaders(token))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData["data"];

        /// Group theo type
        Map<String, List<WIItem>> grouped = {};
        for (var item in data) {
          String type = item["type"];
          WIItem wiItem = WIItem.fromJson(item);

          if (!grouped.containsKey(type)) {
            grouped[type] = [];
          }
          grouped[type]!.add(wiItem);
        }
        return grouped;
      } else {
        throw EquipmentException(
          'Failed to load WIEquipmentById: $id',
          type: EquipmentExceptionType.notFound,
        );
      }
    } catch (e) {
      if (e is EquipmentException) rethrow;
      throw EquipmentException(
        'Lỗi khi lấy thông tin WIequipmentbYId: ${e.toString()}',
        type: EquipmentExceptionType.unknown,
      );
    }
  }

  static Future<NextWIItem> getNextWorkingInstructionById(
    String equipmentId,
  ) async {
    try {
      final queryParams = <String, String>{
        'c': 'MaintenanceController',
        'm': 'getNextCountAndEstDate',
        'equipment_id': equipmentId,
      };

      final uri = Uri.parse(baseUrll).replace(queryParameters: queryParams);
      final token = await ApiService.getToken();
      final response = await http
          .get(uri, headers: _getAuthHeaders(token))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Nếu server trả dạng { "data": { ... } }
        if (jsonData['data'] != null) {
          return NextWIItem.fromJson(jsonData['data']);
        }

        // Nếu server trả trực tiếp object JSON
        return NextWIItem.fromJson(jsonData);
      } else {
        throw EquipmentException(
          'Không tìm thấy Working Instruction với ID: $equipmentId',
          type: EquipmentExceptionType.notFound,
        );
      }
    } catch (e) {
      if (e is EquipmentException) rethrow;
      throw EquipmentException(
        'Lỗi khi lấy Working Instruction: ${e.toString()}',
        type: EquipmentExceptionType.unknown,
      );
    }
  }

  /// Xử lý response từ API
  static EquipmentResponse _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          final jsonData = json.decode(response.body);
          return EquipmentResponse.fromJson(jsonData);
        } catch (e) {
          throw EquipmentException(
            'Unable to parse data from the server.',
            type: EquipmentExceptionType.dataError,
          );
        }

      case 400:
        throw EquipmentException(
          'Invalid request.',
          type: EquipmentExceptionType.badRequest,
        );

      case 401:
        throw EquipmentException(
          'Unauthorized access. Please log in again.',
          type: EquipmentExceptionType.unauthorized,
        );

      case 403:
        throw EquipmentException(
          'You do not have permission to perform this action.',
          type: EquipmentExceptionType.forbidden,
        );

      case 404:
        throw EquipmentException(
          'Data not found.',
          type: EquipmentExceptionType.notFound,
        );

      case 500:
      case 502:
      case 503:
        throw EquipmentException(
          'Server error. Please try again later.',
          type: EquipmentExceptionType.serverError,
        );

      default:
        throw EquipmentException(
          'Unknown error (${response.statusCode}): ${response.reasonPhrase}',
          type: EquipmentExceptionType.unknown,
        );
    }
  }
}

/// Custom exception class cho Equipment operations
class EquipmentException implements Exception {
  final String message;
  final EquipmentExceptionType type;
  final dynamic originalError;

  EquipmentException(this.message, {required this.type, this.originalError});

  @override
  String toString() => message;
}

/// Các loại lỗi có thể xảy ra
enum EquipmentExceptionType {
  networkError,
  dataError,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  unknown,
}
