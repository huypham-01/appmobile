// lib/fmcs/data/models/device_response_model.dart

class DeviceResponseModel {
  final List<DeviceItem> allTableData;
  final List<DeviceItem> coolingTowerTableData;
  final List<DeviceItem> chillerTableData;
  final List<DeviceItem> vacuumTankTableData;
  final List<DeviceItem> airDryerTableData;
  final List<DeviceItem> compressorTableData;
  final List<DeviceItem> endpointAirPressureTableData;
  final List<DeviceItem> airTankTableData;
  final List<DeviceItem> airConditionerTableData;
  final List<DeviceItem> workshopTemperatureTableData;
  final int totalDevices;
  final int connectedDevices;
  final int disconnectedDevices;
  final int breachedDevices;

  DeviceResponseModel({
    required this.allTableData,
    required this.coolingTowerTableData,
    required this.chillerTableData,
    required this.vacuumTankTableData,
    required this.airDryerTableData,
    required this.compressorTableData,
    required this.endpointAirPressureTableData,
    required this.airTankTableData,
    required this.airConditionerTableData,
    required this.workshopTemperatureTableData,
    required this.totalDevices,
    required this.connectedDevices,
    required this.disconnectedDevices,
    required this.breachedDevices,
  });

  factory DeviceResponseModel.fromJson(Map<String, dynamic> json) {
    return DeviceResponseModel(
      allTableData:
          (json['all_tableData'] as List?)
              ?.map((e) => DeviceItem.fromJson(e))
              .toList() ??
          [],
      coolingTowerTableData:
          (json['cooling_tower_tableData'] as List?)
              ?.map((e) => DeviceItem.fromJson(e))
              .toList() ??
          [],
      chillerTableData:
          (json['chiller_tableData'] as List?)
              ?.map((e) => DeviceItem.fromJson(e))
              .toList() ??
          [],
      vacuumTankTableData:
          (json['vacuum_tank_tableData'] as List?)
              ?.map((e) => DeviceItem.fromJson(e))
              .toList() ??
          [],
      airDryerTableData:
          (json['air_dryer_tableData'] as List?)
              ?.map((e) => DeviceItem.fromJson(e))
              .toList() ??
          [],
      compressorTableData:
          (json['compressor_tableData'] as List?)
              ?.map((e) => DeviceItem.fromJson(e))
              .toList() ??
          [],
      endpointAirPressureTableData:
          (json['endpoint_air_pressure_tableData'] as List?)
              ?.map((e) => DeviceItem.fromJson(e))
              .toList() ??
          [],
      airTankTableData:
          (json['air_tank_tableData'] as List?)
              ?.map((e) => DeviceItem.fromJson(e))
              .toList() ??
          [],
      airConditionerTableData:
          (json['air_conditioner_tableData'] as List?)
              ?.map((e) => DeviceItem.fromJson(e))
              .toList() ??
          [],
      workshopTemperatureTableData:
          (json['workshop_temperature_tableData'] as List?)
              ?.map((e) => DeviceItem.fromJson(e))
              .toList() ??
          [],
      totalDevices: json['totalDevices'] ?? 0,
      connectedDevices: json['connectedDevices'] ?? 0,
      disconnectedDevices: json['disconnectedDevices'] ?? 0,
      breachedDevices: json['breachedDevices'] ?? 0,
    );
  }
}

class DeviceItem {
  final String system;
  final String location;
  final String deviceId;
  final String frequency;
  final String? tempLower;
  final String? tempTarget;
  final String? tempUpper;
  final String? humidityLower;
  final String? humidityTarget;
  final String? humidityUpper;
  final String? pressureLower;
  final String? pressureTarget;
  final String? pressureUpper;
  final String freqCheckLimit;
  final String? unit;
  final String? totalCountHours;
  final String? totalCountUpdateAt;
  final String? dataTime;
  final String status;
  final String temperature;
  final String humidity;
  final String pressure;
  final String connection;
  final double? temperatureRaw;
  final double? humidityRaw;
  final double? pressureRaw;
  final String? totalCount;
  final List<String> issues;

  bool action;

  DeviceItem({
    required this.system,
    required this.location,
    required this.deviceId,
    required this.frequency,
    this.tempLower,
    this.tempTarget,
    this.tempUpper,
    this.humidityLower,
    this.humidityTarget,
    this.humidityUpper,
    this.pressureLower,
    this.pressureTarget,
    this.pressureUpper,
    required this.freqCheckLimit,
    this.unit,
    this.totalCountHours,
    this.totalCountUpdateAt,
    this.dataTime,
    required this.status,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.connection,
    this.temperatureRaw,
    this.humidityRaw,
    this.pressureRaw,
    this.totalCount,
    required this.issues,

    this.action = false, // mặc định false
  });

  factory DeviceItem.fromJson(Map<String, dynamic> json) {
    return DeviceItem(
      system: json['system'] ?? '',
      location: json['location'] ?? '',
      deviceId: json['device_id'] ?? '',
      frequency: json['frequency']?.toString() ?? '',
      tempLower: json['temp_lower']?.toString(),
      tempTarget: json['temp_target']?.toString(),
      tempUpper: json['temp_upper']?.toString(),
      humidityLower: json['humidity_lower']?.toString(),
      humidityTarget: json['humidity_target']?.toString(),
      humidityUpper: json['humidity_upper']?.toString(),
      pressureLower: json['pressure_lower']?.toString(),
      pressureTarget: json['pressure_target']?.toString(),
      pressureUpper: json['pressure_upper']?.toString(),
      freqCheckLimit: json['freq_check_limit']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      totalCountHours: json['total_count_hours']?.toString() ?? '',
      totalCountUpdateAt: json['total_count_updated_at']?.toString() ?? '',
      dataTime: json['data_time'],
      status: json['status'] ?? '',
      temperature: json['temperature'] ?? 'N/A',
      humidity: json['humidity'] ?? 'N/A',
      pressure: json['pressure'] ?? 'N/A',
      connection: json['connection'] ?? '',
      temperatureRaw: json['temperature_raw']?.toDouble(),
      humidityRaw: json['humidity_raw']?.toDouble(),
      pressureRaw: json['pressure_raw']?.toDouble(),
      totalCount: json['total_count'] ?? 'N/A',
      issues:
          (json['issues'] as List?)?.map((e) => e.toString()).toList() ?? [],

      action: false, // gán sau khi gọi API action
    );
  }
}

class SystemCategory {
  final String name;
  final int count;

  SystemCategory({required this.name, required this.count});
}

enum DeviceStatus { normal, warning, critical, offline }

enum ConnectionStatus { connected, disconnected, connecting }

/// model action lấy id và plan id
class ActionApiResponse {
  final String issueCode;
  final List<String> planCodes;

  ActionApiResponse({required this.issueCode, required this.planCodes});

  factory ActionApiResponse.fromJson(Map<String, dynamic> json) {
    return ActionApiResponse(
      issueCode: json['issue_code'] as String,
      planCodes: List<String>.from(json['plan_codes']),
    );
  }
}

/// model lấy list action

class Issue {
  final int id;
  final String issueId;
  final String title;
  final String type;
  final String plannedCompletionDate;
  final String createdDate;
  final String creator;
  final int planCount;
  final String status;
  final String doneCount;
  final String approval;
  List<ActionPlan> actionPlans;

  Issue({
    required this.id,
    required this.issueId,
    required this.title,
    required this.type,
    required this.plannedCompletionDate,
    required this.createdDate,
    required this.creator,
    required this.status,
    required this.approval,
    required this.actionPlans,
    required this.doneCount,
    required this.planCount,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      issueId: json['action_code'], // mapping từ API
      title: json['title'] ?? '',
      type: json['issue_type'] ?? '',
      plannedCompletionDate: json['planned_max_date'] ?? '',
      createdDate: json['created_at'] ?? '',
      creator: json['created_by_name'] ?? '',
      status: json['status_text'] ?? '',
      approval: json['approval_status'] ?? '',
      doneCount: json['done_count'] ?? '',
      planCount: json['plan_count'] ?? 0,

      actionPlans: [], // chỗ này bạn call thêm 1 API con nếu cần action plans
    );
  }
}

class LocationItem {
  final int id;
  final String locationName;
  final String? description;

  LocationItem({
    required this.id,
    required this.locationName,
    this.description,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      id: json['id'],
      locationName: json['location_name'],
      description: json['description'],
    );
  }
}

class LocationResponse {
  final String status;
  final int page;
  final int pageSize;
  final int total;
  final List<LocationItem> items;

  LocationResponse({
    required this.status,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      status: json['status'],
      page: json['page'],
      pageSize: json['page_size'],
      total: json['total'],
      items: (json['items'] as List)
          .map((e) => LocationItem.fromJson(e))
          .toList(),
    );
  }
}

class ActionItem {
  final int id;
  final String deviceId;
  final String actionCode;
  final String title;
  final String issueType;
  final String createdAt;
  final String? createdByName;
  final String approvalStatus;
  final int planCount;
  final String? doneCount;
  final String statusText;
  final String? plannedMaxDate;
  final List<ActionPlann>? plans;

  ActionItem({
    required this.id,
    required this.deviceId,
    required this.actionCode,
    required this.title,
    required this.issueType,
    required this.createdAt,
    this.createdByName,
    required this.approvalStatus,
    required this.planCount,
    this.doneCount,
    required this.statusText,
    this.plannedMaxDate,
    this.plans,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      id: json['id'] as int,
      deviceId: json['device_id'] ?? '',
      actionCode: json['action_code'] ?? '',
      title: json['title'] ?? '',
      issueType: json['issue_type'] ?? '',
      createdAt: json['created_at'] ?? '',
      createdByName: json['created_by_name'],
      approvalStatus: json['approval_status'] ?? '',
      planCount: json['plan_count'] ?? 0,
      doneCount: json['done_count'],
      statusText: json['status_text'] ?? '',
      plannedMaxDate: json['planned_max_date'],
      plans: (json['plans'] as List<dynamic>?)
          ?.map((e) => ActionPlann.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'action_code': actionCode,
      'title': title,
      'issue_type': issueType,
      'created_at': createdAt,
      'created_by_name': createdByName,
      'approval_status': approvalStatus,
      'plan_count': planCount,
      'done_count': doneCount,
      'status_text': statusText,
      'planned_max_date': plannedMaxDate,
      'plans': plans?.map((e) => e.toJson()).toList(),
    };
  }

  ActionItem copyWith({
    int? id,
    String? deviceId,
    String? actionCode,
    String? title,
    String? issueType,
    String? createdAt,
    String? createdByName,
    String? approvalStatus,
    int? planCount,
    String? doneCount,
    String? statusText,
    String? plannedMaxDate,
    List<ActionPlann>? plans,
  }) {
    return ActionItem(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      actionCode: actionCode ?? this.actionCode,
      title: title ?? this.title,
      issueType: issueType ?? this.issueType,
      createdAt: createdAt ?? this.createdAt,
      createdByName: createdByName ?? this.createdByName,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      planCount: planCount ?? this.planCount,
      doneCount: doneCount ?? this.doneCount,
      statusText: statusText ?? this.statusText,
      plannedMaxDate: plannedMaxDate ?? this.plannedMaxDate,
      plans: plans ?? this.plans,
    );
  }
}

class ActionPlann {
  final int id;
  final String planCode;
  final String planText;
  final String? estDate;
  final String? ownerName;
  final String status;

  ActionPlann({
    required this.id,
    required this.planCode,
    required this.planText,
    this.estDate,
    this.ownerName,
    required this.status,
  });

  factory ActionPlann.fromJson(Map<String, dynamic> json) {
    return ActionPlann(
      id: json['id'] ?? 0,
      planCode: json['plan_code'] ?? '',
      planText: json['plan_text'] ?? '',
      estDate: json['est_date'],
      ownerName: json['owner_name'],
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_code': planCode,
      'plan_text': planText,
      'est_date': estDate,
      'owner_name': ownerName,
      'status': status,
    };
  }
}

class ActionPlan {
  final int id;
  final int actionId;
  final String actionCode;
  final String planCode;
  final String planText;
  final String status;
  final String? issueNote;
  final String? estDate;
  final int? planOrder;
  final String approvalStatus;
  final String? actualDate;
  final String? resultNote;
  final int? ownerUserId;
  final String? ownerName;
  final int? completedByUserId;
  final String? attachmentUrl;
  final String createdAt;

  ActionPlan({
    required this.id,
    required this.actionId,
    required this.actionCode,
    required this.planCode,
    required this.planText,
    required this.status,
    this.issueNote,
    this.estDate,
    this.planOrder,
    required this.approvalStatus,
    this.actualDate,
    this.resultNote,
    this.ownerUserId,
    this.ownerName,
    this.completedByUserId,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory ActionPlan.fromJson(Map<String, dynamic> json) {
    return ActionPlan(
      id: json['id'],
      actionId: json['action_id'],
      actionCode: json['action_code'],
      planCode: json['plan_code'],
      planText: json['plan_text'],
      status: json['status'],
      issueNote: json['issue_note'],
      estDate: json['est_date'],
      planOrder: json['plan_order'],
      approvalStatus: json['approval_status'],
      actualDate: json['actual_date'],
      resultNote: json['result_note'],
      ownerUserId: json['owner_user_id'],
      ownerName: json['owner_name'],
      completedByUserId: json['completed_by_user_id'],
      attachmentUrl: json['attachment_url'],
      createdAt: json['created_at'],
    );
  }
}
