# OAuth setup: Google and Apple sign-in

A short checklist for making "Sign in with Google" and "Sign in with Apple"
work end to end on iPhone (and on web and Android where noted).

Everything in angle brackets is a placeholder. Never commit a real client id,
client secret or private key.

## 1. Google Cloud

1. Open the [Google Auth Platform](https://console.cloud.google.com/auth/overview)
   and complete the project setup (app name, support email, audience).
   While the app is in **Testing**, add every tester under **Audience**.
2. Under **Clients**, create a **Web application** OAuth client. This is the
   server client: it is the only Google client with a client secret.
   - If you ship the web app through Serverpod, add your web origin under
     **Authorized JavaScript origins** and `<server>/auth/callback` under
     **Authorized redirect URIs**.
   - Download the JSON. It becomes `googleClientSecret` on the server.
3. Create an **iOS** OAuth client with bundle id `com.openbudget.app` (or
   `com.openbudget.app.dev` for the dev flavor). Download its plist and note
   `CLIENT_ID` (the iOS client id) and `REVERSED_CLIENT_ID` (the URL scheme).
4. On Android, create an **Android** OAuth client for the app id and signing
   SHA-1. The web client's id is still needed on Android as
   `GOOGLE_SERVER_CLIENT_ID`.

## 2. Apple Developer

1. In **Certificates, Identifiers & Profiles → Identifiers**, open the App ID
   for `com.openbudget.app` (and `com.openbudget.app.dev`) and enable
   **Sign in with Apple**. The Runner target already carries the matching
   `com.apple.developer.applesignin` entitlement in
   `openbudget_app/ios/Runner/Runner.entitlements`.
2. Create a **Services ID** for web and Android sign-in, for example
   `app.openbudget.signin`. In its configuration add your domain and the return
   URL `https://<your-host>/auth/apple/callback`.
3. Create a **Key** with Sign in with Apple enabled, download the `.p8` once,
   and note its **Key ID** and your **Team ID**. The key contents, key ID, team
   ID, service ID, bundle id and redirect URI all go to the server.

## 3. Local app configuration

1. Copy the example defines file:
   `openbudget_app/config/dart_defines.example.json` →
   `openbudget_app/config/dart_defines.local.json` (gitignored), then fill it:

   | Key                        | Value                                                        |
   | -------------------------- | ------------------------------------------------------------ |
   | `GOOGLE_CLIENT_ID`         | iOS client id from step 1.3 (Android client id on Android)   |
   | `GOOGLE_SERVER_CLIENT_ID`  | Web client id from step 1.2                                  |
   | `APPLE_SERVICE_IDENTIFIER` | Apple Services ID from step 2.2 (web/Android only)           |
   | `APPLE_REDIRECT_URI`       | `https://<your-host>/auth/apple/callback` (web/Android only) |

   On iPhone, Apple sign-in needs neither `APPLE_SERVICE_IDENTIFIER` nor
   `APPLE_REDIRECT_URI`: it identifies the app by its bundle id and entitlement.
2. Copy `openbudget_app/ios/Flutter/Secrets.example.xcconfig` →
   `openbudget_app/ios/Flutter/Secrets.xcconfig` (gitignored) and set
   `GOOGLE_REVERSED_CLIENT_ID` to the `REVERSED_CLIENT_ID` from step 1.3.
   This is the URL scheme Google returns to. Keep it consistent with
   `GOOGLE_CLIENT_ID`.
3. `devenv.nix` passes `config/dart_defines.local.json` to `flutter:app run`,
   `build`, `test` and `drive` when the file exists. A direct `flutter`
   invocation needs `--dart-define-from-file=config/dart_defines.local.json`.

## 4. Server passwords

1. Copy the keys you need from
   `openbudget_server/config/passwords.example.yaml` into
   `openbudget_server/config/passwords.yaml` (gitignored).
   - `googleClientSecret`: the web client JSON from step 1.2.
   - `googleIosClientId` (optional): the iOS client id. Set it when the app
     does not send `GOOGLE_SERVER_CLIENT_ID`; the server then also accepts
     native iOS tokens minted for the iOS client.
   - `appleServiceIdentifier`, `appleBundleIdentifier`
     (`com.openbudget.app`), `appleRedirectUri`, `appleTeamId`, `appleKeyId`,
     `appleKey`: from steps 2.2 and 2.3. Serverpod needs all six to construct
     the provider, including when only native iOS sign-in is used.
   - `appleAndroidPackageIdentifier` (optional, Android only).
2. On Serverpod Cloud, set each value from a file instead of committing it:

   ```bash
   scloud password set googleClientSecret --from-file google-client-secret.json
   scloud password set googleIosClientId --value <ios-client-id>
   scloud password set appleServiceIdentifier --value <service-id>
   scloud password set appleBundleIdentifier --value com.openbudget.app
   scloud password set appleRedirectUri --value https://<your-host>/auth/apple/callback
   scloud password set appleTeamId --value <team-id>
   scloud password set appleKeyId --value <key-id>
   scloud password set appleKey --from-file AuthKey_<key-id>.p8
   ```

   Use `--project <project-id>` when the project is not linked.

The server enables each provider only when its passwords are present, so a
missing key means the matching button has nothing to call.

## 5. Run it

```bash
devenv up

# Dev flavor on an iPhone (devenv adds the defines file automatically).
flutter:app run --flavor dev -t lib/main_dev.dart -d <device-id>

# Production flavor.
flutter:app run --flavor prod -t lib/main_prod.dart -d <device-id>
```

A physical iPhone cannot reach `localhost`. Point the app at your machine's LAN
address or a deployed server:

```bash
flutter:app run --flavor dev -t lib/main_dev.dart -d <device-id> \
  --dart-define=OPENBUDGET_API_URL=http://<your-lan-ip>:8080/
```

## 6. Test on a real iPhone

1. Open the workspace in Xcode, select the Runner target, and confirm the
   Signing team matches the App ID that has the Sign in with Apple capability.
2. Run the app, tap **Continue with Google**, and complete the account picker.
   Then tap **Continue with Apple** and complete the native sheet.
3. In both cases the app should land signed in and the account should appear
   after a restart (the session token is stored by the auth session manager).
4. If a button does not appear:
   - Google needs `GOOGLE_CLIENT_ID` at build time.
   - Apple appears on iPhone without any defines; if it is missing, check the
     platform is iOS and the entitlement is present.
5. If sign-in fails after the native sheet:
   - Google tokens are minted for the iOS client id when
     `GOOGLE_SERVER_CLIENT_ID` is absent. Either set it, or set
     `googleIosClientId` on the server.
   - Apple's identity token is addressed to the bundle id. Verify
     `appleBundleIdentifier` matches the installed app (`com.openbudget.app`,
     not `com.openbudget.app.dev`, unless you registered the dev App ID and set
     it there too).

### What works in the iOS Simulator

- Google sign-in generally works if the simulator has a Google account
  available in Safari. The account picker is a web flow.
- Sign in with Apple can show its sheet on an iOS 16+ simulator, but only with
  an Apple ID signed into the simulator. It is less reliable than a device and
  does not prove your signing setup.
- **The simulator does not validate the Sign in with Apple entitlement.** A
  `flutter build ios --simulator --no-codesign` build can show the button and
  even sign in while the App ID or provisioning profile is wrong. Always
  confirm the flow on a physical iPhone before shipping.
- Push notifications, associated domains and App Store receipts do not work in
  the simulator; none of them are needed for these two sign-in flows.

## 7. Verify the server picked up the configuration

Start the server and check the log. If Google or Apple was disabled, the
missing password key is the cause. The server also logs no secrets, so the log
is safe to share.
