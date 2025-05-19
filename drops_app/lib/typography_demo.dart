import 'package:flutter/material.dart';
import 'theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'common/app_scaffold.dart';
import 'common/variable_font_control.dart';
// Explicitly import all the font classes from custom_fonts.dart
import 'theme/custom_fonts.dart'
    show
        CustomFonts,
        LemonFont,
        LeagueGothicFont,
        LeagueSpartanFont,
        LeagueScriptFont,
        OstrichSansFont,
        OstrichSansInlineFont,
        OstrichSansRoundedFont,
        OstrichSansDashedFont,
        OrbitronFont,
        KnewaveFont,
        JunctionFont,
        GoudyBookletterFont,
        GoudyStMFont,
        BlackoutSunriseFont,
        BlackoutMidnightFont,
        BlackoutTwoAmFont,
        SnigletFont,
        LindenHillFont,
        KyivTypeSansFont,
        KyivTypeSerifFont,
        KyivTypeTitlingFont;

class TypographyDemo extends StatefulWidget {
  const TypographyDemo({super.key});

  @override
  State<TypographyDemo> createState() => _TypographyDemoState();
}

class _TypographyDemoState extends State<TypographyDemo> {
  String _selectedFontFamily = 'Alumni Sans';
  String? _selectedFoundry;

  @override
  void initState() {
    super.initState();
    // Set Fontesk as the initially selected foundry to showcase the new fonts
    _selectedFoundry = 'Fontesk';
    // Initial font from Fontesk collection
    _selectedFontFamily = 'Valiant';

    // For debugging - log the font families
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugPrintFontFamilies();
    });
  }

  // Debug method to test font registration
  void _debugPrintFontFamilies() {
    print(
      '\n\nFONTESK FONTS IN FONTINFO: ${_fontInfo.entries.where((e) => e.value['foundry'] == 'Fontesk').length}',
    );
    print(
      'FONTESK FONTS IN _fontFamilies: ${_fontFamilies.where((f) => _fontInfo[f]?['foundry'] == 'Fontesk').length}',
    );
  }

  // Font foundry information with URLs
  final Map<String, Map<String, String>> _fontInfo = {
    // Google fonts
    'Averia Serif Libre': {'foundry': 'Google', 'url': ''},
    'Alumni Sans': {'foundry': 'Google', 'url': ''},
    'Anaheim': {'foundry': 'Google', 'url': ''},
    'Danfo': {'foundry': 'Google', 'url': ''},
    'Bree Serif': {'foundry': 'Google', 'url': ''},
    'Young Serif': {'foundry': 'Google', 'url': ''},
    'Oxanium': {'foundry': 'Google', 'url': ''},
    'Geist Mono': {'foundry': 'Google', 'url': ''},
    'MuseoModerno': {'foundry': 'Google', 'url': ''},
    'DM Serif Display': {'foundry': 'Google', 'url': ''},
    'Lexend Deca': {'foundry': 'Google', 'url': ''},
    'Pixelify Sans': {'foundry': 'Google', 'url': ''},
    'Gemunu Libre': {'foundry': 'Google', 'url': ''},
    'Podkova': {'foundry': 'Google', 'url': ''},
    'Tourney': {'foundry': 'Google', 'url': ''},
    'Instrument Serif': {'foundry': 'Google', 'url': ''},
    'Tektur': {'foundry': 'Google', 'url': ''},
    'Asap Condensed': {'foundry': 'Google', 'url': ''},
    // League of Moveable Type fonts
    'League Gothic': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/league-gothic',
    },
    'League Spartan': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/league-spartan',
    },
    'League Script': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/league-script-number-one',
    },
    'Ostrich Sans': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/ostrich-sans',
    },
    'Ostrich Sans Inline': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/ostrich-sans',
    },
    'Ostrich Sans Rounded': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/ostrich-sans',
    },
    'Ostrich Sans Dashed': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/ostrich-sans',
    },
    'Orbitron': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/orbitron',
    },
    'Knewave': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/knewave',
    },
    'Junction': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/junction',
    },
    'Goudy Bookletter 1911': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/goudy-bookletter-1911',
    },
    'GoudyStM': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/sorts-mill-goudy',
    },
    'Blackout Sunrise': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/blackout',
    },
    'Blackout Midnight': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/blackout',
    },
    'Blackout Two AM': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/blackout',
    },
    'Sniglet': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/sniglet',
    },
    'Linden Hill': {
      'foundry': 'League',
      'url': 'https://www.theleagueofmoveabletype.com/linden-hill',
    },
    // Kyiv Type fonts
    'Kyiv Type Sans': {
      'foundry': 'Fontesk',
      'url': 'https://www.fontesk.com/kyiv-type-font/',
    },
    'Kyiv Type Serif': {
      'foundry': 'Fontesk',
      'url': 'https://www.fontesk.com/kyiv-type-font/',
    },
    'Kyiv Type Titling': {
      'foundry': 'Fontesk',
      'url': 'https://www.fontesk.com/kyiv-type-font/',
    },
    // Additional Fontesk fonts
    'Valiant': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Starlance': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Farabee': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Farabee Straight': {
      'foundry': 'Fontesk',
      'url': 'https://www.fontesk.com/',
    },
    'Super Jellyfish': {
      'foundry': 'Fontesk',
      'url': 'https://www.fontesk.com/',
    },
    'Vaganov SP Demo': {
      'foundry': 'Fontesk',
      'url': 'https://www.fontesk.com/',
    },
    'Ballast Stencil': {
      'foundry': 'Fontesk',
      'url': 'https://www.fontesk.com/',
    },
    'Parajanov': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Martius': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Super Brave': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Canalha': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Beast': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Lettertype': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'FN Octahedron': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'DotMatrix Duo': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Tintagel': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Gotfridus': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'LT Basix': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Molten Display': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Triform': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Groutpix Flow Serif': {
      'foundry': 'Fontesk',
      'url': 'https://www.fontesk.com/',
    },
    'Rhombic': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Nose Transport': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Outright': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Moonet': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'MYKA Tryba': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Frontline': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Jaro': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Tea Type': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Moloko': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Tachyo': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Scorn': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Fasad': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Krease': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Beon': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Gadems': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Grisha': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Deserta': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Neon Sans': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Rookworst': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Deadender': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Klaxons': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
    'Starway': {'foundry': 'Fontesk', 'url': 'https://www.fontesk.com/'},
  };

  // Available font families to showcase
  final List<String> _fontFamilies = [
    'Averia Serif Libre',
    'Alumni Sans',
    'Anaheim',
    'Danfo',
    'Bree Serif',
    'Young Serif',
    'Oxanium',
    'Geist Mono',
    'MuseoModerno',
    'DM Serif Display',
    'Lexend Deca',
    'Pixelify Sans',
    'Gemunu Libre',
    'Podkova',
    'Tourney',
    'Instrument Serif',
    'Tektur',
    'Asap Condensed',
    'Lemon',
    // League fonts
    'Orbitron',
    'League Gothic',
    'League Spartan',
    'League Script',
    'Ostrich Sans',
    'Ostrich Sans Inline',
    'Ostrich Sans Rounded',
    'Ostrich Sans Dashed',
    'Knewave',
    'Junction',
    'Goudy Bookletter 1911',
    'GoudyStM',
    'Blackout Sunrise',
    'Blackout Midnight',
    'Blackout Two AM',
    'Sniglet',
    'Linden Hill',
    // Kyiv Type fonts
    'Kyiv Type Sans',
    'Kyiv Type Serif',
    'Kyiv Type Titling',
    // Additional Fontesk fonts
    'Valiant',
    'Starlance',
    'Farabee',
    'Farabee Straight',
    'Super Jellyfish',
    'Vaganov SP Demo',
    'Ballast Stencil',
    'Parajanov',
    'Martius',
    'Super Brave',
    'Canalha',
    'Beast',
    'Lettertype',
    'FN Octahedron',
    'DotMatrix Duo',
    'Tintagel',
    'Gotfridus',
    'LT Basix',
    'Molten Display',
    'Triform',
    'Groutpix Flow Serif',
    'Rhombic',
    'Nose Transport',
    'Outright',
    'Moonet',
    'MYKA Tryba',
    'Frontline',
    'Jaro',
    'Tea Type',
    'Moloko',
    'Tachyo',
    'Scorn',
    'Fasad',
    'Krease',
    'Beon',
    'Gadems',
    'Grisha',
    'Deserta',
    'Neon Sans',
    'Rookworst',
    'Deadender',
    'Klaxons',
    'Starway',
  ];

  // Available foundries
  List<String> get _foundries {
    final foundries = _fontInfo.values
        .map((info) => info['foundry']!)
        .toSet()
        .toList();
    foundries.sort();
    return foundries;
  }

  // Filtered font families based on selected foundry
  List<String> get _filteredFontFamilies {
    if (_selectedFoundry == null) {
      return _fontFamilies;
    }

    // Find any fonts that are missing from _fontInfo
    final missingFonts = _fontFamilies
        .where((font) => !_fontInfo.containsKey(font))
        .toList();
    if (missingFonts.isNotEmpty) {
      print('WARNING: These fonts are missing from _fontInfo: $missingFonts');
    }

    final filteredFonts = _fontFamilies
        .where((font) => _fontInfo[font]?['foundry'] == _selectedFoundry)
        .toList();

    // Debug print for Fontesk foundry
    if (_selectedFoundry == 'Fontesk') {
      print('FONTESK FONTS COUNT: ${filteredFonts.length}');
      print('FONTESK FONTS: ${filteredFonts.join(', ')}');
    }

    return filteredFonts;
  }

  // Variable font axis values for each font family
  final Map<String, Map<String, double>> _fontVariations = {
    'Kyiv Type Sans': {'wght': 400.0, 'wdth': 100.0, 'CONT': 100.0},
    'Kyiv Type Serif': {'wght': 400.0, 'wdth': 100.0, 'CONT': 100.0},
    'Kyiv Type Titling': {'wght': 400.0, 'wdth': 100.0, 'CONT': 100.0},
  };

  // Method to check if a font is a variable font
  bool _isVariableFont(String family) {
    return family == CustomFonts.kyivTypeSansFamily ||
        family == CustomFonts.kyivTypeSerifFamily ||
        family == CustomFonts.kyivTypeTitlingFamily;
  }

  // Update font variation value and refresh display
  void _updateFontVariationValue(String axis, double value) {
    setState(() {
      if (_fontVariations.containsKey(_selectedFontFamily)) {
        // Simply set the value directly - continuous range
        _fontVariations[_selectedFontFamily]![axis] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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

    final textColor = theme.colorScheme.onSurface;

    return AppScaffold(
      title: 'Typography Demo',
      showBackButton: true,
      currentIndex: 1,
      appBarActions: [themeToggle],
      body: Center(
        child: Column(
          children: [
            // Filter tags section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      'Filter by Foundry:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        _buildFoundryTag(null, 'All', theme),
                        ..._foundries.map(
                          (foundry) =>
                              _buildFoundryTag(foundry, foundry, theme),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Variable font control section - only shown for variable fonts
            if (_isVariableFont(_selectedFontFamily))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildVariableFontControls(theme),
              ),

            // Font list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ..._filteredFontFamilies.map((font) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          font,
                          textAlign: TextAlign.center,
                          style: _safeFontStyle(font, theme, textColor),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoundryTag(String? foundry, String label, ThemeData theme) {
    final bool isSelected = foundry == _selectedFoundry;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: foundry == _selectedFoundry,
        selectedColor: theme.colorScheme.primary.withOpacity(0.8),
        backgroundColor: theme.colorScheme.surface,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFoundry = foundry;
            });
          }
        },
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

  TextStyle _safeFontStyle(String family, ThemeData theme, Color defaultColor) {
    // Check if this is a Fontesk font
    if (_fontInfo[family]?['foundry'] == 'Fontesk') {
      // Use direct TextStyle for Fontesk fonts
      return TextStyle(
        fontFamily: family,
        fontSize: 24,
        color: defaultColor,
        height: 1.2,
      );
    }

    // Special case for fonts from other foundries
    if (_fontInfo[family]?['foundry'] != 'Google') {
      // Font Library fonts
      if (family == 'Lemon') {
        return LemonFont.regular(color: defaultColor, fontSize: 24);
      }

      // The League of Moveable Type fonts
      if (family == 'League Gothic') {
        return LeagueGothicFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'League Spartan') {
        return LeagueSpartanFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'League Script') {
        return LeagueScriptFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Ostrich Sans') {
        return OstrichSansFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Ostrich Sans Inline') {
        return OstrichSansInlineFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Ostrich Sans Rounded') {
        return OstrichSansRoundedFont.regular(
          color: defaultColor,
          fontSize: 24,
        );
      }
      if (family == 'Ostrich Sans Dashed') {
        return OstrichSansDashedFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Orbitron') {
        return OrbitronFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Knewave') {
        return KnewaveFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Junction') {
        return JunctionFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Goudy Bookletter 1911') {
        return GoudyBookletterFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'GoudyStM') {
        return GoudyStMFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Blackout Sunrise') {
        return BlackoutSunriseFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Blackout Midnight') {
        return BlackoutMidnightFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Blackout Two AM') {
        return BlackoutTwoAmFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Sniglet') {
        return SnigletFont.regular(color: defaultColor, fontSize: 24);
      }
      if (family == 'Linden Hill') {
        return LindenHillFont.regular(color: defaultColor, fontSize: 24);
      }

      // Kyiv Type fonts - variable fonts
      if (family == 'Kyiv Type Sans') {
        final variations = _fontVariations[family];
        return KyivTypeSansFont.regular(
          color: defaultColor,
          fontSize: 24,
          weightValue: variations?['wght'],
          widthValue: variations?['wdth'],
          contrastValue: variations?['CONT'],
        );
      }
      if (family == 'Kyiv Type Serif') {
        final variations = _fontVariations[family];
        return KyivTypeSerifFont.regular(
          color: defaultColor,
          fontSize: 24,
          weightValue: variations?['wght'],
          widthValue: variations?['wdth'],
          contrastValue: variations?['CONT'],
        );
      }
      if (family == 'Kyiv Type Titling') {
        final variations = _fontVariations[family];
        return KyivTypeTitlingFont.regular(
          color: defaultColor,
          fontSize: 24,
          weightValue: variations?['wght'],
          widthValue: variations?['wdth'],
          contrastValue: variations?['CONT'],
        );
      }
    }

    try {
      // Try to load from Google Fonts
      return GoogleFonts.getFont(
        family,
        textStyle: theme.textTheme.headlineMedium?.copyWith(
          color: defaultColor,
        ),
      );
    } catch (_) {
      // google_fonts doesn't have this family – fall back to plain TextStyle
      return theme.textTheme.headlineMedium?.copyWith(
            color: defaultColor,
            fontFamily: family,
          ) ??
          TextStyle(fontSize: 24, color: defaultColor, fontFamily: family);
    }
  }

  // Build variable font controls based on current selected font
  Widget _buildVariableFontControls(ThemeData theme) {
    final textColor = theme.colorScheme.onSurface;
    final accentColor = theme.colorScheme.primary;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Variable Font Controls',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedFontFamily.contains('Kyiv Type')) ...[
              // Weight Axis Slider
              _buildAxisSlider(
                'Weight',
                'wght',
                100,
                900,
                _fontVariations[_selectedFontFamily]!['wght'] ?? 400,
                textColor,
                accentColor,
              ),

              // Width Axis Slider
              _buildAxisSlider(
                'Width',
                'wdth',
                75,
                125,
                _fontVariations[_selectedFontFamily]!['wdth'] ?? 100,
                textColor,
                accentColor,
              ),

              // Contrast Axis Slider
              _buildAxisSlider(
                'Contrast',
                'CONT',
                0,
                1000,
                _fontVariations[_selectedFontFamily]!['CONT'] ?? 100,
                textColor,
                accentColor,
              ),

              const SizedBox(height: 16),
              // Font preview
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: accentColor.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sample Text - АаБбВв',
                    style: _safeFontStyle(
                      _selectedFontFamily,
                      theme,
                      textColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Build a slider for a specific axis
  Widget _buildAxisSlider(
    String label,
    String axis,
    int min,
    int max,
    double value,
    Color textColor,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            Text(value.toInt().toString(), style: TextStyle(color: textColor)),
          ],
        ),
        Slider(
          value: value,
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: accentColor,
          onChanged: (newValue) {
            _updateFontVariationValue(axis, newValue);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
