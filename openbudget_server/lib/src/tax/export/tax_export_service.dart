import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/export/tax_export_token.dart';
import 'package:openbudget_server/src/tax/export/tax_export_zip.dart';
import 'package:openbudget_server/src/tax/tax_summary_service.dart';
import 'package:serverpod/serverpod.dart';

/// One built export download: the ZIP bytes and the name the browser saves.
final class TaxExportDownload {
  const TaxExportDownload({required this.bytes, required this.filename});

  final Uint8List bytes;

  /// `openbudget-tax-<startYear>.zip`.
  final String filename;
}

/// Creates and serves the signed tax summary export downloads
/// (docs/tax-jurisdictions.md, section 8.7).
///
/// A link is an HMAC-signed token over the owner's user id, the entity id,
/// the year and an expiry, so the URL carries no name, email or entity
/// name, needs no table, and dies on its own after ten minutes. The
/// download re-checks the entity's stored owner before building anything,
/// so a token stops working the moment the entity no longer belongs to the
/// user it was signed for.
class TaxExportService {
  static final _log = ObLogger('TaxExportService');

  /// The password the signing key is derived from.
  static const _serviceSecretKey = 'serviceSecret';

  /// The server clock used for the link expiry.
  @visibleForTesting
  static DateTime Function() clock = () => DateTime.now().toUtc();

  /// Builds the entity's summary for the year that starts in [startYear].
  static Future<String> createExportLink(
    Session session, {
    required UuidValue entityId,
    int? startYear,
  }) async {
    final entity = await EntityAccess.requireOwned(session, entityId);
    final year =
        startYear ??
        await TaxSummaryService.defaultStartYear(session, entityId);
    final key = _signingKey(session);
    final token = TaxExportToken.mint(
      signingKey: key,
      payload: TaxExportTokenPayload(
        userId: entity.ownerId,
        entityId: entity.id!,
        startYear: year,
        expiresAt: clock().add(taxExportLinkTtl),
      ),
    );
    return _downloadUrl(session, token);
  }

  /// Builds the download a [token] asks for, or null when the token or the
  /// books behind it do not pass every check.
  ///
  /// Signature, expiry, and the entity's current owner are all verified
  /// here; every rejection answers null so the caller can send one
  /// undistinguished failure with no detail leak.
  static Future<TaxExportDownload?> buildDownload(
    Session session, {
    required String token,
  }) async {
    final key = _signingKeyOrLog(session);
    if (key == null) return null;

    final payload = TaxExportToken.verify(
      token: token,
      signingKey: key,
      now: clock(),
    );
    if (payload == null) {
      _log.warning('Rejected an invalid or expired tax export token');
      return null;
    }

    try {
      final owner = await EntityAccess.systemOwnerFor(
        session,
        payload.entityId,
      );
      if (owner.ownerId != payload.userId) {
        _log.warning(
          'Rejected a tax export token for an entity that changed owner',
        );
        return null;
      }

      final computation = await TaxSummaryService.buildForExport(
        session,
        entityId: payload.entityId,
        startYear: payload.startYear,
        systemOwner: owner,
      );
      return TaxExportDownload(
        bytes: TaxExportZip.build(computation),
        filename: 'openbudget-tax-${computation.view.startYear}.zip',
      );
    } on Exception catch (error) {
      // The books refused the build: the entity is gone, a rate is missing
      // or the year is unsupported. The caller still gets a plain refusal,
      // and the reason stays in the server log.
      _log.warning('Refused a tax export download: $error');
      return null;
    }
  }

  /// Derives the signing key, failing loudly when the secret is missing:
  /// a link signed with a fallback would be a link anyone can forge.
  static Uint8List _signingKey(Session session) {
    final secret = session.passwords[_serviceSecretKey]?.trim() ?? '';
    if (secret.isEmpty) {
      throw ValidationException(
        message:
            '$_serviceSecretKey is not configured, so no tax export link '
            'can be signed.',
      );
    }
    return TaxExportSigningKey.derive(secret);
  }

  /// The same derivation for the download path, where a missing secret is
  /// a server fault that must answer a refusal instead of an exception
  /// with configuration detail in it.
  static Uint8List? _signingKeyOrLog(Session session) {
    final secret = session.passwords[_serviceSecretKey]?.trim() ?? '';
    if (secret.isEmpty) {
      _log.severe(
        'Cannot serve a tax export: $_serviceSecretKey is not configured',
      );
      return null;
    }
    return TaxExportSigningKey.derive(secret);
  }

  /// The absolute URL the app opens with `url_launcher`, pointing at the
  /// Relic route with the token where a filename would sit.
  static String _downloadUrl(Session session, String token) {
    final web = session.server.serverpod.config.webServer;
    if (web == null) {
      throw ValidationException(
        message:
            'The web server is not configured, so no tax export link '
            'can be created.',
      );
    }
    final base = Uri(
      scheme: web.publicScheme,
      host: web.publicHost,
      port: web.publicPort,
    );
    return base.replace(path: '/tax/export/$token.zip').toString();
  }
}
