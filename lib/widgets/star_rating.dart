import 'package:flutter/material.dart';

// Shows 5 stars (full, half or empty) for a rating from 0 to 5.
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  const StarRating({super.key, required this.rating, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (rating >= i + 1) {
          icon = Icons.star;
        } else if (rating >= i + 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: Colors.amber.shade800, size: size);
      }),
    );
  }
}

// A tappable 5-star picker that works inside a Form (has a validator).
class StarPicker extends FormField<int> {
   StarPicker({
    super.key,
    super.validator,
    int initial = 0,
    required ValueChanged<int> onChanged,
  }) : super(
          initialValue: initial,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < (state.value ?? 0);
                    return IconButton(
                      onPressed: () {
                        state.didChange(i + 1);
                        onChanged(i + 1);
                      },
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          filled ? Icons.star : Icons.star_border,
                          key: ValueKey(filled),
                          color: Colors.amber.shade800,
                          size: 38,
                        ),
                      ),
                    );
                  }),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(state.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            );
          },
        );
}
