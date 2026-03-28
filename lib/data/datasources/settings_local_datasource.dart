import 'package:hive_flutter/hive_flutter.dart';

class SettingsLocalDatasource {
  static const String boxName = 'settings';

  Box get _box => Hive.box(boxName);

  int getThemeMode() => _box.get('themeMode', defaultValue: 0) as int;

  Future<void> setThemeMode(int index) => _box.put('themeMode', index);
}
