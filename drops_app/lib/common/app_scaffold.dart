import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showBackButton;
  final bool showAppBar;
  final List<Widget>? appBarActions;
  final bool extendBodyBehindAppBar;
  final Color? appBarBackgroundColor;
  final double? appBarElevation;
  final int currentIndex;

  const AppScaffold({
    super.key,
    required this.body,
    this.title = '',
    this.showBackButton = false,
    this.showAppBar = true,
    this.appBarActions,
    this.extendBodyBehindAppBar = false,
    this.appBarBackgroundColor,
    this.appBarElevation,
    this.currentIndex = 1, // Default to Demos tab
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              backgroundColor: appBarBackgroundColor,
              elevation: appBarElevation,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        // Simply pop the current route when back button is pressed
                        Navigator.of(context).pop();
                      },
                    )
                  : null,
              actions: appBarActions,
            )
          : null,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: true,
      body: body,
      bottomNavigationBar: _buildBottomNavigationBar(context, currentIndex),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int selectedIndex) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface.withOpacity(0),
            theme.colorScheme.surface.withOpacity(0.8),
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
        currentIndex: selectedIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
        onTap: (index) => _handleNavigation(context, index, selectedIndex),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index, int currentIndex) {
    if (index == currentIndex) return;

    // Pop to root if there are multiple pages on stack
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Navigate to the root route with the selected index
    Navigator.of(context).pushReplacementNamed('/', arguments: index);
  }
}

// This is a helper class to navigate to the main screen with a specific tab
class MainScreenRoute extends StatelessWidget {
  final int initialIndex;

  const MainScreenRoute({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    // Use a builder pattern to avoid direct import of MainScreen
    // This helps prevent circular dependencies
    return Builder(
      builder: (context) {
        // Navigate to the main application with correct index
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
            arguments: initialIndex,
          );
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
