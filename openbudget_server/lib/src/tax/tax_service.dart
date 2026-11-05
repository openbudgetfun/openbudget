import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/categories/category_service.dart';
import 'package:openbudget_server/src/envelopes/envelope_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/tax/tax_entry_builder.dart';
import 'package:openbudget_server/src/tax/tax_fx_rates.dart';
import 'package:openbudget_server/src/transactions/transaction_service.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// One tax input plus the bookkeeping the report view needs from it.
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

/// Business logic for tax profiles, categorisation, and reports.
///
/// Every method verifies that the authenticated user owns the budget whose
/// data it reads or writes. The computation itself belongs to the pure rule
/// packs in `openbudget_core`; this service only assembles their input.
class TaxService {
  static final _log = ObLogger('TaxService');

  static const _conversionAssumption =
      'Amounts in other currencies were converted at the exchange rate on '
      'each transaction date.';

  /// Resolves the rule pack for a jurisdiction.
  ///
  /// Tests replace this with a fake pack; production uses [TaxRules].
  @visibleForTesting
  static TaxRulePack Function(TaxJurisdiction jurisdiction) packFor =
      TaxRules.forJurisdiction;

  /// Returns the budget's tax profile, or null when none is set.
  static Future<TaxProfileRecord?> getProfile(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);
    return TaxProfileRecord.db.findFirstRow(
      session,
      where: (t) => t.budgetId.equals(budgetId),
    );
  }

  /// Creates or replaces the budget's tax profile.
  ///
  /// [profileJson] is a [TaxProfile] payload and must agree with
  /// [jurisdiction] and [entityKind]. An individual cannot link another
  /// budget; a sole trader or company may link the personal budget its
  /// figures feed, which must be a different, owned budget that is either
  /// unprofiled or an individual in the same jurisdiction.
  static Future<TaxProfileRecord> saveProfile(
    Session session, {
    required UuidValue budgetId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
    UuidValue? linkedBudgetId,
  }) async {
    _log.info('Saving tax profile budget=$budgetId');
    await BudgetService.getById(session, budgetId: budgetId);

    final parsedJurisdiction = _parseJurisdiction(jurisdiction);
    final parsedKind = _parseEntityKind(entityKind);
    final profile = _decodeProfile(profileJson);

    if (profile.jurisdiction != parsedJurisdiction) {
      throw ValidationException(
        message:
            'profileJson is a ${profile.jurisdiction.countryCode} profile but '
            'the budget jurisdiction is ${parsedJurisdiction.countryCode}.',
      );
    }
    if (profile.entityKind != parsedKind) {
      throw ValidationException(
        message:
            'profileJson is for ${profile.entityKind.name} but the budget is '
            '${parsedKind.name}.',
      );
    }

    if (parsedKind == TaxEntityKind.individual) {
      if (linkedBudgetId != null) {
        throw ValidationException(
          message: 'An individual tax profile cannot link another budget.',
        );
      }
    } else if (linkedBudgetId != null) {
      if (linkedBudgetId == budgetId) {
        throw ValidationException(
          message: 'The linked budget must be different from this budget.',
        );
      }
      await BudgetService.getById(session, budgetId: linkedBudgetId);
      final linkedProfile = await TaxProfileRecord.db.findFirstRow(
        session,
        where: (t) => t.budgetId.equals(linkedBudgetId),
      );
      if (linkedProfile != null &&
          (linkedProfile.entityKind != TaxEntityKind.individual.name ||
              linkedProfile.jurisdiction != parsedJurisdiction.countryCode)) {
        throw ValidationException(
          message:
              'The linked budget must be an individual budget in the same '
              'jurisdiction.',
        );
      }
    }

    final storedJson = jsonEncode(profile.toJson());
    final now = DateTime.now();
    final existing = await TaxProfileRecord.db.findFirstRow(
      session,
      where: (t) => t.budgetId.equals(budgetId),
    );

    if (existing == null) {
      return TaxProfileRecord.db.insertRow(
        session,
        TaxProfileRecord(
          budgetId: budgetId,
          jurisdiction: parsedJurisdiction.countryCode,
          entityKind: parsedKind.name,
          profileJson: storedJson,
          linkedBudgetId: linkedBudgetId,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    return TaxProfileRecord.db.updateRow(
      session,
      existing.copyWith(
        jurisdiction: parsedJurisdiction.countryCode,
        entityKind: parsedKind.name,
        profileJson: storedJson,
        linkedBudgetId: linkedBudgetId,
        updatedAt: now,
      ),
    );
  }

  /// Lists the tax categories available to the budget's entity kind.
  static Future<List<TaxCategoryView>> listCategories(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);
    final record = await _requireProfile(session, budgetId: budgetId);
    final kind = _parseEntityKind(record.entityKind);
    final pack = _requirePack(_parseJurisdiction(record.jurisdiction));

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

  /// Sets or clears the default tax category on an envelope.
  static Future<Envelope> setEnvelopeTaxCategory(
    Session session, {
    required UuidValue envelopeId,
    String? code,
  }) async {
    final envelope = await EnvelopeService.getById(
      session,
      envelopeId: envelopeId,
    );
    final category = await CategoryService.getById(
      session,
      categoryId: envelope.categoryId,
    );
    final record = await _requireProfile(session, budgetId: category.budgetId);
    final kind = _parseEntityKind(record.entityKind);
    final pack = _requirePack(_parseJurisdiction(record.jurisdiction));
    _validateCategoryCode(pack, code, kind);

    return Envelope.db.updateRow(
      session,
      envelope.copyWith(taxCategoryCode: code),
    );
  }

  /// Sets or clears a transaction's tax treatment.
  ///
  /// Passing null for any argument clears that value, so a form can send its
  /// whole state at once.
  static Future<Transaction> setTransactionTax(
    Session session, {
    required UuidValue transactionId,
    String? code,
    int? businessUsePercent,
    int? salesTaxCents,
  }) async {
    final transaction = await TransactionService.getById(
      session,
      transactionId: transactionId,
    );
    final record = await _requireProfile(
      session,
      budgetId: transaction.budgetId,
    );
    final kind = _parseEntityKind(record.entityKind);
    final pack = _requirePack(_parseJurisdiction(record.jurisdiction));
    _validateCategoryCode(pack, code, kind);

    if (businessUsePercent != null &&
        (businessUsePercent < 0 || businessUsePercent > 100)) {
      throw ValidationException(
        message: 'businessUsePercent must be between 0 and 100.',
      );
    }

    final limit = transaction.amountCents.abs();
    if (salesTaxCents != null && (salesTaxCents < 0 || salesTaxCents > limit)) {
      throw ValidationException(
        message:
            'salesTaxCents must be between 0 and the transaction amount '
            '($limit).',
      );
    }

    return Transaction.db.updateRow(
      session,
      transaction.copyWith(
        taxCategoryCode: code,
        businessUsePercent: businessUsePercent,
        salesTaxCents: salesTaxCents,
      ),
    );
  }

  /// Computes the budget's tax report for the year that starts in [startYear].
  ///
  /// When [startYear] is null the tax year containing today is used. Entry
  /// amounts are converted to the jurisdiction's currency at each
  /// transaction's own date.
  static Future<TaxReportView> report(
    Session session, {
    required UuidValue budgetId,
    int? startYear,
  }) async {
    _log.info('Building tax report budget=$budgetId year=$startYear');
    final budget = await BudgetService.getById(session, budgetId: budgetId);
    final record = await _requireProfile(session, budgetId: budgetId);
    final jurisdiction = _parseJurisdiction(record.jurisdiction);
    final pack = _requirePack(jurisdiction);

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

    return _toView(
      report,
      opportunities,
      uncategorizedCount: built.uncategorizedCount,
      convertedCount: built.convertedCount,
    );
  }

  static Future<TaxProfileRecord> _requireProfile(
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
    return record;
  }

  static TaxRulePack _requirePack(TaxJurisdiction jurisdiction) =>
      packFor(jurisdiction);

  static TaxJurisdiction _parseJurisdiction(String value) {
    final jurisdiction = TaxJurisdiction.fromCountryCode(value);
    if (jurisdiction == null) {
      throw ValidationException(
        message: 'Unsupported tax jurisdiction "$value".',
      );
    }
    return jurisdiction;
  }

  static TaxEntityKind _parseEntityKind(String value) {
    for (final kind in TaxEntityKind.values) {
      if (kind.name == value) return kind;
    }
    throw ValidationException(message: 'Unsupported tax entity kind "$value".');
  }

  static TaxProfile _profileForRecord(TaxProfileRecord record) {
    final profile = _decodeProfile(record.profileJson);
    final jurisdiction = _parseJurisdiction(record.jurisdiction);
    final kind = _parseEntityKind(record.entityKind);
    if (profile.jurisdiction != jurisdiction || profile.entityKind != kind) {
      throw ValidationException(
        message:
            'The stored tax profile does not match its jurisdiction and entity '
            'kind.',
      );
    }
    return profile;
  }

  static void _validateCategoryCode(
    TaxRulePack pack,
    String? code,
    TaxEntityKind kind,
  ) {
    if (code == null) return;

    final category = pack.category(code);
    if (category == null) {
      throw ValidationException(
        message:
            'Unknown ${pack.jurisdiction.countryCode} tax category "$code".',
      );
    }
    if (!category.entityKinds.contains(kind)) {
      throw ValidationException(
        message: 'Tax category "$code" does not apply to ${kind.name} books.',
      );
    }
  }

  /// Decodes a client-provided profile, checking value types before handing
  /// the map to [TaxProfile.fromJson].
  static TaxProfile _decodeProfile(String profileJson) {
    final Object? decoded;
    try {
      decoded = jsonDecode(profileJson);
    } on FormatException catch (error) {
      throw ValidationException(
        message: 'profileJson is not valid JSON: ${error.message}',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw ValidationException(message: 'profileJson must be a JSON object.');
    }

    final sanitized = _sanitizeProfileJson(decoded);
    try {
      return TaxProfile.fromJson(sanitized);
    } on FormatException catch (error) {
      throw ValidationException(
        message: 'profileJson is not a valid tax profile: ${error.message}',
      );
    }
  }

  static Map<String, Object?> _sanitizeProfileJson(
    Map<String, Object?> json,
  ) {
    final jurisdictionCode = _requiredString(json, 'jurisdiction');
    final entityKind = _requiredString(json, 'entityKind');
    _parseEntityKind(entityKind);
    final sanitized = <String, Object?>{
      'jurisdiction': jurisdictionCode,
      'entityKind': entityKind,
      'salesTaxRegistered': _optional<bool>(json, 'salesTaxRegistered'),
    };

    switch (TaxJurisdiction.fromCountryCode(jurisdictionCode)) {
      case TaxJurisdiction.gb:
        final studentLoanPlan = _optional<String>(json, 'studentLoanPlan');
        if (studentLoanPlan != null &&
            !GbStudentLoanPlan.values.any(
              (plan) => plan.name == studentLoanPlan,
            )) {
          throw ValidationException(
            message:
                'profileJson has an unknown student loan plan '
                '"$studentLoanPlan".',
          );
        }
        sanitized.addAll({
          'scottishTaxpayer': _optional<bool>(json, 'scottishTaxpayer'),
          'studentLoanPlan': studentLoanPlan,
        });
      case TaxJurisdiction.us:
        final filingStatus = _optional<String>(json, 'filingStatus');
        if (filingStatus != null &&
            !UsFilingStatus.values.any(
              (status) => status.name == filingStatus,
            )) {
          throw ValidationException(
            message:
                'profileJson has an unknown filing status "$filingStatus".',
          );
        }
        final homeOfficeMethod = _optional<String>(json, 'homeOfficeMethod');
        if (homeOfficeMethod != null &&
            !UsHomeOfficeMethod.values.any(
              (method) => method.name == homeOfficeMethod,
            )) {
          throw ValidationException(
            message:
                'profileJson has an unknown home office method '
                '"$homeOfficeMethod".',
          );
        }
        sanitized['filingStatus'] = filingStatus;
        sanitized.addAll({
          'homeOfficeMethod': homeOfficeMethod,
          'specifiedServiceTrade': _optional<bool>(
            json,
            'specifiedServiceTrade',
          ),
          'foreignEarnedIncomeExclusionMinor': _optional<int>(
            json,
            'foreignEarnedIncomeExclusionMinor',
          ),
          'taxpayer65OrOlder': _optional<bool>(json, 'taxpayer65OrOlder'),
          'spouse65OrOlder': _optional<bool>(json, 'spouse65OrOlder'),
          'taxpayerHasSsn': _optional<bool>(json, 'taxpayerHasSsn'),
          'spouseHasSsn': _optional<bool>(json, 'spouseHasSsn'),
          'dependents': _optional<List<Object?>>(json, 'dependents'),
        });
      case TaxJurisdiction.ng:
        sanitized['annualRentMinor'] = _optional<int>(json, 'annualRentMinor');
      case TaxJurisdiction.de:
        sanitized.addAll({
          'jointAssessment': _optional<bool>(json, 'jointAssessment'),
          'churchTax': _optional<bool>(json, 'churchTax'),
          'smallBusinessExemption': _optional<bool>(
            json,
            'smallBusinessExemption',
          ),
        });
      case null:
        throw ValidationException(
          message: 'Unsupported tax jurisdiction "$jurisdictionCode".',
        );
    }

    return sanitized;
  }

  static String _requiredString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw ValidationException(
        message: 'profileJson field "$key" must be a string.',
      );
    }
    return value;
  }

  static T? _optional<T>(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is T) return value as T;
    throw ValidationException(
      message: 'profileJson field "$key" has the wrong type.',
    );
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
    final kind = _parseEntityKind(record.entityKind);
    final linkedBudgetId = record.linkedBudgetId;
    final candidates = <TaxProfileRecord>[];

    if (kind == TaxEntityKind.individual) {
      final soleTraders = await TaxProfileRecord.db.find(
        session,
        where: (t) =>
            t.linkedBudgetId.equals(budget.id) &
            t.entityKind.equals(TaxEntityKind.soleTrader.name) &
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
    } else if (kind == TaxEntityKind.company && linkedBudgetId != null) {
      final linkedProfile = await TaxProfileRecord.db.findFirstRow(
        session,
        where: (t) => t.budgetId.equals(linkedBudgetId),
      );
      if (linkedProfile != null &&
          linkedProfile.entityKind == TaxEntityKind.individual.name &&
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

  static TaxReportView _toView(
    TaxReport report,
    List<TaxOpportunity> opportunities, {
    required int uncategorizedCount,
    required int convertedCount,
  }) => TaxReportView(
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
      if (convertedCount > 0) _conversionAssumption,
    ],
    sources: [for (final source in report.sources) source.toString()],
    rulesVerifiedOn: report.rulesVerifiedOn,
    uncategorizedCount: report.uncategorizedCount + uncategorizedCount,
    convertedEntryCount: convertedCount,
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
