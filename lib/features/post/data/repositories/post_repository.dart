import 'dart:io';

import '../models/post.dart';

abstract class PostRepository {
  Future<List<Post>> getFeed();

  Future<List<Post>> getPostsByUser(String userId);

  Future<Post> getPostById(String id);

  Future<Post> createPost({
    required File image,
    required String caption,
  });

  Future<void> deletePost(String id);

  Future<void> likePost(String postId);

  Future<void> unlikePost(String postId);

  String imagePublicUrl(String path);
}
