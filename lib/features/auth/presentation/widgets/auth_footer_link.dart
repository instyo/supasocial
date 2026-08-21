import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prompt,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
