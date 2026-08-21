import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: AppTextStyles.headlineLgMobile,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Text(
          subtitle,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
