import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/presets_manager.dart';
import '../models/image_category.dart';
import '../../common/font_selector.dart';
import '../widgets/aspect_toggle.dart';
import '../widgets/presets_bar.dart';
import '../widgets/color_panel.dart';
import '../widgets/blur_panel.dart';
import '../widgets/image_panel.dart';
import '../widgets/text_panel.dart';
import '../widgets/noise_panel.dart';
import '../widgets/text_fx_panel.dart';
import '../widgets/rain_panel.dart';
import '../widgets/chromatic_panel.dart';
import '../widgets/ripple_panel.dart';
import '../widgets/music_panel.dart';
import '../controllers/effect_controller.dart';
import '../controllers/music_controller.dart';
import 'dart:io';
import 'dart:math';
import '../widgets/cymatics_panel.dart';

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

class EffectControls {
  // Control logging verbosity - set this to false to disable logs
  static bool enableLogging = false;
  static const String _logTag = 'EffectControls';

  // Custom log function that uses both dart:developer and debugPrint for visibility
  static void _log(String message, {LogLevel level = LogLevel.info}) {
    if (!enableLogging) return;

    if (level == LogLevel.debug &&
        EffectLogger.currentLevel.index > LogLevel.debug.index) {
      return; // Skip debug logs if we're at a higher level
    }

    // Use the new logger
    EffectLogger.log(message, level: level);
  }

  // Selected text line for editing (shared across rebuilds)
  static TextLine selectedTextLine = TextLine.title;

  // Whether the font selector overlay is visible.
  static bool fontSelectorOpen = false;

  // New variable to track presets
  static Map<ShaderAspect, Map<String, dynamic>> cachedPresets = {};

  // Add a counter to force refresh of preset bar
  static int presetsRefreshCounter = 0;

  // Store list of music tracks
  static List<String> musicTracks = [];

  // Reference to the music controller
  static MusicController? _musicController;

  // Debug function to provide information about the music controller state
  static Map<String, dynamic> Function()? debugMusicControllerState;

  // Initialize music controller
  static void initMusicController({
    required ShaderSettings settings,
    required Function(ShaderSettings) onSettingsChanged,
  }) {
    _log('Initializing music controller');
    _musicController = MusicController.getInstance(
      settings: settings,
      onSettingsChanged: onSettingsChanged,
    );

    // Initialize the debug function
    debugMusicControllerState = () {
      if (_musicController == null) {
        return {'state': 'Not initialized', 'source': 'None'};
      }

      // Get the detailed player state information using the new method
      try {
        return _musicController!.getDebugInfo();
      } catch (e) {
        return {
          'state': _musicController!.isPlaying() ? 'playing' : 'paused',
          'source': _musicController!.currentTrack,
          'duration': _musicController!
              .getCurrentSettings()
              .musicSettings
              .duration,
          'position': _musicController!
              .getCurrentSettings()
              .musicSettings
              .playbackPosition,
          'enabled': _musicController!.getMusicEnabledState(),
          'error': e.toString(),
        };
      }
    };
  }

  // Method for cleaning up music resources during hot restart
  static void cleanupMusicResources() {
    _log('Cleaning up music resources for hot restart');
    if (_musicController != null) {
      pauseMusic();
      _musicController?.dispose();
      _musicController = null;
    }
  }

  // Function to load music tracks from assets folder or directory
  static Future<List<String>> loadMusicTracks(
    String directory, {
    Function(List<String>)? onTracksLoaded,
  }) async {
    _log('Loading music tracks from directory: $directory');

    if (_musicController == null) {
      _log('Music controller not initialized', level: LogLevel.warning);
      return [];
    }

    try {
      final tracks = await _musicController!.loadTracks(directory);
      musicTracks = tracks;

      if (tracks.isNotEmpty) {
        _log('Loaded ${tracks.length} music tracks');

        // If there's a callback, notify with the loaded tracks
        onTracksLoaded?.call(tracks);
      } else {
        _log('No music tracks found', level: LogLevel.warning);
      }

      return tracks;
    } catch (e) {
      _log('Error loading music tracks: $e', level: LogLevel.error);
      return [];
    }
  }

  // Music control methods that will be passed to the MusicPanel
  static void playMusic() {
    _log('Play music requested');
    if (_musicController == null) {
      _log('Music controller not initialized', level: LogLevel.warning);
      return;
    }

    // Check if music is enabled
    if (!_musicController!.getMusicEnabledState()) {
      _log('Music is disabled, cannot play', level: LogLevel.warning);
      return; // Don't auto-enable music, let the aspect toggle control that
    }

    if (musicTracks.isEmpty) {
      _log('No music tracks available', level: LogLevel.warning);
      return;
    }

    // Check if there's a track selected
    final bool hasTrack = _musicController!.hasTrackSelected();
    _log('Has track selected: $hasTrack');

    // If no track is selected, set the first one from our list
    if (!hasTrack && musicTracks.isNotEmpty) {
      _log('No track selected, selecting first track: ${musicTracks[0]}');
      selectMusicTrack(musicTracks[0]);
    } else {
      // Track is already selected, just play it
      _log(
        'Playing currently selected track: ${_musicController!.currentTrack}',
      );
      _musicController?.play();
    }
  }

  static void pauseMusic() {
    _log('Pause music requested');

    if (_musicController == null) {
      _log('Music controller not initialized', level: LogLevel.warning);
      return;
    }

    // Force pause regardless of what the controller thinks is the current state
    // This ensures the UI and actual playback state stay in sync
    _log('Pausing audio playback');
    _musicController?.pause();

    // Always update the settings to reflect paused state
    final updatedSettings = _musicController!.getCurrentSettings();
    updatedSettings.musicSettings.isPlaying = false;
    _musicController!.onSettingsChanged(updatedSettings);
  }

  static void seekMusic(double position) {
    _log('Seek music requested: $position seconds');
    _musicController?.seek(position);
  }

  static void selectMusicTrack(String track) {
    _log('Select music track requested: $track');
    if (_musicController == null) {
      _log('Music controller not initialized', level: LogLevel.warning);
      return;
    }

    if (track.isEmpty) {
      _log('Empty track path provided', level: LogLevel.warning);
      return;
    }

    // Ensure the track exists in our list
    if (!musicTracks.contains(track) && musicTracks.isNotEmpty) {
      _log(
        'Track not found in available tracks, using first available track instead',
        level: LogLevel.warning,
      );
      track = musicTracks[0];
    }

    // CRITICAL FIX: Make sure we have a valid track in musicTracks
    if (musicTracks.isEmpty) {
      _log(
        'Music tracks list is empty, trying to add current track',
        level: LogLevel.warning,
      );
      musicTracks.add(track);
    }

    // Check the current musicEnabled state in the copy we have access to
    final bool musicEnabled = _musicController!.getMusicEnabledState();
    final bool wasPlaying = _musicController!.isPlaying();

    _log(
      'Selecting track: $track (music enabled: $musicEnabled, was playing: $wasPlaying)',
    );

    // CRITICAL FIX: Always update settings with the current track first
    final updatedSettings = _musicController!.getCurrentSettings();
    updatedSettings.musicSettings.currentTrack = track;
    _musicController!.onSettingsChanged(updatedSettings);

    if (musicEnabled) {
      // If music is enabled, fully switch tracks (will stop current and play new)
      _musicController!.selectTrack(track);
    } else {
      // If music is disabled, just update the selection without playing
      _musicController!.updateTrackWithoutPlaying(track);
    }
  }

  // Add a method to set volume directly on the controller
  static void setMusicVolume(double volume) {
    _log('Set volume requested: $volume');
    _musicController?.setVolume(volume);
  }

  // Add a method to load presets for a specific aspect
  static Future<Map<String, dynamic>> loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    _log('Loading presets for aspect: $aspect', level: LogLevel.debug);
    if (!cachedPresets.containsKey(aspect)) {
      cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      _log('Loaded ${cachedPresets[aspect]?.length ?? 0} presets for $aspect');
    }
    return cachedPresets[aspect] ?? {};
  }

  // Force a refresh of preset bars
  static void refreshPresets() {
    presetsRefreshCounter++;
    _log(
      'Refreshing presets, counter: $presetsRefreshCounter',
      level: LogLevel.debug,
    );
  }

  // Delete a preset from storage, update the in-memory cache, and report success
  static Future<bool> deletePresetAndUpdate(
    ShaderAspect aspect,
    String name,
  ) async {
    _log('Deleting preset: $name for aspect $aspect');
    final success = await PresetsManager.deletePreset(aspect, name);
    if (success) {
      _log('Successfully deleted preset: $name');
      cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    } else {
      _log('Failed to delete preset: $name', level: LogLevel.warning);
    }
    return success;
  }

  // Load font choices via the shared FontUtils helper so the logic is
  // centralized and can be reused by other widgets as well.
  static Future<List<String>> getFontChoices() {
    return FontUtils.loadFontFamilies();
  }

  // Build controls for toggling and configuring shader aspects
  static Widget buildAspectToggleBar({
    required ShaderSettings settings,
    required Function(ShaderAspect, bool) onAspectToggled,
    required Function(ShaderAspect) onAspectSelected,
    required bool isCurrentImageDark,
    required bool hidden,
  }) {
    _log(
      'Building aspect toggle bar. Color enabled: ${settings.colorEnabled}, TextFX enabled: ${settings.textfxSettings.textfxEnabled}',
      level: LogLevel.debug,
    );

    return AnimatedSlide(
      offset: hidden ? const Offset(0, -1.2) : Offset.zero,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: hidden ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            // Music toggle first
            AspectToggle(
              aspect: ShaderAspect.music,
              isEnabled: settings.musicEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log('Music aspect toggled: $enabled', level: LogLevel.debug);
                onAspectToggled(aspect, enabled);

                // If music is being disabled, pause playback
                if (!enabled && settings.musicSettings.isPlaying) {
                  pauseMusic();
                }
              },
              onTap: onAspectSelected,
            ),
            // Image toggle now second
            AspectToggle(
              aspect: ShaderAspect.image,
              isEnabled: true,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log('Image aspect toggled: $enabled', level: LogLevel.debug);
                onAspectToggled(aspect, enabled);
              },
              onTap: onAspectSelected,
            ),
            // Text toggle moved to be right after image
            AspectToggle(
              aspect: ShaderAspect.text,
              isEnabled: settings.textLayoutSettings.textEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log('Text aspect toggled: $enabled', level: LogLevel.debug);
                onAspectToggled(aspect, enabled);
              },
              onTap: onAspectSelected,
            ),
            // Text FX toggle moved to be right after text
            AspectToggle(
              aspect: ShaderAspect.textfx,
              isEnabled: settings.textfxSettings.textfxEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log('TextFx aspect toggled: $enabled', level: LogLevel.info);

                // Create a deep copy to avoid mutation issues
                var updatedSettings = ShaderSettings.fromMap(settings.toMap());

                // Update setting through proper method
                updatedSettings.textfxSettings.textfxEnabled = enabled;

                // Always keep textfxEnabled and applyToText in sync
                updatedSettings.textfxSettings.applyToText = enabled;

                _log(
                  'Setting TextFx enabled to $enabled and Apply Shaders to Text to $enabled',
                  level: LogLevel.info,
                );

                // Force immediate notification to listeners
                updatedSettings.textfxSettings.forceNotify();

                // Pass through to aspect handler
                onAspectToggled(aspect, enabled);
              },
              onTap: onAspectSelected,
            ),
            AspectToggle(
              aspect: ShaderAspect.color,
              isEnabled: settings.colorEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log('Color aspect toggled: $enabled', level: LogLevel.debug);
                onAspectToggled(aspect, enabled);
              },
              onTap: onAspectSelected,
            ),
            AspectToggle(
              aspect: ShaderAspect.blur,
              isEnabled: settings.blurEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log('Blur aspect toggled: $enabled', level: LogLevel.debug);
                onAspectToggled(aspect, enabled);
              },
              onTap: onAspectSelected,
            ),
            AspectToggle(
              aspect: ShaderAspect.noise,
              isEnabled: settings.noiseEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log('Noise aspect toggled: $enabled', level: LogLevel.debug);
                onAspectToggled(aspect, enabled);
              },
              onTap: onAspectSelected,
            ),
            AspectToggle(
              aspect: ShaderAspect.rain,
              isEnabled: settings.rainSettings.rainEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log('Rain aspect toggled: $enabled', level: LogLevel.debug);
                onAspectToggled(aspect, enabled);
              },
              onTap: onAspectSelected,
            ),
            AspectToggle(
              aspect: ShaderAspect.chromatic,
              isEnabled: settings.chromaticEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log(
                  'Chromatic aspect toggled: $enabled',
                  level: LogLevel.debug,
                );
                onAspectToggled(aspect, enabled);
              },
              onTap: onAspectSelected,
            ),
            AspectToggle(
              aspect: ShaderAspect.ripple,
              isEnabled: settings.rippleEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log('Ripple aspect toggled: $enabled', level: LogLevel.debug);
                onAspectToggled(aspect, enabled);
              },
              onTap: onAspectSelected,
            ),
            // Add Cymatics toggle
            AspectToggle(
              aspect: ShaderAspect.cymatics,
              isEnabled: settings.cymaticsEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) {
                _log(
                  'Cymatics aspect toggled: $enabled',
                  level: LogLevel.debug,
                );
                onAspectToggled(aspect, enabled);
              },
              onTap: onAspectSelected,
            ),
          ],
        ),
      ),
    );
  }

  // Track the last-built aspect to avoid redundant log messages
  static ShaderAspect? _lastBuiltAspect;

  // Build sliders for a specific aspect with proper grouping
  static List<Widget> buildSlidersForAspect({
    required ShaderAspect aspect,
    required ShaderSettings settings,
    required Function(ShaderSettings) onSettingsChanged,
    required Color sliderColor,
    required BuildContext context,
  }) {
    // Only log if building for a different aspect than last time
    if (_lastBuiltAspect != aspect) {
      _log('Building sliders for aspect: $aspect', level: LogLevel.debug);
      _lastBuiltAspect = aspect;
    }

    // Log color settings state when building any panel, but only at debug level
    _log(
      'Current color overlay state - Enabled: ${settings.colorEnabled}, Hue: ${settings.colorSettings.hue.toStringAsFixed(2)}, Saturation: ${settings.colorSettings.saturation.toStringAsFixed(2)}',
      level: LogLevel.debug,
    );

    // Only log overlay settings if they have non-zero values
    if (settings.colorSettings.overlayIntensity > 0 ||
        settings.colorSettings.overlayOpacity > 0) {
      _log(
        'Overlay settings - Hue: ${settings.colorSettings.overlayHue.toStringAsFixed(2)}, Intensity: ${settings.colorSettings.overlayIntensity.toStringAsFixed(2)}, Opacity: ${settings.colorSettings.overlayOpacity.toStringAsFixed(2)}',
        level: LogLevel.debug,
      );
    }

    switch (aspect) {
      case ShaderAspect.color:
        return [
          ColorPanel(
            settings: settings,
            onSettingsChanged: (updatedSettings) {
              _log(
                'Color panel settings changed - Color enabled: ${updatedSettings.colorEnabled}',
                level: LogLevel.debug,
              );
              // Only log overlay settings if they're meaningful
              if (updatedSettings.colorSettings.overlayIntensity > 0 ||
                  updatedSettings.colorSettings.overlayOpacity > 0) {
                _log(
                  'Overlay intensity: ${updatedSettings.colorSettings.overlayIntensity.toStringAsFixed(2)}, Overlay opacity: ${updatedSettings.colorSettings.overlayOpacity.toStringAsFixed(2)}',
                  level: LogLevel.debug,
                );
              }
              onSettingsChanged(updatedSettings);
            },
            sliderColor: sliderColor,
            context: context,
          ),
        ];

      case ShaderAspect.blur:
        return [
          BlurPanel(
            settings: settings,
            onSettingsChanged: onSettingsChanged,
            sliderColor: sliderColor,
            context: context,
          ),
        ];

      case ShaderAspect.image:
        return [
          ImagePanel(
            settings: settings,
            onSettingsChanged: onSettingsChanged,
            sliderColor: sliderColor,
            context: context,
            coverImages: const [],
            artistImages: const [],
            selectedImage: '',
            imageCategory: ImageCategory.covers,
            onImageSelected: (_) {},
            onCategoryChanged: (_) {},
          ),
        ];

      case ShaderAspect.text:
        return [
          TextPanel(
            settings: settings,
            onSettingsChanged: (updatedSettings) {
              _log(
                'Text panel settings changed - Text enabled: ${updatedSettings.textLayoutSettings.textEnabled}',
                level: LogLevel.debug,
              );
              onSettingsChanged(updatedSettings);
            },
            sliderColor: sliderColor,
            context: context,
          ),
        ];

      case ShaderAspect.noise:
        return [
          NoisePanel(
            settings: settings,
            onSettingsChanged: onSettingsChanged,
            sliderColor: sliderColor,
            context: context,
          ),
        ];

      case ShaderAspect.textfx:
        return [
          TextFxPanel(
            settings: settings,
            onSettingsChanged: (updatedSettings) {
              _log(
                'TextFx panel settings changed - TextFx enabled: ${updatedSettings.textfxSettings.textfxEnabled}, Apply shaders: ${updatedSettings.textfxSettings.applyToText}',
                level: LogLevel.debug,
              );
              onSettingsChanged(updatedSettings);
            },
            sliderColor: sliderColor,
            context: context,
          ),
        ];

      case ShaderAspect.rain:
        return [
          RainPanel(
            settings: settings,
            onSettingsChanged: (updatedSettings) {
              _log(
                'Rain panel settings changed - Rain enabled: ${updatedSettings.rainEnabled}',
                level: LogLevel.debug,
              );
              onSettingsChanged(updatedSettings);
            },
            sliderColor: sliderColor,
            context: context,
          ),
        ];

      case ShaderAspect.chromatic:
        return [
          ChromaticPanel(
            settings: settings,
            onSettingsChanged: (updatedSettings) {
              _log(
                'Chromatic panel settings changed - Chromatic enabled: ${updatedSettings.chromaticEnabled}',
                level: LogLevel.debug,
              );
              onSettingsChanged(updatedSettings);
            },
            sliderColor: sliderColor,
          ),
        ];

      case ShaderAspect.ripple:
        return [
          RipplePanel(
            settings: settings,
            onSettingsChanged: (updatedSettings) {
              _log(
                'Ripple panel settings changed - Ripple enabled: ${updatedSettings.rippleEnabled}',
                level: LogLevel.debug,
              );
              onSettingsChanged(updatedSettings);
            },
            sliderColor: sliderColor,
            context: context,
          ),
        ];

      case ShaderAspect.music:
        return [
          MusicPanel(
            settings: settings,
            onSettingsChanged: (updatedSettings) {
              _log(
                'Music panel settings changed - Music enabled: ${updatedSettings.musicEnabled}',
                level: LogLevel.debug,
              );
              onSettingsChanged(updatedSettings);
            },
            sliderColor: sliderColor,
            context: context,
            musicTracks: musicTracks,
            onTrackSelected: selectMusicTrack,
            onPlay: playMusic,
            onPause: pauseMusic,
            onSeek: seekMusic,
          ),
        ];

      case ShaderAspect.cymatics:
        return [
          CymaticsPanel(
            settings: settings,
            onSettingsChanged: (updatedSettings) {
              _log(
                'Cymatics panel settings changed - Cymatics enabled: ${updatedSettings.cymaticsEnabled}',
                level: LogLevel.debug,
              );
              onSettingsChanged(updatedSettings);
            },
            sliderColor: sliderColor,
            context: context,
          ),
        ];
    }
  }

  // Utility method to build image selector dropdown
  static Widget buildImageSelector({
    required String selectedImage,
    required List<String> availableImages,
    required bool isCurrentImageDark,
    required Function(String?) onImageSelected,
  }) {
    final Color textColor = isCurrentImageDark ? Colors.white : Colors.black;

    return DropdownButton<String>(
      dropdownColor: isCurrentImageDark
          ? Colors.black.withOpacity(0.8)
          : Colors.white.withOpacity(0.8),
      value: selectedImage,
      icon: Icon(Icons.arrow_downward, color: textColor),
      elevation: 16,
      style: TextStyle(color: textColor),
      underline: Container(height: 2, color: textColor),
      onChanged: (String? newImage) {
        if (newImage != null && newImage != selectedImage) {
          _log('Image changed to: $newImage');
          onImageSelected(newImage);
        }
      },
      items: availableImages.map<DropdownMenuItem<String>>((String value) {
        final filename = value.split('/').last.split('.').first;
        return DropdownMenuItem<String>(value: value, child: Text(filename));
      }).toList(),
    );
  }

  // Build a widget to display saved presets
  static Widget buildPresetsBar({
    required ShaderAspect aspect,
    required Function(Map<String, dynamic>) onPresetSelected,
    required Color sliderColor,
    required BuildContext context,
  }) {
    return PresetsBar(
      aspect: aspect,
      onPresetSelected: (presetData) {
        _log(
          'Preset selected for $aspect: ${presetData.toString().substring(0, min(100, presetData.toString().length))}...',
          level: LogLevel.debug,
        );
        onPresetSelected(presetData);
      },
      sliderColor: sliderColor,
      loadPresets: loadPresetsForAspect,
      deletePreset: deletePresetAndUpdate,
      refreshPresets: refreshPresets,
      refreshCounter: presetsRefreshCounter,
    );
  }

  // Cleanup resources
  static void dispose() {
    _log('Disposing EffectControls');

    // Dispose music controller if it exists
    _musicController?.dispose();
    _musicController = null;
  }

  // Helper function to limit string length
  static int min(int a, int b) => a < b ? a : b;
}
