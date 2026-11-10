import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/genre_chip.dart';
import '../widgets/movie_row.dart';
import '../widgets/section_header.dart';

// Home tab: greeting, featured banner, genre shortcuts and movie rows.
class HomeScreen extends StatelessWidget {
  final VoidCallback onBrowse;
  const HomeScreen({super.key, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MovieProvider>();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${p.userName}',
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w800)),
                      Text('What are you watching today?',
                          style: TextStyle(color: AppTheme.mutedText(context))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FeaturedCarousel(movies: p.topRated.take(5).toList()),
                const SizedBox(height: 24),

                // Genre shortcuts: tap one to jump to Browse with that filter.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Explore by genre'),
                      const SizedBox(height: 10),
                      Wrap(
                        runSpacing: 8,
                        children: [
                          for (final g in p.genres.where((g) => g != 'All'))
                            GenreChip(
                              label: g,
                              selected: false,
                              onTap: () {
                                p.setGenre(g);
                                onBrowse();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                MovieRow(
                    title: 'Trending Now',
                    subtitle: 'The highest rated picks',
                    movies: p.trending,
                    onSeeAll: onBrowse),
                const SizedBox(height: 24),
                MovieRow(
                    title: 'Recently Viewed',
                    subtitle: 'Pick up where you left off',
                    movies: p.recentMovies),
                if (p.recentMovies.isNotEmpty) const SizedBox(height: 24),
                MovieRow(title: 'Modern Hits', movies: p.modernHits),
                const SizedBox(height: 24),
                MovieRow(title: 'Timeless Classics', movies: p.classics),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
