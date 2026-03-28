import 'package:unigpa/data/datasources/settings_local_datasource.dart';
import 'package:unigpa/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._datasource);

  final SettingsLocalDatasource _datasource;

  @override
  int getThemeMode() => _datasource.getThemeMode();

  @override
  Future<void> setThemeMode(int index) => _datasource.setThemeMode(index);
}
