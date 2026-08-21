# AGENTS.md — Aura

## Project Overview

Aura is a clean, minimalist social media application focused on photography and visual content.  
Users can create photo posts, follow other users, like, comment, bookmark posts, and receive notifications.

**MVP Features:**

- Authentication (Email/Password + Google/Apple)
- User Profile (edit profile, avatar, bio, website)
- Create Post (single image + caption + location)
- Home Feed
- Profile page with post grid
- Like, Comment, Follow, Bookmark
- Notifications

---

## Tech Stack

- Flutter (latest stable)
- Supabase (Auth, Database, Storage, Realtime)
- Riverpod (`flutter_riverpod`) — **no code generation**
- Repository Pattern
- go_router for navigation
- cached_network_image for images

> Do **not** use `riverpod_annotation`, `riverpod_generator`, or `build_runner` for Riverpod.

---

## Architecture

Use a **feature-first** structure:

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── supabase/
├── features/
│   ├── auth/
│   ├── profile/
│   ├── feed/
│   ├── post/
│   ├── notification/
│   └── ...
└── main.dart
```

Recommended structure inside each feature:

```
feature_name/
├── data/
│   ├── models/
│   ├── repositories/
│   └── sources/          # optional
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
```

### Core Rules

1. UI must **never** call Supabase directly. Always go through a Repository.
2. Providers may only depend on Repositories, never on `SupabaseClient` directly.
3. Keep business logic out of widgets.
4. Prefer `StateNotifier` + `StateNotifierProvider` or manual `AsyncNotifier` style for complex state.
5. One feature = one clear responsibility.

---

## Riverpod Guidelines (No Code Generation)

Use the classic Riverpod API only.

### Repository Provider

```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(Supabase.instance.client);
});
```

### StateNotifier Example

```dart
class FeedNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  FeedNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFeed();
  }

  final PostRepository _repository;

  Future<void> loadFeed() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getFeed());
  }
}

final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, AsyncValue<List<Post>>>((ref) {
  return FeedNotifier(ref.watch(postRepositoryProvider));
});
```

### Simple FutureProvider

```dart
final currentUserProvider = FutureProvider<Profile?>((ref) {
  return ref.watch(authRepositoryProvider).getCurrentProfile();
});
```

**Rules:**

- Wrap all network/database data with `AsyncValue`.
- Do not use `StateProvider` for server state.
- Provider names must be clear: `xxxRepositoryProvider`, `xxxNotifierProvider`.

---

## Repository Pattern

All data access must go through a Repository.

```dart
abstract class PostRepository {
  Future<List<Post>> getFeed();
  Future<Post> createPost({
    required File image,
    required String caption,
    String? location,
  });
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
}

class PostRepositoryImpl implements PostRepository {
  final SupabaseClient _client;

  PostRepositoryImpl(this._client);

  // implementation
}
```

**Repository responsibilities:**

- Talk to Supabase (Auth, Database, Storage)
- Map raw data to models
- Handle and map errors
- Contain no UI logic

---

## Supabase Guidelines

- Always enable and respect **Row Level Security (RLS)**.
- Store only the **storage path** in the database (`image_path`, `avatar_url`), never the full public URL.
- Recommended path convention:
  - Avatar → `avatars/{userId}.jpg`
  - Post image → `posts/{userId}/{postId}.jpg`
- Counters (`likes_count`, `followers_count`, `posts_count`, etc.) must be updated by **database triggers**, not from the client.
- Never trust client-side count updates.

---

## Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables & functions: `camelCase`
- Providers: `xxxProvider` / `xxxNotifierProvider`
- Repositories: `XxxRepository` and `XxxRepositoryImpl`

---

## Do's and Don'ts

**Do:**

- Use `AsyncValue.when` for loading / error / data states
- Keep widgets small and focused
- Handle errors properly
- Follow the repository pattern consistently

**Don't:**

- Call `Supabase.instance.client` from widgets
- Use Riverpod code generation
- Put business logic inside `build()` methods
- Create overly large "god" providers or classes
- Add new packages without discussion

---

## MVP Implementation Order

1. Auth + Profile (including avatar upload)
2. Create Post + Feed
3. Like & Follow
4. Comments
5. Notifications
6. Search / Hashtags (later)

---

## Notes for AI Agents

- Always follow the Repository Pattern.
- Use Riverpod **without** annotations or code generation.
- Prefer simplicity over over-engineering.
- Do not introduce new packages without confirmation.
- Keep the codebase consistent with the structure and naming rules defined above.
- When generating new features, follow the existing feature folder structure.

```

```
