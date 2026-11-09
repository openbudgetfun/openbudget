---
openbudget_app: native
openbudget_server: feat
---

# Wire native iOS Google and Apple sign-in

- The iOS Runner target now ships a `Runner.entitlements` file with the Sign in with Apple capability, applied to every build configuration.
- The Google reversed-client-id URL scheme is read from `ios/Flutter/Secrets.xcconfig` (gitignored, with a committed example) so no client id is committed, and the URL schemes in `Info.plist` expand it.
- The login screen decides social availability through a pure `socialSignInAvailability` function: iOS shows Apple from the native entitlement alone and Google when both Google client ids were supplied, while web and Android keep requiring the Apple service id and redirect URI.
- `config/dart_defines.local.json` (gitignored, example committed) carries the client ids, and the devenv `flutter:app` command passes it to `flutter run`, `build`, `test` and `drive` when it exists.
- Native Google sign-in on iOS and Android only shows when `GOOGLE_SERVER_CLIENT_ID` is also supplied, so the ID token is addressed to the web client that Serverpod's Google provider verifies.
- `server.dart` reads the social provider passwords through tested helpers, and `config/passwords.example.yaml` documents every key.
- The Runner target excludes `x86_64` on the simulator, matching the pod targets' existing `EXCLUDED_ARCHS`, so the simulator build links the arm64-only pod frameworks.
