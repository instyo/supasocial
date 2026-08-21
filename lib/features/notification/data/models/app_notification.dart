import '../../../post/data/models/post.dart';

enum NotificationType {
  like,
  comment,
  follow,
  unknown;

  static NotificationType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      default:
        return NotificationType.unknown;
    }
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.actorId,
    required this.type,
    required this.isRead,
    this.postId,
    this.commentId,
    this.createdAt,
    this.actor,
    this.postImagePath,
    this.commentContent,
    this.isFollowingActor = false,
  });

  final String id;
  final String recipientId;
  final String actorId;
  final NotificationType type;
  final String? postId;
  final String? commentId;
  final bool isRead;
  final DateTime? createdAt;
  final PostAuthor? actor;
  final String? postImagePath;
  final String? commentContent;
  final bool isFollowingActor;

  AppNotification copyWith({
    String? id,
    String? recipientId,
    String? actorId,
    NotificationType? type,
    String? postId,
    String? commentId,
    bool? isRead,
    DateTime? createdAt,
    PostAuthor? actor,
    String? postImagePath,
    String? commentContent,
    bool? isFollowingActor,
  }) {
    return AppNotification(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      actorId: actorId ?? this.actorId,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actor: actor ?? this.actor,
      postImagePath: postImagePath ?? this.postImagePath,
      commentContent: commentContent ?? this.commentContent,
      isFollowingActor: isFollowingActor ?? this.isFollowingActor,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    PostAuthor? actor;
    final profiles = json['profiles'];
    if (profiles is Map<String, dynamic>) {
      actor = PostAuthor.fromJson(profiles);
    }

    return AppNotification(
      id: json['id'] as String,
      recipientId: json['recipient_id'] as String,
      actorId: json['actor_id'] as String,
      type: NotificationType.fromString(json['type'] as String?),
      postId: json['post_id'] as String?,
      commentId: json['comment_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      actor: actor,
    );
  }
}
