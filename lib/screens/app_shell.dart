import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import 'browse_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

// Main frame of the app. Responsive navigation:
//  - phone / small screen  -> bottom NavigationBar
//  - tablet / desktop      -> side NavigationRail
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  Widget _page() {
    switch (_index) {
      case 0:
        return HomeScreen(onBrowse: () => setState(() => _index = 1));
      case 1:
        return const BrowseScreen();
      case 2:
        return const LibraryView();
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MovieProvider>();
    final width = MediaQuery.of(context).size.width;
    final wide = width >= 800;
    final extended = width >= 1100;

    // Animated switch between tabs.
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey(_index), child: _page()),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.movie_filter, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Movie Explorer'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => p.toggleTheme(),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(p.isDark ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(p.isDark)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  extended: extended,
                  labelType: extended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: const [
                    NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home')),
                    NavigationRailDestination(
                        icon: Icon(Icons.search),
                        selectedIcon: Icon(Icons.search),
                        label: Text('Browse')),
                    NavigationRailDestination(
                        icon: Icon(Icons.bookmark_border),
                        selectedIcon: Icon(Icons.bookmark),
                        label: Text('Library')),
                    NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Profile')),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.search),
                    selectedIcon: Icon(Icons.search),
                    label: 'Browse'),
                NavigationDestination(
                    icon: Icon(Icons.bookmark_border),
                    selectedIcon: Icon(Icons.bookmark),
                    label: 'Library'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile'),
              ],
            ),
    );
  }
}
