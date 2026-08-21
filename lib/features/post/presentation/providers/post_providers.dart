import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_init.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/models/post.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/repositories/post_repository_impl.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(supabaseClient);
});

final feedNotifierProvider =
    AsyncNotifierProvider<FeedNotifier, List<Post>>(FeedNotifier.new);

class FeedNotifier extends AsyncNotifier<List<Post>> {
  PostRepository get _repository => ref.read(postRepositoryProvider);

  @override
  Future<List<Post>> build() {
    return _repository.getFeed();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getFeed);
  }
}

final userPostsProvider =
    FutureProvider.family<List<Post>, String>((ref, userId) {
  return ref.watch(postRepositoryProvider).getPostsByUser(userId);
});

final postDetailProvider =
    FutureProvider.family<Post, String>((ref, postId) {
  return ref.watch(postRepositoryProvider).getPostById(postId);
});

final createPostControllerProvider =
    AsyncNotifierProvider<CreatePostController, void>(
  CreatePostController.new,
);

class CreatePostController extends AsyncNotifier<void> {
  PostRepository get _repository => ref.read(postRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> create({
    required File image,
    required String caption,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return _repository.createPost(image: image, caption: caption);
    });

    if (!state.hasError) {
      ref.invalidate(feedNotifierProvider);
      ref.invalidate(currentProfileProvider);
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        ref.invalidate(userPostsProvider(userId));
      }
    }

    return !state.hasError;
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final deletePostControllerProvider =
    AsyncNotifierProvider<DeletePostController, void>(
  DeletePostController.new,
);

class DeletePostController extends AsyncNotifier<void> {
  PostRepository get _repository => ref.read(postRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> delete(String postId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.deletePost(postId));

    if (!state.hasError) {
      ref.invalidate(feedNotifierProvider);
      ref.invalidate(currentProfileProvider);
      ref.invalidate(postDetailProvider(postId));
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        ref.invalidate(userPostsProvider(userId));
      }
    }

    return !state.hasError;
  }

  void reset() {
    state = const AsyncData(null);
  }
}
