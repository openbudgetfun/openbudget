import 'package:openbudget_server/src/common/currency_validation.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// Preferences shared by the owner's entities.
abstract final class UserSettingsService {
  /// Lazily creates preferences under an owner advisory lock.
  static Future<UserSettings> get(
    Session session, {
    Transaction? transaction,
  }) async {
    if (transaction == null) {
      return session.db.transaction((tx) => get(session, transaction: tx));
    }
    final userId = EntityAccess.userId(session);
    // Serialize lazy creation across requests without requiring an entity.
    await session.db.unsafeQuery(
      'SELECT pg_advisory_xact_lock(hashtextextended(@owner, 0))',
      parameters: QueryParameters.named({'owner': userId.toString()}),
      transaction: transaction,
    );
    final existing = await UserSettings.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
      transaction: transaction,
    );
    if (existing != null) return existing;
    final first = await Entity.db.findFirstRow(
      session,
      where: (t) => t.ownerId.equals(userId),
      orderBy: (t) => t.createdAt,
      transaction: transaction,
    );
    return UserSettings.db.insertRow(
      session,
      UserSettings(
        userId: userId,
        reportingCurrencyCode: first?.baseCurrencyCode ?? 'USD',
      ),
      transaction: transaction,
    );
  }

  /// Changes the combined reporting currency.
  static Future<UserSettings> setReportingCurrency(
    Session session,
    String currencyCode,
  ) async {
    final code = requireSupportedCurrency(currencyCode);
    return session.db.transaction((tx) async {
      final settings = await get(session, transaction: tx);
      return UserSettings.db.updateRow(
        session,
        settings.copyWith(
          reportingCurrencyCode: code,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: tx,
      );
    });
  }
}
