import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'shader_effect.dart';

/// A utility class for managing shader presets storage and retrieval
class PresetsManager {
  static const String _presetsKey = 'shader_presets';

  // Save a preset
  static Future<bool> savePreset(
    ShaderAspect aspect,
    String name,
    Map<String, dynamic> settings,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing presets
      final String? existingPresetsJson = prefs.getString(_presetsKey);
      Map<String, dynamic> presets = {};

      if (existingPresetsJson != null) {
        // Cast the decoded JSON to the correct type using Map.from
        final dynamic decodedJson = jsonDecode(existingPresetsJson);
        presets = _convertToStringDynamicMap(decodedJson);
      }

      // Create aspect key
      final String aspectKey = aspect.toString();
      if (!presets.containsKey(aspectKey)) {
        presets[aspectKey] = <String, dynamic>{};
      } else if (presets[aspectKey] is Map &&
          !(presets[aspectKey] is Map<String, dynamic>)) {
        // Ensure we have the right map type
        presets[aspectKey] = _convertToStringDynamicMap(presets[aspectKey]);
      }

      // Add the preset to the aspect map
      final aspectMap = presets[aspectKey] as Map<String, dynamic>;
      aspectMap[name] = settings;

      // Save back to SharedPreferences
      await prefs.setString(_presetsKey, jsonEncode(presets));
      return true;
    } catch (e) {
      print('Error saving preset: $e');
      return false;
    }
  }

  // Load presets for a specific aspect
  static Future<Map<String, dynamic>> getPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? presetsJson = prefs.getString(_presetsKey);

      if (presetsJson != null) {
        final dynamic allPresets = jsonDecode(presetsJson);
        final Map<String, dynamic> typedPresets = _convertToStringDynamicMap(
          allPresets,
        );
        final String aspectKey = aspect.toString();

        if (typedPresets.containsKey(aspectKey)) {
          return _convertToStringDynamicMap(typedPresets[aspectKey]);
        }
      }
      return {};
    } catch (e) {
      print('Error loading presets: $e');
      return {};
    }
  }

  // Delete a preset
  static Future<bool> deletePreset(ShaderAspect aspect, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? presetsJson = prefs.getString(_presetsKey);

      if (presetsJson != null) {
        final dynamic decodedJson = jsonDecode(presetsJson);
        final Map<String, dynamic> allPresets = _convertToStringDynamicMap(
          decodedJson,
        );
        final String aspectKey = aspect.toString();

        if (allPresets.containsKey(aspectKey)) {
          final Map<String, dynamic> aspectPresets = _convertToStringDynamicMap(
            allPresets[aspectKey],
          );

          if (aspectPresets.containsKey(name)) {
            aspectPresets.remove(name);
            allPresets[aspectKey] = aspectPresets;
            await prefs.setString(_presetsKey, jsonEncode(allPresets));
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('Error deleting preset: $e');
      return false;
    }
  }

  // Helper method to safely convert dynamic maps to Map<String, dynamic>
  static Map<String, dynamic> _convertToStringDynamicMap(dynamic input) {
    if (input is! Map) {
      return <String, dynamic>{};
    }

    final result = <String, dynamic>{};
    for (final entry in (input as Map).entries) {
      final key = entry.key.toString();
      final value = entry.value;

      // Recursively convert nested maps
      if (value is Map) {
        result[key] = _convertToStringDynamicMap(value);
      } else if (value is List) {
        // Convert lists that might contain maps
        result[key] = _convertListElements(value);
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  // Helper method to handle lists that might contain maps
  static List<dynamic> _convertListElements(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _convertToStringDynamicMap(item);
      } else if (item is List) {
        return _convertListElements(item);
      } else {
        return item;
      }
    }).toList();
  }
}
