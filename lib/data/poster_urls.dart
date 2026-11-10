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
    13: '$_base/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg', // The Matrix
  14: '$_base/ty8TGRuvJLPUmAR1H1nRIsgwvim.jpg', // Gladiator
  15: '$_base/sKCr78MXSLixwmZ8DyJLrpMsd15.jpg', // The Lion King
  16: '$_base/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg', // Titanic
  17: '$_base/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg', // Pulp Fiction
  18: '$_base/6oom5QYQ2yw27p5ZlcpYE2SBPaA.jpg', // Fellowship of the Ring
  19: '$_base/tFXcEccSQMf3lfhfXKSU9iRBpa3.jpg', // Get Out
  20: '$_base/3bhkrj58Vtu7enYsRolD1fZdja1.jpg', // The Godfather
  21: '$_base/or06FN3Dka5tukK1e9sl16pB3iy.jpg', // Avengers: Endgame
  22: '$_base/uDO8zWDhfWwoFdKS4fzkUJt0Rf0.jpg', // La La Land
  23: '$_base/gGEsBPAijhVUFoiNpgZXqRVWJt2.jpg', // Coco
  24: '$_base/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg', // Joker
};

// A poster the user typed in the Edit form wins; otherwise use the list above.
String resolvePosterUrl(Movie movie) {
  final own = movie.posterUrl.trim();
  if (own.isNotEmpty) return own;
  return _posters[movie.id] ?? '';
}
