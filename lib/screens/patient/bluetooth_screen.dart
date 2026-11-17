import 'package:flutter/material.dart';
import '../../services/bluetooth_service.dart';
import '../../models/bluetooth_device_model.dart';
import '../../widgets/bluetooth_device_card.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';

class PatientBluetoothScreen extends StatefulWidget {
  const PatientBluetoothScreen({super.key});

  @override
  State<PatientBluetoothScreen> createState() => _PatientBluetoothScreenState();
}

class _PatientBluetoothScreenState extends State<PatientBluetoothScreen> {
  late BluetoothService _bluetoothService;
  bool _isBluetoothEnabled = false;
  List<BluetoothDeviceModel> _availableDevices = [];
  String _connectionStatus = '';

  @override
  void initState() {
    super.initState();
    _bluetoothService = BluetoothService();
    _initializeBluetoothService();
  }

  Future<void> _initializeBluetoothService() async {
    try {
      await _bluetoothService.initialize();
      
      bool hasPermissions = await _bluetoothService.requestPermissions();
      if (!hasPermissions) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context).bluetoothPermissionRequired)),
          );
        }
        return;
      }

      bool enabled = await _bluetoothService.isBluetoothEnabled();
      if (mounted) {
        setState(() {
          _isBluetoothEnabled = enabled;
          _connectionStatus = enabled ? AppLocalizations.of(context).readyToScan : AppLocalizations.of(context).bluetoothDisabled;
        });
      }

      // Listen to streams
      _bluetoothService.devicesStream.listen((devices) {
        if (mounted) {
          setState(() {
            _availableDevices = devices;
          });
        }
      });

      _bluetoothService.connectionStatusStream.listen((status) {
        if (mounted) {
          setState(() {
            _connectionStatus = status;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing Bluetooth: $e');
      if (mounted) {
        setState(() {
          _connectionStatus = 'Initialization failed';
        });
      }
    }
  }

  void _startScan() async {
    if (!_isBluetoothEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).enableBluetooth)),
      );
      return;
    }

    await _bluetoothService.startScan();
  }

  void _stopScan() async {
    await _bluetoothService.stopScan();
  }

  void _connectToDevice(BluetoothDeviceModel device) async {
    bool success = await _bluetoothService.connectToDevice(device);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).connectedTo(device.name))),
      );
    }
  }

  void _disconnectFromDevice() async {
    bool success = await _bluetoothService.disconnectFromDevice();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).disconnected)),
      );
    }
  }

  void _unpairDevice(String deviceId) async {
    await _bluetoothService.unpairDevice(deviceId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).deviceUnpaired)),
      );
    }
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show connected device from pairedDevices for web and platform independence
    final pairedDevices = _bluetoothService.pairedDevices;
    BluetoothDeviceModel? connectedDeviceModel;
    for (var d in pairedDevices) {
      if (d.isConnected) {
        connectedDeviceModel = d;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Text(
                  AppLocalizations.of(context).bluetoothTitle,
                  style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(bottom: 20),
        child: Column(
          children: [
            // Status Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0B8F55).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFF0B8F55).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bluetooth,
                          color: Color(0xFF0B8F55),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                                              AppLocalizations.of(context).bluetoothStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _connectionStatus,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isBluetoothEnabled ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Connected Device Section (uses BluetoothDeviceModel for cross-platform)
            if (connectedDeviceModel != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected Device',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Color(0xFF0B8F55),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFF0B8F55).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.bluetooth_connected,
                                color: Color(0xFF0B8F55),
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    connectedDeviceModel.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF0B8F55)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Connected',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF0B8F55),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              onPressed: _disconnectFromDevice,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Paired Devices Section
            if (pairedDevices.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paired Devices',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    ...pairedDevices.map((device) {
                      return BluetoothDeviceCard(
                        device: device,
                        isPaired: true,
                        onConnect: () => _connectToDevice(device),
                        onDisconnect: _disconnectFromDevice,
                        onUnpair: () => _unpairDevice(device.id),
                      );
                    }),
                  ],
                ),
              ),

            // Available Devices Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Devices',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${_availableDevices.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (_availableDevices.isEmpty && !_bluetoothService.isScanning)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.bluetooth_disabled,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No devices found',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap "Scan" to search for nearby devices',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...(_availableDevices.map((device) {
                      return BluetoothDeviceCard(
                        device: device,
                        isPaired: false,
                        onConnect: () => _connectToDevice(device),
                        onDisconnect: () {},
                      );
                    }).toList()),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF0B8F55),
        foregroundColor: Colors.white,
        onPressed: _bluetoothService.isScanning ? _stopScan : _startScan,
        icon: Icon(_bluetoothService.isScanning ? Icons.stop : Icons.search),
        label: Text(
          _bluetoothService.isScanning ? 'Stop Scanning' : 'Start Scan',
        ),
      ),
    );
  }
}







