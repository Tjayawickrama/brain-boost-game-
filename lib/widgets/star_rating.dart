import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated star rating widget (1–3 stars).
class StarRating extends StatelessWidget {
  final int stars; // 1, 2 or 3
  final double size;

  const StarRating({super.key, required this.stars, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: filled ? 1.0 : 0.0),
          duration: Duration(milliseconds: 300 + i * 150),
          curve: Curves.elasticOut,
          builder: (_, v, __) => Transform.scale(
            scale: 0.6 + 0.4 * v,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: filled ? AppColors.starGold : AppColors.starGray,
                size: size,
              ),
            ),
          ),
        );
      }),
    );
  }
}
