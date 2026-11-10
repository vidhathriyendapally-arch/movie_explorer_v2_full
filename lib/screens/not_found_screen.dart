import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Shown for unknown links, or a movie/review that no longer exists.
class NotFoundScreen extends StatelessWidget {
  final String message;
  const NotFoundScreen({super.key, this.message = 'Page not found.'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.movie_filter_outlined,
                  size: 72, color: AppTheme.mutedText(context)),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false),
                icon: const Icon(Icons.home),
                label: const Text('Go to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
