import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/presets_manager.dart';
import '../../common/font_selector.dart';
import 'value_slider.dart';
import 'alignment_selector.dart';
import 'aspect_panel_header.dart';
import 'text_input_field.dart';
import 'color_picker.dart';
import 'dart:async';
import '../views/effect_controls.dart';

// Enum for identifying each text line (outside class for reuse)
enum TextLine { title, subtitle, artist, lyrics }

extension TextLineExt on TextLine {
  String get label {
    switch (this) {
      case TextLine.title:
        return 'Title';
      case TextLine.subtitle:
        return 'Subtitle';
      case TextLine.artist:
        return 'Artist';
      case TextLine.lyrics:
        return 'Lyrics';
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

        // Add toggle for applying shader effects to text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Apply Shaders to Text',
              style: TextStyle(color: widget.sliderColor, fontSize: 14),
            ),
            Switch(
              value: widget.settings.textfxSettings.applyShaderEffectsToText,
              activeColor: widget.sliderColor,
              onChanged: (value) {
                final updatedSettings = widget.settings;
                updatedSettings.textfxSettings.applyShaderEffectsToText = value;

                // Ensure text effects are enabled if this is enabled
                if (value && !updatedSettings.textfxSettings.textfxEnabled) {
                  updatedSettings.textfxSettings.textfxEnabled = true;
                }

                // Make sure text is enabled too
                if (value && !updatedSettings.textLayoutSettings.textEnabled) {
                  updatedSettings.textLayoutSettings.textEnabled = true;
                }

                widget.onSettingsChanged(updatedSettings);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: widget.sliderColor.withOpacity(0.3)),

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
          isTextEnabled: () => widget.settings.textLayoutSettings.textEnabled,
          enableText: () {
            widget.settings.textLayoutSettings.textEnabled = true;
            widget.onSettingsChanged(widget.settings);
          },
          multiline: selectedTextLine == TextLine.lyrics,
          maxLines: 8,
        ),
        // Add color picker
        ColorPicker(
          key: ValueKey(
            'text_color_${selectedTextLine.toString()}_${_getCurrentColor().value}',
          ),
          label: 'Text Color',
          currentColor: _getCurrentColor(),
          onColorChanged: (color) {
            _setCurrentColor(color);
          },
          textColor: widget.sliderColor,
        ),
        const SizedBox(height: 12),
        FontSelector(
          selectedFont: _getCurrentFont().isEmpty
              ? 'Default'
              : _getCurrentFont(),
          selectedWeight: _toFontWeight(_getCurrentWeight()),
          labelText: 'Font',
          onFontSelected: (font) {
            final selected = font == 'Default' ? '' : font;
            _setCurrentFont(selected);
            if (!widget.settings.textLayoutSettings.textEnabled)
              widget.settings.textLayoutSettings.textEnabled = true;
            widget.onSettingsChanged(widget.settings);
          },
          onWeightSelected: (fw) {
            _setCurrentWeight(_fromFontWeight(fw));
            if (!widget.settings.textLayoutSettings.textEnabled)
              widget.settings.textLayoutSettings.textEnabled = true;
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
                  if (!widget.settings.textLayoutSettings.textEnabled)
                    widget.settings.textLayoutSettings.textEnabled = true;
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
            if (!widget.settings.textLayoutSettings.textEnabled)
              widget.settings.textLayoutSettings.textEnabled = true;
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
            if (!widget.settings.textLayoutSettings.textEnabled)
              widget.settings.textLayoutSettings.textEnabled = true;
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
    if (!widget.settings.textLayoutSettings.textEnabled)
      widget.settings.textLayoutSettings.textEnabled = true;

    // Update the setting value
    setter(value);

    // Ensure the cache is invalidated for immediate visual feedback
    widget.settings.textLayoutSettings.textEnabled = true;

    // Notify the parent widget
    widget.onSettingsChanged(widget.settings);
  }

  // Mapping helpers for the currently selected text line
  String _getCurrentText() {
    String rawText = "";
    switch (selectedTextLine) {
      case TextLine.title:
        rawText = widget.settings.textLayoutSettings.textTitle;
        break;
      case TextLine.subtitle:
        rawText = widget.settings.textLayoutSettings.textSubtitle;
        break;
      case TextLine.artist:
        rawText = widget.settings.textLayoutSettings.textArtist;
        break;
      case TextLine.lyrics:
        rawText = widget.settings.textLayoutSettings.textLyrics;
        break;
    }

    // Fix for the display - we need to show the correctly ordered text
    return rawText;
  }

  void _setCurrentText(String v) {
    // Store the text directly without reversing
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.textTitle = v;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.textSubtitle = v;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.textArtist = v;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.textLyrics = v;
        break;
    }
  }

  String _getCurrentFont() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.textLayoutSettings.titleFont.isNotEmpty
            ? widget.settings.textLayoutSettings.titleFont
            : widget.settings.textLayoutSettings.textFont;
      case TextLine.subtitle:
        return widget.settings.textLayoutSettings.subtitleFont.isNotEmpty
            ? widget.settings.textLayoutSettings.subtitleFont
            : widget.settings.textLayoutSettings.textFont;
      case TextLine.artist:
        return widget.settings.textLayoutSettings.artistFont.isNotEmpty
            ? widget.settings.textLayoutSettings.artistFont
            : widget.settings.textLayoutSettings.textFont;
      case TextLine.lyrics:
        return widget.settings.textLayoutSettings.lyricsFont.isNotEmpty
            ? widget.settings.textLayoutSettings.lyricsFont
            : widget.settings.textLayoutSettings.textFont;
    }
    return widget.settings.textLayoutSettings.textFont;
  }

  void _setCurrentFont(String f) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.titleFont = f;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.subtitleFont = f;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.artistFont = f;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.lyricsFont = f;
        widget.onSettingsChanged(widget.settings);
        break;
    }
  }

  double _getCurrentSize() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.textLayoutSettings.titleSize > 0
            ? widget.settings.textLayoutSettings.titleSize
            : widget.settings.textLayoutSettings.textSize;
      case TextLine.subtitle:
        return widget.settings.textLayoutSettings.subtitleSize > 0
            ? widget.settings.textLayoutSettings.subtitleSize
            : widget.settings.textLayoutSettings.textSize;
      case TextLine.artist:
        return widget.settings.textLayoutSettings.artistSize > 0
            ? widget.settings.textLayoutSettings.artistSize
            : widget.settings.textLayoutSettings.textSize;
      case TextLine.lyrics:
        return widget.settings.textLayoutSettings.lyricsSize > 0
            ? widget.settings.textLayoutSettings.lyricsSize
            : widget.settings.textLayoutSettings.textSize;
    }
    return widget.settings.textLayoutSettings.textSize;
  }

  void _setCurrentSize(double v) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.titleSize = v;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.subtitleSize = v;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.artistSize = v;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.lyricsSize = v;
        break;
    }
  }

  double _getCurrentPosX() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.textLayoutSettings.titlePosX;
      case TextLine.subtitle:
        return widget.settings.textLayoutSettings.subtitlePosX;
      case TextLine.artist:
        return widget.settings.textLayoutSettings.artistPosX;
      case TextLine.lyrics:
        return widget.settings.textLayoutSettings.lyricsPosX;
    }
    return 0.0;
  }

  void _setCurrentPosX(double v) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.titlePosX = v;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.subtitlePosX = v;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.artistPosX = v;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.lyricsPosX = v;
        break;
    }
  }

  double _getCurrentPosY() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.textLayoutSettings.titlePosY;
      case TextLine.subtitle:
        return widget.settings.textLayoutSettings.subtitlePosY;
      case TextLine.artist:
        return widget.settings.textLayoutSettings.artistPosY;
      case TextLine.lyrics:
        return widget.settings.textLayoutSettings.lyricsPosY;
    }
    return 0.0;
  }

  void _setCurrentPosY(double v) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.titlePosY = v;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.subtitlePosY = v;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.artistPosY = v;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.lyricsPosY = v;
        break;
    }
  }

  // -------- Weight helpers ---------
  int _getCurrentWeight() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.textLayoutSettings.titleWeight > 0
            ? widget.settings.textLayoutSettings.titleWeight
            : widget.settings.textLayoutSettings.textWeight;
      case TextLine.subtitle:
        return widget.settings.textLayoutSettings.subtitleWeight > 0
            ? widget.settings.textLayoutSettings.subtitleWeight
            : widget.settings.textLayoutSettings.textWeight;
      case TextLine.artist:
        return widget.settings.textLayoutSettings.artistWeight > 0
            ? widget.settings.textLayoutSettings.artistWeight
            : widget.settings.textLayoutSettings.textWeight;
      case TextLine.lyrics:
        return widget.settings.textLayoutSettings.lyricsWeight > 0
            ? widget.settings.textLayoutSettings.lyricsWeight
            : widget.settings.textLayoutSettings.textWeight;
    }
    return widget.settings.textLayoutSettings.textWeight;
  }

  void _setCurrentWeight(int w) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.titleWeight = w;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.subtitleWeight = w;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.artistWeight = w;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.lyricsWeight = w;
        break;
    }
  }

  // -------- Fit to width helpers ---------
  bool _getCurrentFitToWidth() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.textLayoutSettings.titleFitToWidth;
      case TextLine.subtitle:
        return widget.settings.textLayoutSettings.subtitleFitToWidth;
      case TextLine.artist:
        return widget.settings.textLayoutSettings.artistFitToWidth;
      case TextLine.lyrics:
        return widget.settings.textLayoutSettings.lyricsFitToWidth;
    }
    return false;
  }

  void _setCurrentFitToWidth(bool value) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.titleFitToWidth = value;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.subtitleFitToWidth = value;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.artistFitToWidth = value;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.lyricsFitToWidth = value;
        break;
    }
  }

  // -------- Horizontal alignment helpers ---------
  int _getCurrentHAlign() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.textLayoutSettings.titleHAlign;
      case TextLine.subtitle:
        return widget.settings.textLayoutSettings.subtitleHAlign;
      case TextLine.artist:
        return widget.settings.textLayoutSettings.artistHAlign;
      case TextLine.lyrics:
        return widget.settings.textLayoutSettings.lyricsHAlign;
    }
    return 0; // Default to left
  }

  void _setCurrentHAlign(int value) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.titleHAlign = value;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.subtitleHAlign = value;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.artistHAlign = value;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.lyricsHAlign = value;
        break;
    }
  }

  // -------- Vertical alignment helpers ---------
  int _getCurrentVAlign() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.textLayoutSettings.titleVAlign;
      case TextLine.subtitle:
        return widget.settings.textLayoutSettings.subtitleVAlign;
      case TextLine.artist:
        return widget.settings.textLayoutSettings.artistVAlign;
      case TextLine.lyrics:
        return widget.settings.textLayoutSettings.lyricsVAlign;
    }
    return 0; // Default to top
  }

  void _setCurrentVAlign(int value) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.titleVAlign = value;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.subtitleVAlign = value;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.artistVAlign = value;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.lyricsVAlign = value;
        break;
    }
  }

  // -------- Line height helpers ---------
  double _getCurrentLineHeight() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.textLayoutSettings.titleLineHeight;
      case TextLine.subtitle:
        return widget.settings.textLayoutSettings.subtitleLineHeight;
      case TextLine.artist:
        return widget.settings.textLayoutSettings.artistLineHeight;
      case TextLine.lyrics:
        return widget.settings.textLayoutSettings.lyricsLineHeight;
    }
    return 1.2; // Default line height
  }

  void _setCurrentLineHeight(double value) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.titleLineHeight = value;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.subtitleLineHeight = value;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.artistLineHeight = value;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.lyricsLineHeight = value;
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
      ..textLayoutSettings.textEnabled = false
      ..textLayoutSettings.textTitle = defaults.textLayoutSettings.textTitle
      ..textLayoutSettings.textSubtitle =
          defaults.textLayoutSettings.textSubtitle
      ..textLayoutSettings.textArtist = defaults.textLayoutSettings.textArtist
      ..textLayoutSettings.textLyrics = defaults.textLayoutSettings.textLyrics
      ..textLayoutSettings.textFont = defaults.textLayoutSettings.textFont
      ..textLayoutSettings.textSize = defaults.textLayoutSettings.textSize
      ..textLayoutSettings.textPosX = defaults.textLayoutSettings.textPosX
      ..textLayoutSettings.textPosY = defaults.textLayoutSettings.textPosY
      ..textLayoutSettings.textWeight = defaults.textLayoutSettings.textWeight
      ..textLayoutSettings.textColor = defaults.textLayoutSettings.textColor
      ..textLayoutSettings.titleFont = defaults.textLayoutSettings.titleFont
      ..textLayoutSettings.titleSize = defaults.textLayoutSettings.titleSize
      ..textLayoutSettings.titlePosX = defaults.textLayoutSettings.titlePosX
      ..textLayoutSettings.titlePosY = defaults.textLayoutSettings.titlePosY
      ..textLayoutSettings.titleWeight = defaults.textLayoutSettings.titleWeight
      ..textLayoutSettings.titleColor = defaults.textLayoutSettings.titleColor
      ..textLayoutSettings.subtitleFont =
          defaults.textLayoutSettings.subtitleFont
      ..textLayoutSettings.subtitleSize =
          defaults.textLayoutSettings.subtitleSize
      ..textLayoutSettings.subtitlePosX =
          defaults.textLayoutSettings.subtitlePosX
      ..textLayoutSettings.subtitlePosY =
          defaults.textLayoutSettings.subtitlePosY
      ..textLayoutSettings.subtitleWeight =
          defaults.textLayoutSettings.subtitleWeight
      ..textLayoutSettings.subtitleColor =
          defaults.textLayoutSettings.subtitleColor
      ..textLayoutSettings.artistFont = defaults.textLayoutSettings.artistFont
      ..textLayoutSettings.artistSize = defaults.textLayoutSettings.artistSize
      ..textLayoutSettings.artistPosX = defaults.textLayoutSettings.artistPosX
      ..textLayoutSettings.artistPosY = defaults.textLayoutSettings.artistPosY
      ..textLayoutSettings.artistWeight =
          defaults.textLayoutSettings.artistWeight
      ..textLayoutSettings.artistColor = defaults.textLayoutSettings.artistColor
      ..textLayoutSettings.lyricsFont = defaults.textLayoutSettings.lyricsFont
      ..textLayoutSettings.lyricsSize = defaults.textLayoutSettings.lyricsSize
      ..textLayoutSettings.lyricsPosX = defaults.textLayoutSettings.lyricsPosX
      ..textLayoutSettings.lyricsPosY = defaults.textLayoutSettings.lyricsPosY
      ..textLayoutSettings.lyricsWeight =
          defaults.textLayoutSettings.lyricsWeight
      ..textLayoutSettings.lyricsColor = defaults.textLayoutSettings.lyricsColor
      ..textLayoutSettings.textFitToWidth =
          defaults.textLayoutSettings.textFitToWidth
      ..textLayoutSettings.textHAlign = defaults.textLayoutSettings.textHAlign
      ..textLayoutSettings.textVAlign = defaults.textLayoutSettings.textVAlign
      ..textLayoutSettings.textLineHeight =
          defaults.textLayoutSettings.textLineHeight
      ..textLayoutSettings.titleFitToWidth =
          defaults.textLayoutSettings.titleFitToWidth
      ..textLayoutSettings.titleHAlign = defaults.textLayoutSettings.titleHAlign
      ..textLayoutSettings.titleVAlign = defaults.textLayoutSettings.titleVAlign
      ..textLayoutSettings.titleLineHeight =
          defaults.textLayoutSettings.titleLineHeight
      ..textLayoutSettings.subtitleFitToWidth =
          defaults.textLayoutSettings.subtitleFitToWidth
      ..textLayoutSettings.subtitleHAlign =
          defaults.textLayoutSettings.subtitleHAlign
      ..textLayoutSettings.subtitleVAlign =
          defaults.textLayoutSettings.subtitleVAlign
      ..textLayoutSettings.subtitleLineHeight =
          defaults.textLayoutSettings.subtitleLineHeight
      ..textLayoutSettings.artistFitToWidth =
          defaults.textLayoutSettings.artistFitToWidth
      ..textLayoutSettings.artistHAlign =
          defaults.textLayoutSettings.artistHAlign
      ..textLayoutSettings.artistVAlign =
          defaults.textLayoutSettings.artistVAlign
      ..textLayoutSettings.artistLineHeight =
          defaults.textLayoutSettings.artistLineHeight
      ..textLayoutSettings.lyricsFitToWidth =
          defaults.textLayoutSettings.lyricsFitToWidth
      ..textLayoutSettings.lyricsHAlign =
          defaults.textLayoutSettings.lyricsHAlign
      ..textLayoutSettings.lyricsVAlign =
          defaults.textLayoutSettings.lyricsVAlign
      ..textLayoutSettings.lyricsLineHeight =
          defaults.textLayoutSettings.lyricsLineHeight;

    // Update the original settings object with the reset values
    widget.settings.textLayoutSettings.textEnabled =
        resetSettings.textLayoutSettings.textEnabled;
    widget.settings.textLayoutSettings.textTitle =
        resetSettings.textLayoutSettings.textTitle;
    widget.settings.textLayoutSettings.textSubtitle =
        resetSettings.textLayoutSettings.textSubtitle;
    widget.settings.textLayoutSettings.textArtist =
        resetSettings.textLayoutSettings.textArtist;
    widget.settings.textLayoutSettings.textLyrics =
        resetSettings.textLayoutSettings.textLyrics;
    widget.settings.textLayoutSettings.textFont =
        resetSettings.textLayoutSettings.textFont;
    widget.settings.textLayoutSettings.textSize =
        resetSettings.textLayoutSettings.textSize;
    widget.settings.textLayoutSettings.textPosX =
        resetSettings.textLayoutSettings.textPosX;
    widget.settings.textLayoutSettings.textPosY =
        resetSettings.textLayoutSettings.textPosY;
    widget.settings.textLayoutSettings.textWeight =
        resetSettings.textLayoutSettings.textWeight;
    widget.settings.textLayoutSettings.textColor =
        resetSettings.textLayoutSettings.textColor;
    widget.settings.textLayoutSettings.titleFont =
        resetSettings.textLayoutSettings.titleFont;
    widget.settings.textLayoutSettings.titleSize =
        resetSettings.textLayoutSettings.titleSize;
    widget.settings.textLayoutSettings.titlePosX =
        resetSettings.textLayoutSettings.titlePosX;
    widget.settings.textLayoutSettings.titlePosY =
        resetSettings.textLayoutSettings.titlePosY;
    widget.settings.textLayoutSettings.titleWeight =
        resetSettings.textLayoutSettings.titleWeight;
    widget.settings.textLayoutSettings.titleColor =
        resetSettings.textLayoutSettings.titleColor;
    widget.settings.textLayoutSettings.subtitleFont =
        resetSettings.textLayoutSettings.subtitleFont;
    widget.settings.textLayoutSettings.subtitleSize =
        resetSettings.textLayoutSettings.subtitleSize;
    widget.settings.textLayoutSettings.subtitlePosX =
        resetSettings.textLayoutSettings.subtitlePosX;
    widget.settings.textLayoutSettings.subtitlePosY =
        resetSettings.textLayoutSettings.subtitlePosY;
    widget.settings.textLayoutSettings.subtitleWeight =
        resetSettings.textLayoutSettings.subtitleWeight;
    widget.settings.textLayoutSettings.subtitleColor =
        resetSettings.textLayoutSettings.subtitleColor;
    widget.settings.textLayoutSettings.artistFont =
        resetSettings.textLayoutSettings.artistFont;
    widget.settings.textLayoutSettings.artistSize =
        resetSettings.textLayoutSettings.artistSize;
    widget.settings.textLayoutSettings.artistPosX =
        resetSettings.textLayoutSettings.artistPosX;
    widget.settings.textLayoutSettings.artistPosY =
        resetSettings.textLayoutSettings.artistPosY;
    widget.settings.textLayoutSettings.artistWeight =
        resetSettings.textLayoutSettings.artistWeight;
    widget.settings.textLayoutSettings.artistColor =
        resetSettings.textLayoutSettings.artistColor;
    widget.settings.textLayoutSettings.lyricsFont =
        resetSettings.textLayoutSettings.lyricsFont;
    widget.settings.textLayoutSettings.lyricsSize =
        resetSettings.textLayoutSettings.lyricsSize;
    widget.settings.textLayoutSettings.lyricsPosX =
        resetSettings.textLayoutSettings.lyricsPosX;
    widget.settings.textLayoutSettings.lyricsPosY =
        resetSettings.textLayoutSettings.lyricsPosY;
    widget.settings.textLayoutSettings.lyricsWeight =
        resetSettings.textLayoutSettings.lyricsWeight;
    widget.settings.textLayoutSettings.lyricsColor =
        resetSettings.textLayoutSettings.lyricsColor;
    widget.settings.textLayoutSettings.textFitToWidth =
        resetSettings.textLayoutSettings.textFitToWidth;
    widget.settings.textLayoutSettings.textHAlign =
        resetSettings.textLayoutSettings.textHAlign;
    widget.settings.textLayoutSettings.textVAlign =
        resetSettings.textLayoutSettings.textVAlign;
    widget.settings.textLayoutSettings.textLineHeight =
        resetSettings.textLayoutSettings.textLineHeight;
    widget.settings.textLayoutSettings.titleFitToWidth =
        resetSettings.textLayoutSettings.titleFitToWidth;
    widget.settings.textLayoutSettings.titleHAlign =
        resetSettings.textLayoutSettings.titleHAlign;
    widget.settings.textLayoutSettings.titleVAlign =
        resetSettings.textLayoutSettings.titleVAlign;
    widget.settings.textLayoutSettings.titleLineHeight =
        resetSettings.textLayoutSettings.titleLineHeight;
    widget.settings.textLayoutSettings.subtitleFitToWidth =
        resetSettings.textLayoutSettings.subtitleFitToWidth;
    widget.settings.textLayoutSettings.subtitleHAlign =
        resetSettings.textLayoutSettings.subtitleHAlign;
    widget.settings.textLayoutSettings.subtitleVAlign =
        resetSettings.textLayoutSettings.subtitleVAlign;
    widget.settings.textLayoutSettings.subtitleLineHeight =
        resetSettings.textLayoutSettings.subtitleLineHeight;
    widget.settings.textLayoutSettings.artistFitToWidth =
        resetSettings.textLayoutSettings.artistFitToWidth;
    widget.settings.textLayoutSettings.artistHAlign =
        resetSettings.textLayoutSettings.artistHAlign;
    widget.settings.textLayoutSettings.artistVAlign =
        resetSettings.textLayoutSettings.artistVAlign;
    widget.settings.textLayoutSettings.artistLineHeight =
        resetSettings.textLayoutSettings.artistLineHeight;
    widget.settings.textLayoutSettings.lyricsFitToWidth =
        resetSettings.textLayoutSettings.lyricsFitToWidth;
    widget.settings.textLayoutSettings.lyricsHAlign =
        resetSettings.textLayoutSettings.lyricsHAlign;
    widget.settings.textLayoutSettings.lyricsVAlign =
        resetSettings.textLayoutSettings.lyricsVAlign;
    widget.settings.textLayoutSettings.lyricsLineHeight =
        resetSettings.textLayoutSettings.lyricsLineHeight;

    widget.onSettingsChanged(widget.settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    widget.settings.textLayoutSettings.textEnabled =
        presetData['textEnabled'] ??
        widget.settings.textLayoutSettings.textEnabled;
    widget.settings.textLayoutSettings.textTitle =
        presetData['textTitle'] ?? widget.settings.textLayoutSettings.textTitle;
    widget.settings.textLayoutSettings.textSubtitle =
        presetData['textSubtitle'] ??
        widget.settings.textLayoutSettings.textSubtitle;
    widget.settings.textLayoutSettings.textArtist =
        presetData['textArtist'] ??
        widget.settings.textLayoutSettings.textArtist;
    widget.settings.textLayoutSettings.textLyrics =
        presetData['textLyrics'] ??
        widget.settings.textLayoutSettings.textLyrics;
    widget.settings.textLayoutSettings.textFont =
        presetData['textFont'] ?? widget.settings.textLayoutSettings.textFont;
    widget.settings.textLayoutSettings.textSize =
        presetData['textSize'] ?? widget.settings.textLayoutSettings.textSize;
    widget.settings.textLayoutSettings.textPosX =
        presetData['textPosX'] ?? widget.settings.textLayoutSettings.textPosX;
    widget.settings.textLayoutSettings.textPosY =
        presetData['textPosY'] ?? widget.settings.textLayoutSettings.textPosY;
    widget.settings.textLayoutSettings.textWeight =
        presetData['textWeight'] ??
        widget.settings.textLayoutSettings.textWeight;
    widget.settings.textLayoutSettings.textColor =
        presetData['textColor'] != null
        ? Color(presetData['textColor'])
        : widget.settings.textLayoutSettings.textColor;
    widget.settings.textLayoutSettings.titleFont =
        presetData['titleFont'] ?? widget.settings.textLayoutSettings.titleFont;
    widget.settings.textLayoutSettings.titleSize =
        presetData['titleSize'] ?? widget.settings.textLayoutSettings.titleSize;
    widget.settings.textLayoutSettings.titlePosX =
        presetData['titlePosX'] ?? widget.settings.textLayoutSettings.titlePosX;
    widget.settings.textLayoutSettings.titlePosY =
        presetData['titlePosY'] ?? widget.settings.textLayoutSettings.titlePosY;
    widget.settings.textLayoutSettings.titleWeight =
        presetData['titleWeight'] ??
        widget.settings.textLayoutSettings.titleWeight;
    widget.settings.textLayoutSettings.titleColor =
        presetData['titleColor'] != null
        ? Color(presetData['titleColor'])
        : widget.settings.textLayoutSettings.titleColor;
    widget.settings.textLayoutSettings.subtitleFont =
        presetData['subtitleFont'] ??
        widget.settings.textLayoutSettings.subtitleFont;
    widget.settings.textLayoutSettings.subtitleSize =
        presetData['subtitleSize'] ??
        widget.settings.textLayoutSettings.subtitleSize;
    widget.settings.textLayoutSettings.subtitlePosX =
        presetData['subtitlePosX'] ??
        widget.settings.textLayoutSettings.subtitlePosX;
    widget.settings.textLayoutSettings.subtitlePosY =
        presetData['subtitlePosY'] ??
        widget.settings.textLayoutSettings.subtitlePosY;
    widget.settings.textLayoutSettings.subtitleWeight =
        presetData['subtitleWeight'] ??
        widget.settings.textLayoutSettings.subtitleWeight;
    widget.settings.textLayoutSettings.subtitleColor =
        presetData['subtitleColor'] != null
        ? Color(presetData['subtitleColor'])
        : widget.settings.textLayoutSettings.subtitleColor;
    widget.settings.textLayoutSettings.artistFont =
        presetData['artistFont'] ??
        widget.settings.textLayoutSettings.artistFont;
    widget.settings.textLayoutSettings.artistSize =
        presetData['artistSize'] ??
        widget.settings.textLayoutSettings.artistSize;
    widget.settings.textLayoutSettings.artistPosX =
        presetData['artistPosX'] ??
        widget.settings.textLayoutSettings.artistPosX;
    widget.settings.textLayoutSettings.artistPosY =
        presetData['artistPosY'] ??
        widget.settings.textLayoutSettings.artistPosY;
    widget.settings.textLayoutSettings.artistWeight =
        presetData['artistWeight'] ??
        widget.settings.textLayoutSettings.artistWeight;
    widget.settings.textLayoutSettings.artistColor =
        presetData['artistColor'] != null
        ? Color(presetData['artistColor'])
        : widget.settings.textLayoutSettings.artistColor;
    widget.settings.textLayoutSettings.lyricsFont =
        presetData['lyricsFont'] ??
        widget.settings.textLayoutSettings.lyricsFont;
    widget.settings.textLayoutSettings.lyricsSize =
        presetData['lyricsSize'] ??
        widget.settings.textLayoutSettings.lyricsSize;
    widget.settings.textLayoutSettings.lyricsPosX =
        presetData['lyricsPosX'] ??
        widget.settings.textLayoutSettings.lyricsPosX;
    widget.settings.textLayoutSettings.lyricsPosY =
        presetData['lyricsPosY'] ??
        widget.settings.textLayoutSettings.lyricsPosY;
    widget.settings.textLayoutSettings.lyricsWeight =
        presetData['lyricsWeight'] ??
        widget.settings.textLayoutSettings.lyricsWeight;
    widget.settings.textLayoutSettings.lyricsColor =
        presetData['lyricsColor'] != null
        ? Color(presetData['lyricsColor'])
        : widget.settings.textLayoutSettings.lyricsColor;
    widget.settings.textLayoutSettings.textFitToWidth =
        presetData['textFitToWidth'] ??
        widget.settings.textLayoutSettings.textFitToWidth;
    widget.settings.textLayoutSettings.textHAlign =
        presetData['textHAlign'] ??
        widget.settings.textLayoutSettings.textHAlign;
    widget.settings.textLayoutSettings.textVAlign =
        presetData['textVAlign'] ??
        widget.settings.textLayoutSettings.textVAlign;
    widget.settings.textLayoutSettings.textLineHeight =
        presetData['textLineHeight'] ??
        widget.settings.textLayoutSettings.textLineHeight;
    widget.settings.textLayoutSettings.titleFitToWidth =
        presetData['titleFitToWidth'] ??
        widget.settings.textLayoutSettings.titleFitToWidth;
    widget.settings.textLayoutSettings.titleHAlign =
        presetData['titleHAlign'] ??
        widget.settings.textLayoutSettings.titleHAlign;
    widget.settings.textLayoutSettings.titleVAlign =
        presetData['titleVAlign'] ??
        widget.settings.textLayoutSettings.titleVAlign;
    widget.settings.textLayoutSettings.titleLineHeight =
        presetData['titleLineHeight'] ??
        widget.settings.textLayoutSettings.titleLineHeight;
    widget.settings.textLayoutSettings.subtitleFitToWidth =
        presetData['subtitleFitToWidth'] ??
        widget.settings.textLayoutSettings.subtitleFitToWidth;
    widget.settings.textLayoutSettings.subtitleHAlign =
        presetData['subtitleHAlign'] ??
        widget.settings.textLayoutSettings.subtitleHAlign;
    widget.settings.textLayoutSettings.subtitleVAlign =
        presetData['subtitleVAlign'] ??
        widget.settings.textLayoutSettings.subtitleVAlign;
    widget.settings.textLayoutSettings.subtitleLineHeight =
        presetData['subtitleLineHeight'] ??
        widget.settings.textLayoutSettings.subtitleLineHeight;
    widget.settings.textLayoutSettings.artistFitToWidth =
        presetData['artistFitToWidth'] ??
        widget.settings.textLayoutSettings.artistFitToWidth;
    widget.settings.textLayoutSettings.artistHAlign =
        presetData['artistHAlign'] ??
        widget.settings.textLayoutSettings.artistHAlign;
    widget.settings.textLayoutSettings.artistVAlign =
        presetData['artistVAlign'] ??
        widget.settings.textLayoutSettings.artistVAlign;
    widget.settings.textLayoutSettings.artistLineHeight =
        presetData['artistLineHeight'] ??
        widget.settings.textLayoutSettings.artistLineHeight;
    widget.settings.textLayoutSettings.lyricsFitToWidth =
        presetData['lyricsFitToWidth'] ??
        widget.settings.textLayoutSettings.lyricsFitToWidth;
    widget.settings.textLayoutSettings.lyricsHAlign =
        presetData['lyricsHAlign'] ??
        widget.settings.textLayoutSettings.lyricsHAlign;
    widget.settings.textLayoutSettings.lyricsVAlign =
        presetData['lyricsVAlign'] ??
        widget.settings.textLayoutSettings.lyricsVAlign;
    widget.settings.textLayoutSettings.lyricsLineHeight =
        presetData['lyricsLineHeight'] ??
        widget.settings.textLayoutSettings.lyricsLineHeight;

    // Add support for shader effects toggle
    widget.settings.textfxSettings.applyShaderEffectsToText =
        presetData['applyShaderEffectsToText'] ??
        widget.settings.textfxSettings.applyShaderEffectsToText;

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
      'textEnabled': widget.settings.textLayoutSettings.textEnabled,
      'selectedTextLine': textLine,
      'textTitle': widget.settings.textLayoutSettings.textTitle,
      'textSubtitle': widget.settings.textLayoutSettings.textSubtitle,
      'textArtist': widget.settings.textLayoutSettings.textArtist,
      'textFont': widget.settings.textLayoutSettings.textFont,
      'textSize': widget.settings.textLayoutSettings.textSize,
      'textPosX': widget.settings.textLayoutSettings.textPosX,
      'textPosY': widget.settings.textLayoutSettings.textPosY,
      'textWeight': widget.settings.textLayoutSettings.textWeight,
      'textColor': widget.settings.textLayoutSettings.textColor.value,
      'titleFont': widget.settings.textLayoutSettings.titleFont,
      'titleSize': widget.settings.textLayoutSettings.titleSize,
      'titlePosX': widget.settings.textLayoutSettings.titlePosX,
      'titlePosY': widget.settings.textLayoutSettings.titlePosY,
      'titleWeight': widget.settings.textLayoutSettings.titleWeight,
      'titleColor': widget.settings.textLayoutSettings.titleColor.value,
      'subtitleFont': widget.settings.textLayoutSettings.subtitleFont,
      'subtitleSize': widget.settings.textLayoutSettings.subtitleSize,
      'subtitlePosX': widget.settings.textLayoutSettings.subtitlePosX,
      'subtitlePosY': widget.settings.textLayoutSettings.subtitlePosY,
      'subtitleWeight': widget.settings.textLayoutSettings.subtitleWeight,
      'subtitleColor': widget.settings.textLayoutSettings.subtitleColor.value,
      'artistFont': widget.settings.textLayoutSettings.artistFont,
      'artistSize': widget.settings.textLayoutSettings.artistSize,
      'artistPosX': widget.settings.textLayoutSettings.artistPosX,
      'artistPosY': widget.settings.textLayoutSettings.artistPosY,
      'artistWeight': widget.settings.textLayoutSettings.artistWeight,
      'artistColor': widget.settings.textLayoutSettings.artistColor.value,
      'textFitToWidth': widget.settings.textLayoutSettings.textFitToWidth,
      'textHAlign': widget.settings.textLayoutSettings.textHAlign,
      'textVAlign': widget.settings.textLayoutSettings.textVAlign,
      'textLineHeight': widget.settings.textLayoutSettings.textLineHeight,
      'titleFitToWidth': widget.settings.textLayoutSettings.titleFitToWidth,
      'titleHAlign': widget.settings.textLayoutSettings.titleHAlign,
      'titleVAlign': widget.settings.textLayoutSettings.titleVAlign,
      'titleLineHeight': widget.settings.textLayoutSettings.titleLineHeight,
      'subtitleFitToWidth':
          widget.settings.textLayoutSettings.subtitleFitToWidth,
      'subtitleHAlign': widget.settings.textLayoutSettings.subtitleHAlign,
      'subtitleVAlign': widget.settings.textLayoutSettings.subtitleVAlign,
      'subtitleLineHeight':
          widget.settings.textLayoutSettings.subtitleLineHeight,
      'artistFitToWidth': widget.settings.textLayoutSettings.artistFitToWidth,
      'artistHAlign': widget.settings.textLayoutSettings.artistHAlign,
      'artistVAlign': widget.settings.textLayoutSettings.artistVAlign,
      'artistLineHeight': widget.settings.textLayoutSettings.artistLineHeight,
      'applyShaderEffectsToText':
          widget.settings.textfxSettings.applyShaderEffectsToText,
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
    // Call the central refresh method for immediate UI update
    EffectControls.refreshPresets();
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

  // -------- Color helpers ---------
  Color _getCurrentColor() {
    switch (selectedTextLine) {
      case TextLine.title:
        return widget.settings.textLayoutSettings.titleColor;
      case TextLine.subtitle:
        return widget.settings.textLayoutSettings.subtitleColor;
      case TextLine.artist:
        return widget.settings.textLayoutSettings.artistColor;
      case TextLine.lyrics:
        return widget.settings.textLayoutSettings.lyricsColor;
    }
  }

  void _setCurrentColor(Color color) {
    switch (selectedTextLine) {
      case TextLine.title:
        widget.settings.textLayoutSettings.titleColor = color;
        break;
      case TextLine.subtitle:
        widget.settings.textLayoutSettings.subtitleColor = color;
        break;
      case TextLine.artist:
        widget.settings.textLayoutSettings.artistColor = color;
        break;
      case TextLine.lyrics:
        widget.settings.textLayoutSettings.lyricsColor = color;
        break;
    }
    // Ensure text is enabled and changes are propagated
    widget.settings.textLayoutSettings.textEnabled = true;
    widget.onSettingsChanged(widget.settings);

    // Ensure text color changes don't affect color overlay
    _ensureTextChangesOnly(widget.settings);
  }

  // Helper to ensure text color changes don't inadvertently affect color overlay
  void _ensureTextChangesOnly(ShaderSettings settings) {
    // When using color pickers in Text panel, make sure we don't accidentally
    // enable the color overlay effect. We check if color settings were previously
    // disabled, and preserve that state to avoid unintended overlay effects.
    if (!settings.colorEnabled) {
      // If color effect was disabled, ensure it stays that way
      settings.colorEnabled = false;
    } else {
      // If color was enabled, we need to make sure the overlay settings don't
      // get inadvertently triggered by color changes in text effects

      // Store the current state of overlay settings
      final bool wasOverlayActive =
          settings.colorSettings.overlayOpacity > 0 &&
          settings.colorSettings.overlayIntensity > 0;

      // If overlay wasn't already active, ensure it stays inactive
      if (!wasOverlayActive) {
        // Set overlay intensity/opacity to 0 to prevent inadvertent overlay effects
        settings.colorSettings.overlayOpacity = 0.0;
        settings.colorSettings.overlayIntensity = 0.0;
      }
    }
  }
}
