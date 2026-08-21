import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({
    super.key,
    required this.onEditProfile,
    required this.onShareProfile,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onShareProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfileSoftButton(
            label: 'Edit Profile',
            onPressed: onEditProfile,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ProfileSoftButton(
            label: 'Share Profile',
            onPressed: onShareProfile,
          ),
        ),
      ],
    );
  }
}

class _ProfileSoftButton extends StatelessWidget {
  const _ProfileSoftButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.borderMd,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
