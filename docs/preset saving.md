# Shader demo V2 Preset Saving Process Documentation

## Overview
This document describes the preset saving flow in the shader demo v2 application, highlighting the current issues with thumbnail generation and proposing solutions.

## Current Preset Saving Flow

### 1. Saving a Preset
When a user saves a preset, the following process occurs:

1. User clicks "Save Preset" from the menu in `lib/shader_demo_v2/views/shader_demo_screen.dart`
2. The `_handleSavePreset()` method (lines ~600-697) shows a dialog prompting for a preset name
3. When the user confirms, `controller.saveNamedPreset(name)` is called
4. Inside `lib/shader_demo_v2/controllers/shader_controller.dart:saveNamedPreset()` (lines ~395-448):
   - The current settings and selected image path are captured
   - `PresetService.saveNamedPreset()` is called with `thumbnailBase64: null`
   - The preset data is saved to persistent storage via `StorageService`
   - UI is updated to reflect the new preset in the list
   - A success message is shown to the user

### 2. Thumbnail Generation (Current Issue)
The current implementation has several issues with thumbnail generation:

- **Missing `_previewKey`**: In `lib/shader_demo_v2/views/shader_demo_screen.dart` (around line 33), the GlobalKey needed for thumbnail capture is commented out:
  ```dart
  // Key for capturing thumbnails like V1 - temporarily disabled
  // final GlobalKey _previewKey = GlobalKey();
  ```

- **Disabled Thumbnail Capture**: In the `_handleSavePreset` method in `lib/shader_demo_v2/views/shader_demo_screen.dart` (around line 665), the thumbnail capture code is commented out:
  ```dart
  // Commented out for now as we removed RepaintBoundary
  // final thumbnailBase64 =
  //     await ThumbnailService.capturePresetThumbnail(
  //       preset: savedPreset,
  //       previewKey: _previewKey,
  //     );
  ```

- **No RepaintBoundary**: In `lib/shader_demo_v2/views/shader_demo_screen.dart:_buildStackContent()` (lines ~480-526), the shader content is not wrapped in a RepaintBoundary, which is necessary for thumbnail capture:
  ```dart
  // Return the stack directly (RepaintBoundary moved to _buildShaderArea)
  return Stack(fit: StackFit.expand, children: stackChildren);
  ```

### 3. Displaying Preset Thumbnails
When viewing saved presets:
1. The app attempts to load thumbnails via `lib/shader_demo_v2/services/thumbnail_service.dart:getOrGenerateThumbnail()` (lines ~47-71)
2. Since no thumbnails were saved during preset creation, this returns null
3. The UI displays a placeholder icon instead of the actual shader effect

## Proposed Solution

To fix the thumbnail generation issue, we need to implement the following changes:

1. **Restore the `_previewKey` GlobalKey** in `lib/shader_demo_v2/views/shader_demo_screen.dart`:
   ```dart
   // Around line 33
   final GlobalKey _previewKey = GlobalKey();
   ```

2. **Add RepaintBoundary to the main content** in `lib/shader_demo_v2/views/shader_demo_screen.dart:_buildStackContent()`:
   ```dart
   // Around line 525
   return RepaintBoundary(
     key: _previewKey,
     child: Stack(fit: StackFit.expand, children: stackChildren),
   );
   ```

3. **Uncomment and update the thumbnail capture code** in `lib/shader_demo_v2/views/shader_demo_screen.dart:_handleSavePreset()`:
   ```dart
   // Around line 665
   final thumbnailBase64 = await ThumbnailService.capturePresetThumbnail(
     preset: savedPreset,
     previewKey: _previewKey,
   );
   ```

4. **Update the preset with the captured thumbnail** in `lib/shader_demo_v2/views/shader_demo_screen.dart:_handleSavePreset()`:
   ```dart
   // After thumbnail capture
   if (thumbnailBase64 != null) {
     await PresetService.savePresetThumbnail(savedPreset.id, thumbnailBase64);
   }
   ```

## Technical Details

### Thumbnail Capture Process
1. A `RepaintBoundary` wraps the content we want to capture
2. The `_capturePreview` method in `lib/shader_demo_v2/services/thumbnail_service.dart` (lines ~74-134) accesses this boundary via a GlobalKey
3. It captures the current render as an image using `toImage()` and converts it to bytes
4. The bytes are encoded to base64 and stored in SharedPreferences via `StorageService.savePresetThumbnail()`

### Key Components
- **ThumbnailService** (`lib/shader_demo_v2/services/thumbnail_service.dart`): Handles capturing, storing, and retrieving thumbnails
- **PresetService** (`lib/shader_demo_v2/services/preset_service.dart`): Manages preset data CRUD operations
- **StorageService** (`lib/shader_demo_v2/services/storage_service.dart`): Provides persistent storage for presets and thumbnails
- **ShaderController** (`lib/shader_demo_v2/controllers/shader_controller.dart`): Manages shader state and preset operations
- **Preset Model** (`lib/shader_demo_v2/models/preset.dart`): Data structure for presets including thumbnail data

### Preset Related Files
- `lib/shader_demo_v2/views/shader_demo_screen.dart` - Main UI file containing the save preset dialog and thumbnail capture logic
- `lib/shader_demo_v2/controllers/shader_controller.dart` - Controller managing preset operations
- `lib/shader_demo_v2/services/preset_service.dart` - Service for saving and loading presets
- `lib/shader_demo_v2/services/thumbnail_service.dart` - Service for capturing and managing thumbnails
- `lib/shader_demo_v2/services/storage_service.dart` - Service for persistent storage operations
- `lib/shader_demo_v2/models/preset.dart` - Data model for presets

## Conclusion
The current implementation has disabled thumbnail generation due to the removal of the RepaintBoundary and related code. By restoring these components and ensuring proper wiring between the capture and storage mechanisms, we can fix the missing thumbnail issue.