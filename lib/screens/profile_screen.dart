import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/movies.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';
import '../widgets/stat_tile.dart';

// Profile tab: user info, stats, settings and the user's reviews.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MovieProvider>();
    final scheme = Theme.of(context).colorScheme;
    final initial = p.userName.isEmpty ? '?' : p.userName[0].toUpperCase();
    final reviews = p.allReviews;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    child: Text(initial,
                        style: const TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(p.userName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                Text(p.userEmail.isEmpty ? 'Guest account' : p.userEmail,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.mutedText(context))),
                const SizedBox(height: 20),

                // Stats
                Row(
                  children: [
                    Expanded(
                        child: StatTile(
                            icon: Icons.favorite,
                            label: 'Favorites',
                            value: p.favoriteMovies.length)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: StatTile(
                            icon: Icons.bookmark,
                            label: 'Watchlist',
                            value: p.watchlistMovies.length)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: StatTile(
                            icon: Icons.rate_review,
                            label: 'Reviews',
                            value: reviews.length)),
                  ],
                ),
                const SizedBox(height: 20),

                // Settings
                Card(
                  color: AppTheme.cardColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: scheme.outline),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.dark_mode),
                        title: const Text('Dark mode'),
                        value: p.isDark,
                        onChanged: (_) => p.toggleTheme(),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text('My favorites'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/favorites'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Log out'),
                        onTap: () => p.logout(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Reviews written by the user
                const Text('Your reviews',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                if (reviews.isEmpty)
                  Text('You have not written any reviews yet.',
                      style: TextStyle(color: AppTheme.mutedText(context))),
                for (final r in reviews)
                  Card(
                    color: AppTheme.cardColor(context),
                    child: ListTile(
                      title: Text(
                          allMovies.firstWhere((m) => m.id == r.movieId).title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(r.comment),
                      trailing: StarRating(rating: r.rating.toDouble(), size: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
