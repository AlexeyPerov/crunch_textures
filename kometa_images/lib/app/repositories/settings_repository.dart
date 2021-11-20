import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

abstract class SettingsRepository {
  Future initialize();

  dynamic get(String key, dynamic defaultValue);
  void put(String key, dynamic value);

  String getString(String key, {String defaultValue = ''});
  void putString(String key, String value);

  int getInt(String key, {int defaultValue = 0});
  void putInt(String key, int value);

  bool getBool(String key, {bool defaultValue = false});
  void putBool(String key, bool value);
}

class HiveSettingsRepository extends SettingsRepository {
  final String _boxName = 'settings';

  @override
  Future initialize() async {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      var path = Directory.current.path;
      Hive.init(path);
    } else if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
      var directory = await pathProvider.getApplicationDocumentsDirectory();
      Hive.init(directory.path);
    }
    await Hive.openBox(_boxName);
  }

  @override
  dynamic get(String key, dynamic defaultValue) {
    return Hive.box(_boxName).get(key, defaultValue: defaultValue);
  }

  @override
  void put(String key, dynamic value) {
    Hive.box(_boxName).put(key, value);
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    return Hive.box(_boxName).get(key, defaultValue: defaultValue);
  }

  @override
  void putString(String key, String value) {
    Hive.box(_boxName).put(key, value);
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    return Hive.box(_boxName).get(key, defaultValue: defaultValue);
  }

  @override
  void putInt(String key, int value) {
    Hive.box(_boxName).put(key, value);
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    return Hive.box(_boxName).get(key, defaultValue: defaultValue);
  }

  @override
  void putBool(String key, bool value) {
    Hive.box(_boxName).put(key, value);
  }
}
