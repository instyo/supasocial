import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_init.dart';
import '../../data/models/profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(supabaseClient);
});

final currentProfileProvider =
    AsyncNotifierProvider<CurrentProfileNotifier, Profile?>(
      CurrentProfileNotifier.new,
    );

final profileByIdProvider =
    FutureProvider.family<Profile, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getProfileById(userId);
});

class CurrentProfileNotifier extends AsyncNotifier<Profile?> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  Future<Profile?> build() {
    return _repository.getCurrentProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getCurrentProfile);
  }
}

final editProfileControllerProvider =
    AsyncNotifierProvider<EditProfileController, void>(
      EditProfileController.new,
    );

class EditProfileController extends AsyncNotifier<void> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> save({
    required String fullName,
    required String username,
    String? bio,
    String? website,
    File? avatarFile,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (avatarFile != null) {
        await _repository.uploadAvatar(avatarFile);
      }
      await _repository.updateProfile(
        fullName: fullName,
        username: username,
        bio: bio,
        website: website,
      );
    });

    if (!state.hasError) {
      ref.invalidate(currentProfileProvider);
    }

    return !state.hasError;
  }

  void reset() {
    state = const AsyncData(null);
  }
}
