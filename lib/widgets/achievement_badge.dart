import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Lockable achievement badge with icon and label.
class AchievementBadge extends StatelessWidget {
  final String icon;   // emoji
  final String label;
  final bool unlocked;

  const AchievementBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: unlocked ? AppColors.primaryLight : const Color(0xFFF0F0F0),
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked ? AppColors.primary : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(icon, style: TextStyle(fontSize: unlocked ? 28 : 26)),
              if (!unlocked)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Colors.grey, size: 22),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: unlocked ? AppColors.textDark : AppColors.textLight,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
