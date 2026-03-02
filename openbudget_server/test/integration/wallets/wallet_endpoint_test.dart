import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given WalletEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test(
      'when connecting invalid address then throws ValidationException',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Wallet Budget',
          'USD',
        );

        await expectLater(
          endpoints.wallet.connectSolanaWallet(
            authedSession,
            budget.id!,
            'not-a-solana-address',
            onBudget: false,
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'when refreshing unknown connection then throws NotFoundException',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Refresh Budget',
          'USD',
        );

        await expectLater(
          endpoints.wallet.refreshSolanaWallet(
            authedSession,
            budget.id!,
            UuidValue.fromString('30000000-0000-4000-a000-000000000001'),
          ),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test(
      'when listing holdings then returns sorted persisted wallet holdings',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Holdings Budget',
          'USD',
        );

        final session = authedSession.build();
        try {
          final connection = await WalletConnection.db.insertRow(
            session,
            WalletConnection(
              budgetId: budget.id!,
              chain: 'solana',
              address: '4Nd1mB8Y6nA2U8k9d7f5m3q1w9x8z7y6t5r4e3w2q1aB',
              label: 'Primary Wallet',
            ),
          );
          final connectionId = connection.id!;

          await WalletHolding.db.insertRow(
            session,
            WalletHolding(
              walletConnectionId: connectionId,
              chain: 'solana',
              assetId: 'z-token',
              symbol: 'ZZZ',
              decimals: 6,
              quantityBaseUnits: '1000000',
              quantityDisplay: 1,
            ),
          );
          await WalletHolding.db.insertRow(
            session,
            WalletHolding(
              walletConnectionId: connectionId,
              chain: 'solana',
              assetId: 'a-token',
              symbol: 'AAA',
              decimals: 6,
              quantityBaseUnits: '2500000',
              quantityDisplay: 2.5,
            ),
          );

          final holdings = await endpoints.wallet.listWalletHoldings(
            authedSession,
            budget.id!,
            connectionId,
          );
          expect(holdings, hasLength(2));
          expect(holdings.first.symbol, 'AAA');
          expect(holdings.last.symbol, 'ZZZ');
        } finally {
          await session.close();
        }
      },
    );

    test(
      "when listing another user's wallet holdings then throws NotFoundException",
      () async {
        final ownerBudget = await endpoints.budget.create(
          authedSession,
          'Owner Wallet Budget',
          'USD',
        );
        final ownerSession = authedSession.build();
        try {
          final connection = await WalletConnection.db.insertRow(
            ownerSession,
            WalletConnection(
              budgetId: ownerBudget.id!,
              chain: 'solana',
              address: '7f3Vw1q2p4n6m8k9j2h4g6d8s1a3z5x7c9v1b2n4m6pQ',
            ),
          );
          final otherUserSession = createAuthenticatedSession(sessionBuilder);

          await expectLater(
            endpoints.wallet.listWalletHoldings(
              otherUserSession,
              ownerBudget.id!,
              connection.id!,
            ),
            throwsA(isA<NotFoundException>()),
          );
        } finally {
          await ownerSession.close();
        }
      },
    );
  });
}
