import 'package:equatable/equatable.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'envelope_activity_provider.g.dart';

/// One loaded page of an envelope's month activity.
class EnvelopeActivityState extends Equatable {
  const EnvelopeActivityState({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  /// Newest first, as the server returns them.
  final List<TransactionView> items;
  final String? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;

  EnvelopeActivityState copyWith({
    List<TransactionView>? items,
    String? nextCursor,
    bool? isLoadingMore,
  }) => EnvelopeActivityState(
    items: items ?? this.items,
    nextCursor: nextCursor ?? this.nextCursor,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [items, nextCursor, isLoadingMore];
}

/// One envelope's month activity: transactions carrying the envelope,
/// within the selected month's dates, paged by the server's keyset cursor.
@riverpod
class EnvelopeActivity extends _$EnvelopeActivity {
  static const _pageSize = 50;

  @override
  Future<EnvelopeActivityState> build(
    String entityId,
    String envelopeId,
  ) async {
    final month = ref.watch(selectedMonthProvider(entityId));
    final page = await _load(envelopeId, month, null);
    return EnvelopeActivityState(
      items: page.items,
      nextCursor: page.nextCursor,
    );
  }

  /// Loads the next page and appends it.
  Future<void> loadMore() async {
    final current = state.value;
    final cursor = current?.nextCursor;
    if (current == null || cursor == null || current.isLoadingMore) return;
    final month = ref.read(selectedMonthProvider(entityId));
    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final page = await _load(envelopeId, month, cursor);
      state = AsyncValue.data(
        EnvelopeActivityState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } on Exception {
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<TransactionPage> _load(
    String envelopeId,
    int month,
    String? cursor,
  ) async {
    final client = ref.read(serverpodClientProvider);
    return client.transaction.list(
      TransactionQuery(
        entityId: UuidValue.fromString(entityId),
        envelopeId: UuidValue.fromString(envelopeId),
        fromDate: MonthKey.toFirstDate(month),
        toDate: MonthKey.toLastDate(month),
        limit: _pageSize,
      )..cursor = cursor,
    );
  }
}
