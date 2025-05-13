// Class to store all shader effect settings
class ShaderSettings {
  // Enable flags for each aspect
  bool colorEnabled;
  bool blurEnabled;

  // Color settings
  double hue;
  double saturation;
  double lightness;
  double overlayHue;
  double overlayIntensity;
  double overlayOpacity;

  // Blur settings
  double blurAmount;
  double blurRadius;

  ShaderSettings({
    // Enable flags
    this.colorEnabled = false,
    this.blurEnabled = false,

    // Color settings
    this.hue = 0.0,
    this.saturation = 0.0,
    this.lightness = 0.0,
    this.overlayHue = 0.0,
    this.overlayIntensity = 0.0,
    this.overlayOpacity = 0.0,

    // Blur settings
    this.blurAmount = 0.0,
    this.blurRadius = 15.0,
  });
}
