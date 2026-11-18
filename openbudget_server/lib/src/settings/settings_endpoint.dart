import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/settings/account_deletion_service.dart';
import 'package:openbudget_server/src/settings/user_settings_service.dart';
import 'package:serverpod/serverpod.dart';

/// User preferences independent of the selected entity.
class SettingsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Loads or creates the caller's settings.
  Future<UserSettings> get(Session session) => UserSettingsService.get(session);

  /// Sets a supported ISO reporting currency.
  Future<UserSettings> setReportingCurrency(
    Session session,
    String currencyCode,
  ) => UserSettingsService.setReportingCurrency(session, currencyCode);

  /// Permanently deletes the caller's account and every entity they own.
  ///
  /// Throws [ValidationException] while a subscription still renews.
  Future<void> deleteAccount(Session session) =>
      AccountDeletionService.deleteCurrentUser(session);
}
