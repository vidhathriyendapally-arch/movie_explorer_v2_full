import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_card.dart';
import 'poster_box.dart';
import 'rating_badge.dart';

// Big auto-sliding banner for featured movies, with dots below.
class FeaturedCarousel extends StatefulWidget {
  final List<Movie> movies;
  const FeaturedCarousel({super.key, required this.movies});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // Slide automatically every 4 seconds.
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients || widget.movies.isEmpty) return;
      final next = (_page + 1) % widget.movies.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _slide(Movie m) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => openMovie(context, m),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PosterBox(movie: m, showTitle: false),
              // Dark fade at the bottom so the text is readable.
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RatingBadge(rating: m.rating),
                        const SizedBox(width: 10),
                        Text('${m.year} • ${m.genre}',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(m.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                    Text(m.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => openMovie(context, m),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('View details'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 270,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.movies.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => _slide(widget.movies[i]),
          ),
        ),
        const SizedBox(height: 12),
        // Animated dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.movies.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withAlpha(70),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
