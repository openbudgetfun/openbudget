import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/common/currency_validation.dart';
import 'package:openbudget_server/src/fx_rates/fx_provider_client.dart';
import 'package:openbudget_server/src/fx_rates/fx_quote_selection.dart';
import 'package:openbudget_server/src/generated/future_calls.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:serverpod/serverpod.dart' as sp;

/// Schedules a provider backfill for one calendar date.
typedef FxBackfillScheduler = Future<void> Function(
  Session session,
  DateTime date,
);

/// Daily FX persistence, cross-rate lookup and backfill orchestration.
///
/// Provider rates are units of a currency per one USD. Every stored rate and
/// every calculation uses an exact decimal string; a missing rate produces no
/// quote and asks for a historical backfill, never a 1:1 conversion.
class FxService {
  static final _log = ObLogger('FxService');

  /// The provider's base currency and the `fx_rate` row base.
  static const String baseCurrencyCode = 'USD';

  /// Calendar dates are looked up within this many days.
  static const int lookbackDays = 7;

  /// A rate more than this many days behind the asked date is stale.
  static const int maxStaleDays = 2;

  /// A current day's rate fetched longer ago than this is stale.
  static const Duration maxFetchedAge = Duration(hours: 48);

  /// How long a resolved quote is cached.
  static const Duration cacheLifetime = Duration(minutes: 10);

  static FxRateProviderClient _providerClient = CurrencyApiProviderClient();
  static String? _configuredApiKey;
  static String _configuredBaseUrl = currencyApiDefaultBaseUrl;
  static DateTime Function() _clock = () => DateTime.now().toUtc();
  static FxBackfillScheduler _backfillScheduler = _scheduleBackfillFutureCall;

  /// Applies provider credentials and test replacements.
  static void configure({
    required String? apiKey,
    required String? baseUrl,
    FxRateProviderClient? providerClient,
    DateTime Function()? clock,
    FxBackfillScheduler? backfillScheduler,
  }) {
    final trimmedApiKey = apiKey?.trim();
    _configuredApiKey = (trimmedApiKey?.isEmpty ?? true) ? null : trimmedApiKey;
    _configuredBaseUrl = (baseUrl == null || baseUrl.trim().isEmpty)
        ? currencyApiDefaultBaseUrl
        : baseUrl.trim();
    if (providerClient != null) {
      _providerClient = providerClient;
    }
    if (clock != null) {
      _clock = clock;
    }
    if (backfillScheduler != null) {
      _backfillScheduler = backfillScheduler;
    }
  }

  /// Restores production collaborators.
  static void resetForTests() {
    _providerClient = CurrencyApiProviderClient();
    _configuredApiKey = null;
    _configuredBaseUrl = currencyApiDefaultBaseUrl;
    _clock = () => DateTime.now().toUtc();
    _backfillScheduler = _scheduleBackfillFutureCall;
  }

  /// Whether a provider key is available from configuration or passwords.
  static bool hasProviderCredentials(Session session) =>
      _resolveApiKey(session) != null;

  /// The latest stored daily rates, for display only.
  ///
  /// Returns a stale USD-only snapshot when no rates have ever been stored;
  /// this is not a conversion and no market rate is invented.
  static Future<FxLatestSnapshot> latest(Session session) async {
    final today = _today();
    final latestRow = await FxRate.db.findFirstRow(
      session,
      where: (table) => table.rateDate <= today,
      orderBy: (table) => table.rateDate.desc(),
    );
    if (latestRow == null) {
      return _emptySnapshot();
    }

    final rows = await FxRate.db.find(
      session,
      where: (table) => table.rateDate.equals(latestRow.rateDate),
      orderBy: (table) => table.currencyCode,
    );
    if (rows.isEmpty) return _emptySnapshot();

    final fetchedAt = rows
        .map((row) => row.fetchedAt.toUtc())
        .reduce((earlier, later) => earlier.isBefore(later) ? earlier : later);
    final isStale =
        _dateIsBehind(latestRow.rateDate, today) ||
        _fetchedAtIsBehind(fetchedAt);

    return FxLatestSnapshot(
      baseCurrencyCode: baseCurrencyCode,
      rateDate: latestRow.rateDate,
      fetchedAt: fetchedAt,
      isStale: isStale,
      rates: [
        for (final row in rows)
          if (ExactDecimal.tryParse(row.rate) != null)
            FxRateQuote(currencyCode: row.currencyCode, rate: row.rate),
      ],
    );
  }

  /// Fetches the provider's latest rates and upserts today's daily rows.
  ///
  /// No currency filter is sent: currencyapi answers with every currency it
  /// prices, and a filter naming one it does not list fails the whole request.
  /// A provider failure is surfaced unchanged. An individual malformed rate is
  /// skipped and never stored as zero.
  static Future<FxLatestSnapshot> refreshNow(Session session) async {
    final apiKey = _requireApiKey(session);
    final rateDate = _today();
    final result = await _providerClient.fetchLatest(
      apiKey: apiKey,
      baseCurrencyCode: baseCurrencyCode,
      baseUrl: _resolveBaseUrl(session),
    );

    final rows = _validatedRows(
      rates: result.rates,
      rateDate: rateDate,
      fetchedAt: result.fetchedAt,
    );
    if (rows.length <= 1) {
      throw ValidationException(
        message: 'FX provider returned no usable rates',
      );
    }

    await _upsert(session, rows);
    return _snapshotFromRows(rows, rateDate: rateDate);
  }

  /// Fetches and stores the provider's historical rates for exactly [date].
  ///
  /// The provider's historical endpoint is the only source. When it has no
  /// usable rates nothing is written, so a later lookup still reports the gap.
  static Future<void> backfill(Session session, DateTime date) async {
    _requireCivilDate(date);
    final apiKey = _requireApiKey(session);
    final result = await _providerClient.fetchHistorical(
      apiKey: apiKey,
      baseCurrencyCode: baseCurrencyCode,
      date: date,
      baseUrl: _resolveBaseUrl(session),
    );

    final rows = _validatedRows(
      rates: result.rates,
      rateDate: date,
      fetchedAt: result.fetchedAt,
    );
    if (rows.length <= 1) {
      _log.warning(
        'FX historical endpoint returned no usable rates for ${_dateKey(date)}',
      );
      return;
    }

    await _upsert(session, rows);
  }

  /// The configured server clock in UTC.
  ///
  /// Report staleness and rate lookup use the same clock, so a test can make
  /// both deterministic with [configure].
  static DateTime utcNow() => _clock().toUtc();

  /// Asks for a historical backfill of [date] without letting a scheduling
  /// failure break a read. A read path may call this after its transaction
  /// commits; it never contacts the provider itself.
  static Future<void> requestBackfill(Session session, DateTime date) =>
      _requestBackfill(session, date);

  /// Resolves the rate that converts [fromCurrencyCode] to [toCurrencyCode]
  /// on [date], or null when a rate is unavailable.
  ///
  /// Identity is used only when the two codes are identical. Otherwise both
  /// currencies need a USD row on the latest date on or before [date] within
  /// the seven-day window. A missing side schedules a historical backfill for
  /// [date] and returns null.
  static Future<FxQuoteView?> rateOn(
    Session session,
    String fromCurrencyCode,
    String toCurrencyCode,
    DateTime date, {
    sp.Transaction? transaction,
  }) async {
    final from = requireSupportedCurrency(fromCurrencyCode);
    final to = requireSupportedCurrency(toCurrencyCode);
    _requireCivilDate(date);

    if (from == to) {
      final identity = FxQuoteSelection.identity(
        fromCurrencyCode: from,
        toCurrencyCode: to,
        date: date,
      );
      return FxQuoteView(
        fromCurrencyCode: from,
        toCurrencyCode: to,
        rate: identity.rateText,
        rateDate: identity.rateDate,
        source: identity.source,
        isStale: identity.isStale,
      );
    }

    final cacheKey = 'fx-quote:$from|$to|${_dateKey(date)}';
    if (transaction == null) {
      final cached = await session.caches.local.get<FxQuoteView>(cacheKey);
      if (cached != null) return cached;
    }

    final windowStart = date.subtract(const Duration(days: lookbackDays));
    final rows = await FxRate.db.find(
      session,
      where: (table) =>
          table.currencyCode.inSet({from, to}) &
          (table.rateDate <= date) &
          (table.rateDate > windowStart),
      orderBy: (table) => table.rateDate.desc(),
      transaction: transaction,
    );

    final selection = FxQuoteSelection.select(
      fromCurrencyCode: from,
      toCurrencyCode: to,
      date: date,
      rates: [
        for (final row in rows)
          FxDailyRate(
            currencyCode: row.currencyCode,
            rateDate: row.rateDate,
            rate: row.rate,
            fetchedAt: row.fetchedAt,
          ),
      ],
      now: _clock().toUtc(),
    );
    if (selection == null) {
      await _requestBackfill(session, date);
      return null;
    }

    final quote = FxQuoteView(
      fromCurrencyCode: from,
      toCurrencyCode: to,
      rate: selection.rateText,
      rateDate: selection.rateDate,
      source: selection.source,
      fetchedAt: selection.fetchedAt,
      isStale: selection.isStale,
    );

    if (transaction == null) {
      await session.caches.local.put(
        cacheKey,
        quote,
        lifetime: cacheLifetime,
      );
    }
    return quote;
  }

  /// Rejects dates that are not a UTC calendar day.
  static void _requireCivilDate(DateTime date) {
    if (!isCivilDate(date)) {
      throw ValidationException(
        message: 'FX rate date must be a UTC calendar date',
      );
    }
  }

  static Future<void> _upsert(Session session, List<FxRate> rows) async {
    await FxRate.db.upsert(
      session,
      rows,
      conflictColumns: (table) => [table.currencyCode, table.rateDate],
      updateColumns: (table) => [table.rate, table.provider, table.fetchedAt],
    );
  }

  static List<FxRate> _validatedRows({
    required Map<String, String> rates,
    required DateTime rateDate,
    required DateTime fetchedAt,
  }) {
    final utcFetchedAt = fetchedAt.toUtc();
    final valid = <String, String>{};
    for (final entry in rates.entries) {
      final currency = CurrencyCode.tryParse(entry.key);
      if (currency == null) continue;
      if (currency.code == baseCurrencyCode) continue;
      final exact = ExactDecimal.tryParse(entry.value);
      if (exact == null) {
        _log.warning(
          'Skipping unusable ${currency.code} rate for ${_dateKey(rateDate)}',
        );
        continue;
      }
      valid[currency.code] = exact.toString();
    }

    if (valid.isEmpty) return const [];

    final rows = <FxRate>[
      FxRate(
        rateDate: rateDate,
        currencyCode: baseCurrencyCode,
        rate: '1',
        provider: FxProvider.currencyapi,
        fetchedAt: utcFetchedAt,
      ),
      for (final entry in valid.entries)
        FxRate(
          rateDate: rateDate,
          currencyCode: entry.key,
          rate: entry.value,
          provider: FxProvider.currencyapi,
          fetchedAt: utcFetchedAt,
        ),
    ]..sort((a, b) => a.currencyCode.compareTo(b.currencyCode));
    return rows;
  }

  static FxLatestSnapshot _snapshotFromRows(
    List<FxRate> rows, {
    required DateTime rateDate,
  }) {
    final fetchedAt = rows
        .map((row) => row.fetchedAt.toUtc())
        .reduce((earlier, later) => earlier.isBefore(later) ? earlier : later);
    return FxLatestSnapshot(
      baseCurrencyCode: baseCurrencyCode,
      rateDate: rateDate,
      fetchedAt: fetchedAt,
      isStale: false,
      rates: [
        for (final row in rows)
          FxRateQuote(currencyCode: row.currencyCode, rate: row.rate),
      ],
    );
  }

  static FxLatestSnapshot _emptySnapshot() {
    final now = _clock().toUtc();
    return FxLatestSnapshot(
      baseCurrencyCode: baseCurrencyCode,
      rateDate: DateTime.utc(now.year, now.month, now.day),
      fetchedAt: now,
      isStale: true,
      rates: [FxRateQuote(currencyCode: baseCurrencyCode, rate: '1')],
    );
  }

  static Future<void> _requestBackfill(Session session, DateTime date) async {
    try {
      await _backfillScheduler(session, date);
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'Failed to request FX backfill for ${_dateKey(date)}: $error',
        error,
        stackTrace,
      );
    }
  }

  static Future<void> _scheduleBackfillFutureCall(
    Session session,
    DateTime date,
  ) async {
    final identifier = 'fx-backfill-${_dateKey(date)}';
    await session.serverpod.futureCalls.cancel(identifier);
    await session.serverpod.futureCalls
        .callAtTime(DateTime.now().toUtc(), identifier: identifier)
        .fxBackfill
        .fetch(date);
  }

  static bool _dateIsBehind(DateTime rateDate, DateTime reference) {
    final days = reference.difference(rateDate).inDays;
    return days > maxStaleDays;
  }

  static bool _fetchedAtIsBehind(DateTime fetchedAt) =>
      _clock().toUtc().difference(fetchedAt.toUtc()) > maxFetchedAge;

  static DateTime _today() {
    final now = _clock().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }

  static String _dateKey(DateTime date) {
    final utc = date.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String _requireApiKey(Session session) {
    final apiKey = _resolveApiKey(session);
    if (apiKey == null) {
      throw ValidationException(
        message: 'Missing currency provider credentials ($currencyApiKeyName).',
      );
    }
    return apiKey;
  }

  static String? _resolveApiKey(Session session) {
    final key =
        _configuredApiKey ?? session.serverpod.getPassword(currencyApiKeyName);
    if (key == null || key.trim().isEmpty) return null;
    return key.trim();
  }

  static String _resolveBaseUrl(Session session) {
    final configured = _configuredBaseUrl.trim();
    if (configured.isNotEmpty) return configured;

    final fromPasswords = session.serverpod
        .getPassword(currencyApiBaseUrlName)
        ?.trim();
    if (fromPasswords != null && fromPasswords.isNotEmpty) {
      return fromPasswords;
    }

    return currencyApiDefaultBaseUrl;
  }
}
