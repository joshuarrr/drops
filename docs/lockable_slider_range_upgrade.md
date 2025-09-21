# Lockable Slider → Range Upgrade Plan

Affected control panels:

[x] color
[x] shatter (blur)
[x] chroma
[x] waves (noise)
[-] rain (currently not even using lockable slider)
[x] ripple
[x] sketch
[x] edge
[x] glitch
[x] vhs

## UX Decisions (Confirmed)
- Every lockable slider becomes a range control with user min/max; default min = 0 preserves existing presets.
- Default presentation shows a single max handle with the min pinned at 0; the second handle only appears once animation is enabled.
- When animating, locking a parameter collapses interaction to a single handle (no animation) and freezes both handles.
- Display string shows combined min–max (e.g. `20–80%`), regardless of animation state.
- Pulse mode oscillates between user min/max; zero is no longer a special case unless min = 0.
- Randomized mode stays within the user-specified min/max window.
- During animation the handles stay fixed while one amber marker animates to show the current value.
- Presets/import-export must persist min, max, and lock state immediately.

## Implementation Phases

### 1. Baseline & Migration Prep
- Inventory every `LockableSlider` usage and capture existing min/max/default semantics.
- Sketch data model deltas for storing min/max per parameter (settings, presets, serialization).

### 2. Range Slider Component
- Design a `RangeLockableSlider` variant (likely extending current widget) that supports dual handles when needed and consolidated formatting.
- Update `LabeledSlider` rendering to keep the user handles static, show a combined label, and drive a single amber indicator that animates to represent the live value.
- Keep range handles fixed at user min/max; animate only the amber indicator while the slider sweeps.
- Hide the min handle (and any associated track styling) until animation is on or the user adjusts the min; ensure locked state falls back to a single static handle with the lock affordance unchanged.

### 3. Animation-State Integration
- Extend `AnimationStateManager` to track both min/max animated values and ensure throttled updates work with ranges.
- Update animation utils to accept user min/max envelopes and clamp pulse/randomized outputs accordingly.
- Ensure lock toggling clears animated values and respects new dual-handle semantics.

### 4. Panel Refactors
- Replace every panel’s slider instantiation with the new range component; keep default min=0 so existing behavior matches until users widen range.
- Adjust formatting per parameter (%, px, °, etc.) so combined labels stay legible.
- Validate lock tooltips/help copy where present.

### 5. Preset & Persistence Updates
- Evolve settings models, JSON serialization, and preset payloads to store `minValue`, `maxValue`, and lock state.
- Add migration path for legacy presets (assume min=global min, max=stored value) to avoid breakage.
- Update import/export schema docs once data model confirmed.

### 6. QA & Documentation
- Expand automated/widget tests to cover range interaction, lock toggling, and animation outputs.
- Update `docs/v2_animation_behavior.md` (and related) to explain min/max-based animation, then archive superseded bug docs.
- Record verification checklist: pulse/randomized bounds, lock behavior, preset round-trip, animation controller duration changes.

## Phase 1 Findings (completed)

**LockableSlider inventory (effect panels referencing `lockable_slider.dart`):**
- `blur_panel.dart`: Shatter Amount `[0–1]` (reset→0), Shatter Radius `[0–120px]` (reset→15), Shatter Opacity `[0–1]` (reset→1), Intensity `[0–3×]` (reset→1), Contrast `[0–200%]` (reset→0).
- `color_panel.dart`: Hue/Saturation/Lightness `[−1–1]` (all reset→0); Overlay Hue/Intensity/Opacity `[−1–1]` (reset→0). Formatting expressed as percentages.
- `noise_panel.dart`: Noise Scale `[0.1–20]` (no explicit reset ⇒ slider defaults to 0 despite min 0.1), Noise Speed `[0–1]` (reset→0.5, only visible when animated), Wave Amount `[0–0.1]` (reset→0.02), Color Intensity `[0–1]` (reset→0.3).
- `chromatic_panel.dart`: Amount `[0–20]` (reset→0.5), Angle `[0–360°]` (reset→0), Spread `[0–1]` (reset→0.5), Intensity `[0–1]` (reset→0.5).
- `edge_panel.dart`: Edge Opacity `[0–1]` (reset→0.7), Edge Intensity `[0.1–5]` (reset→1.5), Edge Thickness `[0.1–5]` (reset→1.0), Edge Color `[0–1]` (reset→0; label maps to black/original/white).
- `glitch_panel.dart`: Effect Opacity `[0–1]` (reset→0.5), Intensity `[0–1]` (reset→0.3), Frequency `[0–3×]` (reset→1.0), Block Size `[0–0.5]` (reset→0.1), Horizontal Slicing `[0–1]` (reset→0), Vertical Slicing `[0–1]` (reset→0).
- `ripple_panel.dart`: Drop Count `[1–30]` (reset→5), Ovalness `[0–1]` (reset→0), Rotation `[0–1]` (reset→0), Intensity `[0–1]` (reset→0.5), Size `[0–1]` (reset→0.5), Speed `[0–1]` (reset→0.5), Opacity `[0–1]` (reset→0.8), Color `[0–1]` (reset→0.5).
- `sketch_panel.dart`: Image Opacity `[0–1]` (reset→1.0), Sketch Opacity `[0–1]` (reset→0.8), Lum Thresholds 1–4 `[0–1]` (reset→0.8/0.6/0.4/0.2 respectively), Hatch Y Offset `[0–50px]` (reset→0), Line Spacing `[5–50px]` (reset→15), Line Thickness `[0.5–5px]` (reset→1.5).
- `vhs_panel.dart`: Effect Opacity `[0–1]` (reset→0.5), Noise Intensity `[0–1]` (reset→0.7), Field Lines `[0–400]` (reset→240), Wave Strength `[0–0.5]` (reset→0.15), Wave Screen Size `[10–200]` (reset→50), Wave Vertical Size `[10–300]` (reset→100), Dotted Noise `[0–1]` (reset→0.2), Distortion Strength `[0–0.02]` (reset→0.0087).

Notes:
- Rain panel and any remaining V1 widgets still use `ValueSlider`; they’ll need separate evaluation before introducing lock/animation parity.
- Several sliders rely on the widget’s default reset (0.0) even when the minimum is higher (`Noise Scale`)—call out during migration to avoid snapping handles below allowed range.

**Docs flagged for archiving / updates:**
- `docs/v2_animation_behavior.md` moved to `docs/archive/v2_animation_behavior.md`; future references should cite the archived copy until a refreshed behavior guide is authored.

**Settings / preset data model sketch:**
- Introduce a reusable `ParameterRange` model (`lib/shader_demo_v2/models/parameter_range.dart`) capturing `current`, `userMin`, `userMax`, plus helpers for defaults and clamping; expose serializers to embed in existing settings maps.
- Augment each effect settings class that currently stores a scalar (`blurAmount`, `colorSettings.hue`, etc.) so the underlying field becomes a `ParameterRange`; keep legacy getters/setters (`double get blurAmount`) delegating to `range.current` for drop-in compatibility.
- Extend `toMap()/fromMap()` on every affected settings class to read/write `*_min`/`*_max` (or nested `range` payload) while defaulting missing values to `(globalMin, storedValue)` to preserve legacy presets.
- Update `ShaderSettings.toMap()` / `fromMap()` and `Preset` serialization in `lib/shader_demo_v2/models/preset.dart` + `services/preset_service.dart` so presets persist both handles alongside lock state.
- Version presets via a new `schemaVersion` (increment in `Preset` model) allowing migration logic in `PresetsManager` to detect older payloads and synthesize ranges without losing user data.
- Record per-parameter defaults (e.g. blur radius min 0 / max 120) next to the new range so future presets don’t require hard-coded fallbacks scattered across widgets.

Next up: begin Phase 2 implementation (range component prototype + ParameterRange wiring).

## Open Items / Risks
- Flutter range-slider UX details (gestures, accessibility) may require exploratory spike.
- Preset migration must be lossless; consider version tagging to differentiate legacy entries.
