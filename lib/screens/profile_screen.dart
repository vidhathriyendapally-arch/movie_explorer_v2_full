import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/star_rating.dart';
import '../widgets/stat_tile.dart';

// Profile tab: user info, stats, settings and the user's own reviews.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _restoreMovies(BuildContext context, MovieProvider p) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDialog(
      context,
      title: 'Restore default movies?',
      message:
          'Movies you added are removed, deleted ones come back and edits are undone. '
          'Favorites, watchlist and reviews of removed movies are cleared.',
      confirmLabel: 'Restore',
    );
    if (!ok) return;
    p.restoreDefaultMovies();
    messenger.showSnackBar(const SnackBar(content: Text('Default movies restored')));
  }

  Widget _reviewCard(BuildContext context, MovieProvider p, Review r) {
    final movie = p.movieById(r.movieId);
    if (movie == null) return const SizedBox.shrink();
    return Card(
      color: AppTheme.cardColor(context),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, '/movie/${movie.id}'),
        title: Text(movie.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StarRating(rating: r.rating.toDouble(), size: 16),
            const SizedBox(height: 2),
            Text(r.comment),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.pushNamed(
                  context, '/movie/${movie.id}/review/${r.id}');
            } else {
              final ok = await confirmDialog(context,
                  title: 'Delete your review?',
                  message: 'This cannot be undone.');
              if (ok) p.deleteReview(r.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MovieProvider>();
    final scheme = Theme.of(context).colorScheme;
    final initial = p.userName.isEmpty ? '?' : p.userName[0].toUpperCase();
    final reviews = p.myReviews;

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
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text('Add a movie'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/add-movie'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.restore),
                        title: const Text('Restore default movies'),
                        onTap: () => _restoreMovies(context, p),
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

                // Reviews written by the current user
                const Text('Your reviews',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                if (reviews.isEmpty)
                  Text('You have not written any reviews yet.',
                      style: TextStyle(color: AppTheme.mutedText(context))),
                for (final r in reviews) _reviewCard(context, p, r),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
