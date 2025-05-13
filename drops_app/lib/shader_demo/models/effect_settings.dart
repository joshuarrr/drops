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

  // Image setting
  bool _fillScreen;

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
    if (enableLogging)
      print("SETTINGS: blurAmount set to ${value.toStringAsFixed(3)}");
  }

  double get blurRadius => _blurRadius;
  set blurRadius(double value) {
    _blurRadius = value;
    if (enableLogging)
      print("SETTINGS: blurRadius set to ${value.toStringAsFixed(3)}");
  }

  // Color settings with logging
  double get hue => _hue;
  set hue(double value) {
    _hue = value;
    if (enableLogging)
      print("SETTINGS: hue set to ${value.toStringAsFixed(3)}");
  }

  double get saturation => _saturation;
  set saturation(double value) {
    _saturation = value;
    if (enableLogging)
      print("SETTINGS: saturation set to ${value.toStringAsFixed(3)}");
  }

  double get lightness => _lightness;
  set lightness(double value) {
    _lightness = value;
    if (enableLogging)
      print("SETTINGS: lightness set to ${value.toStringAsFixed(3)}");
  }

  double get overlayHue => _overlayHue;
  set overlayHue(double value) {
    _overlayHue = value;
    if (enableLogging)
      print("SETTINGS: overlayHue set to ${value.toStringAsFixed(3)}");
  }

  double get overlayIntensity => _overlayIntensity;
  set overlayIntensity(double value) {
    _overlayIntensity = value;
    if (enableLogging)
      print("SETTINGS: overlayIntensity set to ${value.toStringAsFixed(3)}");
  }

  double get overlayOpacity => _overlayOpacity;
  set overlayOpacity(double value) {
    _overlayOpacity = value;
    if (enableLogging)
      print("SETTINGS: overlayOpacity set to ${value.toStringAsFixed(3)}");
  }

  // Blur animation toggle with logging
  bool get blurAnimated => _blurAnimated;
  set blurAnimated(bool value) {
    _blurAnimated = value;
    if (enableLogging) print("SETTINGS: blurAnimated set to $value");
  }

  // New shatter settings with logging
  double get blurOpacity => _blurOpacity;
  set blurOpacity(double value) {
    _blurOpacity = value;
    if (enableLogging)
      print("SETTINGS: blurOpacity set to ${value.toStringAsFixed(3)}");
  }

  double get blurFacets => _blurFacets;
  set blurFacets(double value) {
    _blurFacets = value;
    if (enableLogging)
      print("SETTINGS: blurFacets set to ${value.toStringAsFixed(3)}");
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

    // Image setting
    bool fillScreen = false,
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
       _fillScreen = fillScreen {
    if (enableLogging) print("SETTINGS: ShaderSettings initialized");
  }
}
