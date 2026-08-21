import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_init.dart';
import '../../data/models/app_notification.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(supabaseClient);
});

final notificationsNotifierProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  NotificationRepository get _repository =>
      ref.read(notificationRepositoryProvider);

  @override
  Future<List<AppNotification>> build() async {
    final items = await _repository.getNotifications();
    // Mark all unread as read when the list is opened/loaded.
    final hasUnread = items.any((n) => !n.isRead);
    if (hasUnread) {
      try {
        await _repository.markAllAsRead();
      } catch (_) {
        // Non-blocking.
      }
    }
    return items
        .map((n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final items = await _repository.getNotifications();
      final hasUnread = items.any((n) => !n.isRead);
      if (hasUnread) {
        try {
          await _repository.markAllAsRead();
        } catch (_) {}
      }
      return items
          .map((n) => n.isRead ? n : n.copyWith(isRead: true))
          .toList();
    });
  }

  void patchFollow({
    required String actorId,
    required bool isFollowing,
  }) {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData([
      for (final n in current)
        if (n.actorId == actorId && n.type == NotificationType.follow)
          n.copyWith(isFollowingActor: isFollowing)
        else
          n,
    ]);
  }
}
