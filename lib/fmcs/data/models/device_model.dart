class DeviceData {
  final String system;
  final String deviceId;
  final String location;
  final DateTime time;
  final DeviceStatus status;
  final SensorData? temperature;
  final SensorData? humidity;
  final SensorData? pressure;
  final ConnectionStatus connection;

  DeviceData({
    required this.system,
    required this.deviceId,
    required this.location,
    required this.time,
    required this.status,
    this.temperature,
    this.humidity,
    this.pressure,
    required this.connection,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      system: json['system'] ?? '',
      deviceId: json['deviceId'] ?? '',
      location: json['location'] ?? '',
      time: DateTime.parse(json['time']),
      status: DeviceStatus.values.firstWhere(
        (e) => e.toString() == 'DeviceStatus.${json['status']}',
        orElse: () => DeviceStatus.normal,
      ),
      temperature: json['temperature'] != null
          ? SensorData.fromJson(json['temperature'])
          : null,
      humidity: json['humidity'] != null
          ? SensorData.fromJson(json['humidity'])
          : null,
      pressure: json['pressure'] != null
          ? SensorData.fromJson(json['pressure'])
          : null,
      connection: ConnectionStatus.values.firstWhere(
        (e) => e.toString() == 'ConnectionStatus.${json['connection']}',
        orElse: () => ConnectionStatus.disconnected,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system': system,
      'deviceId': deviceId,
      'location': location,
      'time': time.toIso8601String(),
      'status': status.toString().split('.').last,
      'temperature': temperature?.toJson(),
      'humidity': humidity?.toJson(),
      'pressure': pressure?.toJson(),
      'connection': connection.toString().split('.').last,
    };
  }
}

class SensorData {
  final double actual;
  final double? lower;
  final double? target;
  final double? upper;
  final String unit;

  SensorData({
    required this.actual,
    this.lower,
    this.target,
    this.upper,
    required this.unit,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      actual: (json['actual'] as num).toDouble(),
      lower: json['lower'] != null ? (json['lower'] as num).toDouble() : null,
      target: json['target'] != null
          ? (json['target'] as num).toDouble()
          : null,
      upper: json['upper'] != null ? (json['upper'] as num).toDouble() : null,
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actual': actual,
      'lower': lower,
      'target': target,
      'upper': upper,
      'unit': unit,
    };
  }

  String get displayActual => '$actual$unit';
  String get displayLower => lower != null ? '$lower' : '';
  String get displayTarget => target != null ? '$target' : '';
  String get displayUpper => upper != null ? '$upper' : '';

  bool get isOutOfRange {
    if (lower != null && actual < lower!) return true;
    if (upper != null && actual > upper!) return true;
    return false;
  }
}

enum DeviceStatus { normal, warning, critical, offline }

enum ConnectionStatus { connected, disconnected, connecting }

class SystemCategory {
  final String name;
  final int count;

  SystemCategory({required this.name, required this.count});
}
