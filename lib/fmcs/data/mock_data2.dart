import 'dart:convert';

import 'package:mobile/fmcs/data/models/device_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final DeviceResponseModel mockApiResponse = DeviceResponseModel(
  allTableData: List.generate(
    10,
    (index) => DeviceItem(
      system: 'System ${index % 3 + 1}',
      location: 'Location ${index % 4 + 1}',
      deviceId: 'DEV-${100 + index}',
      frequency: '1h',
      freqCheckLimit: '1h',
      tempLower: null,
      tempTarget: null,
      tempUpper: null,
      humidityLower: '40',
      humidityTarget: '50',
      humidityUpper: '60',
      pressureLower: '30',
      pressureTarget: '35',
      pressureUpper: '40',
      unit: 'unit',
      totalCountHours: '${index * 5}',
      totalCountUpdateAt: '2025-11-27 08:0${index}',
      dataTime: '2025-11-27 08:1${index}',
      status: index % 4 == 0
          ? 'Critical'
          : index % 3 == 0
          ? 'Warning'
          : 'Normal',
      temperature: '${20 + index}',
      humidity: '${50 + index}',
      pressure: '${30 + index}',
      connection: index % 2 == 0 ? 'Connected' : 'Disconnected',
      temperatureRaw: 20.0 + index,
      humidityRaw: 50.0 + index,
      pressureRaw: 11.0 + index,
      totalCount: '${index * 10}',
      issues: index % 3 == 0 ? ['Issue ${index}'] : [],
      action: true,
    ),
  ),
  coolingTowerTableData: List.generate(
    3,
    (index) => DeviceItem(
      system: 'Cooling Tower',
      location: 'CT Location $index',
      deviceId: 'CT-${index + 1}',
      frequency: '2h',
      freqCheckLimit: '2h',
      tempLower: '20',
      tempTarget: '24',
      tempUpper: '28',
      humidityLower: null,
      humidityTarget: null,
      humidityUpper: null,
      pressureLower: '22',
      pressureTarget: '25',
      pressureUpper: '27',
      unit: 'unit',
      totalCountHours: '10',
      totalCountUpdateAt: '2025-11-27 09:09',
      dataTime: '2025-11-27 09:1${index}',
      status: 'Normal',
      temperature: '${25 + index}',
      humidity: '${60 + index}',
      pressure: '15',
      connection: 'Connected',
      temperatureRaw: 25.0 + index,
      humidityRaw: 60.0 + index,
      pressureRaw: 20.0 + index,
      totalCount: '50',
      issues: [],
      action: true,
    ),
  ),
  chillerTableData: List.generate(
    3,
    (index) => DeviceItem(
      system: 'Air Conditioner',
      location: 'CH Location $index',
      deviceId: 'CH-${index + 1}',
      frequency: '2h',
      freqCheckLimit: '2h',
      tempLower: '19',
      tempTarget: '23',
      tempUpper: '27',
      humidityLower: '42',
      humidityTarget: '52',
      humidityUpper: '62',
      pressureLower: null,
      pressureTarget: null,
      pressureUpper: null,
      unit: 'unit',
      totalCountHours: '8',
      totalCountUpdateAt: '2025-11-27 10:10',
      dataTime: '2025-11-27 10:1${index}',
      status: 'Warning',
      temperature: '${22 + index}',
      humidity: '${55 + index}',
      pressure: '${10 + index}',
      connection: 'Disconnected',
      temperatureRaw: 22.0 + index,
      humidityRaw: 55.0 + index,
      pressureRaw: 8 + index * 0.1,
      totalCount: '30',
      issues: ['Overheat'],
      action: true,
    ),
  ),
  vacuumTankTableData: [], // bạn có thể thêm tương tự
  airDryerTableData: [],
  compressorTableData: [],
  endpointAirPressureTableData: [],
  airTankTableData: [],
  airConditionerTableData: [],
  workshopTemperatureTableData: [],
  totalDevices: 16,
  connectedDevices: 9,
  disconnectedDevices: 7,
  breachedDevices: 3,
);

class MockLocationService {
  // Fake database (list nằm trong RAM)
  static final List<LocationItem> _mockLocations = [
    LocationItem(id: 2, locationName: "Arjun", description: ""),
    LocationItem(id: 6, locationName: "Arjun/UL", description: ""),
    LocationItem(id: 1, locationName: "PG", description: null),
    LocationItem(id: 13, locationName: "PG/Arjun", description: ""),
    LocationItem(id: 5, locationName: "PG/Arjun/UL", description: null),
    LocationItem(id: 3, locationName: "UL", description: null),
  ];

  // ======= GET ========
  static Future<List<LocationItem>> fetchLocations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockLocations);
  }

  // ======= ADD ========
  static Future<Map<String, dynamic>> addLocation({
    required String locationName,
    String? description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newItem = LocationItem(
      id: DateTime.now().millisecondsSinceEpoch, // fake ID
      locationName: locationName,
      description: description,
    );

    _mockLocations.add(newItem);

    return {
      "status": "ok",
      "message": "Mock add success",
      "item": newItem.toJson(),
    };
  }

  // ======= UPDATE ========
  static Future<Map<String, dynamic>> updateLocation({
    required int id,
    required String locationName,
    String? description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockLocations.indexWhere((e) => e.id == id);

    if (index == -1) {
      return {"status": "error", "message": "Location not found"};
    }

    _mockLocations[index] = LocationItem(
      id: id,
      locationName: locationName,
      description: description,
    );

    return {"status": "ok", "message": "Mock update success"};
  }

  // ======= DELETE ========
  static Future<Map<String, dynamic>> deleteLocation(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _mockLocations.removeWhere((e) => e.id == id);

    return {"status": "ok", "message": "Mock delete success"};
  }
}

class MockDeviceService {
  static final List<DeviceItem> _mockDevices = [
    ...mockApiResponse.allTableData.map(
      (d) => DeviceItem(
        system: d.system,
        location: d.location,
        locationId: 1, // map tùy ý, ví dụ mặc định 1
        deviceId: d.deviceId,
        frequency: d.frequency,
        freqCheckLimit: d.freqCheckLimit,
        tempLower: d.tempLower,
        tempTarget: d.tempTarget,
        tempUpper: d.tempUpper,
        humidityLower: d.humidityLower,
        humidityTarget: d.humidityTarget,
        humidityUpper: d.humidityUpper,
        pressureLower: d.pressureLower,
        pressureTarget: d.pressureTarget,
        pressureUpper: d.pressureUpper,
        unit: d.unit,
        totalCountHours: d.totalCountHours,
        totalCountUpdateAt: d.totalCountUpdateAt,
        dataTime: d.dataTime,
        status: d.status,
        temperature: d.temperature,
        humidity: d.humidity,
        pressure: d.pressure,
        connection: d.connection,
        temperatureRaw: d.temperatureRaw,
        humidityRaw: d.humidityRaw,
        pressureRaw: d.pressureRaw,
        totalCount: d.totalCount,
        issues: d.issues,
        action: d.action,
      ),
    ),
    ...mockApiResponse.coolingTowerTableData,
    ...mockApiResponse.chillerTableData,
  ];
  static Future<DeviceResponseModel> getAllDevicesData() async {
    await Future.delayed(const Duration(milliseconds: 300)); // mô phỏng loading
    return DeviceResponseModel(
      allTableData: _mockDevices
          .where((d) => d.system != 'Cooling Tower' && d.system != 'Chiller')
          .toList(),
      coolingTowerTableData: _mockDevices
          .where((d) => d.system == 'Cooling Tower')
          .toList(),
      chillerTableData: _mockDevices
          .where((d) => d.system == 'Chiller')
          .toList(),
      vacuumTankTableData: [],
      airDryerTableData: [],
      compressorTableData: [],
      endpointAirPressureTableData: [],
      airTankTableData: [],
      airConditionerTableData: [],
      workshopTemperatureTableData: [],
      totalDevices: _mockDevices.length,
      connectedDevices: _mockDevices
          .where((d) => d.connection == 'Connected')
          .length,
      disconnectedDevices: _mockDevices
          .where((d) => d.connection == 'Disconnected')
          .length,
      breachedDevices: _mockDevices.where((d) => d.status == 'Critical').length,
    );
  }

  // ==== ADD DEVICE ====
  static Future<Map<String, dynamic>> addDevice(
    Map<String, String> newData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final DeviceItem newDevice = DeviceItem(
      system: newData["system"] ?? "",
      location: "Mock Location", // bạn có thể map từ location ID ra tên
      deviceId: newData["device_id"] ?? "",
      frequency: newData["frequency"] ?? "",
      freqCheckLimit: newData["freq_check_limit"] ?? "",
      tempLower: newData["temp_lower"] ?? "",
      tempTarget: newData["temp_target"] ?? "",
      tempUpper: newData["temp_upper"] ?? "",
      humidityLower: newData["humidity_lower"],
      humidityTarget: newData["humidity_target"],
      humidityUpper: newData["humidity_upper"],
      pressureLower: newData["pressure_lower"] ?? "",
      pressureTarget: newData["pressure_target"] ?? "",
      pressureUpper: newData["pressure_upper"] ?? "",
      unit: 'unit',
      totalCountHours: "0",
      totalCountUpdateAt: DateTime.now().toString(),
      dataTime: DateTime.now().toString(),
      status: "Normal",
      temperature: "0",
      humidity: "0",
      pressure: "0",
      connection: "Connected",
      temperatureRaw: 0,
      humidityRaw: 0,
      pressureRaw: 0,
      totalCount: "0",
      issues: [],
      action: false,
    );

    _mockDevices.add(newDevice);

    return {
      "status": "success",
      "message": "Mock add device success",
      "device": newDevice.toJson(),
    };
  }

  static Future<Map<String, dynamic>> updateDeviceMock(
    String deviceId,
    Map<String, String?> updatedData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _mockDevices.indexWhere((d) => d.deviceId == deviceId);
    if (index == -1) return {"status": "error", "message": "Device not found"};

    final old = _mockDevices[index];

    _mockDevices[index] = DeviceItem(
      system: updatedData['system'] ?? old.system,
      location: updatedData['location_name'] ?? old.location,
      locationId:
          int.tryParse(updatedData['location_id'] ?? '') ?? old.locationId,
      deviceId: old.deviceId,
      frequency: updatedData['frequency'] ?? old.frequency,
      freqCheckLimit: updatedData['freq_check_limit'] ?? old.freqCheckLimit,
      tempLower: updatedData['temp_lower'] ?? old.tempLower,
      tempTarget: updatedData['temp_target'] ?? old.tempTarget,
      tempUpper: updatedData['temp_upper'] ?? old.tempUpper,
      humidityLower: updatedData['humidity_lower'] ?? old.humidityLower,
      humidityTarget: updatedData['humidity_target'] ?? old.humidityTarget,
      humidityUpper: updatedData['humidity_upper'] ?? old.humidityUpper,
      pressureLower: updatedData['pressure_lower'] ?? old.pressureLower,
      pressureTarget: updatedData['pressure_target'] ?? old.pressureTarget,
      pressureUpper: updatedData['pressure_upper'] ?? old.pressureUpper,
      unit: old.unit,
      totalCountHours: old.totalCountHours,
      totalCountUpdateAt: DateTime.now().toString(),
      dataTime: old.dataTime,
      status: old.status,
      temperature: updatedData['temp_target'] ?? old.temperature,
      humidity: updatedData['humidity_target'] ?? old.humidity,
      pressure: updatedData['pressure_target'] ?? old.pressure,
      connection: old.connection,
      temperatureRaw:
          double.tryParse(updatedData['temp_target'] ?? old.temperature) ??
          old.temperatureRaw,
      humidityRaw:
          double.tryParse(updatedData['humidity_target'] ?? old.humidity) ??
          old.humidityRaw,
      pressureRaw:
          double.tryParse(updatedData['pressure_target'] ?? old.pressure) ??
          old.pressureRaw,
      totalCount: old.totalCount,
      issues: old.issues,
      action: old.action,
    );

    return {"status": "success", "message": "Device updated successfully"};
  }

  // ==== DELETE DEVICE (MOCK) ====
  static Future<Map<String, dynamic>> deleteDeviceMock(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _mockDevices.indexWhere((d) => d.deviceId == deviceId);

    if (index == -1) {
      return {"status": "error", "message": "Device not found"};
    }

    // Xóa thiết bị
    _mockDevices.removeAt(index);

    return {
      "status": "success",
      "message": "Mock delete device success",
      "device_id": deviceId,
    };
  }

  static Future<Map<String, dynamic>> getActionsMock() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final actionsJson = _mockActions.map((a) => a.toJson()).toList();

    return {
      "status": "success",
      "total": actionsJson.length,
      "actions": actionsJson,
    };
  }

  // ==== CREATE ACTION WITH PLANS (MOCK) ====
  static Future<Map<String, dynamic>> createActionWithPlansMock({
    required String deviceId,
    required String title,
    String? issueType,
    required Map<String, dynamic> metrics,
    required Map<String, dynamic> thresholds,
    required List<Map<String, dynamic>> plans,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final int actionId = DateTime.now().millisecondsSinceEpoch;

    // Converte plan JSON thành list plan mock
    final planObjects = plans.map((p) {
      return MockPlan(
        planId: DateTime.now().microsecondsSinceEpoch + _mockActions.length,
        planText: p["plan_text"] ?? "",
        estDate: p["est_date"] ?? "",
        ownerName: p["owner_name"] ?? "",
      );
    }).toList();

    final newAction = MockAction(
      actionId: actionId,
      deviceId: deviceId,
      title: title,
      issueType: issueType,
      metrics: metrics,
      thresholds: thresholds,
      plans: planObjects,
      createdAt: DateTime.now(),
    );

    _mockActions.add(newAction);

    return {
      "status": "success",
      "message": "Mock create action success",
      "action": newAction.toJson(),
    };
  }

  static List<DeviceItem> getAll() => _mockDevices;
  static final List<MockAction> _mockActions = [];
}

class MockAction {
  final int actionId;
  final String deviceId;
  final String title;
  final String? issueType;
  final Map<String, dynamic> metrics;
  final Map<String, dynamic> thresholds;
  final List<MockPlan> plans;
  final DateTime createdAt;

  MockAction({
    required this.actionId,
    required this.deviceId,
    required this.title,
    required this.issueType,
    required this.metrics,
    required this.thresholds,
    required this.plans,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    "action_id": actionId,
    "device_id": deviceId,
    "title": title,
    "issue_type": issueType,
    "metrics": metrics,
    "thresholds": thresholds,
    "plans": plans.map((e) => e.toJson()).toList(),
    "created_at": createdAt.toIso8601String(),
  };
}

class MockPlan {
  final int planId;
  final String planText;
  final String estDate;
  final String ownerName;

  MockPlan({
    required this.planId,
    required this.planText,
    required this.estDate,
    required this.ownerName,
  });

  Map<String, dynamic> toJson() => {
    "plan_id": planId,
    "plan_text": planText,
    "est_date": estDate,
    "owner_name": ownerName,
  };
}

class MockAuthService {
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
    String otp,
  ) async {
    // Giả lập delay như API thật
    await Future.delayed(Duration(milliseconds: 300));

    // Mock username/password đúng
    if (username == "test" && password == "12345678") {
      const token =
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI3ODI0MmEzOS1hOTU3LTQyODAtYjI0Yi05NmMzYWMwOTg5ZDUiLCJ1c2VybmFtZSI6Im1hZGllNDciLCJyb2xlIjpbeyJ1dWlkIjoiZDgxNTJmZmUtOGI0Yi00MzVjLWE4NGUtZjQwNGVkOTYzMjQ4IiwibmFtZSI6ImFkbWluIiwiZGVzY3JpcHRpb24iOiJObyBkZXNjcmlwdGlvbiBwcm92aWRlZCJ9XSwiaWF0IjoxNzY0MjI4OTkyLCJleHAiOjE3NjQyMzYxOTJ9.eGUdTlBis9TWEfowaDZn2rCslChQ_Ug5oBQ0TS4Lsy4";

      final user = {
        "id": 0,
        "uid": "78242a39-a957-4280-b24b-96c3ac0989d5",
        "username": "madie47",
        "role": [
          {
            "uuid": "d8152ffe-8b4b-435c-a84e-f404ed963248",
            "name": "admin",
            "description": "No description provided",
          },
        ],
        "roles": [],
        "exp": 1764236192,
      };

      // Giả lập lưu token và user vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", token);
      await prefs.setString("user", jsonEncode(user));
      // await prefs.setStringList("permissions", ["view", "edit", "delete"]);
      await prefs.setStringList("permissions", [
        "auth.login",
        "auth.logout",
        "equipment.view",
        "equipment.edit",
        "equipment.delete",
        "masterplan.view",
        "wi.view_list",
        "wi.view_detail",
        "wi.edit",
        "wi.delete",
        "wi.create",
        "inspection.view_daily",
        "inspection.view_equipment_tasks",
        "inspection.execute",
        "maintenance.view_tasks",
        "maintenance.view_equipment_tasks",
        "maintenance.execute",
        "dashboard.view",
        "profile.view",
        "action_count_bulk.view",
        "auth.whoami",
        "action.create",
        "devices.create",
        "device.delete",
        "device.update",
        "action.delete",
        "action.approve",
        "action.update",
        "action.plan.view",
        "action.view",
        "open.popup",
        "create.action.ems",
        "update.status.action.plan",
        "delete.action.plan",
        "device.add.ems",
        "device.update.ems",
        "device.delete.ems",
        "view.list.action",
        "approve.action.ems",
        "reject.action.ems",
        "delete.action.ems",
        "view.backend",
        "view.action.approve",
        "view.backend.page",
        "view.audit.trail",
        "view.audit.trail.ems",
        "audit.view",
        "equipment.view",
        "equipment.edit",
        "equipment.delete",
        "masterplan.view",
        "wi.view_list",
        "wi.view_detail",
        "inspection.view_daily",
        "inspection.view_equipment_tasks",
        "inspection.execute",
        "maintenance.view_tasks",
        "maintenance.view_equipment_tasks",
        "action.create",
        "devices.create",
        "device.delete",
        "device.update",
        "action.delete",
        "action.approve",
        "action.update",
        "action.plan.view",
        "action.view",
        "create.action.ems",
        "update.status.action.plan",
        "delete.action.plan",
        "device.add.ems",
        "device.update.ems",
        "device.delete.ems",
        "view.list.action",
        "approve.action.ems",
        "reject.action.ems",
        "delete.action.ems",
        "view.backend",
        "view.action.approve",
      ]);

      return {"success": true, "user": user, "token": token};
    } else {
      return {"success": false, "message": "Invalid credentials or OTP"};
    }
  }
}

const mockSetPasswordResponse = {
  "status": "success",
  "message": "Password updated successfully (mock)",
  "updated_at": "2025-12-01 10:00:00",
};
