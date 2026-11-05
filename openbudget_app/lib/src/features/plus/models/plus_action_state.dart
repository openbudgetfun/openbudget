import 'package:freezed_annotation/freezed_annotation.dart';

part 'plus_action_state.freezed.dart';

/// A payment action that is currently running.
enum PlusActionKind {
  stripeCheckout,
  stripePortal,
  storePurchase,
  storeRestore,
  storeManage,
  solanaSubscribe,
  refresh,
}

/// Why a payment action did not finish.
enum PlusActionFailure {
  /// The person closed the checkout or wallet prompt.
  cancelled,

  /// The wallet declined the request.
  rejected,

  /// The rail is not configured on this build or platform.
  unavailable,

  /// Anything else, reported without leaking server detail to the screen.
  failed,
}

/// The in-flight state of the Plus payment actions.
@freezed
abstract class PlusActionState with _$PlusActionState {
  const factory PlusActionState({
    @Default(false) bool isBusy,
    PlusActionKind? running,
    PlusActionFailure? failure,
  }) = _PlusActionState;
}
