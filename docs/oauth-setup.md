# OAuth Setup (Google, Apple, and Additional Providers)

This document covers manual setup required to run OAuth login with OpenBudget across web, iOS, and Android.

## Scope Implemented

- Implemented in code: Google + Apple
- Documented only (not implemented in this pass): GitHub, Firebase, Passkey

## Prerequisites

- Apple Developer Program account (paid)
- Google Cloud project with OAuth enabled
- Server running with `openbudget_server`
- Flutter app running with `openbudget_app`

## Server Password Keys

Add these keys to `openbudget_server/config/passwords.yaml` (or env-injected equivalent):

- `googleClientSecret`: JSON string from Google OAuth web client secret file.
- `appleServiceIdentifier`: Apple Service ID (client id for web/android Apple sign-in).
- `appleBundleIdentifier`: Apple app bundle id (native Apple sign-in audience).
- `appleRedirectUri`: Apple callback URI (must point to `/auth/apple/callback` on your server web host).
- `appleTeamId`: Apple Developer Team ID.
- `appleKeyId`: Apple Sign in with Apple key ID.
- `appleKey`: Contents of the Apple private key (`.p8`), including begin/end lines.
- `appleAndroidPackageIdentifier`: Android application id used to build the secure `intent://` callback redirect.

## Runtime Dart Defines

Provide these to the Flutter app:

- `GOOGLE_CLIENT_ID`
- `GOOGLE_SERVER_CLIENT_ID`
- `APPLE_SERVICE_IDENTIFIER`
- `APPLE_REDIRECT_URI`

Example (web):

```bash
flutter:app run -d chrome \
  --dart-define=GOOGLE_CLIENT_ID=<google-web-client-id> \
  --dart-define=APPLE_SERVICE_IDENTIFIER=<apple-service-id> \
  --dart-define=APPLE_REDIRECT_URI=<https://app-domain/auth/apple/callback>
```

Example (mobile):

```bash
flutter:app run -d ios \
  --dart-define=GOOGLE_CLIENT_ID=<google-ios-client-id> \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<google-web-client-id> \
  --dart-define=APPLE_SERVICE_IDENTIFIER=<apple-service-id> \
  --dart-define=APPLE_REDIRECT_URI=<https://app-domain/auth/apple/callback>
```

## Redirect URI Matrix

Use environment-specific callback values consistently in provider dashboards and server config.

- Local: `http://localhost:8082/auth/apple/callback`
- Staging: `https://app-staging.examplepod.com/auth/apple/callback`
- Production: `https://app.examplepod.com/auth/apple/callback`

For Google web/OAuth console entries, keep all required origins and redirect URIs aligned with your actual deployed hosts.

## Google Setup (Manual)

1. In Google Cloud Console, configure OAuth consent screen.
2. Create OAuth clients:
   - Web client (required for server-side verification and web sign-in).
   - iOS client for `com.example.openbudgetFlutter` (or your real bundle id).
   - Android client for `com.example.openbudget_app` with signing SHA fingerprints.
3. Download the web client secret JSON.
4. Store that JSON content in `googleClientSecret`.
5. Set Flutter defines:
   - `GOOGLE_CLIENT_ID`: platform client id used by app runtime.
   - `GOOGLE_SERVER_CLIENT_ID`: web/server client id used for backend token verification flows.
6. For web hosting, set `<meta name="google-signin-client_id" ...>` in `openbudget_app/web/index.html` to your deployed web client id.

## Apple Setup (Manual)

1. In Apple Developer, create or update App ID and enable Sign in with Apple.
2. Create Service ID for web/android Apple sign-in.
3. In the Service ID configuration:
   - Add your domain(s) to Domains and Subdomains.
   - Add callback URL(s) to Return URLs (must match `/auth/apple/callback`).
4. Create a Sign in with Apple key and download the `.p8` once.
5. Set server password keys:
   - `appleServiceIdentifier`, `appleBundleIdentifier`, `appleRedirectUri`
   - `appleTeamId`, `appleKeyId`, `appleKey`
   - `appleAndroidPackageIdentifier`
6. Set Flutter defines:
   - `APPLE_SERVICE_IDENTIFIER`
   - `APPLE_REDIRECT_URI`
7. iOS manual step in Xcode:
   - Add Sign in with Apple capability to the Runner target.
8. Android manual step:
   - Ensure app id matches `appleAndroidPackageIdentifier`.
   - Keep the Sign in with Apple callback activity in `AndroidManifest.xml`.
9. Web manual step:
   - Keep Apple JS SDK script in `openbudget_app/web/index.html`.

## Platform Validation Checklist

### Web

1. Launch app with all required web defines.
2. Google button renders and completes login.
3. Apple popup opens and completes login.
4. App transitions to authenticated route.

### iOS

1. Sign in with Apple capability is enabled.
2. Launch app with required defines.
3. Google login completes and sets authenticated state.
4. Apple login completes and sets authenticated state.

### Android

1. Launch app with required defines.
2. Google login completes and sets authenticated state.
3. Apple flow returns through `intent://callback` and completes login.

### Regression

1. Email/password login still works.
2. Registration flow still works.
3. Logout still clears auth state.

## Other Providers (Documentation Pathways)

### GitHub (Docs Only)

- Use `serverpod_auth_idp_server` GitHub provider endpoint and PKCE flow.
- Configure GitHub OAuth App with callback URLs per environment.
- Add provider endpoint and client widget wiring similar to Google/Apple.

### Firebase (Docs Only)

- Use Firebase Authentication (Google/Apple/Email/etc.) for client-side identity.
- Pass Firebase ID token to backend via Firebase IDP endpoint.
- Configure Firebase project per platform and secure service account handling.

### Passkey (Docs Only)

- Use Serverpod passkey provider endpoints for registration/login challenges.
- Configure relying party id/domain for web and associated mobile platform handling.
- Add credential creation and assertion UX on login/register surfaces.
