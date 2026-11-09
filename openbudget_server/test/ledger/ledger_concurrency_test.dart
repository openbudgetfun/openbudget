import 'dart:convert';
import 'dart:math';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

/// Concurrent requests need real transactions, so this group commits its
/// writes. Each run uses fresh random users, so committed rows never collide
/// with other test files that reuse the helper's counter-based identities.
void main() {
  withServerpod(
    'Given LedgerEndpoint under concurrent requests',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late TestSessionBuilder owner;
      late Budget budget;
      late Map<String, LedgerAccount> accounts;

      String randomUserId() {
        final random = Random.secure();
        final hex = List.generate(
          12,
          (_) => random.nextInt(16).toRadixString(16),
        ).join();
        return '20000000-0000-4000-a000-$hex';
      }

      JournalLineInput line(
        LedgerAccount account, {
        required bool isDebit,
        required int amountMinor,
      }) => JournalLineInput(
        ledgerAccountId: account.id!,
        debitMinor: isDebit ? amountMinor : 0,
        creditMinor: isDebit ? 0 : amountMinor,
        currencyCode: 'GBP',
        functionalDebitMinor: isDebit ? amountMinor : 0,
        functionalCreditMinor: isDebit ? 0 : amountMinor,
        exchangeRate: '1',
        rateDate: DateTime(2026, 11),
        rateSource: 'manual',
      );

      Future<Journal> saveDraft() => endpoints.ledger.saveDraftJournal(
        owner,
        budget.id!,
        DateTime(2026, 11),
        [
          line(accounts['1000']!, isDebit: true, amountMinor: 50000),
          line(accounts['3200']!, isDebit: false, amountMinor: 50000),
        ],
        reference: 'JB-race',
        source: 'opening',
      );

      /// Settles every future and returns how many completed and how many
      /// failed with a [ValidationException].
      Future<({int succeeded, int rejected})> race(
        List<Future<Journal>> attempts,
      ) async {
        var succeeded = 0;
        var rejected = 0;
        await Future.wait([
          for (final attempt in attempts)
            () async {
              try {
                await attempt;
                succeeded++;
              } on ValidationException {
                rejected++;
              }
            }(),
        ]);
        return (succeeded: succeeded, rejected: rejected);
      }

      setUp(() async {
        owner = createAuthenticatedSession(
          sessionBuilder,
          userIdentifier: randomUserId(),
        );
        budget = await endpoints.budget.create(owner, 'Books', 'GBP');
        await endpoints.tax.saveProfile(
          owner,
          budget.id!,
          'GB',
          EntityKind.company.name,
          jsonEncode(
            const GbTaxProfile(entityKind: EntityKind.company).toJson(),
          ),
        );
        await endpoints.ledger.enableLedger(owner, budget.id!);
        final listed = await endpoints.ledger.listAccounts(
          owner,
          budget.id!,
          includeArchived: false,
        );
        accounts = {for (final account in listed) account.code: account};
      });

      test('then concurrent posts of one draft post it once', () async {
        final draft = await saveDraft();

        final outcome = await race([
          for (var i = 0; i < 4; i++)
            endpoints.ledger.postJournal(owner, draft.id!),
        ]);

        expect(outcome, (succeeded: 1, rejected: 3));
        final journals = await endpoints.ledger.listJournals(
          owner,
          budget.id!,
        );
        expect(journals.single.status, 'posted');
      });

      test(
        'then concurrent reversals of one journal reverse it once',
        () async {
          final draft = await saveDraft();
          final journal = await endpoints.ledger.postJournal(owner, draft.id!);

          final outcome = await race([
            for (var i = 0; i < 4; i++)
              endpoints.ledger.reverseJournal(
                owner,
                journal.id!,
                DateTime(2026, 11, 20),
              ),
          ]);

          expect(outcome, (succeeded: 1, rejected: 3));
          final journals = await endpoints.ledger.listJournals(
            owner,
            budget.id!,
          );
          expect(journals, hasLength(2));
          final trialBalance = await endpoints.ledger.trialBalance(
            owner,
            budget.id!,
            DateTime(2026, 11, 30),
          );
          expect(trialBalance.totalDebitMinor, 100000);
          expect(trialBalance.totalCreditMinor, 100000);
        },
      );
    },
  );
}
