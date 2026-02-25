import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/fx_rates/fx_rate_service.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

class _FakeFxProviderClient implements FxRateProviderClient {
  _FakeFxProviderClient({
    required this.responses,
    this.throwOnCall = const <int>{},
  });

  final List<FxProviderResult> responses;
  final Set<int> throwOnCall;

  int _callCount = 0;

  @override
  String get providerName => 'fake';

  @override
  Future<FxProviderResult> fetchLatest({
    required String apiKey,
    required String baseCurrencyCode,
    required List<String> currencies,
    required String baseUrl,
  }) async {
    _callCount += 1;

    if (throwOnCall.contains(_callCount)) {
      throw ValidationException('Simulated provider failure');
    }

    final index = _callCount - 1;
    if (index < responses.length) {
      return responses[index];
    }
    return responses.last;
  }
}

void main() {
  withServerpod('Given FxRateEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
      FxRateService.resetForTests();
    });

    tearDown(FxRateService.resetForTests);

    test('refresh persists and latest serves most recent snapshot', () async {
      final fakeClient = _FakeFxProviderClient(
        responses: [
          FxProviderResult(
            fetchedAt: DateTime.utc(2026, 2, 1, 10),
            rates: const {'USD': 1.0, 'EUR': 0.9, 'GBP': 0.8},
          ),
          FxProviderResult(
            fetchedAt: DateTime.utc(2026, 2, 1, 10, 10),
            rates: const {'USD': 1.0, 'EUR': 0.92, 'GBP': 0.82},
          ),
        ],
      );

      FxRateService.configure(
        apiKey: 'test-key',
        baseUrl: 'https://example.test/v3',
        providerClient: fakeClient,
      );

      final first = await endpoints.fxRate.refresh(authedSession);
      expect(first.baseCurrencyCode, 'USD');
      expect(first.isStale, isFalse);
      expect(first.rates.any((rate) => rate.currencyCode == 'EUR'), isTrue);

      final second = await endpoints.fxRate.refresh(authedSession);
      expect(second.fetchedAt, DateTime.utc(2026, 2, 1, 10, 10));

      final latest = await endpoints.fxRate.latest(authedSession);
      expect(latest.fetchedAt, DateTime.utc(2026, 2, 1, 10, 10));
      expect(
        latest.rates.firstWhere((rate) => rate.currencyCode == 'EUR').rate,
        closeTo(0.92, 0.000001),
      );
    });

    test('latest serves stale snapshot if provider refresh fails', () async {
      final fakeClient = _FakeFxProviderClient(
        responses: [
          FxProviderResult(
            fetchedAt: DateTime.utc(2026, 2, 1, 10),
            rates: const {'USD': 1.0, 'EUR': 0.9},
          ),
        ],
        throwOnCall: const {2},
      );

      FxRateService.configure(
        apiKey: 'test-key',
        baseUrl: 'https://example.test/v3',
        refreshInterval: Duration.zero,
        providerClient: fakeClient,
      );

      final seeded = await endpoints.fxRate.refresh(authedSession);
      expect(seeded.isStale, isFalse);

      final stale = await endpoints.fxRate.latest(authedSession);
      expect(stale.isStale, isTrue);
      expect(stale.fetchedAt, seeded.fetchedAt);
    });

    test('latest requires a valid authenticated session', () async {
      expect(
        () => endpoints.fxRate.latest(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });
}
