import 'package:openbudget_app/src/features/auth/social_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'social_sign_in_provider.g.dart';

/// Reports which social sign-in identifiers the build was given.
///
/// The client identifiers themselves are read by the provider packages from
/// the same environment; this only tells the login screen which buttons are
/// safe to show. Tests override it to exercise every platform combination.
@riverpod
SocialSignInDefines socialSignInDefines(Ref ref) => const SocialSignInDefines(
  googleClientId: bool.hasEnvironment('GOOGLE_CLIENT_ID'),
  appleServiceIdentifier: bool.hasEnvironment('APPLE_SERVICE_IDENTIFIER'),
  appleRedirectUri: bool.hasEnvironment('APPLE_REDIRECT_URI'),
);
