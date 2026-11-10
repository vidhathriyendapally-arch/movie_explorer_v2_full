import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import 'poster_box.dart';
import 'rating_badge.dart';

// Opens the Details screen and remembers the movie as "recently viewed".
void openMovie(BuildContext context, Movie movie) {
  context.read<MovieProvider>().markViewed(movie.id);
    Navigator.pushNamed(context, '/movie/${movie.id}');
}

// Reusable movie card: fade-in on load, zoom on mouse hover, heart if favorite.
class MovieCard extends StatefulWidget {
  final Movie movie;
  final String? heroTag;
  const MovieCard({super.key, required this.movie, this.heroTag});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final isFav =
        context.select<MovieProvider, bool>((p) => p.isFavorite(movie.id));

    // Fade-in animation: opacity goes from 0 to 1.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
          scale: _hover ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Card(
            color: AppTheme.cardColor(context),
            elevation: _hover ? 8 : 1,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            child: InkWell(
              onTap: () => openMovie(context, movie),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child:
                                PosterBox(movie: movie, heroTag: widget.heroTag)),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: RatingBadge(rating: movie.rating),
                        ),
                        if (isFav)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                  color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.favorite,
                                  color: Colors.redAccent, size: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('${movie.year} • ${movie.genre}',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.mutedText(context))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
