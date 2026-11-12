import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/screens/create_entity_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  Widget buildSubject() => ProviderScope(
    child: MaterialApp(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CreateEntityScreen(),
    ),
  );

  group('CreateEntityScreen', () {
    testWidgets('renders welcome onboarding layout', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // The default country leads with the UK, so the base currency
      // starts at GBP; the country sheet switches the default.
      expect(find.text('Create your books'), findsOneWidget);
      expect(find.text('Budget Name'), findsOneWidget);
      expect(find.text('Plan Currency'), findsOneWidget);
      expect(find.text('United Kingdom'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
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

      final bodyTexts = tester
          .widgetList<Text>(find.byType(Text))
          .where(
            (text) =>
                text.style?.fontSize != null && text.style!.fontSize! <= 16,
          )
          .toList();
      expect(bodyTexts, isNotEmpty);
    });
  });
}
