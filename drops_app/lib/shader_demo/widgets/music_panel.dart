import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

import '../models/effect_settings.dart';
import '../models/music_settings.dart';
import '../models/shader_effect.dart';
import '../views/effect_controls.dart';
import '../controllers/effect_controller.dart';
import 'labeled_slider.dart';
import 'labeled_switch.dart';
import 'panel_header.dart';

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
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
    this.musicTracks = const [],
    this.onTrackSelected,
    this.onPlay,
    this.onPause,
    this.onSeek,
  }) : super(key: key);

  @override
  State<MusicPanel> createState() => _MusicPanelState();
}

class _MusicPanelState extends State<MusicPanel> {
  // Add a simple log method
  void _log(String message, {LogLevel level = LogLevel.info}) {
    // Use the EffectLogger to log messages
    EffectLogger.log('[MusicPanel] $message', level: level);
  }

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
                  value: musicSettings.currentTrack.isNotEmpty
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
                      _log(
                        'TRACK SELECTION CHANGED from "${musicSettings.currentTrack}" to "$newValue"',
                        level: LogLevel.info,
                      );

                      // First update settings with new track
                      final updatedSettings = ShaderSettings.fromMap(
                        widget.settings.toMap(),
                      );
                      updatedSettings.musicSettings.currentTrack = newValue;

                      // If music was playing, set isPlaying to true so the new track will start
                      // Otherwise, keep it false
                      final wasPlaying = musicSettings.isPlaying;
                      _log('Previous track was playing: $wasPlaying');
                      updatedSettings.musicSettings.isPlaying = wasPlaying;

                      // Apply settings changes
                      widget.onSettingsChanged(updatedSettings);

                      // Call the track selection callback which will start playing if needed
                      if (widget.onTrackSelected != null) {
                        _log(
                          'Calling onTrackSelected with new track: $newValue',
                        );
                        widget.onTrackSelected!(newValue);
                      } else {
                        _log(
                          'WARNING: onTrackSelected callback is null',
                          level: LogLevel.warning,
                        );
                      }
                    } else if (newValue == musicSettings.currentTrack) {
                      _log('Same track selected, ignoring: $newValue');
                    } else {
                      _log('No track selected (null value)');
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

                          // Important: Make sure we're explicitly calling the onTrackSelected callback
                          if (widget.onTrackSelected != null) {
                            widget.onTrackSelected!(prevTrack);
                          }
                        }
                      },
              ),
              IconButton(
                iconSize: 48,
                icon: Icon(
                  musicSettings.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
                onPressed: musicSettings.currentTrack.isEmpty
                    ? null
                    : () {
                        final updatedSettings = ShaderSettings.fromMap(
                          widget.settings.toMap(),
                        );
                        final bool shouldPlay = !musicSettings.isPlaying;
                        updatedSettings.musicSettings.isPlaying = shouldPlay;
                        widget.onSettingsChanged(updatedSettings);

                        if (shouldPlay) {
                          if (widget.onPlay != null) {
                            widget.onPlay!();
                          }
                        } else {
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

                          // Important: Make sure we're explicitly calling the onTrackSelected callback
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

        // Playback progress slider - ALWAYS SHOW
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: widget.sliderColor,
                  inactiveTrackColor: widget.sliderColor.withOpacity(0.3),
                  thumbColor: widget.sliderColor,
                ),
                child: Slider(
                  value: musicSettings.duration > 0
                      ? musicSettings.playbackPosition.clamp(
                          0,
                          musicSettings.duration,
                        )
                      : 0,
                  min: 0,
                  max: musicSettings.duration > 0
                      ? musicSettings.duration
                      : 100,
                  onChanged: (double value) {
                    if (widget.onSeek != null && musicSettings.duration > 0) {
                      widget.onSeek!(value);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      musicSettings.duration > 0
                          ? _formatDuration(musicSettings.playbackPosition)
                          : '0:00',
                    ),
                    Text(
                      musicSettings.duration > 0
                          ? _formatDuration(musicSettings.duration)
                          : '0:00',
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

                    // Call the controller method directly
                    EffectControls.setMusicVolume(value);
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

        // Autoplay control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LabeledSwitch(
            label: 'Autoplay',
            value: musicSettings.autoplay,
            onChanged: (value) {
              final updatedSettings = ShaderSettings.fromMap(
                widget.settings.toMap(),
              );
              updatedSettings.musicSettings.autoplay = value;
              widget.onSettingsChanged(updatedSettings);
            },
          ),
        ),
      ],
    );
  }
}
