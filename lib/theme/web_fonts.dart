import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'custom_fonts.dart';

/// Helper class for injecting web fonts CSS into the document
class WebFonts {
  /// Initialize web fonts by injecting CSS
  static void initialize() {
    if (kIsWeb) {
      _preloadFonts();
      _injectFontCss();
    }
  }

  /// Preload fonts to improve rendering
  static void _preloadFonts() {
    try {
      CustomFonts.fontUrls.forEach((fontFamily, url) {
        // Create a preload link element for each font
        final linkElement = html.LinkElement()
          ..rel = 'preload'
          ..href = url
          ..as = url.endsWith('.woff') ? 'font' : 'font'
          ..type = url.endsWith('.woff') ? 'font/woff' : 'font/ttf'
          ..crossOrigin = 'anonymous';

        html.document.head!.append(linkElement);
      });

      js.context.callMethod('console.log', ['Font preloading started']);
    } catch (e) {
      js.context.callMethod('console.error', ['Font preload error: $e']);
    }
  }

  /// Inject the CSS for the web fonts
  static void _injectFontCss() {
    try {
      // Create a style element
      final styleElement = html.StyleElement();

      // Add the font-face CSS
      styleElement.text = CustomFonts.getFontFaceCss();

      // Insert it into the head
      html.document.head!.append(styleElement);

      // Create a div to force downloading fonts
      final forceFontLoad = html.DivElement()
        ..id = 'font-preloader'
        ..style.opacity = '0'
        ..style.position = 'absolute'
        ..style.pointerEvents = 'none';

      // Add elements with each custom font to force load
      CustomFonts.fontUrls.keys.forEach((fontFamily) {
        forceFontLoad.append(
          html.SpanElement()
            ..style.fontFamily = fontFamily
            ..text = 'preload',
        );
      });

      html.document.body!.append(forceFontLoad);

      // Log that fonts were initialized
      js.context.callMethod('console.log', ['Web fonts CSS initialized']);
    } catch (e) {
      js.context.callMethod('console.error', ['Font CSS injection error: $e']);
    }
  }
}
