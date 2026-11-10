import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating.dart';

// StatefulWidget because the form uses controllers and local state.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _commentController = TextEditingController();
  int _stars = 0;
  bool _recommends = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill the name if the user is logged in.
    final p = context.read<MovieProvider>();
    _nameController =
        TextEditingController(text: p.userEmail.isEmpty ? '' : p.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submit(Movie movie) {
    // validate() runs every validator; true only if all pass.
    if (_formKey.currentState!.validate()) {
      context.read<MovieProvider>().addReview(
            Review(
              movieId: movie.id,
              name: _nameController.text.trim(),
              rating: _stars,
              comment: _commentController.text.trim(),
              recommends: _recommends,
            ),
          );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review added. Thank you!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = ModalRoute.of(context)!.settings.arguments as Movie;

    return Scaffold(
      appBar: AppBar(title: Text('Review: ${movie.title}')),
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
                  onPressed: () => _submit(movie),
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
