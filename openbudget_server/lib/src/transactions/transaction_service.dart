import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';

/// Reads and writes transactions through the single [TransactionWriter].
///
/// Every method crosses [EntityAccess] directly or through the writer, so a
/// transaction is visible only to the owner of its entity. The service never
/// assigns a cached balance or resolves an FX rate itself: both belong to the
/// writer, which keeps metadata edits from re-pricing or re-balancing history.
abstract final class TransactionService {
  /// The largest page `list` returns, matching the documented 1-200 range.
  static const maxPageLimit = 200;

  /// The largest bulk status or flag request.
  static const int maxBulkIds = TransactionWriter.maxBulkTransactionIds;

  /// The most matches [findDuplicates] returns.
  static const maxDuplicateMatches = 20;

  static const _maxCursorLength = 100;
  static const _cursorPattern = r'^[A-Za-z0-9_-]+$';
  static const _cursorDatePattern = r'^\d{4}-\d{2}-\d{2}$';

  /// Creates a transaction header, its lines and its balance movement.
  static Future<TransactionView> create(
    Session session,
    TransactionInput input,
  ) => TransactionWriter.create(session, input);

  /// Loads one owned transaction with its lines and transfer peer.
  static Future<TransactionView> get(
    Session session,
    UuidValue transactionId,
  ) => TransactionWriter.get(session, transactionId);

  /// Replaces a transaction and its lines.
  static Future<TransactionView> update(
    Session session,
    UuidValue transactionId,
    TransactionInput input,
  ) => TransactionWriter.update(session, transactionId, input);

  /// Deletes a transaction, both legs of a transfer, and their balances.
  static Future<void> delete(Session session, UuidValue transactionId) =>
      TransactionWriter.delete(session, transactionId);

  /// Sets one status on a page of owned transactions.
  static Future<int> setStatus(
    Session session,
    List<UuidValue> transactionIds,
    TransactionStatus status,
  ) => TransactionWriter.setStatus(session, transactionIds, status);

  /// Sets or clears one flag on a page of owned transactions.
  static Future<int> setFlag(
    Session session,
    List<UuidValue> transactionIds,
    TransactionFlag? flag,
  ) => TransactionWriter.setFlag(session, transactionIds, flag);

  /// Creates [from leg, to leg] and their link atomically.
  static Future<List<TransactionView>> createTransfer(
    Session session,
    TransferInput input,
  ) => TransactionWriter.createTransfer(session, input);

  /// Replaces both legs of an existing transfer atomically.
  static Future<List<TransactionView>> updateTransfer(
    Session session,
    UuidValue transferId,
    TransferInput input,
  ) => TransactionWriter.updateTransfer(session, transferId, input);

  /// Lists one keyset page of an owned entity's transactions.
  ///
  /// Rows are newest first by `(date desc, id desc)`. Every filter is
  /// inclusive where it names a boundary. The cursor is opaque base64url of
  /// `yyyy-mm-dd|uuid`, and `nextCursor` is null on the last page.
  static Future<TransactionPage> list(
    Session session,
    TransactionQuery query,
  ) async {
    if (query.limit < 1 || query.limit > maxPageLimit) {
      throw ValidationException(
        message: 'limit must be between 1 and $maxPageLimit',
      );
    }
    _requireCivilDate(query.fromDate, 'fromDate');
    _requireCivilDate(query.toDate, 'toDate');
    final cursor = _decodeCursor(query.cursor);

    await EntityAccess.requireOwned(session, query.entityId);
    await _requireFilterReferences(session, query);

    final search = _likePattern(query.search);
    final ids = await _pageIds(session, query, cursor, search);
    final hasMore = ids.length > query.limit;
    final pageIds = hasMore ? ids.sublist(0, query.limit) : ids;
    if (pageIds.isEmpty) {
      return TransactionPage(items: const []);
    }

    final rows = await model.Transaction.db.find(
      session,
      where: (t) => t.id.inSet(pageIds.toSet()),
    );
    final rowsById = {for (final row in rows) row.id!: row};
    final ordered = [
      for (final id in pageIds)
        if (rowsById[id] != null) rowsById[id]!,
    ];
    if (ordered.isEmpty) {
      return TransactionPage(items: const []);
    }

    final items = await TransactionWriter.views(session, ordered);
    final nextCursor = hasMore && ordered.length == pageIds.length
        ? _encodeCursor(ordered.last.date, ordered.last.id!)
        : null;
    return TransactionPage(items: items, nextCursor: nextCursor);
  }

  /// Finds transactions in [accountId] with the same signed amount and a date
  /// within three civil days of [date].
  ///
  /// The result is bounded by [maxDuplicateMatches], so a review screen can
  /// scan a suspicious row without an unbounded transaction list.
  static Future<List<TransactionView>> findDuplicates(
    Session session,
    UuidValue accountId,
    DateTime date,
    int amountMinor,
  ) async {
    if (!isCivilDate(date)) {
      throw ValidationException(message: 'date must be a UTC calendar date');
    }
    final account = await Account.db.findById(session, accountId);
    if (account == null) {
      throw NotFoundException(message: 'Account not found');
    }
    await EntityAccess.requireOwned(session, account.entityId);

    final rows = await model.Transaction.db.find(
      session,
      where: (t) =>
          t.accountId.equals(accountId) &
          t.amountMinor.equals(amountMinor) &
          (t.date >= date.subtract(const Duration(days: 3))) &
          (t.date <= date.add(const Duration(days: 3))),
      orderByList: (t) => [t.date.desc(), t.id.desc()],
      limit: maxDuplicateMatches,
    );
    return TransactionWriter.views(session, rows);
  }

  static Future<void> _requireFilterReferences(
    Session session,
    TransactionQuery query,
  ) async {
    final accountId = query.accountId;
    if (accountId != null) {
      final account = await Account.db.findById(session, accountId);
      if (account == null || account.entityId != query.entityId) {
        throw NotFoundException(message: 'Account not found');
      }
    }

    final envelopeId = query.envelopeId;
    if (envelopeId != null) {
      final envelope = await Envelope.db.findById(session, envelopeId);
      if (envelope == null || envelope.entityId != query.entityId) {
        throw NotFoundException(message: 'Envelope not found');
      }
    }

    final payeeId = query.payeeId;
    if (payeeId != null) {
      final payee = await Payee.db.findById(session, payeeId);
      if (payee == null || payee.entityId != query.entityId) {
        throw NotFoundException(message: 'Payee not found');
      }
    }
  }

  /// One query selects the page's ids, so ownership and every filter are
  /// applied before a row is loaded. Values are named parameters; only the
  /// sort order and predicate shape are fixed SQL.
  static Future<List<UuidValue>> _pageIds(
    Session session,
    TransactionQuery query,
    _Cursor? cursor,
    String? search,
  ) async {
    final rows = await session.db.unsafeQuery(
      r'''
SELECT t.id::text
FROM "transaction" t
JOIN account a ON a.id = t."accountId"
LEFT JOIN payee p ON p.id = t."payeeId"
WHERE t."entityId" = @entityId::uuid
  AND (@accountId::uuid IS NULL OR t."accountId" = @accountId::uuid)
  AND (@envelopeId::uuid IS NULL OR EXISTS (
    SELECT 1 FROM transaction_line l
    WHERE l."transactionId" = t.id
      AND l."envelopeId" = @envelopeId::uuid))
  AND (@payeeId::uuid IS NULL OR t."payeeId" = @payeeId::uuid)
  AND (@fromDate::timestamp IS NULL OR t.date >= @fromDate::timestamp)
  AND (@toDate::timestamp IS NULL OR t.date <= @toDate::timestamp)
  AND (@status::text IS NULL OR t.status = @status::text)
  AND (@search::text IS NULL
    OR t.description ILIKE @search::text ESCAPE E'\\'
    OR t.memo ILIKE @search::text ESCAPE E'\\'
    OR p.name ILIKE @search::text ESCAPE E'\\')
  AND (
    @uncategorizedOnly::boolean = false
    OR (
      a."onBudget"
      AND EXISTS (
        SELECT 1 FROM transaction_line l
        WHERE l."transactionId" = t.id
          AND l."envelopeId" IS NULL
          AND l."amountMinor" < 0)
      AND NOT EXISTS (
        SELECT 1
        FROM transfer tf
        JOIN "transaction" peer ON peer.id = CASE
          WHEN tf."fromTransactionId" = t.id THEN tf."toTransactionId"
          ELSE tf."fromTransactionId"
        END
        JOIN account pa ON pa.id = peer."accountId"
        WHERE (tf."fromTransactionId" = t.id OR tf."toTransactionId" = t.id)
          AND peer."entityId" = t."entityId"
          AND pa."onBudget")
    )
  )
  AND (@cursorDate::timestamp IS NULL
    OR t.date < @cursorDate::timestamp
    OR (t.date = @cursorDate::timestamp AND t.id < @cursorId::uuid))
ORDER BY t.date DESC, t.id DESC
LIMIT @limit::integer
''',
      parameters: QueryParameters.named({
        'entityId': query.entityId.toString(),
        'accountId': query.accountId?.toString(),
        'envelopeId': query.envelopeId?.toString(),
        'payeeId': query.payeeId?.toString(),
        'fromDate': query.fromDate,
        'toDate': query.toDate,
        'status': query.status?.name,
        'search': search,
        'uncategorizedOnly': query.uncategorizedOnly,
        'cursorDate': cursor?.date,
        'cursorId': cursor?.id.toString(),
        'limit': query.limit + 1,
      }),
    );
    return [for (final row in rows) UuidValue.fromString(row[0] as String)];
  }

  /// Escapes SQL `LIKE` metacharacters so a user's `%`, `_` or `\` matches
  /// itself. The surrounding `%` are the only wildcards.
  static String? _likePattern(String? search) {
    if (search == null || search.isEmpty) return null;
    final escaped = search
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    return '%$escaped%';
  }

  static _Cursor? _decodeCursor(String? raw) {
    if (raw == null) return null;
    if (raw.isEmpty ||
        raw.length > _maxCursorLength ||
        !RegExp(_cursorPattern).hasMatch(raw)) {
      throw ValidationException(message: 'Invalid transaction cursor');
    }

    final String decoded;
    try {
      decoded = utf8.decode(base64Url.decode(base64Url.normalize(raw)));
    } on FormatException {
      throw ValidationException(message: 'Invalid transaction cursor');
    }
    if (decoded.length != 47 || decoded[10] != '|') {
      throw ValidationException(message: 'Invalid transaction cursor');
    }

    final dateText = decoded.substring(0, 10);
    if (!RegExp(_cursorDatePattern).hasMatch(dateText)) {
      throw ValidationException(message: 'Invalid transaction cursor');
    }
    final date = _parseCursorDate(dateText);
    if (date == null) {
      throw ValidationException(message: 'Invalid transaction cursor');
    }

    final UuidValue id;
    try {
      id = UuidValue.withValidation(decoded.substring(11));
    } on FormatException {
      throw ValidationException(message: 'Invalid transaction cursor');
    }
    return _Cursor(date, id);
  }

  static String _encodeCursor(DateTime date, UuidValue id) {
    final text =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}|${id.uuid}';
    return base64Url.encode(utf8.encode(text)).replaceAll('=', '');
  }

  /// Parses the cursor's civil day without throwing for an out-of-range value.
  static DateTime? _parseCursorDate(String text) {
    final year = int.parse(text.substring(0, 4));
    final month = int.parse(text.substring(5, 7));
    final day = int.parse(text.substring(8, 10));
    if (year < 1900 || month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }
    final date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  static void _requireCivilDate(DateTime? date, String field) {
    if (date != null && !isCivilDate(date)) {
      throw ValidationException(
        message: '$field must be a UTC calendar date',
      );
    }
  }
}

final class _Cursor {
  const _Cursor(this.date, this.id);

  final DateTime date;
  final UuidValue id;
}
