import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_data_model.dart';
import 'package:flutter/foundation.dart';

class SensorDataService {
  static final SensorDataService _instance = SensorDataService._internal();

  factory SensorDataService() {
    return _instance;
  }

  SensorDataService._internal();

  BluetoothDevice? _connectedDevice;
  StreamSubscription? _sensorDataSubscription;
  
  final StreamController<SensorDataModel> _sensorDataController =
      StreamController<SensorDataModel>.broadcast();
  
  Stream<SensorDataModel> get sensorDataStream => _sensorDataController.stream;

  // Common BLE characteristic UUIDs for sensor data
  static String heartRateServiceUuid = '180D';
  static String heartRateCharacteristicUuid = '2A37';
  
  static String temperatureServiceUuid = '181A';
  static String temperatureCharacteristicUuid = '2A1C';
  
  static String accelerometerServiceUuid = 'f000aa80-0451-4000-b000-000000000000';
  static String accelerometerCharacteristicUuid = 'f000aa81-0451-4000-b000-000000000000';
  
  static String gyroscopeServiceUuid = 'f000aa50-0451-4000-b000-000000000000';
  static String gyroscopeCharacteristicUuid = 'f000aa51-0451-4000-b000-000000000000';

  /// Set the connected device for sensor data reading
  void setConnectedDevice(BluetoothDevice device) {
    _connectedDevice = device;
    debugPrint('[SensorData] Device set: ${device.platformName}');
  }

  /// Start reading sensor data from the connected device
  Future<void> startReadingSensorData(String dataSource) async {
    if (_connectedDevice == null) {
      debugPrint('[SensorData] No device connected');
      return;
    }

    try {
      // Get services from the device
      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      debugPrint('[SensorData] Found ${services.length} services');

      // Create a map of service UUIDs to characteristics
      Map<String, BluetoothCharacteristic> characteristics = {};

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          final uuid = characteristic.uuid.toString().toLowerCase();
          characteristics[uuid] = characteristic;
          debugPrint('[SensorData] Found characteristic: $uuid');
        }
      }

      // Start a periodic read of sensor data
      _sensorDataSubscription = Stream.periodic(Duration(seconds: 1)).listen((_) async {
        await _readAllSensorData(characteristics, dataSource);
      });
    } catch (e) {
      debugPrint('[SensorData] Error discovering services: $e');
    }
  }

  /// Read all available sensor data
  Future<void> _readAllSensorData(
    Map<String, BluetoothCharacteristic> characteristics,
    String dataSource,
  ) async {
    try {
      double? heartRate;
      double? temperature;
      double? accelX, accelY, accelZ;
      double? gyroX, gyroY, gyroZ;

      // Read Heart Rate
      if (characteristics.containsKey(heartRateCharacteristicUuid.toLowerCase())) {
        final List<int> value = await characteristics[heartRateCharacteristicUuid.toLowerCase()]!.read();
        if (value.isNotEmpty) {
          heartRate = _parseHeartRate(value);
        }
      }

      // Read Temperature
      if (characteristics.containsKey(temperatureCharacteristicUuid.toLowerCase())) {
        final List<int> value = await characteristics[temperatureCharacteristicUuid.toLowerCase()]!.read();
        if (value.isNotEmpty) {
          temperature = _parseTemperature(value);
        }
      }

      // Read Accelerometer
      if (characteristics.containsKey(accelerometerCharacteristicUuid.toLowerCase())) {
        final List<int> value = await characteristics[accelerometerCharacteristicUuid.toLowerCase()]!.read();
        if (value.length >= 6) {
          final parsed = _parseAccelerometer(value);
          accelX = parsed['x'];
          accelY = parsed['y'];
          accelZ = parsed['z'];
        }
      }

      // Read Gyroscope
      if (characteristics.containsKey(gyroscopeCharacteristicUuid.toLowerCase())) {
        final List<int> value = await characteristics[gyroscopeCharacteristicUuid.toLowerCase()]!.read();
        if (value.length >= 6) {
          final parsed = _parseGyroscope(value);
          gyroX = parsed['x'];
          gyroY = parsed['y'];
          gyroZ = parsed['z'];
        }
      }

      // Create sensor data model
      final sensorData = SensorDataModel(
        heartRate: heartRate,
        bodyTemperature: temperature,
        accelerometerX: accelX,
        accelerometerY: accelY,
        accelerometerZ: accelZ,
        gyroscopeX: gyroX,
        gyroscopeY: gyroY,
        gyroscopeZ: gyroZ,
        fallDetected: _detectFall(accelX, accelY, accelZ),
        timestamp: DateTime.now(),
        dataSource: dataSource,
      );

      _sensorDataController.add(sensorData);
      debugPrint('[SensorData] Updated: HR=$heartRate, Temp=$temperature, DataSource=$dataSource');
    } catch (e) {
      debugPrint('[SensorData] Error reading sensor data: $e');
    }
  }

  /// Parse heart rate from BLE characteristic value
  double _parseHeartRate(List<int> value) {
    // Typical heart rate format: [flags, heart_rate_bpm]
    if (value.length >= 2) {
      return value[1].toDouble();
    }
    return value[0].toDouble();
  }

  /// Parse temperature from BLE characteristic value
  double _parseTemperature(List<int> value) {
    // Temperature is typically stored as a 16-bit integer in 0.01°C units
    if (value.length >= 2) {
      final temp = (value[0] | (value[1] << 8));
      return temp / 100.0;
    }
    return 36.5;
  }

  /// Parse accelerometer data from BLE characteristic value
  Map<String, double> _parseAccelerometer(List<int> value) {
    // Accelerometer data: 3x 16-bit signed integers (x, y, z)
    final x = _readInt16(value, 0) / 1000.0;
    final y = _readInt16(value, 2) / 1000.0;
    final z = _readInt16(value, 4) / 1000.0;
    return {'x': x, 'y': y, 'z': z};
  }

  /// Parse gyroscope data from BLE characteristic value
  Map<String, double> _parseGyroscope(List<int> value) {
    // Gyroscope data: 3x 16-bit signed integers (x, y, z)
    final x = _readInt16(value, 0) / 100.0;
    final y = _readInt16(value, 2) / 100.0;
    final z = _readInt16(value, 4) / 100.0;
    return {'x': x, 'y': y, 'z': z};
  }

  /// Read a 16-bit signed integer from bytes
  int _readInt16(List<int> bytes, int offset) {
    int value = (bytes[offset] & 0xFF) | ((bytes[offset + 1] & 0xFF) << 8);
    if (value & 0x8000 != 0) {
      value = -((~value & 0xFFFF) + 1);
    }
    return value;
  }

  /// Detect fall based on accelerometer data
  bool _detectFall(double? accelX, double? accelY, double? accelZ) {
    if (accelX == null || accelY == null || accelZ == null) return false;
    
    // Calculate the magnitude of acceleration
    final magnitude = sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);
    
    // Fall detection: high magnitude followed by low magnitude
    // Threshold can be tuned based on real-world data
    return magnitude > 20.0;
  }

  /// Stop reading sensor data
  Future<void> stopReadingSensorData() async {
    await _sensorDataSubscription?.cancel();
    debugPrint('[SensorData] Stopped reading sensor data');
  }

  void dispose() {
    _sensorDataSubscription?.cancel();
    _sensorDataController.close();
  }
}



