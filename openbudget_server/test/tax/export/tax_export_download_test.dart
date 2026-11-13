import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/export/tax_export_service.dart';
import 'package:openbudget_server/src/tax/export/tax_export_token.dart';
import 'package:openbudget_server/src/tax/tax_endpoint.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:openbudget_server/src/tax/tax_summary_service.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../../support/budget_test_book.dart';
import '../../support/pg_test_server.dart';
import '../../support/tax_test_book.dart';

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
  late TaxEndpoint endpoint;
  var serverStarted = false;

  /// The signing key the tests share, derived the way the service derives
  /// it from the injected `serviceSecret` password.
  final key = TaxExportSigningKey.derive('test-tax-export-secret');

  String mintToken({
    required UuidValue userId,
    required UuidValue entityId,
    int startYear = 2026,
    DateTime? expiresAt,
  }) => TaxExportToken.mint(
    signingKey: key,
    payload: TaxExportTokenPayload(
      userId: userId,
      entityId: entityId,
      startYear: startYear,
      expiresAt: expiresAt ?? DateTime.utc(2026, 11, 13, 12, 10),
    ),
  );

  /// The token a link URL carries, with its `.zip` suffix stripped.
  String tokenFromUrl(String url) {
    final last = Uri.parse(url).pathSegments.last;
    expect(last, endsWith('.zip'));
    return last.substring(0, last.length - '.zip'.length);
  }

  /// Parses CSV text per RFC 4180: quoted fields, doubled quotes, CRLF.
  List<List<String>> parseCsv(String text) {
    final rows = <List<String>>[];
    final field = StringBuffer();
    var row = <String>[];
    var inQuotes = false;
    for (var index = 0; index < text.length; index++) {
      final char = text[index];
      if (inQuotes) {
        if (char == '"') {
          if (index + 1 < text.length && text[index + 1] == '"') {
            field.write('"');
            index++;
          } else {
            inQuotes = false;
          }
        } else {
          field.write(char);
        }
      } else if (char == '"') {
        inQuotes = true;
      } else if (char == ',') {
        row.add(field.toString());
        field.clear();
      } else if (char == '\r') {
        // The line feed that follows ends the row.
      } else if (char == '\n') {
        row.add(field.toString());
        field.clear();
        rows.add(row);
        row = <String>[];
      } else {
        field.write(char);
      }
    }
    if (field.isNotEmpty || row.isNotEmpty) {
      row.add(field.toString());
      rows.add(row);
    }
    return rows;
  }

  /// The export ZIP bytes for [token], or null when the download refused.
  Future<
    ({
      String filename,
      List<List<String>> summary,
      List<List<String>> lines,
      String readme,
    })?
  >
  download(String token) async {
    final result = await TaxExportService.buildDownload(
      book.session,
      token: token,
    );
    if (result == null) return null;
    final archive = ZipDecoder().decodeBytes(result.bytes);
    expect(
      archive.files.map((file) => file.name).toSet(),
      {'summary.csv', 'lines.csv', 'README.txt'},
    );
    return (
      filename: result.filename,
      summary: parseCsv(utf8.decode(archive.findFile('summary.csv')!.content)),
      lines: parseCsv(utf8.decode(archive.findFile('lines.csv')!.content)),
      readme: utf8.decode(archive.findFile('README.txt')!.content),
    );
  }

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      backfillScheduler: (_, _) async {},
    );
    EntityRealtimeNotifier.debugPublisher = (
      _,
      _,
      _, {
      month,
      accountId,
    }) async {};
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxSummaryService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.utc(2026, 11, 13);
    TaxSummaryService.clock = () => DateTime.utc(2026, 11, 13);
    TaxExportService.clock = () => DateTime.utc(2026, 11, 13, 12);
    await server.clearRates();
    // The test config's own secret: CI's passwords.yaml provides one and
    // the ??= keeps it, a bare local run gets this one injected.
    server.session.server.passwords['serviceSecret'] ??=
        'test-tax-export-secret';
    book = await BudgetTestBook.create(
      server.anonymousSession(),
      kind: EntityKind.soleTrader,
    );
    await saveTaxProfile(book.session, book.entity);
    endpoint = TaxEndpoint();
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxSummaryService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.now().toUtc();
    TaxSummaryService.clock = () => DateTime.now().toUtc();
    TaxExportService.clock = () => DateTime.now().toUtc();
    EntityRealtimeNotifier.resetForTests();
    FxService.resetForTests();
  });

  group('when a GB sole trader with VAT and FX lines exports', () {
    setUp(() async {
      final gbp = await book.addAccount(name: 'GBP');
      final usd = await book.addAccount(name: 'USD', currencyCode: 'USD');
      await book.seedRate(
        currencyCode: 'USD',
        rateDate: DateTime.utc(2026, 6, 14),
        rate: '1',
      );
      await book.seedRate(
        currencyCode: 'GBP',
        rateDate: DateTime.utc(2026, 6, 14),
        rate: '0.8',
      );

      // A £1,200 sale carrying £200 output VAT: 20% over its net.
      await createTaxTransaction(
        book.session,
        gbp,
        amountMinor: 120000,
        date: DateTime.utc(2026, 6, 10),
        description: 'Website build invoice',
        lines: [
          TransactionLineInput(
            amountMinor: 120000,
            taxCategoryCode: 'universal.income.self_employment',
            salesTaxMinor: 20000,
          ),
        ],
      );
      // A $1,200 software subscription carrying $200 input VAT, 60%
      // business use. Converted at 0.8 GBP per USD: the base amount is
      // ((100000 * 0.8) * 60%) = 48000.
      await createTaxTransaction(
        book.session,
        usd,
        amountMinor: -120000,
        date: DateTime.utc(2026, 6, 15),
        fxRate: '0.8',
        description: 'Software subscription',
        lines: [
          TransactionLineInput(
            amountMinor: -120000,
            taxCategoryCode: 'universal.expense.software',
            businessUsePercent: 60,
            salesTaxMinor: -20000,
          ),
        ],
      );
      // A £300 travel expense with no VAT, fully business use.
      await createTaxTransaction(
        book.session,
        gbp,
        amountMinor: -30000,
        date: civilDate(2026, 8, 1),
        description: 'Train to client',
        lines: [
          TransactionLineInput(
            amountMinor: -30000,
            taxCategoryCode: 'universal.expense.travel',
          ),
        ],
      );
      // One line with no category, which must feed no total.
      await createTaxTransaction(
        book.session,
        gbp,
        amountMinor: 9999,
        date: DateTime.utc(2026, 5, 6),
        description: 'Uncoded till receipt',
        lines: [TransactionLineInput(amountMinor: 9999)],
      );
    });

    test('then the link URL carries no personal data', () async {
      final url = await endpoint.createExportLink(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );

      final uri = Uri.parse(url);
      expect(uri.path, startsWith('/tax/export/'));
      expect(uri.path, endsWith('.zip'));
      expect(uri.path, isNot(contains('@')));
      expect(uri.path, isNot(contains('Test book')));
      expect(uri.queryParameters, isEmpty);
      final token = tokenFromUrl(url);
      expect(token.split('.'), hasLength(2));
      expect(token, matches(RegExp(r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$')));
    });

    test(
      'then the download is a ZIP whose lines sum to the summary totals',
      () async {
        final url = await endpoint.createExportLink(
          book.session,
          book.entity.id!,
          startYear: 2026,
        );
        final export = await download(tokenFromUrl(url));
        expect(export, isNotNull);
        expect(export!.filename, 'openbudget-tax-2026.zip');

        // The summary carries the header facts and the totals the U8
        // view defines.
        final header = {
          for (final row in export.summary.skip(1))
            if (row[0] == 'header') row[1]: row[6],
        };
        expect(header['summary currency'], 'GBP');
        expect(header['tax year'], '2026/27');
        expect(header['rules layer'], 'rule pack');
        expect(header['rules version'], isNotEmpty);
        expect(header['uncategorised lines'], '1');

        double amountOf(
          List<List<String>> rows,
          String section,
          String item, {
          String label = '',
          String code = '',
        }) => double.parse(
          rows.firstWhere(
            (row) =>
                row[0] == section &&
                (item.isEmpty || row[1] == item) &&
                (label.isEmpty || row[3] == label) &&
                (code.isEmpty || row[2] == code),
          )[4],
        );

        expect(
          amountOf(export.summary, 'income totals', '', code: 'gb.se.turnover'),
          1000.00,
        );
        expect(
          amountOf(
            export.summary,
            'expense totals',
            '',
            code: 'gb.se.phone_office',
          ),
          480.00,
        );
        expect(
          amountOf(
            export.summary,
            'expense totals',
            '',
            code: 'gb.se.car_van_travel',
          ),
          300.00,
        );
        expect(
          amountOf(export.summary, 'sales tax', 'total', label: 'collected'),
          200.00,
        );
        expect(
          amountOf(export.summary, 'sales tax', 'total', label: 'paid'),
          96.00,
        );

        // Every line row sums, per category code, to the matching
        // summary total: the two files cannot disagree.
        final lines = export.lines.skip(1).toList();
        expect(lines, hasLength(4));
        final sumsByCode = <String, double>{};
        for (final row in lines) {
          final code = row[9];
          if (code.isEmpty) continue;
          final base = double.parse(row[5]);
          sumsByCode[code] = (sumsByCode[code] ?? 0) + base;
        }
        final summaryByCode = <String, double>{};
        for (final row in export.summary.skip(1)) {
          if (row[0].endsWith('totals') && row[2].isNotEmpty) {
            summaryByCode[row[2]] = double.parse(row[4]);
          }
        }
        expect(sumsByCode, summaryByCode);

        // The FX line reports the exact rate facts behind its conversion.
        final fxLine = lines.singleWhere((row) => row[4] == 'USD');
        expect(fxLine[0], '2026-06-15');
        expect(fxLine[1], '');
        expect(fxLine[2], 'Software subscription');
        expect(fxLine[3], '-1200.00');
        expect(fxLine[5], '480.00');
        expect(fxLine[6], '0.8');
        expect(fxLine[7], '2026-06-14');
        expect(fxLine[8], 'market');
        expect(fxLine[9], 'gb.se.phone_office');
        expect(fxLine[10], isNotEmpty);
        expect(fxLine[11], '60');
        expect(fxLine[12], '160.00');

        // The uncoded line shows its amount and no base amount.
        final uncoded = lines.singleWhere(
          (row) => row[2] == 'Uncoded till receipt',
        );
        expect(uncoded[3], '99.99');
        expect(uncoded[5], '');
        expect(uncoded[9], '');

        // The README explains the rules version and the disclaimer.
        final ruleSet = TaxRules.forJurisdiction(TaxJurisdiction.gb).ruleSet(
          2026,
        );
        expect(export.readme, contains(ruleSet.versionFor(TaxJurisdiction.gb)));
        // Wrap-safe: the README is fixed-width text, so a phrase may break
        // across lines.
        expect(
          export.readme.replaceAll('\n', ' '),
          contains('not tax advice'),
        );
      },
    );

    test('then amounts are decimal strings at the currency exponent', () async {
      final url = await endpoint.createExportLink(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );
      final export = await download(tokenFromUrl(url));
      expect(export, isNotNull);

      // GBP: two decimal places, exactly.
      final gbpLine = export!.lines
          .skip(1)
          .singleWhere((row) => row[4] == 'GBP' && row[2] == 'Train to client');
      expect(gbpLine[3], '-300.00');
      expect(gbpLine[5], '300.00');
      expect(gbpLine[3].split('.').last, hasLength(2));

      final incomeTotal = export.summary
          .skip(1)
          .firstWhere(
            (row) => row[0] == 'income totals',
          );
      expect(incomeTotal[4], '1000.00');
    });
  });

  group('when a Japanese individual exports a zero-decimal currency', () {
    late Entity japan;

    setUp(() async {
      book = await BudgetTestBook.create(
        server.anonymousSession(),
        baseCurrencyCode: 'JPY',
        countryCode: 'JP',
        timeZone: 'Asia/Tokyo',
      );
      japan = book.entity;
      final account = await book.addAccount();
      await createTaxTransaction(
        book.session,
        account,
        amountMinor: 123456,
        date: DateTime.utc(2026, 3, 15),
        lines: [
          TransactionLineInput(
            amountMinor: 123456,
            taxCategoryCode: 'universal.income.other',
          ),
        ],
      );
    });

    test('then amounts carry no decimal places', () async {
      final url = await endpoint.createExportLink(
        book.session,
        japan.id!,
        startYear: 2026,
      );
      final export = await download(tokenFromUrl(url));
      expect(export, isNotNull);

      final line = export!.lines.skip(1).single;
      expect(line[4], 'JPY');
      expect(line[3], '123456');
      expect(line[3].contains('.'), isFalse);
      expect(line[5], '123456');
      expect(line[5].contains('.'), isFalse);

      final incomeTotal = export.summary
          .skip(1)
          .firstWhere(
            (row) => row[0] == 'income totals',
          );
      expect(incomeTotal[4], '123456');
      expect(incomeTotal[4].contains('.'), isFalse);
    });

    test('then a link without a year resolves the entity tax year', () async {
      // Japan's universal tax year is the calendar year, and the frozen
      // clock sits inside 2026.
      final url = await endpoint.createExportLink(book.session, japan.id!);
      final export = await download(tokenFromUrl(url));
      expect(export, isNotNull);
      expect(export!.filename, 'openbudget-tax-2026.zip');

      final header = {
        for (final row in export.summary.skip(1))
          if (row[0] == 'header') row[1]: row[6],
      };
      expect(header['tax year'], '2026');
      expect(header['rules layer'], 'universal');
    });
  });

  group('when the token expires', () {
    test('then ten minutes later the download refuses', () async {
      var now = DateTime.utc(2026, 11, 13, 12);
      TaxExportService.clock = () => now;

      final url = await endpoint.createExportLink(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );
      final token = tokenFromUrl(url);
      expect(await download(token), isNotNull);

      now = now.add(taxExportLinkTtl);
      expect(
        await download(token),
        isNotNull,
        reason: 'the expiry is inclusive',
      );

      now = now.add(const Duration(milliseconds: 1));
      expect(await download(token), isNull);
    });
  });

  group('when a token is not bound to its owner and entity', () {
    test('then a tampered year fails', () async {
      final url = await endpoint.createExportLink(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );
      final token = tokenFromUrl(url);
      final parts = token.split('.');
      final bytes = Uint8List.fromList(
        base64Url.decode(base64Url.normalize(parts.first)),
      );
      bytes[32] = bytes[32] ^ 0x01;
      final forged =
          '${base64Url.encode(bytes).replaceAll('=', '')}.${parts.last}';

      expect(await download(forged), isNull);
    });

    test("then another user's token for the same entity fails", () async {
      final other = await BudgetTestBook.create(server.anonymousSession());
      final token = mintToken(userId: other.userId, entityId: book.entity.id!);

      expect(await download(token), isNull);
    });

    test('then a token for an entity the user no longer owns fails', () async {
      final other = await BudgetTestBook.create(server.anonymousSession());
      final token = mintToken(userId: book.userId, entityId: book.entity.id!);
      expect(await download(token), isNotNull);

      book.entity.ownerId = other.userId;
      await Entity.db.updateRow(book.session, book.entity);

      expect(await download(token), isNull);
    });

    test('then a token for a missing entity fails', () async {
      final token = mintToken(
        userId: book.userId,
        entityId: const Uuid().v7obj(),
      );

      expect(await download(token), isNull);
    });

    test('then a link cannot be created for a foreign entity', () async {
      final other = await BudgetTestBook.create(server.anonymousSession());

      await expectLater(
        endpoint.createExportLink(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('then a missing service secret fails loudly', () async {
      final passwords = server.session.server.passwords;
      final saved = passwords['serviceSecret'];
      passwords['serviceSecret'] = '';
      try {
        await expectLater(
          endpoint.createExportLink(book.session, book.entity.id!),
          throwsA(
            isA<ValidationException>().having(
              (error) => error.message,
              'message',
              contains('serviceSecret'),
            ),
          ),
        );
        final token = mintToken(userId: book.userId, entityId: book.entity.id!);
        expect(await download(token), isNull);
      } finally {
        if (saved == null) {
          passwords.remove('serviceSecret');
        } else {
          passwords['serviceSecret'] = saved;
        }
      }
    });
  });
}
