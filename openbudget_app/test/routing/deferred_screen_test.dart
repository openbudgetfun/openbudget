import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/l10n/generated/app_localizations_en.dart';
import 'package:openbudget_app/src/routing/deferred_screen.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

final _l10n = AppLocalizationsEn();

Future<void> _pump(WidgetTester tester, Widget widget) => tester.pumpApp(
  widget,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
);

Widget _screen(String library, Future<void> Function() load) => DeferredScreen(
  library: library,
  load: load,
  builder: (_) => const Text('Loaded screen'),
);

void main() {
  group('DeferredScreen', () {
    testWidgets('shows a loading panel until the library loads', (
      tester,
    ) async {
      final load = Completer<void>();
      await _pump(tester, _screen('waits', () => load.future));

      expect(find.text(_l10n.loadingTitle), findsOneWidget);
      expect(find.text('Loaded screen'), findsNothing);

      load.complete();
      await tester.pump();
      await tester.pump();

      expect(find.text('Loaded screen'), findsOneWidget);
      expect(DeferredScreen.isLoaded('waits'), isTrue);
    });

    testWidgets('builds at once when the library is already loaded', (
      tester,
    ) async {
      await DeferredScreen.preload('ready', () async {});
      var loads = 0;
      await _pump(tester, _screen('ready', () async => loads++));

      expect(find.text('Loaded screen'), findsOneWidget);
      expect(loads, 0);
    });

    testWidgets('offers Retry after a failed fetch and loads on retry', (
      tester,
    ) async {
      var attempts = 0;
      await _pump(
        tester,
        _screen('flaky', () async {
          attempts++;
          if (attempts == 1) {
            throw DeferredLoadException('part file unreachable');
          }
        }),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text(_l10n.routerScreenLoadError), findsOneWidget);
      expect(find.text(_l10n.loadProblemOffline), findsOneWidget);
      expect(find.textContaining('part file'), findsNothing);
      expect(DeferredScreen.isLoaded('flaky'), isFalse);

      await tester.tap(find.text(_l10n.homeRetry));
      await tester.pump();
      await tester.pump();

      expect(attempts, 2);
      expect(find.text('Loaded screen'), findsOneWidget);
    });
  });

  group('DeferredScreen.preload', () {
    test('shares one fetch between callers', () async {
      var loads = 0;
      final gate = Completer<void>();
      Future<void> load() async {
        loads++;
        await gate.future;
      }

      final first = DeferredScreen.preload('shared', load);
      final second = DeferredScreen.preload('shared', load);
      gate.complete();
      await Future.wait([first, second]);
      await DeferredScreen.preload('shared', load);

      expect(loads, 1);
      expect(DeferredScreen.isLoaded('shared'), isTrue);
    });

    test('forgets a failed fetch so the next call tries again', () async {
      var loads = 0;
      Future<void> load() async {
        loads++;
        if (loads == 1) throw DeferredLoadException('offline');
      }

      await expectLater(
        DeferredScreen.preload('retry', load),
        throwsA(isA<DeferredLoadException>()),
      );
      await DeferredScreen.preload('retry', load);

      expect(loads, 2);
      expect(DeferredScreen.isLoaded('retry'), isTrue);
    });
  });
}
