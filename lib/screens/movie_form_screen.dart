import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/poster_box.dart';
import 'not_found_screen.dart';

const List<String> kGenres = [
  'Action', 'Animation', 'Comedy', 'Drama', 'Fantasy',
  'Horror', 'Romance', 'Sci-Fi', 'Thriller',
];

const List<int> kPosterColors = [
  0xFF1A237E, 0xFF004D40, 0xFF880E4F, 0xFFBF360C, 0xFF6A1B9A, 0xFF1B5E20,
  0xFF0D47A1, 0xFF37474F, 0xFF3E2723, 0xFF827717, 0xFFB71C1C, 0xFF00695C,
];

// One form for both "Add movie" (movieId == null) and "Edit movie".
class MovieFormScreen extends StatefulWidget {
  final int? movieId;
  const MovieFormScreen({super.key, this.movieId});

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _tagline = TextEditingController();
  final _year = TextEditingController();
  final _runtime = TextEditingController();
  final _director = TextEditingController();
  final _cast = TextEditingController();
  final _posterUrl = TextEditingController();
  final _description = TextEditingController();

  String _genre = kGenres.first;
  double _rating = 7.0;
  int _color = kPosterColors.first;

  Movie? _editing;
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    if (widget.movieId != null) {
      final m = context.read<MovieProvider>().movieById(widget.movieId!);
      if (m == null) {
        _missing = true;
      } else {
        _editing = m;
        _title.text = m.title;
        _tagline.text = m.tagline;
        _year.text = '${m.year}';
        _runtime.text = '${m.runtime}';
        _director.text = m.director;
        _cast.text = m.cast.join(', ');
        _posterUrl.text = m.posterUrl;
        _description.text = m.description;
        _genre = kGenres.contains(m.genre) ? m.genre : kGenres.first;
        _rating = m.rating.clamp(0.0, 10.0).toDouble();
        _color = m.poster.toARGB32();
      }
    } else {
      _year.text = '${DateTime.now().year}';
      _runtime.text = '120';
    }
  }

  @override
  void dispose() {
    for (final c in [
      _title, _tagline, _year, _runtime, _director, _cast, _posterUrl, _description
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _castList() => _cast.text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  // Builds a Movie from what is typed so far (used for the live preview and saving).
  Movie _draft() => Movie(
        id: widget.movieId ?? 0,
        title: _title.text.trim().isEmpty ? 'Your title' : _title.text.trim(),
        tagline: _tagline.text.trim(),
        year: int.tryParse(_year.text.trim()) ?? DateTime.now().year,
        genre: _genre,
        rating: _rating,
        runtime: int.tryParse(_runtime.text.trim()) ?? 120,
        director: _director.text.trim(),
        cast: _castList(),
        description: _description.text.trim(),
        poster: Color(_color),
        posterUrl: _posterUrl.text.trim(),
      );

  void _submit() {
    // validate() runs every validator; true only if all pass.
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<MovieProvider>();
    final messenger = ScaffoldMessenger.of(context);

    var movie = _draft();
    if (movie.tagline.isEmpty) {
      movie = movie.copyWith(tagline: '${movie.genre} • ${movie.year}');
    }

    if (_editing != null) {
      p.updateMovie(movie);
      messenger.showSnackBar(
          SnackBar(content: Text('"${movie.title}" updated')));
      Navigator.pop(context);
    } else {
      final added = p.addMovie(movie);
      messenger
          .showSnackBar(SnackBar(content: Text('"${added.title}" added')));
      // Open the new movie's page (back button returns to the previous screen).
      Navigator.pushReplacementNamed(context, '/movie/${added.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_missing) {
      return const NotFoundScreen(message: 'This movie no longer exists.');
    }
    final editing = _editing != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit movie' : 'Add movie')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 800;

          // Live preview of the poster while typing
          final preview = Column(
            children: [
              SizedBox(
                width: wide ? 220 : 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: PosterBox(movie: _draft()),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Live preview',
                  style: TextStyle(color: AppTheme.mutedText(context))),
            ],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Form(
                  key: _formKey,
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            preview,
                            const SizedBox(width: 32),
                            Expanded(child: _fields(context)),
                          ],
                        )
                      : Column(
                          children: [
                            preview,
                            const SizedBox(height: 20),
                            _fields(context),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fields(BuildContext context) {
    final p = context.read<MovieProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _title,
          decoration: AppTheme.inputDeco('Title', icon: Icons.title),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            final t = v?.trim() ?? '';
            if (t.isEmpty) return 'Please enter a title';
            if (t.length < 2) return 'Title is too short';
            if (t.length > 80) return 'Title is too long (max 80)';
            if (p.titleExists(t, exceptId: widget.movieId)) {
              return 'A movie with this title already exists';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tagline,
          decoration: AppTheme.inputDeco('Tagline (optional)',
              icon: Icons.format_quote),
          maxLength: 60,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _year,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration:
                    AppTheme.inputDeco('Year', icon: Icons.calendar_today),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final y = int.tryParse(v?.trim() ?? '');
                  if (y == null) return 'Enter a year';
                  if (y < 1888 || y > DateTime.now().year + 2) {
                    return '1888 to ${DateTime.now().year + 2}';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _runtime,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration:
                    AppTheme.inputDeco('Runtime (min)', icon: Icons.schedule),
                validator: (v) {
                  final r = int.tryParse(v?.trim() ?? '');
                  if (r == null) return 'Enter minutes';
                  if (r < 1 || r > 600) return '1 to 600';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _genre,
          decoration: AppTheme.inputDeco('Genre', icon: Icons.category),
          items: [
            for (final g in kGenres) DropdownMenuItem(value: g, child: Text(g)),
          ],
          onChanged: (v) => setState(() => _genre = v ?? _genre),
          validator: (v) => v == null ? 'Select a genre' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _director,
          decoration: AppTheme.inputDeco('Director', icon: Icons.person),
          validator: (v) {
            final t = v?.trim() ?? '';
            if (t.isEmpty) return 'Please enter the director';
            if (t.length < 2) return 'Name is too short';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cast,
          decoration: AppTheme.inputDeco('Cast (optional)',
              icon: Icons.groups, hint: 'Comma separated: Actor One, Actor Two'),
        ),
        const SizedBox(height: 20),
        Text('Rating: ${_rating.toStringAsFixed(1)} / 10',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Slider(
          value: _rating,
          min: 0,
          max: 10,
          divisions: 100,
          label: _rating.toStringAsFixed(1),
          onChanged: (v) =>
              setState(() => _rating = double.parse(v.toStringAsFixed(1))),
        ),
        const SizedBox(height: 8),
        const Text('Poster colour',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in kPosterColors)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == c ? scheme.onSurface : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _posterUrl,
          keyboardType: TextInputType.url,
          decoration: AppTheme.inputDeco('Poster image link (optional)',
              icon: Icons.image, hint: 'https://...'),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            final t = v?.trim() ?? '';
            if (t.isEmpty) return null; // optional
            if (!t.startsWith('http://') && !t.startsWith('https://')) {
              return 'Link must start with http:// or https://';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _description,
          maxLines: 4,
          maxLength: 400,
          decoration:
              AppTheme.inputDeco('Description', icon: Icons.description),
          validator: (v) {
            final t = v?.trim() ?? '';
            if (t.isEmpty) return 'Please write a description';
            if (t.length < 20) return 'Write at least 20 characters';
            return null;
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _submit,
              icon: Icon(_editing != null ? Icons.save : Icons.add),
              label: Text(_editing != null ? 'Save changes' : 'Add movie'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}
