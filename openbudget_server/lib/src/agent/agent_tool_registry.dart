import 'dart:convert';
import 'dart:math' as math;

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_access.dart';
import 'package:openbudget_server/src/agent/agent_tax_reports.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
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
      name: 'list_budgets',
      description:
          'List the budgets the user owns, with their currency. Start here '
          'when you do not know which budget the user means.',
      properties: const {},
    ),
    _tool(
      name: 'list_envelopes',
      description:
          "List the envelopes in one budget with this month's assigned, "
          'carryover, activity and available amounts in minor units.',
      properties: {
        'budgetId': _uuidSchema('The budget to read.'),
      },
      required: ['budgetId'],
    ),
    _tool(
      name: 'search_transactions',
      description:
          "Search one budget's transactions by text, date range or both. "
          'Returns at most 50 matches, newest first.',
      properties: {
        'budgetId': _uuidSchema('The budget to search.'),
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
      required: ['budgetId'],
    ),
    _tool(
      name: 'get_tax_report',
      description:
          "Compute the budget's tax report for a tax year. Cite the report's "
          'sources and assumptions in the answer.',
      properties: {
        'budgetId': _uuidSchema('The budget whose tax position to read.'),
        'startYear': {
          'type': 'integer',
          'minimum': 1900,
          'maximum': 2200,
          'description':
              'The calendar year the tax year starts in. Omit for the '
              'current tax year.',
        },
      },
      required: ['budgetId'],
    ),
    _tool(
      name: 'list_tax_categories',
      description:
          'List the tax category codes available to this budget, with their '
          'labels and where they land on the return.',
      properties: {
        'budgetId': _uuidSchema('The budget whose categories to list.'),
      },
      required: ['budgetId'],
    ),
    if (canPropose) ...[
      _tool(
        name: 'propose_move_money',
        description:
            'Propose moving money between two envelopes in one month. This '
            'does not move anything; the user applies the proposal.',
        properties: {
          'budgetId': _uuidSchema('The budget to change.'),
          'fromEnvelopeId': _uuidSchema('The envelope to take money from.'),
          'toEnvelopeId': _uuidSchema('The envelope to give money to.'),
          'amountMinor': {
            'type': 'integer',
            'minimum': 1,
            'description':
                'How much to move, in minor units of the budget '
                'currency.',
          },
          'month': {
            'type': 'string',
            'pattern': r'^\d{4}-(0[1-9]|1[0-2])$',
            'description': 'The budget month, such as 2026-11.',
          },
          'reason': _stringSchema('Why this move helps, in one sentence.'),
        },
        required: [
          'budgetId',
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
            "Propose changing one transaction's tax category. This does not "
            'change the transaction; the user applies the proposal.',
        properties: {
          'transactionId': _uuidSchema('The transaction to recategorise.'),
          'code': _stringSchema('The tax category code to set.'),
          'businessUsePercent': {
            'type': 'integer',
            'minimum': 0,
            'maximum': 100,
            'description': 'The business-use share, from 0 to 100 percent.',
          },
          'reason': _stringSchema('Why this category fits, in one sentence.'),
        },
        required: ['transactionId', 'code', 'reason'],
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
    } on TaxRateUnavailableException catch (error) {
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
      'list_budgets' => _listBudgets(context),
      'list_envelopes' => _listEnvelopes(context, args),
      'search_transactions' => _searchTransactions(context, args),
      'get_tax_report' => _getTaxReport(context, args),
      'list_tax_categories' => _listTaxCategories(context, args),
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

  Future<String> _listBudgets(AgentToolContext context) async {
    final budgets = await Budget.db.find(
      context.session,
      where: (t) => t.ownerId.equals(context.userId),
      orderBy: (t) => t.createdAt.desc(),
    );
    return _json({
      'budgets': [
        for (final budget in budgets)
          {
            'id': budget.id?.toString(),
            'name': budget.name,
            'currencyCode': budget.currencyCode,
            'displayCurrencyCode': budget.displayCurrencyCode,
          },
      ],
    });
  }

  Future<String> _listEnvelopes(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final budgetId = _requireUuid(args, 'budgetId');
    final budget = await requireOwnedBudget(
      context.session,
      userId: context.userId,
      budgetId: budgetId,
    );

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1);

    final categories = await Category.db.find(
      context.session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.sortOrder,
    );
    final categoryNames = {
      for (final category in categories)
        if (category.id != null) category.id!: category.name,
    };
    final categoryIds = categoryNames.keys.toSet();
    final envelopes = categoryIds.isEmpty
        ? <Envelope>[]
        : await Envelope.db.find(
            context.session,
            where: (t) => t.categoryId.inSet(categoryIds),
            orderBy: (t) => t.sortOrder,
          );

    final allocations = await MonthlyAllocation.db.find(
      context.session,
      where: (t) =>
          t.budgetId.equals(budgetId) &
          t.year.equals(now.year) &
          t.month.equals(now.month),
    );
    final allocationByEnvelope = {
      for (final allocation in allocations) allocation.envelopeId: allocation,
    };

    final transactions = await Transaction.db.find(
      context.session,
      where: (t) =>
          t.budgetId.equals(budgetId) &
          (t.transactionDate >= monthStart) &
          (t.transactionDate < monthEnd),
    );
    final activityByEnvelope = <UuidValue, int>{};
    for (final transaction in transactions) {
      final envelopeId = transaction.envelopeId;
      if (envelopeId == null) continue;
      activityByEnvelope[envelopeId] =
          (activityByEnvelope[envelopeId] ?? 0) + transaction.amountCents;
    }

    return _json({
      'budgetId': budgetId.toString(),
      'budgetName': budget.name,
      'currencyCode': budget.currencyCode,
      'month': _monthLabel(now.year, now.month),
      'envelopes': [
        for (final envelope in envelopes)
          _envelopeView(
            envelope,
            categoryName: categoryNames[envelope.categoryId],
            allocation: allocationByEnvelope[envelope.id],
            activityMinor: activityByEnvelope[envelope.id] ?? 0,
          ),
      ],
    });
  }

  static Map<String, Object?> _envelopeView(
    Envelope envelope, {
    required String? categoryName,
    required MonthlyAllocation? allocation,
    required int activityMinor,
  }) {
    final assigned = allocation?.allocatedCents ?? 0;
    final carryover = allocation?.carryoverCents ?? 0;
    return {
      'id': envelope.id?.toString(),
      'name': envelope.name,
      'category': categoryName,
      'currencyCode': envelope.currencyCode,
      'assignedMinor': assigned,
      'carryoverMinor': carryover,
      'activityMinor': activityMinor,
      'availableMinor': assigned + carryover + activityMinor,
    };
  }

  Future<String> _searchTransactions(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final budgetId = _requireUuid(args, 'budgetId');
    await requireOwnedBudget(
      context.session,
      userId: context.userId,
      budgetId: budgetId,
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
        var where = t.budgetId.equals(budgetId);
        if (query != null) {
          where =
              where &
              (t.description.ilike('%$query%') | t.memo.ilike('%$query%'));
        }
        if (from != null) {
          where = where & (t.transactionDate >= from);
        }
        if (to != null) {
          where = where & (t.transactionDate < to);
        }
        return where;
      },
      orderBy: (t) => t.transactionDate.desc(),
      limit: limit,
    );

    final envelopeIds = {
      for (final row in rows)
        if (row.envelopeId != null) row.envelopeId!,
    };
    final envelopeNames = envelopeIds.isEmpty
        ? const <UuidValue, String>{}
        : {
            for (final envelope in await Envelope.db.find(
              context.session,
              where: (t) => t.id.inSet(envelopeIds),
            ))
              if (envelope.id != null) envelope.id!: envelope.name,
          };

    return _json({
      'count': rows.length,
      'transactions': [
        for (final row in rows)
          {
            'id': row.id?.toString(),
            'description': row.description,
            'amountMinor': row.amountCents,
            'currencyCode': row.currencyCode,
            'date': row.transactionDate.toIso8601String(),
            'envelopeId': row.envelopeId?.toString(),
            'envelope': envelopeNames[row.envelopeId],
            'memo': row.memo,
            'taxCategoryCode': row.taxCategoryCode,
            'businessUsePercent': row.businessUsePercent,
          },
      ],
    });
  }

  Future<String> _getTaxReport(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final budgetId = _requireUuid(args, 'budgetId');
    await requireOwnedBudget(
      context.session,
      userId: context.userId,
      budgetId: budgetId,
    );
    final startYear = _optionalInt(args, 'startYear');
    final report = await AgentTaxReports.report(
      context.session,
      budgetId: budgetId,
      startYear: startYear,
    );
    return _json(report.toJson());
  }

  Future<String> _listTaxCategories(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final budgetId = _requireUuid(args, 'budgetId');
    await requireOwnedBudget(
      context.session,
      userId: context.userId,
      budgetId: budgetId,
    );
    final categories = await AgentTaxReports.categories(
      context.session,
      budgetId: budgetId,
    );
    return _json({
      'categories': [for (final category in categories) category.toJson()],
    });
  }

  Future<String> _proposeMoveMoney(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final budgetId = _requireUuid(args, 'budgetId');
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

    final budget = await requireOwnedBudget(
      context.session,
      userId: context.userId,
      budgetId: budgetId,
    );
    final fromEnvelope = await _requireEnvelopeInBudget(
      context,
      budgetId: budgetId,
      envelopeId: fromEnvelopeId,
    );
    final toEnvelope = await _requireEnvelopeInBudget(
      context,
      budgetId: budgetId,
      envelopeId: toEnvelopeId,
    );

    final proposal = await _insertProposal(
      context,
      budgetId: budgetId,
      kind: AgentProposalKind.moveMoney,
      payload: {
        'budgetId': budgetId.toString(),
        'fromEnvelopeId': fromEnvelopeId.toString(),
        'toEnvelopeId': toEnvelopeId.toString(),
        'amountMinor': amountMinor,
        'month': _monthLabel(month.$1, month.$2),
        'reason': reason,
      },
      summary:
          'Move ${_formatAmount(amountMinor, budget.currencyCode)} from '
          '${fromEnvelope.name} to ${toEnvelope.name} in '
          '${_monthLabel(month.$1, month.$2)}.',
    );
    return _proposalResult(proposal);
  }

  Future<String> _proposeTransactionTaxCategory(
    AgentToolContext context,
    Map<String, Object?> args,
  ) async {
    final transactionId = _requireUuid(args, 'transactionId');
    final code = _requireString(args, 'code');
    final businessUsePercent = _optionalInt(args, 'businessUsePercent');
    final reason = _requireString(args, 'reason');

    if (businessUsePercent != null &&
        (businessUsePercent < 0 || businessUsePercent > 100)) {
      throw ValidationException(
        message: 'businessUsePercent must be between 0 and 100.',
      );
    }

    final transaction = await Transaction.db.findById(
      context.session,
      transactionId,
    );
    if (transaction == null) {
      throw NotFoundException(message: 'Transaction not found');
    }
    await requireOwnedBudget(
      context.session,
      userId: context.userId,
      budgetId: transaction.budgetId,
    );
    await _requireTaxCategory(
      context,
      budgetId: transaction.budgetId,
      code: code,
    );

    final percentText = businessUsePercent == null
        ? ''
        : ' at $businessUsePercent% business use';
    final proposal = await _insertProposal(
      context,
      budgetId: transaction.budgetId,
      kind: AgentProposalKind.setTransactionTaxCategory,
      payload: {
        'budgetId': transaction.budgetId.toString(),
        'transactionId': transactionId.toString(),
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
    final category = await Category.db.findById(
      context.session,
      envelope.categoryId,
    );
    if (category == null) {
      throw NotFoundException(message: 'Category not found');
    }
    await requireOwnedBudget(
      context.session,
      userId: context.userId,
      budgetId: category.budgetId,
    );
    await _requireTaxCategory(
      context,
      budgetId: category.budgetId,
      code: code,
    );

    final proposal = await _insertProposal(
      context,
      budgetId: category.budgetId,
      kind: AgentProposalKind.setEnvelopeTaxCategory,
      payload: {
        'budgetId': category.budgetId.toString(),
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

  Future<Envelope> _requireEnvelopeInBudget(
    AgentToolContext context, {
    required UuidValue budgetId,
    required UuidValue envelopeId,
  }) async {
    final envelope = await Envelope.db.findById(context.session, envelopeId);
    if (envelope == null) {
      throw NotFoundException(message: 'Envelope not found');
    }
    final category = await Category.db.findById(
      context.session,
      envelope.categoryId,
    );
    if (category == null || category.budgetId != budgetId) {
      throw NotFoundException(message: 'Envelope not found in this budget');
    }
    return envelope;
  }

  Future<void> _requireTaxCategory(
    AgentToolContext context, {
    required UuidValue budgetId,
    required String code,
  }) async {
    final categories = await AgentTaxReports.categories(
      context.session,
      budgetId: budgetId,
    );
    if (!categories.any((category) => category.code == code)) {
      throw ValidationException(message: 'Unknown tax category "$code".');
    }
  }

  Future<AgentProposal> _insertProposal(
    AgentToolContext context, {
    required UuidValue budgetId,
    required AgentProposalKind kind,
    required Map<String, Object?> payload,
    required String summary,
  }) => AgentProposal.db.insertRow(
    context.session,
    AgentProposal(
      userId: context.userId,
      budgetId: budgetId,
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

  static String _monthLabel(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

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
    final value = _requireString(args, key);
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
      return DateTime(parsed.year, parsed.month, parsed.day + 1);
    }
    return parsed;
  }

  static (int, int) _requireMonth(
    Map<String, Object?> args,
    String key,
  ) {
    final value = _requireString(args, key);
    final match = RegExp(r'^(\d{4})-(0[1-9]|1[0-2])$').firstMatch(value);
    if (match == null) {
      throw ValidationException(message: 'Argument "$key" must be YYYY-MM.');
    }
    return (int.parse(match.group(1)!), int.parse(match.group(2)!));
  }
}
