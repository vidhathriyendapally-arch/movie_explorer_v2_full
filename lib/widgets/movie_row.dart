import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_card.dart';
import 'section_header.dart';

// A titled horizontal list of movie cards (like Netflix rows).
class MovieRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Movie> movies;
  final double hPad;
  final VoidCallback? onSeeAll;

  const MovieRow({
    super.key,
    required this.title,
    required this.movies,
    this.subtitle,
    this.hPad = 16,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: SectionHeader(title: title, subtitle: subtitle, onSeeAll: onSeeAll),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            itemCount: movies.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(width: 160, child: MovieCard(movie: movies[i])),
            ),
          ),
        ),
      ],
    );
  }
}
