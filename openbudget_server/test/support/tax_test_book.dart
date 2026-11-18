import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';

/// A GB profile JSON payload for [kind], before the entity rewrites identity.
String gbProfileJson(
  EntityKind kind, {
  bool salesTaxRegistered = false,
  bool scottishTaxpayer = false,
  int associatedCompanies = 0,
}) => jsonEncode(
  GbTaxProfile(
    entityKind: kind,
    salesTaxRegistered: salesTaxRegistered,
    scottishTaxpayer: scottishTaxpayer,
    associatedCompanies: associatedCompanies,
  ).toJson(),
);

/// Saves a profile whose parameters agree with [entity] by default.
Future<TaxProfileRecord> saveTaxProfile(
  Session session,
  Entity entity, {
  String? profileJson,
  String? jurisdiction,
  String? entityKind,
}) => TaxService.saveProfile(
  session,
  entityId: entity.id!,
  jurisdiction: jurisdiction ?? entity.countryCode,
  entityKind: entityKind ?? entity.kind.name,
  profileJson: profileJson ?? gbProfileJson(entity.kind),
);

/// Creates one transaction through the writer with a manual market rate.
Future<TransactionView> createTaxTransaction(
  Session session,
  Account account, {
  DateTime? date,
  int amountMinor = -10000,
  List<TransactionLineInput> lines = const [],
  String description = 'Transaction',
  String? fxRate,
}) => TransactionWriter.create(
  session,
  TransactionInput(
    accountId: account.id!,
    date: date ?? DateTime.utc(2026, 6, 15),
    amountMinor: amountMinor,
    fxRate: fxRate,
    description: description,
    lines: lines,
  ),
);

/// The single line view of [view].
TransactionLine taxLine(TransactionView view) {
  if (view.lines.length != 1) {
    throw StateError('Expected one line, found ${view.lines.length}');
  }
  return view.lines.single;
}
