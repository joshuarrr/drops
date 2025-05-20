import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../controllers/effect_controller.dart';
import '../models/effect_settings.dart';
import '../models/text_layout_settings.dart';
import '../models/text_fx_settings.dart';
import '../../theme/custom_fonts.dart';

// Enum for identifying each text line
enum TextLine { title, subtitle, artist, lyrics }

/// Non-interactive overlay that renders the Title / Subtitle / Artist lines on
/// top of the current shader preview.
class TextOverlay extends StatefulWidget {
  final ShaderSettings settings;
  final double animationValue;

  // Static cache reference for direct bust
  static _TextOverlayState? _activeState;

  const TextOverlay({
    Key? key,
    required this.settings,
    required this.animationValue,
  }) : super(key: key);

  // Static method to force a refresh
  static void forceFontRefresh() {
    if (_activeState != null) {
      _activeState!._lastTextOverlaySettings = null;
      _activeState!._cachedTextOverlay = null;
      _activeState!._currentKey = const Uuid().v4();
    }
  }

  @override
  State<TextOverlay> createState() => _TextOverlayState();
}

class _TextOverlayState extends State<TextOverlay> {
  // Memoization variables
  Widget? _cachedTextOverlay;
  ShaderSettings? _lastTextOverlaySettings;
  double? _lastTextOverlayAnimValue;

  // UUID generation for forcing rebuilds
  final _uuid = Uuid();
  String _currentKey = '';

  @override
  void initState() {
    super.initState();
    _currentKey = _uuid.v4();
    TextOverlay._activeState = this; // Register this state
  }

  @override
  void dispose() {
    if (TextOverlay._activeState == this) {
      TextOverlay._activeState = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access settings directly without type annotations
    final textSettings = widget.settings.textLayoutSettings;
    final fxSettings = widget.settings.textfxSettings;

    // Use a ListenableBuilder to listen to changes in TextFXSettings
    return ListenableBuilder(
      listenable: fxSettings,
      builder: (context, _) {
        // Check if settings or animation value have changed
        bool settingsChanged =
            _lastTextOverlaySettings == null ||
            !_areTextSettingsEqual(widget.settings, _lastTextOverlaySettings!);

        // Check if any effect is targeted to text
        bool shouldApplyEffectsToText =
            (widget.settings.colorEnabled &&
                widget.settings.colorSettings.applyToText) ||
            (widget.settings.blurEnabled &&
                widget.settings.blurSettings.applyToText) ||
            (widget.settings.noiseEnabled &&
                widget.settings.noiseSettings.applyToText) ||
            (widget.settings.rainEnabled &&
                widget.settings.rainSettings.applyToText) ||
            (widget.settings.chromaticEnabled &&
                widget.settings.chromaticSettings.applyToText) ||
            (widget.settings.rippleEnabled &&
                widget.settings.rippleSettings.applyToText);

        // Check animation changes if shader effects are applied to text
        bool animationChanged =
            shouldApplyEffectsToText &&
            fxSettings.textfxEnabled &&
            (_lastTextOverlayAnimValue == null ||
                ((widget.settings.colorSettings.colorAnimated &&
                            widget.settings.colorEnabled) ||
                        (widget.settings.blurSettings.blurAnimated &&
                            widget.settings.blurEnabled) ||
                        (widget.settings.noiseSettings.noiseAnimated &&
                            widget.settings.noiseEnabled)) &&
                    (_lastTextOverlayAnimValue! - widget.animationValue).abs() >
                        0.01);

        // Force a rebuild if settings changed
        if (settingsChanged) {
          _currentKey = _uuid.v4();
        }

        // Return cached overlay if available and nothing significant changed
        if (_cachedTextOverlay != null &&
            !settingsChanged &&
            !animationChanged) {
          return _cachedTextOverlay!;
        }

        // Build text overlay stack
        final overlayStack = Stack(children: _buildTextLines());

        // Create and cache the result
        Widget result;
        if (shouldApplyEffectsToText) {
          result = Container(
            key: Key(_currentKey), // Force rebuild with key
            color: Colors.transparent,
            child: RepaintBoundary(
              child: EffectController.applyEffects(
                child: overlayStack,
                settings: widget.settings,
                animationValue: widget.animationValue,
                isTextContent: true,
                preserveTransparency: true,
              ),
            ),
          );
        } else {
          result = Container(
            key: Key(_currentKey), // Force rebuild with key
            color: Colors.transparent,
            child: overlayStack,
          );
        }

        // Update cache
        _cachedTextOverlay = result;
        _lastTextOverlaySettings = ShaderSettings.fromMap(
          widget.settings.toMap(),
        );
        _lastTextOverlayAnimValue = widget.animationValue;

        return result;
      },
    );
  }

  // Helper to check if a font is a variable font
  bool _isVariableFont(String family) {
    return family == CustomFonts.kyivTypeSansFamily ||
        family == CustomFonts.kyivTypeSerifFamily ||
        family == CustomFonts.kyivTypeTitlingFamily;
  }

  // Helper to get width for a specific text line
  double getWidthForLine(TextLine line) {
    final textSettings = widget.settings.textLayoutSettings;
    switch (line) {
      case TextLine.title:
        return textSettings.titleWidth;
      case TextLine.subtitle:
        return textSettings.subtitleWidth;
      case TextLine.artist:
        return textSettings.artistWidth;
      case TextLine.lyrics:
        return textSettings.lyricsWidth;
    }
  }

  // Helper to get contrast for a specific text line
  double getContrastForLine(TextLine line) {
    final textSettings = widget.settings.textLayoutSettings;
    switch (line) {
      case TextLine.title:
        return textSettings.titleContrast;
      case TextLine.subtitle:
        return textSettings.subtitleContrast;
      case TextLine.artist:
        return textSettings.artistContrast;
      case TextLine.lyrics:
        return textSettings.lyricsContrast;
    }
  }

  // Extract the text line building logic to a separate method
  List<Widget> _buildTextLines() {
    final Size screenSize = MediaQuery.of(context).size;
    final textSettings = widget.settings.textLayoutSettings;

    List<Widget> positionedLines = [];

    void addLine({
      required String text,
      required String font,
      required double size,
      required double posX,
      required double posY,
      required int weight,
      required bool fitToWidth,
      required int hAlign,
      required int vAlign,
      required double lineHeight,
      required Color textColor,
    }) {
      if (text.isEmpty) return;

      // Compute appropriate text style for this line
      final double computedSize = size > 0
          ? size * screenSize.width
          : textSettings.textSize * screenSize.width;

      final String family = font.isNotEmpty ? font : textSettings.textFont;

      // Create font variations for variable fonts
      List<ui.FontVariation>? fontVariations;
      if (_isVariableFont(family)) {
        // Get width axis value from settings based on text line
        double widthValue = 100.0; // Default width
        double contrastValue = 100.0; // Default contrast

        // Determine which text line we're dealing with
        TextLine? currentLine;
        switch (text) {
          case String t when t == textSettings.textTitle:
            currentLine = TextLine.title;
            break;
          case String t when t == textSettings.textSubtitle:
            currentLine = TextLine.subtitle;
            break;
          case String t when t == textSettings.textArtist:
            currentLine = TextLine.artist;
            break;
          case String t when t == textSettings.textLyrics:
            currentLine = TextLine.lyrics;
            break;
        }

        if (currentLine != null) {
          widthValue = getWidthForLine(currentLine);
          contrastValue = getContrastForLine(currentLine);
        }

        // For Kyiv Type Titling, map the full contrast range to the limited stops
        if (family == CustomFonts.kyivTypeTitlingFamily) {
          // Map the 1-1000 range to approximate stops at 0, 500, and 1000
          if (contrastValue < 350) {
            contrastValue = 0.0; // Low contrast
          } else if (contrastValue < 650) {
            contrastValue = 500.0; // Medium contrast
          } else {
            contrastValue = 1000.0; // High contrast
          }

          // Also map weight to the correct range for this font
          // Font has named instances at: 0, 200, 350, 500, 700, 840, 1000
          if (weight < 150) {
            weight = 0; // Thin
          } else if (weight < 275) {
            weight = 200; // Light
          } else if (weight < 425) {
            weight = 350; // Regular
          } else if (weight < 600) {
            weight = 500; // Medium
          } else if (weight < 770) {
            weight = 700; // Bold
          } else if (weight < 920) {
            weight = 840; // Heavy
          } else {
            weight = 1000; // Black
          }
        }

        fontVariations = [
          ui.FontVariation('wght', weight.toDouble()),
          // We still apply these variations even if they're not in availableAxes
          // This ensures compatibility with future updates to font files
          ui.FontVariation('wdth', widthValue),
          ui.FontVariation('CONT', contrastValue),
        ];
      }

      TextStyle baseStyle = TextStyle(
        color: textColor,
        fontSize: computedSize,
        fontWeight: _isVariableFont(family) ? null : _toFontWeight(weight),
        fontVariations: fontVariations,
        height: fitToWidth ? lineHeight : null,
      );

      late TextStyle textStyle;
      if (family.isEmpty) {
        textStyle = baseStyle; // Default system font
      } else if (_isVariableFont(family)) {
        // For variable fonts, use fontFamily directly with variations
        textStyle = baseStyle.copyWith(fontFamily: family);
      } else {
        try {
          textStyle = GoogleFonts.getFont(family, textStyle: baseStyle);
        } catch (_) {
          // Fallback to system/default font family
          textStyle = baseStyle.copyWith(fontFamily: family);
        }
      }

      // Apply text effects
      textStyle = _applyTextEffects(textStyle);

      // Define horizontal alignment and width constraints based on fitToWidth
      final TextAlign textAlign = _getTextAlign(hAlign);

      // Calculate horizontal position based on alignment
      double leftPosition = posX * screenSize.width;

      // Calculate container width for text wrapping if fitToWidth is enabled
      double? maxWidth;
      if (fitToWidth) {
        // Use screen width minus the left position to avoid overflow
        maxWidth = screenSize.width - leftPosition;

        // Adjust left position for center/right text alignment with fitToWidth
        if (hAlign == 1) {
          // Center
          leftPosition = screenSize.width / 2;
        } else if (hAlign == 2) {
          // Right
          leftPosition = screenSize.width - 20; // Small padding from right edge
          maxWidth = leftPosition - 20; // Ensure text doesn't go to the edge
        }
      }

      // Create a TextPainter to measure the text for vertical alignment
      final textSpan = TextSpan(text: text, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: textAlign,
        maxLines: fitToWidth ? null : 1,
      );
      textPainter.layout(maxWidth: maxWidth ?? double.infinity);

      // Calculate vertical position based on alignment
      final double topPosition = _getVerticalPosition(
        posY * screenSize.height,
        vAlign,
        textPainter.height,
        computedSize,
      );

      // Create the base text widget with key for stability
      Widget textWidget = Text(
        text,
        key: ValueKey('text_${posX}_${posY}_${text.hashCode}'),
        style: textStyle,
        textAlign: textAlign,
        textDirection: TextDirection.ltr,
        softWrap: fitToWidth,
        overflow: fitToWidth ? TextOverflow.visible : TextOverflow.clip,
      );

      // Wrap in container if using fitToWidth
      if (fitToWidth) {
        textWidget = Container(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          alignment: hAlign == 1
              ? Alignment.center
              : (hAlign == 2 ? Alignment.centerRight : Alignment.centerLeft),
          child: textWidget,
        );
      }

      // Final stable wrapper to isolate repaint boundaries
      textWidget = RepaintBoundary(child: textWidget);

      positionedLines.add(
        Positioned(
          key: ValueKey('pos_${posX}_${posY}_${text.hashCode}'),
          left: hAlign == 1 && fitToWidth ? 0 : leftPosition,
          top: topPosition,
          width: hAlign == 1 && fitToWidth ? screenSize.width : null,
          child: textWidget,
        ),
      );
    }

    // Add each text line with its specific settings
    addLine(
      text: textSettings.textTitle,
      font: textSettings.titleFont,
      size: textSettings.titleSize,
      posX: textSettings.titlePosX,
      posY: textSettings.titlePosY,
      weight: textSettings.titleWeight > 0
          ? textSettings.titleWeight
          : textSettings.textWeight,
      fitToWidth: textSettings.titleFitToWidth,
      hAlign: textSettings.titleHAlign,
      vAlign: textSettings.titleVAlign,
      lineHeight: textSettings.titleLineHeight,
      textColor: textSettings.titleColor,
    );

    addLine(
      text: textSettings.textSubtitle,
      font: textSettings.subtitleFont,
      size: textSettings.subtitleSize,
      posX: textSettings.subtitlePosX,
      posY: textSettings.subtitlePosY,
      weight: textSettings.subtitleWeight > 0
          ? textSettings.subtitleWeight
          : textSettings.textWeight,
      fitToWidth: textSettings.subtitleFitToWidth,
      hAlign: textSettings.subtitleHAlign,
      vAlign: textSettings.subtitleVAlign,
      lineHeight: textSettings.subtitleLineHeight,
      textColor: textSettings.subtitleColor,
    );

    addLine(
      text: textSettings.textArtist,
      font: textSettings.artistFont,
      size: textSettings.artistSize,
      posX: textSettings.artistPosX,
      posY: textSettings.artistPosY,
      weight: textSettings.artistWeight > 0
          ? textSettings.artistWeight
          : textSettings.textWeight,
      fitToWidth: textSettings.artistFitToWidth,
      hAlign: textSettings.artistHAlign,
      vAlign: textSettings.artistVAlign,
      lineHeight: textSettings.artistLineHeight,
      textColor: textSettings.artistColor,
    );

    // Add Lyrics
    addLine(
      text: textSettings.textLyrics,
      font: textSettings.lyricsFont,
      size: textSettings.lyricsSize,
      posX: textSettings.lyricsPosX,
      posY: textSettings.lyricsPosY,
      weight: textSettings.lyricsWeight > 0
          ? textSettings.lyricsWeight
          : textSettings.textWeight,
      fitToWidth: textSettings.lyricsFitToWidth,
      hAlign: textSettings.lyricsHAlign,
      vAlign: textSettings.lyricsVAlign,
      lineHeight: textSettings.lyricsLineHeight,
      textColor: textSettings.lyricsColor,
    );

    return positionedLines;
  }

  // Add method to apply text effects to text styles
  TextStyle _applyTextEffects(TextStyle baseStyle) {
    final fxSettings = widget.settings.textfxSettings;

    if (!fxSettings.textfxEnabled) {
      return baseStyle;
    }

    TextStyle style = baseStyle;
    List<Shadow> shadows = [];

    // Apply shadow if enabled
    if (fxSettings.textShadowEnabled) {
      shadows.add(
        Shadow(
          blurRadius: fxSettings.textShadowBlur,
          color: fxSettings.textShadowColor.withOpacity(
            fxSettings.textShadowOpacity,
          ),
          offset: Offset(
            fxSettings.textShadowOffsetX,
            fxSettings.textShadowOffsetY,
          ),
        ),
      );
    }

    // Apply glow if enabled (multiple shadows with decreasing opacity)
    if (fxSettings.textGlowEnabled) {
      // Create a glow effect with multiple shadows
      final int steps = 5;
      for (int i = 0; i < steps; i++) {
        double intensity = 1.0 - (i / steps);
        shadows.add(
          Shadow(
            color: fxSettings.textGlowColor.withOpacity(
              fxSettings.textGlowOpacity * intensity,
            ),
            blurRadius: fxSettings.textGlowBlur * (i + 1) / steps,
          ),
        );
      }
    }

    // Apply outline if enabled
    if (fxSettings.textOutlineEnabled) {
      // Simulate outline with shadows in 8 directions
      final double offset = fxSettings.textOutlineWidth;
      final Color outlineColor = fxSettings.textOutlineColor;

      // Create outline using multiple shadows
      // First do the corners
      shadows.add(
        Shadow(color: outlineColor, offset: Offset(-offset, -offset)),
      );
      shadows.add(Shadow(color: outlineColor, offset: Offset(-offset, offset)));
      shadows.add(Shadow(color: outlineColor, offset: Offset(offset, -offset)));
      shadows.add(Shadow(color: outlineColor, offset: Offset(offset, offset)));

      // Then do the cardinal directions
      shadows.add(Shadow(color: outlineColor, offset: Offset(-offset, 0)));
      shadows.add(Shadow(color: outlineColor, offset: Offset(0, -offset)));
      shadows.add(Shadow(color: outlineColor, offset: Offset(offset, 0)));
      shadows.add(Shadow(color: outlineColor, offset: Offset(0, offset)));
    }

    // Apply metal effect if enabled
    if (fxSettings.textMetalEnabled) {
      // Create metallic effect with linear gradient foreground
      final baseColor = fxSettings.textMetalBaseColor;
      final shineColor = fxSettings.textMetalShineColor;
      final shine = fxSettings.textMetalShine;

      // More dynamic metal gradient with multiple reflection points
      final darkEdge = _darken(baseColor, 60);
      final darkShadow = _darken(baseColor, 40);
      final shadow = _darken(baseColor, 20);
      final midtone = baseColor;
      final highlight = _brighten(shineColor, 15);
      final brightHighlight = _brighten(shineColor, 50);
      final superBright = _brighten(shineColor, 90);

      // Create a dynamic bevel effect by rotating the gradient slightly
      final double angle = 0.7; // ~40 degrees
      final beginAlignment = Alignment(sin(angle) - 0.5, cos(angle) - 0.5);
      final endAlignment = Alignment(-sin(angle) + 0.5, -cos(angle) + 0.5);

      style = style.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(
            begin: beginAlignment,
            end: endAlignment,
            // More color stops creates more realistic metal look with multiple reflection bands
            colors: [
              darkEdge, // Deep edge shadow for 3D effect
              darkShadow, // Dark edge
              shadow, // Shadow transitioning to metal
              midtone, // Base metal color
              highlight, // First light reflection
              brightHighlight, // Strong highlight
              superBright, // Intense specular highlight
              brightHighlight, // Back to strong highlight
              highlight, // Softer highlight
              midtone, // Return to base
              shadow, // Shadow
            ],
            // More carefully spaced stops for realistic metal banding
            stops: [
              0.0,
              0.1,
              0.2,
              0.35,
              0.45,
              0.48,
              0.5 +
                  (shine *
                      0.05), // Center highlight position affected by intensity
              0.52 + (shine * 0.05),
              0.55 + (shine * 0.1),
              0.7,
              1.0,
            ],
          ).createShader(Rect.fromLTWH(0, 0, 500, 150)),
      );

      // Multiple shadows for better 3D effect and bevel appearance
      // Bottom shadow (main drop shadow)
      shadows.add(
        Shadow(
          color: Colors.black.withOpacity(0.7),
          offset: Offset(1.5, 1.5),
          blurRadius: 2,
        ),
      );

      // Inner darker shadow for depth along bottom/right edge
      shadows.add(
        Shadow(
          color: darkShadow.withOpacity(0.7),
          offset: Offset(0.8, 0.8),
          blurRadius: 0.8,
        ),
      );

      // Top/left highlight for embossed effect
      shadows.add(
        Shadow(
          color: superBright.withOpacity(0.9),
          offset: Offset(-1, -1),
          blurRadius: 0.5,
        ),
      );

      // Subtle secondary highlight
      shadows.add(
        Shadow(
          color: brightHighlight.withOpacity(0.5),
          offset: Offset(-1.5, -1.5),
          blurRadius: 2,
        ),
      );
    }

    // Apply glass effect if enabled
    if (fxSettings.textGlassEnabled) {
      final glassColor = fxSettings.textGlassColor;
      final opacity = fxSettings.textGlassOpacity;
      final blur = fxSettings.textGlassBlur;
      final refraction = fxSettings.textGlassRefraction;

      // Add a series of very soft, offset shadows to simulate refraction
      for (int i = 0; i < 8; i++) {
        final double angle = i * (3.14159 / 4); // Distribute around 360 degrees
        shadows.add(
          Shadow(
            color: glassColor.withOpacity(opacity * 0.05),
            blurRadius: blur * 1.5,
            offset: Offset(
              cos(angle) * blur * 0.2 * refraction,
              sin(angle) * blur * 0.2 * refraction,
            ),
          ),
        );
      }

      // Make the text semi-transparent and add a subtle border
      style = style.copyWith(
        color: style.color?.withOpacity(opacity * 0.8),
        shadows: shadows,
        background: Paint()..color = glassColor.withOpacity(0.15),
      );
    }

    // Apply neon effect if enabled
    if (fxSettings.textNeonEnabled) {
      final neonColor = fxSettings.textNeonColor;
      final outerColor = fxSettings.textNeonOuterColor;
      final intensity = fxSettings.textNeonIntensity;
      final width = fxSettings.textNeonWidth;

      // Inner glow - several tightly packed shadows
      final int innerSteps = 3;
      for (int i = 0; i < innerSteps; i++) {
        shadows.add(
          Shadow(
            color: neonColor.withOpacity(0.8),
            blurRadius: (i + 1) * width * 30,
            offset: Offset.zero,
          ),
        );
      }

      // Outer glow - larger, more diffuse shadows
      final int outerSteps = 3;
      for (int i = 0; i < outerSteps; i++) {
        double step = i + 1;
        shadows.add(
          Shadow(
            color: outerColor.withOpacity(0.5 / step),
            blurRadius: step * width * 50 * intensity,
            offset: Offset.zero,
          ),
        );
      }

      // Set the text color to be the neon color
      style = style.copyWith(color: neonColor);
    }

    // Apply all shadows to the style
    if (shadows.isNotEmpty && style.foreground == null) {
      style = style.copyWith(shadows: shadows);
    }

    return style;
  }

  // Helper functions
  FontWeight _toFontWeight(int w) {
    switch (w) {
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

  TextAlign _getTextAlign(int align) {
    switch (align) {
      case 0:
        return TextAlign.left;
      case 1:
        return TextAlign.center;
      case 2:
        return TextAlign.right;
      default:
        return TextAlign.center;
    }
  }

  double _getVerticalPosition(
    double basePosition,
    int vAlign,
    double textHeight,
    double fontSize,
  ) {
    switch (vAlign) {
      case 0:
        return basePosition; // Top
      case 1:
        return basePosition - (fontSize / 2); // Middle
      case 2:
        return basePosition - textHeight; // Bottom
      default:
        return basePosition;
    }
  }

  Color _darken(Color color, int percent) {
    assert(percent >= 0 && percent <= 100);
    final double factor = 1 - (percent / 100);
    return Color.fromARGB(
      color.alpha,
      (color.red * factor).round().clamp(0, 255),
      (color.green * factor).round().clamp(0, 255),
      (color.blue * factor).round().clamp(0, 255),
    );
  }

  Color _brighten(Color color, int percent) {
    assert(percent >= 0 && percent <= 100);
    final double factor = percent / 100;
    return Color.fromARGB(
      color.alpha,
      (color.red + (255 - color.red) * factor).round().clamp(0, 255),
      (color.green + (255 - color.green) * factor).round().clamp(0, 255),
      (color.blue + (255 - color.blue) * factor).round().clamp(0, 255),
    );
  }

  // Helper to check if text-related settings have changed
  bool _areTextSettingsEqual(ShaderSettings a, ShaderSettings b) {
    // Check main text toggles
    if (a.textLayoutSettings.textEnabled != b.textLayoutSettings.textEnabled ||
        a.textfxSettings.textfxEnabled != b.textfxSettings.textfxEnabled) {
      return false;
    }

    // Check if any effect targeting text has changed by comparing each effect's applyToText flag
    if (a.colorSettings.applyToText != b.colorSettings.applyToText ||
        a.blurSettings.applyToText != b.blurSettings.applyToText ||
        a.noiseSettings.applyToText != b.noiseSettings.applyToText ||
        a.rainSettings.applyToText != b.rainSettings.applyToText ||
        a.chromaticSettings.applyToText != b.chromaticSettings.applyToText ||
        a.rippleSettings.applyToText != b.rippleSettings.applyToText) {
      return false;
    }

    // Check if any effect enabling has changed
    if (a.colorEnabled != b.colorEnabled ||
        a.blurEnabled != b.blurEnabled ||
        a.noiseEnabled != b.noiseEnabled ||
        a.rainEnabled != b.rainEnabled ||
        a.chromaticEnabled != b.chromaticEnabled ||
        a.rippleEnabled != b.rippleEnabled) {
      return false;
    }

    // Check text content
    if (a.textLayoutSettings.textTitle != b.textLayoutSettings.textTitle ||
        a.textLayoutSettings.textSubtitle !=
            b.textLayoutSettings.textSubtitle ||
        a.textLayoutSettings.textArtist != b.textLayoutSettings.textArtist ||
        a.textLayoutSettings.textLyrics != b.textLayoutSettings.textLyrics) {
      return false;
    }

    // Explicitly compare variable font width values with more detailed logging
    if ((a.textLayoutSettings.titleWidth - b.textLayoutSettings.titleWidth)
            .abs() >
        0.1) {
      return false;
    }

    if ((a.textLayoutSettings.subtitleWidth -
                b.textLayoutSettings.subtitleWidth)
            .abs() >
        0.1) {
      return false;
    }

    if ((a.textLayoutSettings.artistWidth - b.textLayoutSettings.artistWidth)
            .abs() >
        0.1) {
      return false;
    }

    if ((a.textLayoutSettings.lyricsWidth - b.textLayoutSettings.lyricsWidth)
            .abs() >
        0.1) {
      return false;
    }

    // Explicitly compare variable font contrast values with more detailed logging
    if ((a.textLayoutSettings.titleContrast -
                b.textLayoutSettings.titleContrast)
            .abs() >
        0.1) {
      return false;
    }

    if ((a.textLayoutSettings.subtitleContrast -
                b.textLayoutSettings.subtitleContrast)
            .abs() >
        0.1) {
      return false;
    }

    if ((a.textLayoutSettings.artistContrast -
                b.textLayoutSettings.artistContrast)
            .abs() >
        0.1) {
      return false;
    }

    if ((a.textLayoutSettings.lyricsContrast -
                b.textLayoutSettings.lyricsContrast)
            .abs() >
        0.1) {
      return false;
    }

    // Check text styling for all text lines
    // Title
    if (a.textLayoutSettings.titleFont != b.textLayoutSettings.titleFont ||
        a.textLayoutSettings.titleSize != b.textLayoutSettings.titleSize ||
        a.textLayoutSettings.titleWeight != b.textLayoutSettings.titleWeight ||
        a.textLayoutSettings.titleColor.value !=
            b.textLayoutSettings.titleColor.value ||
        a.textLayoutSettings.titlePosX != b.textLayoutSettings.titlePosX ||
        a.textLayoutSettings.titlePosY != b.textLayoutSettings.titlePosY ||
        a.textLayoutSettings.titleFitToWidth !=
            b.textLayoutSettings.titleFitToWidth ||
        a.textLayoutSettings.titleHAlign != b.textLayoutSettings.titleHAlign ||
        a.textLayoutSettings.titleVAlign != b.textLayoutSettings.titleVAlign ||
        a.textLayoutSettings.titleLineHeight !=
            b.textLayoutSettings.titleLineHeight) {
      return false;
    }

    // Subtitle
    if (a.textLayoutSettings.subtitleFont !=
            b.textLayoutSettings.subtitleFont ||
        a.textLayoutSettings.subtitleSize !=
            b.textLayoutSettings.subtitleSize ||
        a.textLayoutSettings.subtitleWeight !=
            b.textLayoutSettings.subtitleWeight ||
        a.textLayoutSettings.subtitleColor.value !=
            b.textLayoutSettings.subtitleColor.value ||
        a.textLayoutSettings.subtitlePosX !=
            b.textLayoutSettings.subtitlePosX ||
        a.textLayoutSettings.subtitlePosY !=
            b.textLayoutSettings.subtitlePosY ||
        a.textLayoutSettings.subtitleFitToWidth !=
            b.textLayoutSettings.subtitleFitToWidth ||
        a.textLayoutSettings.subtitleHAlign !=
            b.textLayoutSettings.subtitleHAlign ||
        a.textLayoutSettings.subtitleVAlign !=
            b.textLayoutSettings.subtitleVAlign ||
        a.textLayoutSettings.subtitleLineHeight !=
            b.textLayoutSettings.subtitleLineHeight) {
      return false;
    }

    // Artist
    if (a.textLayoutSettings.artistFont != b.textLayoutSettings.artistFont ||
        a.textLayoutSettings.artistSize != b.textLayoutSettings.artistSize ||
        a.textLayoutSettings.artistWeight !=
            b.textLayoutSettings.artistWeight ||
        a.textLayoutSettings.artistColor.value !=
            b.textLayoutSettings.artistColor.value ||
        a.textLayoutSettings.artistPosX != b.textLayoutSettings.artistPosX ||
        a.textLayoutSettings.artistPosY != b.textLayoutSettings.artistPosY ||
        a.textLayoutSettings.artistFitToWidth !=
            b.textLayoutSettings.artistFitToWidth ||
        a.textLayoutSettings.artistHAlign !=
            b.textLayoutSettings.artistHAlign ||
        a.textLayoutSettings.artistVAlign !=
            b.textLayoutSettings.artistVAlign ||
        a.textLayoutSettings.artistLineHeight !=
            b.textLayoutSettings.artistLineHeight) {
      return false;
    }

    // Lyrics
    if (a.textLayoutSettings.lyricsFont != b.textLayoutSettings.lyricsFont ||
        a.textLayoutSettings.lyricsSize != b.textLayoutSettings.lyricsSize ||
        a.textLayoutSettings.lyricsWeight !=
            b.textLayoutSettings.lyricsWeight ||
        a.textLayoutSettings.lyricsColor.value !=
            b.textLayoutSettings.lyricsColor.value ||
        a.textLayoutSettings.lyricsPosX != b.textLayoutSettings.lyricsPosX ||
        a.textLayoutSettings.lyricsPosY != b.textLayoutSettings.lyricsPosY ||
        a.textLayoutSettings.lyricsFitToWidth !=
            b.textLayoutSettings.lyricsFitToWidth ||
        a.textLayoutSettings.lyricsHAlign !=
            b.textLayoutSettings.lyricsHAlign ||
        a.textLayoutSettings.lyricsVAlign !=
            b.textLayoutSettings.lyricsVAlign ||
        a.textLayoutSettings.lyricsLineHeight !=
            b.textLayoutSettings.lyricsLineHeight) {
      return false;
    }

    // Check general text settings
    if (a.textLayoutSettings.textFont != b.textLayoutSettings.textFont ||
        a.textLayoutSettings.textSize != b.textLayoutSettings.textSize ||
        a.textLayoutSettings.textWeight != b.textLayoutSettings.textWeight ||
        a.textLayoutSettings.textColor.value !=
            b.textLayoutSettings.textColor.value ||
        a.textLayoutSettings.textFitToWidth !=
            b.textLayoutSettings.textFitToWidth ||
        a.textLayoutSettings.textHAlign != b.textLayoutSettings.textHAlign ||
        a.textLayoutSettings.textVAlign != b.textLayoutSettings.textVAlign ||
        a.textLayoutSettings.textLineHeight !=
            b.textLayoutSettings.textLineHeight) {
      return false;
    }

    // Check shader effect settings that apply to text
    // Only check detailed settings for enabled effects that apply to text
    if (a.colorEnabled && a.colorSettings.applyToText) {
      if (a.colorSettings.hue != b.colorSettings.hue ||
          a.colorSettings.saturation != b.colorSettings.saturation ||
          a.colorSettings.lightness != b.colorSettings.lightness) {
        return false;
      }
    }

    if (a.blurEnabled && a.blurSettings.applyToText) {
      if (a.blurSettings.blurAmount != b.blurSettings.blurAmount ||
          a.blurSettings.blurRadius != b.blurSettings.blurRadius ||
          a.blurSettings.blurOpacity != b.blurSettings.blurOpacity ||
          a.blurSettings.blurIntensity != b.blurSettings.blurIntensity ||
          a.blurSettings.blurContrast != b.blurSettings.blurContrast ||
          a.blurSettings.blurBlendMode != b.blurSettings.blurBlendMode) {
        return false;
      }
    }

    if (a.noiseEnabled && a.noiseSettings.applyToText) {
      if (a.noiseSettings.waveAmount != b.noiseSettings.waveAmount ||
          a.noiseSettings.colorIntensity != b.noiseSettings.colorIntensity) {
        return false;
      }
    }

    if (a.rainEnabled && a.rainSettings.applyToText) {
      if (a.rainSettings.rainIntensity != b.rainSettings.rainIntensity ||
          a.rainSettings.dropSize != b.rainSettings.dropSize ||
          a.rainSettings.fallSpeed != b.rainSettings.fallSpeed) {
        return false;
      }
    }

    if (a.chromaticEnabled && a.chromaticSettings.applyToText) {
      if (a.chromaticSettings.amount != b.chromaticSettings.amount ||
          a.chromaticSettings.angle != b.chromaticSettings.angle ||
          a.chromaticSettings.spread != b.chromaticSettings.spread) {
        return false;
      }
    }

    if (a.rippleEnabled && a.rippleSettings.applyToText) {
      if (a.rippleSettings.rippleIntensity !=
              b.rippleSettings.rippleIntensity ||
          a.rippleSettings.rippleSize != b.rippleSettings.rippleSize ||
          a.rippleSettings.rippleSpeed != b.rippleSettings.rippleSpeed) {
        return false;
      }
    }

    // All relevant settings are equal
    return true;
  }
}
