import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () => onRatingChanged(starIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starIndex <= rating ? Icons.star : Icons.star_border,
              size: size,
              color: starIndex <= rating
                  ? const Color(0xFFFFA000)
                  : Colors.grey.shade400,
            ),
          ),
        );
      }),
    );
  }
}