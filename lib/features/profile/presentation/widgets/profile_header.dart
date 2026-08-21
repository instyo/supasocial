import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/profile.dart';
import '../providers/profile_providers.dart';
import 'profile_action_buttons.dart';
import 'profile_avatar.dart';
import 'profile_stats_row.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.mode = ProfileActionsMode.own,
    this.onEditProfile,
    this.onShareProfile,
    this.onFollow,
    this.isFollowing = false,
  });

  final Profile profile;
  final ProfileActionsMode mode;
  final VoidCallback? onEditProfile;
  final VoidCallback? onShareProfile;
  final VoidCallback? onFollow;
  final bool isFollowing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(profileRepositoryProvider);
    final avatarUrl = repository.avatarPublicUrl(profile.avatarUrl);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.md,
        AppSpacing.marginMobile,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(imageUrl: avatarUrl, size: 88),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ProfileStatsRow(
                  postCount: profile.postCount,
                  followersCount: profile.followersCount,
                  followingCount: profile.followingCount,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.displayName,
            style: AppTextStyles.headlineMd.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (profile.username.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              profile.username.startsWith('@')
                  ? profile.username
                  : '@${profile.username}',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              profile.bio!,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
          if (profile.website != null &&
              profile.website!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              profile.website!,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ProfileActionButtons(
            mode: mode,
            onEditProfile: onEditProfile,
            onShareProfile: onShareProfile,
            onFollow: onFollow,
            isFollowing: isFollowing,
          ),
        ],
      ),
    );
  }
}
