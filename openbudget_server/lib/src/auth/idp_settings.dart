/// Looks up a password by key, for example `Serverpod.getPassword`.
typedef PasswordLookup = String? Function(String key);

/// The passwords required to construct the Google identity provider.
///
/// `googleClientSecret` is the web OAuth client's JSON secret. The server uses
/// it to verify web tokens and to exchange web authorization codes.
const googleIdpPasswordKeys = ['googleClientSecret'];

/// The passwords required to construct the Apple identity provider.
///
/// Serverpod builds the Apple provider from a single configuration, so the web
/// and Android values are required even when only native iOS sign-in is used.
const appleIdpPasswordKeys = [
  'appleServiceIdentifier',
  'appleBundleIdentifier',
  'appleRedirectUri',
  'appleTeamId',
  'appleKeyId',
  'appleKey',
];

/// The social identity providers that can be switched on from passwords.
class SocialIdpSettings {
  /// Creates a new [SocialIdpSettings].
  const SocialIdpSettings({
    required this.googleEnabled,
    required this.appleEnabled,
  });

  /// Reads the settings through [read].
  factory SocialIdpSettings.fromPasswords(PasswordLookup read) =>
      SocialIdpSettings(
        googleEnabled: hasRequiredPasswords(read, googleIdpPasswordKeys),
        appleEnabled: hasRequiredPasswords(read, appleIdpPasswordKeys),
      );

  /// Whether the Google provider has all of its required passwords.
  final bool googleEnabled;

  /// Whether the Apple provider has all of its required passwords.
  final bool appleEnabled;
}

/// Trims a password and treats an empty value as absent.
String? normalizedPassword(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

/// Whether every password in [keys] has a non-empty value.
bool hasRequiredPasswords(PasswordLookup read, List<String> keys) =>
    keys.every((key) => normalizedPassword(read(key)) != null);

/// The password keys from [keys] that are missing or empty.
List<String> missingPasswords(PasswordLookup read, List<String> keys) =>
    keys.where((key) => normalizedPassword(read(key)) == null).toList();
