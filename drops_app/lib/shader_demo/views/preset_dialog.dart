import 'package:flutter/material.dart';
import '../models/shader_preset.dart';
import '../controllers/preset_controller.dart';
import '../models/effect_settings.dart';
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import '../controllers/custom_shader_widgets.dart';
import '../controllers/effect_controller.dart';

/// Dialog for saving a new preset
class SavePresetDialog extends StatefulWidget {
  final Function(String) onSave;

  const SavePresetDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  State<SavePresetDialog> createState() => _SavePresetDialogState();
}

class _SavePresetDialogState extends State<SavePresetDialog> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _hasUserEditedName = false;

  @override
  void initState() {
    super.initState();
    _loadAutomaticName();
  }

  Future<void> _loadAutomaticName() async {
    setState(() {
      _isLoading = true;
    });

    // Generate an automatic name
    final autoName = await PresetController.generateAutomaticPresetName();

    setState(() {
      _nameController.text = autoName;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Save Preset',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Preset Name',
                                hintText: 'Enter a name for your preset',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                labelStyle: TextStyle(color: Colors.white70),
                                hintStyle: TextStyle(color: Colors.white70),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                              autofocus: true,
                              onChanged: (text) {
                                setState(() {
                                  _hasUserEditedName = true;
                                });
                              },
                              onTap: () {
                                if (!_hasUserEditedName) {
                                  // Auto-select all text when first clicked
                                  _nameController.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: _nameController.text.length,
                                  );
                                  setState(() {
                                    _hasUserEditedName = true;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    widget.onSave(_nameController.text);
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for displaying and loading presets
class PresetsDialog extends StatefulWidget {
  final Function(ShaderPreset) onLoad;

  const PresetsDialog({Key? key, required this.onLoad}) : super(key: key);

  @override
  State<PresetsDialog> createState() => _PresetsDialogState();
}

class _PresetsDialogState extends State<PresetsDialog> {
  List<ShaderPreset> _presets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    setState(() {
      _isLoading = true;
    });

    final presets = await PresetController.getAllPresets();

    // Sort presets by created date (newest first)
    presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _presets = presets;
      _isLoading = false;
    });
  }

  void _handlePresetLoad(ShaderPreset preset) {
    // First create a clean deep copy of the preset settings to avoid reference issues
    final cleanSettings = ShaderSettings.fromMap(preset.settings.toMap());

    // Now call the onLoad callback with the clean settings
    widget.onLoad(preset.copyWith(settings: cleanSettings));

    // Close the dialog
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            children: [
              // Header with title and close button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    // Spacer to balance layout
                    const SizedBox(width: 48),
                    // Expanded space with centered title
                    Expanded(
                      child: Center(
                        child: Text(
                          'Saved Presets',
                          style: TextStyle(
                            fontSize: 20,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    // Close button
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  // Removed the background color to eliminate the scrim
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _presets.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No saved presets yet.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : _buildGridView(size),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the grid view of presets
  Widget _buildGridView(Size size) {
    return GridView.builder(
      // Adjusted padding to ensure content isn't clipped
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 0, right: 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: size.width / size.height,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _presets.length,
      itemBuilder: (context, index) {
        final preset = _presets[index];
        return _buildPresetItem(preset);
      },
    );
  }

  Widget _buildPresetItem(ShaderPreset preset) {
    return InkWell(
      onTap: () => _handlePresetLoad(preset),
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            preset.thumbnailData != null
                ? Image.memory(preset.thumbnailData!, fit: BoxFit.cover)
                : Image.asset(preset.imagePath, fit: BoxFit.cover),

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
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
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
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Preset'),
                            content: Text(
                              'Are you sure you want to delete "${preset.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await PresetController.deletePreset(preset.id);
                          _loadPresets();
                        }
                      },
                      child: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.white,
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
}
