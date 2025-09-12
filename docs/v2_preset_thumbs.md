# V2 Preset Thumbnail Saving Flow

## Current Problem
- Thumbnails are showing the correct iPhone 16 Pro aspect ratio (19.5:9) ✅
- BUT the captured image content is still cropped ❌
- The thumbnail should show the complete image, not the cropped version

## Current Flow Analysis

### 1. Preset Save Trigger
**File:** `lib/shader_demo_v2/views/shader_demo_screen.dart`
**Method:** `_handleSavePreset()` (around line 680)

```dart
// User taps save button
// Preset gets saved to storage
final savedPreset = await PresetService.savePreset(preset);

// Then capture thumbnail
if (savedPreset != null) {
  // Hide controls for clean capture
  controller.toggleControls();
  await Future.delayed(const Duration(milliseconds: 100));
  
  // Capture thumbnail from main screen
  final captureResult = await ThumbnailService.capturePreview(_thumbnailCaptureKey);
  final thumbnailBase64 = base64Encode(captureResult);
  
  // Save thumbnail to preset
  await PresetService.savePresetThumbnail(savedPreset.id, thumbnailBase64);
}
```

### 2. Main Content Rendering
**File:** `lib/shader_demo_v2/views/shader_demo_screen.dart`
**Method:** `_buildContent()` (around line 560)

```dart
return RepaintBoundary(
  key: _thumbnailCaptureKey,  // ← This is what gets captured
  child: Stack(fit: StackFit.expand, children: stackChildren),
);
```

The `stackChildren` contains:
- `ImageContainer` with `BoxFit.cover` (crops image to fill screen)
- Effect overlays
- Controls overlay

### 3. ImageContainer Behavior
**File:** `lib/shader_demo_v2/widgets/image_container.dart`

```dart
Image.asset(
  widget.imagePath,
  fit: fillScreen ? BoxFit.cover : BoxFit.contain,  // ← COVER = CROPS IMAGE
  width: imageWidth,
  height: imageHeight,
)
```

**The Problem:** `BoxFit.cover` scales the image to fill the entire container, cropping parts that don't fit.

### 4. Thumbnail Display
**File:** `lib/shader_demo_v2/views/preset_menu.dart`
**Method:** `_buildThumbnailWidget()` (around line 625)

```dart
Widget _buildThumbnailWidget(Preset preset) {
  const BoxFit thumbnailFit = BoxFit.contain;  // ← Always contain for thumbnails
  
  return Image.memory(
    base64Decode(thumbnailData), 
    fit: thumbnailFit  // ← Shows full image in thumbnail
  );
}
```

**Grid Display:**
```dart
childAspectRatio: size.width / size.height,  // ← Square thumbnails
```

## The Core Issue

1. **Main App:** Uses `BoxFit.cover` → Crops image to fill iPhone screen
2. **Capture:** Captures the cropped main app view → Gets cropped image
3. **Thumbnail Display:** Uses `BoxFit.contain` → Shows cropped image in thumbnail

**Result:** Thumbnail shows the cropped version of the image, not the full image.

## Why This Is Complicated

The fundamental conflict:
- **Main app needs:** `BoxFit.cover` for aesthetic full-screen display
- **Thumbnails need:** `BoxFit.contain` to show complete image content
- **Current approach:** Captures from main app → Gets cropped content

## Possible Solutions

### Solution A: Capture Full Image Content (Off-screen)
- Create separate widget with `BoxFit.contain`
- Render off-screen
- Capture that instead of main screen
- **Problem:** User said "NO OFF-SCREEN"

### Solution B: Temporarily Modify Main Screen
- Temporarily change main screen to `BoxFit.contain`
- Capture thumbnail
- Restore `BoxFit.cover`
- **Problem:** User said "NO CHANGING MAIN CONTENT"

### Solution C: Accept Cropped Thumbnails
- Thumbnails show exactly what user sees in main app
- If main app crops, thumbnail crops the same way
- **Current behavior:** This is what's happening now

### Solution D: Capture at Different Size
- Capture main screen but at full image dimensions
- Let thumbnail display handle the aspect ratio
- **Problem:** Still captures cropped content

## Current State
- ✅ Aspect ratio fixed (iPhone 16 Pro: 19.5:9)
- ❌ Content still cropped (shows "DS OF A F" instead of "BIRDS OF A FEATHER")
- ❌ Thumbnail doesn't represent the complete image

## Next Steps
Need to decide: Should thumbnails show the complete image content, or should they show exactly what the user sees in the main app (cropped)?
