import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_notification.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _table = 'notifications';
  static const _selectWithActor =
      '*, profiles:actor_id(id, username, full_name, avatar_url)';

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final userId = _userId;
    if (userId == null) {
      throw const NotificationFailure('You must be signed in.');
    }

    try {
      final data = await _client
          .from(_table)
          .select(_selectWithActor)
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      final notifications = (data as List<dynamic>)
          .map((row) => AppNotification.fromJson(row as Map<String, dynamic>))
          .toList();

      if (notifications.isEmpty) return notifications;

      final postIds = notifications
          .map((n) => n.postId)
          .whereType<String>()
          .toSet()
          .toList();

      final commentIds = notifications
          .map((n) => n.commentId)
          .whereType<String>()
          .toSet()
          .toList();

      final followActorIds = notifications
          .where((n) => n.type == NotificationType.follow)
          .map((n) => n.actorId)
          .toSet()
          .toList();

      final postImages = await _loadPostImages(postIds);
      final commentBodies = await _loadCommentBodies(commentIds);
      final followingIds = await _loadFollowingIds(followActorIds);

      return notifications
          .map(
            (n) => n.copyWith(
              postImagePath: n.postId != null ? postImages[n.postId!] : null,
              commentContent:
                  n.commentId != null ? commentBodies[n.commentId!] : null,
              isFollowingActor: followingIds.contains(n.actorId),
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw NotificationFailure(e.message);
    } catch (e) {
      if (e is NotificationFailure) rethrow;
      throw const NotificationFailure(
        'Failed to load notifications. Please try again.',
      );
    }
  }

  Future<Map<String, String>> _loadPostImages(List<String> postIds) async {
    if (postIds.isEmpty) return {};

    final data = await _client
        .from('posts')
        .select('id, image_path')
        .inFilter('id', postIds);

    final map = <String, String>{};
    for (final row in data as List<dynamic>) {
      final json = row as Map<String, dynamic>;
      final id = json['id'] as String?;
      final path = json['image_path'] as String?;
      if (id != null && path != null && path.isNotEmpty) {
        map[id] = path;
      }
    }
    return map;
  }

  Future<Map<String, String>> _loadCommentBodies(List<String> commentIds) async {
    if (commentIds.isEmpty) return {};

    final data = await _client
        .from('comments')
        .select('id, content')
        .inFilter('id', commentIds);

    final map = <String, String>{};
    for (final row in data as List<dynamic>) {
      final json = row as Map<String, dynamic>;
      final id = json['id'] as String?;
      final content = json['content'] as String?;
      if (id != null && content != null) {
        map[id] = content;
      }
    }
    return map;
  }

  Future<Set<String>> _loadFollowingIds(List<String> actorIds) async {
    final me = _userId;
    if (me == null || actorIds.isEmpty) return {};

    final data = await _client
        .from('follows')
        .select('following_id')
        .eq('follower_id', me)
        .inFilter('following_id', actorIds);

    return (data as List<dynamic>)
        .map((row) => (row as Map<String, dynamic>)['following_id'] as String)
        .toSet();
  }

  @override
  Future<void> markAsRead(String id) async {
    final userId = _userId;
    if (userId == null) {
      throw const NotificationFailure('You must be signed in.');
    }

    try {
      await _client
          .from(_table)
          .update({'is_read': true})
          .eq('id', id)
          .eq('recipient_id', userId);
    } on PostgrestException catch (e) {
      throw NotificationFailure(e.message);
    } catch (e) {
      if (e is NotificationFailure) rethrow;
      throw const NotificationFailure('Failed to mark notification as read.');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId == null) {
      throw const NotificationFailure('You must be signed in.');
    }

    try {
      await _client
          .from(_table)
          .update({'is_read': true})
          .eq('recipient_id', userId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw NotificationFailure(e.message);
    } catch (e) {
      if (e is NotificationFailure) rethrow;
      throw const NotificationFailure('Failed to mark notifications as read.');
    }
  }
}

class NotificationFailure implements Exception {
  const NotificationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
