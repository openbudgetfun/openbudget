import 'dart:convert';

import 'package:openbudget_site/src/demo_budget.dart';
import 'package:test/test.dart';

void main() {
  group('DemoCurrency.format', () {
    final usd = demoCurrencies.firstWhere((currency) => currency.code == 'USD');
    final ngn = demoCurrencies.firstWhere((currency) => currency.code == 'NGN');

    test('groups thousands after the symbol', () {
      expect(usd.format(0), r'$0');
      expect(usd.format(950), r'$950');
      expect(usd.format(1350), r'$1,350');
      expect(ngn.format(300000), '₦300,000');
      expect(ngn.format(1250000), '₦1,250,000');
    });

    test('puts the sign before the symbol', () {
      expect(usd.format(-50), r'-$50');
      expect(ngn.format(-5000), '-₦5,000');
    });
  });

  group('demo currencies', () {
    for (final currency in demoCurrencies) {
      test('${currency.code} leaves something to assign on every envelope '
          'the slider can reach', () {
        expect(currency.targets, hasLength(demoEnvelopes.length));
        expect(currency.start, hasLength(demoEnvelopes.length));
        for (final (index, target) in currency.targets.indexed) {
          final start = currency.start[index];
          expect(target % currency.step, 0, reason: 'target $index');
          expect(start % currency.step, 0, reason: 'start $index');
          expect(start, inInclusiveRange(0, target), reason: 'start $index');
        }
        expect(currency.readyToAssign, greaterThan(0));
      });
    }

    test('the default is US dollars, as the headline says', () {
      expect(demoCurrencies.first.word, 'dollar');
    });
  });

  group('demoBudgetJson', () {
    test('carries every envelope, currency and message', () {
      final data = jsonDecode(demoBudgetJson()) as Map<String, Object?>;

      expect(
        (data['envelopes']! as List<Object?>).cast<Map<String, Object?>>().map(
          (envelope) => envelope['id'],
        ),
        demoEnvelopes.map((envelope) => envelope.id),
      );
      expect(
        (data['currencies']! as List<Object?>).cast<Map<String, Object?>>().map(
          (currency) => currency['code'],
        ),
        demoCurrencies.map((currency) => currency.code),
      );
      expect(data['messages'], demoMessages);
    });

    test('cannot close the script element it is embedded in', () {
      expect(demoBudgetJson(), isNot(contains('</')));
    });
  });
}
