import 'package:hive/hive.dart';

/// Persists the Pro entitlement and the chosen accent theme.
class EntitlementStore {
  static const boxName = 'snapout';
  static const _keyPro = 'is_pro';
  static const _keyAccent = 'accent';

  Box? get _box => Hive.isBoxOpen(boxName) ? Hive.box(boxName) : null;

  bool get isPro => (_box?.get(_keyPro, defaultValue: false) as bool?) ?? false;

  Future<void> setPro(bool value) async => _box?.put(_keyPro, value);

  /// Accent preset key (e.g. 'lime'). Default 'lime'.
  String get accentKey => (_box?.get(_keyAccent, defaultValue: 'lime') as String?) ?? 'lime';

  Future<void> setAccentKey(String key) async => _box?.put(_keyAccent, key);
}
