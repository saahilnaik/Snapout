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

  /// Stream of package names detected coming to the foreground.
  Stream<String> get detections =>
      _events.receiveBroadcastStream().map((e) => e as String);

  // --- Launch routing (native -> Dart) ---

  /// Warm path: native pushes a route while Dart is alive.
  void onLaunchRoute(void Function(String route) handler) {
    _method.setMethodCallHandler((call) async {
      if (call.method == 'onLaunchRoute' && call.arguments is String) {
        handler(call.arguments as String);
      }
      return null;
    });
  }

  /// Cold path: pull any route the service stashed before Dart was ready.
  Future<String?> consumeLaunchRoute() =>
      _method.invokeMethod<String>('consumeLaunchRoute');
}
