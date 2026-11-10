import 'package:flutter/material.dart';
import '../models/movie.dart';

// Gradient "poster" with the movie title. Fills whatever space its parent gives.
// compact = just the first letter (for tiny thumbnails).
// heroTag = poster flies between screens (Hero animation).
class PosterBox extends StatelessWidget {
  final Movie movie;
  final String? heroTag;
  final bool compact;
  final bool showTitle;

  const PosterBox({
    super.key,
    required this.movie,
    this.heroTag,
    this.compact = false,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (compact) {
      content = Center(
        child: Text(movie.title[0],
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      );
    } else {
      content = Stack(
        children: [
          // Big faded icon in the corner for a "poster" feel.
          Positioned(
            right: -14,
            bottom: -14,
            child: Icon(Icons.movie_creation,
                size: 110, color: Colors.white.withAlpha(30)),
          ),
          if (showTitle)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.movie, color: Colors.white70, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      movie.title,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movie.genre.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    final poster = Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [movie.poster, Color.lerp(movie.poster, Colors.black, 0.6)!],
          ),
        ),
        child: content,
      ),
    );
    return heroTag == null ? poster : Hero(tag: heroTag!, child: poster);
  }
}
