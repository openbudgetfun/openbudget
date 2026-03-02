import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/institutions/institution_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given InstitutionEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test(
      'when listing catalog then seeded institutions are returned',
      () async {
        final institutions = await endpoints.institution.list(authedSession);

        expect(institutions.length, greaterThanOrEqualTo(100));
        expect(
          institutions.any(
            (institution) => institution.name.toLowerCase() == 'jpmorgan chase',
          ),
          isTrue,
        );
        expect(
          institutions.any((institution) => institution.isDigitalBank),
          isTrue,
        );
      },
    );

    test(
      'when listing with GB location then popular GB institutions are prioritized',
      () async {
        final gbInstitutions = await endpoints.institution.list(
          authedSession,
          locationCode: 'GB',
        );
        final usInstitutions = await endpoints.institution.list(
          authedSession,
          locationCode: 'US',
        );

        final gbTopTen = gbInstitutions.take(10).toList();
        final gbTopTenIds = gbTopTen
            .map((institution) => institution.id)
            .toList();
        final usTopTenIds = usInstitutions
            .take(10)
            .map((institution) => institution.id)
            .toList();

        expect(gbTopTen.isNotEmpty, isTrue);
        expect(
          gbTopTen.any((institution) => institution.isDigitalBank),
          isTrue,
        );
        expect(gbTopTenIds, isNot(equals(usTopTenIds)));
      },
    );

    test(
      'when catalog is seeded then institutions can belong to multiple regions',
      () async {
        final session = authedSession.build();
        try {
          await InstitutionService.ensureCatalogSeeded(session);

          final locations = await InstitutionLocation.db.find(session);
          final codesByInstitutionId = <String, Set<String>>{};
          for (final location in locations) {
            final institutionId = location.institutionId.toString();
            codesByInstitutionId
                .putIfAbsent(institutionId, () => <String>{})
                .add(location.locationCode);
          }

          final multiRegionInstitutionId = codesByInstitutionId.entries
              .firstWhere(
                (entry) => entry.value.length >= 2,
                orElse: () => throw StateError(
                  'Expected at least one institution in multiple regions.',
                ),
              )
              .key;

          final institution = await Institution.db.findFirstRow(
            session,
            where: (t) =>
                t.id.equals(UuidValue.fromString(multiRegionInstitutionId)),
          );
          final regions = codesByInstitutionId[multiRegionInstitutionId]!;

          expect(institution, isNotNull);
          expect(regions.length, greaterThanOrEqualTo(2));
        } finally {
          await session.close();
        }
      },
    );
  });
}
