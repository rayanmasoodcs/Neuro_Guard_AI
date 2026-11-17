import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/bluetooth_device_model.dart';

// Conditional import: uses the real implementation on web and a stub on other platforms.
import 'bluetooth_web_helper_stub.dart'
    if (dart.library.html) 'bluetooth_web_helper.dart' as web_helper;

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();

  factory BluetoothService() {
    return _instance;
  }

  BluetoothService._internal();
  
  late SharedPreferences _prefs;
  StreamSubscription? _scanSubscription;
  
  final List<BluetoothDeviceModel> _scannedDevices = [];
  final List<BluetoothDeviceModel> _pairedDevices = [];
  BluetoothDevice? _connectedDevice;
  
  bool _isScanning = false;
  bool _isInitialized = false;

  final StreamController<List<BluetoothDeviceModel>> _devicesStreamController =
      StreamController<List<BluetoothDeviceModel>>.broadcast();
  
  final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();

  Stream<List<BluetoothDeviceModel>> get devicesStream =>
      _devicesStreamController.stream;
  
  Stream<String> get connectionStatusStream =>
      _connectionStatusController.stream;

  bool get isScanning => _isScanning;
  bool get isInitialized => _isInitialized;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothDeviceModel> get pairedDevices => _pairedDevices;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    
    // Restore previously paired device
    await _restorePairedDevice();
    
    debugPrint('[Bluetooth] Service initialized');
  }

  Future<bool> requestPermissions() async {
    // permission_handler does not support web; on web the browser
    // prompts for Bluetooth access when starting a scan. Skip permission
    // requests there to avoid throwing exceptions.
    try {
      // Use kIsWeb to short-circuit web platforms.
      if (bool.fromEnvironment('dart.library.html', defaultValue: false)) {
        debugPrint('[Bluetooth] Running on web, skipping permission_handler');
        return true;
      }
    } catch (_) {
      // Fallback: continue to permission checks on non-web.
    }

    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ];

    final results = await permissions.request();
    
    bool allGranted = true;
    for (var result in results.values) {
      if (!result.isGranted) {
        allGranted = false;
        break;
      }
    }

    if (allGranted) {
      debugPrint('[Bluetooth] All permissions granted');
    } else {
      debugPrint('[Bluetooth] Some permissions denied');
    }

    return allGranted;
  }

  Future<bool> isBluetoothEnabled() async {
    try {
      var state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('[Bluetooth] Error checking BLE state: $e');
      return false;
    }
  }

  Future<void> startScan({Duration? scanDuration}) async {
    if (_isScanning) return;
    final duration = scanDuration ?? const Duration(seconds: 10);

    // Web: use the browser chooser flow (requestDevice) because scanning
    // for advertising peripherals via platform APIs is not always available.
    if (kIsWeb) {
      _isScanning = true;
      _connectionStatusController.add('Scanning...');
      try {
        final deviceInfo = await web_helper.requestDeviceViaBrowser();
        if (deviceInfo == null) {
          _connectionStatusController.add('Device selection cancelled');
          _isScanning = false;
          return;
        }

        // On web, simulate a decent signal strength since we can't get real RSSI
        // Using a random value between -60 and -40 (Good to Excellent range)
        final simulatedRssi = -40 - (DateTime.now().millisecond % 20);
        
        final newDevice = BluetoothDeviceModel(
          id: deviceInfo['id'] ?? '',
          name: deviceInfo['name'] ?? 'Unknown Device',
          rssi: simulatedRssi,
          isConnected: false,
          isConnecting: false,
          lastSeen: DateTime.now(),
          deviceType: _detectDeviceType(deviceInfo['name'] ?? ''),
        );

        _scannedDevices.clear();
        _scannedDevices.add(newDevice);
        _devicesStreamController.add(List.from(_scannedDevices));
        _connectionStatusController.add('Device selected');
        debugPrint('[Bluetooth] Web device selected: ${newDevice.name} (RSSI: $simulatedRssi)');
      } catch (e) {
        _connectionStatusController.add('Device selection failed: ${e.toString()}');
        debugPrint('[Bluetooth] Web scan error: $e');
      } finally {
        _isScanning = false;
      }
      return;
    }

    if (!await isBluetoothEnabled()) {
      _connectionStatusController.add('Bluetooth is disabled');
      debugPrint('[Bluetooth] Bluetooth is disabled');
      return;
    }

    _isScanning = true;
    _scannedDevices.clear();
    _connectionStatusController.add('Scanning...');
    debugPrint('[Bluetooth] Started scanning for devices');

    try {
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final device = result.device;
          final existingIndex = _scannedDevices.indexWhere((d) => d.id == device.remoteId.str);
          
          final newDevice = BluetoothDeviceModel(
            id: device.remoteId.str,
            name: device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
            rssi: result.rssi,
            isConnected: device.isConnected,
            isConnecting: false,
            lastSeen: DateTime.now(),
            deviceType: _detectDeviceType(device.platformName),
          );

          if (existingIndex >= 0) {
            _scannedDevices[existingIndex] = newDevice;
          } else {
            _scannedDevices.add(newDevice);
          }
        }
        
        _devicesStreamController.add(List.from(_scannedDevices));
      });

      await FlutterBluePlus.startScan(timeout: duration);
      
      Future.delayed(duration, () {
        stopScan();
      });
    } catch (e) {
      _connectionStatusController.add('Scan failed: ${e.toString()}');
      debugPrint('[Bluetooth] Scan error: $e');
      _isScanning = false;
    }
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;
    
    try {
      await FlutterBluePlus.stopScan();
      _isScanning = false;
      debugPrint('[Bluetooth] Scan stopped');
      _connectionStatusController.add('Scan completed');
    } catch (e) {
      debugPrint('[Bluetooth] Error stopping scan: $e');
    }
  }

  Future<bool> connectToDevice(BluetoothDeviceModel device) async {
    try {
      _connectionStatusController.add('Connecting to ${device.name}...');
      debugPrint('[Bluetooth] Connecting to ${device.name} (${device.id})');

      if (kIsWeb) {
        // Use web helper to connect
        final ok = await web_helper.connectToDevice(device.id);
        if (!ok) {
          _connectionStatusController.add('Connection failed: web connect error');
          return false;
        }

        // Mark device as paired/connected in model lists
        final existing = _pairedDevices.indexWhere((d) => d.id == device.id);
        final now = DateTime.now();
        final model = BluetoothDeviceModel(
          id: device.id,
          name: device.name,
          rssi: device.rssi,
          isConnected: true,
          isConnecting: false,
          lastSeen: now,
          deviceType: device.deviceType,
        );

        if (existing >= 0) {
          _pairedDevices[existing] = model;
        } else {
          _pairedDevices.add(model);
        }

        await _savePairedDevice(model);
        _connectionStatusController.add('Connected to ${device.name}');
        debugPrint('[Bluetooth] Web: connected to ${device.name}');
        return true;
      }

      final bluetoothDevice = BluetoothDevice(remoteId: DeviceIdentifier(device.id));
      
      await bluetoothDevice.connect(timeout: Duration(seconds: 10), autoConnect: true);
      
      _connectedDevice = bluetoothDevice;
      
      // Save to SharedPreferences
      await _savePairedDevice(device);
      
      _connectionStatusController.add('Connected to ${device.name}');
      debugPrint('[Bluetooth] Successfully connected to ${device.name}');
      
      return true;
    } catch (e) {
      _connectionStatusController.add('Connection failed: ${e.toString()}');
      debugPrint('[Bluetooth] Connection error: $e');
      return false;
    }
  }

  Future<bool> disconnectFromDevice() async {
    try {
      if (kIsWeb) {
        // For web, disconnect the selected JS device and update model
        if (_pairedDevices.isNotEmpty) {
          final connectedIndex = _pairedDevices.indexWhere((d) => d.isConnected);
          if (connectedIndex >= 0) {
            final id = _pairedDevices[connectedIndex].id;
            await web_helper.disconnectDevice(id);
            _pairedDevices[connectedIndex] = BluetoothDeviceModel(
              id: _pairedDevices[connectedIndex].id,
              name: _pairedDevices[connectedIndex].name,
              rssi: _pairedDevices[connectedIndex].rssi,
              isConnected: false,
              isConnecting: false,
              lastSeen: _pairedDevices[connectedIndex].lastSeen,
              deviceType: _pairedDevices[connectedIndex].deviceType,
            );
            _connectionStatusController.add('Disconnected');
            debugPrint('[Bluetooth] Web: disconnected from device $id');
            return true;
          }
        }
        return false;
      }

      if (_connectedDevice != null) {
        _connectionStatusController.add('Disconnecting...');
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        debugPrint('[Bluetooth] Disconnected from device');
        _connectionStatusController.add('Disconnected');
        return true;
      }
    } catch (e) {
      debugPrint('[Bluetooth] Disconnect error: $e');
    }
    return false;
  }

  Future<void> _savePairedDevice(BluetoothDeviceModel device) async {
    await _prefs.setString('paired_device_id', device.id);
    await _prefs.setString('paired_device_name', device.name);
    debugPrint('[Bluetooth] Saved paired device: ${device.name}');
  }

  Future<void> _restorePairedDevice() async {
    final deviceId = _prefs.getString('paired_device_id');
    final deviceName = _prefs.getString('paired_device_name');

    if (deviceId != null && deviceName != null) {
      // On web, use simulated RSSI (Good range); on mobile, use low default
      final rssi = kIsWeb ? -50 : -100;
      
      final pairedDevice = BluetoothDeviceModel(
        id: deviceId,
        name: deviceName,
        rssi: rssi,
        isConnected: false,
        isConnecting: false,
      );
      
      _pairedDevices.add(pairedDevice);
      debugPrint('[Bluetooth] Restored paired device: $deviceName (RSSI: $rssi)');

      // Attempt auto-reconnect
      _attemptAutoReconnect(pairedDevice);
    }
  }

  Future<void> _attemptAutoReconnect(BluetoothDeviceModel device) async {
    if (!await isBluetoothEnabled()) {
      debugPrint('[Bluetooth] Bluetooth disabled, cannot auto-reconnect');
      return;
    }

    debugPrint('[Bluetooth] Attempting auto-reconnect to ${device.name}');
    await connectToDevice(device);
  }

  Future<void> unpairDevice(String deviceId) async {
    try {
      _pairedDevices.removeWhere((d) => d.id == deviceId);
      await _prefs.remove('paired_device_id');
      await _prefs.remove('paired_device_name');
      
      if (_connectedDevice?.remoteId.str == deviceId) {
        await disconnectFromDevice();
      }
      
      debugPrint('[Bluetooth] Unpaired device: $deviceId');
    } catch (e) {
      debugPrint('[Bluetooth] Unpair error: $e');
    }
  }

  String _detectDeviceType(String deviceName) {
    final lowerName = deviceName.toLowerCase();
    if (lowerName.contains('watch') || lowerName.contains('band') || lowerName.contains('wear')) {
      return 'Smartwatch';
    } else if (lowerName.contains('earbuds') || lowerName.contains('buds')) {
      return 'Earbuds';
    } else if (lowerName.contains('phone')) {
      return 'Phone';
    }
    return 'Device';
  }

  void dispose() {
    _scanSubscription?.cancel();
    _devicesStreamController.close();
    _connectionStatusController.close();
  }
}


