import 'package:flutter/material.dart';

/// NeuroGuard AI Centralized Responsive Design Architecture & Helpers.
/// Provides standardized screen breakpoints, adaptive padding, fluid typography,
/// and layout helpers across Android phones and Smartwatch devices.
class Responsive {
  // ---------------------------------------------------------------------------
  // SCREEN CLASSIFICATION BREAKPOINTS
  // ---------------------------------------------------------------------------

  /// Smartwatch / Wearable Screen (< 320 dp width)
  static bool isWatch(BuildContext context) =>
      MediaQuery.of(context).size.width < 320;

  /// Small Android Phone (320 dp <= width < 380 dp)
  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.of(context).size.width >= 320 &&
      MediaQuery.of(context).size.width < 380;

  /// Standard Android Phone (380 dp <= width < 600 dp)
  static bool isStandardMobile(BuildContext context) =>
      MediaQuery.of(context).size.width >= 380 &&
      MediaQuery.of(context).size.width < 600;

  /// Mobile device helper (Watch or Phone < 600 dp)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Large Mobile or Tablet (600 dp <= width < 1024 dp)
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  /// Desktop or Ultra-Wide Display (>= 1024 dp width)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // ---------------------------------------------------------------------------
  // DIMENSION & ORIENTATION HELPERS
  // ---------------------------------------------------------------------------

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  // ---------------------------------------------------------------------------
  // ADAPTIVE SPACING & PADDING HELPERS
  // ---------------------------------------------------------------------------

  /// Adaptive container outer padding
  static double padding(BuildContext context) {
    if (isWatch(context)) return 8.0;
    if (isSmallMobile(context)) return 12.0;
    if (isStandardMobile(context)) return 16.0;
    if (isTablet(context)) return 32.0;
    return 60.0;
  }

  /// Adaptive vertical spacing between card widgets
  static double spacing(BuildContext context) {
    if (isWatch(context)) return 6.0;
    if (isSmallMobile(context)) return 10.0;
    if (isStandardMobile(context)) return 14.0;
    if (isTablet(context)) return 20.0;
    return 24.0;
  }

  /// Adaptive card max width for centered content layouts
  static double cardWidth(BuildContext context) {
    final w = width(context);
    if (isWatch(context)) return w * 0.96;
    if (isSmallMobile(context)) return w * 0.94;
    if (isStandardMobile(context)) return 440.0;
    if (isTablet(context)) return 560.0;
    return 700.0;
  }

  /// Adaptive grid column count
  static int gridColumns(BuildContext context) {
    if (isWatch(context) || isSmallMobile(context)) return 1;
    if (isStandardMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  // ---------------------------------------------------------------------------
  // ADAPTIVE TYPOGRAPHY & ASSET SIZES
  // ---------------------------------------------------------------------------

  static double logoSize(BuildContext context) {
    if (isWatch(context)) return 36.0;
    if (isSmallMobile(context)) return 64.0;
    if (isStandardMobile(context)) return 80.0;
    if (isTablet(context)) return 110.0;
    return 130.0;
  }

  static double titleSize(BuildContext context) {
    if (isWatch(context)) return 13.0;
    if (isSmallMobile(context)) return 20.0;
    if (isStandardMobile(context)) return 24.0;
    if (isTablet(context)) return 32.0;
    return 36.0;
  }

  static double subtitleSize(BuildContext context) {
    if (isWatch(context)) return 9.0;
    if (isSmallMobile(context)) return 12.0;
    if (isStandardMobile(context)) return 14.0;
    if (isTablet(context)) return 16.0;
    return 18.0;
  }

  /// Safe text scale multiplier bound to prevent layout clipping
  static double textScaleFactor(BuildContext context) {
    final factor = MediaQuery.of(context).textScaler.scale(1.0);
    if (isWatch(context)) return factor.clamp(0.8, 1.1);
    return factor.clamp(0.85, 1.3);
  }

  // ---------------------------------------------------------------------------
  // ADAPTIVE INPUT & BUTTON HEIGHTS
  // ---------------------------------------------------------------------------

  static double buttonHeight(BuildContext context) {
    if (isWatch(context)) return 34.0;
    if (isSmallMobile(context)) return 44.0;
    if (isStandardMobile(context)) return 50.0;
    if (isTablet(context)) return 54.0;
    return 58.0;
  }

  static double textFieldHeight(BuildContext context) {
    if (isWatch(context)) return 36.0;
    if (isSmallMobile(context)) return 48.0;
    if (isStandardMobile(context)) return 52.0;
    return 56.0;
  }
}

/// Reusable Adaptive Layout Builder Widget.
/// Renders separate watch vs mobile layouts depending on screen constraints.
class AdaptiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? watch;
  final Widget? tablet;

  const AdaptiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.watch,
    this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 320 && watch != null) {
          return watch!;
        }
        if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
