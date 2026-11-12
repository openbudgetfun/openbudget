import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/more/screens/more_screen.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../ledger/ledger_test_data.dart';

Widget buildSubject({
  TaxProfileRecord? profile,
  AccountingMode accountingMode = AccountingMode.envelope,
  EntityKind kind = EntityKind.individual,
}) {
  final container = ProviderContainer(
    overrides: [
      taxProfileProvider.overrideWith((ref, id) async => profile),
      entityDetailProvider.overrideWith(
        (ref, id) async =>
            testEntity(accountingMode: accountingMode, kind: kind),
      ),
    ],
  );
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MoreScreen(entityId: 'test-budget-1'),
    ),
  );
}

void main() {
  Finder skribbleIcon(WiredSvgIconData data) => find.byWidgetPredicate(
    (widget) => widget is SkribbleIcon && widget.data == data,
  );

  group('MoreScreen', () {
    testWidgets('renders More title in app bar', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('shows all navigation items', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Recurring Transactions'), findsOneWidget);
      expect(find.text('Payees'), findsOneWidget);
      expect(find.text('Transaction Rules'), findsOneWidget);
      expect(find.text('Import Transactions'), findsOneWidget);
      expect(find.text('Taxes'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Assistant'), findsOneWidget);
    });

    testWidgets('shows correct icons for each item', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(skribbleIcon(OpenBudgetIcons.sparkle), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.recurring), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.people), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.rule), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.upload), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.scale), findsOneWidget);
      expect(skribbleIcon(OpenBudgetIcons.settings), findsOneWidget);
    });

    testWidgets('shows chevron trailing icons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(skribbleIcon(OpenBudgetIcons.chevronRight), findsNWidgets(7));
    });

    testWidgets('renders items inside a Card', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    group('books entry', () {
      testWidgets('hides for a personal budget', (tester) async {
        await tester.pumpWidget(
          buildSubject(
            profile: businessTaxProfile(
              entityKind: EntityKind.individual,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('books-entry-tile')), findsNothing);
        expect(find.text('Enable double-entry books'), findsNothing);
      });

      testWidgets('offers to enable books for a sole trader in envelope mode', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(
            profile: businessTaxProfile(),
            kind: EntityKind.soleTrader,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('books-entry-tile')), findsOneWidget);
        expect(find.text('Enable double-entry books'), findsOneWidget);
        expect(skribbleIcon(OpenBudgetIcons.document), findsOneWidget);
      });

      testWidgets('shows the books entry for a company already on ledger', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(
            profile: businessTaxProfile(entityKind: EntityKind.company),
            accountingMode: AccountingMode.ledger,
            kind: EntityKind.company,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('books-entry-tile')), findsOneWidget);
        expect(find.text('Books'), findsOneWidget);
      });
    });
  });
}
