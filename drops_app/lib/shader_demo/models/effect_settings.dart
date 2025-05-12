// Class to store wave effect settings
class WaveSettings {
  double intensity;
  double speed;

  WaveSettings({this.intensity = 0.5, this.speed = 0.5});
}

// Class to store color effect settings
class ColorSettings {
  double hue;
  double saturation;
  double lightness;
  double overlayHue;
  double overlayIntensity;
  double overlayOpacity;

  ColorSettings({
    this.hue = 0.0,
    this.saturation = 0.0,
    this.lightness = 0.0,
    this.overlayHue = 0.0,
    this.overlayIntensity = 0.0,
    this.overlayOpacity = 0.0,
  });
}

// Class to store pixelate/blur effect settings
class PixelateSettings {
  double blurAmount;
  double blurQuality;

  PixelateSettings({this.blurAmount = 0.0, this.blurQuality = 0.0});
}
