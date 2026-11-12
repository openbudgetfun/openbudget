import 'dart:convert';
import 'dart:math' as math;

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_access.dart';
import 'package:openbudget_server/src/budget/budget_month_service.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/reports/net_worth_service.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// Everything a tool may read or write for one turn.
///
/// [userId] is the only authority the tools trust. The Serverpod session is
/// just the database connection, so a future MCP server can reuse the same
/// registry without an authenticated endpoint session.
class AgentToolContext {
  const AgentToolContext({
    required this.session,
    required this.userId,
    required this.canPropose,
    this.conversationId,
  });

  final Session session;
  final UuidValue userId;
  final bool canPropose;
  final UuidValue? conversationId;
}

/// The assistant's read and propose tools.
///
/// Tools never apply a change. The propose tools insert a pending
/// [AgentProposal] that the user applies or dismisses from the endpoint.
///
/// Reads go through the same services the app uses: the envelope month view
/// from [BudgetMonthService], the tax position from [TaxService], net worth
/// from [NetWorthService]. Every money value is reported as a `*Minor` integer
/// next to an explicit ISO currency code; plan amounts are in the entity's
/// base currency.
class AgentToolRegistry {
  const AgentToolRegistry();

  static final _log = ObLogger('AgentToolRegistry');

  static const int _defaultSearchLimit = 25;
  static const int _maxSearchLimit = 50;

  /// The OpenAI function-tool definitions for this deployment.
  ///
  /// Propose tools appear only when [canPropose] is true, so a read-only
  /// deployment never offers the model a change it cannot make.
  List<Map<String, Object?>> definitions({required bool canPropose}) => [
    _tool(
      name: 'list_entities',
      description:
          'List the entities (households, sole traders, companies) the user '
          'owns, with their base currency. Start here when you do not know '
          'which entity the user means.',
      properties: const {},
    ),
    _tool(
      name: 'list_envelopes',
      description:
          "Read one month of an entity's envelope plan: every envelope's "
          'assigned, carryover, activity and available amounts in base-currency '
          'minor units, plus Ready to Assign and income.',
      properties: {
        'entityId': _uuidSchema('The entity to read.'),
        'month': {
          'type': 'integer',
          'description':
              'The plan month as yyyymm, such as 202611. Omit for the '
              "entity's current month.",
        },
      },
      required: ['entityId'],
    ),
    _tool(
      name: 'search_transactions',
      description:
          "Search one entity's transactions by text, date range or both. "
          'Returns at most 50 matches, newest first. Amounts carry both the '
          'account currency and the base currency.',
      properties: {
        'entityId': _uuidSchema('The entity to search.'),
        'query': _stringSchema(
          'Text to look for in the description or memo, case-insensitive.',
        ),
        'fromDate': _stringSchema(
          'Only transactions on or after this ISO 8601 date.',
        ),
        'toDate': _stringSchema(
          'Only transactions before this ISO 8601 date. A plain date '
          'includes that whole day.',
        ),
        'limit': {
          'type': 'integer',
          'minimum': 1,
          'maximum': _maxSearchLimit,
          'description': 'How many matches to return, 1 to $_maxSearchLimit.',
        },
      },
      required: ['entityId'],
    ),
    _tool(
      name: 'get_tax_report',
      description:
          "Compute the entity's tax report for a tax year. Cite the report's "
          'sources and assumptions in the answer.',
      properties: {
        'entityId': _uuidSchema('The entity whose tax position to read.'),
        'startYear': {
          'type': 'integer',
          'minimum': 1900,
          'maximum': 2200,
          'description':
              'The calendar year the tax year starts in. Omit for the '
              'current tax year.',
        },
      },
      required: ['entityId'],
    ),
    _tool(
      name: 'list_tax_categories',
      description:
          'List the tax category codes available to this entity, with their '
          'labels and where they land on the return.',
      properties: {
        'entityId': _uuidSchema('The entity whose categories to list.'),
      },
      required: ['entityId'],
    ),
    _tool(
      name: 'get_net_worth',
      description:
          'Read net worth in minor units of a reporting currency, with '
          'assets, liabilities, per-entity and per-currency breakdowns. '
          'Omit the entity to cover every entity the user includes in net '
          'worth.',
      properties: {
        'entityId': _uuidSchema(
          'One entity to read. Omit for the user whole net-worth scope.',
        ),
        'currencyCode': _stringSchema(
          'ISO 4217 reporting currency. Omit to use the user setting.',
        ),
      },
    ),
    if (canPropose) ...[
      _tool(
        name: 'propose_move_money',
        description:
            'Propose moving money between two envelopes in one month. This '
            'does not move anything; the user applies the proposal. Amounts '
            'are in the entity base-currency minor units.',
        properties: {
          'entityId': _uuidSchema('The entity whose plan to change.'),
          'fromEnvelopeId': _uuidSchema('The envelope to take money from.'),
          'toEnvelopeId': _uuidSchema('The envelope to give money to.'),
          'amountMinor': {
            'type': 'integer',
            'minimum': 1,
            'description': 'How much to move, in base-currency minor units.',
          },
          'month': {
            'type': 'integer',
            'description': 'The plan month as yyyymm, such as 202611.',
          },
          'reason': _stringSchema('Why this move helps, in one sentence.'),
        },
        required: [
          'entityId',
          'fromEnvelopeId',
          'toEnvelopeId',
          'amountMinor',
          'month',
          'reason',
        ],
      ),
      _tool(
        name: 'propose_transaction_tax_category',
        description:
            "Propose setting one transaction line's tax category. This does "
            'not change the transaction; the user applies the proposal. '
            'The search_transactions tool reports the line ids.',
        properties: {
          'transactionLineId': _uuidSchema('The transaction line to code.'),
          'code': _stringSchema('The tax category code to set.'),
          'businessUsePercent': {
            'type': 'integer',
            'minimum': 0,
            'maximum': 100,
            'description': 'The business-use share, from 0 to 100 percent.',
          },
          'reason': _stringSchema('Why this category fits, in one sentence.'),
        },
        required: ['transactionLineId', 'code', 'reason'],
      ),
      _tool(
        name: 'propose_envelope_tax_category',
        description:
            "Propose setting one envelope's default tax category. This does "
            'not change the envelope; the user applies the proposal.',
        properties: {
          'envelopeId': _uuidSchema('The envelope to change.'),
          'code': _stringSchema('The tax category code to set as the default.'),
          'reason': _stringSchema('Why this category fits, in one sentence.'),
        },
        required: ['envelopeId', 'code', 'reason'],
      ),
    ],
  ];

  /// Runs one tool and returns a compact JSON string.
  ///
  /// A bad argument, an unknown tool or an unexpected failure becomes
  /// `{"error": "..."}` so the model can correct itself instead of ending the
  /// turn.
  Future<String> call(
    AgentToolContext context,
    String name,
    Map<String, Object?> args,
  ) async {
    try {
      return await _dispatch(context, name, args);
    } on ValidationException catch (error) {
      return _error(error.message);
    } on NotFoundException catch (error) {
      return _error(error.message);
    } on ForbiddenException catch (error) {
      return _error(error.message);
    } on TaxRulesUnavailableException catch (error) {
      return _error(error.message);
    } on FxRateUnavailableException catch (error) {
      return _error(error.message);
    } on FormatException catch (error) {
      return _error('The arguments were not valid: ${error.message}');
    } on AgentProviderUnavailableException catch (error) {
      return _error(error.message);
    } on Object catch (error, stackTrace) {
      _log.severe('Agent tool $name failed', error, stackTrace);
      return _error('The tool failed unexpectedly.');
    }
  }

  Future<String> _dispatch(
    AgentToolContext context,
    String name,
    Map<String, Object?> args,
  ) {
    if (_isProposeTool(name) && !context.canPropose) {
      throw ValidationException(
        message: 'The propose tools are not available.',
      );
    }
    return switch (name) {
      'list_entities' => _listEntities(context),
      'list_envelopes' => _listEnvelopes(context, args),
      'search_transactions' => _searchTransactions(context, args),
      'get_tax_report' => _getTaxReport(context, args),
      'list_tax_categories' => _listTaxCategories(context, args),
      'get_net_worth' => _getNetWorth(context, args),
      'propose_move_money' => _proposeMoveMoney(context, args),
      'propose_transaction_tax_category' => _proposeTransactionTaxCategory(
        context,
        args,
      ),
      'propose_envelope_tax_category' => _proposeEnvelopeTaxCategory(
        context,
        args,
      ),
      _ => Future.value(_error('Unknown tool "$name".')),
    };
  }

  static bool _isProposeTool(String name) => switch (name) {
    'propose_move_money' ||
    'propose_transaction_tax_category' ||
    'propose_envelope_tax_category' => true,
    _ => false,
  };

  Future<String> _listEntities(AgentToolContext context) async {
    final entities = await Entity.db.find(
      context.session,
      where: (t) => t.ownerId.equals(context.userId),
      orderByList: (t) => [t.sortOrder, t.id],
    );
    return _json({
      'entities': [
        for (final entity in entities)
          {
            'id': entity.id?.toString(),
            'name': entity.name,
            'kind': entity.kind.name,
            'countryCode': entity.countryCode,
            'baseCurrencyCode': entity.baseCurrencyCode,
            'isArchived': entity.archivedAt != null,
          },
      ],
    });
  }

  Future<String> _listEnvelopes(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final entityId = _requireUuid(args, 'entityId');
    final entity = await requireOwnedEntity(
      context.session,
      userId: context.userId,
      entityId: entityId,
    );
    final month = _optionalMonth(args, 'month') ?? _currentMonth(entity);

    final view = await BudgetMonthService.month(
      context.session,
      entityId: entityId,
      month: month,
    );

    final categoryNames = {
      for (final category in view.categories)
        if (category.id != null) category.id!: category.name,
    };

    return _json({
      'entityId': entityId.toString(),
      'entityName': entity.name,
      'month': month,
      'currencyCode': view.currencyCode,
      'readyToAssignMinor': view.summary.readyToAssignMinor,
      'incomeMinor': view.summary.incomeMinor,
      'assignedMinor': view.summary.allocatedMinor,
      'activityMinor': view.summary.activityMinor,
      'overspentLastMonthMinor': view.summary.overspentLastMonthMinor,
      'assignedInFutureMinor': view.summary.assignedInFutureMinor,
      'envelopes': [
        for (final envelope in view.envelopes)
          {
            'id': envelope.envelope.id?.toString(),
            'name': envelope.envelope.name,
            'category': categoryNames[envelope.envelope.categoryId],
            'goalUnderfundedMinor': envelope.goalUnderfundedMinor,
            'carryoverMinor': envelope.carryoverMinor,
            'assignedMinor': envelope.allocatedMinor,
            'activityMinor': envelope.activityMinor,
            'availableMinor': envelope.availableMinor,
          },
      ],
    });
  }

  Future<String> _searchTransactions(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final entityId = _requireUuid(args, 'entityId');
    await requireOwnedEntity(
      context.session,
      userId: context.userId,
      entityId: entityId,
    );
    final query = _optionalString(args, 'query');
    final from = _optionalDate(args, 'fromDate');
    final to = _optionalDate(args, 'toDate', exclusiveDay: true);
    final limit = _optionalInt(args, 'limit') ?? _defaultSearchLimit;
    if (limit < 1 || limit > _maxSearchLimit) {
      throw ValidationException(
        message: 'limit must be between 1 and $_maxSearchLimit.',
      );
    }

    final rows = await Transaction.db.find(
      context.session,
      where: (t) {
        var where = t.entityId.equals(entityId);
        if (query != null) {
          where =
              where &
              (t.description.ilike('%$query%') | t.memo.ilike('%$query%'));
        }
        if (from != null) {
          where = where & (t.date >= from);
        }
        if (to != null) {
          where = where & (t.date < to);
        }
        return where;
      },
      orderByList: (t) => [t.date.desc(), t.id.desc()],
      limit: limit,
    );

    // Amounts are in the account's currency; base amounts in the entity's.
    final accountIds = {for (final row in rows) row.accountId};
    final accountsById = accountIds.isEmpty
        ? const <UuidValue, Account>{}
        : {
            for (final account in await Account.db.find(
              context.session,
              where: (t) => t.id.inSet(accountIds),
            ))
              if (account.id != null) account.id!: account,
          };
    final baseCurrencyCode = (await Entity.db.findById(
      context.session,
      entityId,
    ))?.baseCurrencyCode;

    final transactionIds = {
      for (final row in rows)
        if (row.id != null) row.id!,
    };
    final linesByTransaction = <UuidValue, List<TransactionLine>>{};
    if (transactionIds.isNotEmpty) {
      for (final line in await TransactionLine.db.find(
        context.session,
        where: (t) => t.transactionId.inSet(transactionIds),
        orderByList: (t) => [t.transactionId, t.sortOrder],
      )) {
        linesByTransaction.putIfAbsent(line.transactionId, () => []).add(line);
      }
    }

    return _json({
      'count': rows.length,
      'baseCurrencyCode': baseCurrencyCode,
      'transactions': [
        for (final row in rows)
          {
            'id': row.id?.toString(),
            'description': row.description,
            'amountMinor': row.amountMinor,
            'currencyCode': accountsById[row.accountId]?.currencyCode,
            'baseAmountMinor': row.baseAmountMinor,
            'date': row.date.toIso8601String(),
            'status': row.status.name,
            'memo': row.memo,
            'lines': [
              for (final line
                  in linesByTransaction[row.id!] ?? const <TransactionLine>[])
                {
                  'id': line.id?.toString(),
                  'amountMinor': line.amountMinor,
                  'envelopeId': line.envelopeId?.toString(),
                  'taxCategoryCode': line.taxCategoryCode,
                  'businessUsePercent': line.businessUsePercent,
                },
            ],
          },
      ],
    });
  }

  Future<String> _getTaxReport(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final entityId = _requireUuid(args, 'entityId');
    await requireOwnedEntity(
      context.session,
      userId: context.userId,
      entityId: entityId,
    );
    final startYear = _optionalInt(args, 'startYear');
    final report = await TaxService.report(
      context.session,
      entityId: entityId,
      startYear: startYear,
    );
    return _json(report.toJson());
  }

  Future<String> _listTaxCategories(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final entityId = _requireUuid(args, 'entityId');
    await requireOwnedEntity(
      context.session,
      userId: context.userId,
      entityId: entityId,
    );
    final categories = await TaxService.listCategories(
      context.session,
      entityId: entityId,
    );
    return _json({
      'categories': [for (final category in categories) category.toJson()],
    });
  }

  Future<String> _getNetWorth(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final entityId = _optionalUuid(args, 'entityId');
    if (entityId != null) {
      await requireOwnedEntity(
        context.session,
        userId: context.userId,
        entityId: entityId,
      );
    }
    final currencyCode = _optionalString(args, 'currencyCode');
    final view = await NetWorthService.current(
      context.session,
      entityIds: entityId == null ? null : [entityId],
      currencyCode: currencyCode,
    );
    return _json({
      'currencyCode': view.currencyCode,
      'asOf': view.asOf.toIso8601String(),
      'netWorthMinor': view.netWorthMinor,
      'assetsMinor': view.assetsMinor,
      'liabilitiesMinor': view.liabilitiesMinor,
      'isComplete': view.isComplete,
      'missingCurrencyCodes': view.missingCurrencyCodes,
      'hasStaleRates': view.hasStaleRates,
      'entities': [
        for (final row in view.entities)
          {
            'entityId': row.entityId.toString(),
            'name': row.name,
            'kind': row.kind.name,
            'netWorthMinor': row.netWorthMinor,
          },
      ],
      'currencies': [
        for (final row in view.currencies)
          {
            'currencyCode': row.currencyCode,
            'nativeMinor': row.nativeMinor,
            'convertedMinor': row.convertedMinor,
            'fxRate': row.fxRate,
            'isStale': row.isStale,
          },
      ],
    });
  }

  Future<String> _proposeMoveMoney(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final entityId = _requireUuid(args, 'entityId');
    final fromEnvelopeId = _requireUuid(args, 'fromEnvelopeId');
    final toEnvelopeId = _requireUuid(args, 'toEnvelopeId');
    final amountMinor = _requireInt(args, 'amountMinor');
    final month = _requireMonth(args, 'month');
    final reason = _requireString(args, 'reason');

    if (amountMinor <= 0) {
      throw ValidationException(
        message: 'amountMinor must be greater than zero.',
      );
    }
    if (fromEnvelopeId == toEnvelopeId) {
      throw ValidationException(
        message: 'fromEnvelopeId and toEnvelopeId must be different.',
      );
    }

    final entity = await requireOwnedEntity(
      context.session,
      userId: context.userId,
      entityId: entityId,
    );
    final fromEnvelope = await _requireEnvelopeInEntity(
      context,
      entityId: entityId,
      envelopeId: fromEnvelopeId,
    );
    final toEnvelope = await _requireEnvelopeInEntity(
      context,
      entityId: entityId,
      envelopeId: toEnvelopeId,
    );

    final proposal = await _insertProposal(
      context,
      entityId: entityId,
      kind: AgentProposalKind.moveMoney,
      payload: {
        'entityId': entityId.toString(),
        'fromEnvelopeId': fromEnvelopeId.toString(),
        'toEnvelopeId': toEnvelopeId.toString(),
        'amountMinor': amountMinor,
        'month': month,
        'reason': reason,
      },
      summary:
          'Move ${_formatAmount(amountMinor, entity.baseCurrencyCode)} from '
          '${fromEnvelope.name} to ${toEnvelope.name} in $month.',
    );
    return _proposalResult(proposal);
  }

  Future<String> _proposeTransactionTaxCategory(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final transactionLineId = _requireUuid(args, 'transactionLineId');
    final code = _requireString(args, 'code');
    final businessUsePercent = _optionalInt(args, 'businessUsePercent');
    final reason = _requireString(args, 'reason');

    if (businessUsePercent != null &&
        (businessUsePercent < 0 || businessUsePercent > 100)) {
      throw ValidationException(
        message: 'businessUsePercent must be between 0 and 100.',
      );
    }

    final line = await TransactionLine.db.findById(
      context.session,
      transactionLineId,
    );
    if (line == null) {
      throw NotFoundException(message: 'Transaction line not found');
    }
    final transaction = await Transaction.db.findById(
      context.session,
      line.transactionId,
    );
    if (transaction == null) {
      throw NotFoundException(message: 'Transaction not found');
    }
    await requireOwnedEntity(
      context.session,
      userId: context.userId,
      entityId: transaction.entityId,
    );
    await _requireTaxCategory(
      context,
      entityId: transaction.entityId,
      code: code,
    );

    final percentText = businessUsePercent == null
        ? ''
        : ' at $businessUsePercent% business use';
    final proposal = await _insertProposal(
      context,
      entityId: transaction.entityId,
      kind: AgentProposalKind.setTransactionTaxCategory,
      payload: {
        'entityId': transaction.entityId.toString(),
        'transactionLineId': transactionLineId.toString(),
        'code': code,
        'businessUsePercent': businessUsePercent,
        'reason': reason,
      },
      summary:
          'Set tax category "$code"$percentText on '
          '"${transaction.description}".',
    );
    return _proposalResult(proposal);
  }

  Future<String> _proposeEnvelopeTaxCategory(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final envelopeId = _requireUuid(args, 'envelopeId');
    final code = _requireString(args, 'code');
    final reason = _requireString(args, 'reason');

    final envelope = await Envelope.db.findById(context.session, envelopeId);
    if (envelope == null) {
      throw NotFoundException(message: 'Envelope not found');
    }
    await requireOwnedEntity(
      context.session,
      userId: context.userId,
      entityId: envelope.entityId,
    );
    await _requireTaxCategory(
      context,
      entityId: envelope.entityId,
      code: code,
    );

    final proposal = await _insertProposal(
      context,
      entityId: envelope.entityId,
      kind: AgentProposalKind.setEnvelopeTaxCategory,
      payload: {
        'entityId': envelope.entityId.toString(),
        'envelopeId': envelopeId.toString(),
        'code': code,
        'reason': reason,
      },
      summary:
          'Set the default tax category "$code" on '
          '"${envelope.name}".',
    );
    return _proposalResult(proposal);
  }

  Future<Envelope> _requireEnvelopeInEntity(
    AgentToolContext context, {
    required UuidValue entityId,
    required UuidValue envelopeId,
  }) async {
    final envelope = await Envelope.db.findById(context.session, envelopeId);
    if (envelope == null || envelope.entityId != entityId) {
      throw NotFoundException(message: 'Envelope not found in this entity');
    }
    return envelope;
  }

  Future<void> _requireTaxCategory(
    AgentToolContext context, {
    required UuidValue entityId,
    required String code,
  }) async {
    final categories = await TaxService.listCategories(
      context.session,
      entityId: entityId,
    );
    if (!categories.any((category) => category.code == code)) {
      throw ValidationException(message: 'Unknown tax category "$code".');
    }
  }

  Future<AgentProposal> _insertProposal(
    AgentToolContext context, {
    required UuidValue entityId,
    required AgentProposalKind kind,
    required Map<String, Object?> payload,
    required String summary,
  }) => AgentProposal.db.insertRow(
    context.session,
    AgentProposal(
      userId: context.userId,
      entityId: entityId,
      conversationId: context.conversationId,
      kind: kind,
      payloadJson: jsonEncode(payload),
      summary: summary,
      status: AgentProposalStatus.pending,
    ),
  );

  static String _proposalResult(AgentProposal proposal) => _json({
    'proposalId': proposal.id?.toString(),
    'summary': proposal.summary,
    'status': proposal.status.name,
  });

  static int _currentMonth(Entity entity) =>
      MonthKey.fromDate(EntityClock.today(entity));

  static String _formatAmount(int minor, String currencyCode) {
    final currency = CurrencyCode.tryParse(currencyCode);
    final decimals = currency?.decimals ?? 2;
    final sign = minor < 0 ? '-' : '';
    final magnitude = minor.abs();
    if (decimals == 0) return '$sign$magnitude $currencyCode';
    final divisor = math.pow(10, decimals).toInt();
    final whole = magnitude ~/ divisor;
    final fraction = (magnitude % divisor).toString().padLeft(decimals, '0');
    return '$sign$whole.$fraction $currencyCode';
  }

  static Map<String, Object?> _tool({
    required String name,
    required String description,
    required Map<String, Object?> properties,
    List<String> required = const [],
  }) => {
    'type': 'function',
    'function': {
      'name': name,
      'description': description,
      'parameters': {
        'type': 'object',
        'properties': properties,
        'required': required,
        'additionalProperties': false,
      },
    },
  };

  static Map<String, Object?> _uuidSchema(String description) => {
    'type': 'string',
    'format': 'uuid',
    'description': description,
  };

  static Map<String, Object?> _stringSchema(String description) => {
    'type': 'string',
    'description': description,
  };

  static String _json(Object? value) => jsonEncode(value);

  static String _error(String message) => _json({'error': message});

  static String _requireString(Map<String, Object?> args, String key) {
    final value = args[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    throw ValidationException(
      message: 'Argument "$key" must be a non-empty string.',
    );
  }

  static String? _optionalString(Map<String, Object?> args, String key) {
    final value = args[key];
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    throw ValidationException(message: 'Argument "$key" must be a string.');
  }

  static int _requireInt(Map<String, Object?> args, String key) {
    final value = _optionalInt(args, key);
    if (value == null) {
      throw ValidationException(message: 'Argument "$key" is required.');
    }
    return value;
  }

  static int? _optionalInt(Map<String, Object?> args, String key) {
    final value = args[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    throw ValidationException(message: 'Argument "$key" must be an integer.');
  }

  static UuidValue _requireUuid(Map<String, Object?> args, String key) {
    final value = _optionalUuid(args, key);
    if (value == null) {
      throw ValidationException(message: 'Argument "$key" is required.');
    }
    return value;
  }

  static UuidValue? _optionalUuid(Map<String, Object?> args, String key) {
    final value = _optionalString(args, key);
    if (value == null) return null;
    try {
      return UuidValue.withFormatValidation(value);
    } on FormatException {
      throw ValidationException(message: 'Argument "$key" must be a UUID.');
    }
  }

  static DateTime? _optionalDate(
    Map<String, Object?> args,
    String key, {
    bool exclusiveDay = false,
  }) {
    final value = _optionalString(args, key);
    if (value == null) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw ValidationException(
        message: 'Argument "$key" must be an ISO 8601 date.',
      );
    }
    if (exclusiveDay && value.length == 10) {
      return DateTime.utc(parsed.year, parsed.month, parsed.day + 1);
    }
    if (value.length == 10) {
      // A plain date is a civil date: UTC midnight, like the stored column.
      return DateTime.utc(parsed.year, parsed.month, parsed.day);
    }
    return parsed.toUtc();
  }

  static int _requireMonth(Map<String, Object?> args, String key) {
    final value = _requireInt(args, key);
    if (!MonthKey.isValid(value)) {
      throw ValidationException(message: 'Argument "$key" must be yyyymm.');
    }
    return value;
  }

  static int? _optionalMonth(Map<String, Object?> args, String key) {
    final value = _optionalInt(args, key);
    if (value == null) return null;
    if (!MonthKey.isValid(value)) {
      throw ValidationException(message: 'Argument "$key" must be yyyymm.');
    }
    return value;
  }
}
