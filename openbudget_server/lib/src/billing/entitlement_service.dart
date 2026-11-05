import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Reads and records OpenBudget Plus subscriptions.
///
/// Payment rails (Stripe, RevenueCat, Solana) call [record] when their
/// webhooks or collectors learn about a change. Features that need a paid
/// plan call [activeFor] or [requireActive].
abstract final class EntitlementService {
  /// Statuses that still grant access until the period ends.
  static const Set<EntitlementStatus> _grantingStatuses = {
    EntitlementStatus.active,
    EntitlementStatus.pastDue,
    EntitlementStatus.canceled,
  };

  /// Returns the entitlement that grants access at [now], or null.
  ///
  /// When several rails grant access, the one whose period ends last wins.
  static Future<Entitlement?> activeFor(
    Session session,
    UuidValue userId, {
    DateTime? now,
  }) async {
    final at = (now ?? DateTime.now()).toUtc();
    final rows = await Entitlement.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          t.status.inSet(_grantingStatuses) &
          (t.currentPeriodEnd > at),
      orderBy: (t) => t.currentPeriodEnd.desc(),
      limit: 1,
    );
    return rows.firstOrNull;
  }

  static UuidValue _requireUserId(Session session) {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) throw AuthenticationRequiredException();
    return UuidValue.fromString(userIdentifier);
  }

  /// Returns the signed-in user's granting entitlement, or null.
  static Future<Entitlement?> activeForCurrentUser(Session session) =>
      activeFor(session, _requireUserId(session));

  /// Returns the granting entitlement for [userId] or throws
  /// [EntitlementRequiredException].
  static Future<Entitlement> requireActive(
    Session session,
    UuidValue userId, {
    DateTime? now,
  }) async {
    final entitlement = await activeFor(session, userId, now: now);
    if (entitlement == null) throw EntitlementRequiredException();
    return entitlement;
  }

  /// Creates or updates the row for one rail subscription.
  ///
  /// Idempotent: replaying the same webhook writes the same values.
  static Future<Entitlement> record(
    Session session, {
    required UuidValue userId,
    required EntitlementSource source,
    required String externalId,
    required EntitlementStatus status,
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
  }) async {
    if (externalId.isEmpty) {
      throw ValidationException(message: 'externalId must not be empty');
    }
    if (!currentPeriodEnd.isAfter(currentPeriodStart)) {
      throw ValidationException(
        message: 'currentPeriodEnd must follow the start',
      );
    }
    return session.db.transaction((transaction) async {
      final existing = await Entitlement.db.findFirstRow(
        session,
        where: (t) => t.source.equals(source) & t.externalId.equals(externalId),
        transaction: transaction,
      );
      final now = DateTime.now().toUtc();
      if (existing == null) {
        return Entitlement.db.insertRow(
          session,
          Entitlement(
            userId: userId,
            source: source,
            externalId: externalId,
            status: status,
            currentPeriodStart: currentPeriodStart.toUtc(),
            currentPeriodEnd: currentPeriodEnd.toUtc(),
            createdAt: now,
            updatedAt: now,
          ),
          transaction: transaction,
        );
      }
      if (existing.userId != userId) {
        throw ForbiddenException(
          message: 'This subscription belongs to a different user',
        );
      }
      return Entitlement.db.updateRow(
        session,
        existing.copyWith(
          status: status,
          currentPeriodStart: currentPeriodStart.toUtc(),
          currentPeriodEnd: currentPeriodEnd.toUtc(),
          updatedAt: now,
        ),
        transaction: transaction,
      );
    });
  }
}
