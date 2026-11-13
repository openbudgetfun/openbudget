import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_actions_provider.dart';
import 'package:openbudget_app/src/features/home/screens/create_entity_screen.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The arguments of one `create` call.
typedef _Created = ({
  EntityKind kind,
  String countryCode,
  String baseCurrencyCode,
  String timeZone,
  int? fiscalYearEndMonth,
  int? fiscalYearEndDay,
});

/// Records what the screen asks to create. It returns no id, so the screen
/// stays put instead of routing on.
class _RecordingEntityActions extends EntityActions {
  final List<_Created> created = [];

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<String> create({
    required String name,
    required EntityKind kind,
    required String countryCode,
    required String baseCurrencyCode,
    required String timeZone,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
  }) async {
    created.add((
      kind: kind,
      countryCode: countryCode,
      baseCurrencyCode: baseCurrencyCode,
      timeZone: timeZone,
      fiscalYearEndMonth: fiscalYearEndMonth,
      fiscalYearEndDay: fiscalYearEndDay,
    ));
    return '';
  }
}

void main() {
  // A notifier instance serves one container, so each test gets its own.
  late _RecordingEntityActions actions;

  Widget buildSubject() {
    actions = _RecordingEntityActions();
    return ProviderScope(
      overrides: [entityActionsProvider.overrideWith(() => actions)],
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ObWiredScope(child: CreateEntityScreen()),
      ),
    );
  }

  Future<void> pumpPhone(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(360, 780) * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
  }

  /// The picker row for [name], not the search field that may hold it.
  Finder row(String name) => find.descendant(
    of: find.byType(BottomSheet),
    matching: find.widgetWithText(InkWell, name),
  );

  Future<void> pickCountry(WidgetTester tester, String query) async {
    await tester.tap(find.byKey(const Key('create-entity-country-row')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, query);
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    final button = find.byKey(const Key('create-entity-create-button'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  String rowValue(WidgetTester tester, String key) => tester
      .widgetList<Text>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(Text),
        ),
      )
      .map((text) => text.data)
      .whereType<String>()
      .last;

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

    group('any country', () {
      testWidgets('creating a Kenyan individual fills KES, Nairobi and the '
          'Kenyan tax year', (tester) async {
        await pumpPhone(tester);

        await pickCountry(tester, 'kenya');
        await tester.tap(row('Kenya'));
        await tester.pumpAndSettle();

        expect(
          rowValue(tester, 'create-entity-country-row'),
          'Kenya',
        );
        expect(
          rowValue(tester, 'create-entity-currency-row'),
          'Kenyan Shilling (KES)',
        );
        expect(
          rowValue(tester, 'create-entity-time-zone-row'),
          'Africa/Nairobi',
        );
        expect(
          rowValue(tester, 'create-entity-tax-year-row'),
          'Jan 1 to Dec 31',
        );

        await submit(tester);
        expect(actions.created, [
          (
            kind: EntityKind.individual,
            countryCode: 'KE',
            baseCurrencyCode: 'KES',
            timeZone: 'Africa/Nairobi',
            fiscalYearEndMonth: 12,
            fiscalYearEndDay: 31,
          ),
        ]);
      });

      testWidgets('the picker offers servable countries only', (
        tester,
      ) async {
        await pumpPhone(tester);
        final servable = Countries.all.where((c) => c.servable).length;

        await tester.tap(find.byKey(const Key('create-entity-country-row')));
        await tester.pumpAndSettle();
        expect(find.text('$servable results'), findsOneWidget);

        for (final blocked in Countries.all.where((c) => !c.servable)) {
          await tester.enterText(find.byType(TextField).last, blocked.name);
          await tester.pumpAndSettle();
          expect(
            row(blocked.displayName),
            findsNothing,
            reason: '${blocked.code} is not servable',
          );
        }

        // Russia is the case the picker must never show.
        await tester.enterText(find.byType(TextField).last, 'russia');
        await tester.pumpAndSettle();
        expect(row('Russia'), findsNothing);
        expect(row('RU'), findsNothing);
        expect(find.textContaining('Nothing matches'), findsOneWidget);
      });

      testWidgets('countries with a tax pack lead the list', (tester) async {
        await pumpPhone(tester);
        await tester.tap(find.byKey(const Key('create-entity-country-row')));
        await tester.pumpAndSettle();

        expect(find.text('With tax rules built in'), findsOneWidget);
        double top(Finder finder) => tester.getTopLeft(finder).dy;
        // The four packs sit together, above the rest.
        final allCountries = top(find.text('All countries'));
        for (final pack in [
          'Germany',
          'Nigeria',
          'United Kingdom',
          'United States',
        ]) {
          expect(top(row(pack)), lessThan(allCountries), reason: pack);
        }
      });

      testWidgets('a country is found by its code', (tester) async {
        await pumpPhone(tester);
        await pickCountry(tester, 'KE');

        expect(row('Kenya'), findsOneWidget);
      });

      testWidgets('a country is found by what people call it', (tester) async {
        await pumpPhone(tester);
        await pickCountry(tester, 'uk');
        expect(row('United Kingdom'), findsOneWidget);

        await tester.enterText(find.byType(TextField).last, 'ivory coast');
        await tester.pumpAndSettle();
        expect(row('Côte d’Ivoire'), findsOneWidget);
      });

      testWidgets('Bulgaria books in euros', (tester) async {
        await pumpPhone(tester);
        await pickCountry(tester, 'bulgaria');
        await tester.tap(row('Bulgaria'));
        await tester.pumpAndSettle();

        expect(rowValue(tester, 'create-entity-currency-row'), 'Euro (EUR)');
      });

      testWidgets('the currency can still be changed after the country', (
        tester,
      ) async {
        await pumpPhone(tester);
        await pickCountry(tester, 'kenya');
        await tester.tap(row('Kenya'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('create-entity-currency-row')));
        await tester.pumpAndSettle();
        // The country's own currency leads, under its own heading.
        expect(find.text('Used in Kenya'), findsOneWidget);
        await tester.enterText(find.byType(TextField).last, 'USD');
        await tester.pumpAndSettle();
        await tester.tap(row('US Dollar'));
        await tester.pumpAndSettle();

        expect(
          rowValue(tester, 'create-entity-currency-row'),
          'US Dollar (USD)',
        );
        await submit(tester);
        expect(actions.created.single.countryCode, 'KE');
        expect(actions.created.single.baseCurrencyCode, 'USD');
      });

      testWidgets('any ISO currency is searchable, by name or symbol', (
        tester,
      ) async {
        await pumpPhone(tester);
        await tester.tap(find.byKey(const Key('create-entity-currency-row')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).last, 'shilling');
        await tester.pumpAndSettle();
        expect(row('Kenyan Shilling'), findsOneWidget);

        await tester.enterText(find.byType(TextField).last, 'KES');
        await tester.pumpAndSettle();
        expect(row('Kenyan Shilling'), findsOneWidget);
      });

      testWidgets('GB keeps its defaults: GBP, London, 6 April tax year', (
        tester,
      ) async {
        await pumpPhone(tester);

        expect(
          rowValue(tester, 'create-entity-currency-row'),
          'British Pound (GBP)',
        );
        expect(
          rowValue(tester, 'create-entity-time-zone-row'),
          'Europe/London',
        );
        expect(
          rowValue(tester, 'create-entity-tax-year-row'),
          'Apr 6 to Apr 5',
        );

        await submit(tester);
        expect(actions.created.single, (
          kind: EntityKind.individual,
          countryCode: 'GB',
          baseCurrencyCode: 'GBP',
          timeZone: 'Europe/London',
          fiscalYearEndMonth: 4,
          fiscalYearEndDay: 5,
        ));
      });

      testWidgets('a company shows its editable year end, not the tax year', (
        tester,
      ) async {
        await pumpPhone(tester);
        await tester.tap(find.text('Company'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('create-entity-tax-year-row')),
          findsNothing,
        );
        expect(
          rowValue(tester, 'create-entity-fiscal-year-row'),
          'Day 31 of month 3',
        );

        await pickCountry(tester, 'australia');
        await tester.tap(row('Australia'));
        await tester.pumpAndSettle();
        expect(
          rowValue(tester, 'create-entity-fiscal-year-row'),
          'Day 30 of month 6',
        );
      });

      testWidgets('a country whose tax year has no Gregorian dates shows no '
          'tax year', (tester) async {
        await pumpPhone(tester);
        await pickCountry(tester, 'nepal');
        await tester.tap(row('Nepal'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('create-entity-tax-year-row')),
          findsNothing,
        );
        await submit(tester);
        expect(actions.created.single.fiscalYearEndMonth, 12);
        expect(actions.created.single.fiscalYearEndDay, 31);
      });

      testWidgets('a country with no bookable currency starts on USD', (
        tester,
      ) async {
        await pumpPhone(tester);
        await pickCountry(tester, 'antarctica');
        await tester.tap(row('Antarctica'));
        await tester.pumpAndSettle();

        expect(
          rowValue(tester, 'create-entity-currency-row'),
          'US Dollar (USD)',
        );
        expect(
          rowValue(tester, 'create-entity-time-zone-row'),
          'Antarctica/McMurdo',
        );
      });
    });
  });
}
