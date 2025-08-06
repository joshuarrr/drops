import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shader_effect.dart';
import '../models/image_category.dart';
import '../controllers/shader_controller.dart';
import '../controllers/music_controller.dart';
import '../widgets/background_panel.dart';
import '../widgets/color_panel.dart';
import '../widgets/blur_panel.dart';
import '../widgets/image_panel.dart';
import '../widgets/text_panel.dart';
import '../widgets/noise_panel.dart';
import '../widgets/text_fx_panel.dart';
import '../widgets/rain_panel.dart';
import '../widgets/chromatic_panel.dart';
import '../widgets/ripple_panel.dart';
import '../widgets/highlights_panel.dart';
import '../widgets/aspect_toggle.dart';
import '../widgets/music_panel.dart';
import '../services/asset_service.dart';

/// Effect controls for shader demo V2 - matches V1 UI exactly
/// Uses toggle bar + single aspect panel pattern from V1
class EffectControlsV2 extends StatefulWidget {
  const EffectControlsV2({Key? key}) : super(key: key);

  @override
  State<EffectControlsV2> createState() => _EffectControlsV2State();
}

class _EffectControlsV2State extends State<EffectControlsV2> {
  ShaderAspect _selectedAspect = ShaderAspect.color;
  bool _showAspectSliders = false;
  ImageCategory _imageCategory = ImageCategory.covers;

  // Dynamic image lists loaded from assets
  List<String> _coverImages = [];
  List<String> _artistImages = [];
  bool _imagesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadImageAssets();
  }

  /// Load image assets dynamically from the asset manifest
  Future<void> _loadImageAssets() async {
    try {
      final images = await AssetService.loadImageAssets();
      if (mounted) {
        setState(() {
          _coverImages = images['covers'] ?? [];
          _artistImages = images['artists'] ?? [];
          _imagesLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading image assets: $e');
      if (mounted) {
        setState(() {
          _imagesLoaded = true; // Mark as loaded even if failed
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ShaderController>(
      builder: (context, controller, child) {
        final settings = controller.settings;
        final sliderColor = theme.colorScheme.primary;

        return Stack(
          children: [
            // Toggle bar (always visible)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAspectToggleBar(controller, sliderColor, theme),
            ),

            // Aspect control panel (modal style)
            if (_showAspectSliders)
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height - 150,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.black.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildAspectParameterSliders(
                      controller,
                      sliderColor,
                      theme,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build the aspect toggle bar (identical to V1)
  Widget _buildAspectToggleBar(
    ShaderController controller,
    Color sliderColor,
    ThemeData theme,
  ) {
    final settings = controller.settings;
    final isCurrentImageDark = theme.brightness == Brightness.dark;

    return AnimatedSlide(
      offset: _showAspectSliders ? const Offset(0, -1.2) : Offset.zero,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: _showAspectSliders ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            AspectToggle(
              aspect: ShaderAspect.music,
              isEnabled: settings.musicEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.background,
              isEnabled: settings.backgroundEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.image,
              isEnabled: settings.imageEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.text,
              isEnabled: settings.textEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.textfx,
              isEnabled: settings.textfxEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.color,
              isEnabled: settings.colorEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.blur,
              isEnabled: settings.blurEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.noise,
              isEnabled: settings.noiseEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.rain,
              isEnabled: settings.rainEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.chromatic,
              isEnabled: settings.chromaticEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.ripple,
              isEnabled: settings.rippleEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
            AspectToggle(
              aspect: ShaderAspect.highlights,
              isEnabled: settings.highlightsEnabled,
              isCurrentImageDark: isCurrentImageDark,
              onToggled: (aspect, enabled) =>
                  _toggleAspect(aspect, enabled, controller),
              onTap: _selectAspect,
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual aspect chip
  Widget _buildAspectChip(
    ShaderAspect aspect,
    String label,
    bool enabled,
    ShaderController controller,
    Color sliderColor,
    ThemeData theme,
  ) {
    final isSelected = _selectedAspect == aspect;

    return GestureDetector(
      onTap: () {
        setState(() {
          final bool selectingNewAspect = _selectedAspect != aspect;
          _selectedAspect = aspect;

          if (selectingNewAspect) {
            _showAspectSliders = true;

            // Auto-enable aspect if selecting it
            if (!enabled) {
              _toggleAspect(aspect, true, controller);
            }
          } else {
            _showAspectSliders = !_showAspectSliders;
          }
        });
      },
      onLongPress: () {
        // Long press toggles enabled state
        _toggleAspect(aspect, !enabled, controller);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled
              ? sliderColor.withOpacity(0.2)
              : theme.colorScheme.onSurface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? sliderColor
                : (enabled
                      ? sliderColor.withOpacity(0.5)
                      : theme.colorScheme.onSurface.withOpacity(0.5)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled
                ? sliderColor
                : theme.colorScheme.onSurface.withOpacity(0.5),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Select aspect for parameter editing
  void _selectAspect(ShaderAspect aspect) {
    setState(() {
      final bool selectingNewAspect = _selectedAspect != aspect;
      _selectedAspect = aspect;

      if (selectingNewAspect) {
        _showAspectSliders = true;
      } else {
        _showAspectSliders = !_showAspectSliders;
      }
    });
  }

  /// Toggle aspect enabled state
  void _toggleAspect(
    ShaderAspect aspect,
    bool enabled,
    ShaderController controller,
  ) {
    final settings = controller.settings;

    switch (aspect) {
      case ShaderAspect.background:
        settings.backgroundEnabled = enabled;
        break;
      case ShaderAspect.color:
        settings.colorEnabled = enabled;
        break;
      case ShaderAspect.blur:
        settings.blurEnabled = enabled;
        break;
      case ShaderAspect.image:
        settings.imageEnabled = enabled;
        break;
      case ShaderAspect.text:
        settings.textEnabled = enabled;
        break;
      case ShaderAspect.noise:
        settings.noiseEnabled = enabled;
        break;
      case ShaderAspect.textfx:
        settings.textfxEnabled = enabled;
        break;
      case ShaderAspect.rain:
        settings.rainEnabled = enabled;
        break;
      case ShaderAspect.chromatic:
        settings.chromaticEnabled = enabled;
        break;
      case ShaderAspect.ripple:
        settings.rippleEnabled = enabled;
        break;
      case ShaderAspect.highlights:
        settings.highlightsEnabled = enabled;
        break;
      case ShaderAspect.music:
        settings.musicEnabled = enabled;
        break;
      case ShaderAspect.cymatics:
        // V2 doesn't support cymatics - skip
        break;
    }

    controller.updateSettings(settings);
    setState(() {});
  }

  /// Build music panel with proper V2 integration
  Widget _buildMusicPanel(ShaderController controller, Color sliderColor) {
    return FutureBuilder<MusicController?>(
      future: _initializeMusicController(controller),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final musicController = snapshot.data;
        if (musicController == null) {
          return const Center(child: Text('Music controller not available'));
        }

        return MusicPanel(
          settings: controller.settings,
          onSettingsChanged: controller.updateSettings,
          sliderColor: sliderColor,
          context: context,
          musicTracks: musicController.availableTracks,
          onTrackSelected: (track) => musicController.selectTrack(track),
          onPlay: () => musicController.play(),
          onPause: () => musicController.pause(),
          onSeek: (position) => musicController.seek(position),
        );
      },
    );
  }

  /// Initialize music controller for V2
  Future<MusicController?> _initializeMusicController(
    ShaderController controller,
  ) async {
    try {
      final musicController = MusicController.getInstance(
        settings: controller.settings,
        onSettingsChanged: controller.updateSettings,
      );

      // Load tracks from assets music directory
      await musicController.loadTracks('assets/music');

      return musicController;
    } catch (e) {
      print('Error initializing music controller: $e');
      return null;
    }
  }

  /// Build parameter sliders for the selected aspect
  Widget _buildAspectParameterSliders(
    ShaderController controller,
    Color sliderColor,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show appropriate panel based on selected aspect
          if (_selectedAspect == ShaderAspect.background)
            BackgroundPanel(
              settings: controller.settings,
              onSettingsChanged: controller.updateSettings,
              sliderColor: sliderColor,
              context: context,
            ),
          if (_selectedAspect == ShaderAspect.color)
            ColorPanel(
              settings: controller.settings,
              onSettingsChanged: controller.updateSettings,
              sliderColor: sliderColor,
              context: context,
            ),
          if (_selectedAspect == ShaderAspect.blur)
            BlurPanel(
              settings: controller.settings,
              onSettingsChanged: controller.updateSettings,
              sliderColor: sliderColor,
              context: context,
            ),
          if (_selectedAspect == ShaderAspect.image)
            _imagesLoaded
                ? ImagePanel(
                    settings: controller.settings,
                    onSettingsChanged: controller.updateSettings,
                    sliderColor: sliderColor,
                    context: context,
                    coverImages: _coverImages,
                    artistImages: _artistImages,
                    selectedImage: controller.selectedImage,
                    imageCategory: _imageCategory,
                    onImageSelected: controller.updateSelectedImage,
                    onCategoryChanged: (category) {
                      setState(() {
                        _imageCategory = category;
                      });
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          if (_selectedAspect == ShaderAspect.text)
            TextPanel(
              settings: controller.settings,
              onSettingsChanged: controller.updateSettings,
              sliderColor: sliderColor,
              context: context,
            ),
          if (_selectedAspect == ShaderAspect.noise)
            NoisePanel(
              settings: controller.settings,
              onSettingsChanged: controller.updateSettings,
              sliderColor: sliderColor,
              context: context,
            ),
          if (_selectedAspect == ShaderAspect.textfx)
            TextFxPanel(
              settings: controller.settings,
              onSettingsChanged: controller.updateSettings,
              sliderColor: sliderColor,
              context: context,
            ),
          if (_selectedAspect == ShaderAspect.rain)
            RainPanel(
              settings: controller.settings,
              onSettingsChanged: controller.updateSettings,
              sliderColor: sliderColor,
              context: context,
            ),
          if (_selectedAspect == ShaderAspect.chromatic)
            ChromaticPanel(
              settings: controller.settings,
              onSettingsChanged: controller.updateSettings,
              sliderColor: sliderColor,
            ),
          if (_selectedAspect == ShaderAspect.ripple)
            RipplePanel(
              settings: controller.settings,
              onSettingsChanged: controller.updateSettings,
              sliderColor: sliderColor,
              context: context,
            ),
          if (_selectedAspect == ShaderAspect.highlights)
            HighlightsPanel(
              settings: controller.settings,
              onSettingsChanged: controller.updateSettings,
              sliderColor: sliderColor,
              context: context,
            ),
          if (_selectedAspect == ShaderAspect.music)
            _buildMusicPanel(controller, sliderColor),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
