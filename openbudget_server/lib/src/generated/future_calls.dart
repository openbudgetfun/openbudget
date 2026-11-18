/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: depend_on_referenced_packages

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;

import 'package:clock/clock.dart' as _io0w16m8;
import 'package:serverpod/serverpod.dart' as _is;

import '../accounts/balance_verify_future_call.dart' as _i3hgsuzd;
import '../billing/solana_billing_collector_future_call.dart' as _i6oeyfz6;
import '../fx_rates/fx_backfill_future_call.dart' as _idsel8od;
import '../fx_rates/fx_refresh_future_call.dart' as _i1ol5dhc;
import '../recurring_transactions/recurring_post_future_call.dart' as _ibpoas7h;
import '../wallets/wallet_refresh_future_call.dart' as _i5v17gy5;
import 'future_calls_generated_models/fx_backfill_future_call_fetch_model.dart'
    as _iuflqeka;

/// Invokes a future call.
typedef _InvokeFutureCall = Future<void> Function(
  String name,
  _is.SerializableModel? object,
);

extension ServerpodFutureCallsGetter on _is.Serverpod {
  /// Generated future calls.
  FutureCalls get futureCalls => FutureCalls();
}

class FutureCalls extends _is.FutureCallDispatch<_FutureCallRef> {
  FutureCalls._();

  factory FutureCalls() {
    return _instance;
  }

  static final FutureCalls _instance = FutureCalls._();

  _is.FutureCallManager? _futureCallManager;

  String? _serverId;

  String get _effectiveServerId {
    if (_serverId == null) {
      throw StateError('FutureCalls is not initialized.');
    }
    return _serverId!;
  }

  _is.FutureCallManager get _effectiveFutureCallManager {
    if (_futureCallManager == null) {
      throw StateError('FutureCalls is not initialized.');
    }
    return _futureCallManager!;
  }

  @override
  void initialize(
    _is.FutureCallManager futureCallManager,
    String serverId,
  ) {
    var registeredFutureCalls = <String, _is.InvokableFutureCall>{
      'BalanceVerifyVerifyFutureCall': BalanceVerifyVerifyFutureCall(),
      'SolanaBillingCollectorCollectFutureCall':
          SolanaBillingCollectorCollectFutureCall(),
      'FxBackfillFetchFutureCall': FxBackfillFetchFutureCall(),
      'FxRefreshRefreshFutureCall': FxRefreshRefreshFutureCall(),
      'RecurringPostPostDueFutureCall': RecurringPostPostDueFutureCall(),
      'WalletRefreshRefreshFutureCall': WalletRefreshRefreshFutureCall(),
    };
    _futureCallManager = futureCallManager;
    _serverId = serverId;
    for (final entry in registeredFutureCalls.entries) {
      _futureCallManager?.registerFutureCall(entry.value, entry.key);
    }
  }

  @override
  _FutureCallRef callAtTime(
    DateTime time, {
    String? identifier,
  }) {
    return _FutureCallRef(
      (name, object) {
        return _effectiveFutureCallManager.scheduleFutureCall(
          name,
          object,
          time,
          _effectiveServerId,
          identifier,
        );
      },
    );
  }

  @override
  _FutureCallRef callWithDelay(
    Duration delay, {
    String? identifier,
  }) {
    return _FutureCallRef(
      (name, object) {
        return _effectiveFutureCallManager.scheduleFutureCall(
          name,
          object,
          DateTime.now().toUtc().add(delay),
          _effectiveServerId,
          identifier,
        );
      },
    );
  }

  @override
  _is.RecurringFutureCallDispatch<_FutureCallRef> callRecurring({
    String? identifier,
  }) {
    return _RecurringFutureCallDispatchImpl(
      _effectiveFutureCallManager,
      _effectiveServerId,
      identifier,
    );
  }

  @override
  Future<void> cancel(String identifier) async {
    await _effectiveFutureCallManager.cancelFutureCall(identifier);
  }
}

class _RecurringFutureCallDispatchImpl
    extends _is.RecurringFutureCallDispatch<_FutureCallRef> {
  _RecurringFutureCallDispatchImpl(
    this._futureCallManager,
    this._serverId,
    this._identifier,
  );

  final _is.FutureCallManager _futureCallManager;

  final String _serverId;

  final String? _identifier;

  @override
  _FutureCallRef cron(String cronExpression) {
    return _FutureCallRef(
      (name, object) {
        return _futureCallManager.scheduleFutureCall(
          name,
          object,
          _is.Cron.parse(cronExpression).nextTime(),
          _serverId,
          _identifier,
          scheduling: _is.CronFutureCallScheduling(cron: cronExpression),
        );
      },
    );
  }

  @override
  _FutureCallRef every(
    Duration interval, {
    DateTime? start,
  }) {
    final now = _io0w16m8.clock.now().toUtc();
    return _FutureCallRef(
      (name, object) {
        return _futureCallManager.scheduleFutureCall(
          name,
          object,
          start ?? now.add(interval),
          _serverId,
          _identifier,
          scheduling: _is.IntervalFutureCallScheduling(
            interval: interval,
            start: start,
          ),
        );
      },
    );
  }
}

class _FutureCallRef {
  _FutureCallRef(this._invokeFutureCall);

  final _InvokeFutureCall _invokeFutureCall;

  late final balanceVerify = _BalanceVerifyFutureCallDispatcher(
    _invokeFutureCall,
  );

  late final solanaBillingCollector =
      _SolanaBillingCollectorFutureCallDispatcher(_invokeFutureCall);

  late final fxBackfill = _FxBackfillFutureCallDispatcher(_invokeFutureCall);

  late final fxRefresh = _FxRefreshFutureCallDispatcher(_invokeFutureCall);

  late final recurringPost = _RecurringPostFutureCallDispatcher(
    _invokeFutureCall,
  );

  late final walletRefresh = _WalletRefreshFutureCallDispatcher(
    _invokeFutureCall,
  );
}

class _BalanceVerifyFutureCallDispatcher {
  _BalanceVerifyFutureCallDispatcher(this._invokeFutureCall);

  final _InvokeFutureCall _invokeFutureCall;

  Future<void> verify() {
    return _invokeFutureCall(
      'BalanceVerifyVerifyFutureCall',
      null,
    );
  }
}

class _SolanaBillingCollectorFutureCallDispatcher {
  _SolanaBillingCollectorFutureCallDispatcher(this._invokeFutureCall);

  final _InvokeFutureCall _invokeFutureCall;

  Future<void> collect() {
    return _invokeFutureCall(
      'SolanaBillingCollectorCollectFutureCall',
      null,
    );
  }
}

class _FxBackfillFutureCallDispatcher {
  _FxBackfillFutureCallDispatcher(this._invokeFutureCall);

  final _InvokeFutureCall _invokeFutureCall;

  Future<void> fetch(DateTime date) {
    var object = _iuflqeka.FxBackfillFutureCallFetchModel(date: date);
    return _invokeFutureCall(
      'FxBackfillFetchFutureCall',
      object,
    );
  }
}

class _FxRefreshFutureCallDispatcher {
  _FxRefreshFutureCallDispatcher(this._invokeFutureCall);

  final _InvokeFutureCall _invokeFutureCall;

  Future<void> refresh() {
    return _invokeFutureCall(
      'FxRefreshRefreshFutureCall',
      null,
    );
  }
}

class _RecurringPostFutureCallDispatcher {
  _RecurringPostFutureCallDispatcher(this._invokeFutureCall);

  final _InvokeFutureCall _invokeFutureCall;

  Future<void> postDue() {
    return _invokeFutureCall(
      'RecurringPostPostDueFutureCall',
      null,
    );
  }
}

class _WalletRefreshFutureCallDispatcher {
  _WalletRefreshFutureCallDispatcher(this._invokeFutureCall);

  final _InvokeFutureCall _invokeFutureCall;

  Future<void> refresh() {
    return _invokeFutureCall(
      'WalletRefreshRefreshFutureCall',
      null,
    );
  }
}

/// Repairs drift and schedules tomorrow even if verification fails.
class BalanceVerifyVerifyFutureCall extends _is.FutureCall
    implements _is.InvokableFutureCall {
  @override
  _ida.Future<void> invoke(
    _is.Session session,
    _is.SerializableModel? object,
  ) async {
    await _i3hgsuzd.BalanceVerifyFutureCall().verify(session);
  }
}

class SolanaBillingCollectorCollectFutureCall extends _is.FutureCall
    implements _is.InvokableFutureCall {
  @override
  _ida.Future<void> invoke(
    _is.Session session,
    _is.SerializableModel? object,
  ) async {
    await _i6oeyfz6.SolanaBillingCollectorFutureCall().collect(session);
  }
}

/// Backfills exactly [date]. Never substitutes a newer day's rates.
class FxBackfillFetchFutureCall
    extends _is.FutureCall<_iuflqeka.FxBackfillFutureCallFetchModel>
    implements
        _is.InvokableFutureCall<_iuflqeka.FxBackfillFutureCallFetchModel> {
  @override
  _ida.Future<void> invoke(
    _is.Session session,
    _iuflqeka.FxBackfillFutureCallFetchModel? object,
  ) async {
    if (object != null) {
      await _idsel8od.FxBackfillFutureCall().fetch(
        session,
        object.date,
      );
    }
  }
}

/// Fetches the provider's latest rates and upserts today's rows.
///
/// A missing provider key skips the sweep. Provider failures propagate so a
/// broken upstream is visible instead of silently serving stale rates.
class FxRefreshRefreshFutureCall extends _is.FutureCall
    implements _is.InvokableFutureCall {
  @override
  _ida.Future<void> invoke(
    _is.Session session,
    _is.SerializableModel? object,
  ) async {
    await _i1ol5dhc.FxRefreshFutureCall().refresh(session);
  }
}

/// Posts all due schedules across every non-archived entity.
class RecurringPostPostDueFutureCall extends _is.FutureCall
    implements _is.InvokableFutureCall {
  @override
  _ida.Future<void> invoke(
    _is.Session session,
    _is.SerializableModel? object,
  ) async {
    await _ibpoas7h.RecurringPostFutureCall().postDue(session);
  }
}

/// Runs one refresh pass over every wallet.
class WalletRefreshRefreshFutureCall extends _is.FutureCall
    implements _is.InvokableFutureCall {
  @override
  _ida.Future<void> invoke(
    _is.Session session,
    _is.SerializableModel? object,
  ) async {
    await _i5v17gy5.WalletRefreshFutureCall().refresh(session);
  }
}
