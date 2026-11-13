import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/envelopes/envelope_service.dart';
import 'package:openbudget_server/src/fx_rates/fx_quote_selection.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/tax/tax_catalogue_validation.dart';
import 'package:openbudget_server/src/tax/tax_entry_builder.dart';
import 'package:openbudget_server/src/tax/tax_fx_rates.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';

/// A stored profile plus the canonical profile parsed from its entity.
typedef _StoredTaxProfile = ({
  TaxProfileRecord record,
  TaxProfile profile,
});

/// One report computation, or the rates the read could not find.
class _MissingTaxRates implements Exception {
  const _MissingTaxRates(this.requests);

  final List<TaxFxRequest> requests;
}

/// Business logic for tax profiles, categorisation, and reports.
///
/// Every method verifies that the authenticated user owns the entity whose
/// data it reads or writes. The entity is the single source of jurisdiction,
/// entity kind, fiscal year end and the personal-business link; the stored
/// profile JSON is rewritten from it on every save and read. The computation
/// itself belongs to the pure rule packs in `openbudget_core`; this service
/// only assembles their input from stored transaction lines.
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

  /// The server clock used for the default tax year and quote staleness.
  @visibleForTesting
  static DateTime Function() clock = () => DateTime.now().toUtc();

  /// Returns the entity's canonical tax profile, or null when none is set.
  static Future<TaxProfileRecord?> getProfile(
    Session session, {
    required UuidValue entityId,
  }) async {
    final entity = await EntityAccess.requireOwned(session, entityId);
    _requireJurisdiction(entity);

    final record = await TaxProfileRecord.db.findFirstRow(
      session,
      where: (t) => t.entityId.equals(entityId),
    );
    if (record == null) return null;

    final profile = _parseCanonicalProfile(entity, record.profileJson);
    return record.copyWith(profileJson: jsonEncode(profile.toJson()));
  }

  /// Creates or replaces the entity's tax profile atomically.
  ///
  /// [jurisdiction] and [entityKind] are the documented §7.1 parameters kept
  /// for the existing endpoint surface. They are redundant assertions only:
  /// a value that disagrees with the entity rejects, and neither can override
  /// the entity's country or kind. The personal-business link likewise comes
  /// from `Entity.linkedPersonalEntityId`; this method never writes it.
  ///
  /// An individual cannot have a linked personal entity. A sole trader or
  /// company may link only an owned personal entity in the same country.
  static Future<TaxProfileRecord> saveProfile(
    Session session, {
    required UuidValue entityId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
  }) async {
    _log.info('Saving tax profile entity=$entityId');

    final saved = await session.db.transaction((tx) async {
      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: tx,
          lock: true,
        ),
      );
      _requireJurisdiction(entity);
      _requireProfileParameters(entity, jurisdiction, entityKind);
      await _requireLinkedEntity(session, entity, tx);

      final profile = _parseCanonicalProfile(entity, profileJson);
      final now = clock();
      final row = await TaxProfileRecord.db.upsertRow(
        session,
        TaxProfileRecord(
          entityId: entity.id!,
          profileJson: jsonEncode(profile.toJson()),
          createdAt: now,
          updatedAt: now,
        ),
        conflictColumns: (t) => [t.entityId],
        updateColumns: (t) => [t.profileJson, t.updatedAt],
        transaction: tx,
      );
      if (row == null) {
        throw StateError('Saving a tax profile returned no row');
      }
      return row;
    });

    // Publish only after the upsert has committed, so a reader that reacts to
    // the event always sees the new profile.
    await EntityRealtimeNotifier.notify(session, entityId, ChangeScope.entity);
    return saved;
  }

  /// Lists the tax categories available to the entity's kind.
  ///
  /// An entity whose country has no rule pack lists the universal
  /// catalogue, and needs no tax profile: profiles are pack-shaped, so
  /// none can exist for that country yet. Pack countries keep their own
  /// catalogue after the entity has set up its profile.
  static Future<List<TaxCategoryView>> listCategories(
    Session session, {
    required UuidValue entityId,
  }) async {
    final entity = await EntityAccess.requireOwned(session, entityId);
    final jurisdiction = TaxJurisdiction.fromCountryCode(entity.countryCode);
    if (jurisdiction == null) {
      return [
        for (final category in UniversalTaxCategories.categoriesFor(
          entity.kind,
        ))
          TaxCategoryView(
            code: category.code,
            label: category.label,
            kind: category.kind.name,
            reportReference: category.reportReference,
            description: category.description,
          ),
      ];
    }

    await _requireProfile(session, entity);
    final pack = _requirePack(jurisdiction);

    return [
      for (final category in pack.categoriesFor(entity.kind))
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
  ///
  /// The envelope's own update path owns validation, archive guards and the
  /// post-commit event, so this method only resolves the entity and its
  /// profile and then delegates. A null or blank [code] clears the default.
  static Future<Envelope> setEnvelopeTaxCategory(
    Session session, {
    required UuidValue envelopeId,
    String? code,
  }) async {
    final envelope = await EnvelopeService.getById(
      session,
      envelopeId: envelopeId,
    );
    final entity = await EntityAccess.requireOwned(session, envelope.entityId);
    await _requireProfile(session, entity);

    final trimmed = code?.trim();
    final clear = trimmed == null || trimmed.isEmpty;
    return EnvelopeService.update(
      session,
      envelopeId: envelopeId,
      taxCategoryCode: clear ? null : trimmed,
      clearTaxCategoryCode: clear ? true : null,
    );
  }

  /// Sets one stored line's tax treatment and returns the transaction view.
  ///
  /// Null leaves that field unchanged; [clearTaxCategoryCode] clears only the
  /// category. The write locks the account and header in the writer's order,
  /// verifies the locked header still names that account, then goes through
  /// [TransactionWriter.updateLines], so a reconciled row, period lock,
  /// archived entity, ledger revision, audit and every other line keep their
  /// existing rules and values.
  static Future<TransactionView> setLineTax(
    Session session, {
    required UuidValue transactionLineId,
    String? taxCategoryCode,
    bool? clearTaxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
  }) async {
    final clear = clearTaxCategoryCode ?? false;
    final code = TaxCatalogueValidation.normalise(taxCategoryCode);

    if (clear && code != null) {
      throw ValidationException(
        message: 'clearTaxCategoryCode cannot be combined with taxCategoryCode',
      );
    }
    if (businessUsePercent != null &&
        (businessUsePercent < 0 || businessUsePercent > 100)) {
      throw ValidationException(
        message: 'businessUsePercent must be between 0 and 100',
      );
    }

    return TransactionWriter.inTransaction(session, (tx) async {
      final discovered = await TransactionLine.db.findById(
        session,
        transactionLineId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Transaction line not found');
      }

      final discoveredHeader = await model.Transaction.db.findById(
        session,
        discovered.transactionId,
        transaction: tx,
      );
      if (discoveredHeader == null) {
        throw NotFoundException(message: 'Transaction not found');
      }

      // Ownership rejects a foreign line before any row is locked or read
      // further. The entity lock is FOR NO KEY UPDATE by default, so it
      // serializes with other entity writers without blocking the foreign-key
      // key share an ordinary create takes on this row while it holds the
      // account. A stronger entity lock here would close a 40P01 cycle.
      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discoveredHeader.entityId,
          transaction: tx,
          lock: true,
        ),
      );

      // The writer takes the account before the header, so the tax path takes
      // the same order and cannot deadlock with an ordinary edit.
      final account = await Account.db.findById(
        session,
        discoveredHeader.accountId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (account == null) {
        throw ValidationException(
          message: 'The transaction changed concurrently; retry the edit',
        );
      }

      final header = await model.Transaction.db.findById(
        session,
        discovered.transactionId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      // An ordinary edit may have moved the header to another account of the
      // same entity while this call waited. Reject it here, before the writer
      // locks that new account after the header and inverts the lock order.
      if (header == null ||
          header.entityId != entity.id ||
          header.accountId != account.id) {
        throw ValidationException(
          message: 'The transaction changed concurrently; retry the edit',
        );
      }

      final lines = await TransactionLine.db.find(
        session,
        where: (t) => t.transactionId.equals(header.id),
        orderByList: (t) => [t.sortOrder, t.id],
        transaction: tx,
      );

      TransactionLine? target;
      for (final line in lines) {
        if (line.id == discovered.id) {
          target = line;
          break;
        }
      }
      if (target == null) {
        throw NotFoundException(message: 'Transaction line not found');
      }

      final inputs = [
        for (final line in lines)
          TransactionLineInput(
            amountMinor: line.amountMinor,
            envelopeId: line.envelopeId,
            ledgerAccountId: line.ledgerAccountId,
            taxCategoryCode: line.id == target.id
                ? (clear ? null : code ?? line.taxCategoryCode)
                : line.taxCategoryCode,
            businessUsePercent: line.id == target.id
                ? businessUsePercent ?? line.businessUsePercent
                : line.businessUsePercent,
            salesTaxMinor: line.id == target.id
                ? salesTaxMinor ?? line.salesTaxMinor
                : line.salesTaxMinor,
            memo: line.memo,
          ),
      ];

      return TransactionWriter.updateLines(
        session,
        header.id!,
        inputs,
        transaction: tx,
      );
    });
  }

  /// Computes the entity's tax report for the year that starts in [startYear].
  ///
  /// When [startYear] is null the tax year containing the entity's local today
  /// is used. The whole read runs at repeatable-read isolation, so every line,
  /// envelope and rate comes from one committed snapshot even while a write is
  /// in flight. A missing rate fails the read with
  /// [FxRateUnavailableException] after requesting one backfill per date.
  static Future<TaxReportView> report(
    Session session, {
    required UuidValue entityId,
    int? startYear,
  }) async {
    _log.info('Building tax report entity=$entityId year=$startYear');

    try {
      return await session.db.transaction(
        (tx) async {
          final entity = await EntityAccess.requireOwned(
            session,
            entityId,
            transaction: tx,
          );
          final jurisdiction = _requireJurisdiction(entity);
          final pack = _requirePack(jurisdiction);

          final linkedEntities = await _linkedEntities(session, entity, tx);
          final profiles = await _loadProfiles(
            session,
            [entity, ...linkedEntities],
            tx,
          );
          final mainProfile = profiles[entity.id!];
          if (mainProfile == null) {
            throw NotFoundException(
              message: 'Tax profile not found for this entity',
            );
          }
          final year = _resolveYear(pack, entity, startYear);

          final includedLinked = [
            for (final linked in linkedEntities)
              if (profiles.containsKey(linked.id)) linked,
          ];

          final included = [entity, ...includedLinked];
          final entityIds = {for (final row in included) row.id!};
          final linesByEntity = await loadTaxLines(
            session,
            entityIds,
            year.start,
            year.end,
            tx,
          );
          final allLines = [
            for (final lines in linesByEntity.values) ...lines,
          ];
          final requests = taxFxRequestsFor(
            lines: allLines,
            year: year,
            targetCurrencyCode: jurisdiction.currencyCode,
          ).toList();
          final rates = await loadTaxFxRates(
            session,
            requests,
            tx,
            targetCurrencyCode: jurisdiction.currencyCode,
          );
          final missing = rates.missingFor(requests);
          if (missing.isNotEmpty) throw _MissingTaxRates(missing);

          final built = <UuidValue, TaxEntryBuildResult>{};
          for (final row in included) {
            built[row.id!] = buildTaxEntries(
              lines: linesByEntity[row.id!] ?? const [],
              year: year,
              rates: rates,
              targetCurrencyCode: jurisdiction.currencyCode,
            );
          }

          final mainBuilt = built[entity.id!]!;
          var uncategorizedCount = mainBuilt.uncategorizedCount;
          var convertedCount = mainBuilt.convertedCount;
          var unmappedUniversalCount = 0;
          final linkedInputs = <TaxInput>[];
          for (final linked in includedLinked) {
            final linkedBuilt = built[linked.id!]!;
            linkedInputs.add(
              TaxInput(
                profile: profiles[linked.id!]!.profile,
                year: year,
                entries: _mapUniversalEntries(
                  linkedBuilt.entries,
                  pack: pack,
                  kind: linked.kind,
                  onUnmapped: () => unmappedUniversalCount++,
                ),
              ),
            );
            uncategorizedCount += linkedBuilt.uncategorizedCount;
            convertedCount += linkedBuilt.convertedCount;
          }

          final input = TaxInput(
            profile: mainProfile.profile,
            year: year,
            entries: _mapUniversalEntries(
              mainBuilt.entries,
              pack: pack,
              kind: entity.kind,
              onUnmapped: () => unmappedUniversalCount++,
            ),
            linked: linkedInputs,
          );

          final TaxReport report;
          try {
            report = pack.report(input);
          } on UnsupportedTaxYearException catch (error) {
            throw TaxRulesUnavailableException(message: error.toString());
          }
          final opportunities = pack.opportunities(input, report);

          return _toView(
            report,
            opportunities,
            ruleSet: pack.ruleSet(input.year.startYear),
            uncategorizedCount: uncategorizedCount,
            convertedCount: convertedCount,
            unmappedUniversalCount: unmappedUniversalCount,
          );
        },
        settings: const TransactionSettings(
          isolationLevel: IsolationLevel.repeatableRead,
        ),
      );
    } on _MissingTaxRates catch (missing) {
      final dates = {for (final request in missing.requests) request.date};
      for (final date in dates.toList()..sort()) {
        await FxService.requestBackfill(session, date);
      }

      final first = missing.requests.first;
      throw FxRateUnavailableException(
        message:
            'No exchange rate is available to convert '
            '${first.fromCurrencyCode} to ${first.toCurrencyCode} on '
            '${first.date.toIso8601String()}.',
        fromCurrencyCode: first.fromCurrencyCode,
        toCurrencyCode: first.toCurrencyCode,
        date: first.date,
      );
    }
  }

  static TaxYear _resolveYear(
    TaxRulePack pack,
    Entity entity,
    int? startYear,
  ) {
    try {
      return startYear == null
          ? pack.taxYearFor(EntityClock.today(entity, now: clock()))
          : pack.taxYear(startYear);
    } on UnsupportedTaxYearException catch (error) {
      throw TaxRulesUnavailableException(message: error.toString());
    }
  }

  static Future<_StoredTaxProfile> _requireProfile(
    Session session,
    Entity entity, {
    Transaction? transaction,
  }) async {
    final profile = await _loadProfile(
      session,
      entity,
      transaction: transaction,
    );
    if (profile == null) {
      throw NotFoundException(
        message: 'Tax profile not found for this entity',
      );
    }
    return profile;
  }

  static Future<_StoredTaxProfile?> _loadProfile(
    Session session,
    Entity entity, {
    Transaction? transaction,
  }) async {
    _requireJurisdiction(entity);
    final record = await TaxProfileRecord.db.findFirstRow(
      session,
      where: (t) => t.entityId.equals(entity.id),
      transaction: transaction,
    );
    if (record == null) return null;

    return _storedProfile(entity, record);
  }

  /// Loads every profile of [entities] in one query for a coherent report.
  static Future<Map<UuidValue, _StoredTaxProfile>> _loadProfiles(
    Session session,
    List<Entity> entities,
    Transaction transaction,
  ) async {
    final byId = {for (final entity in entities) entity.id!: entity};
    if (byId.isEmpty) return const {};

    final records = await TaxProfileRecord.db.find(
      session,
      where: (t) => t.entityId.inSet(byId.keys.toSet()),
      transaction: transaction,
    );

    final profiles = <UuidValue, _StoredTaxProfile>{};
    for (final record in records) {
      final entity = byId[record.entityId];
      if (entity == null) continue;

      profiles[record.entityId] = _storedProfile(entity, record);
    }
    return profiles;
  }

  static _StoredTaxProfile _storedProfile(
    Entity entity,
    TaxProfileRecord record,
  ) {
    _requireJurisdiction(entity);
    final profile = _parseCanonicalProfile(entity, record.profileJson);
    return (
      record: record.copyWith(profileJson: jsonEncode(profile.toJson())),
      profile: profile,
    );
  }

  /// The entities whose books feed [main]'s report.
  ///
  /// An individual collects the sole traders that name it as their personal
  /// entity. A company collects only the personal entity it names, so its
  /// director comparison never reaches into that person's other businesses.
  /// Every link is restricted to the same owner and country, so a foreign or
  /// forged link cannot feed another user's figures.
  static Future<List<Entity>> _linkedEntities(
    Session session,
    Entity main,
    Transaction transaction,
  ) async {
    switch (main.kind) {
      case EntityKind.individual:
        return Entity.db.find(
          session,
          where: (t) =>
              t.ownerId.equals(main.ownerId) &
              t.kind.equals(EntityKind.soleTrader) &
              t.linkedPersonalEntityId.equals(main.id) &
              t.countryCode.equals(main.countryCode),
          orderByList: (t) => [t.id],
          transaction: transaction,
        );
      case EntityKind.company:
        final linkedId = main.linkedPersonalEntityId;
        if (linkedId == null) return const [];

        final linked = await Entity.db.findById(
          session,
          linkedId,
          transaction: transaction,
        );
        if (linked == null) {
          throw ValidationException(
            message: 'The linked personal entity no longer exists.',
          );
        }
        if (linked.ownerId != main.ownerId) {
          throw ValidationException(
            message:
                'The linked personal entity must belong to the same owner.',
          );
        }
        if (linked.kind != EntityKind.individual) {
          throw ValidationException(
            message: 'The linked entity must be a personal entity.',
          );
        }
        if (linked.countryCode != main.countryCode) {
          throw ValidationException(
            message: 'The linked personal entity must be in the same country.',
          );
        }
        return [linked];
      case EntityKind.soleTrader:
        return const [];
    }
  }

  /// Loads every in-period line for [entityIds] in one query.
  ///
  /// The period is the half-open range `[periodStart, periodEnd)` of civil
  /// dates. The account join supplies the line's currency, the envelope
  /// join its default tax code and the transfer join marks legs that are
  /// outside tax. No daily FX request leaves this method; the caller loads
  /// all rates once.
  ///
  /// Shared with the tax-ready summary service, so a report and a summary
  /// can never disagree about which lines a period contains.
  static Future<Map<UuidValue, List<TaxEntrySourceLine>>> loadTaxLines(
    Session session,
    Set<UuidValue> entityIds,
    DateTime periodStart,
    DateTime periodEnd,
    Transaction transaction,
  ) async {
    if (entityIds.isEmpty) return const {};

    final rows = await session.db.unsafeQuery(
      _taxLinesSql,
      parameters: QueryParameters.named({
        'entityIds': _uuidArrayLiteral(entityIds),
        'yearStart': periodStart,
        'yearEnd': periodEnd,
      }),
      transaction: transaction,
    );

    final grouped = <UuidValue, List<TaxEntrySourceLine>>{
      for (final id in entityIds) id: <TaxEntrySourceLine>[],
    };
    for (final row in rows) {
      final entityId = UuidValue.fromString(row[1] as String);
      grouped[entityId]?.add(
        TaxEntrySourceLine(
          id: UuidValue.fromString(row[0] as String),
          date: row[2] as DateTime,
          description: row[3] as String,
          currencyCode: row[4] as String,
          amountMinor: row[5] as int,
          salesTaxMinor: row[6] as int?,
          businessUsePercent: row[7] as int?,
          taxCategoryCode: row[8] as String?,
          envelopeTaxCategoryCode: row[9] as String?,
          isTransfer: row[10] as bool,
          envelopeName: row[11] as String?,
          payeeName: row[12] as String?,
        ),
      );
    }
    return grouped;
  }

  /// Loads the stored daily rows the given requests' conversions read.
  ///
  /// Shared with the tax-ready summary service, which reports the rate
  /// facts behind its converted lines from the same rows the report
  /// converts with.
  static Future<TaxFxRates> loadTaxFxRates(
    Session session,
    List<TaxFxRequest> requests,
    Transaction transaction, {
    required String targetCurrencyCode,
  }) async {
    final needed = {
      for (final request in requests)
        if (!request.isIdentity) ...{
          request.fromCurrencyCode,
          request.toCurrencyCode,
        },
    };
    if (needed.isEmpty) {
      return TaxFxRates(rates: const [], evaluatedAt: clock());
    }

    final dates = [
      for (final request in requests)
        if (!request.isIdentity) request.date,
    ]..sort();
    final first = dates.first;
    final last = dates.last;

    final rows = await FxRate.db.find(
      session,
      where: (t) =>
          t.currencyCode.inSet(needed) &
          (t.rateDate > first.subtract(const Duration(days: 7))) &
          (t.rateDate <= last),
      orderByList: (t) => [t.currencyCode, t.rateDate],
      transaction: transaction,
    );

    return TaxFxRates(
      rates: [
        for (final row in rows)
          FxDailyRate(
            currencyCode: row.currencyCode,
            rateDate: row.rateDate,
            rate: row.rate,
            fetchedAt: row.fetchedAt,
          ),
      ],
      evaluatedAt: clock(),
    );
  }

  static TaxJurisdiction _requireJurisdiction(Entity entity) {
    final jurisdiction = TaxJurisdiction.fromCountryCode(entity.countryCode);
    if (jurisdiction == null) {
      throw ValidationException(
        message:
            'No tax rules are available for ${entity.countryCode}. The '
            'entity country is the only source of tax jurisdiction.',
      );
    }
    return jurisdiction;
  }

  static TaxRulePack _requirePack(TaxJurisdiction jurisdiction) =>
      packFor(jurisdiction);

  static Entity _requireWritable(Entity entity) {
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects tax changes',
      );
    }
    return entity;
  }

  static void _requireProfileParameters(
    Entity entity,
    String jurisdiction,
    String entityKind,
  ) {
    final country = jurisdiction.trim().toUpperCase();
    if (country != entity.countryCode.toUpperCase()) {
      throw ValidationException(
        message:
            'The entity is in ${entity.countryCode}, not $jurisdiction. Its '
            'country is the only source of tax jurisdiction.',
      );
    }

    final kind = entityKind.trim();
    if (kind != entity.kind.name) {
      throw ValidationException(
        message:
            'The entity is ${entity.kind.name}, not $entityKind. Its kind is '
            'the only source of tax entity kind.',
      );
    }
  }

  static Future<void> _requireLinkedEntity(
    Session session,
    Entity entity,
    Transaction transaction,
  ) async {
    final linkedId = entity.linkedPersonalEntityId;
    if (linkedId == null) return;

    if (entity.kind == EntityKind.individual) {
      throw ValidationException(
        message: 'An individual entity cannot link another personal entity.',
      );
    }

    final linked = await EntityAccess.requireOwned(
      session,
      linkedId,
      transaction: transaction,
    );
    if (linked.kind != EntityKind.individual) {
      throw ValidationException(
        message: 'The linked entity must be a personal entity.',
      );
    }
    if (linked.countryCode != entity.countryCode) {
      throw ValidationException(
        message: 'The linked personal entity must be in the same country.',
      );
    }
  }

  /// Decodes a client or stored profile and rewrites its identity from entity.
  ///
  /// The overwritten keys are the only source of jurisdiction, entity kind and
  /// the GB accounting period. A forged or stale value in `profileJson`
  /// therefore cannot change identity, while any other malformed field still
  /// throws [ValidationException].
  static TaxProfile _parseCanonicalProfile(
    Entity entity,
    String profileJson,
  ) {
    final decoded = _decodeJsonObject(profileJson);
    try {
      return TaxProfile.fromJson(_canonicalProfileMap(decoded, entity));
    } on FormatException catch (error) {
      throw ValidationException(
        message: 'The tax profile is not valid: ${error.message}',
      );
    }
  }

  static Map<String, Object?> _canonicalProfileMap(
    Map<String, Object?> decoded,
    Entity entity,
  ) {
    final canonical = Map<String, Object?>.of(decoded)
      ..['jurisdiction'] = entity.countryCode.toUpperCase()
      ..['entityKind'] = entity.kind.name;

    if (entity.countryCode.toUpperCase() == 'GB') {
      canonical['accountingPeriodEndMonth'] = entity.fiscalYearEndMonth;
      canonical['accountingPeriodEndDay'] = entity.fiscalYearEndDay;
    } else {
      canonical
        ..remove('accountingPeriodEndMonth')
        ..remove('accountingPeriodEndDay');
    }

    return canonical;
  }

  static Map<String, Object?> _decodeJsonObject(String profileJson) {
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
    return decoded;
  }

  static String _uuidArrayLiteral(Iterable<UuidValue> ids) =>
      '{${ids.map((id) => id.uuid).join(',')}}';

  /// Maps universal category codes through [pack] for one entity's
  /// entries, before they reach the report computation.
  ///
  /// A mapped entry keeps its figures under the pack's own code. An entry
  /// whose universal code has no home in the pack is dropped and reported
  /// through [onUnmapped]: it counts as uncategorised on the report with
  /// a caveat, rather than land somewhere its rules may not allow.
  static List<TaxEntry> _mapUniversalEntries(
    List<TaxEntry> entries, {
    required TaxRulePack pack,
    required EntityKind kind,
    required void Function() onUnmapped,
  }) {
    final mapped = <TaxEntry>[];
    for (final entry in entries) {
      final code = entry.categoryCode;
      if (!UniversalTaxCategories.isUniversalCode(code)) {
        mapped.add(entry);
        continue;
      }
      final packCode = pack.mapUniversalCategory(code, kind);
      if (packCode == null) {
        onUnmapped();
        continue;
      }
      if (packCode == code) {
        mapped.add(entry);
        continue;
      }
      mapped.add(
        TaxEntry(
          date: entry.date,
          amountMinor: entry.amountMinor,
          categoryCode: packCode,
          businessUsePercent: entry.businessUsePercent,
          salesTaxMinor: entry.salesTaxMinor,
          sourceId: entry.sourceId,
          note: entry.note,
        ),
      );
    }
    return mapped;
  }

  /// Caveat for entries whose universal code this report cannot place.
  static String _unmappedUniversalCaveat(
    int count,
    TaxJurisdiction jurisdiction,
  ) {
    final entries = count == 1 ? 'entry' : 'entries';
    return 'Caveat: $count tagged $entries use universal tax categories '
        'with no ${jurisdiction.countryCode} return box, so they are '
        'counted as uncategorised.';
  }

  static TaxReportView _toView(
    TaxReport report,
    List<TaxOpportunity> opportunities, {
    required TaxRuleSet ruleSet,
    required int uncategorizedCount,
    required int convertedCount,
    int unmappedUniversalCount = 0,
  }) {
    // Only the figures this report's lines quote travel to the app, each
    // with its grade so a secondary figure can carry its badge.
    final quotedFigureIds = <String>{
      for (final line in report.lines) ?line.figureId,
    };
    return TaxReportView(
      jurisdiction: report.year.jurisdiction.countryCode,
      startYear: report.year.startYear,
      yearLabel: report.year.label,
      yearStart: report.year.start,
      yearEnd: report.year.end,
      entityKind: report.entityKind,
      currencyCode: report.currencyCode,
      lines: [
        for (final line in report.lines)
          TaxReportLineView(
            label: line.label,
            amountMinor: line.amountMinor,
            code: line.code,
            reportReference: line.reportReference,
            entryCount: line.entryCount,
            figureId: line.figureId,
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
        if (unmappedUniversalCount > 0)
          _unmappedUniversalCaveat(
            unmappedUniversalCount,
            report.year.jurisdiction,
          ),
      ],
      sources: [for (final source in report.sources) source.toString()],
      caveats: [
        for (final caveat in report.caveats)
          TaxRuleCaveatView(
            id: caveat.id,
            text: caveat.text,
            grade: caveat.grade.name,
            sections: [for (final section in caveat.sections) section.name],
            keys: [for (final key in caveat.keys) key],
            recheckBy: caveat.recheckBy,
            announced: caveat.announced,
          ),
      ],
      figures: [
        for (final figureId in quotedFigureIds)
          if (ruleSet.figures[figureId] case final figure?)
            TaxFigureView(
              id: figure.id,
              value: figure.value,
              unit: figure.unit.name,
              grade: figure.grade.name,
              verifiedOn: figure.verifiedOn,
              source: figure.source.toString(),
            ),
      ],
      rulesVerifiedOn: report.rulesVerifiedOn,
      rulesVersion: report.rulesVersion,
      maturity: report.maturity.name,
      coverage: {
        for (final entry in report.coverage.entries)
          entry.key.name: entry.value.name,
      },
      uncategorizedCount:
          report.uncategorizedCount +
          uncategorizedCount +
          unmappedUniversalCount,
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
}

/// One row per stored transaction line inside the entity and year window.
///
/// The transfer join is left-sided because an ordinary line has no match.
const _taxLinesSql = '''
SELECT
  l.id::text,
  t."entityId"::text,
  t.date,
  t.description,
  a."currencyCode",
  l."amountMinor",
  l."salesTaxMinor",
  l."businessUsePercent",
  l."taxCategoryCode",
  e."taxCategoryCode",
  tr.id IS NOT NULL,
  e.name,
  p.name
FROM transaction_line l
JOIN "transaction" t ON t.id = l."transactionId"
JOIN account a ON a.id = t."accountId"
LEFT JOIN envelope e ON e.id = l."envelopeId"
LEFT JOIN payee p ON p.id = t."payeeId"
LEFT JOIN transfer tr
  ON tr."fromTransactionId" = t.id OR tr."toTransactionId" = t.id
WHERE t."entityId" = ANY(@entityIds::uuid[])
  AND t.date >= @yearStart
  AND t.date < @yearEnd
ORDER BY t.date, t.id, l."sortOrder", l.id
''';
