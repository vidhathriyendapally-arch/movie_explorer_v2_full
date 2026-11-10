import 'package:flutter/material.dart';

// A review written by the user.
class Review {
  final int movieId;
  final String name;
  final int rating; // 1 to 5 stars
  final String comment;
  final bool recommends;
  final DateTime date;

  Review({
    required this.movieId,
    required this.name,
    required this.rating,
    required this.comment,
    required this.recommends,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

// A movie. "poster" is a colour used to draw a gradient poster (no image files needed).
class Movie {
  final int id;
  final String title;
  final String tagline;
  final int year;
  final String genre;
  final double rating;
  final int runtime; // minutes
  final String director;
  final List<String> cast;
  final String description;
  final Color poster;

  const Movie({
    required this.id,
    required this.title,
    required this.tagline,
    required this.year,
    required this.genre,
    required this.rating,
    required this.runtime,
    required this.director,
    required this.cast,
    required this.description,
    required this.poster,
  });
}
