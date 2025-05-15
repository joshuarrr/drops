import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/presets_manager.dart';
import '../../common/font_selector.dart';
import 'value_slider.dart';
import 'alignment_selector.dart';
import 'aspect_panel_header.dart';
import 'text_input_field.dart';

// Enum for identifying each text line (outside class for reuse)
enum TextLine { title, subtitle, artist }

extension TextLineExt on TextLine {
  String get label {
    switch (this) {
      case TextLine.title:
        return 'Title';
      case TextLine.subtitle:
        return 'Subtitle';
      case TextLine.artist:
        return 'Artist';
    }
  }
}

class TextPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const TextPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<TextPanel> createState() => _TextPanelState();
}

class _TextPanelState extends State<TextPanel> {
  // Selected text line for editing
  TextLine selectedTextLine = TextLine.title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectPanelHeader(
          aspect: ShaderAspect.text,
          onPresetSelected: _applyPreset,
          onReset: _resetText,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
        ),
        // Add wrap for text line selection buttons
        Wrap(
          spacing: 6,
          children: TextLine.values.map((line) {
            return ChoiceChip(
              label: Text(
                line.label,
                style: TextStyle(color: widget.sliderColor),
              ),
              selected: selectedTextLine == line,
              selectedColor: widget.sliderColor.withOpacity(0.3),
              backgroundColor: widget.sliderColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.transparent),
              ),
              onSelected: (_) {
                setState(() {
                  selectedTextLine = line;
                });
                widget.onSettingsChanged(widget.settings);
              },
            );
          }).toList(),
        ),
        TextInputField(
          label: '${selectedTextLine.label} Text',
          value: _getCurrentText(),
          onChanged: _setCurrentText,
          textColor: widget.sliderColor,
          enableLogging: false,
          isTextEnabled: () => widget.settings.textEnabled,
          enableText: () {
            widget.settings.textEnabled = true;
            widget.onSettingsChanged(widget.settings);
          },
        ),
        FontSelector(
          selectedFont: _getCurrentFont().isEmpty
              ? 'Default'
              : _getCurrentFont(),
          selectedWeight: _toFontWeight(_getCurrentWeight()),
          labelText: 'Font',
          onFontSelected: (font) {
            final selected = font == 'Default' ? '' : font;
            _setCurrentFont(selected);
            if (!widget.settings.textEnabled)
              widget.settings.textEnabled = true;
            widget.onSettingsChanged(widget.settings);
          },
          onWeightSelected: (fw) {
            _setCurrentWeight(_fromFontWeight(fw));
            if (!widget.settings.textEnabled)
              widget.settings.textEnabled = true;
            widget.onSettingsChanged(widget.settings);
          },
        ),
        const SizedBox(height: 12),
        ValueSlider(
          label: 'Size',
          value: _getCurrentSize(),
          onChanged: (v) => _onSliderChanged(v, _setCurrentSize),
          sliderColor: widget.sliderColor,
          defaultValue: 0.05,
        ),
        // Add Fit to Width checkbox
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fit to Width',
              style: TextStyle(color: widget.sliderColor, fontSize: 14),
            ),
            Checkbox(
              value: _getCurrentFitToWidth(),
              checkColor: Colors.black,
              activeColor: widget.sliderColor,
              side: BorderSide(color: widget.sliderColor),
              onChanged: (value) {
                if (value != null) {
                  _setCurrentFitToWidth(value);
                  if (!widget.settings.textEnabled)
                    widget.settings.textEnabled = true;
                  widget.onSettingsChanged(widget.settings);
                }
              },
            ),
          ],
        ),
        // Only show line height slider if fitToWidth is enabled
        if (_getCurrentFitToWidth())
          ValueSlider(
            label: 'Line Height',
            value: _getCurrentLineHeight() / 2.0, // Scale to 0-1 range
            onChanged: (v) => _onSliderChanged(
              v,
              (val) => _setCurrentLineHeight(val * 2.0),
            ), // Scale to 0-2 range
            sliderColor: widget.sliderColor,
            defaultValue: 0.6, // Default 1.2 scaled to 0-1 range
          ),
        ValueSlider(
          label: 'Position X',
          value: _getCurrentPosX(),
          onChanged: (v) => _onSliderChanged(v, _setCurrentPosX),
          sliderColor: widget.sliderColor,
          defaultValue: 0.1,
        ),
        ValueSlider(
          label: 'Position Y',
          value: _getCurrentPosY(),
          onChanged: (v) => _onSliderChanged(v, _setCurrentPosY),
          sliderColor: widget.sliderColor,
          defaultValue: 0.1,
        ),
        // Add horizontal alignment controls
        AlignmentSelector(
          label: 'Horizontal Alignment',
          currentValue: _getCurrentHAlign(),
          onChanged: (value) {
            _setCurrentHAlign(value);
            if (!widget.settings.textEnabled)
              widget.settings.textEnabled = true;
            widget.onSettingsChanged(widget.settings);
          },
          sliderColor: widget.sliderColor,
          icons: const [
            Icons.format_align_left,
            Icons.format_align_center,
            Icons.format_align_right,
          ],
          tooltips: const ['Left Align', 'Center Align', 'Right Align'],
        ),
        const SizedBox(height: 16),
        // Add vertical alignment controls
        AlignmentSelector(
          label: 'Vertical Alignment',
          currentValue: _getCurrentVAlign(),
          onChanged: (value) {
            _setCurrentVAlign(value);
            if (!widget.settings.textEnabled)
              widget.settings.textEnabled = true;
            widget.onSettingsChanged(widget.settings);
          },
          sliderColor: widget.sliderColor,
          icons: const [
            Icons.vertical_align_top,
            Icons.vertical_align_center,
            Icons.vertical_align_bottom,
          ],
          tooltips: const ['Top Align', 'Middle Align', 'Bottom Align'],
        ),
      ],
    );
  }

  void _onSliderChanged(double value, Function(double) setter) {
    // Enable the corresponding effect if it's not already enabled
    if (!widget.settings.textEnabled) widget.settings.textEnabled = true;

    // Update the setting value
    setter(value);
    // Notify the parent widget
    widget.onSettingsChanged(widget.settings);
  }

  // Mapping helpers for the currently selected text line
  String _getCurrentText() {
    String rawText = "";
    switch (selectedTextLine) {
      case TextLine.title:
        rawText = widget.settings.textTitle;
        break;
      case TextLine.subtitle:
        rawText = widget.settings.textSubtitle;
        break;
      case TextLine.artist:
        rawText = widget.settings.textArtist;
        break;
    }

    // Fix for the display - we need to show the correctly ordered text
    return rawText;
  }

  void _setCurrentText(String v) {
    // The text is coming from the text field in reverse order (last character first)
    // Reverse it back to normal order before storing
    final correctedText = String.fromCharCodes(v.runes.toList().reversed);

    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textTitle = correctedText;
        break;
      case TextLine.subtitle:
        widget.settings.textSubtitle = correctedText;
        break;
      case TextLine.artist:
        widget.settings.textArtist = correctedText;
        break;
    }
  }

  String _getCurrentFont() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.titleFont.isNotEmpty
            ? widget.settings.titleFont
            : widget.settings.textFont;
      case TextLine.subtitle:
        return widget.settings.subtitleFont.isNotEmpty
            ? widget.settings.subtitleFont
            : widget.settings.textFont;
      case TextLine.artist:
        return widget.settings.artistFont.isNotEmpty
            ? widget.settings.artistFont
            : widget.settings.textFont;
    }
    return widget.settings.textFont;
  }

  void _setCurrentFont(String f) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.titleFont = f;
        break;
      case TextLine.subtitle:
        widget.settings.subtitleFont = f;
        break;
      case TextLine.artist:
        widget.settings.artistFont = f;
        break;
    }
  }

  double _getCurrentSize() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.titleSize > 0
            ? widget.settings.titleSize
            : widget.settings.textSize;
      case TextLine.subtitle:
        return widget.settings.subtitleSize > 0
            ? widget.settings.subtitleSize
            : widget.settings.textSize;
      case TextLine.artist:
        return widget.settings.artistSize > 0
            ? widget.settings.artistSize
            : widget.settings.textSize;
    }
    return widget.settings.textSize;
  }

  void _setCurrentSize(double v) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.titleSize = v;
        break;
      case TextLine.subtitle:
        widget.settings.subtitleSize = v;
        break;
      case TextLine.artist:
        widget.settings.artistSize = v;
        break;
    }
  }

  double _getCurrentPosX() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.titlePosX;
      case TextLine.subtitle:
        return widget.settings.subtitlePosX;
      case TextLine.artist:
        return widget.settings.artistPosX;
    }
    return 0.0;
  }

  void _setCurrentPosX(double v) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.titlePosX = v;
        break;
      case TextLine.subtitle:
        widget.settings.subtitlePosX = v;
        break;
      case TextLine.artist:
        widget.settings.artistPosX = v;
        break;
    }
  }

  double _getCurrentPosY() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.titlePosY;
      case TextLine.subtitle:
        return widget.settings.subtitlePosY;
      case TextLine.artist:
        return widget.settings.artistPosY;
    }
    return 0.0;
  }

  void _setCurrentPosY(double v) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.titlePosY = v;
        break;
      case TextLine.subtitle:
        widget.settings.subtitlePosY = v;
        break;
      case TextLine.artist:
        widget.settings.artistPosY = v;
        break;
    }
  }

  // -------- Weight helpers ---------
  int _getCurrentWeight() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.titleWeight > 0
            ? widget.settings.titleWeight
            : widget.settings.textWeight;
      case TextLine.subtitle:
        return widget.settings.subtitleWeight > 0
            ? widget.settings.subtitleWeight
            : widget.settings.textWeight;
      case TextLine.artist:
        return widget.settings.artistWeight > 0
            ? widget.settings.artistWeight
            : widget.settings.textWeight;
    }
    return widget.settings.textWeight;
  }

  void _setCurrentWeight(int w) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.titleWeight = w;
        break;
      case TextLine.subtitle:
        widget.settings.subtitleWeight = w;
        break;
      case TextLine.artist:
        widget.settings.artistWeight = w;
        break;
    }
  }

  // -------- Fit to width helpers ---------
  bool _getCurrentFitToWidth() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.titleFitToWidth;
      case TextLine.subtitle:
        return widget.settings.subtitleFitToWidth;
      case TextLine.artist:
        return widget.settings.artistFitToWidth;
    }
    return false;
  }

  void _setCurrentFitToWidth(bool value) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.titleFitToWidth = value;
        break;
      case TextLine.subtitle:
        widget.settings.subtitleFitToWidth = value;
        break;
      case TextLine.artist:
        widget.settings.artistFitToWidth = value;
        break;
    }
  }

  // -------- Horizontal alignment helpers ---------
  int _getCurrentHAlign() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.titleHAlign;
      case TextLine.subtitle:
        return widget.settings.subtitleHAlign;
      case TextLine.artist:
        return widget.settings.artistHAlign;
    }
    return 0; // Default to left
  }

  void _setCurrentHAlign(int value) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.titleHAlign = value;
        break;
      case TextLine.subtitle:
        widget.settings.subtitleHAlign = value;
        break;
      case TextLine.artist:
        widget.settings.artistHAlign = value;
        break;
    }
  }

  // -------- Vertical alignment helpers ---------
  int _getCurrentVAlign() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.titleVAlign;
      case TextLine.subtitle:
        return widget.settings.subtitleVAlign;
      case TextLine.artist:
        return widget.settings.artistVAlign;
    }
    return 0; // Default to top
  }

  void _setCurrentVAlign(int value) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.titleVAlign = value;
        break;
      case TextLine.subtitle:
        widget.settings.subtitleVAlign = value;
        break;
      case TextLine.artist:
        widget.settings.artistVAlign = value;
        break;
    }
  }

  // -------- Line height helpers ---------
  double _getCurrentLineHeight() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.titleLineHeight;
      case TextLine.subtitle:
        return widget.settings.subtitleLineHeight;
      case TextLine.artist:
        return widget.settings.artistLineHeight;
    }
    return 1.2; // Default line height
  }

  void _setCurrentLineHeight(double value) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.titleLineHeight = value;
        break;
      case TextLine.subtitle:
        widget.settings.subtitleLineHeight = value;
        break;
      case TextLine.artist:
        widget.settings.artistLineHeight = value;
        break;
    }
  }

  // Helper to convert int weight to FontWeight
  FontWeight _toFontWeight(int weight) {
    switch (weight) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  int _fromFontWeight(FontWeight fw) {
    switch (fw) {
      case FontWeight.w100:
        return 100;
      case FontWeight.w200:
        return 200;
      case FontWeight.w300:
        return 300;
      case FontWeight.w400:
        return 400;
      case FontWeight.w500:
        return 500;
      case FontWeight.w600:
        return 600;
      case FontWeight.w700:
        return 700;
      case FontWeight.w800:
        return 800;
      case FontWeight.w900:
        return 900;
      default:
        return 400;
    }
  }

  void _resetText() {
    final defaults = ShaderSettings();
    // Create a copy of the current settings and reset only text properties
    final resetSettings = ShaderSettings.fromMap(widget.settings.toMap())
      ..textEnabled = false
      ..textTitle = defaults.textTitle
      ..textSubtitle = defaults.textSubtitle
      ..textArtist = defaults.textArtist
      ..textFont = defaults.textFont
      ..textSize = defaults.textSize
      ..textPosX = defaults.textPosX
      ..textPosY = defaults.textPosY
      ..textWeight = defaults.textWeight
      ..titleFont = defaults.titleFont
      ..titleSize = defaults.titleSize
      ..titlePosX = defaults.titlePosX
      ..titlePosY = defaults.titlePosY
      ..titleWeight = defaults.titleWeight
      ..subtitleFont = defaults.subtitleFont
      ..subtitleSize = defaults.subtitleSize
      ..subtitlePosX = defaults.subtitlePosX
      ..subtitlePosY = defaults.subtitlePosY
      ..subtitleWeight = defaults.subtitleWeight
      ..artistFont = defaults.artistFont
      ..artistSize = defaults.artistSize
      ..artistPosX = defaults.artistPosX
      ..artistPosY = defaults.artistPosY
      ..artistWeight = defaults.artistWeight
      ..textFitToWidth = defaults.textFitToWidth
      ..textHAlign = defaults.textHAlign
      ..textVAlign = defaults.textVAlign
      ..textLineHeight = defaults.textLineHeight
      ..titleFitToWidth = defaults.titleFitToWidth
      ..titleHAlign = defaults.titleHAlign
      ..titleVAlign = defaults.titleVAlign
      ..titleLineHeight = defaults.titleLineHeight
      ..subtitleFitToWidth = defaults.subtitleFitToWidth
      ..subtitleHAlign = defaults.subtitleHAlign
      ..subtitleVAlign = defaults.subtitleVAlign
      ..subtitleLineHeight = defaults.subtitleLineHeight
      ..artistFitToWidth = defaults.artistFitToWidth
      ..artistHAlign = defaults.artistHAlign
      ..artistVAlign = defaults.artistVAlign
      ..artistLineHeight = defaults.artistLineHeight;

    // Update the original settings object with the reset values
    widget.settings.textEnabled = resetSettings.textEnabled;
    widget.settings.textTitle = resetSettings.textTitle;
    widget.settings.textSubtitle = resetSettings.textSubtitle;
    widget.settings.textArtist = resetSettings.textArtist;
    widget.settings.textFont = resetSettings.textFont;
    widget.settings.textSize = resetSettings.textSize;
    widget.settings.textPosX = resetSettings.textPosX;
    widget.settings.textPosY = resetSettings.textPosY;
    widget.settings.textWeight = resetSettings.textWeight;
    widget.settings.titleFont = resetSettings.titleFont;
    widget.settings.titleSize = resetSettings.titleSize;
    widget.settings.titlePosX = resetSettings.titlePosX;
    widget.settings.titlePosY = resetSettings.titlePosY;
    widget.settings.titleWeight = resetSettings.titleWeight;
    widget.settings.subtitleFont = resetSettings.subtitleFont;
    widget.settings.subtitleSize = resetSettings.subtitleSize;
    widget.settings.subtitlePosX = resetSettings.subtitlePosX;
    widget.settings.subtitlePosY = resetSettings.subtitlePosY;
    widget.settings.subtitleWeight = resetSettings.subtitleWeight;
    widget.settings.artistFont = resetSettings.artistFont;
    widget.settings.artistSize = resetSettings.artistSize;
    widget.settings.artistPosX = resetSettings.artistPosX;
    widget.settings.artistPosY = resetSettings.artistPosY;
    widget.settings.artistWeight = resetSettings.artistWeight;
    widget.settings.textFitToWidth = resetSettings.textFitToWidth;
    widget.settings.textHAlign = resetSettings.textHAlign;
    widget.settings.textVAlign = resetSettings.textVAlign;
    widget.settings.textLineHeight = resetSettings.textLineHeight;
    widget.settings.titleFitToWidth = resetSettings.titleFitToWidth;
    widget.settings.titleHAlign = resetSettings.titleHAlign;
    widget.settings.titleVAlign = resetSettings.titleVAlign;
    widget.settings.titleLineHeight = resetSettings.titleLineHeight;
    widget.settings.subtitleFitToWidth = resetSettings.subtitleFitToWidth;
    widget.settings.subtitleHAlign = resetSettings.subtitleHAlign;
    widget.settings.subtitleVAlign = resetSettings.subtitleVAlign;
    widget.settings.subtitleLineHeight = resetSettings.subtitleLineHeight;
    widget.settings.artistFitToWidth = resetSettings.artistFitToWidth;
    widget.settings.artistHAlign = resetSettings.artistHAlign;
    widget.settings.artistVAlign = resetSettings.artistVAlign;
    widget.settings.artistLineHeight = resetSettings.artistLineHeight;

    widget.onSettingsChanged(widget.settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    widget.settings.textEnabled =
        presetData['textEnabled'] ?? widget.settings.textEnabled;
    widget.settings.textTitle =
        presetData['textTitle'] ?? widget.settings.textTitle;
    widget.settings.textSubtitle =
        presetData['textSubtitle'] ?? widget.settings.textSubtitle;
    widget.settings.textArtist =
        presetData['textArtist'] ?? widget.settings.textArtist;
    widget.settings.textFont =
        presetData['textFont'] ?? widget.settings.textFont;
    widget.settings.textSize =
        presetData['textSize'] ?? widget.settings.textSize;
    widget.settings.textPosX =
        presetData['textPosX'] ?? widget.settings.textPosX;
    widget.settings.textPosY =
        presetData['textPosY'] ?? widget.settings.textPosY;
    widget.settings.textWeight =
        presetData['textWeight'] ?? widget.settings.textWeight;
    widget.settings.titleFont =
        presetData['titleFont'] ?? widget.settings.titleFont;
    widget.settings.titleSize =
        presetData['titleSize'] ?? widget.settings.titleSize;
    widget.settings.titlePosX =
        presetData['titlePosX'] ?? widget.settings.titlePosX;
    widget.settings.titlePosY =
        presetData['titlePosY'] ?? widget.settings.titlePosY;
    widget.settings.titleWeight =
        presetData['titleWeight'] ?? widget.settings.titleWeight;
    widget.settings.subtitleFont =
        presetData['subtitleFont'] ?? widget.settings.subtitleFont;
    widget.settings.subtitleSize =
        presetData['subtitleSize'] ?? widget.settings.subtitleSize;
    widget.settings.subtitlePosX =
        presetData['subtitlePosX'] ?? widget.settings.subtitlePosX;
    widget.settings.subtitlePosY =
        presetData['subtitlePosY'] ?? widget.settings.subtitlePosY;
    widget.settings.subtitleWeight =
        presetData['subtitleWeight'] ?? widget.settings.subtitleWeight;
    widget.settings.artistFont =
        presetData['artistFont'] ?? widget.settings.artistFont;
    widget.settings.artistSize =
        presetData['artistSize'] ?? widget.settings.artistSize;
    widget.settings.artistPosX =
        presetData['artistPosX'] ?? widget.settings.artistPosX;
    widget.settings.artistPosY =
        presetData['artistPosY'] ?? widget.settings.artistPosY;
    widget.settings.artistWeight =
        presetData['artistWeight'] ?? widget.settings.artistWeight;
    widget.settings.textFitToWidth =
        presetData['textFitToWidth'] ?? widget.settings.textFitToWidth;
    widget.settings.textHAlign =
        presetData['textHAlign'] ?? widget.settings.textHAlign;
    widget.settings.textVAlign =
        presetData['textVAlign'] ?? widget.settings.textVAlign;
    widget.settings.textLineHeight =
        presetData['textLineHeight'] ?? widget.settings.textLineHeight;
    widget.settings.titleFitToWidth =
        presetData['titleFitToWidth'] ?? widget.settings.titleFitToWidth;
    widget.settings.titleHAlign =
        presetData['titleHAlign'] ?? widget.settings.titleHAlign;
    widget.settings.titleVAlign =
        presetData['titleVAlign'] ?? widget.settings.titleVAlign;
    widget.settings.titleLineHeight =
        presetData['titleLineHeight'] ?? widget.settings.titleLineHeight;
    widget.settings.subtitleFitToWidth =
        presetData['subtitleFitToWidth'] ?? widget.settings.subtitleFitToWidth;
    widget.settings.subtitleHAlign =
        presetData['subtitleHAlign'] ?? widget.settings.subtitleHAlign;
    widget.settings.subtitleVAlign =
        presetData['subtitleVAlign'] ?? widget.settings.subtitleVAlign;
    widget.settings.subtitleLineHeight =
        presetData['subtitleLineHeight'] ?? widget.settings.subtitleLineHeight;
    widget.settings.artistFitToWidth =
        presetData['artistFitToWidth'] ?? widget.settings.artistFitToWidth;
    widget.settings.artistHAlign =
        presetData['artistHAlign'] ?? widget.settings.artistHAlign;
    widget.settings.artistVAlign =
        presetData['artistVAlign'] ?? widget.settings.artistVAlign;
    widget.settings.artistLineHeight =
        presetData['artistLineHeight'] ?? widget.settings.artistLineHeight;

    // If preset has a selected text line, switch to it
    if (presetData['selectedTextLine'] != null) {
      final String textLineName = presetData['selectedTextLine'];
      for (TextLine line in TextLine.values) {
        if (line.toString() == textLineName) {
          setState(() {
            selectedTextLine = line;
          });
          break;
        }
      }
    }

    widget.onSettingsChanged(widget.settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    // Get current text line settings
    String textLine = selectedTextLine.toString();
    Map<String, dynamic> presetData = {
      'textEnabled': widget.settings.textEnabled,
      'selectedTextLine': textLine,
      'textTitle': widget.settings.textTitle,
      'textSubtitle': widget.settings.textSubtitle,
      'textArtist': widget.settings.textArtist,
      'textFont': widget.settings.textFont,
      'textSize': widget.settings.textSize,
      'textPosX': widget.settings.textPosX,
      'textPosY': widget.settings.textPosY,
      'textWeight': widget.settings.textWeight,
      'titleFont': widget.settings.titleFont,
      'titleSize': widget.settings.titleSize,
      'titlePosX': widget.settings.titlePosX,
      'titlePosY': widget.settings.titlePosY,
      'titleWeight': widget.settings.titleWeight,
      'subtitleFont': widget.settings.subtitleFont,
      'subtitleSize': widget.settings.subtitleSize,
      'subtitlePosX': widget.settings.subtitlePosX,
      'subtitlePosY': widget.settings.subtitlePosY,
      'subtitleWeight': widget.settings.subtitleWeight,
      'artistFont': widget.settings.artistFont,
      'artistSize': widget.settings.artistSize,
      'artistPosX': widget.settings.artistPosX,
      'artistPosY': widget.settings.artistPosY,
      'artistWeight': widget.settings.artistWeight,
      'textFitToWidth': widget.settings.textFitToWidth,
      'textHAlign': widget.settings.textHAlign,
      'textVAlign': widget.settings.textVAlign,
      'textLineHeight': widget.settings.textLineHeight,
      'titleFitToWidth': widget.settings.titleFitToWidth,
      'titleHAlign': widget.settings.titleHAlign,
      'titleVAlign': widget.settings.titleVAlign,
      'titleLineHeight': widget.settings.titleLineHeight,
      'subtitleFitToWidth': widget.settings.subtitleFitToWidth,
      'subtitleHAlign': widget.settings.subtitleHAlign,
      'subtitleVAlign': widget.settings.subtitleVAlign,
      'subtitleLineHeight': widget.settings.subtitleLineHeight,
      'artistFitToWidth': widget.settings.artistFitToWidth,
      'artistHAlign': widget.settings.artistHAlign,
      'artistVAlign': widget.settings.artistVAlign,
      'artistLineHeight': widget.settings.artistLineHeight,
    };

    bool success = await PresetsManager.savePreset(aspect, name, presetData);

    if (success) {
      // Update cached presets
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Force refresh of the UI to show the new preset immediately
      _refreshPresets();
    }
  }

  // These will need to be connected to EffectControls static methods
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  static Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    // Delegate to EffectControls
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return _cachedPresets[aspect] ?? {};
  }

  static void _refreshPresets() {
    _refreshCounter++;
  }

  static Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String name,
  ) async {
    final success = await PresetsManager.deletePreset(aspect, name);
    if (success) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return success;
  }
}
