# NeuroGuard AI — Responsive UI Audit Report

**Project:** NeuroGuard AI  
**Scope:** Responsive Mobile & Smartwatch Experience Audit  
**Date:** September 3, 2026  
**Status:** Completed  

---

## 1. AUDIT SUMMARY & METHODOLOGY

A comprehensive frontend UI audit was performed across all patient, doctor, authentication, EEG, and widget components in the NeuroGuard AI Flutter codebase. The audit inspected layout geometry, pixel constraints, text scale resilience, keyboard obstruction safety, and wearable screen adaptation.

---

## 2. DETECTED RESPONSIVE UI ISSUES BY SEVERITY

### A. CRITICAL ISSUES (RenderFlex Overflows & Textfield Clipping)

| Component / Screen | File Location | Problem Description | Root Cause | Impact |
| :--- | :--- | :--- | :--- | :--- |
| **Login Screen** | [`lib/screens/auth/login_screen.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/auth/login_screen.dart) | `TextField` wrapped in fixed `SizedBox(height: textFieldHeight)` causing vertical text clipping and label overflow when font scale increases or error text is displayed. | Hardcoded fixed height constraint on `SizedBox` wrapping `TextField`. | Text labels cut off on small mobile devices ($320-360\,\text{dp}$). |
| **Signup Screen** | [`lib/screens/auth/signup_screen.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/auth/signup_screen.dart) | Bottom form buttons obscured or pushed off-screen when software keyboard opens on small Android devices ($320-360\,\text{dp}$). | Insufficient `SingleChildScrollView` bottom inset padding relative to `MediaQuery.of(context).viewInsets.bottom`. | User unable to tap "Create Account" when typing. |
| **Realtime Sensor Screen** | [`lib/screens/patient/realtime_sensor_data_screen.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/realtime_sensor_data_screen.dart) | Fixed height containers for EEG charts (`height: 250`) causing `RenderFlex overflow` on small screens or portrait orientation. | Fixed pixel height without `Flexible` or `LayoutBuilder` wrapper. | Yellow-and-black overflow stripe on small devices. |

---

### B. HIGH ISSUES (Smartwatch & Small Mobile Adaptations)

| Component / Screen | File Location | Problem Description | Root Cause | Impact |
| :--- | :--- | :--- | :--- | :--- |
| **Watch Breakpoint Threshold** | [`lib/responsive/responsive.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/responsive/responsive.dart) | `isWatch` threshold set to `< 280dp`. Wear OS and Apple Watch viewports range from $280\,\text{dp}$ to $320\,\text{dp}$. | Narrow breakpoint definition. | Larger smartwatches ($280-320\,\text{dp}$) rendered dense phone UI instead of watch layout. |
| **Patient Dashboard** | [`lib/screens/patient/patient_dashboard.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/patient_dashboard.dart) | Action cards rendered in 2-column grid without single-column fallback for small phones ($< 360\,\text{dp}$). | Fixed grid column count without adaptive breakpoint scaling. | Squeezed text and clipped icon buttons on small phones. |
| **Doctor Upload EEG Screen** | [`lib/screens/doctor/upload_eeg_screen.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/doctor/upload_eeg_screen.dart) | Large file drop zone and parameter fields overlap when device keyboard opens. | Hardcoded vertical padding and non-scrollable header area. | Form input obstruction on small devices. |

---

### C. MEDIUM ISSUES (Layout & Card Constraints)

| Component / Screen | File Location | Problem Description | Root Cause | Impact |
| :--- | :--- | :--- | :--- | :--- |
| **Seizure Prediction Card** | [`lib/widgets/seizure_prediction_card.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/widgets/seizure_prediction_card.dart) | Hardcoded inner row spacing causing timestamp and risk badge to wrap awkwardly. | Missing `FittedBox` / `Flexible` wrapping on title row elements. | Unaligned text badges on narrow screens. |
| **Bluetooth Device Card** | [`lib/widgets/bluetooth_device_card.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/widgets/bluetooth_device_card.dart) | Device RSSI and MAC address text overflowing card boundaries. | `Text` widgets lacking `TextOverflow.ellipsis`. | Text spilling outside card borders. |

---

### D. POLISH ISSUES (Typography Scaling & Safe Area Insets)

| Component / Screen | File Location | Problem Description | Root Cause | Impact |
| :--- | :--- | :--- | :--- | :--- |
| **Drawer Navigation** | [`lib/screens/patient/patient_main_dashboard.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/patient_main_dashboard.dart) | Drawer header text overlaps system notch on cutout devices. | `UserAccountsDrawerHeader` missing top padding buffer for `SafeArea`. | Minor visual overlap on notched phones. |
| **Dialog Modals** | Various screens | Alert dialogs exceed screen height when font scaling is set to $1.3\times$. | Missing `SingleChildScrollView` inside `AlertDialog.content`. | Dialog buttons pushed off-screen. |

---

## 3. AUDITED SCREENS & COMPONENT MATRIX

| Screen / Component | Audited | Responsiveness Status | Key Action Required |
| :--- | :---: | :---: | :--- |
| `LoginScreen` | ✅ YES | Needs Fix | Remove fixed `SizedBox` around `TextField`, enhance watch layout |
| `SignupScreen` | ✅ YES | Needs Fix | Add keyboard inset scroll padding, dynamic textfield bounds |
| `PatientDashboard` | ✅ YES | Needs Fix | Adaptive grid columns ($1$ on small, $2$ on std, $3$ on large), watch routing |
| `PatientMainDashboard` | ✅ YES | Needs Fix | Responsive navigation bar, safe drawer header |
| `DoctorDashboard` | ✅ YES | Needs Fix | Adaptive grid cards, responsive patient summary table |
| `UploadEEGScreen` | ✅ YES | Needs Fix | Scrollable upload container, responsive drop zone |
| `RealtimeSensorDataScreen` | ✅ YES | Needs Fix | Flexible chart container, responsive status badges |
| `SeizurePredictionCard` | ✅ YES | Needs Fix | `Flexible` text wrapping, responsive padding |
| `SeizureEventsCard` | ✅ YES | Needs Fix | Scrollable timeline, adaptive chip sizes |
| `BluetoothDeviceCard` | ✅ YES | Needs Fix | `TextOverflow.ellipsis`, adaptive action button |
| `SmartwatchDashboard` | 🆕 NEW | To Implement | Dedicated Wearable Screen for device status, alert, and Emergency SOS |

---

## 4. SEVERITY-BASED ACTION PLAN

1. **Phase 1 (Critical & High):** Upgrade `Responsive` helper class in `lib/responsive/responsive.dart` with 5 clear screen categories ($< 320$, $320-380$, $380-600$, $600-1024$, $> 1024$).
2. **Phase 2 (Wearable Architecture):** Build `lib/screens/wearable/smartwatch_dashboard.dart` to provide a dedicated smartwatch UI for status monitoring, active alerts, and Emergency SOS.
3. **Phase 3 (Screen Adaptation):** Refactor `LoginScreen`, `SignupScreen`, `PatientHomeScreen`, `PatientMainDashboard`, `DoctorDashboard`, `UploadEEGScreen`, and core cards to eliminate fixed height `SizedBox` textfields and RenderFlex overflows.
4. **Phase 4 (Testing & Verification):** Verify via `dart analyze` and update `RESPONSIVE_TEST_REPORT.md`.
