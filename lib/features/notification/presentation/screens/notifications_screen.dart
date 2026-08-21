import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/app_notification.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_section_header.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: notificationsAsync.when(
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
                  onPressed: () => ref
                      .read(notificationsNotifierProvider.notifier)
                      .refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref
                  .read(notificationsNotifierProvider.notifier)
                  .refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.22),
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No notifications yet',
                    style: AppTextStyles.headlineMd,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Likes, comments, and follows will show up here.',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final rows = _buildRows(notifications);

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationsNotifierProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                return switch (row) {
                  _HeaderRow(:final label) =>
                    NotificationSectionHeader(label: label),
                  _ItemRow(:final notification) =>
                    NotificationTile(notification: notification),
                };
              },
            ),
          );
        },
      ),
    );
  }
}

sealed class _NotificationRow {
  const _NotificationRow();
}

class _HeaderRow extends _NotificationRow {
  const _HeaderRow(this.label);
  final String label;
}

class _ItemRow extends _NotificationRow {
  const _ItemRow(this.notification);
  final AppNotification notification;
}

List<_NotificationRow> _buildRows(List<AppNotification> items) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final yesterdayStart = todayStart.subtract(const Duration(days: 1));

  final today = <AppNotification>[];
  final yesterday = <AppNotification>[];
  final earlier = <AppNotification>[];

  for (final n in items) {
    final created = n.createdAt?.toLocal();
    if (created == null) {
      earlier.add(n);
      continue;
    }
    if (!created.isBefore(todayStart)) {
      today.add(n);
    } else if (!created.isBefore(yesterdayStart)) {
      yesterday.add(n);
    } else {
      earlier.add(n);
    }
  }

  final rows = <_NotificationRow>[];
  if (today.isNotEmpty) {
    rows.add(const _HeaderRow('Today'));
    rows.addAll(today.map(_ItemRow.new));
  }
  if (yesterday.isNotEmpty) {
    rows.add(const _HeaderRow('Yesterday'));
    rows.addAll(yesterday.map(_ItemRow.new));
  }
  if (earlier.isNotEmpty) {
    rows.add(const _HeaderRow('Earlier'));
    rows.addAll(earlier.map(_ItemRow.new));
  }
  return rows;
}
