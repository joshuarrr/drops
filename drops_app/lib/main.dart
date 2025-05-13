import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'common/app_scaffold.dart';
import 'demos_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'shader_demo/controllers/effect_controller.dart';
import 'shader_demo/controllers/custom_shader_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations and full screen mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);

  // Check for debug mode flags in environment variables
  final bool isVerboseDebugMode =
      Platform.environment.containsKey('FLUTTER_LOG_LEVEL') &&
      Platform.environment['FLUTTER_LOG_LEVEL'] == 'verbose';

  final bool isShaderDebugMode = Platform.environment.containsKey(
    'ENABLE_SHADER_DEBUG',
  );

  // Configure shader debugging based on debug mode
  enableShaderDebugLogs = isVerboseDebugMode || isShaderDebugMode;

  if (enableShaderDebugLogs) {
    print("Shader debugging enabled");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Drops App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AnimatedThemeBuilder(),
      onGenerateRoute: (settings) {
        // Handle main route with initialIndex parameter
        if (settings.name == '/') {
          final int initialIndex = settings.arguments as int? ?? 1;
          return MaterialPageRoute(
            builder: (context) =>
                AnimatedThemeBuilder(initialIndex: initialIndex),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AnimatedThemeBuilder extends StatelessWidget {
  final int initialIndex;

  const AnimatedThemeBuilder({super.key, this.initialIndex = 1});

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: Theme.of(context),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: MainScreen(initialIndex: initialIndex),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 1});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static final List<Widget> _screens = [
    const GradientScreen(),
    const DemosScreen(),
    const ThemesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _screens[_selectedIndex],
      extendBody: true,
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.background.withOpacity(0),
              theme.colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Demos'),
            BottomNavigationBarItem(icon: Icon(Icons.palette), label: 'Themes'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onBackground.withOpacity(0.5),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final isLightMode = themeProvider.themeMode == ThemeMode.light;
    final isSystemMode = themeProvider.themeMode == ThemeMode.system;

    return AppScaffold(
      title: 'Theme Settings',
      currentIndex: 2, // Themes tab
      showBackButton: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Theme',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Theme mode options
              _buildThemeOption(
                context,
                title: 'Light Theme',
                subtitle: 'Use light theme always',
                icon: Icons.light_mode,
                isSelected: isLightMode,
                onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              ),

              const SizedBox(height: 16),

              _buildThemeOption(
                context,
                title: 'Dark Theme',
                subtitle: 'Use dark theme always',
                icon: Icons.dark_mode,
                isSelected: isDarkMode,
                onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              ),

              const SizedBox(height: 16),

              _buildThemeOption(
                context,
                title: 'System Default',
                subtitle: 'Follow system theme settings',
                icon: Icons.settings_suggest,
                isSelected: isSystemMode,
                onTap: () => themeProvider.setThemeMode(ThemeMode.system),
              ),

              const SizedBox(height: 32),

              // Preview section
              const Text(
                'Preview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPreviewSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    child: Text(title),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    child: Text(subtitle),
                  ),
                ],
              ),
            ),
            if (isSelected)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Typography showcase
          Text('Display Large', style: theme.textTheme.displayLarge),
          Text('Headline Medium', style: theme.textTheme.headlineMedium),
          Text('Title Large', style: theme.textTheme.titleLarge),
          Text('Body Large', style: theme.textTheme.bodyLarge),
          Text('Label Small', style: theme.textTheme.labelSmall),

          const SizedBox(height: 16),

          // Buttons preview
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              const SizedBox(width: 8),
              TextButton(onPressed: () {}, child: const Text('Text')),
            ],
          ),

          const SizedBox(height: 16),

          // Interactive controls preview
          Row(
            children: [
              Switch(value: true, onChanged: (_) {}),
              const SizedBox(width: 16),
              Expanded(child: Slider(value: 0.5, onChanged: (_) {})),
            ],
          ),

          const SizedBox(height: 16),

          // TextField preview
          TextField(
            decoration: InputDecoration(
              labelText: 'Input',
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Color samples
          Row(
            children: [
              _buildColorSample(
                'Primary',
                theme.colorScheme.primary,
                theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              _buildColorSample(
                'Surface',
                theme.colorScheme.surface,
                theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              _buildColorSample(
                'Background',
                theme.colorScheme.background,
                theme.colorScheme.onBackground,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSample(String label, Color color, Color textColor) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          child: Text(label),
        ),
      ),
    );
  }
}

class GradientScreen extends StatefulWidget {
  const GradientScreen({super.key});

  @override
  State<GradientScreen> createState() => _GradientScreenState();
}

class _GradientScreenState extends State<GradientScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Gradient colors based on theme
    final List<Color> gradientColors = isDarkMode
        ? [Colors.black, Colors.grey[800]!, Colors.black]
        : [Colors.white, Colors.grey[300]!, Colors.white];

    return AppScaffold(
      title: 'Home',
      currentIndex: 0, // Home tab
      showBackButton: false,
      extendBodyBehindAppBar: true,
      appBarBackgroundColor: Colors.transparent,
      appBarElevation: 0,
      body: FadeTransition(
        opacity: _animation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              child: const Text('Drops App'),
            ),
          ),
        ),
      ),
    );
  }
}
