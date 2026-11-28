import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/plaid/plaid_service.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:serverpod_auth_idp_server/core.dart';

/// Permanently deletes the signed-in user and everything they own.
///
/// App Store guideline 5.1.1(v) and Google Play's account deletion policy
/// both require that someone who can create an account can also delete it
/// from inside the app. Deletion removes:
///
/// - every entity the user owns, its transactions and journals first, then
///   the entity's cascade removes its accounts, plan, envelopes, tax
///   profiles, bank and wallet links;
/// - the auth user, which cascades to sign-in methods, sessions, settings,
///   Money guide conversations, access tokens and billing rows.
///
/// A subscription that still renews blocks deletion, because the payment rail
/// (Stripe, the App Store, Google Play or a Solana subscription) would keep
/// charging someone whose account no longer exists. The person cancels first;
/// a cancelled plan that runs to the end of its period does not block.
abstract final class AccountDeletionService {
  static final _log = ObLogger('AccountDeletionService');

  /// The statuses whose subscription will charge again.
  static const Set<EntitlementStatus> renewingStatuses = {
    EntitlementStatus.active,
    EntitlementStatus.pastDue,
  };

  /// The message shown when a renewing subscription blocks deletion.
  static const renewingSubscriptionMessage =
      'Cancel your OpenBudget Plus subscription before deleting your account.';

  /// Deletes the caller's account and all of their data.
  static Future<void> deleteCurrentUser(Session session) async {
    final userId = EntityAccess.userId(session);
    late final Set<UuidValue> entityIds;
    late final List<String> plaidTokens;

    // The subscription check and the deletes share one transaction, so a
    // subscription that starts renewing cannot slip in between them. The
    // Plaid tokens are read while the rows still exist; the revoke calls run
    // only after the commit, so a rolled-back delete never breaks a link.
    await session.db.transaction((tx) async {
      final renewing = await Entitlement.db.count(
        session,
        where: (t) =>
            t.userId.equals(userId) & t.status.inSet(renewingStatuses),
        transaction: tx,
      );
      if (renewing > 0) {
        throw ValidationException(message: renewingSubscriptionMessage);
      }

      final entities = await Entity.db.find(
        session,
        where: (t) => t.ownerId.equals(userId),
        transaction: tx,
      );
      entityIds = {for (final entity in entities) entity.id!};

      if (entityIds.isEmpty) {
        plaidTokens = const [];
      } else {
        final connections = await PlaidConnection.db.find(
          session,
          where: (t) => t.entityId.inSet(entityIds),
          transaction: tx,
        );
        plaidTokens = await PlaidService.collectAccessTokens(
          session,
          connections,
        );

        // Envelope and ledger lines reference their parent rows without a
        // cascade, so the movements go before the entities do; deleting a
        // transaction or journal cascades its own lines.
        await Transaction.db.deleteWhere(
          session,
          where: (t) => t.entityId.inSet(entityIds),
          transaction: tx,
        );
        await Journal.db.deleteWhere(
          session,
          where: (t) => t.entityId.inSet(entityIds),
          transaction: tx,
        );

        await Entity.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(userId),
          transaction: tx,
        );
      }

      await const AuthUsers().delete(
        session,
        authUserId: userId,
        transaction: tx,
      );
    });

    await PlaidService.removeItems(session, plaidTokens);

    _log.info('deleted account entities=${entityIds.length}');

    for (final entityId in entityIds) {
      await EntityRealtimeNotifier.notify(
        session,
        entityId,
        ChangeScope.entity,
      );
    }
    await session.messages.authenticationRevoked(
      userId.toString(),
      RevokedAuthenticationUser(),
    );
  }
}
