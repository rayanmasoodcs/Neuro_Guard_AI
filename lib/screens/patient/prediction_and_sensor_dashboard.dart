import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/seizure_prediction_model.dart';
import '../../models/sensor_data_model.dart';
import '../../services/prediction_service.dart';
import '../../widgets/seizure_prediction_card.dart';

class PredictionAndSensorDashboard extends StatefulWidget {
  final int userId;
  final String? patientId;

  const PredictionAndSensorDashboard({
    super.key,
    required this.userId,
    this.patientId,
  });

  @override
  State<PredictionAndSensorDashboard> createState() =>
      _PredictionAndSensorDashboardState();
}

class _PredictionAndSensorDashboardState
    extends State<PredictionAndSensorDashboard> {
  late PredictionService _predictionService;

  SeizurePredictionResult? _latestPrediction;
  List<Map<String, dynamic>> _alerts = [];
  SensorDataModel? _latestSensorData;
  List<Map<String, dynamic>> _sensorHistory = [];

  bool _isLoadingPrediction = false;
  bool _isLoadingAlerts = false;
  bool _isLoadingSensorData = false;

  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _predictionService = PredictionService();

    _loadDashboardData();

    // Set up periodic refresh (every 30 seconds)
    Future.delayed(Duration(seconds: 30), _refreshDashboardData);
  }

  Future<void> _loadDashboardData() async {
    await Future.wait([
      _loadLatestPrediction(),
      _loadAlerts(),
      _loadSensorHistory(),
    ]);
  }

  Future<void> _refreshDashboardData() async {
    if (mounted) {
      await _loadDashboardData();
      // Schedule next refresh
      Future.delayed(Duration(seconds: 30), _refreshDashboardData);
    }
  }

  Future<void> _loadLatestPrediction() async {
    setState(() => _isLoadingPrediction = true);
    try {
      final history = await _predictionService.getPredictionHistory(
        userId: widget.userId,
      );
      if (history.isNotEmpty && mounted) {
        // Create prediction from history
        setState(() {
          _latestPrediction = history.first;
        });
      }
    } catch (e) {
      debugPrint('[Dashboard] Error loading prediction: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPrediction = false);
      }
    }
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoadingAlerts = true);
    try {
      final alerts = await _predictionService.getAlerts(
        userId: widget.userId,
        limit: 10,
        days: 7,
      );
      if (mounted) {
        setState(() => _alerts = alerts);
      }
    } catch (e) {
      debugPrint('[Dashboard] Error loading alerts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingAlerts = false);
      }
    }
  }

  Future<void> _loadSensorHistory() async {
    setState(() => _isLoadingSensorData = true);
    try {
      final history = await _predictionService.getSensorHistory(
        userId: widget.userId,
        limit: 100,
        hours: 24,
      );
      if (mounted) {
        setState(() {
          _sensorHistory = history;
          if (history.isNotEmpty) {
            // Convert latest sensor data
            final latest = history.first;
            _latestSensorData = SensorDataModel(
              heartRate: latest['heart_rate']?.toDouble(),
              bodyTemperature: latest['body_temperature']?.toDouble(),
              accelerometerX: latest['accelerometer_x']?.toDouble(),
              accelerometerY: latest['accelerometer_y']?.toDouble(),
              accelerometerZ: latest['accelerometer_z']?.toDouble(),
              gyroscopeX: latest['gyroscope_x']?.toDouble(),
              gyroscopeY: latest['gyroscope_y']?.toDouble(),
              gyroscopeZ: latest['gyroscope_z']?.toDouble(),
              fallDetected: latest['fall_detected'] == 1,
              timestamp: DateTime.parse(
                latest['created_at'] ?? DateTime.now().toIso8601String(),
              ),
              dataSource: latest['data_source'] ?? 'Unknown',
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[Dashboard] Error loading sensor history: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSensorData = false);
      }
    }
  }

  Future<void> _acknowledgeAlert(int alertId) async {
    final success = await _predictionService.acknowledgeAlert(
      alertId: alertId,
      acknowledgedBy: 'patient_app',
      actionTaken: 'Reviewed',
    );

    if (success) {
      _showSnackBar('Alert acknowledged');
      _loadAlerts();
    } else {
      _showSnackBar('Failed to acknowledge alert');
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
        backgroundColor: Colors.white,
        title: Text(
          'Health Monitoring',
          style: TextStyle(
            color: Color(0xFF0B8F55),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF0B8F55)),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab Navigation
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab(0, 'Predictions', Icons.analytics),
                    _buildTab(1, 'Sensor Data', Icons.sensors),
                    _buildTab(2, 'Alerts', Icons.notifications_active),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Content based on selected tab
              if (_selectedTabIndex == 0) _buildPredictionsTab(),
              if (_selectedTabIndex == 1) _buildSensorDataTab(),
              if (_selectedTabIndex == 2) _buildAlertsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 12.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF0B8F55) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Color(0xFF0B8F55)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Color(0xFF0B8F55),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF0B8F55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionsTab() {
    if (_isLoadingPrediction) {
      return Center(child: CircularProgressIndicator());
    }

    if (_latestPrediction == null) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'No predictions yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Upload an EEG file or connect a sensor device to get predictions',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SeizurePredictionCard(
      prediction: _latestPrediction!,
      onDetails: () {
        _showPredictionDetails(_latestPrediction!);
      },
      isLoading: _isLoadingPrediction,
    );
  }

  Widget _buildSensorDataTab() {
    if (_isLoadingSensorData) {
      return Center(child: CircularProgressIndicator());
    }

    if (_latestSensorData == null) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors_off, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'No sensor data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Connect a Bluetooth device to view real-time sensor data',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        LiveSensorValuesCard(
          heartRate: _latestSensorData!.heartRate,
          bodyTemperature: _latestSensorData!.bodyTemperature,
          accelerometerIntensity: _latestSensorData!.accelerometerX != null
              ? (_latestSensorData!.accelerometerX! *
                            _latestSensorData!.accelerometerX! +
                        _latestSensorData!.accelerometerY! *
                            _latestSensorData!.accelerometerY! +
                        _latestSensorData!.accelerometerZ! *
                            _latestSensorData!.accelerometerZ!)
                    .toDouble()
              : null,
          fallDetected: _latestSensorData!.fallDetected,
          timestamp: _latestSensorData!.timestamp,
          dataSource: _latestSensorData!.dataSource,
        ),
        SizedBox(height: 20),
        if (_sensorHistory.length > 1)
          Text(
            'History (Last 24 hours)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        if (_sensorHistory.length > 1) SizedBox(height: 12),
        if (_sensorHistory.length > 1)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_sensorHistory.length} readings recorded in the last 24 hours',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  Widget _buildAlertsTab() {
    if (_isLoadingAlerts) {
      return Center(child: CircularProgressIndicator());
    }

    if (_alerts.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Color(0xFF22C55E)),
            SizedBox(height: 16),
            Text('No alerts', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Text(
              'You\'re all set! No seizure alerts in the past 7 days',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return Padding(
          padding: EdgeInsetsDirectional.only(bottom: 12.0),
          child: _buildAlertCard(alert),
        );
      },
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final severity = alert['severity'] ?? 'Medium';
    final isAcknowledged = alert['is_acknowledged'] == 1;

    Color severityColor = Colors.orange;
    if (severity == 'High') {
      severityColor = Color(0xFFEF4444);
    } else if (severity == 'Low') {
      severityColor = Color(0xFF22C55E);
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['seizure_type'] ?? 'Alert',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • HH:mm',
                        ).format(DateTime.parse(alert['created_at'])),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    severity,
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Message
            if (alert['alert_message'] != null)
              Text(
                alert['alert_message'],
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
              ),
            SizedBox(height: 12),

            // Confidence
            if (alert['confidence_score'] != null)
              Row(
                children: [
                  Text(
                    'Confidence: ',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    '${(alert['confidence_score'] * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 12),

            // Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isAcknowledged)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF22C55E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Color(0xFF22C55E),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Acknowledged',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _acknowledgeAlert(alert['id'] as int),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0B8F55),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Acknowledge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  void _showPredictionDetails(SeizurePredictionResult prediction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prediction Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  prediction.getDetailedAnalysis(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





