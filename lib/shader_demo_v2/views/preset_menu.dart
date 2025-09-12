import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../controllers/shader_controller.dart';
import '../models/preset.dart';
import '../services/thumbnail_service.dart';
import 'dart:math';
import 'dart:convert';

// Sorting options
enum SortMethod { dateNewest, alphabetical, reverseAlphabetical, random }

// View type options
enum ViewType { grid, list }

/// Enhanced preset menu with visual preview cards and view switcher
class PresetMenu extends StatefulWidget {
  const PresetMenu({Key? key}) : super(key: key);

  @override
  State<PresetMenu> createState() => _PresetMenuState();
}

class _PresetMenuState extends State<PresetMenu> {
  SortMethod _currentSort = SortMethod.dateNewest;
  ViewType _currentView = ViewType.grid;
  List<Preset> _sortedPresets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSortedPresets();
    });
  }

  void _updateSortedPresets() {
    final controller = context.read<ShaderController>();
    final presets = List<Preset>.from(controller.savedPresets);
    _sortPresets(presets);
    setState(() {
      _sortedPresets = presets;
    });
  }

  void _sortPresets(List<Preset> presets) {
    switch (_currentSort) {
      case SortMethod.dateNewest:
        presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortMethod.alphabetical:
        presets.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case SortMethod.reverseAlphabetical:
        presets.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case SortMethod.random:
        final random = Random();
        for (var i = presets.length - 1; i > 0; i--) {
          var j = random.nextInt(i + 1);
          var temp = presets[i];
          presets[i] = presets[j];
          presets[j] = temp;
        }
        break;
    }
  }

  void _changeSort(SortMethod method) {
    if (_currentSort != method) {
      setState(() {
        _currentSort = method;
      });
      _updateSortedPresets();
    }
  }

  void _changeView(ViewType view) {
    if (_currentView != view) {
      setState(() {
        _currentView = view;
      });
    }
  }

  Future<void> _handlePresetLoad(
    Preset preset,
    ShaderController controller,
  ) async {
    await controller.loadPreset(preset);
    Navigator.pop(context);
  }

  Future<void> _handlePresetDelete(
    Preset preset,
    ShaderController controller,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.deletePreset(preset.id);
      _updateSortedPresets();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preset "${preset.name}" deleted'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      /// Build thumbnail widget with on-demand generation
      Widget _buildThumbnailWidget(Preset preset) {
        // Always use contain to show complete image
        const BoxFit thumbnailFit = BoxFit.contain;

        if (preset.hasThumbnail) {
          // Show existing thumbnail from memory or storage
          final thumbnailData = preset.effectiveThumbnailBase64;
          if (thumbnailData != null) {
            return Image.memory(base64Decode(thumbnailData), fit: thumbnailFit);
          }
        }

        // Use FutureBuilder to generate thumbnail on-demand
        print('🖼️ [PresetMenu] Building thumbnail widget for: ${preset.name}');
        return FutureBuilder<String?>(
          future: ThumbnailService.getOrGenerateThumbnail(preset),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading indicator while generating
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              // Show generated thumbnail with correct fit mode
              return Image.memory(
                base64Decode(snapshot.data!),
                fit: thumbnailFit,
              );
            }

            // Fallback to placeholder
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.palette,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.black,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.95), Colors.black],
          ),
        ),
        child: Consumer<ShaderController>(
          builder: (context, controller, child) {
            // Update sorted presets when controller state changes
            if (_sortedPresets.length != controller.savedPresets.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateSortedPresets();
              });
            }

            return Column(
              children: [
                // App Bar replacement - positioned like standard navigation
                SafeArea(
                  bottom: false,
                  child: Container(
                    height: 56, // Standard AppBar height
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.9),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Saved Presets',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // View switcher and sort options
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // View switcher
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              'View:',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildViewToggle(theme),
                          ],
                        ),
                      ),

                      // Sort options
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text(
                          'Sort by:',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            _buildSortTag(
                              SortMethod.dateNewest,
                              'Date (Newest)',
                              theme,
                            ),
                            _buildSortTag(
                              SortMethod.alphabetical,
                              'A-Z',
                              theme,
                            ),
                            _buildSortTag(
                              SortMethod.reverseAlphabetical,
                              'Z-A',
                              theme,
                            ),
                            _buildSortTag(SortMethod.random, 'Random', theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: controller.savedPresets.isEmpty
                        ? _buildEmptyState(theme)
                        : _currentView == ViewType.grid
                        ? _buildGridView(size, controller)
                        : _buildListView(controller, theme),
                  ),
                ),

                // Quick save button if has unsaved changes
                if (controller.hasUnsavedChanges)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await controller.saveNamedPreset(
                          'Quick Save ${DateTime.now().millisecondsSinceEpoch}',
                        );
                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Quick Save Current Settings'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildViewToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(
            icon: Icons.grid_view,
            isSelected: _currentView == ViewType.grid,
            onTap: () => _changeView(ViewType.grid),
            theme: theme,
          ),
          _buildViewButton(
            icon: Icons.list,
            isSelected: _currentView == ViewType.list,
            onTap: () => _changeView(ViewType.list),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildSortTag(SortMethod method, String label, ThemeData theme) {
    final bool isSelected = method == _currentSort;
    final bool isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(
          label,
          style: isSelected
              ? theme.textTheme.labelLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                )
              : theme.textTheme.labelLarge,
        ),
        selected: isSelected,
        selectedColor: isDark
            ? Colors.black.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.85),
        backgroundColor: theme.colorScheme.surface,
        onSelected: (selected) {
          if (selected) {
            _changeSort(method);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No saved presets yet.',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust controls and save your first preset',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(Size size, ShaderController controller) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: size.width / size.height,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _sortedPresets.length,
      itemBuilder: (context, index) {
        final preset = _sortedPresets[index];
        return _buildPresetCard(preset, controller);
      },
    );
  }

  Widget _buildListView(ShaderController controller, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      itemCount: _sortedPresets.length,
      itemBuilder: (context, index) {
        final preset = _sortedPresets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: preset.hasThumbnail
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(preset.effectiveThumbnailBase64!),
                        fit: preset.settings.fillScreen
                            ? BoxFit.cover
                            : BoxFit.contain,
                      ),
                    )
                  : Icon(Icons.palette, color: theme.colorScheme.primary),
            ),
            title: Text(preset.name),
            subtitle: Text(preset.createdAt.toString().split(' ')[0]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _handlePresetDelete(preset, controller),
                ),
              ],
            ),
            onTap: () => _handlePresetLoad(preset, controller),
          ),
        );
      },
    );
  }

  Widget _buildPresetCard(Preset preset, ShaderController controller) {
    return InkWell(
      onTap: () => _handlePresetLoad(preset, controller),
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background - thumbnail or placeholder
            _buildThumbnailWidget(preset),

            // Overlay with name and delete button at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Preset name
                    Expanded(
                      child: Text(
                        preset.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Delete button
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _handlePresetDelete(preset, controller),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build thumbnail widget - shows existing thumbnails or placeholder
  /// Respects the original preset's fill/fit mode
  Widget _buildThumbnailWidget(Preset preset) {
    // Always use contain to show complete image
    const BoxFit thumbnailFit = BoxFit.contain;

    if (preset.hasThumbnail) {
      // Show existing thumbnail from memory or storage
      final thumbnailData = preset.effectiveThumbnailBase64;
      if (thumbnailData != null) {
        return Image.memory(base64Decode(thumbnailData), fit: thumbnailFit);
      }
    }

    // Show placeholder for presets without thumbnails
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.palette,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
