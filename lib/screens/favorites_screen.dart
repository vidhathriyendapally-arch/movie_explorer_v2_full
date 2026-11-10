import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';
import '../widgets/poster_box.dart';
import '../widgets/rating_badge.dart';

// Standalone page for the '/favorites' route.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: const LibraryView(),
    );
  }
}

// Two tabs: Favorites and Watchlist. Also used inside the Library tab of the shell.
class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MovieProvider>();
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: scheme.onSurface,
            indicatorColor: scheme.primary,
            tabs: [
              Tab(
                  icon: const Icon(Icons.favorite),
                  text: 'Favorites (${p.favoriteMovies.length})'),
              Tab(
                  icon: const Icon(Icons.bookmark),
                  text: 'Watchlist (${p.watchlistMovies.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _MovieList(
                  movies: p.favoriteMovies,
                  emptyIcon: Icons.favorite_border,
                  emptyText: 'No favorites yet.\nTap the heart on a movie!',
                  onRemove: (m) => p.toggleFavorite(m.id),
                ),
                _MovieList(
                  movies: p.watchlistMovies,
                  emptyIcon: Icons.bookmark_border,
                  emptyText: 'Your watchlist is empty.\nSave movies to watch later.',
                  onRemove: (m) => p.toggleWatchlist(m.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieList extends StatelessWidget {
  final List<Movie> movies;
  final IconData emptyIcon;
  final String emptyText;
  final void Function(Movie) onRemove;

  const _MovieList({
    required this.movies,
    required this.emptyIcon,
    required this.emptyText,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 64, color: AppTheme.mutedText(context)),
            const SizedBox(height: 8),
            Text(emptyText, textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: movies.length,
          itemBuilder: (context, i) {
            final m = movies[i];
            // Swipe left to remove (works on touch screens).
            return Dismissible(
              key: ValueKey(m.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => onRemove(m),
              background: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.only(right: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                color: AppTheme.cardColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                child: ListTile(
                  leading: SizedBox(
                    width: 52,
                    height: 52,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: PosterBox(movie: m, compact: true),
                    ),
                  ),
                  title: Text(m.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${m.year} • ${m.genre} • ${m.runtime} min'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RatingBadge(rating: m.rating),
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onRemove(m),
                      ),
                    ],
                  ),
                  onTap: () => openMovie(context, m),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
