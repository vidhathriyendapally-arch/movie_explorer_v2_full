import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';
import 'not_found_screen.dart';

// Used for writing a new review AND editing your own (reviewId != null).
// StatefulWidget because the form uses controllers and local state.
class ReviewScreen extends StatefulWidget {
  final int movieId;
  final String? reviewId;
  const ReviewScreen({super.key, required this.movieId, this.reviewId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _commentController;
  int _stars = 0;
  bool _recommends = true;
  Review? _existing;
  bool _blocked = false; // review missing, or it belongs to someone else

  @override
  void initState() {
    super.initState();
    final p = context.read<MovieProvider>();
    if (widget.reviewId != null) {
      _existing = p.reviewById(widget.reviewId!);
      if (_existing == null || !p.isMine(_existing!)) _blocked = true;
    }
    final r = _existing;
    // Pre-fill the name if the user is logged in (or from the review being edited).
    _nameController = TextEditingController(
        text: r?.name ?? (p.userEmail.isEmpty ? '' : p.userName));
    _commentController = TextEditingController(text: r?.comment ?? '');
    _stars = r?.rating ?? 0;
    _recommends = r?.recommends ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    // validate() runs every validator; true only if all pass.
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<MovieProvider>();
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();

    if (_existing == null) {
      p.addReview(
        movieId: widget.movieId,
        name: name,
        rating: _stars,
        comment: comment,
        recommends: _recommends,
      );
    } else {
      p.updateReview(
        _existing!.id,
        name: name,
        rating: _stars,
        comment: comment,
        recommends: _recommends,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(_existing == null ? 'Review added. Thank you!' : 'Review updated.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final movie = context.watch<MovieProvider>().movieById(widget.movieId);
    if (movie == null) {
      return const NotFoundScreen(message: 'This movie does not exist.');
    }
    if (_blocked) {
      return const NotFoundScreen(
          message: 'This review was not found, or it is not yours to edit.');
    }
    final editing = _existing != null;

    return Scaffold(
      appBar: AppBar(
          title: Text(editing ? 'Edit review: ${movie.title}' : 'Review: ${movie.title}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('How was ${movie.title}?',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: AppTheme.inputDeco('Your name', icon: Icons.person),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your name';
                    if (v.trim().length < 2) return 'Name is too short';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Your rating (1 to 5 stars)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                StarPicker(
                  initial: _stars,
                  onChanged: (v) => _stars = v,
                  validator: (v) =>
                      (v == null || v == 0) ? 'Please select a star rating' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: 200,
                  decoration: AppTheme.inputDeco('Comment', icon: Icons.comment),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please write a comment';
                    if (v.trim().length < 10) return 'Write at least 10 characters';
                    return null;
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I recommend this movie'),
                  value: _recommends,
                  onChanged: (v) => setState(() => _recommends = v),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(editing ? Icons.save : Icons.send),
                  label: Text(editing ? 'Save Changes' : 'Submit Review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
