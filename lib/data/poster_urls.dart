import '../models/movie.dart';

// Poster images (TMDB). Keyed by movie id from movies.dart.
const String _base = 'https://image.tmdb.org/t/p/w500';

const Map<int, String> _posters = {
  1: '$_base/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg', // Inception
  2: '$_base/qJ2tW6WMUDux911r6m7haRef0WH.jpg', // The Dark Knight
  3: '$_base/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg', // Interstellar
  4: '$_base/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg', // Parasite
  5: '$_base/uXDfjJbdP4ijW5hWSBrPrlKpxab.jpg', // Toy Story
  6: '$_base/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg', // Shawshank Redemption
  7: '$_base/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg', // Spirited Away
  8: '$_base/8tZYtuWezp8JbcsvHYO0O46tFbo.jpg', // Mad Max: Fury Road
  9: '$_base/eWdyYQreja6JGCzqHWXpWHDrrPo.jpg', // Grand Budapest Hotel
  10: '$_base/lv5xShBIDboIhSWCaVMnPlhcPFh.jpg', // Gone Girl
  11: '$_base/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg', // Forrest Gump
  12: '$_base/uluhlXubGu1VxU63X9VHCLWDAYP.jpg', // The Hangover
};

// A poster the user typed in the Edit form wins; otherwise use the list above.
String resolvePosterUrl(Movie movie) {
  final own = movie.posterUrl.trim();
  if (own.isNotEmpty) return own;
  return _posters[movie.id] ?? '';
}
