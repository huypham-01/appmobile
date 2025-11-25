// // lib/fmcs/data/mappers/device_data_mapper.dart

// import 'package:mobile/fmcs/data/models/device_model.dart';

// import 'models/device_response_model.dart';

// class DeviceDataMapper {
//   /// Chuyển đổi DeviceItem từ API sang DeviceData cho UI
//   static DeviceData toDeviceData(DeviceItem item) {
//     return DeviceData(
//       deviceId: item.deviceId,
//       system: item.system,
//       location: item.location,
//       time: _parseDateTime(item.dataTime),
//       status: _mapStatus(item.status, item.connection),
//       connection: _mapConnection(item.connection),
//       temperature: _mapTemperatureSensor(item),
//       humidity: _mapHumiditySensor(item),
//       pressure: _mapPressureSensor(item),
//     );
//   }

//   /// Chuyển đổi list DeviceItem sang list DeviceData
//   static List<DeviceData> toDeviceDataList(List<DeviceItem> items) {
//     return items.map((item) => toDeviceData(item)).toList();
//   }

//   /// Parse datetime string
//   static DateTime _parseDateTime(String? dateTime) {
//     if (dateTime == null || dateTime == 'N/A' || dateTime.isEmpty) {
//       return DateTime.now();
//     }
//     try {
//       return DateTime.parse(dateTime);
//     } catch (e) {
//       return DateTime.now();
//     }
//   }

//   /// Map status từ API sang DeviceStatus
//   static DeviceStatus _mapStatus(String status, String connection) {
//     // Nếu disconnected thì trả về offline
//     if (connection.toLowerCase() == 'disconnected') {
//       return DeviceStatus.offline;
//     }

//     // Map status từ API
//     switch (status.toLowerCase()) {
//       case 'green':
//         return DeviceStatus.normal;
//       case 'red':
//         return DeviceStatus.critical;
//       case 'brown_breach':
//         return DeviceStatus.critical;
//       case 'brown_disconnect':
//         return DeviceStatus.offline;
//       default:
//         return DeviceStatus.offline;
//     }
//   }

//   /// Map connection từ API sang ConnectionStatus
//   static ConnectionStatus _mapConnection(String connection) {
//     switch (connection.toLowerCase()) {
//       case 'connected':
//         return ConnectionStatus.connected;
//       case 'disconnected':
//         return ConnectionStatus.disconnected;
//       case 'connecting':
//         return ConnectionStatus.connecting;
//       default:
//         return ConnectionStatus.disconnected;
//     }
//   }

//   /// Map temperature sensor data
//   static SensorData? _mapTemperatureSensor(DeviceItem item) {
//     if (item.temperature == 'N/A') return null;

//     final actual = item.temperatureRaw;
//     if (actual == null) return null;

//     final lower = _parseDouble(item.tempLower);
//     final target = _parseDouble(item.tempTarget);
//     final upper = _parseDouble(item.tempUpper);

//     final isOutOfRange = _isOutOfRange(actual, lower, upper);

//     return SensorData(
//       actual: actual,
//       lower: lower,
//       target: target,
//       upper: upper,
//       unit: '°C',
//     );
//   }

//   /// Map humidity sensor data
//   static SensorData? _mapHumiditySensor(DeviceItem item) {
//     if (item.humidity == 'N/A') return null;

//     final actual = item.humidityRaw;
//     if (actual == null) return null;

//     final lower = _parseDouble(item.humidityLower);
//     final target = _parseDouble(item.humidityTarget);
//     final upper = _parseDouble(item.humidityUpper);

//     final isOutOfRange = _isOutOfRange(actual, lower, upper);

//     return SensorData(
//       actual: actual,
//       lower: lower,
//       target: target,
//       upper: upper,
//       unit: '%RH',
//     );
//   }

//   /// Map pressure sensor data
//   static SensorData? _mapPressureSensor(DeviceItem item) {
//     if (item.pressure == 'N/A') return null;

//     final actual = item.pressureRaw;
//     if (actual == null) return null;

//     final lower = _parseDouble(item.pressureLower);
//     final target = _parseDouble(item.pressureTarget);
//     final upper = _parseDouble(item.pressureUpper);

//     // Đối với vacuum tank, pressure là âm
//     // Nên logic kiểm tra ngược lại
//     final isOutOfRange = _isOutOfRange(actual, lower, upper);

//     // Xác định unit dựa trên system
//     String unit = 'kg/cm²';
//     if (item.system.toLowerCase().contains('vacuum')) {
//       unit = 'cmHg';
//     }

//     return SensorData(
//       actual: actual,
//       lower: lower,
//       target: target,
//       upper: upper,
//       unit: unit,
//     );
//   }

//   /// Parse double từ string
//   static double? _parseDouble(String? value) {
//     if (value == null || value.isEmpty) return null;
//     return double.tryParse(value);
//   }

//   /// Kiểm tra giá trị có nằm ngoài range không
//   static bool _isOutOfRange(double actual, double? lower, double? upper) {
//     if (lower != null && actual < lower) return true;
//     if (upper != null && actual > upper) return true;
//     return false;
//   }

//   /// Tạo SystemCategory từ DeviceResponseModel
//   static List<SystemCategory> createSystemCategories(
//     DeviceResponseModel response,
//   ) {
//     final categories = <SystemCategory>[];

//     // Issue category (tất cả thiết bị có vấn đề)
//     final issueCount = response.allTableData
//         .where((d) => d.issues.isNotEmpty || d.connection == 'Disconnected')
//         .length;
//     categories.add(SystemCategory(name: 'Issue', count: issueCount));

//     // Các category theo system
//     final systemCounts = <String, int>{};
//     for (var device in response.allTableData) {
//       systemCounts[device.system] = (systemCounts[device.system] ?? 0) + 1;
//     }

//     systemCounts.forEach((system, count) {
//       categories.add(SystemCategory(name: system, count: count));
//     });

//     return categories;
//   }

//   /// Tạo status summary
//   static Map<String, int> createStatusSummary(DeviceResponseModel response) {
//     return {
//       'total': response.totalDevices,
//       'connected': response.connectedDevices,
//       'offline': response.disconnectedDevices,
//       'warning': response.breachedDevices,
//     };
//   }
// }
