import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  Widget buildSubject(AppToastVariant variant) => MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => showAppToast(
              context,
              message: 'Saved',
              variant: variant,
            ),
            child: const Text('Show'),
          ),
        ),
      ),
    ),
  );

  Finder skribbleIcon(WiredSvgIconData data) => find.byWidgetPredicate(
    (widget) => widget is SkribbleIcon && widget.data == data,
  );

  ObRoughDecoration toastDecoration(WidgetTester tester) => tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.byType(Container),
        ),
      )
      .map((container) => container.decoration)
      .whereType<ObRoughDecoration>()
      .single;

  Future<void> showToast(WidgetTester tester, AppToastVariant variant) async {
    await tester.pumpWidget(buildSubject(variant));
    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> dismissToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  group('showAppToast', () {
    testWidgets('draws a funded paper card for success', (tester) async {
      await showToast(tester, AppToastVariant.success);

      final palette = OpenBudgetTheme.light.ob;
      final decoration = toastDecoration(tester);

      expect(find.text('Saved'), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.checkCircle), findsOneWidget);
      expect(decoration.color, palette.fundedWash);
      expect(decoration.outline, palette.quietPen);

      await dismissToast(tester);
    });

    testWidgets('draws an overspent paper card for errors', (tester) async {
      await showToast(tester, AppToastVariant.error);

      final palette = OpenBudgetTheme.light.ob;
      final decoration = toastDecoration(tester);

      expect(skribbleIcon(OpenBudgetIcons.error), findsOneWidget);
      expect(decoration.color, palette.overspentWash);
      expect(decoration.outline, palette.quietPen);

      await dismissToast(tester);
    });
  });
}
