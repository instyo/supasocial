import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post.dart';
import 'post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _table = 'posts';
  static const _bucket = 'posts';
  static const _selectWithAuthor =
      '*, profiles:user_id(id, username, full_name, avatar_url)';

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<List<Post>> getFeed() async {
    try {
      final data = await _client
          .from(_table)
          .select(_selectWithAuthor)
          .order('created_at', ascending: false);

      return (data as List<dynamic>)
          .map((row) => Post.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw PostFailure(e.message);
    } catch (_) {
      throw const PostFailure('Failed to load feed. Please try again.');
    }
  }

  @override
  Future<List<Post>> getPostsByUser(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select(_selectWithAuthor)
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List<dynamic>)
          .map((row) => Post.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw PostFailure(e.message);
    } catch (_) {
      throw const PostFailure('Failed to load posts. Please try again.');
    }
  }

  @override
  Future<Post> getPostById(String id) async {
    try {
      final data = await _client
          .from(_table)
          .select(_selectWithAuthor)
          .eq('id', id)
          .single();

      return Post.fromJson(data);
    } on PostgrestException catch (e) {
      throw PostFailure(e.message);
    } catch (_) {
      throw const PostFailure('Failed to load post. Please try again.');
    }
  }

  @override
  Future<Post> createPost({
    required File image,
    required String caption,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const PostFailure('You must be signed in to create a post.');
    }

    final path =
        '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await _client.storage.from(_bucket).upload(
            path,
            image,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      final cleanedCaption = caption.trim();
      final data = await _client
          .from(_table)
          .insert({
            'user_id': userId,
            'caption': cleanedCaption.isEmpty ? null : cleanedCaption,
            'image_path': path,
          })
          .select(_selectWithAuthor)
          .single();

      return Post.fromJson(data);
    } on StorageException catch (e) {
      throw PostFailure(e.message);
    } on PostgrestException catch (e) {
      throw PostFailure(e.message);
    } catch (e) {
      if (e is PostFailure) rethrow;
      throw const PostFailure('Failed to create post. Please try again.');
    }
  }

  @override
  Future<void> deletePost(String id) async {
    final userId = _userId;
    if (userId == null) {
      throw const PostFailure('You must be signed in to delete a post.');
    }

    try {
      final row = await _client
          .from(_table)
          .select('id, user_id, image_path')
          .eq('id', id)
          .single();

      final ownerId = row['user_id'] as String?;
      if (ownerId != userId) {
        throw const PostFailure('You can only delete your own posts.');
      }

      final imagePath = row['image_path'] as String? ?? '';

      await _client
          .from(_table)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      if (imagePath.isNotEmpty) {
        try {
          await _client.storage.from(_bucket).remove([imagePath]);
        } catch (_) {
          // Row is already gone; orphaned storage is acceptable.
        }
      }
    } on PostgrestException catch (e) {
      throw PostFailure(e.message);
    } catch (e) {
      if (e is PostFailure) rethrow;
      throw const PostFailure('Failed to delete post. Please try again.');
    }
  }

  @override
  String imagePublicUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return _client.storage.from(_bucket).getPublicUrl(path);
  }
}

class PostFailure implements Exception {
  const PostFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
