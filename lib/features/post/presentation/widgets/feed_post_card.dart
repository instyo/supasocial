import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_relative_time.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/presentation/widgets/profile_avatar.dart';
import '../../data/models/post.dart';
import '../providers/post_providers.dart';
import 'post_action_bar.dart';
import 'post_image.dart';

class FeedPostCard extends ConsumerStatefulWidget {
  const FeedPostCard({super.key, required this.post});

  final Post post;

  @override
  ConsumerState<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends ConsumerState<FeedPostCard> {
  late bool _liked;
  late bool _bookmarked;
  late int _likesCount;
  bool _likeBusy = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.post.isLiked;
    _bookmarked = false;
    _likesCount = widget.post.likesCount;
  }

  @override
  void didUpdateWidget(covariant FeedPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.isLiked != widget.post.isLiked ||
        oldWidget.post.likesCount != widget.post.likesCount) {
      _liked = widget.post.isLiked;
      _likesCount = widget.post.likesCount;
    }
  }

  Future<void> _toggleLike() async {
    if (_likeBusy) return;

    final previousLiked = _liked;
    final previousCount = _likesCount;
    final nextLiked = !_liked;
    final nextCount = nextLiked
        ? _likesCount + 1
        : (_likesCount - 1).clamp(0, 1 << 30);

    setState(() {
      _likeBusy = true;
      _liked = nextLiked;
      _likesCount = nextCount;
    });

    ref.read(feedNotifierProvider.notifier).patchLike(
          postId: widget.post.id,
          isLiked: nextLiked,
          likesCount: nextCount,
        );

    final result = await ref.read(postLikeControllerProvider).toggle(
          postId: widget.post.id,
          currentlyLiked: previousLiked,
        );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _liked = previousLiked;
        _likesCount = previousCount;
        _likeBusy = false;
      });
      ref.read(feedNotifierProvider.notifier).patchLike(
            postId: widget.post.id,
            isLiked: previousLiked,
            likesCount: previousCount,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update like. Try again.')),
      );
      return;
    }

    setState(() => _likeBusy = false);
  }

  void _toggleBookmark() {
    setState(() => _bookmarked = !_bookmarked);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final postRepo = ref.watch(postRepositoryProvider);
    final profileRepo = ref.watch(profileRepositoryProvider);
    final imageUrl = postRepo.imagePublicUrl(post.imagePath);
    final author = post.author;
    final avatarUrl = profileRepo.avatarPublicUrl(author?.avatarUrl);
    final displayName = author?.displayName ?? 'User';
    final caption = post.caption?.trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.borderXl,
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                ProfileAvatar(
                  imageUrl: avatarUrl,
                  size: 40,
                  showBorder: false,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formatRelativeTime(post.createdAt),
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/posts/${post.id}'),
            child: PostImage(
              imageUrl: imageUrl,
              borderRadius: BorderRadius.zero,
              aspectRatio: 4 / 5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm + 4,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm + 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostActionBar(
                  likesCount: _likesCount,
                  commentsCount: post.commentsCount,
                  liked: _liked,
                  bookmarked: _bookmarked,
                  onLike: _toggleLike,
                  onComment: () => context.push('/posts/${post.id}'),
                  onBookmark: _toggleBookmark,
                ),
                if (caption.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    caption,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurface,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
