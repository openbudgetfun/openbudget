import 'package:openbudget_server/src/accounts/account_balance_service.dart';
import 'package:openbudget_server/src/generated/future_calls.dart';
import 'package:serverpod/serverpod.dart';

/// Repairs and audits cached balance drift daily at 03:00 UTC.
class BalanceVerifyFutureCall extends FutureCall {
  /// Uses the next UTC boundary rather than accumulating a 24-hour delay.
  static DateTime nextRun(DateTime now) {
    final utc = now.toUtc();
    final today = DateTime.utc(utc.year, utc.month, utc.day, 3);
    return today.isAfter(utc) ? today : today.add(const Duration(days: 1));
  }

  /// Repairs drift and schedules tomorrow even if verification fails.
  Future<void> verify(Session session) async {
    try {
      await AccountBalanceService.verify(session);
    } finally {
      await session.serverpod.futureCalls
          .callAtTime(
            nextRun(DateTime.now()),
            identifier: 'balance-verify-nightly',
          )
          .balanceVerify
          .verify();
    }
  }
}
