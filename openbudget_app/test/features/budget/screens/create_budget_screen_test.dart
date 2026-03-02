import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/screens/create_budget_screen.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildSubject() {
    return ProviderScope(
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CreateBudgetScreen(),
      ),
    );
  }

  group('CreateBudgetScreen', () {
    testWidgets('renders welcome onboarding layout', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Welcome, new OpenBudgeter!'), findsOneWidget);
      expect(find.text('Plan Currency'), findsOneWidget);
      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    });

    testWidgets('renders personalize action button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Personalize Your Plan'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('uses dark status bar icons in light mode', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final annotatedRegions = tester
          .widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
          )
          .toList();
      expect(
        annotatedRegions.any(
          (region) => region.value.statusBarIconBrightness == Brightness.dark,
        ),
        isTrue,
      );
    });

    testWidgets('renders readable paragraph text in light mode', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final subtitle = tester.widget<Text>(
        find.text(
          "We'll show you how to give every dollar a job so you can spend without second-guessing.",
        ),
      );
      final body = tester.widget<Text>(
        find.text(
          "First, let's make sure your categories are in tip-top shape.",
        ),
      );
      final theme = Theme.of(tester.element(find.byType(CreateBudgetScreen)));

      expect(subtitle.style?.color, OpenBudgetPalette.fgSecondaryFor(theme));
      expect(body.style?.color, OpenBudgetPalette.fgSecondaryFor(theme));
    });

    testWidgets('opens currency selector from plan currency row', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Plan Currency'));
      await tester.tap(find.text('Plan Currency'));
      await tester.pumpAndSettle();

      expect(find.text('US Dollar (USD)'), findsWidgets);
    });
  });
}
