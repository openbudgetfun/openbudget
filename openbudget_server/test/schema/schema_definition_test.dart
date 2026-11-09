import 'dart:io';

import 'package:test/test.dart';

void main() {
  final migrations = Directory('migrations')
      .listSync()
      .whereType<Directory>()
      .toList();
  final sql = File('${migrations.single.path}/definition.sql')
      .readAsStringSync();
  final tables = RegExp(r'CREATE TABLE "([^\"]+)" \(([\s\S]*?)\n\);')
      .allMatches(sql)
      .where((m) => !m[1]!.startsWith('serverpod_'))
      .toList();

  test('reset has one migration and no legacy root or wallet tables', () {
    expect(migrations, hasLength(1));
    final names = tables.map((m) => m[1]).toSet();
    expect(
      names,
      containsAll([
        'entity',
        'account',
        'transaction',
        'transaction_line',
        'transfer',
        'account_valuation',
        'monthly_allocation',
        'fx_rate',
        'wallet',
        'audit_event',
      ]),
    );
    for (final old in [
      'budget',
      'fx_rate_entry',
      'fx_rate_snapshot',
      'solana_wallet',
      'wallet_connection',
      'ledger_audit_event',
    ]) {
      expect(names, isNot(contains(old)));
    }
  });
  test('all OpenBudget primary keys are UUIDs', () {
    expect(tables, isNotEmpty);
    for (final table in tables) {
      expect(table[2], contains('"id" uuid'), reason: table[1]);
    }
  });
  test(
    'OpenBudget minor amounts are bigint and no table stores double precision',
    () {
      var amounts = 0;
      for (final table in tables) {
        expect(table[2], isNot(contains('double precision')), reason: table[1]);
        for (final amount in RegExp(
          r'"(\w*Minor)" ([a-z]+)',
        ).allMatches(table[2]!)) {
          amounts++;
          expect(amount[2], 'bigint', reason: '${table[1]}.${amount[1]}');
        }
      }
      expect(amounts, greaterThan(20));
    },
  );
  test(
    'ownership cascades and protective references are in the definition',
    () {
      final constraints = RegExp(
        r'ALTER TABLE ONLY "([^\"]+)"[\s\S]*?FOREIGN KEY\s*\("([^\"]+)"\)[\s\S]*?ON DELETE ([A-Z ]+?)(?:;|\s+ON UPDATE)',
      ).allMatches(sql).toList();
      expect(constraints, isNotEmpty);
      for (final constraint in constraints) {
        final column = constraint[2]!;
        final action = constraint[3]!.trim();
        if (column == 'entityId')
          expect(action, 'CASCADE', reason: constraint[1]);
        if (column == 'ownerId')
          expect(action, 'RESTRICT', reason: constraint[1]);
      }
    },
  );
}
