import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/effect_controller.dart';
import '../models/effect_settings.dart';

/// Non-interactive overlay that renders the Title / Subtitle / Artist lines on
/// top of the current shader preview.
class TextOverlay extends StatelessWidget {
  const TextOverlay({
    super.key,
    required this.settings,
    required this.animationValue,
  });

  /// Full set of shader + layout options. Only a subset is used here, but we
  /// keep the whole object to avoid brittle parameter lists.
  final ShaderSettings settings;

  /// Base animation value taken from the driving AnimationController (0-1).
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    // Create Stack with a transparent background explicitly
    final overlayStack = Stack(
      fit: StackFit.passthrough,
      children: _buildTextLines(context),
    );

    // Performance: render text at lower resolution while applying heavy
    // shaders (blur / shatter) and scale it back up.  This dramatically
    // reduces the number of pixels processed each frame.
    const double _scale = 0.6; // 60 % resolution → ~65 % fewer pixels

    // Only apply shader effects to text if the toggle is enabled AND text effects are enabled
    if (settings.textfxSettings.applyShaderEffectsToText &&
        settings.textfxSettings.textfxEnabled) {
      // Wrap in a transparent container to ensure background transparency is preserved
      // 1. Down-scale before sending into the shader.
      final Widget scaledDown = Transform.scale(
        scale: _scale,
        alignment: Alignment.topLeft,
        child: overlayStack,
      );

      // 2. Clone settings and disable blur animation for text to enable
      //    caching of the expensive shatter pass (huge perf win).
      final ShaderSettings textSettings = ShaderSettings.fromMap(
        settings.toMap(),
      )..blurSettings.blurAnimated = false; // static blur for text

      final Widget processed = EffectController.applyEffects(
        child: scaledDown,
        settings: textSettings,
        animationValue:
            animationValue, // still pass base time, ignored when not animated
        isTextContent: true,
        preserveTransparency: true,
      );

      // 3. Scale the processed result back up to full size.
      return Container(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1 / _scale,
          alignment: Alignment.topLeft,
          child: RepaintBoundary(child: processed),
        ),
      );
    }

    // Ensure the standard stack is also transparent
    return Container(color: Colors.transparent, child: overlayStack);
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  List<Widget> _buildTextLines(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    List<Widget> positionedLines = [];

    // Local helper to map int weight (100-900) to FontWeight constant
    FontWeight toFontWeight(int w) {
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

    // Helper to map horizontal alignment int to TextAlign
    TextAlign getTextAlign(int align) {
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

    double getVerticalPosition(
      double base,
      int vAlign,
      double textHeight,
      double fontSize,
    ) {
      switch (vAlign) {
        case 0:
          return base; // top
        case 1:
          return base - (fontSize / 2); // middle
        case 2:
          return base - textHeight; // bottom
        default:
          return base;
      }
    }

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
      required Color color,
    }) {
      if (text.isEmpty) return;

      final double computedSize = size > 0
          ? size * screenSize.width
          : settings.textLayoutSettings.textSize * screenSize.width;

      final String family = font.isNotEmpty
          ? font
          : settings.textLayoutSettings.textFont;

      TextStyle baseStyle = TextStyle(
        color: color,
        fontSize: computedSize,
        fontWeight: toFontWeight(weight),
        height: fitToWidth ? lineHeight : null,
      );

      // Try to resolve Google Font first, fall back to system if it fails.
      late TextStyle style;
      if (family.isEmpty) {
        style = baseStyle;
      } else {
        try {
          style = GoogleFonts.getFont(family, textStyle: baseStyle);
        } catch (_) {
          style = baseStyle.copyWith(fontFamily: family);
        }
      }

      style = _applyTextEffects(style);

      final TextAlign align = getTextAlign(hAlign);
      double left = posX * screenSize.width;

      double? maxWidth;
      if (fitToWidth) {
        maxWidth = screenSize.width - left;
        if (hAlign == 1) {
          left = screenSize.width / 2;
        } else if (hAlign == 2) {
          left = screenSize.width - 20;
          maxWidth = left - 20;
        }
      }

      final textSpan = TextSpan(text: text, style: style);
      final painter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: align,
        maxLines: fitToWidth ? null : 1,
      )..layout(maxWidth: maxWidth ?? double.infinity);

      final double top = getVerticalPosition(
        posY * screenSize.height,
        vAlign,
        painter.height,
        computedSize,
      );

      Widget line = Text(
        text,
        key: ValueKey('tl_${posX}_${posY}_${text.hashCode}'),
        style: style,
        textAlign: align,
        textDirection: TextDirection.ltr,
        softWrap: fitToWidth,
        overflow: fitToWidth ? TextOverflow.visible : TextOverflow.clip,
      );

      if (fitToWidth) {
        line = Container(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          alignment: hAlign == 1
              ? Alignment.center
              : (hAlign == 2 ? Alignment.centerRight : Alignment.centerLeft),
          child: line,
        );
      }

      line = RepaintBoundary(child: line);

      positionedLines.add(
        Positioned(
          left: hAlign == 1 && fitToWidth ? 0 : left,
          top: top,
          width: hAlign == 1 && fitToWidth ? screenSize.width : null,
          child: line,
        ),
      );
    }

    // Title
    addLine(
      text: settings.textLayoutSettings.textTitle,
      font: settings.textLayoutSettings.titleFont,
      size: settings.textLayoutSettings.titleSize,
      posX: settings.textLayoutSettings.titlePosX,
      posY: settings.textLayoutSettings.titlePosY,
      weight: settings.textLayoutSettings.titleWeight > 0
          ? settings.textLayoutSettings.titleWeight
          : settings.textLayoutSettings.textWeight,
      fitToWidth: settings.textLayoutSettings.titleFitToWidth,
      hAlign: settings.textLayoutSettings.titleHAlign,
      vAlign: settings.textLayoutSettings.titleVAlign,
      lineHeight: settings.textLayoutSettings.titleLineHeight,
      color: settings.textLayoutSettings.titleColor,
    );

    // Subtitle
    addLine(
      text: settings.textLayoutSettings.textSubtitle,
      font: settings.textLayoutSettings.subtitleFont,
      size: settings.textLayoutSettings.subtitleSize,
      posX: settings.textLayoutSettings.subtitlePosX,
      posY: settings.textLayoutSettings.subtitlePosY,
      weight: settings.textLayoutSettings.subtitleWeight > 0
          ? settings.textLayoutSettings.subtitleWeight
          : settings.textLayoutSettings.textWeight,
      fitToWidth: settings.textLayoutSettings.subtitleFitToWidth,
      hAlign: settings.textLayoutSettings.subtitleHAlign,
      vAlign: settings.textLayoutSettings.subtitleVAlign,
      lineHeight: settings.textLayoutSettings.subtitleLineHeight,
      color: settings.textLayoutSettings.subtitleColor,
    );

    // Artist
    addLine(
      text: settings.textLayoutSettings.textArtist,
      font: settings.textLayoutSettings.artistFont,
      size: settings.textLayoutSettings.artistSize,
      posX: settings.textLayoutSettings.artistPosX,
      posY: settings.textLayoutSettings.artistPosY,
      weight: settings.textLayoutSettings.artistWeight > 0
          ? settings.textLayoutSettings.artistWeight
          : settings.textLayoutSettings.textWeight,
      fitToWidth: settings.textLayoutSettings.artistFitToWidth,
      hAlign: settings.textLayoutSettings.artistHAlign,
      vAlign: settings.textLayoutSettings.artistVAlign,
      lineHeight: settings.textLayoutSettings.artistLineHeight,
      color: settings.textLayoutSettings.artistColor,
    );

    return positionedLines;
  }

  // ---------------------------------------------------------------------------
  // Text effect utilities (copied from original implementation)
  // ---------------------------------------------------------------------------

  TextStyle _applyTextEffects(TextStyle base) {
    final fx = settings.textfxSettings;
    // If text effects are not enabled, return the base style unmodified
    if (!fx.textfxEnabled) return base;

    // Continue with normal text effects application
    TextStyle style = base;
    List<Shadow> shadows = [];

    // Shadow
    if (fx.textShadowEnabled) {
      shadows.add(
        Shadow(
          blurRadius: fx.textShadowBlur,
          color: fx.textShadowColor.withOpacity(fx.textShadowOpacity),
          offset: Offset(fx.textShadowOffsetX, fx.textShadowOffsetY),
        ),
      );
    }

    // Glow
    if (fx.textGlowEnabled) {
      const int steps = 5;
      for (int i = 0; i < steps; i++) {
        final double intensity = 1 - (i / steps);
        shadows.add(
          Shadow(
            color: fx.textGlowColor.withOpacity(fx.textGlowOpacity * intensity),
            blurRadius: fx.textGlowBlur * (i + 1) / steps,
          ),
        );
      }
    }

    // Outline
    if (fx.textOutlineEnabled) {
      final double offset = fx.textOutlineWidth;
      final c = fx.textOutlineColor;
      shadows.addAll([
        Shadow(color: c, offset: Offset(-offset, -offset)),
        Shadow(color: c, offset: Offset(-offset, offset)),
        Shadow(color: c, offset: Offset(offset, -offset)),
        Shadow(color: c, offset: Offset(offset, offset)),
        Shadow(color: c, offset: Offset(-offset, 0)),
        Shadow(color: c, offset: Offset(0, -offset)),
        Shadow(color: c, offset: Offset(offset, 0)),
        Shadow(color: c, offset: Offset(0, offset)),
      ]);
    }

    // Metal effect – identical to original implementation
    if (fx.textMetalEnabled) {
      final baseColor = fx.textMetalBaseColor;
      final shineColor = fx.textMetalShineColor;
      final shine = fx.textMetalShine;

      Color darken(Color c, int p) {
        final f = 1 - (p / 100);
        return Color.fromARGB(
          c.alpha,
          (c.red * f).round().clamp(0, 255),
          (c.green * f).round().clamp(0, 255),
          (c.blue * f).round().clamp(0, 255),
        );
      }

      Color brighten(Color c, int p) {
        final f = p / 100;
        return Color.fromARGB(
          c.alpha,
          (c.red + (255 - c.red) * f).round().clamp(0, 255),
          (c.green + (255 - c.green) * f).round().clamp(0, 255),
          (c.blue + (255 - c.blue) * f).round().clamp(0, 255),
        );
      }

      final darkEdge = darken(baseColor, 60);
      final darkShadow = darken(baseColor, 40);
      final shadow = darken(baseColor, 20);
      final mid = baseColor;
      final highlight = brighten(shineColor, 15);
      final bright = brighten(shineColor, 50);
      final superBright = brighten(shineColor, 90);

      final double angle = 0.7;
      final begin = Alignment(sin(angle) - 0.5, cos(angle) - 0.5);
      final end = Alignment(-sin(angle) + 0.5, -cos(angle) + 0.5);

      style = style.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(
            begin: begin,
            end: end,
            colors: [
              darkEdge,
              darkShadow,
              shadow,
              mid,
              highlight,
              bright,
              superBright,
              bright,
              highlight,
              mid,
              shadow,
            ],
            stops: [
              0.0,
              0.1,
              0.2,
              0.35,
              0.45,
              0.48,
              0.5 + (shine * 0.05),
              0.52 + (shine * 0.05),
              0.55 + (shine * 0.1),
              0.7,
              1.0,
            ],
          ).createShader(Rect.fromLTWH(0, 0, 500, 150)),
      );

      shadows.addAll([
        Shadow(
          color: Colors.black.withOpacity(0.7),
          offset: const Offset(1.5, 1.5),
          blurRadius: 2,
        ),
        Shadow(
          color: darkShadow.withOpacity(0.7),
          offset: const Offset(0.8, 0.8),
          blurRadius: 0.8,
        ),
        Shadow(
          color: superBright.withOpacity(0.9),
          offset: const Offset(-1, -1),
          blurRadius: 0.5,
        ),
        Shadow(
          color: bright.withOpacity(0.5),
          offset: const Offset(-1.5, -1.5),
          blurRadius: 2,
        ),
      ]);
    }

    // Glass
    if (fx.textGlassEnabled) {
      final c = fx.textGlassColor;
      final opacity = fx.textGlassOpacity;
      final blur = fx.textGlassBlur;
      final refr = fx.textGlassRefraction;
      for (int i = 0; i < 8; i++) {
        final ang = i * (pi / 4);
        shadows.add(
          Shadow(
            color: c.withOpacity(opacity * 0.05),
            blurRadius: blur * 1.5,
            offset: Offset(
              cos(ang) * blur * 0.2 * refr,
              sin(ang) * blur * 0.2 * refr,
            ),
          ),
        );
      }
      style = style.copyWith(
        color: style.color?.withOpacity(opacity * 0.8),
        shadows: shadows,
        background: Paint()..color = c.withOpacity(0.15),
      );
    }

    // Neon
    if (fx.textNeonEnabled) {
      final neon = fx.textNeonColor;
      final outer = fx.textNeonOuterColor;
      final intensity = fx.textNeonIntensity;
      final width = fx.textNeonWidth;

      for (int i = 0; i < 3; i++) {
        shadows.add(
          Shadow(
            color: neon.withOpacity(0.8),
            blurRadius: (i + 1) * width * 30,
          ),
        );
      }
      for (int i = 0; i < 3; i++) {
        final step = i + 1;
        shadows.add(
          Shadow(
            color: outer.withOpacity(0.5 / step),
            blurRadius: step * width * 50 * intensity,
          ),
        );
      }
      style = style.copyWith(color: neon);
    }

    if (shadows.isNotEmpty && style.foreground == null) {
      style = style.copyWith(shadows: shadows);
    }

    return style;
  }
}
