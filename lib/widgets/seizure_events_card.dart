// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../services/alerts_service.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// SeizureEventsCard Widget
/// 
/// Displays recent seizure events with date, time, severity, and status.
/// Shows medication and appointment notification status.
/// Includes quick actions to acknowledge events and add doctor notes.
class SeizureEventsCard extends StatefulWidget {
  final int userId;
  final String? patientId;
  final VoidCallback? onRefresh;

  const SeizureEventsCard({
    super.key,
    required this.userId,
    this.patientId,
    this.onRefresh,
  });

  @override
  State<SeizureEventsCard> createState() => _SeizureEventsCardState();
}

class _SeizureEventsCardState extends State<SeizureEventsCard> {
  final AlertsService _alertsService = AlertsService();
  List<Map<String, dynamic>> _seizureEvents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSeizureEvents();
  }

  /// Load seizure events from backend
  Future<void> _loadSeizureEvents() async {
    setState(() => _isLoading = true);

    final events = await _alertsService.getSeizureEvents(
      userId: widget.userId,
      days: 30,
      limit: 10,
    );

    setState(() {
      _seizureEvents = events;
      _isLoading = false;
    });
  }

  /// Format timestamp for display (e.g., "Jul 21, 14:30")
  String _formatEventDateTime(String date, String time) {
    try {
      final dateTime = DateTime.parse('$date $time');
      final formatter = DateFormat('MMM dd, HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      return '$date $time';
    }
  }

  /// Get severity color (red for HIGH/CRITICAL, orange for MEDIUM, green for LOW)
  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
      default:
        return Colors.green;
    }
  }

  /// Get severity icon
  IconData _getSeverityIcon(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return Icons.priority_high;
      case 'HIGH':
        return Icons.warning;
      case 'MEDIUM':
        return Icons.info;
      case 'LOW':
      default:
        return Icons.check_circle;
    }
  }

  /// Show acknowledgment dialog for a seizure event
  void _showAcknowledgmentDialog(Map<String, dynamic> event) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context).acknowledgeSeizureEvent),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context).acknowledge}: ${event['seizure_type'] ?? AppLocalizations.of(context).seizureTypeUnknown}'),
                        Text('${AppLocalizations.of(context).predictionTime}: ${_formatEventDateTime(event['event_date'], event['event_time'])}'),
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).addDoctorNotes,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await _alertsService.acknowledgeSeizureEvent(
                eventId: event['id'],
                doctorNotes: notesController.text,
              );

              if (mounted) {
                Navigator.pop(context);
                if (result['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppLocalizations.of(context).eventAcknowledged)),
                  );
                  _loadSeizureEvents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${AppLocalizations.of(context).errorOccurred}: ${result['message']}')),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context).acknowledge),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_seizureEvents.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 48,
                color: Colors.green.shade300,
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).noSeizureEvents,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).seizureEventsWillAppear,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with refresh button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).recentSeizureEvents,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _loadSeizureEvents,
                  tooltip: AppLocalizations.of(context).refresh,
                ),
              ],
            ),
            Divider(height: 24),
            // List of seizure events
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _seizureEvents.length,
              separatorBuilder: (context, index) => SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = _seizureEvents[index];
                final severity = event['severity'] ?? 'MEDIUM';
                final isAcknowledged = event['is_acknowledged'] == 1;

                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seizure type and severity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['seizure_type'] ?? AppLocalizations.of(context).seizureTypeUnknown,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatEventDateTime(
                                    event['event_date'],
                                    event['event_time'],
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Severity badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(severity).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getSeverityIcon(severity),
                                  size: 14,
                                  color: _getSeverityColor(severity),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  severity,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getSeverityColor(severity),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Notification status indicators
                      Row(
                        children: [
                          // Medication notification status
                          if (event['medication_notification_sent'] == 1)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFC8E6C9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.medication, size: 12, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context).medicationAlertSent,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(width: 8),
                          // Appointment notification status
                          if (event['appointment_notification_sent'] == 1)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFE9FFF4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today, size: 12, color: Color(0xFF0B8F55)),
                                  SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context).appointmentAlertSent,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Acknowledgment status and action buttons
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
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context).acknowledged,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () => _showAcknowledgmentDialog(event),
                              icon: Icon(Icons.done, size: 16),
                              label: Text(AppLocalizations.of(context).acknowledge),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}



