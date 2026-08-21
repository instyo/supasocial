class PostAuthor {
  const PostAuthor({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : username;

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.imagePath,
    this.caption,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.createdAt,
    this.updatedAt,
    this.author,
  });

  final String id;
  final String userId;
  final String? caption;
  final String imagePath;
  final int likesCount;
  final int commentsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PostAuthor? author;

  List<String> get hashtags {
    final text = caption ?? '';
    final matches = RegExp(r'#(\w+)').allMatches(text);
    return matches.map((m) => '#${m.group(1)}').toList();
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    PostAuthor? author;
    final profiles = json['profiles'];
    if (profiles is Map<String, dynamic>) {
      author = PostAuthor.fromJson(profiles);
    }

    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      caption: json['caption'] as String?,
      imagePath: json['image_path'] as String? ?? '',
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      author: author,
    );
  }

  Post copyWith({
    String? id,
    String? userId,
    String? caption,
    String? imagePath,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    PostAuthor? author,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      imagePath: imagePath ?? this.imagePath,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
    );
  }
}
