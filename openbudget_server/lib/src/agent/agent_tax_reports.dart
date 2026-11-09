import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/tax/tax_entry_builder.dart';
import 'package:openbudget_server/src/tax/tax_fx_rates.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// Reads a budget's tax position for the assistant's tools.
///
/// The endpoint tax service checks `session.authenticated` while it loads the
/// budget. The agent's tools instead receive the owner explicitly, so this
/// class assembles the same report from the public tax building blocks. The
/// rules, the FX conversion and the fixtures all come from the existing tax
/// code; only the ownership check lives at the tool boundary.
abstract final class AgentTaxReports {
  static const _conversionAssumption =
      'Amounts in other currencies were converted at the exchange rate on '
      'each transaction date.';

  /// Computes the report for [budgetId] using the same rules as the endpoint.
  static Future<TaxReportView> report(
    Session session, {
    required UuidValue budgetId,
    int? startYear,
  }) async {
    final budget = await Budget.db.findById(session, budgetId);
    if (budget == null) throw NotFoundException(message: 'Budget not found');

    final record = await TaxProfileRecord.db.findFirstRow(
      session,
      where: (t) => t.budgetId.equals(budgetId),
    );
    if (record == null) {
      throw NotFoundException(message: 'Tax profile not found for this budget');
    }

    final jurisdiction = _jurisdiction(record.jurisdiction);
    final pack = TaxRules.forJurisdiction(jurisdiction);
    final TaxYear year;
    try {
      year = startYear == null
          ? pack.taxYearFor(DateTime.now().toUtc())
          : pack.taxYear(startYear);
    } on UnsupportedTaxYearException catch (error) {
      throw TaxRulesUnavailableException(message: error.toString());
    }

    final profile = _profileForRecord(record);
    final rates = await _loadRates(session);
    final built = await _buildInput(
      session,
      budget: budget,
      record: record,
      profile: profile,
      year: year,
      rates: rates,
    );

    final TaxReport report;
    try {
      report = pack.report(built.input);
    } on UnsupportedTaxYearException catch (error) {
      throw TaxRulesUnavailableException(message: error.toString());
    }
    final opportunities = pack.opportunities(built.input, report);

    return TaxReportView(
      jurisdiction: report.year.jurisdiction.countryCode,
      startYear: report.year.startYear,
      yearLabel: report.year.label,
      yearStart: report.year.start,
      yearEnd: report.year.end,
      entityKind: report.entityKind.name,
      currencyCode: report.currencyCode,
      lines: [
        for (final line in report.lines)
          TaxReportLineView(
            label: line.label,
            amountMinor: line.amountMinor,
            code: line.code,
            reportReference: line.reportReference,
            entryCount: line.entryCount,
          ),
      ],
      liabilities: [
        for (final liability in report.liabilities)
          TaxLiabilityView(
            label: liability.label,
            amountMinor: liability.amountMinor,
            bands: [
              for (final band in liability.bands)
                TaxBandSliceView(
                  label: band.label,
                  baseMinor: band.baseMinor,
                  rateBasisPoints: band.rateBasisPoints,
                  taxMinor: band.taxMinor,
                ),
            ],
          ),
      ],
      totalLiabilityMinor: report.totalLiabilityMinor,
      alreadyPaidMinor: report.alreadyPaidMinor,
      balanceDueMinor: report.balanceDueMinor,
      assumptions: [
        ...report.assumptions,
        if (built.convertedCount > 0) _conversionAssumption,
      ],
      sources: [for (final source in report.sources) source.toString()],
      rulesVerifiedOn: report.rulesVerifiedOn,
      uncategorizedCount: report.uncategorizedCount + built.uncategorizedCount,
      convertedEntryCount: built.convertedCount,
      opportunities: [
        for (final opportunity in opportunities)
          TaxOpportunityView(
            id: opportunity.id,
            title: opportunity.title,
            explanation: opportunity.explanation,
            estimatedSavingMinor: opportunity.estimatedSavingMinor,
            deadline: opportunity.deadline,
            source: opportunity.source.toString(),
          ),
      ],
    );
  }

  /// Lists the categories the budget's entity kind may use.
  static Future<List<TaxCategoryView>> categories(
    Session session, {
    required UuidValue budgetId,
  }) async {
    final record = await TaxProfileRecord.db.findFirstRow(
      session,
      where: (t) => t.budgetId.equals(budgetId),
    );
    if (record == null) {
      throw NotFoundException(message: 'Tax profile not found for this budget');
    }
    final kind = _entityKind(record.entityKind);
    final pack = TaxRules.forJurisdiction(
      _jurisdiction(record.jurisdiction),
    );

    return [
      for (final category in pack.categoriesFor(kind))
        TaxCategoryView(
          code: category.code,
          label: category.label,
          kind: category.kind.name,
          reportReference: category.reportReference,
          description: category.description,
        ),
    ];
  }

  static TaxJurisdiction _jurisdiction(String value) {
    final jurisdiction = TaxJurisdiction.fromCountryCode(value);
    if (jurisdiction == null) {
      throw ValidationException(
        message: 'Unsupported tax jurisdiction "$value".',
      );
    }
    return jurisdiction;
  }

  static EntityKind _entityKind(String value) {
    for (final kind in EntityKind.values) {
      if (kind.name == value) return kind;
    }
    throw ValidationException(message: 'Unsupported tax entity kind "$value".');
  }

  static TaxProfile _profileForRecord(TaxProfileRecord record) {
    final Object? decoded;
    try {
      decoded = jsonDecode(record.profileJson);
    } on FormatException {
      throw ValidationException(
        message: 'The stored tax profile is not valid JSON.',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw ValidationException(
        message: 'The stored tax profile is not an object.',
      );
    }
    final profile = TaxProfile.fromJson(decoded);
    if (profile.jurisdiction.countryCode != record.jurisdiction ||
        profile.entityKind.name != record.entityKind) {
      throw ValidationException(
        message:
            'The stored tax profile does not match its jurisdiction and entity '
            'kind.',
      );
    }
    return profile;
  }

  static Future<TaxFxRates> _loadRates(Session session) async {
    final snapshots = await FxRateSnapshot.db.find(
      session,
      orderBy: (t) => t.fetchedAt,
    );
    final snapshotIds = {
      for (final snapshot in snapshots)
        if (snapshot.id != null) snapshot.id!,
    };
    final rateEntries = snapshotIds.isEmpty
        ? <FxRateEntry>[]
        : await FxRateEntry.db.find(
            session,
            where: (t) => t.snapshotId.inSet(snapshotIds),
          );

    final ratesBySnapshot = <UuidValue, Map<String, double>>{};
    for (final entry in rateEntries) {
      (ratesBySnapshot[entry.snapshotId] ??= {})[entry.currencyCode] =
          entry.rate;
    }

    return TaxFxRates([
      for (final snapshot in snapshots)
        TaxFxSnapshotRates(
          baseCurrencyCode: snapshot.baseCurrencyCode,
          fetchedAt: snapshot.fetchedAt,
          rates: ratesBySnapshot[snapshot.id] ?? const {},
        ),
    ]);
  }

  static Future<_BuiltTaxInput> _buildInput(
    Session session, {
    required Budget budget,
    required TaxProfileRecord record,
    required TaxProfile profile,
    required TaxYear year,
    required TaxFxRates rates,
  }) async {
    final result = await _entriesForBudget(
      session,
      budgetId: budget.id!,
      year: year,
      rates: rates,
    );
    final linked = await _linkedInputs(
      session,
      budget: budget,
      record: record,
      year: year,
      rates: rates,
    );

    return _BuiltTaxInput(
      input: TaxInput(
        profile: profile,
        year: year,
        entries: result.entries,
        linked: [for (final linkedInput in linked) linkedInput.input],
      ),
      uncategorizedCount:
          result.uncategorizedCount +
          linked.fold(0, (sum, input) => sum + input.uncategorizedCount),
      convertedCount:
          result.convertedCount +
          linked.fold(0, (sum, input) => sum + input.convertedCount),
    );
  }

  static Future<TaxEntryBuildResult> _entriesForBudget(
    Session session, {
    required UuidValue budgetId,
    required TaxYear year,
    required TaxFxRates rates,
  }) async {
    final transactions = await Transaction.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
    );

    return buildTaxEntries(
      transactions: transactions,
      envelopesById: await _envelopesForBudget(session, budgetId: budgetId),
      year: year,
      rates: rates,
      targetCurrencyCode: year.jurisdiction.currencyCode,
    );
  }

  static Future<Map<UuidValue, Envelope>> _envelopesForBudget(
    Session session, {
    required UuidValue budgetId,
  }) async {
    final categories = await Category.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
    );
    final categoryIds = {
      for (final category in categories)
        if (category.id != null) category.id!,
    };
    if (categoryIds.isEmpty) return {};

    final envelopes = await Envelope.db.find(
      session,
      where: (t) => t.categoryId.inSet(categoryIds),
    );
    return {
      for (final envelope in envelopes)
        if (envelope.id != null) envelope.id!: envelope,
    };
  }

  static Future<List<_BuiltTaxInput>> _linkedInputs(
    Session session, {
    required Budget budget,
    required TaxProfileRecord record,
    required TaxYear year,
    required TaxFxRates rates,
  }) async {
    final kind = _entityKind(record.entityKind);
    final linkedBudgetId = record.linkedBudgetId;
    final candidates = <TaxProfileRecord>[];

    if (kind == EntityKind.individual) {
      final soleTraders = await TaxProfileRecord.db.find(
        session,
        where: (t) =>
            t.linkedBudgetId.equals(budget.id) &
            t.entityKind.equals(EntityKind.soleTrader.name) &
            t.jurisdiction.equals(record.jurisdiction),
      );
      for (final candidate in soleTraders) {
        final linkedBudget = await Budget.db.findById(
          session,
          candidate.budgetId,
        );
        if (linkedBudget == null || linkedBudget.ownerId != budget.ownerId) {
          continue;
        }
        candidates.add(candidate);
      }
    } else if (kind == EntityKind.company && linkedBudgetId != null) {
      final linkedProfile = await TaxProfileRecord.db.findFirstRow(
        session,
        where: (t) => t.budgetId.equals(linkedBudgetId),
      );
      if (linkedProfile != null &&
          linkedProfile.entityKind == EntityKind.individual.name &&
          linkedProfile.jurisdiction == record.jurisdiction) {
        candidates.add(linkedProfile);
      }
    }

    final inputs = <_BuiltTaxInput>[];
    for (final candidate in candidates) {
      final result = await _entriesForBudget(
        session,
        budgetId: candidate.budgetId,
        year: year,
        rates: rates,
      );
      inputs.add(
        _BuiltTaxInput(
          input: TaxInput(
            profile: _profileForRecord(candidate),
            year: year,
            entries: result.entries,
          ),
          uncategorizedCount: result.uncategorizedCount,
          convertedCount: result.convertedCount,
        ),
      );
    }
    return inputs;
  }
}

/// One tax input plus the counts the report view needs from it.
class _BuiltTaxInput {
  const _BuiltTaxInput({
    required this.input,
    required this.uncategorizedCount,
    required this.convertedCount,
  });

  final TaxInput input;
  final int uncategorizedCount;
  final int convertedCount;
}
