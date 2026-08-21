import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Social sign-in coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'or continue with',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.outlineVariant)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              label: 'G',
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            _SocialButton(
              label: 'A',
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            _SocialButton(
              label: 'F',
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.socialButtonBg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
