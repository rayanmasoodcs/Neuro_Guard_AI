import 'package:flutter/material.dart';

/// Centralized ChangeNotifier that triggers UI rebuilds after CRUD operations.
/// Screens listen to this and re-fetch data from the backend when notified.
class GlobalRefreshNotifier extends ChangeNotifier {
  static final GlobalRefreshNotifier _instance = GlobalRefreshNotifier._();
  factory GlobalRefreshNotifier() => _instance;
  GlobalRefreshNotifier._();

  int _tick = 0;
  int get tick => _tick;

  /// Call this after ANY successful Create, Update, or Delete operation.
  /// All listening widgets will rebuild and re-fetch their data.
  void notifyDataChanged() {
    _tick++;
    notifyListeners();
  }
}

/// Mixin that subscribes a StatefulWidget to GlobalRefreshNotifier
/// and calls [onDataChanged] whenever a CRUD operation completes.
mixin AutoRefreshMixin<T extends StatefulWidget> on State<T> {
  bool _refreshPending = false;

  @override
  void initState() {
    super.initState();
    GlobalRefreshNotifier().addListener(_onRefreshTick);
  }

  @override
  void dispose() {
    GlobalRefreshNotifier().removeListener(_onRefreshTick);
    super.dispose();
  }

  void _onRefreshTick() {
    if (!mounted) return;
    _refreshPending = true;
    // trigger a build so widgets can decide when to consume the refresh
    if (mounted) setState(() {});
  }

  /// Override this in your State class to re-fetch data.
  void onDataChanged();

  /// Call this in your build method before building widgets.
  /// If a refresh was pending, schedules onDataChanged after the frame and returns true.
  bool consumeRefresh() {
    final pending = _refreshPending;
    if (pending) {
      _refreshPending = false;
      // schedule the actual refresh after the current frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) onDataChanged();
      });
    }
    return pending;
  }
}

/// Widget that calls [onRefresh] only when the global notifier advances its tick.
class DataRefreshListener extends StatefulWidget {
  final Widget child;
  final VoidCallback onRefresh;

  const DataRefreshListener({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<DataRefreshListener> createState() => _DataRefreshListenerState();
}

class _DataRefreshListenerState extends State<DataRefreshListener> {
  late int _lastTick;

  @override
  void initState() {
    super.initState();
    _lastTick = GlobalRefreshNotifier().tick;
    GlobalRefreshNotifier().addListener(_onGlobalTick);
  }

  @override
  void dispose() {
    GlobalRefreshNotifier().removeListener(_onGlobalTick);
    super.dispose();
  }

  void _onGlobalTick() {
    final current = GlobalRefreshNotifier().tick;
    if (current != _lastTick) {
      _lastTick = current;
      // schedule a post-frame callback to run the refresh outside build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onRefresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

