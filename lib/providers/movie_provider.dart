import 'package:flutter/material.dart';
import '../data/movies.dart';
import '../models/movie.dart';

enum SortBy { rating, year, title }

// Holds ALL app state (login, theme, filters, favorites, watchlist, reviews).
// Every method that changes data ends with notifyListeners()
// so the screens that use it rebuild automatically.
class MovieProvider extends ChangeNotifier {
  // ---------- Login (stored in memory only) ----------
  final Map<String, String> _passwords = {'demo@movie.com': 'demo123'};
  final Map<String, String> _names = {'demo@movie.com': 'Demo User'};
  String userName = 'Guest';
  String userEmail = '';
  bool isLoggedIn = false;

  // Returns null on success, or an error message.
  String? login(String email, String password) {
    final key = email.trim().toLowerCase();
    if (!_passwords.containsKey(key)) return 'No account found for this email';
    if (_passwords[key] != password) return 'Incorrect password';
    userName = _names[key]!;
    userEmail = key;
    isLoggedIn = true;
    notifyListeners();
    return null;
  }

  String? signUp(String name, String email, String password) {
    final key = email.trim().toLowerCase();
    if (_passwords.containsKey(key)) return 'An account with this email already exists';
    _passwords[key] = password;
    _names[key] = name;
    userName = name;
    userEmail = key;
    isLoggedIn = true;
    notifyListeners();
    return null;
  }

  void continueAsGuest() {
    userName = 'Guest';
    userEmail = '';
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    userName = 'Guest';
    userEmail = '';
    notifyListeners();
  }

  // ---------- Theme ----------
  bool isDark = false;

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }

  // ---------- Browse: search, filter, sort ----------
  String query = '';
  String selectedGenre = 'All';
  double minRating = 0;
  SortBy sortBy = SortBy.rating;

  List<String> get genres => ['All', ...allMovies.map((m) => m.genre).toSet()];

  List<Movie> get filteredMovies {
    final list = allMovies.where((m) {
      final genreOk = selectedGenre == 'All' || m.genre == selectedGenre;
      final searchOk = m.title.toLowerCase().contains(query.toLowerCase());
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
    final list = [...allMovies];
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  List<Movie> get trending => allMovies.where((m) => m.rating >= 8.6).toList();
  List<Movie> get modernHits => allMovies.where((m) => m.year >= 2010).toList();
  List<Movie> get classics => allMovies.where((m) => m.year < 2010).toList();

  // Movies from the same genre first, then other top movies.
  List<Movie> similarTo(Movie movie) {
    final same =
        allMovies.where((m) => m.genre == movie.genre && m.id != movie.id).toList();
    final others =
        topRated.where((m) => m.genre != movie.genre && m.id != movie.id).take(4);
    return [...same, ...others];
  }

  // ---------- Favorites & Watchlist ----------
  final Set<int> _favorites = {};
  final Set<int> _watchlist = {};

  List<Movie> get favoriteMovies =>
      allMovies.where((m) => _favorites.contains(m.id)).toList();
  List<Movie> get watchlistMovies =>
      allMovies.where((m) => _watchlist.contains(m.id)).toList();

  bool isFavorite(int id) => _favorites.contains(id);
  bool inWatchlist(int id) => _watchlist.contains(id);

  void toggleFavorite(int id) {
    if (!_favorites.remove(id)) _favorites.add(id);
    notifyListeners();
  }

  void toggleWatchlist(int id) {
    if (!_watchlist.remove(id)) _watchlist.add(id);
    notifyListeners();
  }

  // ---------- Recently viewed ----------
  final List<int> _recent = [];

  List<Movie> get recentMovies =>
      _recent.map((id) => allMovies.firstWhere((m) => m.id == id)).toList();

  void markViewed(int id) {
    _recent.remove(id);
    _recent.insert(0, id);
    if (_recent.length > 8) _recent.removeLast();
    notifyListeners();
  }

  // ---------- Reviews ----------
  final List<Review> _reviews = [];

  List<Review> get allReviews => List.unmodifiable(_reviews);

  List<Review> reviewsFor(int movieId) =>
      _reviews.where((r) => r.movieId == movieId).toList();

  // Average star rating given by users, or null if no reviews yet.
  double? averageUserRating(int movieId) {
    final list = reviewsFor(movieId);
    if (list.isEmpty) return null;
    final total = list.fold<int>(0, (sum, r) => sum + r.rating);
    return total / list.length;
  }

  void addReview(Review review) {
    _reviews.insert(0, review);
    notifyListeners();
  }
}
