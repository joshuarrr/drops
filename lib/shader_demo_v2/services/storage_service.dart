import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Clean wrapper around SharedPreferences for V2
/// Handles only storage operations, no business logic
class StorageService {
  static const String _presetPrefix = 'shader_v2_preset_';
  static const String _thumbnailPrefix = 'shader_v2_thumb_';
  static const String _untitledKey = 'shader_v2_untitled';
  static const String _lastStateKey = 'shader_v2_last_state';

  static SharedPreferences? _prefs;

  /// Initialize the storage service
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance (ensure initialized first)
  static SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError(
        'StorageService not initialized. Call initialize() first.',
      );
    }
    return _prefs!;
  }

  /// Save JSON data with a key
  static Future<bool> saveJson(String key, Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      return await _preferences.setString(key, jsonString);
    } catch (e) {
      print('Error saving JSON for key $key: $e');
      return false;
    }
  }

  /// Load JSON data by key
  static Map<String, dynamic>? loadJson(String key) {
    try {
      final jsonString = _preferences.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading JSON for key $key: $e');
      return null;
    }
  }

  /// Save string value
  static Future<bool> saveString(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  /// Load string value
  static String? loadString(String key) {
    return _preferences.getString(key);
  }

  /// Save boolean value
  static Future<bool> saveBool(String key, bool value) async {
    return await _preferences.setBool(key, value);
  }

  /// Load boolean value
  static bool? loadBool(String key) {
    return _preferences.getBool(key);
  }

  /// Remove a key
  static Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }

  /// Check if a key exists
  static bool containsKey(String key) {
    return _preferences.containsKey(key);
  }

  /// Get all keys matching a prefix
  static List<String> getKeysWithPrefix(String prefix) {
    return _preferences
        .getKeys()
        .where((key) => key.startsWith(prefix))
        .toList();
  }

  /// Clear all data (use with caution)
  static Future<bool> clearAll() async {
    return await _preferences.clear();
  }

  /// Preset-specific storage helpers

  /// Save a preset
  static Future<bool> savePreset(
    String presetId,
    Map<String, dynamic> presetData,
  ) async {
    return await saveJson('${_presetPrefix}$presetId', presetData);
  }

  /// Load a preset
  static Map<String, dynamic>? loadPreset(String presetId) {
    return loadJson('${_presetPrefix}$presetId');
  }

  /// Remove a preset
  static Future<bool> removePreset(String presetId) async {
    // Remove both preset data and thumbnail
    final presetRemoved = await remove('${_presetPrefix}$presetId');
    final thumbnailRemoved = await remove('${_thumbnailPrefix}$presetId');
    return presetRemoved; // Main success criteria
  }

  /// Get all preset IDs
  static List<String> getAllPresetIds() {
    return getKeysWithPrefix(
      _presetPrefix,
    ).map((key) => key.replaceFirst(_presetPrefix, '')).toList();
  }

  /// Save preset thumbnail
  static Future<bool> savePresetThumbnail(
    String presetId,
    String base64Data,
  ) async {
    return await saveString('${_thumbnailPrefix}$presetId', base64Data);
  }

  /// Load preset thumbnail
  static String? loadPresetThumbnail(String presetId) {
    final result = loadString('${_thumbnailPrefix}$presetId');
    return result;
  }

  /// Save untitled preset state
  static Future<bool> saveUntitledState(Map<String, dynamic> state) async {
    return await saveJson(_untitledKey, state);
  }

  /// Load untitled preset state
  static Map<String, dynamic>? loadUntitledState() {
    return loadJson(_untitledKey);
  }

  /// Clear untitled state
  static Future<bool> clearUntitledState() async {
    return await remove(_untitledKey);
  }

  /// Save last app state (for restoration)
  static Future<bool> saveLastState(Map<String, dynamic> state) async {
    return await saveJson(_lastStateKey, state);
  }

  /// Load last app state
  static Map<String, dynamic>? loadLastState() {
    return loadJson(_lastStateKey);
  }

  /// Get storage statistics
  static Map<String, int> getStorageStats() {
    final allKeys = _preferences.getKeys();
    final presetCount = allKeys
        .where((k) => k.startsWith(_presetPrefix))
        .length;
    final thumbnailCount = allKeys
        .where((k) => k.startsWith(_thumbnailPrefix))
        .length;

    return {
      'totalKeys': allKeys.length,
      'presets': presetCount,
      'thumbnails': thumbnailCount,
      'hasUntitled': containsKey(_untitledKey) ? 1 : 0,
      'hasLastState': containsKey(_lastStateKey) ? 1 : 0,
    };
  }
}
