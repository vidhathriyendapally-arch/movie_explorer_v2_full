import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'screens/app_shell.dart';
import 'screens/details_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/login_screen.dart';
import 'screens/review_screen.dart';
import 'theme/app_theme.dart';

void main() {
  // ChangeNotifierProvider makes MovieProvider available to every screen.
  runApp(
    ChangeNotifierProvider(
      create: (_) => MovieProvider(),
      child: const MovieExplorerApp(),
    ),
  );
}

// Lets mouse users drag-scroll horizontal lists (Flutter web disables it by default).
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class MovieExplorerApp extends StatelessWidget {
  const MovieExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<MovieProvider>().isDark;

    return MaterialApp(
      title: 'Movie Explorer',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      // Named routes
      routes: {
        '/': (context) => const AuthGate(),
        '/details': (context) => const DetailsScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/review': (context) => const ReviewScreen(),
      },
    );
  }
}

// Shows the Login screen until the user logs in, then the main app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn =
        context.select<MovieProvider, bool>((p) => p.isLoggedIn);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: loggedIn
          ? const AppShell(key: ValueKey('shell'))
          : const LoginScreen(key: ValueKey('login')),
    );
  }
}
