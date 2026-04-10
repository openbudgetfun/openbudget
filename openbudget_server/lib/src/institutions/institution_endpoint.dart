import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/institutions/institution_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for institution catalog discovery.
class InstitutionEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the seeded institution catalog sorted for a user's location.
  Future<List<Institution>> list(
    Session session, {
    String? locationCode,
  }) async => InstitutionService.listCatalog(session, locationCode: locationCode);
}
