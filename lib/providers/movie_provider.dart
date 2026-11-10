import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/movies.dart';
import '../models/movie.dart';

enum SortBy { rating, year, title }

// Holds ALL app state and saves it in the browser (shared_preferences),
// so accounts, movies, favorites, watchlist, reviews and theme survive a refresh.
// Every method that changes data ends with notifyListeners()
// so the screens that use it rebuild automatically.
class MovieProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  MovieProvider(this._prefs) {
    _load();
  }

  // ---------- Saved data ----------
  List<Movie> _movies = [];
  final Map<String, Map<String, String>> _users = {};
  final Set<int> _favorites = {};
  final Set<int> _watchlist = {};
  final List<int> _recent = [];
  final List<Review> _reviews = [];

  String userName = 'Guest';
  String userEmail = '';
  bool isLoggedIn = false;
  bool isDark = false;

  // ---------- Loading from storage ----------
  void _load() {
    // Accounts (a demo account always exists)
    try {
      final raw = _prefs.getString('users');
      if (raw != null) {
        (jsonDecode(raw) as Map<String, dynamic>).forEach((email, data) {
          _users[email] = Map<String, String>.from(data as Map);
        });
      }
    } catch (_) {}
    _users.putIfAbsent(
        'demo@movie.com', () => {'name': 'Demo User', 'password': 'demo123'});

    // Restore the logged-in session
    final session = _prefs.getString('session');
    if (session == 'guest') {
      isLoggedIn = true;
    } else if (session != null && _users.containsKey(session)) {
      isLoggedIn = true;
      userEmail = session;
      userName = _users[session]!['name'] ?? 'User';
    }

    isDark = _prefs.getBool('dark') ?? false;

    // Movies: saved list, or the 12 starter movies
    _movies = List.of(allMovies);
    try {
      final raw = _prefs.getString('movies');
      if (raw != null) {
        _movies = (jsonDecode(raw) as List)
            .map((e) => Movie.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _movies = List.of(allMovies);
    }

    _favorites.addAll(_readIds('favorites'));
    _watchlist.addAll(_readIds('watchlist'));
    _recent.addAll(_readIds('recent'));

    try {
      final raw = _prefs.getString('reviews');
      if (raw != null) {
        _reviews.addAll((jsonDecode(raw) as List)
            .map((e) => Review.fromJson(e as Map<String, dynamic>)));
      }
    } catch (_) {}
  }

  Iterable<int> _readIds(String key) =>
      (_prefs.getStringList(key) ?? []).map(int.tryParse).whereType<int>();

  // ---------- Saving to storage ----------
  void _saveUsers() => _prefs.setString('users', jsonEncode(_users));

  void _saveSession() {
    if (!isLoggedIn) {
      _prefs.remove('session');
    } else {
      _prefs.setString('session', userEmail.isEmpty ? 'guest' : userEmail);
    }
  }

  void _saveMovies() => _prefs.setString(
      'movies', jsonEncode(_movies.map((m) => m.toJson()).toList()));

  void _saveLists() {
    _prefs.setStringList('favorites', _favorites.map((e) => '$e').toList());
    _prefs.setStringList('watchlist', _watchlist.map((e) => '$e').toList());
    _prefs.setStringList('recent', _recent.map((e) => '$e').toList());
  }

  void _saveReviews() => _prefs.setString(
      'reviews', jsonEncode(_reviews.map((r) => r.toJson()).toList()));

  // ---------- Login (accounts are saved in this browser only: demo, not real security) ----------
  void _startSession(String email, String name) {
    userEmail = email;
    userName = name;
    isLoggedIn = true;
    _saveSession();
    notifyListeners();
  }

  // Returns null on success, or an error message.
  String? login(String email, String password) {
    final key = email.trim().toLowerCase();
    final user = _users[key];
    if (user == null) return 'No account found for this email';
    if (user['password'] != password) return 'Incorrect password';
    _startSession(key, user['name'] ?? 'User');
    return null;
  }

  String? signUp(String name, String email, String password) {
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) {
      return 'An account with this email already exists';
    }
    _users[key] = {'name': name, 'password': password};
    _saveUsers();
    _startSession(key, name);
    return null;
  }

  void continueAsGuest() => _startSession('', 'Guest');

  void logout() {
    isLoggedIn = false;
    userName = 'Guest';
    userEmail = '';
    _saveSession();
    notifyListeners();
  }

  // ---------- Theme ----------
  void toggleTheme() {
    isDark = !isDark;
    _prefs.setBool('dark', isDark);
    notifyListeners();
  }

  // ---------- Movies: read, add, edit, delete ----------
  List<Movie> get movies => List.unmodifiable(_movies);

  Movie? movieById(int id) {
    for (final m in _movies) {
      if (m.id == id) return m;
    }
    return null;
  }

  bool titleExists(String title, {int? exceptId}) {
    final t = title.trim().toLowerCase();
    return _movies.any((m) => m.title.toLowerCase() == t && m.id != exceptId);
  }

  // Gives the new movie the next free id and returns it.
  Movie addMovie(Movie draft) {
    final nextId = _movies.fold<int>(0, (max, m) => m.id > max ? m.id : max) + 1;
    final movie = draft.copyWith(id: nextId);
    _movies.add(movie);
    _saveMovies();
    notifyListeners();
    return movie;
  }

  void updateMovie(Movie movie) {
    final i = _movies.indexWhere((m) => m.id == movie.id);
    if (i == -1) return;
    _movies[i] = movie;
    _saveMovies();
    notifyListeners();
  }

  // Also removes the movie's reviews, favorite, watchlist and recent entries.
  void deleteMovie(int id) {
    _movies.removeWhere((m) => m.id == id);
    _cleanupOrphans();
    _saveAll();
    notifyListeners();
  }

  // Brings back the 12 starter movies (removes added ones, undoes edits/deletes).
  void restoreDefaultMovies() {
    _movies = List.of(allMovies);
    _cleanupOrphans();
    _saveAll();
    notifyListeners();
  }

  void _cleanupOrphans() {
    final ids = _movies.map((m) => m.id).toSet();
    _favorites.removeWhere((id) => !ids.contains(id));
    _watchlist.removeWhere((id) => !ids.contains(id));
    _recent.removeWhere((id) => !ids.contains(id));
    _reviews.removeWhere((r) => !ids.contains(r.movieId));
    if (!genres.contains(selectedGenre)) selectedGenre = 'All';
  }

  void _saveAll() {
    _saveMovies();
    _saveLists();
    _saveReviews();
  }

  // ---------- Browse: search, filter, sort ----------
  String query = '';
  String selectedGenre = 'All';
  double minRating = 0;
  SortBy sortBy = SortBy.rating;

  List<String> get genres =>
      ['All', ...(_movies.map((m) => m.genre).toSet().toList()..sort())];

  List<Movie> get filteredMovies {
    final q = query.trim().toLowerCase();
    final list = _movies.where((m) {
      final genreOk = selectedGenre == 'All' || m.genre == selectedGenre;
      // Search matches title, director or any cast member.
      final searchOk = q.isEmpty ||
          m.title.toLowerCase().contains(q) ||
          m.director.toLowerCase().contains(q) ||
          m.cast.any((c) => c.toLowerCase().contains(q));
      final ratingOk = m.rating >= minRating;
      return genreOk && searchOk && ratingOk;
    }).toList();

    switch (sortBy) {
      case SortBy.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortBy.year:
        list.sort((a, b) => b.year.compareTo(a.year));
        break;
      case SortBy.title:
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return list;
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setGenre(String genre) {
    selectedGenre = genre;
    notifyListeners();
  }

  void setMinRating(double value) {
    minRating = value;
    notifyListeners();
  }

  void setSort(SortBy value) {
    sortBy = value;
    notifyListeners();
  }

  void resetFilters() {
    query = '';
    selectedGenre = 'All';
    minRating = 0;
    sortBy = SortBy.rating;
    notifyListeners();
  }

  // ---------- Ready-made lists for the Home screen ----------
  List<Movie> get topRated {
    final list = [..._movies];
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  List<Movie> get trending => _movies.where((m) => m.rating >= 8.6).toList();
  List<Movie> get modernHits => _movies.where((m) => m.year >= 2010).toList();
  List<Movie> get classics => _movies.where((m) => m.year < 2010).toList();

  // Movies from the same genre first, then other top movies.
  List<Movie> similarTo(Movie movie) {
    final same = _movies
        .where((m) => m.genre == movie.genre && m.id != movie.id)
        .toList();
    final others =
        topRated.where((m) => m.genre != movie.genre && m.id != movie.id).take(4);
    return [...same, ...others];
  }

  // ---------- Favorites & Watchlist ----------
  List<Movie> get favoriteMovies =>
      _movies.where((m) => _favorites.contains(m.id)).toList();
  List<Movie> get watchlistMovies =>
      _movies.where((m) => _watchlist.contains(m.id)).toList();

  bool isFavorite(int id) => _favorites.contains(id);
  bool inWatchlist(int id) => _watchlist.contains(id);

  void toggleFavorite(int id) {
    if (!_favorites.remove(id)) _favorites.add(id);
    _saveLists();
    notifyListeners();
  }

  void toggleWatchlist(int id) {
    if (!_watchlist.remove(id)) _watchlist.add(id);
    _saveLists();
    notifyListeners();
  }

  // ---------- Recently viewed ----------
  List<Movie> get recentMovies =>
      _recent.map(movieById).whereType<Movie>().toList();

  void markViewed(int id) {
    _recent.remove(id);
    _recent.insert(0, id);
    if (_recent.length > 8) _recent.removeLast();
    _saveLists();
    notifyListeners();
  }

  // ---------- Reviews (each one belongs to the user who wrote it) ----------
  List<Review> get allReviews => List.unmodifiable(_reviews);

  // True if the current user wrote this review.
  bool isMine(Review r) => r.userEmail == userEmail;

  List<Review> get myReviews => _reviews.where(isMine).toList();

  List<Review> reviewsFor(int movieId) =>
      _reviews.where((r) => r.movieId == movieId).toList();

  Review? reviewById(String id) {
    for (final r in _reviews) {
      if (r.id == id) return r;
    }
    return null;
  }

  // Average star rating given by users, or null if no reviews yet.
  double? averageUserRating(int movieId) {
    final list = reviewsFor(movieId);
    if (list.isEmpty) return null;
    final total = list.fold<int>(0, (sum, r) => sum + r.rating);
    return total / list.length;
  }

  void addReview({
    required int movieId,
    required String name,
    required int rating,
    required String comment,
    required bool recommends,
  }) {
    _reviews.insert(
      0,
      Review(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        movieId: movieId,
        userEmail: userEmail,
        name: name,
        rating: rating,
        comment: comment,
        recommends: recommends,
      ),
    );
    _saveReviews();
    notifyListeners();
  }

  void updateReview(
    String id, {
    required String name,
    required int rating,
    required String comment,
    required bool recommends,
  }) {
    final i = _reviews.indexWhere((r) => r.id == id);
    if (i == -1 || !isMine(_reviews[i])) return;
    _reviews[i] = _reviews[i].copyWith(
        name: name, rating: rating, comment: comment, recommends: recommends);
    _saveReviews();
    notifyListeners();
  }

  void deleteReview(String id) {
    final i = _reviews.indexWhere((r) => r.id == id);
    if (i == -1 || !isMine(_reviews[i])) return;
    _reviews.removeAt(i);
    _saveReviews();
    notifyListeners();
  }
}
