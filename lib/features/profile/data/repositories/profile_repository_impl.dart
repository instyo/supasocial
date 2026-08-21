import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _table = 'profiles';
  static const _followsTable = 'follows';
  static const _avatarBucket = 'avatars';

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Profile?> getCurrentProfile() async {
    final userId = _userId;
    if (userId == null) return null;

    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return Profile.fromJson(data);
    } on PostgrestException catch (e) {
      throw ProfileFailure(e.message);
    } catch (_) {
      throw const ProfileFailure('Failed to load profile. Please try again.');
    }
  }

  @override
  Future<Profile> getProfileById(String id) async {
    try {
      final data =
          await _client.from(_table).select().eq('id', id).single();
      final following = await isFollowing(id);
      return Profile.fromJson(data, isFollowing: following);
    } on PostgrestException catch (e) {
      throw ProfileFailure(e.message);
    } catch (e) {
      if (e is ProfileFailure) rethrow;
      throw const ProfileFailure('Failed to load profile. Please try again.');
    }
  }

  @override
  Future<Profile> updateProfile({
    required String fullName,
    required String username,
    String? bio,
    String? website,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const ProfileFailure('You must be signed in to update your profile.');
    }

    final cleanedUsername = username.trim().replaceFirst(RegExp(r'^@'), '');
    if (cleanedUsername.isEmpty) {
      throw const ProfileFailure('Username is required.');
    }

    try {
      final data = await _client
          .from(_table)
          .update({
            'full_name': fullName.trim(),
            'username': cleanedUsername,
            'bio': bio?.trim().isEmpty == true ? null : bio?.trim(),
            'website': website?.trim().isEmpty == true ? null : website?.trim(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      return Profile.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ProfileFailure('That username is already taken.');
      }
      throw ProfileFailure(e.message);
    } catch (e) {
      if (e is ProfileFailure) rethrow;
      throw const ProfileFailure('Failed to update profile. Please try again.');
    }
  }

  @override
  Future<Profile> uploadAvatar(File file) async {
    final userId = _userId;
    if (userId == null) {
      throw const ProfileFailure('You must be signed in to update your avatar.');
    }

    final path = '$userId.jpg';

    try {
      await _client.storage.from(_avatarBucket).upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final data = await _client
          .from(_table)
          .update({
            'avatar_url': path,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      return Profile.fromJson(data);
    } on StorageException catch (e) {
      throw ProfileFailure(e.message);
    } on PostgrestException catch (e) {
      throw ProfileFailure(e.message);
    } catch (e) {
      if (e is ProfileFailure) rethrow;
      throw const ProfileFailure('Failed to upload avatar. Please try again.');
    }
  }

  @override
  Future<bool> isFollowing(String userId) async {
    final me = _userId;
    if (me == null || me == userId) return false;

    try {
      final data = await _client
          .from(_followsTable)
          .select('follower_id')
          .eq('follower_id', me)
          .eq('following_id', userId)
          .maybeSingle();

      return data != null;
    } on PostgrestException catch (e) {
      throw ProfileFailure(e.message);
    } catch (_) {
      throw const ProfileFailure('Failed to check follow status.');
    }
  }

  @override
  Future<void> followUser(String userId) async {
    final me = _userId;
    if (me == null) {
      throw const ProfileFailure('You must be signed in to follow users.');
    }
    if (me == userId) {
      throw const ProfileFailure('You cannot follow yourself.');
    }

    try {
      await _client.from(_followsTable).insert({
        'follower_id': me,
        'following_id': userId,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') return;
      throw ProfileFailure(e.message);
    } catch (e) {
      if (e is ProfileFailure) rethrow;
      throw const ProfileFailure('Failed to follow user. Please try again.');
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    final me = _userId;
    if (me == null) {
      throw const ProfileFailure('You must be signed in to unfollow users.');
    }

    try {
      await _client
          .from(_followsTable)
          .delete()
          .eq('follower_id', me)
          .eq('following_id', userId);
    } on PostgrestException catch (e) {
      throw ProfileFailure(e.message);
    } catch (e) {
      if (e is ProfileFailure) rethrow;
      throw const ProfileFailure('Failed to unfollow user. Please try again.');
    }
  }

  @override
  String? avatarPublicUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return _client.storage.from(_avatarBucket).getPublicUrl(path);
  }
}

class ProfileFailure implements Exception {
  const ProfileFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
