import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_row.dart';
import '../widgets/poster_box.dart';
import '../widgets/rating_badge.dart';
import '../widgets/star_rating.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The movie is passed through Navigator.pushNamed(arguments: movie).
    final movie = ModalRoute.of(context)!.settings.arguments as Movie;
    final p = context.watch<MovieProvider>();
    final isFav = p.isFavorite(movie.id);
    final inList = p.inWatchlist(movie.id);
    final reviews = p.reviewsFor(movie.id);
    final avg = p.averageUserRating(movie.id);
    final muted = AppTheme.mutedText(context);

    void toast(String message) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 800;

          // Poster with Hero animation
          final poster = ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: PosterBox(movie: movie, heroTag: 'poster_${movie.id}'),
            ),
          );

          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.title,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(movie.tagline,
                  style: TextStyle(
                      fontSize: 16, fontStyle: FontStyle.italic, color: muted)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(icon: Icons.category, text: movie.genre),
                  _Pill(icon: Icons.calendar_today, text: '${movie.year}'),
                  _Pill(
                      icon: Icons.schedule,
                      text: '${movie.runtime ~/ 60}h ${movie.runtime % 60}m'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  RatingBadge(rating: movie.rating),
                  const SizedBox(width: 8),
                  Text('Critic score', style: TextStyle(color: muted)),
                ],
              ),
              if (avg != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    StarRating(rating: avg),
                    const SizedBox(width: 8),
                    Text('${avg.toStringAsFixed(1)}/5 from ${reviews.length} review(s)',
                        style: TextStyle(color: muted)),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              const Text('Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(movie.description, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 16),
              Text('Director: ${movie.director}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Text('Cast',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final name in movie.cast)
                    Chip(
                      avatar: CircleAvatar(child: Text(name[0])),
                      label: Text(name),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Action buttons
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      p.toggleFavorite(movie.id);
                      toast(isFav ? 'Removed from favorites' : 'Added to favorites');
                    },
                    // Heart icon animates when toggled.
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isFav)),
                    ),
                    label: Text(isFav ? 'Favorited' : 'Favorite'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      p.toggleWatchlist(movie.id);
                      toast(inList ? 'Removed from watchlist' : 'Added to watchlist');
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(inList ? Icons.bookmark : Icons.bookmark_border,
                          key: ValueKey(inList)),
                    ),
                    label: Text(inList ? 'In watchlist' : 'Watchlist'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/review', arguments: movie),
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Add Review'),
                  ),
                ],
              ),
            ],
          );

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 300, child: poster),
                            const SizedBox(width: 32),
                            Expanded(child: info),
                          ],
                        )
                      else ...[
                        Center(child: SizedBox(width: 220, child: poster)),
                        const SizedBox(height: 20),
                        info,
                      ],
                      const SizedBox(height: 32),

                      // Reviews
                      Text('Reviews (${reviews.length})',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      if (reviews.isEmpty)
                        Text('No reviews yet. Be the first!',
                            style: TextStyle(color: muted)),
                      for (final r in reviews)
                        Card(
                          color: AppTheme.cardColor(context),
                          child: ListTile(
                            leading: CircleAvatar(child: Text(r.name[0].toUpperCase())),
                            title: Text(r.name,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${r.comment}\n${r.recommends ? 'Recommends this movie' : 'Does not recommend'}  •  ${r.date.day}/${r.date.month}/${r.date.year}'),
                            isThreeLine: true,
                            trailing: StarRating(rating: r.rating.toDouble(), size: 16),
                          ),
                        ),
                      const SizedBox(height: 32),

                      // Similar movies
                      MovieRow(
                        title: 'You might also like',
                        movies: p.similarTo(movie),
                        hPad: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Small rounded label with an icon.
class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
