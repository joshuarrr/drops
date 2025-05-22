# AudioPlayers Implementation

## Files Involved

1. **drops_app/lib/shader_demo/controllers/music_controller.dart** - Core controller that manages AudioPlayer instance and playback logic
2. **drops_app/lib/shader_demo/models/music_settings.dart** - Data model that stores music configuration and state
3. **drops_app/lib/shader_demo/widgets/music_panel.dart** - UI widget with playback controls and track selector
4. **drops_app/lib/shader_demo/views/effect_controls.dart** - Static methods to control music playback and initialize controller
5. **drops_app/lib/shader_demo/shader_demo_impl.dart** - Main implementation that bootstraps music controller
6. **drops_app/lib/shader_demo/services/asset_service.dart** - Service for loading music tracks from assets
7. **drops_app/lib/shader_demo/models/effect_settings.dart** - Container for settings including music configuration
8. **drops_app/lib/shader_demo/state/shader_demo_state.dart** - State management for shader demo including music state

## Critical Fixes

1. **Track Selection Mismatch**
   - Debug logs show different tracks in UI vs settings: "01 Non Photo-Blue.mp3" vs "01 Ain't Got No, I Got Life.mp3"
   - Track selector dropdown not appearing in UI

2. **Source Not Set**
   - AudioPlayer debug shows `current_source: null` despite track being selected
   - Player state is stopped and not reacting to play commands

3. **State Synchronization Issues**
   - UI shows music as enabled (`Music enabled: true`) but player shows `enabled: false`
   - Play/Pause control not working because of state mismatch

4. **Player Initialization Problems**
   - Player is initialized (`initialized: true`) but not properly configured with the selected track
   - Duration and position values are both 0.0 despite track selection

5. **Missing Track List**
   - Track selector missing because track list not properly loaded or passed to UI components

6. **UI State vs. Player State Conflict**
   - Multiple conflicting state sources (settings state vs actual player state)
   - UI updating from wrong state source
