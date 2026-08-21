import 'dart:io';

import '../models/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getCurrentProfile();

  Future<Profile> getProfileById(String id);

  Future<Profile> updateProfile({
    required String fullName,
    required String username,
    String? bio,
    String? website,
  });

  Future<Profile> uploadAvatar(File file);

  String? avatarPublicUrl(String? path);
}
