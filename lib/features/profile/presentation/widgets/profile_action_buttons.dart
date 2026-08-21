import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

enum ProfileActionsMode { own, peer }

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({
    super.key,
    this.mode = ProfileActionsMode.own,
    this.onEditProfile,
    this.onShareProfile,
    this.onFollow,
    this.isFollowing = false,
  });

  final ProfileActionsMode mode;
  final VoidCallback? onEditProfile;
  final VoidCallback? onShareProfile;
  final VoidCallback? onFollow;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    if (mode == ProfileActionsMode.peer) {
      return Row(
        children: [
          Expanded(
            child: _ProfileFilledButton(
              label: isFollowing ? 'Following' : 'Follow',
              isPrimary: !isFollowing,
              onPressed: onFollow,
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
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

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

class _ProfileFilledButton extends StatelessWidget {
  const _ProfileFilledButton({
    required this.label,
    required this.isPrimary,
    this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primary : AppColors.surfaceContainerHigh,
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
              color: isPrimary ? AppColors.onPrimary : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
