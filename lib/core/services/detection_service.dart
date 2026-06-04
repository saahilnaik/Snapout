import 'package:flutter/services.dart';

/// Dart side of the native detection bridge. Wraps the MethodChannel (control +
/// permissions) and EventChannel (foreground-app detections) exposed by the
/// Android [DetectionService] / MainActivity.
class DetectionService {
  DetectionService();

  static const MethodChannel _method = MethodChannel('snapout/detection');
  static const EventChannel _events = EventChannel('snapout/events');

  // --- Permissions ---

  Future<bool> hasUsageAccess() async =>
      await _method.invokeMethod<bool>('hasUsageAccess') ?? false;

  Future<void> requestUsageAccess() => _method.invokeMethod('requestUsageAccess');

  Future<bool> hasOverlayPermission() async =>
      await _method.invokeMethod<bool>('hasOverlayPermission') ?? false;

  Future<void> requestOverlayPermission() =>
      _method.invokeMethod('requestOverlayPermission');

  // --- Service control ---

  Future<bool> startService(List<String> targets) async =>
      await _method.invokeMethod<bool>('startService', {'targets': targets}) ?? false;

  Future<void> stopService() => _method.invokeMethod('stopService');

  Future<bool> isServiceRunning() async =>
      await _method.invokeMethod<bool>('isServiceRunning') ?? false;

  /// Skip: leave the protected app, drop the user on their launcher.
  Future<void> goHome() => _method.invokeMethod('goHome');

  /// Open anyway: send SnapOut behind, revealing the protected app.
  Future<void> moveToBack() => _method.invokeMethod('moveToBack');

  /// Stream of package names detected coming to the foreground.
  Stream<String> get detections =>
      _events.receiveBroadcastStream().map((e) => e as String);

  // --- Launch routing (native -> Dart) ---

  void Function(String)? _onLaunchRouteHandler;
  void Function()? _onLauncherLaunchHandler;

  /// Warm path: native pushes a route while Dart is alive.
  void onLaunchRoute(void Function(String route) handler) {
    _onLaunchRouteHandler = handler;
    _setupMethodCallHandler();
  }

  /// Called when the app is resumed/opened from the launcher without a route.
  void onLauncherLaunch(void Function() handler) {
    _onLauncherLaunchHandler = handler;
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    _method.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onLaunchRoute':
          if (call.arguments is String) {
            _onLaunchRouteHandler?.call(call.arguments as String);
          }
          break;
        case 'onLauncherLaunch':
          _onLauncherLaunchHandler?.call();
          break;
      }
      return null;
    });
  }

  /// Cold path: pull any route the service stashed before Dart was ready.
  Future<String?> consumeLaunchRoute() =>
      _method.invokeMethod<String>('consumeLaunchRoute');
}
