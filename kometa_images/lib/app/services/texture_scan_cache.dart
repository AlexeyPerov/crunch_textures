import 'package:kometa_images/app/repositories/settings_repository.dart';

class TextureScanCache {
  static const String _cacheKey = 'texture_scan_cache_v1';

  final SettingsRepository _settings;
  final Map<String, TextureScanCacheEntry> _entries = {};

  TextureScanCache(this._settings);

  void load() {
    _entries.clear();
    final raw = _settings.get(_cacheKey, {});
    if (raw is! Map) {
      return;
    }

    raw.forEach((key, value) {
      if (key is! String || value is! Map) {
        return;
      }

      final entry = TextureScanCacheEntry.fromMap(value);
      if (entry == null) {
        return;
      }
      _entries[key] = entry;
    });
  }

  TextureScanCacheEntry? getValid(
      String path, int modifiedMs, int fileLength) {
    final entry = _entries[path];
    if (entry == null) {
      return null;
    }

    if (entry.modifiedMs != modifiedMs || entry.fileLength != fileLength) {
      return null;
    }

    return entry;
  }

  void upsert(String path, int modifiedMs, int fileLength, int width, int height) {
    _entries[path] = TextureScanCacheEntry(
      modifiedMs: modifiedMs,
      fileLength: fileLength,
      width: width,
      height: height,
    );
  }

  void save() {
    final serialized = <String, Map<String, int>>{};
    _entries.forEach((path, entry) {
      serialized[path] = entry.toMap();
    });
    _settings.put(_cacheKey, serialized);
  }
}

class TextureScanCacheEntry {
  final int modifiedMs;
  final int fileLength;
  final int width;
  final int height;

  TextureScanCacheEntry({
    required this.modifiedMs,
    required this.fileLength,
    required this.width,
    required this.height,
  });

  static TextureScanCacheEntry? fromMap(Map input) {
    final modifiedMs = input['modifiedMs'];
    final fileLength = input['fileLength'];
    final width = input['width'];
    final height = input['height'];

    if (modifiedMs is! int ||
        fileLength is! int ||
        width is! int ||
        height is! int) {
      return null;
    }

    return TextureScanCacheEntry(
      modifiedMs: modifiedMs,
      fileLength: fileLength,
      width: width,
      height: height,
    );
  }

  Map<String, int> toMap() {
    return {
      'modifiedMs': modifiedMs,
      'fileLength': fileLength,
      'width': width,
      'height': height,
    };
  }
}
