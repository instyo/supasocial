import 'post.dart';

class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.createdAt,
    this.author,
  });

  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime? createdAt;
  final PostAuthor? author;

  factory Comment.fromJson(Map<String, dynamic> json) {
    PostAuthor? author;
    final profiles = json['profiles'];
    if (profiles is Map<String, dynamic>) {
      author = PostAuthor.fromJson(profiles);
    }

    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      author: author,
    );
  }
}
