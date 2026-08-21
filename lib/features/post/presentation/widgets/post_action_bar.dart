import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_count.dart';

class PostActionBar extends StatelessWidget {
  const PostActionBar({
    super.key,
    required this.likesCount,
    required this.commentsCount,
    this.liked = false,
    this.bookmarked = false,
    this.showShare = false,
    this.showBookmark = true,
    this.onLike,
    this.onComment,
    this.onBookmark,
    this.onShare,
  });

  final int likesCount;
  final int commentsCount;
  final bool liked;
  final bool bookmarked;
  final bool showShare;
  final bool showBookmark;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: liked ? const Color(0xFFE11D48) : AppColors.onSurface,
          label: formatCount(likesCount),
          onTap: onLike,
        ),
        const SizedBox(width: AppSpacing.md),
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          color: AppColors.onSurface,
          label: formatCount(commentsCount),
          onTap: onComment,
        ),
        const Spacer(),
        if (showShare)
          IconButton(
            onPressed: onShare,
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.ios_share_rounded,
              size: 22,
              color: AppColors.onSurface,
            ),
          ),
        if (showBookmark)
          IconButton(
            onPressed: onBookmark,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              size: 22,
              color: AppColors.onSurface,
            ),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
