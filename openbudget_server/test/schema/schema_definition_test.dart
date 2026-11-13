import 'dart:io';

import 'package:test/test.dart';

void main() {
  final migrations =
      Directory('migrations').listSync().whereType<Directory>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  // The newest definition.sql is the full current schema; older ones are
  // history.
  final sql = File('${migrations.last.path}/definition.sql').readAsStringSync();
  final tables = RegExp(r'CREATE TABLE "([^\"]+)" \(([\s\S]*?)\n\);')
      .allMatches(sql)
      .where((m) => !m[1]!.startsWith('serverpod_'))
      .toList();
  String tableSql(String name) => tables.singleWhere((m) => m[1] == name)[2]!;

  test('the schema reset is the first and multichain the newest migration', () {
    expect(migrations, hasLength(2));
    expect(migrations.first.path, endsWith('schema-reset'));
    expect(migrations.last.path, endsWith('multichain-wallet-schema'));
  });

  test('no legacy root or wallet tables', () {
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

  test(
    'the newest definition has the multichain wallet tables and columns',
    () {
      final names = tables.map((m) => m[1]).toSet();
      expect(names, contains('wallet_network_state'));
      expect(
        tableSql('wallet_network_state'),
        contains('"historyCursor" text'),
      );
      expect(
        tableSql('wallet_holding'),
        contains('"network" text NOT NULL'),
      );
      expect(
        tableSql('wallet_holding'),
        contains("\"position\" text NOT NULL DEFAULT 'available'::text"),
      );
      expect(
        tableSql('wallet_holding'),
        contains("\"spamVerdict\" text NOT NULL DEFAULT 'clean'::text"),
      );
      expect(
        tableSql('wallet_transaction'),
        contains('"network" text NOT NULL'),
      );
      expect(tableSql('wallet'), contains('"scanNetworks" json'));
      expect(tableSql('wallet'), contains('"descriptorCiphertext" text'));
      expect(tableSql('wallet'), contains('"descriptorNonce" text'));
    },
  );

  test('the multichain indexes are in the newest definition', () {
    expect(
      sql,
      contains(
        'CREATE UNIQUE INDEX "wallet_holding_wallet_asset_unique_idx" ON '
        '"wallet_holding" USING btree '
        '("walletId", "network", "assetId", "position");',
      ),
    );
    expect(
      sql,
      contains(
        'CREATE INDEX "wallet_holding_asset_idx" ON "wallet_holding" '
        'USING btree ("network", "assetId");',
      ),
    );
    expect(
      sql,
      contains(
        'CREATE UNIQUE INDEX "wallet_transaction_wallet_signature_unique_idx" '
        'ON "wallet_transaction" USING btree '
        '("walletId", "network", "signature");',
      ),
    );
    expect(
      sql,
      contains(
        'CREATE UNIQUE INDEX "wallet_network_state_wallet_network_unique_idx" '
        'ON "wallet_network_state" USING btree ("walletId", "network");',
      ),
    );
  });

  test('the newest migration backfills holdings and transactions', () {
    final migrationSql = File(
      '${migrations.last.path}/migration.sql',
    ).readAsStringSync();
    for (final entry in [
      ('wallet_holding', 'h'),
      ('wallet_transaction', 't'),
    ]) {
      final (table, alias) = entry;
      expect(
        migrationSql,
        contains('ALTER TABLE "$table" ADD COLUMN "network" text;'),
        reason: 'the column is added nullable so existing rows survive',
      );
      expect(
        migrationSql,
        contains(
          'UPDATE "$table" AS $alias SET "network" = w."network"\n'
          '  FROM "wallet" AS w WHERE $alias."walletId" = w."id";',
        ),
        reason: '$table is backfilled from its wallet',
      );
      expect(
        migrationSql,
        contains('ALTER TABLE "$table" ALTER COLUMN "network" SET NOT NULL;'),
      );
    }
    expect(migrationSql, isNot(contains('DROP TABLE')));
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
        if (column == 'entityId') {
          expect(action, 'CASCADE', reason: constraint[1]);
        }
        if (column == 'ownerId') {
          expect(action, 'RESTRICT', reason: constraint[1]);
        }
      }
    },
  );
}
