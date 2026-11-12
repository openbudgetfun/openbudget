import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'institution_catalog_provider.g.dart';

@riverpod
Future<List<Institution>> institutionCatalog(
  Ref ref,
  String locationCode,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.institution.list(locationCode: locationCode);
}
