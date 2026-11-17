# NeuroGuard AI — Responsive Design Architecture & Wearable Strategy

**Project:** NeuroGuard AI  
**Scope:** Responsive Mobile & Smartwatch Architecture Specification  
**Date:** September 3, 2026  
**Status:** Validated  
**Architecture Module:** [`lib/responsive/responsive.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/responsive/responsive.dart)  
**Wearable Module:** [`lib/screens/wearable/smartwatch_dashboard.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/wearable/smartwatch_dashboard.dart)

---

## 1. CENTRALIZED RESPONSIVE DESIGN STRATEGY

NeuroGuard AI enforces a unified, breakpoint-driven responsive architecture across all Android mobile phone screens, tablets, and wearable viewports. The application avoids scattered hardcoded pixel values and utilizes fluid typography, adaptive padding, constraints-based card widths, and device-aware layout routing.

---

## 2. SCREEN BREAKPOINT CLASSIFICATION

The application classifies display viewports into 5 distinct screen categories via [`lib/responsive/responsive.dart`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/responsive/responsive.dart):

```
       < 320 dp           320 – 380 dp          380 – 600 dp         600 – 1024 dp        >= 1024 dp
┌───────────────────┬─────────────────────┬─────────────────────┬───────────────────┬───────────────────┐
│  SMALL WEARABLE   │    SMALL MOBILE     │   STANDARD MOBILE   │   LARGE / TABLET  │   DESKTOP / WIDE  │
│ (Wear OS Watches) │ (Small Androids)    │ (Standard Androids) │ (Tablets/Foldables│ (Desktop Displays)│
└───────────────────┴─────────────────────┴─────────────────────┴───────────────────┴───────────────────┘
```

| Category ID | Width Range | Target Hardware | Grid Columns | Padding | Spacing | Card Max Width |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: |
| **Small Wearable** | $< 320\,\text{dp}$ | Wear OS, Apple Watch, Round/Square Watch faces | 1 | $8\,\text{dp}$ | $6\,\text{dp}$ | $96\%$ screen width |
| **Small Mobile** | $320 - 380\,\text{dp}$ | Small Android Phones (e.g., Galaxy A03 Core, Pixel 4a) | 1 | $12\,\text{dp}$ | $10\,\text{dp}$ | $94\%$ screen width |
| **Standard Mobile** | $380 - 600\,\text{dp}$ | Standard Android Phones (e.g., Pixel 7/8, Galaxy S23/S24) | 2 | $16\,\text{dp}$ | $14\,\text{dp}$ | $440\,\text{dp}$ |
| **Large Mobile / Tablet** | $600 - 1024\,\text{dp}$ | Foldables, Tablets (e.g., Galaxy Tab, Pixel Tablet) | 3 | $32\,\text{dp}$ | $20\,\text{dp}$ | $560\,\text{dp}$ |
| **Desktop / Wide** | $\ge 1024\,\text{dp}$ | Wide Desktop Viewports | 4 | $60\,\text{dp}$ | $24\,\text{dp}$ | $700\,\text{dp}$ |

---

## 3. PHONE VS. SMARTWATCH FEATURE BOUNDARIES

The application clearly delineates feature scope between **Full Phone Application** and **Smartwatch Companion**:

```
                               ┌──────────────────────────────┐
                               │  NEUROGUARD AI SYSTEM SCOPE  │
                               └──────────────┬───────────────┘
                                              │
                    ┌─────────────────────────┴─────────────────────────┐
                    ▼                                                   ▼
┌───────────────────────────────────────┐               ┌───────────────────────────────────────┐
│     PHONE APPLICATION EXPERIENCE      │               │     SMARTWATCH COMPANION EXPERIENCE   │
│       (Full Clinical Suite)           │               │     (Critical Monitoring Companion)   │
├───────────────────────────────────────┤               ├───────────────────────────────────────┤
│ • Full EEG Upload & Processing        │               │ • Connection & Sensor Status          │
│ • Detailed Multi-Channel Waveform UI  │               │ • Current Patient Monitoring Status   │
│ • Interactive Seizure History Charts │               │ • Active Alert Warning State          │
│ • Comprehensive Medication Management │               │ • Protected Emergency SOS Action      │
│ • Doctor Patient Management Suite     │               │ • Quick Alert Notification Cards      │
│ • AI Chatbot & Clinical Consultations │               │ ❌ NO EEG File Uploads                │
│ • Detailed Research Metric Reports    │               │ ❌ NO Dense Forms or Complex Charts   │
└───────────────────────────────────────┘               └───────────────────────────────────────┘
```

---

## 4. HONEST SMARTWATCH FEATURE AUDIT & REALITY MATRIX

Per project requirements, smartwatch capabilities are transparently audited without fabricating unverified hardware functionality:

| Feature Category | Implementation Status | Scope / Technical Details |
| :--- | :---: | :--- |
| **Wearable UI Dashboard** | **IMPLEMENTED NOW** | Dedicated [`SmartwatchDashboard`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/wearable/smartwatch_dashboard.dart) for $< 320\,\text{dp}$ viewports. |
| **Bluetooth Sensor Status** | **IMPLEMENTED NOW** | Live connection indicator synced with [`PatientBluetoothScreen`](file:///c:/Users/DELL/Downloads/NeuroGuard%20AI/lib/screens/patient/bluetooth_screen.dart). |
| **Emergency SOS Trigger** | **IMPLEMENTED NOW** | 2-step confirmation dialog modal preventing accidental triggers on watch faces. |
| **Wear OS Native Package** | **UI PROTOTYPE ONLY** | Responsive Flutter layout supporting Wear OS aspect ratios; native Android Wearable OS background service target is a roadmap item. |
| **Watch PPG/EEG Sensor Direct**| **FUTURE ROADMAP** | Direct hardware sensor ingestion from smartwatch PPG/EEG hardware requires specialized medical sensor firmware integration. |

---

## 5. REUSABLE RESPONSIVE WIDGET HELPERS

1. **`Responsive.padding(context)`**: Dynamic margin and padding calculated from screen width category.
2. **`Responsive.cardWidth(context)`**: Constrained width container preventing oversized cards on large screens and squeezed cards on small screens.
3. **`AdaptiveLayoutBuilder`**: Layout Builder wrapper rendering distinct mobile vs watch widgets based on constraints.
4. **`KeyboardInsetScrollPadding`**: Inset padding (`MediaQuery.of(context).viewInsets.bottom`) attached to forms ensuring active fields remain visible above the software keyboard.
