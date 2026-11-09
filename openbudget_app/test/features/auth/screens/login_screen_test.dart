import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/social_sign_in_provider.dart';
import 'package:openbudget_app/src/features/auth/screens/login_screen.dart';
import 'package:openbudget_app/src/features/auth/social_sign_in.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

const _noDefines = SocialSignInDefines(
  googleClientId: false,
  appleServiceIdentifier: false,
  appleRedirectUri: false,
);

const _googleOnly = SocialSignInDefines(
  googleClientId: true,
  appleServiceIdentifier: false,
  appleRedirectUri: false,
);

void main() {
  setUp(() {
    GoogleSignInPlatform.instance = _FakeGoogleSignInPlatform();
  });

  Widget buildSubject({
    SocialSignInDefines defines = _noDefines,
    TargetPlatform platform = TargetPlatform.android,
  }) => ProviderScope(
    overrides: [socialSignInDefinesProvider.overrideWithValue(defines)],
    child: MaterialApp(
      theme: OpenBudgetTheme.light.copyWith(platform: platform),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LoginScreen(),
    ),
  );

  group('LoginScreen', () {
    testWidgets('renders OpenBudget login fields', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byKey(const Key('login-openbudget-mark')), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(ObHighlighter), findsOneWidget);
      expect(find.byType(WiredDoodle), findsOneWidget);
      expect(find.text('Continue with Apple'), findsNothing);
      expect(find.text('Continue with Google'), findsNothing);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets(
      'shows Apple and Google on iOS with only the Google client id',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(platform: TargetPlatform.iOS, defines: _googleOnly),
        );
        await tester.pump();

        expect(find.byType(AppleSignInWidget), findsOneWidget);
        expect(find.byType(GoogleSignInWidget), findsOneWidget);
        expect(find.text('Continue with Apple'), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);
      },
    );

    testWidgets('shows only Apple on iOS without any client ids', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(platform: TargetPlatform.iOS),
      );
      await tester.pump();

      expect(find.byType(AppleSignInWidget), findsOneWidget);
      expect(find.byType(GoogleSignInWidget), findsNothing);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Continue with Google'), findsNothing);
    });

    testWidgets('shows only Google on Android with the Google client id', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(defines: _googleOnly),
      );
      await tester.pump();

      expect(find.byType(AppleSignInWidget), findsNothing);
      expect(find.byType(GoogleSignInWidget), findsOneWidget);
      expect(find.text('Continue with Apple'), findsNothing);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('hides the social section on desktop', (tester) async {
      await tester.pumpWidget(
        buildSubject(platform: TargetPlatform.macOS, defines: _googleOnly),
      );
      await tester.pump();

      expect(find.byType(AppleSignInWidget), findsNothing);
      expect(find.byType(GoogleSignInWidget), findsNothing);
    });

    testWidgets('uses dark status bar icons in light mode', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final annotatedRegion = tester
          .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
          );
      expect(annotatedRegion.value.statusBarIconBrightness, Brightness.dark);
    });

    testWidgets('login button starts disabled when form is empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 500));

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('can enter email and password text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final inputs = find.byType(TextField);
      await tester.enterText(inputs.first, 'test@example.com');
      await tester.enterText(inputs.last, 'password123');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}

/// A platform implementation that supports native sign-in without touching a
/// method channel, so widget tests can render the real Google button.
class _FakeGoogleSignInPlatform extends GoogleSignInPlatform {
  @override
  Future<void> init(InitParameters params) async {}

  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) => null;

  @override
  bool supportsAuthenticate() => true;

  @override
  Future<AuthenticationResults> authenticate(
    AuthenticateParameters params,
  ) => throw UnimplementedError();

  @override
  bool authorizationRequiresUserInteraction() => true;

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) async => null;

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) async => null;

  @override
  Future<void> signOut(SignOutParams params) async {}

  @override
  Future<void> disconnect(DisconnectParams params) async {}
}
