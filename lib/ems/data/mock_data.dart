import 'package:mobile/ems/data/models/machine_model.dart';

class MockMachineService {
  static bool initialized = false;

  /// ===== STORE MOCK =====
  static List<Machine> _machines = [];

  /// ===== INIT MOCK DATA =====
  static void initializeMockData() {
    if (initialized) return;

    final List<Map<String, dynamic>> mockJson = [
      {
        "mold_id": "12222",
        "family": "IU35 4PK/6PK",
        "process": "12",
        "mold_cavity": 0,
        "actual_cavity": 0,
        "capacity_per_hr": 2880,
        "efficiency": 0,
        "efficiency_lower_limit": 90,
        "current_cycle": 0,
        "output": 0,
        "cyclecount": 0,
        "total_count": 872676,
        "cavity_count": null,
        "total_rpm": 12000,
        "total_cycle": 145461,
        "target": 8,
        "bush_per_cycle": 6,
        "hole_per_brush": null,
        "upper_limit": 12,
        "lower_limit": 8,
        "total_lost_pcs": 2880,
        "lost_time": 60,
        "status": "BREACHED",
        "last_updated": "2025-11-28 11:43:48",
        "is_flex": true,
        "has_action": false,
      },
      {
        "mold_id": "VP24005A",
        "family": "Alpha",
        "process": "22",
        "mold_cavity": 0,
        "actual_cavity": 0,
        "capacity_per_hr": 0,
        "efficiency": 0,
        "efficiency_lower_limit": 85,
        "current_cycle": 0,
        "output": 0,
        "cyclecount": 0,
        "total_count": 66407,
        "cavity_count": null,
        "total_rpm": 12000,
        "total_cycle": 22139,
        "target": 12,
        "bush_per_cycle": 0,
        "hole_per_brush": null,
        "upper_limit": 14,
        "lower_limit": 12,
        "total_lost_pcs": 720,
        "lost_time": 60,
        "status": "DISCONNECTED",
        "last_updated": "2025-11-28 11:44:30",
        "is_flex": false,
        "has_action": false,
      },
      {
        "mold_id": "12222",
        "family": "IU35 4PK/6PK",
        "process": "12",
        "mold_cavity": 0,
        "actual_cavity": 0,
        "capacity_per_hr": 2880,
        "efficiency": 0,
        "efficiency_lower_limit": 90,
        "current_cycle": 0,
        "output": 0,
        "cyclecount": 0,
        "total_count": 872676,
        "cavity_count": null,
        "total_rpm": 12000,
        "total_cycle": 145461,
        "target": 8,
        "bush_per_cycle": 6,
        "hole_per_brush": null,
        "upper_limit": 12,
        "lower_limit": 8,
        "total_lost_pcs": 2880,
        "lost_time": 60,
        "status": "BREACHED",
        "last_updated": "2025-11-28 11:43:48",
        "is_flex": true,
        "has_action": false,
      },
      {
        "mold_id": "VP24005A",
        "family": "Alpha",
        "process": "22",
        "mold_cavity": 0,
        "actual_cavity": 0,
        "capacity_per_hr": 0,
        "efficiency": 0,
        "efficiency_lower_limit": 85,
        "current_cycle": 0,
        "output": 0,
        "cyclecount": 0,
        "total_count": 66407,
        "cavity_count": null,
        "total_rpm": 12000,
        "total_cycle": 22139,
        "target": 12,
        "bush_per_cycle": 0,
        "hole_per_brush": null,
        "upper_limit": 14,
        "lower_limit": 12,
        "total_lost_pcs": 720,
        "lost_time": 60,
        "status": "DISCONNECTED",
        "last_updated": "2025-11-28 11:44:30",
        "is_flex": false,
        "has_action": false,
      },
      {
        "mold_id": "12222",
        "family": "IU35 4PK/6PK",
        "process": "12",
        "mold_cavity": 0,
        "actual_cavity": 0,
        "capacity_per_hr": 2880,
        "efficiency": 0,
        "efficiency_lower_limit": 90,
        "current_cycle": 0,
        "output": 0,
        "cyclecount": 0,
        "total_count": 872676,
        "cavity_count": null,
        "total_rpm": 12000,
        "total_cycle": 145461,
        "target": 8,
        "bush_per_cycle": 6,
        "hole_per_brush": null,
        "upper_limit": 12,
        "lower_limit": 8,
        "total_lost_pcs": 2880,
        "lost_time": 60,
        "status": "BREACHED",
        "last_updated": "2025-11-28 11:43:48",
        "is_flex": true,
        "has_action": false,
      },
      {
        "mold_id": "VP24005A",
        "family": "Alpha",
        "process": "22",
        "mold_cavity": 0,
        "actual_cavity": 0,
        "capacity_per_hr": 0,
        "efficiency": 0,
        "efficiency_lower_limit": 85,
        "current_cycle": 0,
        "output": 0,
        "cyclecount": 0,
        "total_count": 66407,
        "cavity_count": null,
        "total_rpm": 12000,
        "total_cycle": 22139,
        "target": 12,
        "bush_per_cycle": 0,
        "hole_per_brush": null,
        "upper_limit": 14,
        "lower_limit": 12,
        "total_lost_pcs": 720,
        "lost_time": 60,
        "status": "DISCONNECTED",
        "last_updated": "2025-11-28 11:44:30",
        "is_flex": false,
        "has_action": false,
      },
      {
        "mold_id": "12222",
        "family": "IU35 4PK/6PK",
        "process": "12",
        "mold_cavity": 0,
        "actual_cavity": 0,
        "capacity_per_hr": 2880,
        "efficiency": 0,
        "efficiency_lower_limit": 90,
        "current_cycle": 0,
        "output": 0,
        "cyclecount": 0,
        "total_count": 872676,
        "cavity_count": null,
        "total_rpm": 12000,
        "total_cycle": 145461,
        "target": 8,
        "bush_per_cycle": 6,
        "hole_per_brush": null,
        "upper_limit": 12,
        "lower_limit": 8,
        "total_lost_pcs": 2880,
        "lost_time": 60,
        "status": "BREACHED",
        "last_updated": "2025-11-28 11:43:48",
        "is_flex": true,
        "has_action": false,
      },
      {
        "mold_id": "VP24005A",
        "family": "Alpha",
        "process": "22",
        "mold_cavity": 0,
        "actual_cavity": 0,
        "capacity_per_hr": 0,
        "efficiency": 0,
        "efficiency_lower_limit": 85,
        "current_cycle": 0,
        "output": 0,
        "cyclecount": 0,
        "total_count": 66407,
        "cavity_count": null,
        "total_rpm": 12000,
        "total_cycle": 22139,
        "target": 12,
        "bush_per_cycle": 0,
        "hole_per_brush": null,
        "upper_limit": 14,
        "lower_limit": 12,
        "total_lost_pcs": 720,
        "lost_time": 60,
        "status": "DISCONNECTED",
        "last_updated": "2025-11-28 11:44:30",
        "is_flex": false,
        "has_action": false,
      },
    ];

    _machines = mockJson.map((e) => Machine.fromJson(e)).toList();

    initialized = true;
  }

  // ============================================================
  // ================== FETCH MACHINE (MOCK) =====================
  // ============================================================
  static Future<List<Machine>> fetchMachineMock(String key) async {
    initializeMockData();
    await Future.delayed(Duration(milliseconds: 300));
    return _machines; // Không lọc theo key
  }

  // ============================================================
  // ==================== ADD MACHINE (MOCK) =====================
  // ============================================================
  static Future<Map<String, dynamic>> addMachineMock(Machine newMachine) async {
    initializeMockData();

    /// Kiểm tra trùng mold_id
    final exists = _machines.any((m) => m.moldId == newMachine.moldId);
    if (exists) {
      return {"status": "error", "message": "Machine already exists"};
    }

    _machines.add(newMachine);

    return {"status": "success", "message": "Machine added (mock)"};
  }

  // ============================================================
  // ================== UPDATE MACHINE (MOCK) ====================
  // ============================================================
  static Future<Map<String, dynamic>> updateMachineMock(
    String moldId,
    Map<String, dynamic> newData,
  ) async {
    initializeMockData();

    final index = _machines.indexWhere((m) => m.moldId == moldId);

    if (index == -1) {
      return {"status": "error", "message": "Machine not found"};
    }

    final old = _machines[index];

    final updated = Machine(
      moldId: newData["mold_id"] ?? old.moldId,
      family: newData["family"] ?? old.family,
      process: newData["process"] ?? old.process,
      moldCavity: newData["mold_cavity"] ?? old.moldCavity,
      actualCavity: newData["actual_cavity"] ?? old.actualCavity,
      capacityPerHr: newData["capacity_per_hr"] ?? old.capacityPerHr,
      efficiency: newData["efficiency"] ?? old.efficiency,
      efficiencylowerlimit:
          newData["efficiency_lower_limit"] ?? old.efficiencylowerlimit,
      currentCycle: newData["current_cycle"] ?? old.currentCycle,
      output: newData["output"] ?? old.output,
      cycleCount: newData["cyclecount"] ?? old.cycleCount,
      totalCount: newData["total_count"] ?? old.totalCount,
      cavityCount: newData["cavity_count"] ?? old.cavityCount,
      totalrpm: newData["total_rpm"] ?? old.totalrpm,
      totalcycle: newData["total_cycle"] ?? old.totalcycle,
      target: newData["target"] ?? old.target,
      bushPerCycle: newData["bush_per_cycle"] ?? old.bushPerCycle,
      holePerBrush: newData["hole_per_brush"] ?? old.holePerBrush,
      upperLimit: newData["upper_limit"] ?? old.upperLimit,
      lowerLimit: newData["lower_limit"] ?? old.lowerLimit,
      totalLostPcs: newData["total_lost_pcs"] ?? old.totalLostPcs,
      lostTime: newData["lost_time"] ?? old.lostTime,
      status: newData["status"] ?? old.status,
      lastUpdated: newData["last_updated"] ?? old.lastUpdated,
      isFlex: newData["is_flex"] ?? old.isFlex,
      hasAction: newData["has_action"] ?? old.hasAction,
    );

    _machines[index] = updated;

    return {"status": "success", "message": "Machine updated (mock)"};
  }

  // ============================================================
  // ================== DELETE MACHINE (MOCK) ====================
  // ============================================================
  // static Future<Map<String, dynamic>> deleteMachineMock(String moldId) async {
  //   initializeMockData();

  //   final index = _machines.indexWhere((m) => m.moldId == moldId);

  //   if (index == -1) {
  //     return {"status": "error", "message": "Machine not found"};
  //   }

  //   _machines.removeAt(index);

  //   return {"status": "success", "message": "Machine deleted (mock)"};
  // }
}
//

class MockDeviceService {
  static bool _initialized = false;
  static Map<String, List<Device>> _devices = {};

  // ===== Khởi tạo dữ liệu mock =====
  static void initializeMockData() {
    if (_initialized) return;

    _devices = {
      "mold": [
        Device(
          id: 35,
          deviceId: "TY2024-007",
          displayType: "mold",
          dataSource: "mold",
          product: "Jordan Green family",
          cavities: 16,
          process: "Single",
          metricName: "cycle_time",
          lowerLimit: "62.00",
          targetLimit: "65.00",
          upperLimit: "68.00",
          frequency: 300,
          freqCheckLimit: 60,
          capacity: 886,
          moldType: "Rotating",
          efficiencyUpperLimit: "0.00",
          efficiencyLowerLimit: "95.0",
          flex: 0,
          totalCount: 30232,
          unit: "shot",
          totalCountUpdatedAt: "2025-11-28 07:44:50",
          cavityCount: 483712,
          cavityCountUpdatedAt: "2025-11-28 07:44:50",
          totalRpm: 0,
          totalCycle: 0,
          historyCount: 0,
        ),
      ],
      "injection": [
        Device(
          id: 54,
          deviceId: "VI01043",
          displayType: "injection",
          dataSource: "injection",
          product: "Alpha, Wisdom, Jordan",
          frequency: 300,
          freqCheckLimit: 60,
          flex: 0,
          totalCount: 0,
          unit: "pcs",
          cavityCount: 0,
          totalRpm: 0,
          totalCycle: 0,
          historyCount: 0,
          efficiencyUpperLimit: "0.00",
          efficiencyLowerLimit: "0.0",
        ),
      ],

      "end-rounding": [],
      "blister": [
        Device(
          id: 118,
          deviceId: "VP14005",
          displayType: "blister",
          dataSource: "blister",
          product: "Bane",
          metricName: "cyclecount",
          lowerLimit: "12.00",
          targetLimit: "12.00",
          upperLimit: "14.00",
          frequency: 300,
          freqCheckLimit: 60,
          capacity: 2160,
          flex: 1,
          brushesPerCycle: 3,
          totalCount: 374330,
          unit: "pcs",
          totalCountUpdatedAt: "2025-11-28 07:47:31",
          totalCycle: 187168,
          totalCycleUpdatedAt: "2025-11-28 07:47:31",
          totalRpm: 0,
          cavityCount: 0,
          historyCount: 0,
          efficiencyUpperLimit: "0.00",
          efficiencyLowerLimit: "0.0",
        ),
      ],
    };

    _initialized = true;
  }

  // ===== READ =====
  static Future<DeviceResponse> fetchDevicesMock() async {
    initializeMockData();
    await Future.delayed(const Duration(milliseconds: 300));
    return DeviceResponse(status: 'success', devices: _devices);
  }

  // ===== CREATE =====
  static Future<Device> createDevice(String type, Device device) async {
    initializeMockData();
    final newId = (_devices[type]?.isNotEmpty ?? false)
        ? _devices[type]!.last.id + 1
        : 1;
    final newDevice = Device(
      id: newId,
      deviceId: device.deviceId,
      displayType: type,
      dataSource: type,
      product: device.product,
      model: device.model,
      manufacturer: device.manufacturer,
      manufacturingDate: device.manufacturingDate,
      cavities: device.cavities,
      holePerBrush: device.holePerBrush,
      process: device.process,
      metricName: device.metricName,
      lowerLimit: device.lowerLimit,
      targetLimit: device.targetLimit,
      upperLimit: device.upperLimit,
      frequency: device.frequency,
      freqCheckLimit: device.freqCheckLimit,
      capacity: device.capacity,
      moldType: device.moldType,
      efficiencyUpperLimit: device.efficiencyUpperLimit,
      efficiencyLowerLimit: device.efficiencyLowerLimit,
      flex: device.flex,
      brushesPerCycle: device.brushesPerCycle,
      totalCount: device.totalCount,
      unit: device.unit,
      totalCountUpdatedAt: device.totalCountUpdatedAt,
      cavityCount: device.cavityCount,
      cavityCountUpdatedAt: device.cavityCountUpdatedAt,
      totalRpm: device.totalRpm,
      totalRpmUpdatedAt: device.totalRpmUpdatedAt,
      totalCycle: device.totalCycle,
      totalCycleUpdatedAt: device.totalCycleUpdatedAt,
      historyCount: device.historyCount,
      historyCountUpdatedAt: device.historyCountUpdatedAt,
    );

    _devices[type] ??= [];
    _devices[type]!.add(newDevice);
    await Future.delayed(const Duration(milliseconds: 200));
    return newDevice;
  }

  // ===== UPDATE =====
  static Future<Device?> updateDevice(
    String type,
    int id,
    Device updatedDevice,
  ) async {
    final index = _devices[type]?.indexWhere((d) => d.id == id);
    if (index == null || index == -1) return null;
    _devices[type]![index] = updatedDevice;
    await Future.delayed(const Duration(milliseconds: 200));
    return _devices[type]![index];
  }

  // ===== DELETE =====
}

class MockEmsApiService {
  // ===== Add device =====
  static Future<Map<String, dynamic>> addDevice(
    Map<String, String?> newData,
  ) async {
    try {
      // Lấy loại thiết bị từ display_type
      final type = newData['display_type'] ?? 'mold';

      // Tạo Device mới dựa trên dữ liệu nhập
      final newDevice = Device(
        id: (_getDevicesByType(type).isNotEmpty)
            ? _getDevicesByType(type).last.id + 1
            : 1,
        deviceId: newData['device_id'] ?? '',
        displayType: type,
        dataSource: type,
        product: newData['product'],
        model: newData['model'],
        manufacturer: newData['manufacturer'],
        manufacturingDate: newData['manufacturing_date'],
        cavities: int.tryParse(newData['cavities'] ?? ''),
        holePerBrush: int.tryParse(newData['hole_per_brush'] ?? ''),
        process: newData['process'],
        metricName: null,
        lowerLimit: newData['lower_limit'],
        targetLimit: newData['target_limit'],
        upperLimit: newData['upper_limit'],
        frequency: int.tryParse(newData['frequency'] ?? '0') ?? 0,
        freqCheckLimit: int.tryParse(newData['freq_check_limit'] ?? '0') ?? 0,
        capacity: int.tryParse(newData['capacity'] ?? ''),
        moldType: newData['mold_type'],
        efficiencyUpperLimit: null,
        efficiencyLowerLimit: newData['efficiency_lower_limit'] ?? "0",
        flex: int.tryParse(newData['flex'] ?? '0') ?? 0,
        brushesPerCycle: int.tryParse(newData['brushes_per_cycle'] ?? ''),
        totalCount: int.tryParse(newData['total_count'] ?? '0') ?? 0,
        unit: newData['unit'] ?? 'pcs',
        totalCountUpdatedAt: DateTime.now().toString(),
        cavityCount: int.tryParse(newData['cavity_count'] ?? '0') ?? 0,
        cavityCountUpdatedAt: DateTime.now().toString(),
        totalRpm: int.tryParse(newData['total_rpm'] ?? '0') ?? 0,
        totalRpmUpdatedAt: DateTime.now().toString(),
        totalCycle: int.tryParse(newData['total_cycle'] ?? '0') ?? 0,
        totalCycleUpdatedAt: DateTime.now().toString(),
        historyCount: int.tryParse(newData['history_count'] ?? '0') ?? 0,
        historyCountUpdatedAt: DateTime.now().toString(),
      );

      // Thêm vào mock data
      _getDevicesByType(type).add(newDevice);

      await Future.delayed(const Duration(milliseconds: 200));

      return {"status": "success", "device": newDevice.toJson()};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // ===== Update device =====
  static Future<Map<String, dynamic>> updateDevice(
    Map<String, String?> newData,
  ) async {
    try {
      final type = newData['display_type'] ?? 'mold';
      final id = int.tryParse(newData['id'] ?? '');
      if (id == null) {
        return {"status": "error", "message": "Invalid ID"};
      }

      final devices = _getDevicesByType(type);
      final index = devices.indexWhere((d) => d.id == id);
      if (index == -1)
        return {"status": "error", "message": "Device not found"};

      // Cập nhật thông tin
      final oldDevice = devices[index];
      final updatedDevice = Device(
        id: oldDevice.id,
        deviceId: newData['device_id'] ?? oldDevice.deviceId,
        displayType: type,
        dataSource: type,
        product: newData['product'] ?? oldDevice.product,
        model: newData['model'] ?? oldDevice.model,
        manufacturer: newData['manufacturer'] ?? oldDevice.manufacturer,
        manufacturingDate:
            newData['manufacturing_date'] ?? oldDevice.manufacturingDate,
        cavities: int.tryParse(newData['cavities'] ?? '') ?? oldDevice.cavities,
        holePerBrush:
            int.tryParse(newData['hole_per_brush'] ?? '') ??
            oldDevice.holePerBrush,
        process: newData['process'] ?? oldDevice.process,
        metricName: oldDevice.metricName,
        lowerLimit: newData['lower_limit'] ?? oldDevice.lowerLimit,
        targetLimit: newData['target_limit'] ?? oldDevice.targetLimit,
        upperLimit: newData['upper_limit'] ?? oldDevice.upperLimit,
        frequency:
            int.tryParse(newData['frequency'] ?? '') ?? oldDevice.frequency,
        freqCheckLimit:
            int.tryParse(newData['freq_check_limit'] ?? '') ??
            oldDevice.freqCheckLimit,
        capacity: int.tryParse(newData['capacity'] ?? '') ?? oldDevice.capacity,
        moldType: newData['mold_type'] ?? oldDevice.moldType,
        efficiencyUpperLimit: oldDevice.efficiencyUpperLimit,
        efficiencyLowerLimit:
            newData['efficiency_lower_limit'] ?? oldDevice.efficiencyLowerLimit,
        flex: int.tryParse(newData['flex'] ?? '') ?? oldDevice.flex,
        brushesPerCycle:
            int.tryParse(newData['brushes_per_cycle'] ?? '') ??
            oldDevice.brushesPerCycle,
        totalCount:
            int.tryParse(newData['total_count'] ?? '') ?? oldDevice.totalCount,
        unit: newData['unit'] ?? oldDevice.unit,
        totalCountUpdatedAt: DateTime.now().toString(),
        cavityCount:
            int.tryParse(newData['cavity_count'] ?? '') ??
            oldDevice.cavityCount,
        cavityCountUpdatedAt: DateTime.now().toString(),
        totalRpm:
            int.tryParse(newData['total_rpm'] ?? '') ?? oldDevice.totalRpm,
        totalRpmUpdatedAt: DateTime.now().toString(),
        totalCycle:
            int.tryParse(newData['total_cycle'] ?? '') ?? oldDevice.totalCycle,
        totalCycleUpdatedAt: DateTime.now().toString(),
        historyCount:
            int.tryParse(newData['history_count'] ?? '') ??
            oldDevice.historyCount,
        historyCountUpdatedAt: DateTime.now().toString(),
      );

      devices[index] = updatedDevice;

      await Future.delayed(const Duration(milliseconds: 200));

      return {"status": "success", "device": updatedDevice.toJson()};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteDevice(String id) async {
    try {
      // Chắc chắn mock data đã khởi tạo
      MockDeviceService.initializeMockData();

      int deviceId = int.tryParse(id) ?? 0;
      if (deviceId == 0) {
        return {"status": "error", "message": "Invalid ID"};
      }

      bool removed = false;

      // Duyệt tất cả các loại thiết bị
      MockDeviceService._devices.forEach((type, list) {
        // tìm index
        final index = list.indexWhere((d) => d.id == deviceId);
        if (index != -1) {
          list.removeAt(index);
          removed = true;
        }
      });

      await Future.delayed(const Duration(milliseconds: 200));

      if (removed) {
        return {"status": "success", "message": "Device deleted successfully"};
      } else {
        return {"status": "error", "message": "Device not found"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // ===== Helper: lấy list thiết bị theo type =====
  static List<Device> _getDevicesByType(String type) {
    MockDeviceService.initializeMockData();
    MockDeviceService._devices[type] ??= [];
    return MockDeviceService._devices[type]!;
  }
}

class MockSummaryService {
  static Future<SummaryReport?> fetchSummaryReport({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200)); // giả lập delay

    // Dữ liệu mock giống API thật
    final mockJson = {
      "mold": {
        "status": {"running": 4, "breakdown": 32, "warning": 4, "total": 36},
        "efficiency": {"day": 3.19, "night": 6.04, "average": 4.61},
        "output": {
          "day": 11111,
          "night": 25656,
          "total": 39208,
          "day_lost_pcs": 0,
          "day_loss_percent": 0,
          "night_lost_pcs": 0,
          "night_loss_percent": 0,
          "total_lost_pcs": 0,
          "total_loss_percent": 0,
        },
      },
      "tuft": {
        "status": {"running": 22, "breakdown": 21, "warning": 19, "total": 43},
        "efficiency": {"day": 22.46, "night": 23.5, "average": 22.98},
        "output": {
          "day": 90705,
          "night": 94919,
          "total": 185624,
          "day_lost_pcs": 0,
          "day_loss_percent": 0,
          "night_lost_pcs": 0,
          "night_loss_percent": 0,
          "total_lost_pcs": 0,
          "total_loss_percent": 0,
        },
      },
      "blister": {
        "status": {"running": 10, "breakdown": 10, "warning": 9, "total": 20},
        "efficiency": {"day": 11, "night": 10.46, "average": 10.73},
        "output": {
          "day": 55140,
          "night": 52401,
          "total": 107541,
          "day_lost_pcs": 35565,
          "day_loss_percent": 39.21,
          "night_lost_pcs": 42518,
          "night_loss_percent": 44.79,
          "total_lost_pcs": 78083,
          "total_loss_percent": 42.07,
        },
      },
      "_range": {
        "day_from": from.toString().split('.').first,
        "day_to": to.toString().split('.').first,
        "night_from": from
            .add(const Duration(hours: 12))
            .toString()
            .split('.')
            .first,
        "night_to": to
            .add(const Duration(hours: 12))
            .toString()
            .split('.')
            .first,
      },
    };

    return SummaryReport.fromJson(mockJson);
  }
}

//mock status
class MockMachineStatusService {
  // Dữ liệu mock
  static final List<Map<String, dynamic>> _mockData = [
    {
      "mold_id": "AC110208",
      "family": "Beta (Oral-C)",
      "process": "Single",
      "mold_cavity": 12,
      "actual_cavity": 12,
      "capacity_per_hr": 1200,
      "efficiency": 95,
      "efficiency_lower_limit": 85,
      "current_cycle": 100,
      "output": 950,
      "cyclecount": 100,
      "total_count": 5000,
      "cavity_count": 6000,
      "total_rpm": 3000,
      "total_cycle": 150,
      "target": 45,
      "bush_per_cycle": 2,
      "hole_per_brush": 8,
      "upper_limit": 48,
      "lower_limit": 42,
      "total_lost_pcs": 50,
      "lost_time": 15,
      "status": "RUNNING",
      "last_updated": "2025-11-28 08:00:00",
      "is_flex": true,
      "has_action": true,
    },
    {
      "mold_id": "AC110208",
      "family": "Beta (Oral-C)",
      "process": "Single",
      "mold_cavity": 12,
      "actual_cavity": 12,
      "capacity_per_hr": 1200,
      "efficiency": 95,
      "efficiency_lower_limit": 85,
      "current_cycle": 100,
      "output": 950,
      "cyclecount": 100,
      "total_count": 5000,
      "cavity_count": 6000,
      "total_rpm": 3000,
      "total_cycle": 150,
      "target": 45,
      "bush_per_cycle": 2,
      "hole_per_brush": 8,
      "upper_limit": 48,
      "lower_limit": 42,
      "total_lost_pcs": 50,
      "lost_time": 15,
      "status": "RUNNING",
      "last_updated": "2025-11-28 08:00:00",
      "is_flex": true,
      "has_action": true,
    },
    {
      "mold_id": "AC110208",
      "family": "Beta (Oral-C)",
      "process": "Single",
      "mold_cavity": 12,
      "actual_cavity": 12,
      "capacity_per_hr": 1200,
      "efficiency": 95,
      "efficiency_lower_limit": 85,
      "current_cycle": 100,
      "output": 950,
      "cyclecount": 100,
      "total_count": 5000,
      "cavity_count": 6000,
      "total_rpm": 3000,
      "total_cycle": 150,
      "target": 45,
      "bush_per_cycle": 2,
      "hole_per_brush": 8,
      "upper_limit": 48,
      "lower_limit": 42,
      "total_lost_pcs": 50,
      "lost_time": 15,
      "status": "RUNNING",
      "last_updated": "2025-11-28 08:00:00",
      "is_flex": true,
      "has_action": true,
    },
    {
      "mold_id": "AC110208",
      "family": "Beta (Oral-C)",
      "process": "Single",
      "mold_cavity": 12,
      "actual_cavity": 12,
      "capacity_per_hr": 1200,
      "efficiency": 95,
      "efficiency_lower_limit": 85,
      "current_cycle": 100,
      "output": 950,
      "cyclecount": 100,
      "total_count": 5000,
      "cavity_count": 6000,
      "total_rpm": 3000,
      "total_cycle": 150,
      "target": 45,
      "bush_per_cycle": 2,
      "hole_per_brush": 8,
      "upper_limit": 48,
      "lower_limit": 42,
      "total_lost_pcs": 50,
      "lost_time": 15,
      "status": "RUNNING",
      "last_updated": "2025-11-28 08:00:00",
      "is_flex": true,
      "has_action": true,
    },
    {
      "mold_id": "AC110208",
      "family": "Beta (Oral-C)",
      "process": "Single",
      "mold_cavity": 12,
      "actual_cavity": 12,
      "capacity_per_hr": 1200,
      "efficiency": 95,
      "efficiency_lower_limit": 85,
      "current_cycle": 100,
      "output": 950,
      "cyclecount": 100,
      "total_count": 5000,
      "cavity_count": 6000,
      "total_rpm": 3000,
      "total_cycle": 150,
      "target": 45,
      "bush_per_cycle": 2,
      "hole_per_brush": 8,
      "upper_limit": 48,
      "lower_limit": 42,
      "total_lost_pcs": 50,
      "lost_time": 15,
      "status": "RUNNING",
      "last_updated": "2025-11-28 08:00:00",
      "is_flex": true,
      "has_action": true,
    },
    {
      "mold_id": "AC110208",
      "family": "Beta (Oral-C)",
      "process": "Single",
      "mold_cavity": 12,
      "actual_cavity": 12,
      "capacity_per_hr": 1200,
      "efficiency": 95,
      "efficiency_lower_limit": 85,
      "current_cycle": 100,
      "output": 950,
      "cyclecount": 100,
      "total_count": 5000,
      "cavity_count": 6000,
      "total_rpm": 3000,
      "total_cycle": 150,
      "target": 45,
      "bush_per_cycle": 2,
      "hole_per_brush": 8,
      "upper_limit": 48,
      "lower_limit": 42,
      "total_lost_pcs": 50,
      "lost_time": 15,
      "status": "RUNNING",
      "last_updated": "2025-11-28 08:00:00",
      "is_flex": true,
      "has_action": true,
    },
    {
      "mold_id": "AC110208",
      "family": "Beta (Oral-C)",
      "process": "Single",
      "mold_cavity": 12,
      "actual_cavity": 12,
      "capacity_per_hr": 1200,
      "efficiency": 95,
      "efficiency_lower_limit": 85,
      "current_cycle": 100,
      "output": 950,
      "cyclecount": 100,
      "total_count": 5000,
      "cavity_count": 6000,
      "total_rpm": 3000,
      "total_cycle": 150,
      "target": 45,
      "bush_per_cycle": 2,
      "hole_per_brush": 8,
      "upper_limit": 48,
      "lower_limit": 42,
      "total_lost_pcs": 50,
      "lost_time": 15,
      "status": "RUNNING",
      "last_updated": "2025-11-28 08:00:00",
      "is_flex": true,
      "has_action": true,
    },
  ];

  // Hàm mock
  static Future<List<Machine>> fetchMachineStatus(
    String processName,
    String status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200)); // giả lập delay

    // Lọc dữ liệu theo processName + status
    final filtered = _mockData.where((item) {
      final matchProcess = processName.isEmpty
          ? true
          : item['process'] == processName;
      final matchStatus = status.isEmpty ? true : item['status'] == status;
      return matchProcess && matchStatus;
    }).toList();

    return filtered.map((item) => Machine.fromJson(item)).toList();
  }

  static Future<DetailMachineResponse?> fetchMachineEfficiency(
    DateTime fromDate,
    DateTime toDate,
    String processName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300)); // fake delay

    const mockJson = {
      "summary_all": {
        "mold": {"day": 8.11, "night": 11.3, "average": 3.19},
        "tuft": {"day": 22.46, "night": 0, "average": 22.46},
        "blister": {"day": 11, "night": 0, "average": 11},
      },
      "details": [
        {
          "machine_id": "AC111111",
          "family": "Wisdom Kids",
          "process": "Single",
          "mold_cavity": 8,
          "capacity_per_hour": 514,
          "capacity": 6168,
          "target": 56,
          "upper_limit": 59,
          "lower_limit": 53,
          "actual_cavity": 8,
          "output": 16,
          "current_cycle": 90.545,
          "total_lost_pcs": 4.27444444,
          "lost_time": 0.498962386511,
          "efficiency": 0.25940337224383914,
        },
        {
          "machine_id": "AC170402",
          "family": "Bane",
          "process": "Single",
          "mold_cavity": 16,
          "capacity_per_hour": 1440,
          "capacity": 17280,
          "target": 40,
          "upper_limit": 41,
          "lower_limit": 39,
          "actual_cavity": 16,
          "output": 13536,
          "current_cycle": 51.008582,
          "total_lost_pcs": 3719.2,
          "lost_time": 154.966666666667,
          "efficiency": 78.33333333333333,
        },
      ],
      "_range_details": {
        "from_local": "2025-11-28 07:00:00",
        "to_local": "2025-11-28 19:00:00",
        "hours": 12,
        "db_is_utc": false,
      },
      "_range_summary_windows": {
        "day_from_vn": "2025-11-28 07:00:00",
        "day_to_vn": "2025-11-28 19:00:00",
        "night_from_vn": "2025-11-28 19:00:00",
        "night_to_vn": "2025-11-28 19:00:00",
        "h_day": 12,
        "h_night": 0.0002777777777777778,
        "h_total": 12,
      },
    };

    return DetailMachineResponse.fromJson(mockJson);
  }

  static Future<DetailMachineOutput?> fetchDetailMachineOutput({
    required DateTime fromDate,
    required DateTime toDate,
    required String processName,
    required String family,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    const mockJson = {
      "summary": {
        "day_output": 13552,
        "night_output": 0,
        "total_output": 13552,
        "day_lost": 0,
        "night_lost": 0,
        "total_lost": 0,
        "day_loss_percent": 0,
        "night_loss_percent": 0,
        "total_loss_percent": 0,
      },
      "details": [
        {
          "machine_id": "AC172222",
          "family": "Bane",
          "process": "Single",
          "mold_cavity": 16,
          "capacity": 1440,
          "target": 40,
          "upper_limit": 41,
          "lower_limit": 39,
          "output": 13536,
          "SubTotal": 13536,
          "efficiency": 78.55,
          "total_lost_pcs": 3696,
          "lost_time": 154,
          "current_cycle": 51.008582,
          "subtotal": 13536,
        },
        {
          "machine_id": "AC110904",
          "family": "Wisdom Kids",
          "process": "Single",
          "mold_cavity": 8,
          "capacity": 514,
          "target": 56,
          "upper_limit": 59,
          "lower_limit": 53,
          "output": 16,
          "SubTotal": 16,
          "efficiency": 93.39,
          "total_lost_pcs": 1.1333,
          "lost_time": 0,
          "current_cycle": 90.545,
          "subtotal": 16,
        },
      ],
      "family_counts": {"Bane": 1, "Wisdom Kids": 1},
    };

    return DetailMachineOutput.fromJson(mockJson);
  }
}

class MockProductionService {
  static Future<ProductionResponse> getProductionData({
    required DateTime fromDate,
    required DateTime toDate,
    String? family,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    const mockJson = {
      "status": "success",
      "hours": 24,
      "matrix": {
        "Alpha": {
          "mold": {"output": 11111, "cap": 222, "efficiency": 33},
          "tuft": {"output": 0, "cap": 0, "efficiency": 0},
          "blister": {"output": 0, "cap": 0, "efficiency": 0},
        },
        "Arjun": {
          "mold": {"output": 0, "cap": 0, "efficiency": 0},
          "tuft": {"output": 0, "cap": 0, "efficiency": 0},
          "blister": {"output": 41910, "cap": 0, "efficiency": 0},
        },
        "Arjun/Classic": {
          "mold": {"output": 0, "cap": 0, "efficiency": 0},
          "tuft": {"output": 0, "cap": 0, "efficiency": 0},
          "blister": {"output": 0, "cap": 2520, "efficiency": 0},
        },
        "Bane": {
          "mold": {"output": 0, "cap": 0, "efficiency": 0},
          "tuft": {"output": 0, "cap": 0, "efficiency": 0},
          "blister": {"output": 5912, "cap": 12240, "efficiency": 2.01},
        },
        "Common": {
          "mold": {"output": 0, "cap": 0, "efficiency": 0},
          "tuft": {"output": 0, "cap": 0, "efficiency": 0},
          "blister": {"output": 15610, "cap": 0, "efficiency": 0},
        },
        "Flexible": {
          "mold": {"output": 0, "cap": 0, "efficiency": 0},
          "tuft": {"output": 0, "cap": 0, "efficiency": 0},
          "blister": {"output": 42456, "cap": 18360, "efficiency": 9.64},
        },
        "IU35 4PK/6PK": {
          "mold": {"output": 0, "cap": 0, "efficiency": 0},
          "tuft": {"output": 0, "cap": 0, "efficiency": 0},
          "blister": {"output": 0, "cap": 2880, "efficiency": 0},
        },
        "Lollipop": {
          "mold": {"output": 0, "cap": 0, "efficiency": 0},
          "tuft": {"output": 0, "cap": 0, "efficiency": 0},
          "blister": {"output": 0, "cap": 2160, "efficiency": 0},
        },
        "ZAHA": {
          "mold": {"output": 0, "cap": 0, "efficiency": 0},
          "tuft": {"output": 0, "cap": 0, "efficiency": 0},
          "blister": {"output": 1653, "cap": 3600, "efficiency": 1.91},
        },
      },
      "totals": {
        "out": {"mold": 0, "tuft": 0, "blister": 107541},
        "cap": {"mold": 0, "tuft": 0, "blister": 41760},
        "eff_weighted": {"mold": 0, "tuft": 0, "blister": 10.73},
        "eff_avg": {"mold": 0, "tuft": 0, "blister": 4.52},
      },
    };

    return ProductionResponse.fromJson(mockJson);
  }
}
// 
class MockActionService {
  static Future<Map<String, dynamic>> createActionWithPlans({
    required String deviceId,
    required String title,
    String? issueType,
    int? assignedTo,
    required List<Map<String, dynamic>> plans,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // giả lập delay API

    return {
      "success": true,
      "message": "Action created (mock)",
      "action": {
        "id": 999,
        "device_id": deviceId,
        "title": title,
        "issue_type": issueType ?? "",
        "assigned_to_user_id": assignedTo ?? 0,
        "plans": plans,
        "created_at": "2025-11-29 10:00:00",
      }
    };
  }
}
