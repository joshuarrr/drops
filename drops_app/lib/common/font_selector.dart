import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import '../theme/custom_fonts.dart';
import 'variable_font_control.dart';

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

      // Add League fonts
      final Set<String> leagueFonts = {
        CustomFonts.leagueGothicFamily,
        CustomFonts.leagueSpartanFamily,
        CustomFonts.leagueScriptFamily,
        CustomFonts.ostrichSansFamily,
        CustomFonts.ostrichSansInlineFamily,
        CustomFonts.ostrichSansRoundedFamily,
        CustomFonts.ostrichSansDashedFamily,
        CustomFonts.orbitronFamily,
        CustomFonts.knewaveFamily,
        CustomFonts.junctionFamily,
        CustomFonts.goudyBookletterFamily,
        CustomFonts.goudyStMFamily,
        CustomFonts.blackoutSunriseFamily,
        CustomFonts.blackoutMidnightFamily,
        CustomFonts.blackoutTwoAmFamily,
        CustomFonts.snigletFamily,
        CustomFonts.lindenHillFamily,
      };

      families.addAll(leagueFonts);

      // Add Kyiv Type fonts
      final Set<String> kyivTypeFonts = {
        CustomFonts.kyivTypeSansFamily,
        CustomFonts.kyivTypeSerifFamily,
        CustomFonts.kyivTypeTitlingFamily,
      };

      families.addAll(kyivTypeFonts);

      // Add all Fontesk fonts
      final Set<String> fonteskFonts = {
        CustomFonts.kyivTypeSansFamily,
        CustomFonts.kyivTypeSerifFamily,
        CustomFonts.kyivTypeTitlingFamily,
        CustomFonts.valiantFamily,
        CustomFonts.starlanceFamily,
        CustomFonts.farabeeFamily,
        CustomFonts.farabeeStraightFamily,
        CustomFonts.superJellyfishFamily,
        CustomFonts.vaganovSpDemoFamily,
        CustomFonts.ballastStencilFamily,
        CustomFonts.parajanovFamily,
        CustomFonts.martiusFamily,
        CustomFonts.superBraveFamily,
        CustomFonts.canalhaFamily,
        CustomFonts.beastFamily,
        CustomFonts.lettertypeFamily,
        CustomFonts.fnOctahedronFamily,
        CustomFonts.dotMatrixDuoFamily,
        CustomFonts.tintagelFamily,
        CustomFonts.gotfridusFamily,
        CustomFonts.ltBasixFamily,
        CustomFonts.moltenDisplayFamily,
        CustomFonts.triformFamily,
        CustomFonts.groutpixFlowSerifFamily,
        CustomFonts.rhombicFamily,
        CustomFonts.noseTransportFamily,
        CustomFonts.outrightFamily,
        CustomFonts.moonetFamily,
        CustomFonts.mykaFamily,
        CustomFonts.frontlineFamily,
        CustomFonts.jaroFamily,
        CustomFonts.teaTypeFamily,
        CustomFonts.molokoFamily,
        CustomFonts.tachyoFamily,
        CustomFonts.scornFamily,
        CustomFonts.fasadFamily,
        CustomFonts.kreaseFamily,
        CustomFonts.beonFamily,
        CustomFonts.gademsFamily,
        CustomFonts.grishaFamily,
        CustomFonts.desertaFamily,
        CustomFonts.neonSansFamily,
        CustomFonts.rookworstFamily,
        CustomFonts.deadenderFamily,
        CustomFonts.klaxonsFamily,
        CustomFonts.starwayFamily,
      };

      families.addAll(fonteskFonts);

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
class FontSelector extends StatefulWidget {
  const FontSelector({
    super.key,
    required this.selectedFont,
    required this.onFontSelected,
    this.selectedWeight,
    this.onWeightSelected,
    this.dropdownColor,
    this.labelText,
  });

  /// Currently selected font family name ("Roboto" etc.).
  final String selectedFont;

  /// Called when the user picks a new font.
  final ValueChanged<String> onFontSelected;

  /// Currently selected weight – if null the dropdown defaults to w400.
  final FontWeight? selectedWeight;

  /// Callback when the weight is changed. If null the weight dropdown is still shown but disabled.
  final ValueChanged<FontWeight>? onWeightSelected;

  /// Optional dropdown background color – defaults to Theme brightness.
  final Color? dropdownColor;

  /// Optional text label shown before the dropdown.
  final String? labelText;

  @override
  State<FontSelector> createState() => _FontSelectorState();
}

class _FontSelectorState extends State<FontSelector> {
  // Store axis values for variable fonts
  Map<String, double> _axisValues = {};

  // Method to check if a font is a League font
  bool _isLeagueFont(String family) {
    return family == CustomFonts.leagueGothicFamily ||
        family == CustomFonts.leagueSpartanFamily ||
        family == CustomFonts.leagueScriptFamily ||
        family == CustomFonts.ostrichSansFamily ||
        family == CustomFonts.ostrichSansInlineFamily ||
        family == CustomFonts.ostrichSansRoundedFamily ||
        family == CustomFonts.ostrichSansDashedFamily ||
        family == CustomFonts.orbitronFamily ||
        family == CustomFonts.knewaveFamily ||
        family == CustomFonts.junctionFamily ||
        family == CustomFonts.goudyBookletterFamily ||
        family == CustomFonts.goudyStMFamily ||
        family == CustomFonts.blackoutSunriseFamily ||
        family == CustomFonts.blackoutMidnightFamily ||
        family == CustomFonts.blackoutTwoAmFamily ||
        family == CustomFonts.snigletFamily ||
        family == CustomFonts.lindenHillFamily;
  }

  // Method to check if a font is a Fontesk font
  bool _isFonteskFont(String family) {
    return family == CustomFonts.kyivTypeSansFamily ||
        family == CustomFonts.kyivTypeSerifFamily ||
        family == CustomFonts.kyivTypeTitlingFamily ||
        family == CustomFonts.valiantFamily ||
        family == CustomFonts.starlanceFamily ||
        family == CustomFonts.farabeeFamily ||
        family == CustomFonts.farabeeStraightFamily ||
        family == CustomFonts.superJellyfishFamily ||
        family == CustomFonts.vaganovSpDemoFamily ||
        family == CustomFonts.ballastStencilFamily ||
        family == CustomFonts.parajanovFamily ||
        family == CustomFonts.martiusFamily ||
        family == CustomFonts.superBraveFamily ||
        family == CustomFonts.canalhaFamily ||
        family == CustomFonts.beastFamily ||
        family == CustomFonts.lettertypeFamily ||
        family == CustomFonts.fnOctahedronFamily ||
        family == CustomFonts.dotMatrixDuoFamily ||
        family == CustomFonts.tintagelFamily ||
        family == CustomFonts.gotfridusFamily ||
        family == CustomFonts.ltBasixFamily ||
        family == CustomFonts.moltenDisplayFamily ||
        family == CustomFonts.triformFamily ||
        family == CustomFonts.groutpixFlowSerifFamily ||
        family == CustomFonts.rhombicFamily ||
        family == CustomFonts.noseTransportFamily ||
        family == CustomFonts.outrightFamily ||
        family == CustomFonts.moonetFamily ||
        family == CustomFonts.mykaFamily ||
        family == CustomFonts.frontlineFamily ||
        family == CustomFonts.jaroFamily ||
        family == CustomFonts.teaTypeFamily ||
        family == CustomFonts.molokoFamily ||
        family == CustomFonts.tachyoFamily ||
        family == CustomFonts.scornFamily ||
        family == CustomFonts.fasadFamily ||
        family == CustomFonts.kreaseFamily ||
        family == CustomFonts.beonFamily ||
        family == CustomFonts.gademsFamily ||
        family == CustomFonts.grishaFamily ||
        family == CustomFonts.desertaFamily ||
        family == CustomFonts.neonSansFamily ||
        family == CustomFonts.rookworstFamily ||
        family == CustomFonts.deadenderFamily ||
        family == CustomFonts.klaxonsFamily ||
        family == CustomFonts.starwayFamily;
  }

  // Method to check if a font is a variable font
  bool _isVariableFont(String family) {
    // Kyiv Type variable fonts
    if (family == CustomFonts.kyivTypeSansFamily ||
        family == CustomFonts.kyivTypeSerifFamily ||
        family == CustomFonts.kyivTypeTitlingFamily) {
      return true;
    }

    // League Spartan is also a variable font
    if (family == CustomFonts.leagueSpartanFamily) {
      return true;
    }

    return false;
  }

  // Handle axis value changes from the variable font control
  void _handleAxisValuesChanged(Map<String, double> values) {
    // Store values without setState to avoid build issues
    _axisValues = values;

    // Avoid setState during build with post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // State is already updated, just trigger rebuild
      });

      // Convert weight axis to FontWeight for backward compatibility
      if (values.containsKey('wght') && widget.onWeightSelected != null) {
        final weightValue = values['wght']!;
        // Convert numeric weight to FontWeight
        FontWeight fontWeight;
        if (weightValue <= 150)
          fontWeight = FontWeight.w100;
        else if (weightValue <= 250)
          fontWeight = FontWeight.w200;
        else if (weightValue <= 350)
          fontWeight = FontWeight.w300;
        else if (weightValue <= 450)
          fontWeight = FontWeight.w400;
        else if (weightValue <= 550)
          fontWeight = FontWeight.w500;
        else if (weightValue <= 650)
          fontWeight = FontWeight.w600;
        else if (weightValue <= 750)
          fontWeight = FontWeight.w700;
        else if (weightValue <= 850)
          fontWeight = FontWeight.w800;
        else
          fontWeight = FontWeight.w900;

        widget.onWeightSelected!(fontWeight);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color accent = theme.colorScheme.primary;
    final Color textColor = theme.colorScheme.onSurface;

    Widget buildDropdown(List<String> families) {
      // Add a searchable/scrollable list of fonts? For now simple dropdown.
      final List<String> items = ['Default', ...families];
      if (!items.contains(widget.selectedFont)) {
        items.insert(
          1,
          widget.selectedFont,
        ); // keep currently selected visible.
      }

      return DropdownButton<String>(
        value: widget.selectedFont,
        dropdownColor:
            widget.dropdownColor ?? (isDark ? Colors.black87 : Colors.white),
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: accent),
        underline: Container(height: 2, color: accent),
        style: TextStyle(color: textColor),
        onChanged: (String? v) {
          if (v != null) widget.onFontSelected(v);
        },
        items: items.map<DropdownMenuItem<String>>((String family) {
          TextStyle? previewStyle;
          if (family != 'Default') {
            // Handle League fonts and Fontesk fonts differently from Google fonts
            if (_isLeagueFont(family) || _isFonteskFont(family)) {
              previewStyle = TextStyle(fontFamily: family, color: textColor);
            } else {
              try {
                previewStyle = GoogleFonts.getFont(
                  family,
                  textStyle: TextStyle(color: textColor),
                );
              } catch (_) {
                previewStyle = TextStyle(fontFamily: family, color: textColor);
              }
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
            if (widget.labelText != null) ...[
              Text(
                widget.labelText!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            buildDropdown(families),
            const SizedBox(height: 8),
            // Show Variable Font Control or Weight Dropdown based on selected font
            _isVariableFont(widget.selectedFont)
                ? VariableFontControl(
                    fontFamily: widget.selectedFont,
                    onAxisValuesChanged: _handleAxisValuesChanged,
                    initialAxisValues: _axisValues,
                    textColor: textColor,
                  )
                : _buildWeightDropdown(textColor, accent),
          ],
        );
      },
    );
  }

  /// Builds weight dropdown using common typographic weights.
  Widget _buildWeightDropdown(Color textColor, Color accent) {
    // Common display names for weights
    const weightLabels = {
      FontWeight.w100: 'Thin',
      FontWeight.w200: 'Extra-Light',
      FontWeight.w300: 'Light',
      FontWeight.w400: 'Regular',
      FontWeight.w500: 'Medium',
      FontWeight.w600: 'Semi-Bold',
      FontWeight.w700: 'Bold',
      FontWeight.w800: 'Extra-Bold',
      FontWeight.w900: 'Black',
    };

    final FontWeight current = widget.selectedWeight ?? FontWeight.w400;

    return DropdownButton<FontWeight>(
      value: current,
      dropdownColor: widget.dropdownColor ?? Colors.black87,
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, color: accent),
      underline: Container(height: 2, color: accent),
      style: TextStyle(color: textColor),
      onChanged: widget.onWeightSelected == null
          ? null
          : (FontWeight? w) {
              if (w != null) widget.onWeightSelected!(w);
            },
      items: weightLabels.entries.map<DropdownMenuItem<FontWeight>>((entry) {
        final weight = entry.key;
        final label = '${entry.value} (${weight.index + 1}00)';
        TextStyle preview;

        // Handle League and Fontesk fonts differently for weight preview
        if (widget.selectedFont != 'Default' &&
            (_isLeagueFont(widget.selectedFont) ||
                _isFonteskFont(widget.selectedFont))) {
          preview = TextStyle(
            color: textColor,
            fontWeight: weight,
            fontFamily: widget.selectedFont,
          );
        } else {
          try {
            preview = GoogleFonts.getFont(
              widget.selectedFont == 'Default' ? 'Roboto' : widget.selectedFont,
              textStyle: TextStyle(color: textColor, fontWeight: weight),
            );
          } catch (_) {
            preview = TextStyle(
              color: textColor,
              fontWeight: weight,
              fontFamily: widget.selectedFont == 'Default'
                  ? null
                  : widget.selectedFont,
            );
          }
        }

        return DropdownMenuItem<FontWeight>(
          value: weight,
          child: Text(label, style: preview),
        );
      }).toList(),
    );
  }
}
