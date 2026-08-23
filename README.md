# Aura (supasocial)

Clean, minimalist social app for photography and visual content.  
Built with **Flutter** and **Supabase** (Auth, Database, Storage).

Users can sign up, create photo posts, follow others, like, comment, bookmark-style profile grids, and receive notifications.

|Home|Notification|Profile|New Post|Post Detail|Edit Profile|Sign In|Sign Up|
|------|------|------|------|------|------|------|------|
|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-08-23 at 12 40 00" src="https://github.com/user-attachments/assets/90e4b660-937a-4839-bf71-18b392fd2780" />|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-08-23 at 12 52 20" src="https://github.com/user-attachments/assets/33beef76-a329-47dd-b9b4-8dfef22fd98d" />|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-08-23 at 12 52 33" src="https://github.com/user-attachments/assets/4ad7e531-81ec-4aac-80ff-7354bf1b0812" />|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-08-23 at 12 53 03" src="https://github.com/user-attachments/assets/960298a8-dda5-49ba-abfc-4a2866612564" />|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-08-23 at 12 53 17" src="https://github.com/user-attachments/assets/73dd62a2-ef21-498d-8b54-1b3087d730d7" />|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-08-23 at 12 53 25" src="https://github.com/user-attachments/assets/0486a8de-f53f-4b45-8740-a183f1dd786d" />|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-08-23 at 12 53 38" src="https://github.com/user-attachments/assets/2a12fe8d-afbd-4f10-a067-46393f5ba412" />|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-08-23 at 12 53 54" src="https://github.com/user-attachments/assets/981f3a60-507d-47f1-abec-89b65a9955a3" />|


---

## Features

| Area | What’s included |
|------|-----------------|
| **Auth** | Email / password sign-up & sign-in (Google/Apple UI placeholders — not wired yet) |
| **Profile** | View/edit profile, avatar upload, bio, website, stats, post grid |
| **Posts** | Create post (image + caption + location), feed, post detail |
| **Social** | Like, comment, follow / unfollow |
| **Notifications** | Follow, like, and comment notifications (via DB triggers) |

---

## Tech stack

- **Flutter** (SDK `^3.12.2`)
- **Supabase** — Auth, Postgres, Storage, RLS
- **Riverpod** (`flutter_riverpod`) — classic API, **no** code generation
- **go_router** — navigation + auth redirects
- **cached_network_image** — image caching
- **image_picker** — camera / gallery
- **google_fonts** — Inter typography

Architecture: **feature-first** + **repository pattern**. UI never talks to Supabase directly.

---

## Prerequisites

Install:

1. [Flutter](https://docs.flutter.dev/get-started/install) (stable)
2. [Supabase CLI](https://supabase.com/docs/guides/cli)
3. A [Supabase](https://supabase.com) account / project
4. Xcode (iOS) and/or Android Studio (Android), if running on devices/simulators

Check Flutter:

```bash
flutter doctor
```

---

## Quick start

### 1. Clone and install packages

```bash
git clone <your-repo-url>
cd supasocial
flutter pub get
```

### 2. Create a Supabase project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard) → **New project**
2. Note **Project URL** and **anon / public** key  
   (Project Settings → API)

### 3. Link the CLI and apply migrations

This repo stores schema as SQL migrations under `supabase/migrations/` (generated with `supabase db pull` from a working remote).

```bash
# Log in (browser)
supabase login

# Link to your project (use the project ref from the dashboard URL)
supabase link --project-ref <your-project-ref>

# Push migrations to the linked remote database
supabase db push
```

> **Note:** There may be an empty migration file from an earlier `db pull`. If `db push` complains, remove empty files under `supabase/migrations/` and try again.

#### Fresh local Supabase (optional)

```bash
supabase init          # only if you need a local config.toml
supabase start
supabase db reset      # applies all migrations locally
```

Local Studio is usually at `http://127.0.0.1:54323`.

### 4. Create Storage buckets

Migrations include **storage policies** for `avatars` and `posts`, but buckets themselves are often created in the dashboard (or may already exist on the source project).

In **Storage** → **New bucket**:

| Bucket    | Public | Purpose |
|-----------|--------|---------|
| `avatars` | ✅ Yes | Profile photos (`{userId}.jpg`) |
| `posts`   | ✅ Yes | Post images (`{userId}/{postId}.jpg`) |

If policies were already applied by migration, you only need the buckets. If you create buckets first and policies fail on push, re-run push or add policies from the migration file.

### 5. Auth settings

In **Authentication** → **Providers**:

- Enable **Email**
- For local/dev, you can disable “Confirm email” so sign-up works immediately

A trigger (`handle_new_user`) creates a row in `public.profiles` when a user signs up.

### 6. Run the app

Credentials are injected at compile time via `--dart-define` (see `lib/core/constants/env.dart`):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

**iOS simulator:**

```bash
flutter run -d iPhone \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

**Android emulator:**

```bash
flutter run -d emulator-5554 \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Do **not** commit real keys. Prefer local shell aliases, IDE run configs, or a private `.env` script that is gitignored.

---

## Supabase migrations workflow

This project treats the remote database as the source of truth and pulls schema into git with the CLI.

### Pull schema from remote → repo

After changing schema in the Dashboard (or on a shared remote):

```bash
supabase link --project-ref <your-project-ref>
supabase db pull
```

This creates a new file under `supabase/migrations/` (e.g. `YYYYMMDDHHMMSS_remote_schema.sql`).

Commit the migration so others can reproduce the schema:

```bash
git add supabase/migrations
git commit -m "chore(db): pull remote schema"
```

### Push migrations → another project / teammate setup

```bash
supabase link --project-ref <their-project-ref>
supabase db push
```

### Tips

- Prefer one meaningful migration per change set; avoid committing empty migration files.
- Counters (`likes_count`, `followers_count`, `post_count`, etc.) are maintained by **database triggers**, not the Flutter client.
- Store **storage paths** in the DB (`image_path`, `avatar_url`), not full public URLs. The app builds public URLs with the Supabase client.
- Always keep **RLS** enabled (already on for all app tables).

---

## Database overview

### Tables

| Table | Role |
|-------|------|
| `profiles` | User profile (1:1 with `auth.users`) |
| `posts` | Photo posts |
| `post_likes` | Likes (composite PK) |
| `comments` | Comments on posts |
| `follows` | Follower graph |
| `notifications` | In-app notifications |

### Notable rules

- **Username:** `^[a-z0-9._]+$`, length 3–30, unique  
- **No self-follow**  
- **Comment content** must be non-empty after trim  
- Profile row auto-created on signup via `handle_new_user`

### Triggers (high level)

- Like / comment / follow → update counters  
- Like / comment / follow → insert notification (skips self-actions where applicable)  
- Post insert/delete → `profiles.post_count`  
- `updated_at` on posts (and related)

### Storage path conventions

```
avatars/{userId}.jpg
posts/{userId}/{postId}.jpg
```

---

## Project structure

```
lib/
├── core/
│   ├── constants/          # Env / compile-time config
│   ├── router/             # go_router + auth redirect
│   ├── supabase/           # Supabase.initialize
│   ├── theme/              # Colors, type, spacing, radius
│   └── utils/
├── features/
│   ├── auth/
│   ├── home/               # Feed shell screen
│   ├── post/               # Create, detail, likes, comments
│   ├── profile/
│   ├── notification/
│   └── shell/              # Bottom navigation shell
└── main.dart

supabase/
└── migrations/             # SQL from `supabase db pull` / schema history
```

Typical feature layout:

```
feature_name/
├── data/
│   ├── models/
│   └── repositories/       # Interface + Impl (Supabase only here)
└── presentation/
    ├── providers/          # Riverpod
    ├── screens/
    └── widgets/
```

### Architecture rules

1. Widgets/providers **must not** use `Supabase.instance.client` directly.  
2. Providers depend on **repositories** only.  
3. Network/DB state is exposed as `AsyncValue`.  
4. No Riverpod code generation (`riverpod_annotation` / `build_runner` not used).

---

## App routes

| Path | Screen |
|------|--------|
| `/sign-in` | Sign in |
| `/sign-up` | Sign up |
| `/home` | Home feed |
| `/create` | Create post |
| `/notifications` | Notifications |
| `/profile` | Current user profile |
| `/profile/edit` | Edit profile |
| `/users/:id` | Peer profile |
| `/posts/:id` | Post detail |

Unauthenticated users are redirected to `/sign-in`.

---

## Development

```bash
# Analyze
flutter analyze

# Tests
flutter test

# Format
dart format .
```

### IDE run configuration

Add dart-defines so you don’t type them every time:

**VS Code** (`.vscode/launch.json`):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Aura",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "toolArgs": [
        "--dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY"
      ]
    }
  ]
}
```

Keep this file out of git or use placeholders if you share the repo.

---

## Environment variables

| Define | Description |
|--------|-------------|
| `SUPABASE_URL` | Project URL (`https://xxxx.supabase.co`) |
| `SUPABASE_ANON_KEY` | Public anon key (safe for client with RLS) |

Never ship the **service_role** key in the Flutter app.

---

## Troubleshooting

| Issue | What to try |
|-------|-------------|
| App can’t reach Supabase | Check dart-defines; confirm project is not paused |
| Sign-up “works” but no profile | Ensure migrations ran (`handle_new_user` trigger on `auth.users`) |
| Image upload fails | Create `avatars` / `posts` buckets; confirm policies; check path format |
| Empty feed | Create a second user + posts, or seed data manually in SQL Editor |
| `db push` fails on empty migration | Delete zero-byte files in `supabase/migrations/` |
| RLS errors in logs | User must be authenticated; policies require `auth.uid()` ownership where applicable |

---

## Security notes

- RLS is enabled on all public tables.  
- Counters are trigger-owned — don’t trust client-side count writes.  
- Anon key is public by design; security lives in RLS + storage policies.  
- Prefer confirming email in production.

---

## Roadmap / not yet implemented

- Google & Apple sign-in (UI only today)  
- Search / hashtags  
- Bookmarks as a first-class feature (if not already in your remote schema)  
- Push notifications  

See `AGENTS.md` for contributor conventions and `DESIGN.md` for the design system tokens.

---

## License

Private / unpublished (`publish_to: 'none'`). Add a license if you open-source the project.
