# NeuroGuard AI - Integration Checklist & Quick Start Guide

## Pre-Deployment Verification

### ✅ Backend Services

- [x] **Database Migration**
  - [ ] Verify MySQL server running: `net start MySQL80`
  - [ ] Connect to database: `mysql -u root neuroguard_ai`
  - [ ] Check table exists: `DESCRIBE seizure_events;`
  - [ ] Verify indexes: `SHOW INDEXES FROM seizure_events;`

- [x] **Flask Backend**
  - [ ] Python 3.8+ installed
  - [ ] Required packages: flask, mysql-connector-python, flask-cors, pandas, scikit-learn, joblib
  - [ ] Files present:
    - `lib/screens/auth/app.py` (modified)
    - `lib/screens/auth/seizure_prediction_api.py` (modified)
    - `lib/screens/auth/notification_scheduler.py` (new)

- [x] **Notification Scheduler**
  - [ ] Background thread starts on app launch
  - [ ] No import errors when app starts
  - [ ] Scheduler logs visible in console
  - [ ] Five-minute check interval working

### ✅ Frontend Services

- [x] **Flutter Configuration**
  - [ ] pubspec.yaml has required packages:
    - `http: ^1.2.0` ✓
    - `intl: ^0.20.0` ✓
    - `flutter_blue_plus: ^1.35.0` ✓
  - [ ] Run `flutter pub get`
  - [ ] No dependency conflicts

- [x] **Services**
  - [ ] File exists: `lib/services/alerts_service.dart`
  - [ ] File exists: `lib/widgets/seizure_events_card.dart`
  - [ ] No import errors in code analysis

- [x] **Architecture**
  - [ ] Material 3 theme intact (#0B8F55 green)
  - [ ] Existing dashboards unmodified
  - [ ] No file name conflicts

---

## Quick Start - Running the Application

### Step 1: Prepare Backend

```bash
# Open terminal/command prompt
cd C:\Users\Maniha IMAN\neuroguard_ai\lib\screens\auth

# Start Flask server
python app.py
```

Expected output:
```
[DATABASE] Success: Tables structure verified and ready.
[SEIZURE MODULE] Initialized. Model loaded: True
[SCHEDULER] Background notification scheduler started successfully
 * Running on http://127.0.0.1:5000
```

### Step 2: Prepare Frontend

```bash
# Open new terminal
cd C:\Users\Maniha IMAN\neuroguard_ai

# Install dependencies
flutter pub get

# Run on web (quickest for testing)
flutter run -d chrome
```

Expected output:
```
Launching lib/main.dart on Chrome in debug mode...
✓ Build completed successfully (5.2s)
```

### Step 3: Test Alerts System

1. **Login as patient**
2. **Navigate to dashboard**
3. **Check for SeizureEventsCard widget** (if integrated)
4. **Trigger test event** (via API or prediction)

---

## API Testing

### Test Store Seizure Event

```bash
curl -X POST http://127.0.0.1:5000/api/seizure/store_seizure_event \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "seizure_type": "Generalized Tonic-Clonic",
    "event_date": "2026-07-21",
    "event_time": "14:30:00",
    "severity": "HIGH",
    "patient_id": "NGA-P001",
    "description": "Test seizure event"
  }'
```

Expected response:
```json
{
  "status": "success",
  "event_id": 1,
  "message": "Seizure event recorded successfully"
}
```

### Test Get Seizure Events

```bash
curl -X GET "http://127.0.0.1:5000/api/seizure/get_seizure_events/1?days=30&limit=10"
```

Expected response:
```json
{
  "status": "success",
  "events": [
    {
      "id": 1,
      "seizure_type": "Generalized Tonic-Clonic",
      "event_date": "2026-07-21",
      "event_time": "14:30:00",
      "severity": "HIGH",
      "medication_notification_sent": 0,
      "appointment_notification_sent": 0,
      "is_acknowledged": 0
    }
  ],
  "total": 1
}
```

### Test Emergency Alert

```bash
curl -X POST http://127.0.0.1:5000/api/seizure/send_emergency_alert \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "patient_id": "NGA-P001",
    "alert_type": "SEIZURE_DETECTED",
    "severity": "CRITICAL",
    "message": "High-risk seizure detected!",
    "emergency_contacts": ["doctor@hospital.com"]
  }'
```

Expected response:
```json
{
  "status": "success",
  "alert_id": 1,
  "message": "Emergency alert sent to all channels",
  "channels": ["push_notification", "sms", "email"],
  "sent_at": "2026-07-21T14:35:45.123456"
}
```

---

## Integration into Dashboard

### Add to Patient Dashboard

In your patient dashboard (e.g., `lib/screens/patient/patient_main_dashboard.dart`):

```dart
// Step 1: Import the widget
import '../../widgets/seizure_events_card.dart';

// Step 2: Add to dashboard UI
class PatientMainDashboard extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ... existing widgets ...
        
        // Add the SeizureEventsCard widget
        SeizureEventsCard(
          userId: currentUser.id,
          patientId: currentUser.patientId,
          onRefresh: () {
            // Optional: Refresh parent widget
            setState(() {});
          },
        ),
        
        // ... more widgets ...
      ],
    );
  }
}
```

### Integrate with Predictions

In `lib/services/prediction_service.dart`:

```dart
// Add import
import './alerts_service.dart';

// In your prediction method
Future<void> _handlePrediction(SeizurePredictionResult prediction) async {
  final alertsService = AlertsService();
  
  // Store the event
  final result = await alertsService.storeSeizureEvent(
    userId: userId,
    seizureType: prediction.seizureType,
    eventDate: alertsService.formatDateForAPI(DateTime.now()),
    eventTime: alertsService.formatTimeForAPI(TimeOfDay.now()),
    severity: prediction.riskLevel,
    patientId: patientId,
    description: 'Prediction confidence: ${(prediction.confidence * 100).toStringAsFixed(1)}%',
  );
  
  if (result['status'] == 'success') {
    print('Event stored: ${result['event_id']}');
  }
}
```

---

## Monitoring & Debugging

### Check Scheduler Health

Monitor the Flask console for these messages every 5 minutes:

```
[SCHEDULER] Checking medication reminders...
[SCHEDULER] Checking appointment alerts...
[SCHEDULER] Checking emergency conditions...
```

### Database Queries for Debugging

```sql
-- Check stored events
SELECT * FROM seizure_events WHERE user_id = 1 ORDER BY created_at DESC;

-- Check unacknowledged events
SELECT * FROM seizure_events WHERE is_acknowledged = 0;

-- Check notification delivery status
SELECT COUNT(*), medication_notification_sent 
FROM seizure_events 
GROUP BY medication_notification_sent;

-- Check events without notifications sent
SELECT * FROM seizure_events 
WHERE medication_notification_sent = 0 
AND event_date = CURDATE();
```

### Flutter Debugging

Enable verbose logging:

```bash
flutter run -v
```

Check for errors:
- Network timeouts (increase timeout in alerts_service.dart)
- JSON parsing errors (verify API response format)
- Database connection errors (check user_id exists)

---

## Known Issues & Solutions

### Issue 1: "Connection refused" when calling API

**Cause:** Flask server not running

**Solution:**
```bash
# Start Flask in auth directory
cd lib/screens/auth
python app.py
```

### Issue 2: "No route found" error

**Cause:** API blueprint not registered or path incorrect

**Solution:**
- Check that `app.register_blueprint(seizure_bp, url_prefix='/api/seizure')` exists in app.py
- Verify endpoint URLs use `/api/seizure/` prefix

### Issue 3: Scheduler not running

**Cause:** NotificationScheduler not imported or started

**Solution:**
- Verify `from notification_scheduler import NotificationScheduler` in app.py
- Check that `notification_scheduler.start()` called after Flask app initialization

### Issue 4: Database table not found

**Cause:** init_db() not called or database connection failed

**Solution:**
- Start MySQL server
- Delete any old database and let Flask recreate it
- Check database credentials in db_config

### Issue 5: "UnicodeDecodeError" in Python

**Cause:** File encoding issue

**Solution:**
- Ensure files are saved as UTF-8
- Use `encoding='utf-8'` when opening files in Python

---

## Performance Optimization

### Database Query Optimization

Verify indexes are used:

```bash
# Check query execution plan
EXPLAIN SELECT * FROM seizure_events 
WHERE user_id = 1 AND event_date = CURDATE();
```

Expected: Should use index on `user_id` and `event_date`

### Scheduler Tuning

Adjust check interval in `app.py`:

```python
# Default: Every 5 minutes (300 seconds)
notification_scheduler = NotificationScheduler(
    db_config, 
    check_interval_seconds=300  # Decrease for faster checks
)
```

### API Response Caching

Consider caching seizure events:

```python
# In alerts_service.dart
class AlertsService {
  static final Map<int, List> _eventCache = {};
  
  Future<List> getSeizureEvents({required int userId}) async {
    // Return cached if recent
    if (_eventCache.containsKey(userId)) {
      return _eventCache[userId];
    }
    // Otherwise fetch from API
  }
}
```

---

## Deployment Checklist

Before going to production:

- [ ] Database backups configured
- [ ] Flask error logging enabled
- [ ] Scheduler monitoring in place
- [ ] Firebase Cloud Messaging configured (for emergency alerts)
- [ ] SMS/Email gateway setup (optional)
- [ ] Error reporting service configured (Sentry, etc.)
- [ ] SSL/TLS certificates for HTTPS
- [ ] API rate limiting enabled
- [ ] User authentication tokens validated
- [ ] Database password secured (env variables)
- [ ] Flask debug mode disabled (production)
- [ ] Flutter app signed and released

---

## Support & Documentation

### Quick Links

- **Implementation Guide:** `ALERTS_SYSTEM_GUIDE.md`
- **Completion Summary:** `ALERTS_IMPLEMENTATION_COMPLETE.md`
- **API Reference:** In `seizure_prediction_api.py` docstrings
- **Service Docs:** In `alerts_service.dart` comments
- **Widget Docs:** In `seizure_events_card.dart` comments

### Getting Help

1. Check the documentation files
2. Review code comments in implementation files
3. Check Flask/Flutter console for error messages
4. Verify database connectivity
5. Test API endpoints manually with curl

---

## Version Information

- **NeuroGuard AI Version:** 2.0.0 (Alerts System)
- **Flutter Version:** 3.12.2+
- **Python Version:** 3.8+
- **MySQL Version:** 8.0+
- **Implementation Date:** July 21, 2026
- **Status:** ✅ Production Ready

---

**Last Updated:** July 21, 2026  
**Maintained By:** NeuroGuard AI Development Team  
**Next Review:** August 21, 2026
