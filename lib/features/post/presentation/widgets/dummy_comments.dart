import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profile/presentation/widgets/profile_avatar.dart';

class DummyComment {
  const DummyComment({
    required this.name,
    required this.body,
    required this.timeLabel,
  });

  final String name;
  final String body;
  final String timeLabel;
}

const dummyComments = [
  DummyComment(
    name: 'Marcus Chen',
    body:
        'The composition here is incredible. Love how the curve leads the eye upwards.',
    timeLabel: '1h',
  ),
  DummyComment(
    name: 'Sarah Jenkins',
    body:
        'So peaceful. This perfectly captures the essence of digital minimalism in a physical space.',
    timeLabel: '45m',
  ),
];

class DummyCommentsList extends StatelessWidget {
  const DummyCommentsList({super.key, this.comments = dummyComments});

  final List<DummyComment> comments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...comments.map((c) => _CommentTile(comment: c)),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final DummyComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileAvatar(size: 36, showBorder: false),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.borderLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.name,
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.body,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comment.timeLabel,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
