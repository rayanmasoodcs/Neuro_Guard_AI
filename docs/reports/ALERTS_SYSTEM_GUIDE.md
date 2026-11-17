# NeuroGuard AI - Alerts System Implementation Guide

## Overview

The comprehensive alerts system enables:
1. **Seizure Event Tracking** - Store seizure occurrences with date/time for alert scheduling
2. **Automated Notifications** - Background scheduler matches seizure dates with medication/appointment times
3. **Emergency Alerts** - Immediate high-priority notifications even when app is closed
4. **Medical Compliance** - Full audit trail of alerts and acknowledgments

---

## Architecture

### Backend Components

#### 1. MySQL Database Tables

**New Table: `seizure_events`**
```sql
CREATE TABLE seizure_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    patient_id VARCHAR(255),
    
    -- Seizure occurrence details
    seizure_type VARCHAR(255),
    event_date DATE NOT NULL,
    event_time TIME NOT NULL,
    severity VARCHAR(50),
    description TEXT,
    
    -- Associated medication/appointment tracking
    associated_medication_id INT,
    associated_reminder_id INT,
    related_eeg_upload_id INT,
    
    -- Notification tracking
    medication_notification_sent TINYINT(1) DEFAULT 0,
    medication_notification_time DATETIME,
    appointment_notification_sent TINYINT(1) DEFAULT 0,
    appointment_notification_time DATETIME,
    
    -- Alert status
    is_acknowledged TINYINT(1) DEFAULT 0,
    acknowledged_at TIMESTAMP NULL,
    doctor_notes TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_event_date (event_date),
    INDEX idx_event_time (event_time),
    INDEX idx_notification_sent (medication_notification_sent),
    INDEX idx_patient_id (patient_id)
);
```

#### 2. Flask API Endpoints

All endpoints are registered under `/api/seizure/` blueprint:

**POST /api/seizure/store_seizure_event**
- Store a seizure event occurrence
- Request: `{ user_id, seizure_type, event_date, event_time, severity, patientId, description }`
- Response: `{ status, event_id }`

**GET /api/seizure/get_seizure_events/<user_id>**
- Retrieve seizure events for a user
- Query params: `days` (default 30), `limit` (default 50)
- Response: `{ status, events: [], total }`

**GET /api/seizure/get_upcoming_alerts/<user_id>**
- Get alerts for upcoming medication/appointment times based on seizure dates
- Query params: `hours_ahead` (default 24)
- Response: `{ status, upcoming_alerts: [], total }`

**POST /api/seizure/trigger_notification**
- Trigger notification for a seizure event
- Request: `{ event_id, user_id, notification_type, title, message, send_emergency_alert }`
- Response: `{ status, sent_at }`

**POST /api/seizure/send_emergency_alert**
- Send emergency alert (CRITICAL priority)
- Request: `{ user_id, patient_id, alert_type, severity, message, emergency_contacts }`
- Response: `{ status, alert_id, channels }`

**POST /api/seizure/acknowledge_seizure_event/<event_id>**
- Acknowledge a seizure event with doctor notes
- Request: `{ acknowledged, doctor_notes, medication_adjustment }`
- Response: `{ status, message }`

#### 3. Background Notification Scheduler

**File:** `lib/screens/auth/notification_scheduler.py`

Key methods:
- `start()` - Start background scheduler thread
- `stop()` - Stop scheduler gracefully
- `_check_medication_reminders()` - Match seizure dates with medication times
- `_check_appointment_alerts()` - Match seizure dates with appointment times
- `_check_emergency_conditions()` - Monitor for critical situations

Features:
- Runs every 5 minutes (configurable)
- Matches seizure event dates with reminder times
- Checks for multiple seizures in short timeframe
- Monitors CRITICAL severity alerts
- Thread-safe and error-resilient

---

### Frontend Components

#### 1. Flutter Services

**File:** `lib/services/alerts_service.dart`

Singleton service with methods:
```dart
// Store seizure event
storeSeizureEvent({
  required int userId,
  required String seizureType,
  required String eventDate,
  required String eventTime,
  required String severity,
  String? patientId,
  String? description,
})

// Get seizure events
getSeizureEvents({
  required int userId,
  int days = 30,
  int limit = 50,
})

// Get upcoming alerts
getUpcomingAlerts({
  required int userId,
  int hoursAhead = 24,
})

// Acknowledge event
acknowledgeSeizureEvent({
  required int eventId,
  required String doctorNotes,
  String? medicationAdjustment,
})

// Send emergency alert
sendEmergencyAlert({
  required int userId,
  required String patientId,
  required String alertType,
  required String message,
  required String severity,
  List<String>? emergencyContacts,
})

// Trigger notification
triggerNotification({
  required int eventId,
  required int userId,
  required String notificationType,
  required String title,
  required String message,
  bool sendEmergencyAlert = false,
})
```

#### 2. Flutter Widgets

**File:** `lib/widgets/seizure_events_card.dart`

Widget displays:
- Recent seizure events with date/time
- Severity level with color coding (red/orange/green)
- Medication notification status (pill icon)
- Appointment notification status (calendar icon)
- Acknowledgment status (checkmark)
- Action buttons to acknowledge events and add doctor notes

Features:
- Pull-to-refresh functionality
- Empty state messaging
- Doctor note input dialog
- Responsive design (mobile/tablet)
- Material 3 design with green theme (#0B8F55)

---

## Integration Steps

### Step 1: Backend Setup

1. Flask app already imports and starts scheduler:
```python
# app.py (already added)
from notification_scheduler import NotificationScheduler

notification_scheduler = NotificationScheduler(db_config, check_interval_seconds=300)
notification_scheduler.start()
```

2. MySQL table created automatically in `init_db()`:
```python
# app.py init_db() function
CREATE TABLE IF NOT EXISTS seizure_events (...)
```

3. All API endpoints already registered in `seizure_prediction_api.py`

### Step 2: Flutter Integration

1. Import AlertsService in your screens:
```dart
import '../../services/alerts_service.dart';
```

2. Add SeizureEventsCard widget to patient dashboard:
```dart
import '../../widgets/seizure_events_card.dart';

// In PredictionAndSensorDashboard or PatientDashboard
SeizureEventsCard(
  userId: userId,
  patientId: patientId,
  onRefresh: () {
    // Refresh parent widget if needed
  },
)
```

3. Store seizure event when detected (in PredictionService):
```dart
final AlertsService _alertsService = AlertsService();

// After seizure prediction
if (prediction.confidence > 0.6) {
  // Store the event
  await _alertsService.storeSeizureEvent(
    userId: userId,
    seizureType: prediction.seizureType,
    eventDate: _alertsService.formatDateForAPI(DateTime.now()),
    eventTime: _alertsService.formatTimeForAPI(TimeOfDay.now()),
    severity: prediction.riskLevel,
    patientId: patientId,
    description: 'AI prediction: ${prediction.seizureType}',
  );
  
  // Send emergency alert if critical
  if (prediction.confidence > 0.9) {
    await _alertsService.sendEmergencyAlert(
      userId: userId,
      patientId: patientId,
      alertType: 'SEIZURE_DETECTED',
      message: 'High-risk seizure detected!',
      severity: 'CRITICAL',
    );
  }
}
```

### Step 3: Local Notifications (Optional - Production)

For background notifications when app is closed, integrate with:

1. **Android:**
   - Add `firebase_messaging` package
   - Implement FCM token refresh
   - Handle foreground/background messages

2. **iOS:**
   - Configure APNs certificates
   - Request user notification permissions
   - Handle notification responses

3. **Configuration:**
```yaml
# pubspec.yaml
firebase_messaging: ^14.0.0
flutter_local_notifications: ^16.0.0
```

---

## Usage Examples

### Example 1: Store Seizure Event from Prediction

```dart
void _handleSeizurePrediction(SeizurePredictionResult prediction) async {
  final alertsService = AlertsService();
  
  // Store the event
  final result = await alertsService.storeSeizureEvent(
    userId: currentUser.id,
    seizureType: prediction.seizureType,
    eventDate: alertsService.formatDateForAPI(DateTime.now()),
    eventTime: alertsService.formatTimeForAPI(TimeOfDay.now()),
    severity: prediction.riskLevel,
    patientId: currentUser.patientId,
    description: 'Prediction confidence: ${(prediction.confidence * 100).toStringAsFixed(1)}%',
  );
  
  if (result['status'] == 'success') {
    print('Event stored with ID: ${result['event_id']}');
    
    // Show confirmation to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seizure event recorded')),
    );
  }
}
```

### Example 2: Display Upcoming Alerts

```dart
void _checkUpcomingAlerts() async {
  final alertsService = AlertsService();
  
  // Get upcoming alerts for next 24 hours
  final upcomingAlerts = await alertsService.getUpcomingAlerts(
    userId: currentUser.id,
    hoursAhead: 24,
  );
  
  // Display in UI
  for (var alert in upcomingAlerts) {
    print('Upcoming alert: ${alert['reminder_title']} at ${alert['reminder_time']}');
  }
}
```

### Example 3: Send Emergency Alert

```dart
void _sendEmergencyAlert() async {
  final alertsService = AlertsService();
  
  final result = await alertsService.sendEmergencyAlert(
    userId: currentUser.id,
    patientId: currentUser.patientId,
    alertType: 'SEIZURE_DETECTED',
    message: '⚠️ CRITICAL: High-risk seizure detected! Emergency services alerted.',
    severity: 'CRITICAL',
    emergencyContacts: [
      'doctor@hospital.com',
      '9876543210',
    ],
  );
  
  if (result['status'] == 'success') {
    print('Emergency alert sent (ID: ${result['alert_id']})');
    print('Channels: ${result['channels']}');
  }
}
```

### Example 4: Acknowledge Seizure Event

```dart
void _acknowledgeEvent(int eventId) async {
  final alertsService = AlertsService();
  
  final result = await alertsService.acknowledgeSeizureEvent(
    eventId: eventId,
    doctorNotes: 'Patient monitored for 30 minutes. Stable condition.',
    medicationAdjustment: 'Increased Levetiracetam to 1000mg daily',
  );
  
  if (result['status'] == 'success') {
    // Refresh UI
    setState(() {});
  }
}
```

---

## Data Flow Diagram

```
Seizure Prediction
    ↓
[PredictionService] → alerts_service.storeSeizureEvent()
    ↓
    └─→ POST /api/seizure/store_seizure_event
            ↓
        MySQL seizure_events table
            ↓
[Scheduler Thread] runs every 5 minutes
    ├─→ _check_medication_reminders()
    │   └─→ JOIN seizure_events with reminders
    │       └─→ MATCH event_date with reminder_date
    │           └─→ IF MATCH: _send_notification()
    │
    ├─→ _check_appointment_alerts()
    │   └─→ JOIN seizure_events with reminders
    │       └─→ MATCH event_date with appointment_date
    │           └─→ IF MATCH: _send_notification()
    │
    └─→ _check_emergency_conditions()
        └─→ DETECT: Multiple seizures in 2 hours
            └─→ SEVERITY = CRITICAL
                └─→ _send_emergency_notification()

[Flutter Dashboard]
    ├─→ SeizureEventsCard widget
    │   └─→ Displays events with status badges
    │
    └─→ AlertsService
        ├─→ getSeizureEvents() → Display in card
        ├─→ getUpcomingAlerts() → Show next medication times
        └─→ acknowledgeSeizureEvent() → Doctor confirmation
```

---

## Configuration

### Scheduler Timing

Edit in `app.py`:
```python
# Check for alerts every 5 minutes (300 seconds)
notification_scheduler = NotificationScheduler(
    db_config, 
    check_interval_seconds=300  # Adjust as needed
)
```

### Notification Thresholds

Edit in `notification_scheduler.py`:

```python
# Multiple seizures threshold (in _check_emergency_conditions)
HAVING seizure_count >= 2 AND max_severity IN ('HIGH', 'CRITICAL')

# Time window for emergency check
TIMESTAMPDIFF(MINUTE, CONCAT(event_date, ' ', event_time), NOW()) < 120
```

### Medication Reminder Matching

Edit in `notification_scheduler.py`:

```python
# Default: Check within 5 minute window of medication time
TIME(NOW()) >= TIME_SUB(r.reminder_time, INTERVAL 5 MINUTE)
TIME(NOW()) <= TIME_ADD(r.reminder_time, INTERVAL 5 MINUTE)
```

---

## Production Deployment Checklist

- [ ] Database: Verify `seizure_events` table exists with proper indexes
- [ ] Backend: Scheduler running without errors in logs
- [ ] Flutter: AlertsService imported and working
- [ ] UI: SeizureEventsCard displaying events correctly
- [ ] Notifications: Test with Flutter app
- [ ] FCM: Configure Firebase Cloud Messaging (optional)
- [ ] Emergency Contacts: Set up SMS/Email integration (optional)
- [ ] Monitoring: Check scheduler logs for failures
- [ ] Testing: Run with live seizure prediction events

---

## Code Quality Standards

### Comments
- All functions documented with docstrings
- Complex logic explained inline
- Error handling with descriptive messages

### Error Handling
- Try-catch blocks on all network calls
- Graceful fallbacks for missing data
- User-friendly error messages

### Architecture
- Follows existing app patterns
- Singleton pattern for services
- Material 3 design consistency
- Responsive layouts

### Database
- Proper indexes on frequently queried columns
- Foreign key constraints for referential integrity
- Cascading deletes for data cleanup
- Timestamps for audit trails

---

## Future Enhancements

1. **Push Notifications**
   - Firebase Cloud Messaging integration
   - SMS alerts for critical events
   - Email notifications to doctors

2. **Geofencing**
   - Alert when patient leaves safe zone
   - Location-based emergency response

3. **Predictive Alerts**
   - ML model to predict seizure likelihood
   - Alert before seizure occurs
   - Preventive medication triggers

4. **Doctor Dashboard**
   - Real-time alert feed
   - Patient seizure trends
   - Medication effectiveness tracking

5. **Wearable Integration**
   - Smartwatch notifications
   - Direct wearable emergency buttons
   - Continuous monitoring display

---

## Troubleshooting

### Scheduler Not Triggering Notifications

**Issue:** Scheduler runs but notifications not sent
**Solution:**
1. Check logs for scheduler errors
2. Verify MySQL connection in scheduler
3. Confirm seizure_events table has data
4. Check reminder dates match seizure dates

### Alerts Not Appearing in UI

**Issue:** SeizureEventsCard shows "No events"
**Solution:**
1. Verify storeSeizureEvent() call succeeded
2. Check database for entries: `SELECT * FROM seizure_events WHERE user_id = ?`
3. Verify userId parameter is correct
4. Check network requests in Flutter DevTools

### Emergency Alerts Not Sending

**Issue:** Emergency alert endpoint returns error
**Solution:**
1. Verify all required fields provided (user_id, alert_type, message, severity)
2. Check user_id exists in users table
3. Review Firebase/SMS service configuration
4. Check error log: `[ERROR] Failed to send emergency alert`

---

## Related Documentation

- [PredictionService Integration](./PREDICTION_SERVICE_GUIDE.md)
- [Notification Settings](./NOTIFICATION_SETTINGS.md)
- [Database Schema](./DATABASE_SCHEMA.md)
- [Flutter Best Practices](./FLUTTER_BEST_PRACTICES.md)

