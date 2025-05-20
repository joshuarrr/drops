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

class _PresetsDialogState extends State<PresetsDialog>
    with SingleTickerProviderStateMixin {
  List<ShaderPreset> _presets = [];
  bool _isLoading = true;

  // Add shared animation controller for shader previews
  late AnimationController _shaderAnimationController;

  @override
  void initState() {
    super.initState();

    // Create shared animation controller for shader animations
    _shaderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    // Start continuous animation
    _shaderAnimationController.repeat();

    _loadPresets();
  }

  @override
  void dispose() {
    // Dispose animation controller
    _shaderAnimationController.dispose();

    super.dispose();
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
    final topPadding = MediaQuery.of(context).padding.top;

    // Define app bar height to match the app's toolbar height
    const appBarHeight = kToolbarHeight;

    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            // Header that matches app bar size and position
            Container(
              height: appBarHeight + topPadding,
              padding: EdgeInsets.only(top: topPadding),
              child: Row(
                children: [
                  // Spacer to balance layout
                  SizedBox(width: 48),
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
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                color: Colors.black.withOpacity(0.4),
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
    );
  }

  // Build the grid view of presets
  Widget _buildGridView(Size size) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Use MiniShaderPreview with the shared controller
              child: MiniShaderPreview(
                preset: preset,
                sharedController: _shaderAnimationController,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
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
              Material(
                color: Colors.transparent,
                child: InkWell(
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
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mini preview widget for rendering a shader effect from a preset's settings
class MiniShaderPreview extends StatefulWidget {
  final ShaderPreset preset;
  final AnimationController? sharedController;

  const MiniShaderPreview({
    Key? key,
    required this.preset,
    this.sharedController,
  }) : super(key: key);

  @override
  State<MiniShaderPreview> createState() => _MiniShaderPreviewState();
}

class _MiniShaderPreviewState extends State<MiniShaderPreview>
    with SingleTickerProviderStateMixin {
  AnimationController? _localController;

  // Use either the shared controller or a local one
  AnimationController get _controller =>
      widget.sharedController ?? _localController!;

  @override
  void initState() {
    super.initState();

    // Only create a local controller if no shared one was provided
    if (widget.sharedController == null) {
      _localController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10),
      );
      _localController!.repeat();
    }
  }

  @override
  void dispose() {
    // Only dispose the local controller if we created one
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animationValue = _controller.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Base image with effects
            Container(
              color: Colors.black,
              child: EffectController.applyEffects(
                child: Image.asset(widget.preset.imagePath, fit: BoxFit.cover),
                settings: widget.preset.settings,
                animationValue: animationValue,
              ),
            ),

            // Text overlay if enabled
            if (widget.preset.settings.textLayoutSettings.textEnabled)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.preset.settings.textLayoutSettings.textTitle.isNotEmpty
                      ? widget.preset.settings.textLayoutSettings.textTitle
                      : widget.preset.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black.withOpacity(0.7),
                        offset: const Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }
}
