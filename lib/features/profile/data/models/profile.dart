class Profile {
  const Profile({
    required this.id,
    required this.username,
    this.fullName,
    this.bio,
    this.website,
    this.avatarUrl,
    this.postCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String username;
  final String? fullName;
  final String? bio;
  final String? website;
  final String? avatarUrl;
  final int postCount;
  final int followersCount;
  final int followingCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : username;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      postCount: (json['post_count'] as num?)?.toInt() ?? 0,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'bio': bio,
      'website': website,
      'avatar_url': avatarUrl,
      'post_count': postCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? bio,
    String? website,
    String? avatarUrl,
    int? postCount,
    int? followersCount,
    int? followingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      postCount: postCount ?? this.postCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
