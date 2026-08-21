import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_relative_time.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/presentation/utils/open_user_profile.dart';
import '../../../profile/presentation/widgets/profile_avatar.dart';
import '../../data/models/post.dart';
import '../providers/post_providers.dart';
import '../widgets/comments_list.dart';
import '../widgets/post_action_bar.dart';
import '../widgets/post_image.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  bool? _liked;
  int? _likesCount;
  bool? _following;
  bool _likeBusy = false;
  bool _followBusy = false;
  bool _likeSeeded = false;
  bool _followSeeded = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _seedLikeState(Post post) {
    if (_likeSeeded) return;
    _liked = post.isLiked;
    _likesCount = post.likesCount;
    _likeSeeded = true;
  }

  void _seedFollowState(bool isFollowing) {
    if (_followSeeded) return;
    _following = isFollowing;
    _followSeeded = true;
  }

  Future<void> _toggleLike(Post post) async {
    if (_likeBusy) return;

    final previousLiked = _liked ?? post.isLiked;
    final previousCount = _likesCount ?? post.likesCount;
    final nextLiked = !previousLiked;
    final nextCount = nextLiked
        ? previousCount + 1
        : (previousCount - 1).clamp(0, 1 << 30);

    setState(() {
      _likeBusy = true;
      _liked = nextLiked;
      _likesCount = nextCount;
    });

    ref.read(feedNotifierProvider.notifier).patchLike(
          postId: post.id,
          isLiked: nextLiked,
          likesCount: nextCount,
        );

    final result = await ref.read(postLikeControllerProvider).toggle(
          postId: post.id,
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
            postId: post.id,
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

  Future<void> _toggleFollow(String userId) async {
    if (_followBusy || _following == null) return;

    final previousFollowing = _following!;
    final nextFollowing = !previousFollowing;

    setState(() {
      _followBusy = true;
      _following = nextFollowing;
    });

    final result = await ref.read(followControllerProvider).toggle(
          userId: userId,
          currentlyFollowing: previousFollowing,
        );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _following = previousFollowing;
        _followBusy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update follow. Try again.')),
      );
      return;
    }

    setState(() => _followBusy = false);
  }

  void _showPostActions(Post post) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  title: Text(
                    'Delete',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDelete(post);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final success = await ref.read(addCommentControllerProvider.notifier).add(
          postId: widget.postId,
          content: text,
        );

    if (!mounted) return;

    if (success) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
      return;
    }

    final error = ref.read(addCommentControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error?.toString() ?? 'Failed to add comment.')),
    );
  }

  Future<void> _confirmDelete(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete post?'),
          content: const Text(
            'This post will be permanently deleted. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(deletePostControllerProvider.notifier)
        .delete(post.id);

    if (!mounted) return;

    if (success) {
      context.pop();
      return;
    }

    final error = ref.read(deletePostControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error?.toString() ?? 'Failed to delete post.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.postId));
    final currentUserId = ref.watch(authRepositoryProvider).currentUser?.id;
    final isDeleting = ref.watch(deletePostControllerProvider).isLoading;
    final isCommenting = ref.watch(addCommentControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: isDeleting ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Post',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          postAsync.maybeWhen(
            data: (post) {
              final isOwner =
                  currentUserId != null && post.userId == currentUserId;
              if (!isOwner) return const SizedBox.shrink();
              return IconButton(
                onPressed: isDeleting ? null : () => _showPostActions(post),
                icon: const Icon(Icons.more_vert_rounded),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Stack(
        children: [
          postAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      error.toString(),
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(postDetailProvider(widget.postId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (post) {
              final isOwnPost = currentUserId != null &&
                  post.userId == currentUserId;

              if (!_likeSeeded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted || _likeSeeded) return;
                  setState(() => _seedLikeState(post));
                });
              }

              if (!isOwnPost && !_followSeeded) {
                final followAsync =
                    ref.watch(isFollowingProvider(post.userId));
                followAsync.whenData((isFollowing) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted || _followSeeded) return;
                    setState(() => _seedFollowState(isFollowing));
                  });
                });
              }

              return _PostDetailBody(
                post: post,
                liked: _liked ?? post.isLiked,
                following: _following ?? false,
                likesCount: _likesCount ?? post.likesCount,
                isOwnPost: isOwnPost,
                currentUserId: currentUserId,
                commentController: _commentController,
                isCommenting: isCommenting,
                followBusy: _followBusy,
                onLike: () => _toggleLike(post),
                onFollow: () => _toggleFollow(post.userId),
                onShare: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon')),
                  );
                },
                onSubmitComment: _submitComment,
              );
            },
          ),
          if (isDeleting)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _PostDetailBody extends ConsumerWidget {
  const _PostDetailBody({
    required this.post,
    required this.liked,
    required this.following,
    required this.likesCount,
    required this.isOwnPost,
    required this.currentUserId,
    required this.commentController,
    required this.isCommenting,
    required this.followBusy,
    required this.onLike,
    required this.onFollow,
    required this.onShare,
    required this.onSubmitComment,
  });

  final Post post;
  final bool liked;
  final bool following;
  final int likesCount;
  final bool isOwnPost;
  final String? currentUserId;
  final TextEditingController commentController;
  final bool isCommenting;
  final bool followBusy;
  final VoidCallback onLike;
  final VoidCallback onFollow;
  final VoidCallback onShare;
  final VoidCallback onSubmitComment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postRepo = ref.watch(postRepositoryProvider);
    final profileRepo = ref.watch(profileRepositoryProvider);
    final imageUrl = postRepo.imagePublicUrl(post.imagePath);
    final author = post.author;
    final avatarUrl = profileRepo.avatarPublicUrl(author?.avatarUrl);
    final displayName = author?.displayName ?? 'User';
    final caption = post.caption?.trim() ?? '';
    final hashtags = post.hashtags;

    void openAuthor() {
      openUserProfile(
        context,
        userId: post.userId,
        currentUserId: currentUserId,
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PostImage(
                  imageUrl: imageUrl,
                  borderRadius: BorderRadius.zero,
                  aspectRatio: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: openAuthor,
                            child: ProfileAvatar(
                              imageUrl: avatarUrl,
                              size: 44,
                              showBorder: false,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: GestureDetector(
                              onTap: openAuthor,
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.w600,
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
                          ),
                          if (!isOwnPost) ...[
                            const SizedBox(width: AppSpacing.sm),
                            FilledButton(
                              onPressed: followBusy ? null : onFollow,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(88, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm + 4,
                                ),
                                backgroundColor: following
                                    ? AppColors.surfaceContainerHigh
                                    : AppColors.primary,
                                foregroundColor: following
                                    ? AppColors.onSurface
                                    : AppColors.onPrimary,
                                disabledBackgroundColor: following
                                    ? AppColors.surfaceContainerHigh
                                    : AppColors.primary.withValues(alpha: 0.5),
                              ),
                              child: Text(following ? 'Following' : 'Follow'),
                            ),
                          ],
                        ],
                      ),
                      if (caption.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm + 4),
                        Text(
                          caption,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (hashtags.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: hashtags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: AppRadius.borderFull,
                                  ),
                                  child: Text(
                                    tag,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      const Divider(height: 1, color: AppColors.outlineVariant),
                      PostActionBar(
                        likesCount: likesCount,
                        commentsCount: post.commentsCount,
                        liked: liked,
                        showBookmark: false,
                        showShare: true,
                        onLike: onLike,
                        onShare: onShare,
                      ),
                      const Divider(height: 1, color: AppColors.outlineVariant),
                      const SizedBox(height: AppSpacing.md),
                      CommentsList(postId: post.id),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Material(
          color: AppColors.surface,
          elevation: 8,
          shadowColor: Colors.black12,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.sm,
                AppSpacing.marginMobile,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      enabled: !isCommenting,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 4,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.borderFull,
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.borderFull,
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.borderFull,
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: (_) {
                        if (!isCommenting) onSubmitComment();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    onPressed: isCommenting ? null : onSubmitComment,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.4),
                    ),
                    icon: isCommenting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
