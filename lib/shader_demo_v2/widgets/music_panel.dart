import 'package:flutter/material.dart';

import '../models/effect_settings.dart';
import 'labeled_switch.dart';

class MusicPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  // List of available music tracks
  final List<String> musicTracks;

  // Callbacks for music controls
  final Function(String)? onTrackSelected;
  final Function()? onPlay;
  final Function()? onPause;
  final Function(double)? onSeek;

  const MusicPanel({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
    this.musicTracks = const [],
    this.onTrackSelected,
    this.onPlay,
    this.onPause,
    this.onSeek,
  });

  @override
  State<MusicPanel> createState() => _MusicPanelState();
}

class _MusicPanelState extends State<MusicPanel> {
  // Format duration as MM:SS
  String _formatDuration(double seconds) {
    final Duration duration = Duration(seconds: seconds.round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds - minutes * 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final musicSettings = widget.settings.musicSettings;

    // Use music settings directly for V2 (no debug state available)
    bool isPlaying = musicSettings.isPlaying;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Music Controls',
            style: TextStyle(
              color: widget.sliderColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Music selection dropdown
        if (widget.musicTracks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Track:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value:
                      musicSettings.currentTrack.isNotEmpty &&
                          widget.musicTracks.contains(
                            musicSettings.currentTrack,
                          )
                      ? musicSettings.currentTrack
                      : null,
                  hint: const Text('Select a track'),
                  items: widget.musicTracks.map((String track) {
                    // Better handling of file names to display readable names
                    String filename = track.split('/').last;
                    // Remove extension
                    if (filename.contains('.')) {
                      filename = filename.substring(
                        0,
                        filename.lastIndexOf('.'),
                      );
                    }
                    // Remove numeric prefixes if present (like "07 ")
                    if (filename.length > 2 &&
                        RegExp(r'^\d+ ').hasMatch(filename)) {
                      filename = filename.replaceFirst(RegExp(r'^\d+ '), '');
                    }
                    return DropdownMenuItem<String>(
                      value: track,
                      child: Text(filename),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null &&
                        newValue != musicSettings.currentTrack) {
                      // First update settings with new track
                      final updatedSettings = ShaderSettings.fromMap(
                        widget.settings.toMap(),
                      );
                      updatedSettings.musicSettings.currentTrack = newValue;

                      // If music was playing, keep it playing for new track
                      final wasPlaying = musicSettings.isPlaying;
                      updatedSettings.musicSettings.isPlaying = wasPlaying;

                      // Apply settings changes
                      widget.onSettingsChanged(updatedSettings);

                      // Call the track selection callback
                      if (widget.onTrackSelected != null) {
                        widget.onTrackSelected!(newValue);
                      }
                    }
                  },
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Transport controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed:
                    musicSettings.currentTrack.isEmpty ||
                        widget.musicTracks.isEmpty
                    ? null
                    : () {
                        // Get previous track in the list
                        final currentIndex = widget.musicTracks.indexOf(
                          musicSettings.currentTrack,
                        );
                        if (currentIndex > 0) {
                          final prevTrack =
                              widget.musicTracks[currentIndex - 1];

                          if (widget.onTrackSelected != null) {
                            widget.onTrackSelected!(prevTrack);
                          }
                        }
                      },
              ),
              IconButton(
                iconSize: 48,
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
                onPressed:
                    musicSettings.currentTrack.isEmpty ||
                        !widget.settings.musicEnabled
                    ? null
                    : () {
                        // Update the settings to reflect the player state
                        final ShaderSettings updatedSettings =
                            ShaderSettings.fromMap(widget.settings.toMap());

                        // Call play/pause based on current state
                        if (!isPlaying) {
                          // Set isPlaying to true in the settings to update UI immediately
                          updatedSettings.musicSettings.isPlaying = true;
                          widget.onSettingsChanged(updatedSettings);

                          if (widget.onPlay != null) {
                            widget.onPlay!();
                          }
                        } else {
                          // Set isPlaying to false in the settings to update UI immediately
                          updatedSettings.musicSettings.isPlaying = false;
                          widget.onSettingsChanged(updatedSettings);

                          if (widget.onPause != null) {
                            widget.onPause!();
                          }
                        }
                      },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed:
                    musicSettings.currentTrack.isEmpty ||
                        widget.musicTracks.isEmpty
                    ? null
                    : () {
                        // Get next track in the list
                        final currentIndex = widget.musicTracks.indexOf(
                          musicSettings.currentTrack,
                        );
                        if (currentIndex < widget.musicTracks.length - 1) {
                          final nextTrack =
                              widget.musicTracks[currentIndex + 1];

                          if (widget.onTrackSelected != null) {
                            widget.onTrackSelected!(nextTrack);
                          }
                        }
                      },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Playback progress slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: widget.sliderColor,
                  inactiveTrackColor: widget.sliderColor.withValues(alpha: 0.3),
                  thumbColor: widget.sliderColor,
                ),
                child: Builder(
                  builder: (context) {
                    double displayDuration = musicSettings.duration;
                    double currentPosition = musicSettings.playbackPosition;

                    // Use default duration if none available
                    if (displayDuration <= 0) {
                      displayDuration = 100.0;
                    }

                    // Clamp position to valid range
                    currentPosition = currentPosition.clamp(
                      0.0,
                      displayDuration > 0 ? displayDuration : 100.0,
                    );

                    return Slider(
                      value: currentPosition,
                      min: 0,
                      max: displayDuration > 0 ? displayDuration : 100,
                      onChanged: (double value) {
                        if (widget.onSeek != null && displayDuration > 0) {
                          widget.onSeek!(value);
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Current position display
                    Text(
                      _formatDuration(musicSettings.playbackPosition),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Total duration display
                    Text(
                      musicSettings.duration > 0
                          ? _formatDuration(musicSettings.duration)
                          : '0:00',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Volume control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(width: 80, child: Text('Volume')),
              Expanded(
                child: Slider(
                  value: musicSettings.volume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  activeColor: widget.sliderColor,
                  label: '${(musicSettings.volume * 100).round()}%',
                  onChanged: (value) {
                    final updatedSettings = ShaderSettings.fromMap(
                      widget.settings.toMap(),
                    );
                    updatedSettings.musicSettings.volume = value;
                    widget.onSettingsChanged(updatedSettings);
                  },
                ),
              ),
              SizedBox(
                width: 50,
                child: Text('${(musicSettings.volume * 100).round()}%'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Loop control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LabeledSwitch(
            label: 'Loop Playback',
            value: musicSettings.loop,
            onChanged: (value) {
              final updatedSettings = ShaderSettings.fromMap(
                widget.settings.toMap(),
              );
              updatedSettings.musicSettings.loop = value;
              widget.onSettingsChanged(updatedSettings);
            },
          ),
        ),
      ],
    );
  }
}
