import 'package:hive/hive.dart';

/// A single app the user has chosen to guard.
class ProtectedApp {
  const ProtectedApp({required this.packageName, required this.name});

  final String packageName;
  final String name;

  Map<String, dynamic> toMap() => {'package': packageName, 'name': name};

  factory ProtectedApp.fromMap(Map map) =>
      ProtectedApp(packageName: map['package'] as String, name: map['name'] as String);
}

/// Persists the protected-app list in Hive (box opened in main).
class ProtectedAppsStore {
  static const boxName = 'snapout';
  static const _key = 'protected_apps';

  Box? get _box => Hive.isBoxOpen(boxName) ? Hive.box(boxName) : null;

  List<ProtectedApp> getAll() {
    final raw = _box?.get(_key) as List?;
    if (raw == null) return const [];
    return raw.map((e) => ProtectedApp.fromMap(e as Map)).toList();
  }

  Future<void> setAll(List<ProtectedApp> apps) async =>
      _box?.put(_key, apps.map((a) => a.toMap()).toList());
}
