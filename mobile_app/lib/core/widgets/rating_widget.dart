import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RatingWidget extends StatelessWidget {
  final int rating;
  final double starSize;
  final bool readOnly;
  final ValueChanged<int>? onRatingChanged;

  const RatingWidget({
    super.key,
    this.rating = 0,
    this.starSize = 32,
    this.readOnly = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;
        return GestureDetector(
          onTap: readOnly ? null : () => onRatingChanged?.call(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: starSize,
              color: isFilled ? AppTheme.warning : AppTheme.textHint,
            ),
          ),
        );
      }),
    );
  }
}
