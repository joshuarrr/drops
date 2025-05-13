import 'package:flutter/material.dart';
import 'theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'common/app_scaffold.dart';

class TypographyDemo extends StatefulWidget {
  const TypographyDemo({super.key});

  @override
  State<TypographyDemo> createState() => _TypographyDemoState();
}

class _TypographyDemoState extends State<TypographyDemo> {
  String _selectedFontFamily = 'Default';

  // Available font families to showcase
  final List<String> _fontFamilies = [
    'Default',
    'Roboto',
    'Helvetica',
    'Times New Roman',
    'Courier',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final textColor = theme.colorScheme.onSurface;
    final accentColor = theme.colorScheme.primary;

    // Theme toggle action for app bar
    final themeToggle = IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey<bool>(isDarkMode),
        ),
      ),
      onPressed: () {
        themeProvider.toggleTheme();
      },
    );

    return AppScaffold(
      title: 'Typography Demo',
      showBackButton: true,
      currentIndex: 1, // Demos tab
      appBarActions: [themeToggle],
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: theme.colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Font family selector
              _buildFontFamilySelector(textColor, accentColor, theme),
              const SizedBox(height: 24),

              // Material Typography Showcase
              _buildSectionHeader(
                'Material Typography',
                textColor,
                accentColor,
              ),
              _buildMaterialTypography(textColor),
              const SizedBox(height: 32),

              // Font Weight Showcase
              _buildSectionHeader('Font Weights', textColor, accentColor),
              _buildFontWeights(textColor),
              const SizedBox(height: 32),

              // Text Styling Showcase
              _buildSectionHeader('Text Styling', textColor, accentColor),
              _buildTextStyling(textColor, accentColor),
              const SizedBox(height: 32),

              // Text Alignment Showcase
              _buildSectionHeader('Text Alignment', textColor, accentColor),
              _buildTextAlignment(textColor, theme),
              const SizedBox(height: 32),

              // Lorem Ipsum Paragraph
              _buildSectionHeader('Text Paragraph', textColor, accentColor),
              _buildTextParagraph(textColor),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFontFamilySelector(
    Color textColor,
    Color accentColor,
    ThemeData theme,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          'Font Family:',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedFontFamily,
            dropdownColor: isDarkMode ? Colors.black87 : Colors.white,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: accentColor),
            underline: Container(height: 2, color: accentColor),
            style: TextStyle(color: textColor),
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedFontFamily = value;
                });
              }
            },
            items: _fontFamilies.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: value != 'Default'
                      ? TextStyle(fontFamily: value)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color textColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: accentColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: _selectedFontFamily == 'Default'
                ? null
                : _selectedFontFamily,
          ),
        ),
        Container(
          height: 2,
          width: 100,
          color: accentColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ],
    );
  }

  Widget _buildMaterialTypography(Color textColor) {
    final fontFamily = _selectedFontFamily == 'Default'
        ? null
        : _selectedFontFamily;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Headline Large',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Headline Medium',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Headline Small',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Title Large',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Body Large',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Body Medium',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Label Large',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildFontWeights(Color textColor) {
    final fontFamily = _selectedFontFamily == 'Default'
        ? null
        : _selectedFontFamily;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thin (w100)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w100,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Extra-Light (w200)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w200,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Light (w300)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Regular (w400)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Medium (w500)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bold (w700)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Extra-Bold (w800)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Black (w900)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildTextStyling(Color textColor, Color accentColor) {
    final fontFamily = _selectedFontFamily == 'Default'
        ? null
        : _selectedFontFamily;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Italic Text',
          style: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Underlined Text',
          style: TextStyle(
            fontSize: 18,
            decoration: TextDecoration.underline,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Line-through Text',
          style: TextStyle(
            fontSize: 18,
            decoration: TextDecoration.lineThrough,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Overline Text',
          style: TextStyle(
            fontSize: 18,
            decoration: TextDecoration.overline,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 18,
              color: textColor,
              fontFamily: fontFamily,
            ),
            children: [
              const TextSpan(text: 'Mixed '),
              TextSpan(
                text: 'styled ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const TextSpan(text: 'text with '),
              TextSpan(
                text: 'multiple ',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(text: 'formats'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextAlignment(Color textColor, ThemeData theme) {
    final fontFamily = _selectedFontFamily == 'Default'
        ? null
        : _selectedFontFamily;

    final isDarkMode = theme.brightness == Brightness.dark;
    final containerColor = isDarkMode ? Colors.grey[900] : Colors.grey[200];

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Left Aligned Text',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Center Aligned Text',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Right Aligned Text',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'This is justified text that spans multiple lines to demonstrate how justified alignment works in Flutter typography.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextParagraph(Color textColor) {
    final fontFamily = _selectedFontFamily == 'Default'
        ? null
        : _selectedFontFamily;

    return Text(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla facilisi. Maecenas auctor, nisl eget interdum accumsan, nisi nisl aliquam nisl, eget aliquet nunc nisl eu nisl. Donec euismod, nisl eget aliquam aliquet, nisl nisl aliquam nisl, eget aliquet nunc nisl eu nisl. Donec euismod, nisl eget aliquam aliquet, nisl nisl aliquam nisl, eget aliquet nunc nisl eu nisl.',
      style: TextStyle(
        fontSize: 16,
        color: textColor,
        height: 1.5, // Line height
        fontFamily: fontFamily,
      ),
    );
  }
}
