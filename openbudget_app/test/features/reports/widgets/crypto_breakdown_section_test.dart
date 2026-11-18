import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/crypto_breakdown_provider.dart';
import 'package:openbudget_app/src/features/reports/widgets/crypto_breakdown_section.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/crypto_breakdown.dart';

const _entityId = '00000000-0000-0000-0000-0000000000e1';

Widget _subject({
  required FutureOr<CryptoBreakdownView> Function(CryptoBreakdownGrouping)
  answer,
  ThemeData? theme,
  List<(String, CryptoBreakdownGrouping)>? requests,
}) => ProviderScope(
  overrides: [
    cryptoBreakdownProvider.overrideWith((ref, arg) {
      requests?.add(arg);
      return answer(arg.$2);
    }),
  ],
  child: MaterialApp(
    theme: theme ?? OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CryptoBreakdownSection(entityId: _entityId),
        ),
      ),
    ),
  ),
);

Finder get _section => find.byKey(const Key('crypto-breakdown-section'));
Finder _bar(CryptoBreakdownGrouping grouping) =>
    find.byKey(ValueKey('crypto-breakdown-bar-${grouping.name}'));

void main() {
  testWidgets('shows the bar, the total and a row per chain', (tester) async {
    await tester.pumpWidget(_subject(answer: cryptoBreakdownView));
    await tester.pumpAndSettle();

    expect(_section, findsOneWidget);
    expect(find.text('Crypto'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('crypto-breakdown-total')),
        matching: find.text('£200.00'),
      ),
      findsOneWidget,
    );
    expect(find.text('Across 2 wallets'), findsOneWidget);
    expect(_bar(CryptoBreakdownGrouping.byChain), findsOneWidget);

    for (final (key, name, value, share) in const [
      ('ethereumMainnet', 'Ethereum', '£100.00', '50%'),
      ('solanaMainnet', 'Solana', '£70.00', '35%'),
      ('baseMainnet', 'Base', '£30.00', '15%'),
    ]) {
      final row = find.byKey(ValueKey('crypto-breakdown-row-$key'));
      expect(row, findsOneWidget, reason: key);
      expect(
        find.descendant(of: row, matching: find.text(name)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: row, matching: find.text(value)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: row, matching: find.text(share)),
        findsOneWidget,
      );
    }
    expect(find.text('4 holdings'), findsOneWidget);
    expect(find.text('1 holding'), findsOneWidget);
  });

  testWidgets('the bar has a text alternative listing the shares', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_subject(answer: cryptoBreakdownView));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(_bar(CryptoBreakdownGrouping.byChain)),
      matchesSemantics(
        label: 'By chain: Ethereum 50%, Solana 35%, Base 15%',
        isImage: true,
      ),
    );

    await tester.tap(find.byKey(const Key('crypto-breakdown-toggle-by-asset')));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(_bar(CryptoBreakdownGrouping.byAsset)),
      matchesSemantics(
        label: 'By asset: USDC 40%, ETH 30%, SOL 20%, Other 10%',
        isImage: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('the toggle regroups by asset and back, merging USDC', (
    tester,
  ) async {
    final requests = <(String, CryptoBreakdownGrouping)>[];
    await tester.pumpWidget(
      _subject(answer: cryptoBreakdownView, requests: requests),
    );
    await tester.pumpAndSettle();

    // Both groupings are requested up front, once each.
    expect(requests, [
      (_entityId, CryptoBreakdownGrouping.byChain),
      (_entityId, CryptoBreakdownGrouping.byAsset),
    ]);
    expect(
      find.byKey(const ValueKey('crypto-breakdown-row-asset:USDC')),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('crypto-breakdown-toggle-by-asset')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('crypto-breakdown-row-ethereumMainnet')),
      findsNothing,
    );
    final usdc = find.byKey(const ValueKey('crypto-breakdown-row-asset:USDC'));
    expect(usdc, findsOneWidget);
    expect(
      find.descendant(of: usdc, matching: find.text('USDC')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: usdc, matching: find.text('Ethereum, Base +1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: usdc, matching: find.text('£80.00')),
      findsOneWidget,
    );
    final other = find.byKey(const ValueKey('crypto-breakdown-row-other'));
    expect(
      find.descendant(of: other, matching: find.text('Other')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: other, matching: find.text('3 smaller holdings')),
      findsOneWidget,
    );
    expect(_bar(CryptoBreakdownGrouping.byAsset), findsOneWidget);
    // The total does not change with the grouping.
    expect(
      find.descendant(
        of: find.byKey(const Key('crypto-breakdown-total')),
        matching: find.text('£200.00'),
      ),
      findsOneWidget,
    );
    // The switch used what was already fetched.
    expect(requests, hasLength(2));

    await tester.tap(find.byKey(const Key('crypto-breakdown-toggle-by-chain')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('crypto-breakdown-row-ethereumMainnet')),
      findsOneWidget,
    );
  });

  testWidgets('the selected toggle says it is selected', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_subject(answer: cryptoBreakdownView));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(
        find.byKey(const Key('crypto-breakdown-toggle-by-chain')),
      ),
      matchesSemantics(
        label: 'By chain',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('an entity with no wallets shows nothing', (tester) async {
    await tester.pumpWidget(_subject(answer: noWalletsBreakdown));
    await tester.pumpAndSettle();

    expect(_section, findsNothing);
    expect(find.text('Crypto'), findsNothing);
    expect(tester.getSize(find.byType(CryptoBreakdownSection)).height, 0);
  });

  testWidgets('nothing is drawn while the first answer is loading', (
    tester,
  ) async {
    final completer = Completer<CryptoBreakdownView>();
    await tester.pumpWidget(_subject(answer: (_) => completer.future));
    await tester.pump();

    expect(_section, findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    completer.complete(cryptoBreakdownView(CryptoBreakdownGrouping.byChain));
    await tester.pumpAndSettle();
    expect(_section, findsOneWidget);
  });

  testWidgets('a failed request says so and retries', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      _subject(
        answer: (grouping) {
          attempts += 1;
          if (attempts <= 2) throw StateError('server down');
          return cryptoBreakdownView(grouping);
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load your crypto breakdown"), findsOneWidget);
    expect(_section, findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(_section, findsOneWidget);
    expect(find.text("Couldn't load your crypto breakdown"), findsNothing);
  });

  testWidgets('wallets with nothing counted explain the empty section', (
    tester,
  ) async {
    await tester.pumpWidget(
      _subject(
        answer: (grouping) => cryptoBreakdownView(
          grouping,
          walletCount: 1,
          rows: const [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Across 1 wallet'), findsOneWidget);
    expect(find.byKey(const Key('crypto-breakdown-empty')), findsOneWidget);
    expect(_bar(CryptoBreakdownGrouping.byChain), findsNothing);
  });

  testWidgets('a currency with no rate is named, never guessed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _subject(
        answer: (grouping) => cryptoBreakdownView(
          grouping,
          isComplete: false,
          missingCurrencyCodes: const ['EUR', 'JPY'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No exchange rate for EUR, JPY, so those holdings are left out of '
        'this figure.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a slice under one percent reads "<1%"', (tester) async {
    await tester.pumpWidget(
      _subject(
        answer: (grouping) => cryptoBreakdownView(
          grouping,
          rows: [
            cryptoBreakdownView(grouping).rows.first.copyWith(
              valueMinor: 19950,
              shareBasisPoints: 9975,
            ),
            cryptoBreakdownView(grouping).rows.last.copyWith(
              valueMinor: 50,
              shareBasisPoints: 25,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('<1%'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('an unlisted token without a symbol shows a short id', (
    tester,
  ) async {
    await tester.pumpWidget(
      _subject(
        answer: (grouping) => cryptoBreakdownView(
          grouping,
          rows: grouping == CryptoBreakdownGrouping.byChain
              ? null
              : [
                  CryptoBreakdownRow(
                    key: 'baseMainnet:0xabcdef0123456789abcdef0123456789abcdef01',
                    networks: const [WalletNetwork.baseMainnet],
                    assetId: '0xabcdef0123456789abcdef0123456789abcdef01',
                    isOther: false,
                    holdingCount: 1,
                    valueMinor: 1000,
                    shareBasisPoints: 10000,
                  ),
                ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('crypto-breakdown-toggle-by-asset')));
    await tester.pumpAndSettle();

    expect(find.text('0xabcd…ef01'), findsOneWidget);
  });

  for (final (name, size, ratio) in const [
    ('phone', Size(390, 844), 3.0),
    ('small phone', Size(320, 640), 2.0),
    ('desktop', Size(1280, 800), 1.0),
  ]) {
    for (final theme in [
      ('light', OpenBudgetTheme.light),
      ('dark', OpenBudgetTheme.dark),
    ]) {
      testWidgets('lays out on a ${theme.$1} $name without overflow', (
        tester,
      ) async {
        tester.view
          ..physicalSize = size * ratio
          ..devicePixelRatio = ratio;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _subject(answer: cryptoBreakdownView, theme: theme.$2),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(
          find.byKey(const Key('crypto-breakdown-toggle-by-asset')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(_bar(CryptoBreakdownGrouping.byAsset), findsOneWidget);
      });
    }
  }

  testWidgets('the bar paints without animating under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _subject(answer: cryptoBreakdownView),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(_bar(CryptoBreakdownGrouping.byChain), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
