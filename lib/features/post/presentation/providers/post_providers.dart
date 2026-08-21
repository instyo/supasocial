import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_init.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/models/comment.dart';
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

  void patchLike({
    required String postId,
    required bool isLiked,
    required int likesCount,
  }) {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData([
      for (final post in current)
        if (post.id == postId)
          post.copyWith(isLiked: isLiked, likesCount: likesCount)
        else
          post,
    ]);
  }

  void patchCommentsCount({
    required String postId,
    required int commentsCount,
  }) {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData([
      for (final post in current)
        if (post.id == postId)
          post.copyWith(commentsCount: commentsCount)
        else
          post,
    ]);
  }
}

final postLikeControllerProvider = Provider<PostLikeController>((ref) {
  return PostLikeController(ref);
});

class PostLikeController {
  PostLikeController(this._ref);

  final Ref _ref;

  PostRepository get _repository => _ref.read(postRepositoryProvider);

  /// Returns the new liked state on success, or null on failure.
  Future<bool?> toggle({
    required String postId,
    required bool currentlyLiked,
  }) async {
    try {
      if (currentlyLiked) {
        await _repository.unlikePost(postId);
        return false;
      } else {
        await _repository.likePost(postId);
        return true;
      }
    } catch (_) {
      return null;
    }
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

final postCommentsProvider =
    FutureProvider.family<List<Comment>, String>((ref, postId) {
  return ref.watch(postRepositoryProvider).getComments(postId);
});

final addCommentControllerProvider =
    AsyncNotifierProvider<AddCommentController, void>(
  AddCommentController.new,
);

class AddCommentController extends AsyncNotifier<void> {
  PostRepository get _repository => ref.read(postRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> add({
    required String postId,
    required String content,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.addComment(postId: postId, content: content);
    });

    if (!state.hasError) {
      ref.invalidate(postCommentsProvider(postId));
      ref.invalidate(postDetailProvider(postId));

      final feed = ref.read(feedNotifierProvider).asData?.value;
      if (feed != null) {
        for (final post in feed) {
          if (post.id == postId) {
            ref.read(feedNotifierProvider.notifier).patchCommentsCount(
                  postId: postId,
                  commentsCount: post.commentsCount + 1,
                );
            break;
          }
        }
      }
    }

    return !state.hasError;
  }

  void reset() {
    state = const AsyncData(null);
  }
}

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
