# Shader Control Architecture Analysis

## Current Architecture

### Main Components
1. **ShaderDemoImpl.dart** - Main screen implementation with:
   - Main shader effect display area
   - Top controls for selecting aspect
   - Settings panel for each aspect when selected
   - Persistence of settings

2. **ShaderSettings** - Central settings model that contains:
   - Specialized settings classes for each effect (ColorSettings, BlurSettings, etc.)
   - Flags for enabling/disabling each effect
   - Animation settings

3. **EffectController** - Static class for applying shader effects:
   - `applyEffects()` - Main method to apply all enabled effects to a widget
   - Handles both image and text content through the `isTextContent` parameter
   - Applies each effect in sequence based on enable flags

4. **Per-Effect Panels** - Widget classes for each effect type:
   - ColorPanel, BlurPanel, NoisePanel, etc.
   - Each has similar structure but different controls
   - Uses AspectPanelHeader for consistent header with preset controls

### Key UI Components
- **AspectToggleBar** - Row of toggles for enabling/disabling effects
- **AspectPanelHeader** - Consistent header for each panel with:
  - Title
  - PopupMenuButton with options
  - Presets display
- **ValueSlider** - Consistent slider control for numeric values

### Current "Apply to Image/Text" Implementation
- **TextLayoutSettings.applyShaderEffectsToImage** - Flag for applying shaders to images
- **TextFXSettings.applyShaderEffectsToText** - Flag for applying shaders to text
- In ImagePanel, there's a direct toggle for "Apply Shaders to Image"
- These settings control whether shaders are applied in ShaderDemoImpl via:
  ```dart
  effectsWidget = _shaderSettings.textLayoutSettings.applyShaderEffectsToImage
    ? Container(..., child: EffectController.applyEffects(...))
    : baseImage!; // Don't apply effects if disabled
  ```
- For text, it's controlled in TextOverlay:
  ```dart
  if (fxSettings.applyShaderEffectsToText && fxSettings.textfxEnabled) {
    result = Container(..., child: EffectController.applyEffects(...));
  } else {
    result = Container(..., child: overlayStack);
  }
  ```

### Color Panel Example (Model Panel with All Features)
The ColorPanel implements:
1. AspectPanelHeader with title, options menu, and presets
2. Section headers with collapsible content
3. ValueSliders for various parameters
4. Animation controls

## Refactoring Requirements

### Changes Needed:
1. **Remove global "Apply shaders to image" and "Apply shaders to text" buttons**
   - Remove from ImagePanel
   - Remove from TextFXPanel

2. **Make each effect individually targetable to image or text**
   - Add per-effect flags for "Apply to Image" and "Apply to Text"
   - Update model classes to store these preferences
   - Modify EffectController to respect per-effect targeting

3. **Standardize control panel UI**
   - Ensure all control panels use the same scaffolding:
     - AspectPanelHeader with title
     - Options menu with common functions
     - Consistent section headers
     - Consistent slider controls
   - Add "Apply to Image" and "Apply to Text" checkboxes to each panel's options menu

### Architectural Changes:
1. **Model Changes:**
   - Add applyToImage and applyToText boolean flags to each effect settings class
   - Remove the global flags from TextLayoutSettings and TextFXSettings

2. **Controller Changes:**
   - Modify EffectController.applyEffects to check per-effect flags
   - Update effect application logic to respect individual targeting

3. **UI Changes:**
   - Update all panel implementations to ensure consistent structure
   - Add checkboxes to each panel's options menu
   - Update the effect application in ShaderDemoImpl.dart

## Implementation Strategy
1. Update models first to add the new flags
2. Create a standardized panel template for common elements
3. Update the controller to use the new per-effect flags
4. Refactor individual panels to use the standardized template
5. Remove global toggles from ImagePanel and TextFXPanel

## IMPLEMENTATION NOTES 

### Completed Implementation

The refactoring has been successfully completed with the following key changes:

1. **Model Changes:**
   - Created a new `TargetableEffectSettings` mixin that adds `applyToImage` and `applyToText` boolean flags to all effect settings classes
   - Updated all effect settings classes (ColorSettings, BlurSettings, NoiseSettings, RainSettings, ChromaticSettings, RippleSettings, TextFXSettings) to use this mixin
   - Set default values for targeting flags to `true` as requested
   - Added serialization support to preserve targeting flags in presets with backward compatibility

2. **Controller Changes:**
   - Modified `EffectController.applyEffects()` to check per-effect targeting flags
   - Updated the application logic in `_buildEffectsWidget()` to only apply effects that target the current content type
   - Each effect application method now checks if the effect should be applied based on content type

3. **UI Components:**
   - Created new `EnhancedPanelHeader` component to replace the previous AspectPanelHeader
   - Created new `EffectOptionsMenu` component with targeting checkboxes in a consistent dot menu
   - Updated all panel widgets (ColorPanel, BlurPanel, NoisePanel, etc.) to use the new header and menu

4. **Panel Updates:**
   - Removed the global "Apply shaders to image" toggle from ImagePanel
   - Changed TextFXPanel to use per-effect targeting instead of the global toggle
   - Updated TextPanel to toggle all effect targeting flags simultaneously when needed
   - Ensured consistent UI across all panels

5. **Application Logic:**
   - Updated ShaderDemoImpl to use per-effect targeting
   - Updated TextOverlay to check per-effect targeting flags
   - Added detection for whether any effect targets the current content type

6. **Preset Handling:**
   - Added support for the new targeting flags in preset serialization
   - Ensured backward compatibility with existing presets
