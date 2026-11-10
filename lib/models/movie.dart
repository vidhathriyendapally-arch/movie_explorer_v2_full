import 'package:flutter/material.dart';

// A review written by a user. userEmail says who owns it:
// only the owner can edit or delete it ('' means a guest).
class Review {
  final String id;
  final int movieId;
  final String userEmail;
  final String name;
  final int rating; // 1 to 5 stars
  final String comment;
  final bool recommends;
  final DateTime date;

  Review({
    required this.id,
    required this.movieId,
    required this.userEmail,
    required this.name,
    required this.rating,
    required this.comment,
    required this.recommends,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Review copyWith({
    String? name,
    int? rating,
    String? comment,
    bool? recommends,
  }) =>
      Review(
        id: id,
        movieId: movieId,
        userEmail: userEmail,
        name: name ?? this.name,
        rating: rating ?? this.rating,
        comment: comment ?? this.comment,
        recommends: recommends ?? this.recommends,
        date: date,
      );

  // toJson / fromJson are used to save data in the browser (shared_preferences).
  Map<String, dynamic> toJson() => {
        'id': id,
        'movieId': movieId,
        'userEmail': userEmail,
        'name': name,
        'rating': rating,
        'comment': comment,
        'recommends': recommends,
        'date': date.toIso8601String(),
      };

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id: j['id'] as String,
        movieId: j['movieId'] as int,
        userEmail: j['userEmail'] as String,
        name: j['name'] as String,
        rating: j['rating'] as int,
        comment: j['comment'] as String,
        recommends: j['recommends'] as bool,
        date: DateTime.parse(j['date'] as String),
      );
}

// A movie. "poster" is the base colour for the generated poster art.
// posterUrl is optional: a real image link shown on top of the art.
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
  final String posterUrl;

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
    this.posterUrl = '',
  });

  Movie copyWith({
    int? id,
    String? title,
    String? tagline,
    int? year,
    String? genre,
    double? rating,
    int? runtime,
    String? director,
    List<String>? cast,
    String? description,
    Color? poster,
    String? posterUrl,
  }) =>
      Movie(
        id: id ?? this.id,
        title: title ?? this.title,
        tagline: tagline ?? this.tagline,
        year: year ?? this.year,
        genre: genre ?? this.genre,
        rating: rating ?? this.rating,
        runtime: runtime ?? this.runtime,
        director: director ?? this.director,
        cast: cast ?? this.cast,
        description: description ?? this.description,
        poster: poster ?? this.poster,
        posterUrl: posterUrl ?? this.posterUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'tagline': tagline,
        'year': year,
        'genre': genre,
        'rating': rating,
        'runtime': runtime,
        'director': director,
        'cast': cast,
        'description': description,
        'poster': poster.toARGB32(),
        'posterUrl': posterUrl,
      };

  factory Movie.fromJson(Map<String, dynamic> j) => Movie(
        id: j['id'] as int,
        title: j['title'] as String,
        tagline: j['tagline'] as String,
        year: j['year'] as int,
        genre: j['genre'] as String,
        rating: (j['rating'] as num).toDouble(),
        runtime: j['runtime'] as int,
        director: j['director'] as String,
        cast: (j['cast'] as List).map((e) => e.toString()).toList(),
        description: j['description'] as String,
        poster: Color(j['poster'] as int),
        posterUrl: (j['posterUrl'] ?? '') as String,
      );
}
