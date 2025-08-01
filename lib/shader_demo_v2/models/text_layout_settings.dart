import 'package:flutter/material.dart';

class TextLayoutSettings {
  // Enable flag for text
  bool _textEnabled;

  // Image setting
  bool _fillScreen;
  double _fitScreenMargin; // Margin in pixels when using Fit to Screen mode

  // Text content
  String _textTitle;
  String _textSubtitle;
  String _textArtist;
  String _textLyrics = '';

  // Main text settings
  String _textFont;
  double _textSize;
  double _textPosX;
  double _textPosY;
  Color _textColor; // Default text color for all text elements
  int _textWeight; // 100-900 (default 400)

  // Per-line styling (independent font, size, position)
  String _titleFont;
  double _titleSize;
  double _titlePosX;
  double _titlePosY;
  Color _titleColor;
  int _titleWeight;

  String _subtitleFont;
  double _subtitleSize;
  double _subtitlePosX;
  double _subtitlePosY;
  Color _subtitleColor;
  int _subtitleWeight;

  String _artistFont;
  double _artistSize;
  double _artistPosX;
  double _artistPosY;
  Color _artistColor;
  int _artistWeight;

  String _lyricsFont = '';
  double _lyricsSize = 0.03;
  double _lyricsPosX = 0.1;
  double _lyricsPosY = 0.34;
  Color _lyricsColor = Colors.white;
  int _lyricsWeight = 400;

  // Text layout settings
  bool _textFitToWidth; // General setting for all text
  int _textHAlign; // 0=left, 1=center, 2=right
  int _textVAlign; // 0=top, 1=middle, 2=bottom
  double _textLineHeight; // Multiplier for line height (default 1.2)

  // Per-line fit and alignment
  bool _titleFitToWidth;
  int _titleHAlign; // 0=left, 1=center, 2=right
  int _titleVAlign; // 0=top, 1=middle, 2=bottom
  double _titleLineHeight; // Line height multiplier

  bool _subtitleFitToWidth;
  int _subtitleHAlign;
  int _subtitleVAlign;
  double _subtitleLineHeight;

  bool _artistFitToWidth;
  int _artistHAlign;
  int _artistVAlign;
  double _artistLineHeight;

  bool _lyricsFitToWidth = true;
  int _lyricsHAlign = 0;
  int _lyricsVAlign = 0;
  double _lyricsLineHeight = 1.2;

  // Flag to control logging
  static bool enableLogging = false;

  // Helper to safely get a color's value or default to white if null
  int _safeColorValue(Color? color) {
    return color?.value ?? Colors.white.value;
  }

  // Helper to safely get a double value, replacing NaN with a default
  double _safeDoubleValue(double value, double defaultValue) {
    return value.isNaN || value.isInfinite ? defaultValue : value;
  }

  // Image setting getter/setter
  bool get fillScreen => _fillScreen;
  set fillScreen(bool value) {
    _fillScreen = value;
    if (enableLogging) print("SETTINGS: fillScreen set to $value");
  }

  double get fitScreenMargin => _fitScreenMargin;
  set fitScreenMargin(double value) {
    _fitScreenMargin = _safeDoubleValue(value, 0.0);
  }

  // Text getters/setters
  bool get textEnabled => _textEnabled;
  set textEnabled(bool value) {
    _textEnabled = value;
    if (enableLogging) print("SETTINGS: textEnabled set to $value");
  }

  String get textTitle => _textTitle;
  set textTitle(String value) {
    _textTitle = value;
    if (enableLogging) print("SETTINGS: textTitle set to $value");
  }

  String get textSubtitle => _textSubtitle;
  set textSubtitle(String value) {
    _textSubtitle = value;
    if (enableLogging) print("SETTINGS: textSubtitle set to $value");
  }

  String get textArtist => _textArtist;
  set textArtist(String value) {
    _textArtist = value;
    if (enableLogging) print("SETTINGS: textArtist set to $value");
  }

  String get textLyrics => _textLyrics;
  set textLyrics(String value) {
    _textLyrics = value;
    if (enableLogging) print("SETTINGS: textLyrics set to $value");
  }

  String get textFont => _textFont;
  set textFont(String value) {
    _textFont = value;
    if (enableLogging) print("SETTINGS: textFont set to $value");
  }

  double get textSize => _textSize;
  set textSize(double value) {
    _textSize = _safeDoubleValue(value, 0.05);
    if (enableLogging) print("SETTINGS: textSize set to $_textSize");
  }

  double get textPosX => _textPosX;
  set textPosX(double value) {
    _textPosX = _safeDoubleValue(value, 0.1);
    if (enableLogging) print("SETTINGS: textPosX set to $_textPosX");
  }

  double get textPosY => _textPosY;
  set textPosY(double value) {
    _textPosY = _safeDoubleValue(value, 0.1);
    if (enableLogging) print("SETTINGS: textPosY set to $_textPosY");
  }

  // Weight getters/setters
  int get textWeight => _textWeight;
  set textWeight(int v) {
    _textWeight = v;
    if (enableLogging) print("SETTINGS: textWeight set to $v");
  }

  int get titleWeight => _titleWeight;
  set titleWeight(int v) {
    _titleWeight = v;
    if (enableLogging) print("SETTINGS: titleWeight set to $v");
  }

  int get subtitleWeight => _subtitleWeight;
  set subtitleWeight(int v) {
    _subtitleWeight = v;
    if (enableLogging) print("SETTINGS: subtitleWeight set to $v");
  }

  int get artistWeight => _artistWeight;
  set artistWeight(int v) {
    _artistWeight = v;
    if (enableLogging) print("SETTINGS: artistWeight set to $v");
  }

  int get lyricsWeight => _lyricsWeight;
  set lyricsWeight(int v) {
    _lyricsWeight = v;
    if (enableLogging) print("SETTINGS: lyricsWeight set to $v");
  }

  // --------------------- Per-line getters/setters ---------------------
  String get titleFont => _titleFont;
  set titleFont(String v) {
    _titleFont = v;
    if (enableLogging) print("SETTINGS: titleFont set to $v");
  }

  double get titleSize => _titleSize;
  set titleSize(double v) {
    _titleSize = v;
    if (enableLogging) print("SETTINGS: titleSize set to $v");
  }

  double get titlePosX => _titlePosX;
  set titlePosX(double v) {
    _titlePosX = v;
    if (enableLogging) print("SETTINGS: titlePosX set to $v");
  }

  double get titlePosY => _titlePosY;
  set titlePosY(double v) {
    _titlePosY = v;
    if (enableLogging) print("SETTINGS: titlePosY set to $v");
  }

  String get subtitleFont => _subtitleFont;
  set subtitleFont(String v) {
    _subtitleFont = v;
    if (enableLogging) print("SETTINGS: subtitleFont set to $v");
  }

  double get subtitleSize => _subtitleSize;
  set subtitleSize(double v) {
    _subtitleSize = v;
    if (enableLogging) print("SETTINGS: subtitleSize set to $v");
  }

  double get subtitlePosX => _subtitlePosX;
  set subtitlePosX(double v) {
    _subtitlePosX = v;
    if (enableLogging) print("SETTINGS: subtitlePosX set to $v");
  }

  double get subtitlePosY => _subtitlePosY;
  set subtitlePosY(double v) {
    _subtitlePosY = v;
    if (enableLogging) print("SETTINGS: subtitlePosY set to $v");
  }

  String get artistFont => _artistFont;
  set artistFont(String v) {
    _artistFont = v;
    if (enableLogging) print("SETTINGS: artistFont set to $v");
  }

  double get artistSize => _artistSize;
  set artistSize(double v) {
    _artistSize = v;
    if (enableLogging) print("SETTINGS: artistSize set to $v");
  }

  double get artistPosX => _artistPosX;
  set artistPosX(double v) {
    _artistPosX = v;
    if (enableLogging) print("SETTINGS: artistPosX set to $v");
  }

  double get artistPosY => _artistPosY;
  set artistPosY(double v) {
    _artistPosY = v;
    if (enableLogging) print("SETTINGS: artistPosY set to $v");
  }

  String get lyricsFont => _lyricsFont;
  set lyricsFont(String v) {
    _lyricsFont = v;
    if (enableLogging) print("SETTINGS: lyricsFont set to $v");
  }

  double get lyricsSize => _lyricsSize;
  set lyricsSize(double v) {
    _lyricsSize = v;
    if (enableLogging) print("SETTINGS: lyricsSize set to $v");
  }

  double get lyricsPosX => _lyricsPosX;
  set lyricsPosX(double v) {
    _lyricsPosX = v;
    if (enableLogging) print("SETTINGS: lyricsPosX set to $v");
  }

  double get lyricsPosY => _lyricsPosY;
  set lyricsPosY(double v) {
    _lyricsPosY = v;
    if (enableLogging) print("SETTINGS: lyricsPosY set to $v");
  }

  // Text layout getters/setters
  bool get textFitToWidth => _textFitToWidth;
  set textFitToWidth(bool v) {
    _textFitToWidth = v;
    if (enableLogging) print("SETTINGS: textFitToWidth set to $v");
  }

  int get textHAlign => _textHAlign;
  set textHAlign(int v) {
    _textHAlign = v;
    if (enableLogging) print("SETTINGS: textHAlign set to $v");
  }

  int get textVAlign => _textVAlign;
  set textVAlign(int v) {
    _textVAlign = v;
    if (enableLogging) print("SETTINGS: textVAlign set to $v");
  }

  // Title layout
  bool get titleFitToWidth => _titleFitToWidth;
  set titleFitToWidth(bool v) {
    _titleFitToWidth = v;
    if (enableLogging) print("SETTINGS: titleFitToWidth set to $v");
  }

  int get titleHAlign => _titleHAlign;
  set titleHAlign(int v) {
    _titleHAlign = v;
    if (enableLogging) print("SETTINGS: titleHAlign set to $v");
  }

  int get titleVAlign => _titleVAlign;
  set titleVAlign(int v) {
    _titleVAlign = v;
    if (enableLogging) print("SETTINGS: titleVAlign set to $v");
  }

  // Subtitle layout
  bool get subtitleFitToWidth => _subtitleFitToWidth;
  set subtitleFitToWidth(bool v) {
    _subtitleFitToWidth = v;
    if (enableLogging) print("SETTINGS: subtitleFitToWidth set to $v");
  }

  int get subtitleHAlign => _subtitleHAlign;
  set subtitleHAlign(int v) {
    _subtitleHAlign = v;
    if (enableLogging) print("SETTINGS: subtitleHAlign set to $v");
  }

  int get subtitleVAlign => _subtitleVAlign;
  set subtitleVAlign(int v) {
    _subtitleVAlign = v;
    if (enableLogging) print("SETTINGS: subtitleVAlign set to $v");
  }

  // Artist layout
  bool get artistFitToWidth => _artistFitToWidth;
  set artistFitToWidth(bool v) {
    _artistFitToWidth = v;
    if (enableLogging) print("SETTINGS: artistFitToWidth set to $v");
  }

  int get artistHAlign => _artistHAlign;
  set artistHAlign(int v) {
    _artistHAlign = v;
    if (enableLogging) print("SETTINGS: artistHAlign set to $v");
  }

  int get artistVAlign => _artistVAlign;
  set artistVAlign(int v) {
    _artistVAlign = v;
    if (enableLogging) print("SETTINGS: artistVAlign set to $v");
  }

  // Line height getters/setters
  double get textLineHeight => _textLineHeight;
  set textLineHeight(double v) {
    _textLineHeight = v;
    if (enableLogging) print("SETTINGS: textLineHeight set to $v");
  }

  double get titleLineHeight => _titleLineHeight;
  set titleLineHeight(double v) {
    _titleLineHeight = v;
    if (enableLogging) print("SETTINGS: titleLineHeight set to $v");
  }

  double get subtitleLineHeight => _subtitleLineHeight;
  set subtitleLineHeight(double v) {
    _subtitleLineHeight = v;
    if (enableLogging) print("SETTINGS: subtitleLineHeight set to $v");
  }

  double get artistLineHeight => _artistLineHeight;
  set artistLineHeight(double v) {
    _artistLineHeight = v;
    if (enableLogging) print("SETTINGS: artistLineHeight set to $v");
  }

  double get lyricsLineHeight => _lyricsLineHeight;
  set lyricsLineHeight(double v) {
    _lyricsLineHeight = v;
    if (enableLogging) print("SETTINGS: lyricsLineHeight set to $v");
  }

  // Text color getters/setters
  Color get textColor => _textColor;
  set textColor(Color value) {
    _textColor = value;
    if (enableLogging) print("SETTINGS: textColor set to $value");
  }

  Color get titleColor => _titleColor;
  set titleColor(Color value) {
    _titleColor = value;
    if (enableLogging) print("SETTINGS: titleColor set to $value");
  }

  Color get subtitleColor => _subtitleColor;
  set subtitleColor(Color value) {
    _subtitleColor = value;
    if (enableLogging) print("SETTINGS: subtitleColor set to $value");
  }

  Color get artistColor => _artistColor;
  set artistColor(Color value) {
    _artistColor = value;
    if (enableLogging) print("SETTINGS: artistColor set to $value");
  }

  Color get lyricsColor => _lyricsColor;
  set lyricsColor(Color value) {
    _lyricsColor = value;
    if (enableLogging) print("SETTINGS: lyricsColor set to $value");
  }

  // Lyrics layout
  bool get lyricsFitToWidth => _lyricsFitToWidth;
  set lyricsFitToWidth(bool v) {
    _lyricsFitToWidth = v;
    if (enableLogging) print("SETTINGS: lyricsFitToWidth set to $v");
  }

  int get lyricsHAlign => _lyricsHAlign;
  set lyricsHAlign(int v) {
    _lyricsHAlign = v;
    if (enableLogging) print("SETTINGS: lyricsHAlign set to $v");
  }

  int get lyricsVAlign => _lyricsVAlign;
  set lyricsVAlign(int v) {
    _lyricsVAlign = v;
    if (enableLogging) print("SETTINGS: lyricsVAlign set to $v");
  }

  // Variable font width properties (default is 100.0 for normal width)
  double _titleWidth = 100.0;
  double _subtitleWidth = 100.0;
  double _artistWidth = 100.0;
  double _lyricsWidth = 100.0;
  double _textWidth = 100.0;

  // Variable font contrast properties (default is 100.0 for normal contrast)
  double _titleContrast = 100.0;
  double _subtitleContrast = 100.0;
  double _artistContrast = 100.0;
  double _lyricsContrast = 100.0;
  double _textContrast = 100.0;

  TextLayoutSettings({
    bool textEnabled = false,
    bool fillScreen = false,
    double fitScreenMargin = 0.0,

    // Text content
    String textTitle = '',
    String textSubtitle = '',
    String textArtist = '',
    String textLyrics = '',

    // Main text settings
    String textFont = 'Roboto',
    double textSize = 0.05,
    double textPosX = 0.1,
    double textPosY = 0.1,
    Color textColor = Colors.white,
    int textWeight = 400,

    // Per-line styling (independent font, size, position)
    String titleFont = '',
    double titleSize = 0.05,
    double titlePosX = 0.1,
    double titlePosY = 0.1,
    Color titleColor = Colors.white,
    int titleWeight = 400,

    String subtitleFont = '',
    double subtitleSize = 0.04,
    double subtitlePosX = 0.1,
    double subtitlePosY = 0.18,
    Color subtitleColor = Colors.white,
    int subtitleWeight = 400,

    String artistFont = '',
    double artistSize = 0.035,
    double artistPosX = 0.1,
    double artistPosY = 0.26,
    Color artistColor = Colors.white,
    int artistWeight = 400,

    String lyricsFont = '',
    double lyricsSize = 0.03,
    double lyricsPosX = 0.1,
    double lyricsPosY = 0.34,
    Color lyricsColor = Colors.white,
    int lyricsWeight = 400,

    // Text layout defaults
    bool textFitToWidth = false,
    int textHAlign = 0, // left
    int textVAlign = 0, // top
    double textLineHeight = 1.2,

    // Per-line layout defaults
    bool titleFitToWidth = false,
    int titleHAlign = 0,
    int titleVAlign = 0,
    double titleLineHeight = 1.2,

    bool subtitleFitToWidth = false,
    int subtitleHAlign = 0,
    int subtitleVAlign = 0,
    double subtitleLineHeight = 1.2,

    bool artistFitToWidth = false,
    int artistHAlign = 0,
    int artistVAlign = 0,
    double artistLineHeight = 1.2,

    bool lyricsFitToWidth = true,
    int lyricsHAlign = 0,
    int lyricsVAlign = 0,
    double lyricsLineHeight = 1.2,

    // Variable font width properties
    double titleWidth = 100.0,
    double subtitleWidth = 100.0,
    double artistWidth = 100.0,
    double lyricsWidth = 100.0,
    double textWidth = 100.0,

    // Variable font contrast properties
    double titleContrast = 100.0,
    double subtitleContrast = 100.0,
    double artistContrast = 100.0,
    double lyricsContrast = 100.0,
    double textContrast = 100.0,
  }) : _textEnabled = textEnabled,
       _fillScreen = fillScreen,
       _fitScreenMargin = fitScreenMargin,
       _textTitle = textTitle,
       _textSubtitle = textSubtitle,
       _textArtist = textArtist,
       _textLyrics = textLyrics,
       _textFont = textFont,
       _textSize = textSize,
       _textPosX = textPosX,
       _textPosY = textPosY,
       _textColor = textColor,
       _textWeight = textWeight,
       _titleFont = titleFont,
       _titleSize = titleSize,
       _titlePosX = titlePosX,
       _titlePosY = titlePosY,
       _titleColor = titleColor,
       _titleWeight = titleWeight,
       _subtitleFont = subtitleFont,
       _subtitleSize = subtitleSize,
       _subtitlePosX = subtitlePosX,
       _subtitlePosY = subtitlePosY,
       _subtitleColor = subtitleColor,
       _subtitleWeight = subtitleWeight,
       _artistFont = artistFont,
       _artistSize = artistSize,
       _artistPosX = artistPosX,
       _artistPosY = artistPosY,
       _artistColor = artistColor,
       _artistWeight = artistWeight,
       _lyricsFont = lyricsFont,
       _lyricsSize = lyricsSize,
       _lyricsPosX = lyricsPosX,
       _lyricsPosY = lyricsPosY,
       _lyricsColor = lyricsColor,
       _lyricsWeight = lyricsWeight,
       _textFitToWidth = textFitToWidth,
       _textHAlign = textHAlign,
       _textVAlign = textVAlign,
       _textLineHeight = textLineHeight,
       _titleFitToWidth = titleFitToWidth,
       _titleHAlign = titleHAlign,
       _titleVAlign = titleVAlign,
       _titleLineHeight = titleLineHeight,
       _subtitleFitToWidth = subtitleFitToWidth,
       _subtitleHAlign = subtitleHAlign,
       _subtitleVAlign = subtitleVAlign,
       _subtitleLineHeight = subtitleLineHeight,
       _artistFitToWidth = artistFitToWidth,
       _artistHAlign = artistHAlign,
       _artistVAlign = artistVAlign,
       _artistLineHeight = artistLineHeight,
       _lyricsFitToWidth = lyricsFitToWidth,
       _lyricsHAlign = lyricsHAlign,
       _lyricsVAlign = lyricsVAlign,
       _lyricsLineHeight = lyricsLineHeight,
       _titleWidth = titleWidth,
       _subtitleWidth = subtitleWidth,
       _artistWidth = artistWidth,
       _lyricsWidth = lyricsWidth,
       _textWidth = textWidth,
       _titleContrast = titleContrast,
       _subtitleContrast = subtitleContrast,
       _artistContrast = artistContrast,
       _lyricsContrast = lyricsContrast,
       _textContrast = textContrast {
    if (enableLogging) print("SETTINGS: TextLayoutSettings initialized");
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    return {
      'textEnabled': _textEnabled,
      'fillScreen': _fillScreen,
      'fitScreenMargin': _safeDoubleValue(_fitScreenMargin, 0.0),
      'textTitle': _textTitle,
      'textSubtitle': _textSubtitle,
      'textArtist': _textArtist,
      'textLyrics': _textLyrics,
      'textFont': _textFont,
      'textSize': _safeDoubleValue(_textSize, 0.05),
      'textPosX': _safeDoubleValue(_textPosX, 0.1),
      'textPosY': _safeDoubleValue(_textPosY, 0.1),
      'textColor': _safeColorValue(_textColor),
      'textWeight': _textWeight,
      'titleFont': _titleFont,
      'titleSize': _safeDoubleValue(_titleSize, 0.05),
      'titlePosX': _safeDoubleValue(_titlePosX, 0.1),
      'titlePosY': _safeDoubleValue(_titlePosY, 0.1),
      'titleColor': _safeColorValue(_titleColor),
      'subtitleFont': _subtitleFont,
      'subtitleSize': _safeDoubleValue(_subtitleSize, 0.04),
      'subtitlePosX': _safeDoubleValue(_subtitlePosX, 0.1),
      'subtitlePosY': _safeDoubleValue(_subtitlePosY, 0.18),
      'subtitleColor': _safeColorValue(_subtitleColor),
      'artistFont': _artistFont,
      'artistSize': _safeDoubleValue(_artistSize, 0.035),
      'artistPosX': _safeDoubleValue(_artistPosX, 0.1),
      'artistPosY': _safeDoubleValue(_artistPosY, 0.26),
      'artistColor': _safeColorValue(_artistColor),
      'lyricsFont': _lyricsFont,
      'lyricsSize': _safeDoubleValue(_lyricsSize, 0.03),
      'lyricsPosX': _safeDoubleValue(_lyricsPosX, 0.1),
      'lyricsPosY': _safeDoubleValue(_lyricsPosY, 0.34),
      'lyricsColor': _safeColorValue(_lyricsColor),
      'titleWeight': _titleWeight,
      'subtitleWeight': _subtitleWeight,
      'artistWeight': _artistWeight,
      'lyricsWeight': _lyricsWeight,
      'textFitToWidth': _textFitToWidth,
      'textHAlign': _textHAlign,
      'textVAlign': _textVAlign,
      'textLineHeight': _safeDoubleValue(_textLineHeight, 1.2),
      'titleFitToWidth': _titleFitToWidth,
      'titleHAlign': _titleHAlign,
      'titleVAlign': _titleVAlign,
      'titleLineHeight': _safeDoubleValue(_titleLineHeight, 1.2),
      'subtitleFitToWidth': _subtitleFitToWidth,
      'subtitleHAlign': _subtitleHAlign,
      'subtitleVAlign': _subtitleVAlign,
      'subtitleLineHeight': _safeDoubleValue(_subtitleLineHeight, 1.2),
      'artistFitToWidth': _artistFitToWidth,
      'artistHAlign': _artistHAlign,
      'artistVAlign': _artistVAlign,
      'artistLineHeight': _safeDoubleValue(_artistLineHeight, 1.2),
      'lyricsFitToWidth': _lyricsFitToWidth,
      'lyricsHAlign': _lyricsHAlign,
      'lyricsVAlign': _lyricsVAlign,
      'lyricsLineHeight': _safeDoubleValue(_lyricsLineHeight, 1.2),
      'titleWidth': _safeDoubleValue(_titleWidth, 100.0),
      'subtitleWidth': _safeDoubleValue(_subtitleWidth, 100.0),
      'artistWidth': _safeDoubleValue(_artistWidth, 100.0),
      'lyricsWidth': _safeDoubleValue(_lyricsWidth, 100.0),
      'textWidth': _safeDoubleValue(_textWidth, 100.0),
      'titleContrast': _safeDoubleValue(_titleContrast, 100.0),
      'subtitleContrast': _safeDoubleValue(_subtitleContrast, 100.0),
      'artistContrast': _safeDoubleValue(_artistContrast, 100.0),
      'lyricsContrast': _safeDoubleValue(_lyricsContrast, 100.0),
      'textContrast': _safeDoubleValue(_textContrast, 100.0),
    };
  }

  factory TextLayoutSettings.fromMap(Map<String, dynamic> map) {
    return TextLayoutSettings(
      textEnabled: map['textEnabled'] ?? false,
      fillScreen: map['fillScreen'] ?? false,
      fitScreenMargin: map['fitScreenMargin'] ?? 0.0,
      textTitle: map['textTitle'] ?? '',
      textSubtitle: map['textSubtitle'] ?? '',
      textArtist: map['textArtist'] ?? '',
      textLyrics: map['textLyrics'] ?? '',
      textFont: map['textFont'] ?? 'Roboto',
      textSize: map['textSize'] ?? 0.05,
      textPosX: map['textPosX'] ?? 0.1,
      textPosY: map['textPosY'] ?? 0.1,
      textColor: map['textColor'] != null
          ? Color(map['textColor'])
          : Colors.white,
      textWeight: map['textWeight'] ?? 400,
      titleFont: map['titleFont'] ?? '',
      titleSize: map['titleSize'] ?? 0.05,
      titlePosX: map['titlePosX'] ?? 0.1,
      titlePosY: map['titlePosY'] ?? 0.1,
      titleColor: map['titleColor'] != null
          ? Color(map['titleColor'])
          : Colors.white,
      subtitleFont: map['subtitleFont'] ?? '',
      subtitleSize: map['subtitleSize'] ?? 0.04,
      subtitlePosX: map['subtitlePosX'] ?? 0.1,
      subtitlePosY: map['subtitlePosY'] ?? 0.18,
      subtitleColor: map['subtitleColor'] != null
          ? Color(map['subtitleColor'])
          : Colors.white,
      artistFont: map['artistFont'] ?? '',
      artistSize: map['artistSize'] ?? 0.035,
      artistPosX: map['artistPosX'] ?? 0.1,
      artistPosY: map['artistPosY'] ?? 0.26,
      artistColor: map['artistColor'] != null
          ? Color(map['artistColor'])
          : Colors.white,
      lyricsFont: map['lyricsFont'] ?? '',
      lyricsSize: map['lyricsSize'] ?? 0.03,
      lyricsPosX: map['lyricsPosX'] ?? 0.1,
      lyricsPosY: map['lyricsPosY'] ?? 0.34,
      lyricsColor: map['lyricsColor'] != null
          ? Color(map['lyricsColor'])
          : Colors.white,
      titleWeight: map['titleWeight'] ?? 400,
      subtitleWeight: map['subtitleWeight'] ?? 400,
      artistWeight: map['artistWeight'] ?? 400,
      lyricsWeight: map['lyricsWeight'] ?? 400,
      textFitToWidth: map['textFitToWidth'] ?? false,
      textHAlign: map['textHAlign'] ?? 0,
      textVAlign: map['textVAlign'] ?? 0,
      textLineHeight: map['textLineHeight'] ?? 1.2,
      titleFitToWidth: map['titleFitToWidth'] ?? false,
      titleHAlign: map['titleHAlign'] ?? 0,
      titleVAlign: map['titleVAlign'] ?? 0,
      titleLineHeight: map['titleLineHeight'] ?? 1.2,
      subtitleFitToWidth: map['subtitleFitToWidth'] ?? false,
      subtitleHAlign: map['subtitleHAlign'] ?? 0,
      subtitleVAlign: map['subtitleVAlign'] ?? 0,
      subtitleLineHeight: map['subtitleLineHeight'] ?? 1.2,
      artistFitToWidth: map['artistFitToWidth'] ?? false,
      artistHAlign: map['artistHAlign'] ?? 0,
      artistVAlign: map['artistVAlign'] ?? 0,
      artistLineHeight: map['artistLineHeight'] ?? 1.2,
      lyricsFitToWidth: map['lyricsFitToWidth'] ?? true,
      lyricsHAlign: map['lyricsHAlign'] ?? 0,
      lyricsVAlign: map['lyricsVAlign'] ?? 0,
      lyricsLineHeight: map['lyricsLineHeight'] ?? 1.2,
      titleWidth: map['titleWidth'] ?? 100.0,
      subtitleWidth: map['subtitleWidth'] ?? 100.0,
      artistWidth: map['artistWidth'] ?? 100.0,
      lyricsWidth: map['lyricsWidth'] ?? 100.0,
      textWidth: map['textWidth'] ?? 100.0,
      titleContrast: map['titleContrast'] ?? 100.0,
      subtitleContrast: map['subtitleContrast'] ?? 100.0,
      artistContrast: map['artistContrast'] ?? 100.0,
      lyricsContrast: map['lyricsContrast'] ?? 100.0,
      textContrast: map['textContrast'] ?? 100.0,
    );
  }

  // Variable font width getters/setters
  double get titleWidth => _titleWidth;
  set titleWidth(double v) {
    _titleWidth = v;
    if (enableLogging) print("SETTINGS: titleWidth set to $v");
  }

  double get subtitleWidth => _subtitleWidth;
  set subtitleWidth(double v) {
    _subtitleWidth = v;
    if (enableLogging) print("SETTINGS: subtitleWidth set to $v");
  }

  double get artistWidth => _artistWidth;
  set artistWidth(double v) {
    _artistWidth = v;
    if (enableLogging) print("SETTINGS: artistWidth set to $v");
  }

  double get lyricsWidth => _lyricsWidth;
  set lyricsWidth(double v) {
    _lyricsWidth = v;
    if (enableLogging) print("SETTINGS: lyricsWidth set to $v");
  }

  double get textWidth => _textWidth;
  set textWidth(double v) {
    _textWidth = v;
    if (enableLogging) print("SETTINGS: textWidth set to $v");
  }

  // Variable font contrast getters/setters
  double get titleContrast => _titleContrast;
  set titleContrast(double v) {
    _titleContrast = v;
    if (enableLogging) print("SETTINGS: titleContrast set to $v");
  }

  double get subtitleContrast => _subtitleContrast;
  set subtitleContrast(double v) {
    _subtitleContrast = v;
    if (enableLogging) print("SETTINGS: subtitleContrast set to $v");
  }

  double get artistContrast => _artistContrast;
  set artistContrast(double v) {
    _artistContrast = v;
    if (enableLogging) print("SETTINGS: artistContrast set to $v");
  }

  double get lyricsContrast => _lyricsContrast;
  set lyricsContrast(double v) {
    _lyricsContrast = v;
    if (enableLogging) print("SETTINGS: lyricsContrast set to $v");
  }

  double get textContrast => _textContrast;
  set textContrast(double v) {
    _textContrast = v;
    if (enableLogging) print("SETTINGS: textContrast set to $v");
  }
}
