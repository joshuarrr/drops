import 'animation_options.dart';

// Class to store all shader effect settings
class ShaderSettings {
  // Enable flags for each aspect
  bool _colorEnabled;
  bool _blurEnabled;

  // Color settings
  double _hue;
  double _saturation;
  double _lightness;
  double _overlayHue;
  double _overlayIntensity;
  double _overlayOpacity;

  // Blur settings
  double _blurAmount;
  double _blurRadius;

  // Additional shatter settings
  double _blurOpacity; // 0-1 opacity of shatter overlay
  double _blurFacets; // number of facets (1+)
  int _blurBlendMode; // 0=normal,1=multiply,2=screen

  // Animation flag for blur (shatter) effect
  bool _blurAnimated;

  // Animation flag for color effect
  bool _colorAnimated;

  // Animation flag for overlay color
  bool _overlayAnimated;

  // Image setting
  bool _fillScreen;

  // Text settings
  bool _textEnabled;
  String _textTitle;
  String _textSubtitle;
  String _textArtist;
  String _textFont;
  double _textSize;
  double _textPosX;
  double _textPosY;

  // Per-line styling (independent font, size, position)
  String _titleFont;
  double _titleSize;
  double _titlePosX;
  double _titlePosY;

  String _subtitleFont;
  double _subtitleSize;
  double _subtitlePosX;
  double _subtitlePosY;

  String _artistFont;
  double _artistSize;
  double _artistPosX;
  double _artistPosY;

  // Weight settings
  int _textWeight; // 100-900 (default 400)
  int _titleWeight;
  int _subtitleWeight;
  int _artistWeight;

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

  // Flag to control logging
  static bool enableLogging = false;

  // Property getters and setters
  bool get colorEnabled => _colorEnabled;
  set colorEnabled(bool value) {
    _colorEnabled = value;
    if (enableLogging) print("SETTINGS: colorEnabled set to $value");
  }

  bool get blurEnabled => _blurEnabled;
  set blurEnabled(bool value) {
    _blurEnabled = value;
    if (enableLogging) print("SETTINGS: blurEnabled set to $value");
  }

  double get blurAmount => _blurAmount;
  set blurAmount(double value) {
    _blurAmount = value;
    if (enableLogging) {
      print("SETTINGS: blurAmount set to ${value.toStringAsFixed(3)}");
    }
  }

  double get blurRadius => _blurRadius;
  set blurRadius(double value) {
    _blurRadius = value;
    if (enableLogging) {
      print("SETTINGS: blurRadius set to ${value.toStringAsFixed(3)}");
    }
  }

  // Color settings with logging
  double get hue => _hue;
  set hue(double value) {
    _hue = value;
    if (enableLogging) {
      print("SETTINGS: hue set to ${value.toStringAsFixed(3)}");
    }
  }

  double get saturation => _saturation;
  set saturation(double value) {
    _saturation = value;
    if (enableLogging) {
      print("SETTINGS: saturation set to ${value.toStringAsFixed(3)}");
    }
  }

  double get lightness => _lightness;
  set lightness(double value) {
    _lightness = value;
    if (enableLogging) {
      print("SETTINGS: lightness set to ${value.toStringAsFixed(3)}");
    }
  }

  double get overlayHue => _overlayHue;
  set overlayHue(double value) {
    _overlayHue = value;
    if (enableLogging) {
      print("SETTINGS: overlayHue set to ${value.toStringAsFixed(3)}");
    }
  }

  double get overlayIntensity => _overlayIntensity;
  set overlayIntensity(double value) {
    _overlayIntensity = value;
    if (enableLogging) {
      print("SETTINGS: overlayIntensity set to ${value.toStringAsFixed(3)}");
    }
  }

  double get overlayOpacity => _overlayOpacity;
  set overlayOpacity(double value) {
    _overlayOpacity = value;
    if (enableLogging) {
      print("SETTINGS: overlayOpacity set to ${value.toStringAsFixed(3)}");
    }
  }

  // Blur animation toggle with logging
  bool get blurAnimated => _blurAnimated;
  set blurAnimated(bool value) {
    _blurAnimated = value;
    if (enableLogging) print("SETTINGS: blurAnimated set to $value");
  }

  // Color animation toggle with logging
  bool get colorAnimated => _colorAnimated;
  set colorAnimated(bool value) {
    _colorAnimated = value;
    if (enableLogging) print("SETTINGS: colorAnimated set to $value");
  }

  // Overlay animation toggle with logging
  bool get overlayAnimated => _overlayAnimated;
  set overlayAnimated(bool value) {
    _overlayAnimated = value;
    if (enableLogging) print("SETTINGS: overlayAnimated set to $value");
  }

  // New shatter settings with logging
  double get blurOpacity => _blurOpacity;
  set blurOpacity(double value) {
    _blurOpacity = value;
    if (enableLogging) {
      print("SETTINGS: blurOpacity set to ${value.toStringAsFixed(3)}");
    }
  }

  double get blurFacets => _blurFacets;
  set blurFacets(double value) {
    _blurFacets = value;
    if (enableLogging) {
      print("SETTINGS: blurFacets set to ${value.toStringAsFixed(3)}");
    }
  }

  int get blurBlendMode => _blurBlendMode;
  set blurBlendMode(int value) {
    _blurBlendMode = value;
    if (enableLogging) print("SETTINGS: blurBlendMode set to $value");
  }

  bool get fillScreen => _fillScreen;
  set fillScreen(bool value) {
    _fillScreen = value;
    if (enableLogging) print("SETTINGS: fillScreen set to $value");
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

  String get textFont => _textFont;
  set textFont(String value) {
    _textFont = value;
    if (enableLogging) print("SETTINGS: textFont set to $value");
  }

  double get textSize => _textSize;
  set textSize(double value) {
    _textSize = value;
    if (enableLogging) print("SETTINGS: textSize set to $value");
  }

  double get textPosX => _textPosX;
  set textPosX(double value) {
    _textPosX = value;
    if (enableLogging) print("SETTINGS: textPosX set to $value");
  }

  double get textPosY => _textPosY;
  set textPosY(double value) {
    _textPosY = value;
    if (enableLogging) print("SETTINGS: textPosY set to $value");
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

  // ---------------------------------------------------------------------------
  // Independent animation options for HSL and Overlay
  // ---------------------------------------------------------------------------

  AnimationOptions _colorAnimOptions;
  AnimationOptions _overlayAnimOptions;
  AnimationOptions _blurAnimOptions;

  AnimationOptions get colorAnimOptions => _colorAnimOptions;
  set colorAnimOptions(AnimationOptions value) {
    _colorAnimOptions = value;
    if (enableLogging) print("SETTINGS: colorAnimOptions updated");
  }

  AnimationOptions get overlayAnimOptions => _overlayAnimOptions;
  set overlayAnimOptions(AnimationOptions value) {
    _overlayAnimOptions = value;
    if (enableLogging) print("SETTINGS: overlayAnimOptions updated");
  }

  AnimationOptions get blurAnimOptions => _blurAnimOptions;
  set blurAnimOptions(AnimationOptions value) {
    _blurAnimOptions = value;
    if (enableLogging) print("SETTINGS: blurAnimOptions updated");
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

  ShaderSettings({
    // Enable flags
    bool colorEnabled = false,
    bool blurEnabled = false,

    // Color settings
    double hue = 0.0,
    double saturation = 0.0,
    double lightness = 0.0,
    double overlayHue = 0.0,
    double overlayIntensity = 0.0,
    double overlayOpacity = 0.0,

    // Blur settings
    double blurAmount = 0.0,
    double blurRadius = 15.0,

    // Additional shatter defaults
    double blurOpacity = 1.0,
    double blurFacets = 1.0,
    int blurBlendMode = 0,

    // Animation flag
    bool blurAnimated = false,

    // Color animation flag
    bool colorAnimated = false,

    // Overlay animation flag
    bool overlayAnimated = false,

    // Image setting
    bool fillScreen = false,

    // Text defaults
    String textTitle = '',
    String textSubtitle = '',
    String textArtist = '',
    String textFont = 'Roboto',
    double textSize = 0.05,
    double textPosX = 0.1,
    double textPosY = 0.1,

    // New weight defaults
    int textWeight = 400,

    // Independent animation options
    AnimationOptions? colorAnimOptions,
    AnimationOptions? overlayAnimOptions,
    AnimationOptions? blurAnimOptions,

    // Text enabled flag
    bool textEnabled = false,

    // Per-line styling (independent font, size, position)
    String titleFont = '',
    double titleSize = 0.05,
    double titlePosX = 0.1,
    double titlePosY = 0.1,

    String subtitleFont = '',
    double subtitleSize = 0.04,
    double subtitlePosX = 0.1,
    double subtitlePosY = 0.18,

    String artistFont = '',
    double artistSize = 0.035,
    double artistPosX = 0.1,
    double artistPosY = 0.26,

    // Per-line weight defaults
    int titleWeight = 400,
    int subtitleWeight = 400,
    int artistWeight = 400,

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
  }) : _colorEnabled = colorEnabled,
       _blurEnabled = blurEnabled,
       _hue = hue,
       _saturation = saturation,
       _lightness = lightness,
       _overlayHue = overlayHue,
       _overlayIntensity = overlayIntensity,
       _overlayOpacity = overlayOpacity,
       _blurAmount = blurAmount,
       _blurRadius = blurRadius,
       _blurOpacity = blurOpacity,
       _blurFacets = blurFacets,
       _blurBlendMode = blurBlendMode,
       _blurAnimated = blurAnimated,
       _colorAnimated = colorAnimated,
       _overlayAnimated = overlayAnimated,
       _colorAnimOptions = colorAnimOptions ?? AnimationOptions(),
       _overlayAnimOptions = overlayAnimOptions ?? AnimationOptions(),
       _blurAnimOptions = blurAnimOptions ?? AnimationOptions(),
       _fillScreen = fillScreen,
       _textEnabled = textEnabled,
       _textTitle = textTitle,
       _textSubtitle = textSubtitle,
       _textArtist = textArtist,
       _textFont = textFont,
       _textSize = textSize,
       _textPosX = textPosX,
       _textPosY = textPosY,
       _textWeight = textWeight,
       _titleWeight = titleWeight,
       _subtitleWeight = subtitleWeight,
       _artistWeight = artistWeight,
       _titleFont = titleFont,
       _titleSize = titleSize,
       _titlePosX = titlePosX,
       _titlePosY = titlePosY,
       _subtitleFont = subtitleFont,
       _subtitleSize = subtitleSize,
       _subtitlePosX = subtitlePosX,
       _subtitlePosY = subtitlePosY,
       _artistFont = artistFont,
       _artistSize = artistSize,
       _artistPosX = artistPosX,
       _artistPosY = artistPosY,
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
       _artistLineHeight = artistLineHeight {
    if (enableLogging) print("SETTINGS: ShaderSettings initialized");
  }

  // ---------------------------------------------------------------------------
  // Serialization helpers for persistence
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'colorEnabled': _colorEnabled,
      'blurEnabled': _blurEnabled,
      'hue': _hue,
      'saturation': _saturation,
      'lightness': _lightness,
      'overlayHue': _overlayHue,
      'overlayIntensity': _overlayIntensity,
      'overlayOpacity': _overlayOpacity,
      'blurAmount': _blurAmount,
      'blurRadius': _blurRadius,
      'blurOpacity': _blurOpacity,
      'blurFacets': _blurFacets,
      'blurBlendMode': _blurBlendMode,
      'blurAnimated': _blurAnimated,
      'colorAnimated': _colorAnimated,
      'overlayAnimated': _overlayAnimated,
      'colorAnimOptions': _colorAnimOptions.toMap(),
      'overlayAnimOptions': _overlayAnimOptions.toMap(),
      'blurAnimOptions': _blurAnimOptions.toMap(),
      'fillScreen': _fillScreen,
      'textEnabled': _textEnabled,
      'textTitle': _textTitle,
      'textSubtitle': _textSubtitle,
      'textArtist': _textArtist,
      'textFont': _textFont,
      'textSize': _textSize,
      'textPosX': _textPosX,
      'textPosY': _textPosY,
      'textWeight': _textWeight,
      'titleFont': _titleFont,
      'titleSize': _titleSize,
      'titlePosX': _titlePosX,
      'titlePosY': _titlePosY,
      'subtitleFont': _subtitleFont,
      'subtitleSize': _subtitleSize,
      'subtitlePosX': _subtitlePosX,
      'subtitlePosY': _subtitlePosY,
      'artistFont': _artistFont,
      'artistSize': _artistSize,
      'artistPosX': _artistPosX,
      'artistPosY': _artistPosY,
      'titleWeight': _titleWeight,
      'subtitleWeight': _subtitleWeight,
      'artistWeight': _artistWeight,
      'textFitToWidth': _textFitToWidth,
      'textHAlign': _textHAlign,
      'textVAlign': _textVAlign,
      'textLineHeight': _textLineHeight,
      'titleFitToWidth': _titleFitToWidth,
      'titleHAlign': _titleHAlign,
      'titleVAlign': _titleVAlign,
      'titleLineHeight': _titleLineHeight,
      'subtitleFitToWidth': _subtitleFitToWidth,
      'subtitleHAlign': _subtitleHAlign,
      'subtitleVAlign': _subtitleVAlign,
      'subtitleLineHeight': _subtitleLineHeight,
      'artistFitToWidth': _artistFitToWidth,
      'artistHAlign': _artistHAlign,
      'artistVAlign': _artistVAlign,
      'artistLineHeight': _artistLineHeight,
    };
  }

  factory ShaderSettings.fromMap(Map<String, dynamic> map) {
    return ShaderSettings(
      colorEnabled: map['colorEnabled'] as bool? ?? false,
      blurEnabled: map['blurEnabled'] as bool? ?? false,
      hue: (map['hue'] as num?)?.toDouble() ?? 0.0,
      saturation: (map['saturation'] as num?)?.toDouble() ?? 0.0,
      lightness: (map['lightness'] as num?)?.toDouble() ?? 0.0,
      overlayHue: (map['overlayHue'] as num?)?.toDouble() ?? 0.0,
      overlayIntensity: (map['overlayIntensity'] as num?)?.toDouble() ?? 0.0,
      overlayOpacity: (map['overlayOpacity'] as num?)?.toDouble() ?? 0.0,
      blurAmount: (map['blurAmount'] as num?)?.toDouble() ?? 0.0,
      blurRadius: (map['blurRadius'] as num?)?.toDouble() ?? 15.0,
      blurOpacity: (map['blurOpacity'] as num?)?.toDouble() ?? 1.0,
      blurFacets: (map['blurFacets'] as num?)?.toDouble() ?? 1.0,
      blurBlendMode: map['blurBlendMode'] as int? ?? 0,
      blurAnimated: map['blurAnimated'] as bool? ?? false,
      colorAnimated: map['colorAnimated'] as bool? ?? false,
      overlayAnimated: map['overlayAnimated'] as bool? ?? false,
      colorAnimOptions: map.containsKey('colorAnimOptions')
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['colorAnimOptions'] as Map),
            )
          : null,
      overlayAnimOptions: map.containsKey('overlayAnimOptions')
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['overlayAnimOptions'] as Map),
            )
          : null,
      blurAnimOptions: map.containsKey('blurAnimOptions')
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['blurAnimOptions'] as Map),
            )
          : null,
      fillScreen: map['fillScreen'] as bool? ?? false,
      textEnabled: map['textEnabled'] as bool? ?? false,
      textTitle: map['textTitle'] as String? ?? '',
      textSubtitle: map['textSubtitle'] as String? ?? '',
      textArtist: map['textArtist'] as String? ?? '',
      textFont: map['textFont'] as String? ?? 'Roboto',
      textSize: (map['textSize'] as num?)?.toDouble() ?? 0.05,
      textPosX: (map['textPosX'] as num?)?.toDouble() ?? 0.1,
      textPosY: (map['textPosY'] as num?)?.toDouble() ?? 0.1,
      textWeight: (map['textWeight'] as int?) ?? 400,
      titleFont: map['titleFont'] as String? ?? '',
      titleSize: (map['titleSize'] as num?)?.toDouble() ?? 0.05,
      titlePosX: (map['titlePosX'] as num?)?.toDouble() ?? 0.1,
      titlePosY: (map['titlePosY'] as num?)?.toDouble() ?? 0.1,
      subtitleFont: map['subtitleFont'] as String? ?? '',
      subtitleSize: (map['subtitleSize'] as num?)?.toDouble() ?? 0.04,
      subtitlePosX: (map['subtitlePosX'] as num?)?.toDouble() ?? 0.1,
      subtitlePosY: (map['subtitlePosY'] as num?)?.toDouble() ?? 0.18,
      artistFont: map['artistFont'] as String? ?? '',
      artistSize: (map['artistSize'] as num?)?.toDouble() ?? 0.035,
      artistPosX: (map['artistPosX'] as num?)?.toDouble() ?? 0.1,
      artistPosY: (map['artistPosY'] as num?)?.toDouble() ?? 0.26,
      titleWeight: (map['titleWeight'] as int?) ?? 400,
      subtitleWeight: (map['subtitleWeight'] as int?) ?? 400,
      artistWeight: (map['artistWeight'] as int?) ?? 400,
      textFitToWidth: map['textFitToWidth'] as bool? ?? false,
      textHAlign: map['textHAlign'] as int? ?? 0,
      textVAlign: map['textVAlign'] as int? ?? 0,
      textLineHeight: (map['textLineHeight'] as num?)?.toDouble() ?? 1.2,
      titleFitToWidth: map['titleFitToWidth'] as bool? ?? false,
      titleHAlign: map['titleHAlign'] as int? ?? 0,
      titleVAlign: map['titleVAlign'] as int? ?? 0,
      titleLineHeight: (map['titleLineHeight'] as num?)?.toDouble() ?? 1.2,
      subtitleFitToWidth: map['subtitleFitToWidth'] as bool? ?? false,
      subtitleHAlign: map['subtitleHAlign'] as int? ?? 0,
      subtitleVAlign: map['subtitleVAlign'] as int? ?? 0,
      subtitleLineHeight:
          (map['subtitleLineHeight'] as num?)?.toDouble() ?? 1.2,
      artistFitToWidth: map['artistFitToWidth'] as bool? ?? false,
      artistHAlign: map['artistHAlign'] as int? ?? 0,
      artistVAlign: map['artistVAlign'] as int? ?? 0,
      artistLineHeight: (map['artistLineHeight'] as num?)?.toDouble() ?? 1.2,
    );
  }
}
