import 'dart:math';

class SensorDataModel {
  final double? heartRate;
  final double? bodyTemperature;
  final double? accelerometerX;
  final double? accelerometerY;
  final double? accelerometerZ;
  final double? gyroscopeX;
  final double? gyroscopeY;
  final double? gyroscopeZ;
  final bool? fallDetected;
  final List<int>? eegData;
  final DateTime timestamp;
  final String dataSource; // 'NeuroGuard Band', 'Android Phone', 'Smartwatch'

  SensorDataModel({
    this.heartRate,
    this.bodyTemperature,
    this.accelerometerX,
    this.accelerometerY,
    this.accelerometerZ,
    this.gyroscopeX,
    this.gyroscopeY,
    this.gyroscopeZ,
    this.fallDetected,
    this.eegData,
    required this.timestamp,
    required this.dataSource,
  });

  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      heartRate: json['heart_rate']?.toDouble(),
      bodyTemperature: json['body_temperature']?.toDouble(),
      accelerometerX: json['accelerometer_x']?.toDouble(),
      accelerometerY: json['accelerometer_y']?.toDouble(),
      accelerometerZ: json['accelerometer_z']?.toDouble(),
      gyroscopeX: json['gyroscope_x']?.toDouble(),
      gyroscopeY: json['gyroscope_y']?.toDouble(),
      gyroscopeZ: json['gyroscope_z']?.toDouble(),
      fallDetected: json['fall_detected'] as bool?,
      eegData: json['eeg_data'] != null
          ? List<int>.from(json['eeg_data'] as List)
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      dataSource: json['data_source'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heart_rate': heartRate,
      'body_temperature': bodyTemperature,
      'accelerometer_x': accelerometerX,
      'accelerometer_y': accelerometerY,
      'accelerometer_z': accelerometerZ,
      'gyroscope_x': gyroscopeX,
      'gyroscope_y': gyroscopeY,
      'gyroscope_z': gyroscopeZ,
      'fall_detected': fallDetected,
      'eeg_data': eegData,
      'timestamp': timestamp.toIso8601String(),
      'data_source': dataSource,
    };
  }

  // Helper methods for display
  String getHeartRateStatus() {
    if (heartRate == null) return 'N/A';
    if (heartRate! < 60) return 'Low';
    if (heartRate! > 100) return 'High';
    return 'Normal';
  }

  String getTemperatureStatus() {
    if (bodyTemperature == null) return 'N/A';
    if (bodyTemperature! < 36.1) return 'Low';
    if (bodyTemperature! > 37.5) return 'High';
    return 'Normal';
  }

  String getMotionIntensity() {
    if (accelerometerX == null || accelerometerY == null || accelerometerZ == null) {
      return 'No Data';
    }
    final intensity = sqrt(accelerometerX! * accelerometerX! +
        accelerometerY! * accelerometerY! +
        accelerometerZ! * accelerometerZ!);
    if (intensity < 1.5) return 'Minimal';
    if (intensity < 5) return 'Low';
    if (intensity < 15) return 'Moderate';
    return 'High';
  }
}

