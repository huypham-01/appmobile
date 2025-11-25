// File: lib/data/models/equipment_model.dart

import 'package:intl/intl.dart';

class EquipmentData {
  final String uuid;
  final String machineId;
  final String family;
  final String model;
  final String cavity;
  final String manufacturer;
  final String manufacturingDate;
  final int historyCount;
  final String unit;
  final String category;

  EquipmentData({
    required this.uuid,
    required this.machineId,
    required this.family,
    required this.model,
    required this.cavity,
    required this.manufacturer,
    required this.manufacturingDate,
    required this.historyCount,
    required this.unit,
    required this.category,
  });

  factory EquipmentData.fromJson(Map<String, dynamic> json) {
    return EquipmentData(
      uuid: json['uuid'] ?? '',
      machineId: json['machine_id'] ?? 'N/A',
      family: json['family'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      cavity: json['cavity'] ?? 'N/A',
      manufacturer: json['manufacturer'] ?? 'N/A',
      manufacturingDate: json['manufacturing_date'] ?? 'N/A',
      historyCount:
          int.tryParse(json['history_count']?.toString() ?? '0') ??
          0, // ép về int
      unit: json['unit'] ?? 'N/A',
      category: json['category'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'machine_id': machineId,
      'family': family,
      'model': model,
      'cavity': cavity,
      'manufacturer': manufacturer,
      'manufacturing_date': manufacturingDate,
      'history_count': historyCount,
      'unit': unit,
      'category': category,
    };
  }

  // Convert to Map format để tương thích với code hiện tại
  Map<String, String> toDisplayMap() {
    return {
      "machineId": machineId,
      "name": "$machineId - $family",
      "model": model,
      "category": category,
      "status": _getRandomStatus(), // Tạm thời random status vì API không có
      "manufacturer": manufacturer, // Tạm thời dùng manufacturer làm position
      "uuid": uuid,
      "family": family,
      "cavity": cavity,
      "manufacturingDate": manufacturingDate,
      "historyCount": _formatNumber(historyCount),
      "unit": unit,
    };
  }

  // format số có dấu chấm ngăn cách
  String _formatNumber(int value) {
    return NumberFormat("#,###", "vi_VN").format(value);
  }

  // Tạm thời random status vì API không có field này
  String _getRandomStatus() {
    final statuses = ["Active", "Inactive", "Maintenance"];
    return statuses[uuid.hashCode % statuses.length];
  }

  @override
  String toString() {
    return 'EquipmentData{uuid: $uuid, machineId: $machineId, family: $family, model: $model, category: $category}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentData &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;
}

class EquipmentResponse {
  final String status;
  final String message;
  final List<EquipmentData> data;
  final int totalItems;
  final int totalPages;
  final int totalInAllPage;

  EquipmentResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.totalItems,
    required this.totalPages,
    required this.totalInAllPage,
  });

  factory EquipmentResponse.fromJson(Map<String, dynamic> json) {
    return EquipmentResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => EquipmentData.fromJson(item))
              .toList() ??
          [],
      totalItems: json['total_items'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      totalInAllPage: json['total_in_all_page'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'total_items': totalItems,
      'total_pages': totalPages,
      'total_in_all_page': totalInAllPage,
    };
  }

  @override
  String toString() {
    return 'EquipmentResponse{status: $status, message: $message, totalItems: $totalItems, totalPages: $totalPages}';
  }
}

class WIItem {
  final String code;
  final String wiId;
  final String schema;
  final String? countTarget;
  final String frequency;
  final String name;
  final String type;
  final String unitValue;
  final String unitType;

  WIItem({
    required this.code,
    required this.wiId,
    required this.schema,
    this.countTarget,
    required this.frequency,
    required this.name,
    required this.type,
    required this.unitValue,
    required this.unitType,
  });

  factory WIItem.fromJson(Map<String, dynamic> json) {
    return WIItem(
      code: json['code'],
      wiId: json['wi_id'],
      schema: json['schema'],
      countTarget: json["count_target"], // <-- thêm dòng này
      frequency: json["frequency"] ?? "", // <-- thêm dòng này
      name: json["name"] ?? "", // <-- thêm dòng này
      type: json["type"] ?? "", // <-- thêm dòng này
      unitValue: json["unit_value"] ?? "", // <-- thêm dòng này
      unitType: json["unit_type"] ?? "", // <-- thêm dòng này
    );
  }
}

class NextWIItem {
  final String code;
  final String type;
  final String countTarget;
  final String dateStart;

  NextWIItem({
    required this.code,
    required this.type,
    required this.countTarget,
    required this.dateStart,
  });

  factory NextWIItem.fromJson(Map<String, dynamic> json) {
    return NextWIItem(
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      countTarget: json['count_target']?.toString() ?? '',
      dateStart: json['date_start']?.toString() ?? '',
    );
  }
}
