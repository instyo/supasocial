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
| **Auth** | Email / password + Google Sign-In + Apple Sign-In |
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
- **google_sign_in** — native Google Sign-In (ID token → Supabase)
- **sign_in_with_apple** + **crypto** — Apple Sign-In (ID token + nonce → Supabase)
- **google_fonts** — Inter typography

Architecture: **feature-first** + **repository pattern**. UI never talks to Supabase directly.

---

## Prerequisites

Install:

1. [Flutter](https://docs.flutter.dev/get-started/install) (stable)
2. [Supabase CLI](https://supabase.com/docs/guides/cli)
3. A [Supabase](https://supabase.com) account / project
4. A [Google Cloud](https://console.cloud.google.com/) project (for Google Sign-In)
5. An [Apple Developer](https://developer.apple.com/) account (for Sign in with Apple)
6. Xcode (iOS) and/or Android Studio (Android), if running on devices/simulators

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

### 5. Auth settings (email)

In **Authentication** → **Providers**:

- Enable **Email**
- For local/dev, you can disable “Confirm email” so sign-up works immediately

A trigger (`handle_new_user`) creates a row in `public.profiles` when a user signs up (email, Google, or Apple).

For Google / Apple, continue with the sections below.

### 6. Run the app

Credentials are injected at compile time via `--dart-define` (see `lib/core/constants/env.dart`):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com \
  --dart-define=AUTH_REDIRECT_URL=com.ikhwan.supasocial://login-callback
```

**iOS simulator:**

```bash
flutter run -d iPhone \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=GOOGLE_WEB_CLIENT_ID=... \
  --dart-define=AUTH_REDIRECT_URL=com.ikhwan.supasocial://login-callback
```

**Android emulator / device:**

```bash
flutter run -d emulator-5554 \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=GOOGLE_WEB_CLIENT_ID=... \
  --dart-define=AUTH_REDIRECT_URL=com.ikhwan.supasocial://login-callback
```

Do **not** commit real keys. Prefer local shell aliases, IDE run configs, or a private script that is gitignored.

---

## Google Sign-In setup

The app uses **native** Google Sign-In (`google_sign_in`) and exchanges the Google **ID token** with Supabase via `signInWithIdToken`.  
No browser OAuth flow and no deep-link redirect URL are required for mobile.

### Overview

| Piece | Role |
|-------|------|
| **Web OAuth client** | Client ID + secret → Supabase Google provider; Client ID → app as `GOOGLE_WEB_CLIENT_ID` (`serverClientId`) |
| **iOS OAuth client** | Bundle ID + reversed client ID URL scheme in `Info.plist` |
| **Android OAuth client** | Package name + **SHA-1** of the keystore that signs the app |

### A. Google Cloud — project and consent

1. Open [Google Cloud Console](https://console.cloud.google.com/) and create (or select) a project.
2. Go to **APIs & Services** → **OAuth consent screen** (or **Google Auth Platform** → **Audience** / **Branding**, depending on the console UI).
3. Configure the app name and support email. For development, **External** + test users is fine.
4. Under **Data Access / Scopes**, ensure at least:
   - `openid`
   - `.../auth/userinfo.email`
   - `.../auth/userinfo.profile`

### B. Create OAuth clients

Go to **APIs & Services** → **Credentials** → **Create credentials** → **OAuth client ID** (or **Google Auth Platform** → **Clients**).

#### 1. Web application (required)

1. Application type: **Web application**
2. Name: e.g. `Aura Web`
3. You can leave origins/redirects empty for the native mobile ID-token flow, **or** add Supabase’s callback if you also use web OAuth later:
   - `https://YOUR_PROJECT.supabase.co/auth/v1/callback`
4. Create and save:
   - **Client ID** → this is `GOOGLE_WEB_CLIENT_ID`
   - **Client secret** → only for Supabase Dashboard (never put the secret in the Flutter app)

#### 2. iOS (required for iOS devices / simulator)

1. Application type: **iOS**
2. Bundle ID: `com.ikhwan.supasocial` (must match Xcode / `ios/Runner`)
3. Create and save the **iOS Client ID**  
   Format: `xxxxx.apps.googleusercontent.com`
4. Derive the **reversed client ID** for URL schemes:  
   `com.googleusercontent.apps.xxxxx`  
   (swap the prefix; drop `.apps.googleusercontent.com` from the end and use it after `com.googleusercontent.apps.`)

Example:

| Field | Value |
|-------|--------|
| iOS Client ID | `123456789-abcdef.apps.googleusercontent.com` |
| Reversed client ID | `com.googleusercontent.apps.123456789-abcdef` |

#### 3. Android (required for Android emulators / devices)

1. Application type: **Android**
2. Package name: `com.ikhwan.supasocial`
3. **SHA-1 certificate fingerprint** — must match the keystore Gradle uses (see next step)
4. Create the client (Android clients have no secret)

You need a separate Android client (or additional SHA-1 entries) for each signing key (debug vs Play App Signing release).

### C. Android SHA-1 (this repo)

Debug builds are signed with the **project** keystore at the repo root:

```
debug.keystore
```

This is wired in `android/app/build.gradle.kts` (not the machine default `~/.android/debug.keystore`).

**Get the SHA-1:**

```bash
# From repo root
keytool -list -v \
  -keystore debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android
```

Or:

```bash
cd android && ./gradlew :app:signingReport
```

Look for **SHA1** under the `debug` variant. Paste that value into the Android OAuth client in Google Cloud.

If SHA-1 in Google Cloud does not match the keystore that signed the APK/AAB, Google Sign-In fails with errors like:

```text
GoogleSignInExceptionCode.canceled, [16] Account reauth failed
```

### D. Supabase — enable Google provider

1. Supabase Dashboard → **Authentication** → **Providers** → **Google**
2. **Enable** Google
3. **Client ID** = Web client ID (from step B.1)
4. **Client Secret** = Web client secret (from step B.1)
5. (Optional) Additional Client IDs: paste iOS and/or Android client IDs, comma-separated
6. Turn **Skip nonce check** **ON** (needed for native iOS Google Sign-In with this stack)
7. Save

Profile rows are still created by `handle_new_user` on first Google sign-in (username defaults to `user_<8 chars of uuid>` unless metadata provides one).

### E. iOS URL scheme

`ios/Runner/Info.plist` must register the **reversed iOS client ID** under `CFBundleURLTypes` → `CFBundleURLSchemes`.

This repo already includes a scheme for the project’s iOS client. If you create **your own** iOS OAuth client, replace that string with your reversed client ID.

Optional: pass your iOS client ID at runtime (defaults exist in `Env` for this project):

```bash
--dart-define=GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID.apps.googleusercontent.com
```

### F. App dart-defines

| Define | Required | Description |
|--------|----------|-------------|
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase anon (public) key |
| `GOOGLE_WEB_CLIENT_ID` | Yes (for Google) | **Web** OAuth client ID (`serverClientId`) |
| `GOOGLE_IOS_CLIENT_ID` | iOS only | iOS OAuth client ID; has a project default in `Env` |

Example:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi... \
  --dart-define=GOOGLE_WEB_CLIENT_ID=123456789-xyz.apps.googleusercontent.com \
  --dart-define=GOOGLE_IOS_CLIENT_ID=123456789-ios.apps.googleusercontent.com
```

### G. How it works in code

1. User taps **G** on sign-in / sign-up  
2. `AuthRepository.signInWithGoogle()` initializes `GoogleSignIn` with `serverClientId` = Web client ID  
3. Native Google UI returns an **ID token** (+ access token for scopes)  
4. App calls Supabase `signInWithIdToken(provider: google, ...)`  
5. `go_router` sees a session and redirects to `/home`  
6. On sign-out, both Google and Supabase sessions are cleared  

Implementation lives in:

- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/presentation/widgets/social_auth_buttons.dart`
- `lib/core/constants/env.dart`

### H. Checklist

- [ ] Web OAuth client created; ID + secret saved  
- [ ] Web client ID + secret entered in Supabase Google provider  
- [ ] Skip nonce check enabled in Supabase  
- [ ] iOS OAuth client with bundle `com.ikhwan.supasocial`  
- [ ] `Info.plist` reversed client ID matches that iOS client  
- [ ] Android OAuth client with package `com.ikhwan.supasocial`  
- [ ] Android SHA-1 from **this repo’s** `debug.keystore` registered  
- [ ] App run with `GOOGLE_WEB_CLIENT_ID` set  
- [ ] Cold start → tap G → account picker → lands on Home  

After changing OAuth clients or SHA-1 in Google Cloud, wait a few minutes and do a full app restart (`flutter run` again).

---

## Apple Sign-In setup

Hybrid flow (no custom Apple redirect host required):

| Platform | Flow |
|----------|------|
| **iOS** | Native Apple sheet → ID token → `signInWithIdToken` |
| **Android** | Browser OAuth → Supabase callback → **app deep link** → session |

Default deep link: `com.ikhwan.supasocial://login-callback`

### A. Apple Developer

1. **Identifiers → App IDs** → `com.ikhwan.supasocial`  
   - Enable **Sign In with Apple** (matches `ios/Runner/Runner.entitlements`)
2. **Identifiers → Services IDs** → create e.g. `com.ikhwan.supasocial.auth`  
   - Enable **Sign In with Apple**  
   - Configure:  
     - **Domains**: your Supabase host only (e.g. `xxxx.supabase.co`)  
     - **Return URLs**: `https://xxxx.supabase.co/auth/v1/callback`
3. **Keys** → create a **Sign in with Apple** key (`.p8`)  
   - Note **Key ID**, download the `.p8` once  
   - Note your **Team ID** (Membership details)

### B. Generate Apple client secret (OAuth JWT) — important

Android / web Apple Sign-In uses Supabase’s **OAuth** flow. Apple does **not** accept the raw `.p8` file as `client_secret`. You must create a short-lived **JWT** signed with the `.p8` key and paste that JWT into Supabase as the Apple **Secret**.

If the secret is wrong, Android fails after Apple login with:

```text
Unable to exchange external code: …
```

(`…` is only the first 4 chars of the auth code — not an Apple error code. The real failure is Supabase ↔ Apple token exchange.)

#### Why not only the Supabase dashboard generator?

Some setups hit `Unable to exchange external code` when the secret was produced only via the dashboard helper (wrong `sub`, bad paste, Safari issues, etc.). This project generates the secret locally with Node so every claim is explicit and correct.

Reference script:  
[gist: dlazares Apple client secret JWT](https://gist.github.com/dlazares/c68fec4b0fa05a631a5452e8a050cd57)

#### What the JWT must contain

| Claim / header | Value |
|----------------|--------|
| `iss` | Your Apple **Team ID** |
| `sub` | **Services ID** (e.g. `com.ikhwan.supasocial.auth`) — **not** the Bundle ID |
| `aud` | `https://appleid.apple.com` |
| `iat` | now (unix seconds) |
| `exp` | now + up to **6 months** (Apple max) |
| header `kid` | Apple **Key ID** for the `.p8` |
| algorithm | `ES256` |
| signing key | contents of `AuthKey_XXXXXXXXXX.p8` |

**Critical:** `sub` must equal the **Services ID** used for OAuth, and that same Services ID must be the **first** entry in Supabase Apple **Client IDs**. Supabase uses `Client IDs[0]` as Apple `client_id` for OAuth.

#### Generate the secret (Node)

```bash
npm install jsonwebtoken
```

```js
// generate-apple-secret.js
// Based on https://gist.github.com/dlazares/c68fec4b0fa05a631a5452e8a050cd57
const jwt = require('jsonwebtoken')
const fs = require('fs')

// MUST be the Services ID (OAuth), not the iOS Bundle ID
const appleId = 'com.ikhwan.supasocial.auth'
const keyId = 'XXXXXXXXXX'   // 10-char Key ID from Apple Keys
const teamId = 'ZZZZZZZZZZ'  // Team ID
const privateKey = fs.readFileSync('./AuthKey_XXXXXXXXXX.p8')

const secret = jwt.sign(
  {
    iss: teamId,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 86400 * 180, // 6 months
    aud: 'https://appleid.apple.com',
    sub: appleId,
  },
  privateKey,
  {
    algorithm: 'ES256',
    keyid: keyId,
  },
)

console.log(secret)
```

```bash
node generate-apple-secret.js
```

Copy the single-line JWT output (starts with `eyJ…`).

**Do not commit** the `.p8`, the script with real IDs, or the JWT. Keep them local / secrets manager only.

#### Rotate every 6 months

Apple client secrets expire (max ~180 days). Set a calendar reminder to regenerate the JWT and paste it again into Supabase, or Android Apple OAuth will start failing with the same exchange error.

### C. Supabase Dashboard

**Authentication → Providers → Apple**

1. Enable **Apple**
2. **Client IDs**: Services ID **first**, then Bundle ID  
   `com.ikhwan.supasocial.auth,com.ikhwan.supasocial`  
   - First ID = OAuth `client_id` (must match JWT `sub`)  
   - Bundle ID still required for native iOS `signInWithIdToken`
3. **Secret**: paste the **JWT** from step B (not the raw `.p8` file contents)  
   - If the UI also has Team ID / Key ID / private key fields, prefer the single pre-generated **Secret** field with this JWT so `sub` is under your control
4. Save

**Authentication → URL configuration** (critical for Android)

1. **Redirect URLs** — add exactly (no trailing slash unless you use one in the app too):  
   `com.ikhwan.supasocial://login-callback`
2. If this URL is missing, Supabase falls back to **Site URL** (often `http://localhost:3000`) after Apple — that is the usual “why localhost?” bug.

Site URL can stay as-is for web; mobile OAuth uses `redirectTo` from the app.

### E. App config

No Apple secret in the app. Deep link default is in `Env.authRedirectUrl`.

Optional override:

```bash
--dart-define=AUTH_REDIRECT_URL=com.ikhwan.supasocial://login-callback
```

Android intent filter is in `android/app/src/main/AndroidManifest.xml`  
(`scheme=com.ikhwan.supasocial`, `host=login-callback`).

### F. How it works in code

**iOS**

1. Nonce + native Apple sheet  
2. `signInWithIdToken(provider: apple, …)`  
3. Optional first-login name → `profiles.full_name`  
4. `go_router` → `/home`

**Android**

1. `signInWithOAuth(apple, redirectTo: authRedirectUrl)` opens the browser  
2. Apple → `https://xxxx.supabase.co/auth/v1/callback`  
3. Supabase redirects to `com.ikhwan.supasocial://login-callback?code=…`  
4. `supabase_flutter` parses the deep link into a session  
5. `go_router` → `/home`

Implementation:

- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/presentation/widgets/social_auth_buttons.dart`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Runner.entitlements`
- `lib/core/constants/env.dart`

### G. Checklist

- [ ] Sign In with Apple enabled on App ID `com.ikhwan.supasocial`  
- [ ] Services ID `com.ikhwan.supasocial.auth` domain + return URL = Supabase host + `/auth/v1/callback`  
- [ ] Client secret JWT generated locally (`sub` = Services ID); pasted into Supabase Apple **Secret**  
- [ ] Supabase Client IDs: `com.ikhwan.supasocial.auth,com.ikhwan.supasocial` (Services ID **first**)  
- [ ] Supabase **Redirect URLs** includes `com.ikhwan.supasocial://login-callback`  
- [ ] Calendar reminder to rotate Apple secret every ≤ 6 months  
- [ ] iOS: tap Apple → authorize → Home  
- [ ] Android: tap Apple → browser → back into app → Home (not localhost)  
- [ ] Cancel → no error snackbar  

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
- Store **storage paths** in the DB (`image_path`, `avatar_url`), not full public URLs. The app builds public URLs with the Supabase client. Google avatar URLs (full `https://…`) are also supported when present.
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

debug.keystore              # Shared Android debug signing (SHA-1 for Google)
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

# Android signing / SHA-1
cd android && ./gradlew :app:signingReport
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
        "--dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY",
        "--dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com",
        "--dart-define=AUTH_REDIRECT_URL=com.ikhwan.supasocial://login-callback"
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
| `GOOGLE_WEB_CLIENT_ID` | Google **Web** OAuth client ID (required for Google Sign-In) |
| `GOOGLE_IOS_CLIENT_ID` | Google **iOS** OAuth client ID (optional; defaults in `Env` for this project) |
| `AUTH_REDIRECT_URL` | OAuth deep link (optional; default `com.ikhwan.supasocial://login-callback`) |

Never ship the **service_role** key, Google **client secret**, or Apple **.p8** private key in the Flutter app.

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
| Snackbar: Google Sign-In is not configured | Pass `--dart-define=GOOGLE_WEB_CLIENT_ID=...` |
| `[16] Account reauth failed` on Android | SHA-1 mismatch. Use `debug.keystore` SHA-1 from this repo (`signingReport`) and register it on the **Android** OAuth client. Package must be `com.ikhwan.supasocial`. |
| Google works on iOS, fails on Android | Android OAuth client + correct SHA-1; rebuild after Gradle signing change |
| Google works on Android, fails on iOS | Reversed client ID in `Info.plist`; `GOOGLE_IOS_CLIENT_ID`; Supabase **Skip nonce check** ON |
| Apple Android ends on `localhost:3000` | Add `com.ikhwan.supasocial://login-callback` to Supabase **Redirect URLs** (exact match). Site URL fallback is localhost by default. |
| Apple Android browser works but app never logs in | Deep link intent-filter; rebuild app; confirm redirect URL scheme/host match `AndroidManifest` |
| Apple fails on Android after browser | Services ID → Supabase callback; Apple provider secret; Redirect URLs allow-list |
| `Unable to exchange external code` | Apple rejected token exchange. Regenerate client secret JWT with `sub` = Services ID (`com.ikhwan.supasocial.auth`); put Services ID **first** in Client IDs; do not paste raw `.p8` as Secret. See [gist](https://gist.github.com/dlazares/c68fec4b0fa05a631a5452e8a050cd57). Check Auth logs for the real internal error. |
| Apple fails on iOS | App ID capability + entitlements; Supabase Client IDs include Bundle ID `com.ikhwan.supasocial` |
| Apple user has empty name | Normal after first login if name was skipped; Apple only sends name once — edit profile |
| User cancels Google / Apple sheet | Expected — no error snackbar |
| Still failing after Cloud changes | Wait a few minutes; uninstall app / full restart; confirm Web client ID is used as `serverClientId` |

---

## Security notes

- RLS is enabled on all public tables.  
- Counters are trigger-owned — don’t trust client-side count writes.  
- Anon key is public by design; security lives in RLS + storage policies.  
- Prefer confirming email in production.  
- Only the Google **Web client ID** belongs in the app for social auth; keep OAuth secrets and the Apple `.p8` in Supabase / Apple Developer only.  
- Don’t commit real dart-define values, keystores with production keys, or `google-services.json` with secrets if you add one later.

---

## Roadmap / not yet implemented

- Search / hashtags  
- Bookmarks as a first-class feature (if not already in your remote schema)  
- Push notifications  

See `AGENTS.md` for contributor conventions and `DESIGN.md` for the design system tokens.

---

## License

Private / unpublished (`publish_to: 'none'`). Add a license if you open-source the project.
