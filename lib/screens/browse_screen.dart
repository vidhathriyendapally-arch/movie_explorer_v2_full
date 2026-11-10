import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/genre_chip.dart';
import '../widgets/movie_card.dart';

// Browse tab: search + genre chips + rating slider + sort + responsive grid.
class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: context.read<MovieProvider>().query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // Responsive: number of grid columns depends on the available width.
  int _columnsFor(double width) {
    if (width < 600) return 2; // mobile
    if (width < 900) return 3; // small tablet
    if (width < 1100) return 4; // tablet
    if (width < 1400) return 5; // laptop
    return 6; // large desktop
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MovieProvider>();
    final movies = p.filteredMovies;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar with a clear button
              TextField(
                controller: _search,
                onChanged: p.setQuery,
                decoration: AppTheme.inputDeco(
                  'Search movies',
                  icon: Icons.search,
                  suffix: p.query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _search.clear();
                            p.setQuery('');
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Genre chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final g in p.genres)
                      GenreChip(
                        label: g,
                        selected: p.selectedGenre == g,
                        onTap: () => p.setGenre(g),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Rating slider + sort dropdown + result count
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                children: [
                  SizedBox(
                    width: 280,
                    child: Row(
                      children: [
                        Text('Min rating ${p.minRating.toStringAsFixed(1)}'),
                        Expanded(
                          child: Slider(
                            value: p.minRating,
                            min: 0,
                            max: 9,
                            divisions: 18,
                            onChanged: p.setMinRating,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownButton<SortBy>(
                    value: p.sortBy,
                    items: const [
                      DropdownMenuItem(
                          value: SortBy.rating, child: Text('Sort: Top rated')),
                      DropdownMenuItem(
                          value: SortBy.year, child: Text('Sort: Newest')),
                      DropdownMenuItem(
                          value: SortBy.title, child: Text('Sort: A to Z')),
                    ],
                    onChanged: (v) {
                      if (v != null) p.setSort(v);
                    },
                  ),
                  Text('${movies.length} movies',
                      style: TextStyle(color: AppTheme.mutedText(context))),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: movies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off,
                          size: 64, color: AppTheme.mutedText(context)),
                      const SizedBox(height: 8),
                      const Text('No movies match your filters'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          _search.clear();
                          p.resetFilters();
                        },
                        child: const Text('Clear filters'),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: movies.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _columnsFor(constraints.maxWidth),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (context, i) => MovieCard(
                        movie: movies[i],
                        heroTag: 'poster_${movies[i].id}',
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
