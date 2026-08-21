import 'dart:io';

import '../models/comment.dart';
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

  Future<List<Comment>> getComments(String postId);

  Future<Comment> addComment({
    required String postId,
    required String content,
  });

  String imagePublicUrl(String path);
}
