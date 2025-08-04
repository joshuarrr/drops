import 'package:flutter/material.dart';

import '../models/image_category.dart';

/// A compact control that lets the user pick between the "covers" and
/// "artists" image categories and then choose a concrete image inside the
/// active category.
///
/// The widget is intentionally kept stateless – the owner manages the selected
/// values and passes them back in via the constructor.
class ImageSelector extends StatelessWidget {
  const ImageSelector({
    super.key,
    required this.category,
    required this.coverImages,
    required this.artistImages,
    required this.selectedImage,
    required this.onCategoryChanged,
    required this.onImageSelected,
  });

  /// Currently selected category.
  final ImageCategory category;

  /// All available cover art image asset paths (sorted).
  final List<String> coverImages;

  /// All available artist image asset paths (sorted).
  final List<String> artistImages;

  /// Currently selected image asset path (must be contained in either list).
  final String selectedImage;

  /// Callback whenever the category changes.
  final ValueChanged<ImageCategory> onCategoryChanged;

  /// Callback whenever the user taps a thumbnail.
  final ValueChanged<String> onImageSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = category == ImageCategory.covers
        ? coverImages
        : artistImages;

    return Column(
      children: [
        _CategoryToggle(category: category, onChanged: onCategoryChanged),
        const SizedBox(height: 12),
        if (images.isEmpty)
          Text(
            'No images',
            style: TextStyle(color: theme.colorScheme.onSurface),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: images.map((path) {
              final bool isSelected = path == selectedImage;
              return GestureDetector(
                onTap: () {
                  print('DEBUG: Image selector tapped: $path');
                  onImageSelected(path);
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Image.asset(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('DEBUG: Error loading thumbnail: $path - $error');
                      return Container(
                        color: Colors.grey[800],
                        child: Icon(Icons.broken_image, color: Colors.white),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _CategoryToggle extends StatelessWidget {
  const _CategoryToggle({required this.category, required this.onChanged});

  final ImageCategory category;
  final ValueChanged<ImageCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRadio(ImageCategory.covers, 'Covers', textColor),
        const SizedBox(width: 24),
        _buildRadio(ImageCategory.artists, 'Artists', textColor),
      ],
    );
  }

  Widget _buildRadio(ImageCategory value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Theme(
          data: ThemeData(
            radioTheme: RadioThemeData(
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return color;
                }
                return color.withOpacity(0.5);
              }),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          ),
          child: Radio<ImageCategory>(
            value: value,
            groupValue: category,
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
            activeColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
