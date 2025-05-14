import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

/// Utility that discovers bundled Google Font families from `AssetManifest.json`.
///
/// The lookup is performed once and the result is cached for the lifetime of
/// the process so subsequent callers return immediately.
class FontUtils {
  FontUtils._(); // no instantiation

  static List<String>? _cachedFamilies;

  /// Returns the list of available font families (e.g. "Orbitron", "Bree Serif").
  ///
  /// A family is considered available when at least one TTF exists under
  /// `assets/google_fonts/<family>/`.
  static Future<List<String>> loadFontFamilies() async {
    if (_cachedFamilies != null) return _cachedFamilies!;

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final dynamic manifestJson = json.decode(manifestContent);

      Iterable<String> assetKeys = [];
      if (manifestJson is Map<String, dynamic>) {
        if (manifestJson.containsKey('assets') &&
            manifestJson['assets'] is Map<String, dynamic>) {
          assetKeys = (manifestJson['assets'] as Map<String, dynamic>).keys;
        } else {
          assetKeys = manifestJson.keys;
        }
      }

      final Set<String> families = assetKeys
          .where(
            (p) => p.startsWith('assets/google_fonts/') && p.endsWith('.ttf'),
          )
          .map((p) {
            final parts = p.split('/');
            if (parts.length >= 3) {
              // Directory name is the family with underscores instead of spaces
              final dir = parts[2];
              return dir.replaceAll('_', ' ');
            }
            return '';
          })
          .where((f) => f.isNotEmpty)
          .toSet();

      final list = families.toList()..sort();
      _cachedFamilies = list;
      return list;
    } catch (e, s) {
      debugPrint('FontUtils.loadFontFamilies failed: $e\n$s');
      _cachedFamilies = ['Roboto'];
      return _cachedFamilies!;
    }
  }
}

/// Simple dropdown widget that lets the user pick a font family.
///
/// If the bundled fonts haven't finished loading yet a [CircularProgressIndicator]
/// is shown.
class FontSelector extends StatelessWidget {
  const FontSelector({
    super.key,
    required this.selectedFont,
    required this.onFontSelected,
    this.dropdownColor,
    this.labelText,
  });

  /// Currently selected font family name ("Roboto" etc.).
  final String selectedFont;

  /// Called when the user picks a new font.
  final ValueChanged<String> onFontSelected;

  /// Optional dropdown background color – defaults to Theme brightness.
  final Color? dropdownColor;

  /// Optional text label shown before the dropdown.
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color accent = theme.colorScheme.primary;
    final Color textColor = theme.colorScheme.onSurface;

    Widget buildDropdown(List<String> families) {
      // Add a searchable/scrollable list of fonts? For now simple dropdown.
      final List<String> items = ['Default', ...families];
      if (!items.contains(selectedFont)) {
        items.insert(1, selectedFont); // keep currently selected visible.
      }

      return DropdownButton<String>(
        value: selectedFont,
        dropdownColor:
            dropdownColor ?? (isDark ? Colors.black87 : Colors.white),
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: accent),
        underline: Container(height: 2, color: accent),
        style: TextStyle(color: textColor),
        onChanged: (String? v) {
          if (v != null) onFontSelected(v);
        },
        items: items.map<DropdownMenuItem<String>>((String family) {
          TextStyle? previewStyle;
          if (family != 'Default') {
            try {
              previewStyle = GoogleFonts.getFont(
                family,
                textStyle: TextStyle(color: textColor),
              );
            } catch (_) {
              previewStyle = TextStyle(fontFamily: family, color: textColor);
            }
          }
          return DropdownMenuItem<String>(
            value: family,
            child: Text(family, style: previewStyle),
          );
        }).toList(),
      );
    }

    return FutureBuilder<List<String>>(
      future: FontUtils.loadFontFamilies(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final families = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (labelText != null) ...[
              Text(
                labelText!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            buildDropdown(families),
          ],
        );
      },
    );
  }
}
