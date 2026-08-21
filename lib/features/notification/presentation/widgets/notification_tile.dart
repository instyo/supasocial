import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_relative_time_short.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../post/presentation/providers/post_providers.dart';
import '../../../post/presentation/widgets/post_image.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/presentation/utils/open_user_profile.dart';
import '../../../profile/presentation/widgets/profile_avatar.dart';
import '../../data/models/app_notification.dart';
import '../providers/notification_providers.dart';

class NotificationTile extends ConsumerStatefulWidget {
  const NotificationTile({super.key, required this.notification});

  final AppNotification notification;

  @override
  ConsumerState<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends ConsumerState<NotificationTile> {
  late bool _following;
  bool _followBusy = false;

  @override
  void initState() {
    super.initState();
    _following = widget.notification.isFollowingActor;
  }

  @override
  void didUpdateWidget(covariant NotificationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notification.id != widget.notification.id ||
        oldWidget.notification.isFollowingActor !=
            widget.notification.isFollowingActor) {
      _following = widget.notification.isFollowingActor;
    }
  }

  Future<void> _toggleFollow() async {
    if (_followBusy) return;

    final previous = _following;
    final next = !previous;

    setState(() {
      _followBusy = true;
      _following = next;
    });

    ref.read(notificationsNotifierProvider.notifier).patchFollow(
          actorId: widget.notification.actorId,
          isFollowing: next,
        );

    final result = await ref.read(followControllerProvider).toggle(
          userId: widget.notification.actorId,
          currentlyFollowing: previous,
        );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _following = previous;
        _followBusy = false;
      });
      ref.read(notificationsNotifierProvider.notifier).patchFollow(
            actorId: widget.notification.actorId,
            isFollowing: previous,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update follow. Try again.')),
      );
      return;
    }

    setState(() => _followBusy = false);
  }

  void _openActor() {
    final currentUserId = ref.read(authRepositoryProvider).currentUser?.id;
    openUserProfile(
      context,
      userId: widget.notification.actorId,
      currentUserId: currentUserId,
    );
  }

  void _onTap() {
    final n = widget.notification;
    switch (n.type) {
      case NotificationType.like:
      case NotificationType.comment:
        if (n.postId != null) {
          context.push('/posts/${n.postId}');
        }
      case NotificationType.follow:
        _openActor();
      case NotificationType.unknown:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final profileRepo = ref.watch(profileRepositoryProvider);
    final postRepo = ref.watch(postRepositoryProvider);
    final avatarUrl = profileRepo.avatarPublicUrl(n.actor?.avatarUrl);
    final displayName = n.actor?.displayName ?? 'Someone';
    final timeLabel = formatRelativeTimeShort(n.createdAt);

    final thumbUrl = n.postImagePath != null && n.postImagePath!.isNotEmpty
        ? postRepo.imagePublicUrl(n.postImagePath!)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: 6,
      ),
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.borderXl,
        child: InkWell(
          onTap: _onTap,
          borderRadius: AppRadius.borderXl,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderXl,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _openActor,
                  child: _AvatarWithBadge(
                    imageUrl: avatarUrl,
                    type: n.type,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NotificationMessage(
                        type: n.type,
                        displayName: displayName,
                        commentContent: n.commentContent,
                        onNameTap: _openActor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeLabel,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (n.type == NotificationType.follow)
                  _FollowChip(
                    following: _following,
                    busy: _followBusy,
                    onPressed: _toggleFollow,
                  )
                else if (thumbUrl != null)
                  GestureDetector(
                    onTap: () {
                      if (n.postId != null) {
                        context.push('/posts/${n.postId}');
                      }
                    },
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: PostImage(
                        imageUrl: thumbUrl,
                        borderRadius: AppRadius.borderMd,
                        height: double.infinity,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  const _AvatarWithBadge({
    required this.imageUrl,
    required this.type,
  });

  final String? imageUrl;
  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    IconData? badgeIcon;
    Color? badgeColor;

    switch (type) {
      case NotificationType.like:
        badgeIcon = Icons.favorite_rounded;
        badgeColor = const Color(0xFFE11D48);
      case NotificationType.comment:
        badgeIcon = Icons.chat_bubble_rounded;
        badgeColor = AppColors.primary;
      case NotificationType.follow:
      case NotificationType.unknown:
        break;
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ProfileAvatar(
            imageUrl: imageUrl,
            size: 44,
            showBorder: false,
          ),
          if (badgeIcon != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(badgeIcon, size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationMessage extends StatelessWidget {
  const _NotificationMessage({
    required this.type,
    required this.displayName,
    required this.onNameTap,
    this.commentContent,
  });

  final NotificationType type;
  final String displayName;
  final String? commentContent;
  final VoidCallback onNameTap;

  @override
  Widget build(BuildContext context) {
    final nameStyle = AppTextStyles.labelMd.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    );
    final bodyStyle = AppTextStyles.labelMd.copyWith(
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
      height: 1.35,
    );

    String suffix;
    switch (type) {
      case NotificationType.like:
        suffix = ' liked your photo.';
      case NotificationType.comment:
        final quote = (commentContent ?? '').trim();
        suffix = quote.isEmpty
            ? ' commented on your photo.'
            : ' commented: "$quote"';
      case NotificationType.follow:
        suffix = ' started following you.';
      case NotificationType.unknown:
        suffix = ' interacted with you.';
    }

    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onNameTap,
              child: Text(displayName, style: nameStyle),
            ),
          ),
          TextSpan(text: suffix, style: bodyStyle),
        ],
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _FollowChip extends StatelessWidget {
  const _FollowChip({
    required this.following,
    required this.busy,
    required this.onPressed,
  });

  final bool following;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          backgroundColor:
              following ? AppColors.surfaceContainerHigh : AppColors.primary,
          foregroundColor:
              following ? AppColors.onSurface : AppColors.onPrimary,
          disabledBackgroundColor: following
              ? AppColors.surfaceContainerHigh
              : AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderFull,
          ),
          textStyle: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(following ? 'Following' : 'Follow'),
      ),
    );
  }
}
