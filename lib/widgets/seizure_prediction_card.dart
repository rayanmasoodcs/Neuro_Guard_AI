import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/seizure_prediction_model.dart';

/// Widget to display seizure prediction results with visual indicators
class SeizurePredictionCard extends StatelessWidget {
  final SeizurePredictionResult prediction;
  final VoidCallback? onDetails;
  final bool isLoading;

  const SeizurePredictionCard({
    super.key,
    required this.prediction,
    this.onDetails,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seizure Status',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      prediction.seizureType,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B8F55),
                          ),
                    ),
                  ],
                ),
                // Risk Level Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: prediction.getRiskColor().withValues(alpha: 0.15),
                    border: Border.all(
                      color: prediction.getRiskColor(),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prediction.riskLevel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: prediction.getRiskColor(),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Confidence Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prediction Confidence',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: prediction.getConfidenceColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            prediction.getConfidenceText(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: prediction.getConfidenceColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Confidence Meter
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: prediction.confidence,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          prediction.getConfidenceColor(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // EEG Patterns
            if (prediction.eegPatterns.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected EEG Patterns',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: prediction.eegPatterns.map((pattern) {
                      return Chip(
                        label: Text(pattern),
                        avatar: Icon(Icons.check_circle_outline, size: 18),
                        backgroundColor: Color(0xFF0B8F55).withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: Color(0xFF0B8F55),
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                ],
              ),

            // Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prediction Time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm:ss')
                      .format(prediction.predictionTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Details Button
            if (onDetails != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0B8F55),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLoading ? 'Analyzing...' : 'View Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying live sensor values
class LiveSensorValuesCard extends StatelessWidget {
  final double? heartRate;
  final double? bodyTemperature;
  final double? accelerometerIntensity;
  final bool? fallDetected;
  final DateTime timestamp;
  final String dataSource;

  const LiveSensorValuesCard({
    super.key,
    this.heartRate,
    this.bodyTemperature,
    this.accelerometerIntensity,
    this.fallDetected,
    required this.timestamp,
    required this.dataSource,
  });

  String _getHeartRateStatus() {
    if (heartRate == null) return 'N/A';
    if (heartRate! < 60) return 'Low';
    if (heartRate! > 100) return 'High';
    return 'Normal';
  }

  Color _getHeartRateColor() {
    if (heartRate == null) return Colors.grey;
    if (heartRate! < 60) return Color(0xFF2E7D32); // Dark Green
    if (heartRate! > 100) return Color(0xFFEF4444); // Red
    return Color(0xFF22C55E); // Green
  }

  String _getTemperatureStatus() {
    if (bodyTemperature == null) return 'N/A';
    if (bodyTemperature! < 36.1) return 'Low';
    if (bodyTemperature! > 37.5) return 'High';
    return 'Normal';
  }

  Color _getTemperatureColor() {
    if (bodyTemperature == null) return Colors.grey;
    if (bodyTemperature! < 36.1) return Color(0xFF2E7D32);
    if (bodyTemperature! > 37.5) return Color(0xFFEF4444);
    return Color(0xFF22C55E);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Sensor Data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'from $dataSource',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                // Connection indicator
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Connected',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Heart Rate
            if (heartRate != null)
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: 16),
                child: _SensorTile(
                  icon: Icons.favorite,
                  label: 'Heart Rate',
                  value: '${heartRate!.toStringAsFixed(0)} bpm',
                  status: _getHeartRateStatus(),
                  statusColor: _getHeartRateColor(),
                ),
              ),

            // Temperature
            if (bodyTemperature != null)
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: 16),
                child: _SensorTile(
                  icon: Icons.thermostat,
                  label: 'Body Temperature',
                  value: '${bodyTemperature!.toStringAsFixed(1)}°C',
                  status: _getTemperatureStatus(),
                  statusColor: _getTemperatureColor(),
                ),
              ),

            // Motion Intensity
            if (accelerometerIntensity != null)
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: 16),
                child: _SensorTile(
                  icon: Icons.motion_photos_on,
                  label: 'Motion Intensity',
                  value: accelerometerIntensity!.toStringAsFixed(2),
                  status: _getMotionStatus(accelerometerIntensity!),
                  statusColor: _getMotionColor(accelerometerIntensity!),
                ),
              ),

            // Fall Detection
            if (fallDetected != null)
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: 16),
                child: _SensorTile(
                  icon: Icons.warning_outlined,
                  label: 'Fall Detection',
                  value: fallDetected! ? 'FALL DETECTED' : 'Normal',
                  status: fallDetected! ? 'Alert' : 'Safe',
                  statusColor: fallDetected!
                      ? Color(0xFFEF4444)
                      : Color(0xFF22C55E),
                ),
              ),

            SizedBox(height: 16),

            // Timestamp
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Updated: ${DateFormat('HH:mm:ss').format(timestamp)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotionStatus(double intensity) {
    if (intensity < 1.5) return 'Minimal';
    if (intensity < 5) return 'Low';
    if (intensity < 15) return 'Moderate';
    return 'High';
  }

  Color _getMotionColor(double intensity) {
    if (intensity < 1.5) return Color(0xFF22C55E);
    if (intensity < 5) return Color(0xFF22C55E);
    if (intensity < 15) return Color(0xFFFCD34D);
    return Color(0xFFEF4444);
  }
}

/// Individual sensor tile widget
class _SensorTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String status;
  final Color statusColor;

  const _SensorTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: statusColor,
            size: 24,
          ),
        ),
        SizedBox(width: 16),

        // Label and Value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),

        // Status Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}



