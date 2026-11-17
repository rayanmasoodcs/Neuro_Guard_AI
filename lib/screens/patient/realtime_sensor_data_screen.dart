import 'package:flutter/material.dart';
import '../../services/sensor_data_service.dart';
import '../../services/bluetooth_service.dart';
import '../../models/sensor_data_model.dart';
import '../../responsive/responsive.dart';

class RealTimeSensorDataScreen extends StatefulWidget {
  const RealTimeSensorDataScreen({super.key});

  @override
  State<RealTimeSensorDataScreen> createState() =>
      _RealTimeSensorDataScreenState();
}

class _RealTimeSensorDataScreenState extends State<RealTimeSensorDataScreen> {
  late SensorDataService _sensorDataService;
  late BluetoothService _bluetoothService;
  String _selectedDataSource = 'NeuroGuard Band';
  bool _isReading = false;

  final List<String> dataSources = [
    'NeuroGuard Band (BLE)',
    'Android Phone (Simulated)',
    'Smartwatch (BLE)',
  ];

  @override
  void initState() {
    super.initState();
    _sensorDataService = SensorDataService();
    _bluetoothService = BluetoothService();
  }

  Future<void> _startReading() async {
    try {
      final pairedDevices = _bluetoothService.pairedDevices;

      if (pairedDevices.isEmpty) {
        _showSnackBar(
          'No paired Bluetooth devices found. Please pair a device first.',
        );
        return;
      }

      // Use the first paired device
      final device = pairedDevices.first;
      debugPrint('[UI] Starting sensor reading from ${device.name}');

      // Note: On mobile, we would set the actual BluetoothDevice reference
      // On web, BLE handling is different through the Web Bluetooth API
      // For demonstration, we skip the device connection setup here
      // In production, you would need to maintain a reference to the connected device

      setState(() => _isReading = true);
      await _sensorDataService.startReadingSensorData(_selectedDataSource);
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
      debugPrint('[Error] Failed to start reading: $e');
    }
  }

  Future<void> _stopReading() async {
    try {
      await _sensorDataService.stopReadingSensorData();
      setState(() => _isReading = false);
      _showSnackBar('Sensor reading stopped');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FAF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF0B8F55),
        title: Text(
          'Real-Time Sensor Data',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isReading) {
              _stopReading();
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Source Selection
            Text(
              'Select Data Source',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildDataSourceButtons(),
            SizedBox(height: 24),

            // Start/Stop Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isReading ? _stopReading : _startReading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isReading
                      ? Colors.red.shade600
                      : Color(0xFF0B8F55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  _isReading ? Icons.stop_circle : Icons.play_circle_filled,
                ),
                label: Text(
                  _isReading ? 'Stop Reading' : 'Start Reading',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Disclaimer
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade800),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Disclaimer: This app pairs with physical hardware via BLE. '
                      'It is not intended to replace professional medical advice, diagnosis, or treatment.',
                      style: TextStyle(color: Colors.amber.shade900, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Sensor Data Display
            if (_isReading)
              StreamBuilder<SensorDataModel>(
                stream: _sensorDataService.sensorDataStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF0B8F55),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Waiting for sensor data...',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data!;

                  return Column(
                    children: [
                      _buildSensorCard(
                        title: 'Heart Rate',
                        value: data.heartRate != null
                            ? '${data.heartRate!.toStringAsFixed(0)} bpm'
                            : 'N/A',
                        unit: 'beats/min',
                        icon: Icons.favorite,
                        status: data.getHeartRateStatus(),
                        color: _getStatusColor(data.getHeartRateStatus()),
                      ),
                      SizedBox(height: 12),
                      _buildSensorCard(
                        title: 'Body Temperature',
                        value: data.bodyTemperature != null
                            ? '${data.bodyTemperature!.toStringAsFixed(1)}°C'
                            : 'N/A',
                        unit: 'Celsius',
                        icon: Icons.thermostat,
                        status: data.getTemperatureStatus(),
                        color: _getStatusColor(data.getTemperatureStatus()),
                      ),
                      SizedBox(height: 12),
                      _buildMotionCard(data),
                      SizedBox(height: 12),
                      _buildRotationCard(data),
                      SizedBox(height: 12),
                      if (data.fallDetected ?? false)
                        _buildAlertCard(
                          'Fall Detected!',
                          Icons.warning,
                          Colors.red,
                        ),
                      if (data.eegData != null &&
                          (data.eegData?.isNotEmpty ?? false))
                        _buildEegCard(data.eegData),
                      SizedBox(height: 12),
                      _buildTimestampCard(data.timestamp),
                    ],
                  );
                },
              )
            else
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade100,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.sensors_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Click "Start Reading" to begin receiving sensor data',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSourceButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: dataSources.map((source) {
        final isSelected = _selectedDataSource == source;
        return FilterChip(
          selected: isSelected,
          onSelected: _isReading
              ? null
              : (selected) {
                  setState(() => _selectedDataSource = source);
                },
          label: Text(source),
          backgroundColor: Colors.white,
          selectedColor: Color(0xFF0B8F55),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required String status,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    unit,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotionCard(SensorDataModel data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF0B8F55).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Color(0xFF0B8F55),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Motion/Accelerometer',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        data.getMotionIntensity(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildAxisRow('X', data.accelerometerX),
            SizedBox(height: 8),
            _buildAxisRow('Y', data.accelerometerY),
            SizedBox(height: 8),
            _buildAxisRow('Z', data.accelerometerZ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationCard(SensorDataModel data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF2E7D32).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.rotate_90_degrees_ccw,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Gyroscope/Rotation',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildAxisRow('X (Roll)', data.gyroscopeX),
            SizedBox(height: 8),
            _buildAxisRow('Y (Pitch)', data.gyroscopeY),
            SizedBox(height: 8),
            _buildAxisRow('Z (Yaw)', data.gyroscopeZ),
          ],
        ),
      ),
    );
  }

  Widget _buildAxisRow(String label, double? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value != null ? '${value.toStringAsFixed(2)} m/s²' : 'N/A',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(String message, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEegCard(List<int>? eegData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF0B8F55).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Color(0xFF0B8F55),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'EEG Data',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Data Points: ${eegData?.length ?? 0}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            if (eegData != null && eegData.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Sample: ${eegData.take(5).join(', ')}...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampCard(DateTime timestamp) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Center(
        child: Text(
          'Last Update: ${timestamp.hour}:${timestamp.minute}:${timestamp.second}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return Colors.green;
      case 'Low':
        return Color(0xFF2E7D32);
      case 'High':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    if (_isReading) {
      _sensorDataService.stopReadingSensorData();
    }
    super.dispose();
  }
}




