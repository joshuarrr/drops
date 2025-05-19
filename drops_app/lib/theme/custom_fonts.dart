import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:io';

/// Custom fonts from non-Google sources
class CustomFonts {
  static const String lemonFontFamily = 'Lemon';

  // League of Moveable Type fonts
  static const String leagueGothicFamily = 'League Gothic';
  static const String leagueSpartanFamily = 'League Spartan';
  static const String leagueScriptFamily = 'League Script';
  static const String ostrichSansFamily = 'Ostrich Sans';
  static const String ostrichSansInlineFamily = 'Ostrich Sans Inline';
  static const String ostrichSansRoundedFamily = 'Ostrich Sans Rounded';
  static const String ostrichSansDashedFamily = 'Ostrich Sans Dashed';
  static const String orbitronFamily = 'Orbitron';
  static const String knewaveFamily = 'Knewave';
  static const String junctionFamily = 'Junction';
  static const String goudyBookletterFamily = 'Goudy Bookletter 1911';
  static const String goudyStMFamily = 'GoudyStM';
  static const String blackoutSunriseFamily = 'Blackout Sunrise';
  static const String blackoutMidnightFamily = 'Blackout Midnight';
  static const String blackoutTwoAmFamily = 'Blackout Two AM';
  static const String snigletFamily = 'Sniglet';
  static const String lindenHillFamily = 'Linden Hill';

  // Kyiv Type variable fonts
  static const String kyivTypeSansFamily = 'Kyiv Type Sans';
  static const String kyivTypeSerifFamily = 'Kyiv Type Serif';
  static const String kyivTypeTitlingFamily = 'Kyiv Type Titling';

  // Additional Fontesk fonts
  static const String valiantFamily = 'Valiant';
  static const String starlanceFamily = 'Starlance';
  static const String farabeeFamily = 'Farabee';
  static const String farabeeStraightFamily = 'Farabee Straight';
  static const String superJellyfishFamily = 'Super Jellyfish';
  static const String vaganovSpDemoFamily = 'Vaganov SP Demo';
  static const String ballastStencilFamily = 'Ballast Stencil';
  static const String parajanovFamily = 'Parajanov';
  static const String martiusFamily = 'Martius';
  static const String superBraveFamily = 'Super Brave';
  static const String canalhaFamily = 'Canalha';
  static const String beastFamily = 'Beast';
  static const String lettertypeFamily = 'Lettertype';
  static const String fnOctahedronFamily = 'FN Octahedron';
  static const String dotMatrixDuoFamily = 'DotMatrix Duo';
  static const String tintagelFamily = 'Tintagel';
  static const String gotfridusFamily = 'Gotfridus';
  static const String ltBasixFamily = 'LT Basix';
  static const String moltenDisplayFamily = 'Molten Display';
  static const String triformFamily = 'Triform';
  static const String groutpixFlowSerifFamily = 'Groutpix Flow Serif';
  static const String rhombicFamily = 'Rhombic';
  static const String noseTransportFamily = 'Nose Transport';
  static const String outrightFamily = 'Outright';
  static const String moonetFamily = 'Moonet';
  static const String mykaFamily = 'MYKA Tryba';
  static const String frontlineFamily = 'Frontline';
  static const String jaroFamily = 'Jaro';
  static const String teaTypeFamily = 'Tea Type';
  static const String molokoFamily = 'Moloko';
  static const String tachyoFamily = 'Tachyo';
  static const String scornFamily = 'Scorn';
  static const String fasadFamily = 'Fasad';
  static const String kreaseFamily = 'Krease';
  static const String beonFamily = 'Beon';
  static const String gademsFamily = 'Gadems';
  static const String grishaFamily = 'Grisha';
  static const String desertaFamily = 'Deserta';
  static const String neonSansFamily = 'Neon Sans';
  static const String rookworstFamily = 'Rookworst';
  static const String deadenderFamily = 'Deadender';
  static const String klaxonsFamily = 'Klaxons';
  static const String starwayFamily = 'Starway';

  // Font URLs - using CDN sources that support CORS
  static const Map<String, String> fontUrls = {
    'Lemon':
        'https://fontlibrary.org/assets/fonts/lemon/7d50c9c6576dc993ade0c468f3036ba3/684996e569a2f97407ef168b29f5a05f/LemonRegular.ttf',
    'League Gothic':
        'https://cdn.jsdelivr.net/gh/theleagueof/league-gothic@master/webfonts/leaguegothic-regular-webfont.woff',
    'League Spartan':
        'https://cdn.jsdelivr.net/gh/theleagueof/league-spartan@master/webfonts/leaguespartan-bold-webfont.woff',
    'League Script':
        'https://cdn.jsdelivr.net/gh/theleagueof/league-script-number-one@master/webfonts/LeagueScriptNumberOne-webfont.woff',
    'Ostrich Sans':
        'https://cdn.jsdelivr.net/gh/theleagueof/ostrich-sans@master/webfonts/ostrichsans-bold-webfont.woff',
    'Ostrich Sans Inline':
        'https://cdn.jsdelivr.net/gh/theleagueof/ostrich-sans@master/webfonts/ostrichsans-inline-regular.woff',
    'Ostrich Sans Rounded':
        'https://cdn.jsdelivr.net/gh/theleagueof/ostrich-sans@master/webfonts/ostrichsans-rounded.woff',
    'Ostrich Sans Dashed':
        'https://cdn.jsdelivr.net/gh/theleagueof/ostrich-sans@master/webfonts/ostrichsans-dashed.woff',
    'Orbitron':
        'https://cdn.jsdelivr.net/gh/theleagueof/orbitron@master/webfonts/orbitron-medium-webfont.woff',
    'Knewave':
        'https://cdn.jsdelivr.net/gh/theleagueof/knewave@master/webfonts/knewave-webfont.woff',
    'Junction':
        'https://cdn.jsdelivr.net/gh/theleagueof/junction@master/webfonts/junction-regular.woff',
    'Goudy Bookletter 1911':
        'https://cdn.jsdelivr.net/gh/theleagueof/goudy-bookletter-1911@master/webfonts/goudy_bookletter_1911-webfont.woff',
    'GoudyStM':
        'https://cdn.jsdelivr.net/gh/theleagueof/sorts-mill-goudy@master/webfonts/GoudyStM-webfont.woff',
    'Blackout Sunrise':
        'https://cdn.jsdelivr.net/gh/theleagueof/blackout@master/webfonts/blackout_sunrise-webfont.woff',
    'Blackout Midnight':
        'https://cdn.jsdelivr.net/gh/theleagueof/blackout@master/webfonts/blackout_midnight-webfont.woff',
    'Blackout Two AM':
        'https://cdn.jsdelivr.net/gh/theleagueof/blackout@master/webfonts/blackout_two_am-webfont.woff',
    'Sniglet':
        'https://cdn.jsdelivr.net/gh/theleagueof/sniglet@master/webfonts/Sniglet-webfont.woff',
    'Linden Hill':
        'https://cdn.jsdelivr.net/gh/theleagueof/linden-hill@master/webfonts/LindenHill-webfont.woff',
  };

  // Local font paths - relative to assets directory
  static const Map<String, String> localFontPaths = {
    'League Gothic': 'fonts/league/LeagueGothic-Regular.ttf',
    'League Spartan': 'fonts/league/LeagueSpartan-VF.ttf',
    'League Script': 'fonts/league/LeagueScriptNumberOne-webfont.ttf',
    'Ostrich Sans': 'fonts/league/ostrich-sans-regular.ttf',
    'Ostrich Sans Inline': 'fonts/league/ostrich-sans-inline-regular.ttf',
    'Ostrich Sans Rounded': 'fonts/league/ostrich-sans-rounded.ttf',
    'Ostrich Sans Dashed': 'fonts/league/ostrich-sans-dashed.ttf',
    'Orbitron': 'fonts/league/Orbitron Medium.ttf',
    'Knewave': 'fonts/league/knewave.ttf',
    'Junction': 'fonts/league/junction-regular.ttf',
    'Goudy Bookletter 1911': 'fonts/league/goudy_bookletter_1911-webfont.ttf',
    'GoudyStM': 'fonts/league/GoudyStM-webfont.ttf',
    'Blackout Sunrise': 'fonts/league/blackout_sunrise-webfont.ttf',
    'Blackout Midnight': 'fonts/league/blackout_midnight-webfont.ttf',
    'Blackout Two AM': 'fonts/league/blackout_two_am-webfont.ttf',
    'Sniglet': 'fonts/league/Sniglet-webfont.ttf',
    'Linden Hill': 'fonts/league/LindenHill-webfont.ttf',
    'Kyiv Type Sans':
        'fonts/fontesk/KyivType-VariableGX/KyivTypeSans-VarGX.ttf',
    'Kyiv Type Serif':
        'fonts/fontesk/KyivType-VariableGX/KyivTypeSerif-VarGX.ttf',
    'Kyiv Type Titling':
        'fonts/fontesk/KyivType-VariableGX/KyivTypeTitling-VarGX.ttf',
  };

  /// Register web fonts for Flutter web
  static Future<void> loadFonts() async {
    // Web fonts are loaded via CSS in web apps
    // For non-web platforms, we still rely on the pubspec.yaml definitions
  }

  /// Get font CSS for web
  static String getFontFaceCss() {
    final buffer = StringBuffer();

    // Add Lemon font from FontLibrary
    buffer.write('''
      @font-face { 
        font-family: 'Lemon'; 
        src: url('${fontUrls['Lemon']}') format('truetype');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
    ''');

    // Add League of Moveable Type fonts
    buffer.write('''
      @font-face { 
        font-family: 'League Gothic'; 
        src: url('${fontUrls['League Gothic']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'League Spartan'; 
        src: url('${fontUrls['League Spartan']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'League Script'; 
        src: url('${fontUrls['League Script']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Ostrich Sans'; 
        src: url('${fontUrls['Ostrich Sans']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Ostrich Sans Inline'; 
        src: url('${fontUrls['Ostrich Sans Inline']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Ostrich Sans Rounded'; 
        src: url('${fontUrls['Ostrich Sans Rounded']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Ostrich Sans Dashed'; 
        src: url('${fontUrls['Ostrich Sans Dashed']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Orbitron'; 
        src: url('${fontUrls['Orbitron']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Knewave'; 
        src: url('${fontUrls['Knewave']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Junction'; 
        src: url('${fontUrls['Junction']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Goudy Bookletter 1911'; 
        src: url('${fontUrls['Goudy Bookletter 1911']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'GoudyStM'; 
        src: url('${fontUrls['GoudyStM']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Blackout Sunrise'; 
        src: url('${fontUrls['Blackout Sunrise']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Blackout Midnight'; 
        src: url('${fontUrls['Blackout Midnight']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Blackout Two AM'; 
        src: url('${fontUrls['Blackout Two AM']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Sniglet'; 
        src: url('${fontUrls['Sniglet']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
      
      @font-face { 
        font-family: 'Linden Hill'; 
        src: url('${fontUrls['Linden Hill']}') format('woff');
        font-weight: normal; 
        font-style: normal;
        font-display: swap;
      }
    ''');

    return buffer.toString();
  }
}

/// Stub class to match the WebFonts API for non-web platforms
class WebFonts {
  /// Initialize is a no-op on non-web platforms
  static void initialize() {
    // Do nothing on non-web platforms since fonts are loaded from pubspec.yaml
  }
}

/// Font definition for the Lemon font from FontLibrary
class LemonFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.lemonFontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for League Gothic from The League of Moveable Type
class LeagueGothicFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.leagueGothicFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for League Spartan from The League of Moveable Type
class LeagueSpartanFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.leagueSpartanFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Ostrich Sans from The League of Moveable Type
class OstrichSansFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.ostrichSansFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle bold({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.ostrichSansFamily,
      fontWeight: FontWeight.bold,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle light({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.ostrichSansFamily,
      fontWeight: FontWeight.w300,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle black({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.ostrichSansFamily,
      fontWeight: FontWeight.w900,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle medium({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.ostrichSansFamily,
      fontWeight: FontWeight.w500,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle heavy({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.ostrichSansFamily,
      fontWeight: FontWeight.w800,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Orbitron from The League of Moveable Type
class OrbitronFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.orbitronFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle medium({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.orbitronFamily,
      fontWeight: FontWeight.w500,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle light({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.orbitronFamily,
      fontWeight: FontWeight.w300,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle bold({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.orbitronFamily,
      fontWeight: FontWeight.bold,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle black({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.orbitronFamily,
      fontWeight: FontWeight.w900,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Knewave from The League of Moveable Type
class KnewaveFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.knewaveFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle outline({
    Color? color,
    double? fontSize,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.knewaveFamily,
      fontStyle: FontStyle.italic, // Using italic to represent outline variant
      color: color,
      fontSize: fontSize,
      decoration: decoration,
    );
  }
}

/// Font definition for Junction from The League of Moveable Type
class JunctionFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.junctionFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle light({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.junctionFamily,
      fontWeight: FontWeight.w300,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle bold({
    Color? color,
    double? fontSize,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.junctionFamily,
      fontWeight: FontWeight.bold,
      color: color,
      fontSize: fontSize,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Goudy Bookletter 1911 from The League of Moveable Type
class GoudyBookletterFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.goudyBookletterFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Blackout Sunrise from The League of Moveable Type
class BlackoutSunriseFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.blackoutSunriseFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Blackout Midnight from The League of Moveable Type
class BlackoutMidnightFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.blackoutMidnightFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Blackout Two AM from The League of Moveable Type
class BlackoutTwoAmFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.blackoutTwoAmFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Sniglet from The League of Moveable Type
class SnigletFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.snigletFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Linden Hill from The League of Moveable Type
class LindenHillFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.lindenHillFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle italic({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.lindenHillFamily,
      fontStyle: FontStyle.italic,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
    );
  }
}

/// Font definition for League Script from The League of Moveable Type
class LeagueScriptFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.leagueScriptFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Ostrich Sans Inline from The League of Moveable Type
class OstrichSansInlineFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.ostrichSansInlineFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle italic({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.ostrichSansInlineFamily,
      fontStyle: FontStyle.italic,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
    );
  }
}

/// Font definition for Ostrich Sans Rounded from The League of Moveable Type
class OstrichSansRoundedFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.ostrichSansRoundedFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for Ostrich Sans Dashed from The League of Moveable Type
class OstrichSansDashedFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.ostrichSansDashedFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }
}

/// Font definition for GoudyStM from The League of Moveable Type
class GoudyStMFont {
  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.goudyStMFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle italic({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: CustomFonts.goudyStMFamily,
      fontStyle: FontStyle.italic,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
    );
  }
}

/// Font definition for Kyiv Type Sans
class KyivTypeSansFont {
  // Variable font axes
  static const String weightAxis = 'wght';
  static const String widthAxis = 'wdth';
  static const String contrastAxis = 'CONT';
  static const String italicAxis = 'slnt';

  // Check if this font is a variable font
  static bool get isVariableFont => true;

  // Get the available axes for this variable font
  static List<String> get availableAxes => [
    weightAxis,
    // widthAxis and contrastAxis are defined but may not work correctly
    // in the current implementation. Uncomment after testing.
    widthAxis,
    contrastAxis,
  ];

  // Get the available axes as a map with details about each axis
  static Map<String, Map<String, dynamic>> get availableAxesInfo => {
    weightAxis: {
      'name': 'Weight',
      'min': 100.0,
      'max': 1000.0,
      'default': 400.0,
    },
    widthAxis: {'name': 'Width', 'min': 1.0, 'max': 1000.0, 'default': 100.0},
    contrastAxis: {
      'name': 'Contrast',
      'min': 1.0,
      'max': 1000.0,
      'default': 100.0,
    },
  };

  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? weightValue,
    double? widthValue,
    double? contrastValue,
    double? italicValue,
  }) {
    final fontVariations = <ui.FontVariation>[];

    // Add weight variation if specified (default to 400 for regular)
    if (weightValue != null) {
      fontVariations.add(ui.FontVariation(weightAxis, weightValue));
    } else if (fontWeight != null) {
      // Convert FontWeight to numeric value (100-900)
      final weightNumeric = (fontWeight.index + 1) * 100;
      fontVariations.add(
        ui.FontVariation(weightAxis, weightNumeric.toDouble()),
      );
    } else {
      fontVariations.add(ui.FontVariation(weightAxis, 400));
    }

    // Add width variation if specified
    if (widthValue != null) {
      fontVariations.add(ui.FontVariation(widthAxis, widthValue));
    }

    // Add contrast variation if specified
    if (contrastValue != null) {
      fontVariations.add(ui.FontVariation(contrastAxis, contrastValue));
    }

    // Add italic variation if specified
    if (italicValue != null) {
      fontVariations.add(ui.FontVariation(italicAxis, italicValue));
    } else if (fontStyle == FontStyle.italic) {
      fontVariations.add(
        ui.FontVariation(italicAxis, -10),
      ); // Typical slant value
    }

    return TextStyle(
      fontFamily: CustomFonts.kyivTypeSansFamily,
      color: color,
      fontSize: fontSize,
      fontVariations: fontVariations,
      decoration: decoration,
    );
  }
}

/// Font definition for Kyiv Type Serif
class KyivTypeSerifFont {
  // Variable font axes
  static const String weightAxis = 'wght';
  static const String widthAxis = 'wdth';
  static const String contrastAxis = 'CONT';
  static const String italicAxis = 'slnt';

  // Check if this font is a variable font
  static bool get isVariableFont => true;

  // Get the available axes for this variable font
  static List<String> get availableAxes => [
    weightAxis,
    // widthAxis and contrastAxis are defined but may not work correctly
    // in the current implementation. Uncomment after testing.
    widthAxis,
    contrastAxis,
  ];

  // Get the available axes as a map with details about each axis
  static Map<String, Map<String, dynamic>> get availableAxesInfo => {
    weightAxis: {
      'name': 'Weight',
      'min': 100.0,
      'max': 1000.0,
      'default': 400.0,
    },
    widthAxis: {'name': 'Width', 'min': 1.0, 'max': 1000.0, 'default': 100.0},
    contrastAxis: {
      'name': 'Contrast',
      'min': 1.0,
      'max': 1000.0,
      'default': 100.0,
    },
  };

  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? weightValue,
    double? widthValue,
    double? contrastValue,
    double? italicValue,
  }) {
    final fontVariations = <ui.FontVariation>[];

    // Add weight variation if specified (default to 400 for regular)
    if (weightValue != null) {
      fontVariations.add(ui.FontVariation(weightAxis, weightValue));
    } else if (fontWeight != null) {
      // Convert FontWeight to numeric value (100-900)
      final weightNumeric = (fontWeight.index + 1) * 100;
      fontVariations.add(
        ui.FontVariation(weightAxis, weightNumeric.toDouble()),
      );
    } else {
      fontVariations.add(ui.FontVariation(weightAxis, 400));
    }

    // Add width variation if specified
    if (widthValue != null) {
      fontVariations.add(ui.FontVariation(widthAxis, widthValue));
    }

    // Add contrast variation if specified
    if (contrastValue != null) {
      fontVariations.add(ui.FontVariation(contrastAxis, contrastValue));
    }

    // Add italic variation if specified
    if (italicValue != null) {
      fontVariations.add(ui.FontVariation(italicAxis, italicValue));
    } else if (fontStyle == FontStyle.italic) {
      fontVariations.add(
        ui.FontVariation(italicAxis, -10),
      ); // Typical slant value
    }

    return TextStyle(
      fontFamily: CustomFonts.kyivTypeSerifFamily,
      color: color,
      fontSize: fontSize,
      fontVariations: fontVariations,
      decoration: decoration,
    );
  }
}

/// Font definition for Kyiv Type Titling
class KyivTypeTitlingFont {
  // Variable font axes
  static const String weightAxis = 'wght';
  static const String widthAxis = 'wdth';
  static const String contrastAxis = 'CONT';
  static const String italicAxis = 'slnt';

  // Check if this font is a variable font
  static bool get isVariableFont => true;

  // Get the available axes for this variable font
  static List<String> get availableAxes => [
    weightAxis,
    // Width axis from font info - may not work as expected
    widthAxis,
    // Contrast axis has only 3 distinct values according to font info
    contrastAxis,
  ];

  // Get the available axes as a map with details about each axis
  static Map<String, Map<String, dynamic>> get availableAxesInfo => {
    weightAxis: {
      'name': 'Weight',
      'min': 0.0, // From font info: starts at 0.0, not 100.0
      'max': 1000.0,
      'default': 350.0, // Default to Regular (350.0) weight
      'stops': [
        0.0,
        200.0,
        350.0,
        500.0,
        700.0,
        840.0,
        1000.0,
      ], // Named instances
    },
    widthAxis: {'name': 'Width', 'min': 0.0, 'max': 1000.0, 'default': 100.0},
    // Contrast has only 3 discrete values
    contrastAxis: {
      'name': 'Contrast',
      'min': 0.0,
      'max': 1000.0,
      'default': 0.0,
      'stops': [0.0, 500.0, 1000.0], // Only 3 effective values
      'description':
          'This font supports only low (0), medium (500), and high (1000) contrast values',
    },
  };

  static TextStyle regular({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? weightValue,
    double? widthValue,
    double? contrastValue,
    double? italicValue,
  }) {
    final fontVariations = <ui.FontVariation>[];

    // Add weight variation if specified (default to 350 for regular)
    if (weightValue != null) {
      fontVariations.add(ui.FontVariation(weightAxis, weightValue));
    } else if (fontWeight != null) {
      // Map standard FontWeight to the font's named instances
      double mappedWeight;
      switch (fontWeight) {
        case FontWeight.w100:
          mappedWeight = 0.0; // Thin
          break;
        case FontWeight.w200:
          mappedWeight = 200.0; // Light
          break;
        case FontWeight.w300:
        case FontWeight.w400:
          mappedWeight = 350.0; // Regular
          break;
        case FontWeight.w500:
          mappedWeight = 500.0; // Medium
          break;
        case FontWeight.w600:
        case FontWeight.w700:
          mappedWeight = 700.0; // Bold
          break;
        case FontWeight.w800:
          mappedWeight = 840.0; // Heavy
          break;
        case FontWeight.w900:
          mappedWeight = 1000.0; // Black
          break;
        default:
          mappedWeight = 350.0; // Default to Regular
      }
      fontVariations.add(ui.FontVariation(weightAxis, mappedWeight));
    } else {
      fontVariations.add(
        ui.FontVariation(weightAxis, 350.0),
      ); // Default to Regular
    }

    // Add width variation if specified
    if (widthValue != null) {
      fontVariations.add(ui.FontVariation(widthAxis, widthValue));
    }

    // Add contrast variation if specified
    if (contrastValue != null) {
      // Map to the 3 discrete values
      double mappedContrast;
      if (contrastValue < 350) {
        mappedContrast = 0.0; // Low
      } else if (contrastValue < 650) {
        mappedContrast = 500.0; // Medium
      } else {
        mappedContrast = 1000.0; // High
      }
      fontVariations.add(ui.FontVariation(contrastAxis, mappedContrast));
    }

    // Add italic variation if specified (Note: Titling may not support italic)
    if (italicValue != null) {
      fontVariations.add(ui.FontVariation(italicAxis, italicValue));
    } else if (fontStyle == FontStyle.italic) {
      fontVariations.add(
        ui.FontVariation(italicAxis, -10),
      ); // Typical slant value
    }

    return TextStyle(
      fontFamily: CustomFonts.kyivTypeTitlingFamily,
      color: color,
      fontSize: fontSize,
      fontVariations: fontVariations,
      decoration: decoration,
    );
  }
}
