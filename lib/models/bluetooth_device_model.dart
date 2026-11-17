class BluetoothDeviceModel {
  final String id;
  final String name;
  final int rssi;
  final bool isConnected;
  final bool isConnecting;
  final DateTime? lastSeen;
  final String? deviceType;

  BluetoothDeviceModel({
    required this.id,
    required this.name,
    required this.rssi,
    required this.isConnected,
    required this.isConnecting,
    this.lastSeen,
    this.deviceType,
  });

  factory BluetoothDeviceModel.fromJson(Map<String, dynamic> json) {
    return BluetoothDeviceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Device',
      rssi: json['rssi'] ?? -100,
      isConnected: json['isConnected'] ?? false,
      isConnecting: json['isConnecting'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      deviceType: json['deviceType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rssi': rssi,
      'isConnected': isConnected,
      'isConnecting': isConnecting,
      'lastSeen': lastSeen?.toIso8601String(),
      'deviceType': deviceType,
    };
  }

  String getSignalStrength() {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -60) return 'Good';
    if (rssi >= -70) return 'Fair';
    return 'Poor';
  }

  double getSignalPercentage() {
    if (rssi >= -50) return 1.0;
    if (rssi >= -60) return 0.75;
    if (rssi >= -70) return 0.5;
    if (rssi >= -80) return 0.25;
    return 0.1;
  }
}

