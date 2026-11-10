import 'theme/polish.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/movie_provider.dart';
import 'screens/app_shell.dart';
import 'screens/details_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/login_screen.dart';
import 'screens/movie_form_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/review_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Open the browser storage before the app starts.
  final prefs = await SharedPreferences.getInstance();

  // ChangeNotifierProvider makes MovieProvider available to every screen.
  runApp(
    ChangeNotifierProvider(
      create: (_) => MovieProvider(prefs),
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
      theme: PolishedTheme.light,
darkTheme: PolishedTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      // Named routes (fixed pages)
      routes: {
        '/': (context) => const AuthGate(),
        '/favorites': (context) => const FavoritesScreen(),
        '/add-movie': (context) => const AuthGuard(child: MovieFormScreen()),
      },
      // Named routes that contain an id, e.g. /movie/3 or /movie/3/edit.
      // The movie is found from the id, so refreshing the page still works.
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => const NotFoundScreen(),
      ),
    );
  }
}

// /movie/<id>                  -> details
// /movie/<id>/edit             -> edit movie form
// /movie/<id>/review           -> new review
// /movie/<id>/review/<reviewId>-> edit review
Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  final parts = Uri.parse(settings.name ?? '/').pathSegments;
  Widget? page;

  if (parts.length >= 2 && parts[0] == 'movie') {
    final id = int.tryParse(parts[1]);
    if (id != null) {
      if (parts.length == 2) {
        page = DetailsScreen(movieId: id);
      } else if (parts.length == 3 && parts[2] == 'edit') {
        page = MovieFormScreen(movieId: id);
      } else if (parts.length == 3 && parts[2] == 'review') {
        page = ReviewScreen(movieId: id);
      } else if (parts.length == 4 && parts[2] == 'review') {
        page = ReviewScreen(movieId: id, reviewId: parts[3]);
      }
    }
  }

  if (page == null) return null; // falls back to onUnknownRoute
  final screen = page;
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => AuthGuard(child: screen),
  );
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

// Protects a page: if nobody is logged in (e.g. opening a link directly),
// the login screen is shown first, then the page.
class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final loggedIn =
        context.select<MovieProvider, bool>((p) => p.isLoggedIn);
    return loggedIn ? child : const LoginScreen();
  }
}
