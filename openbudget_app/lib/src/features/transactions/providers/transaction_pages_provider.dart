import 'package:equatable/equatable.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_pages_provider.g.dart';

/// The filters the transaction list screen can set. Every field maps onto
/// [TransactionQuery]; a changed filter re-queries from the first page.
class TransactionFilter extends Equatable {
  const TransactionFilter({
    this.accountId,
    this.envelopeId,
    this.payeeId,
    this.status,
    this.uncategorizedOnly = false,
    this.search,
    this.fromDate,
    this.toDate,
    this.limit = 50,
  });

  final String? accountId;
  final String? envelopeId;
  final String? payeeId;
  final TransactionStatus? status;
  final bool uncategorizedOnly;
  final String? search;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int limit;

  TransactionFilter copyWith({
    String? accountId,
    String? envelopeId,
    String? payeeId,
    bool clearAccountId = false,
    bool clearEnvelopeId = false,
    bool clearPayeeId = false,
    Object? status = _unset,
    bool uncategorizedOnly = false,
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
    bool clearDates = false,
  }) {
    return TransactionFilter(
      accountId: clearAccountId ? null : accountId ?? this.accountId,
      envelopeId: clearEnvelopeId ? null : envelopeId ?? this.envelopeId,
      payeeId: clearPayeeId ? null : payeeId ?? this.payeeId,
      status: status == _unset ? this.status : status as TransactionStatus?,
      uncategorizedOnly: uncategorizedOnly,
      search: search ?? this.search,
      fromDate: clearDates ? null : fromDate ?? this.fromDate,
      toDate: clearDates ? null : toDate ?? this.toDate,
      limit: limit,
    );
  }

  TransactionQuery query(String entityId) => TransactionQuery(
    entityId: UuidValue.fromString(entityId),
    accountId: accountId == null ? null : UuidValue.fromString(accountId!),
    envelopeId: envelopeId == null ? null : UuidValue.fromString(envelopeId!),
    payeeId: payeeId == null ? null : UuidValue.fromString(payeeId!),
    fromDate: fromDate,
    toDate: toDate,
    status: status,
    uncategorizedOnly: uncategorizedOnly,
    search: search?.trim().isEmpty ?? true ? null : search!.trim(),
    limit: limit,
  );

  static const _unset = Object();

  @override
  List<Object?> get props => [
    accountId,
    envelopeId,
    payeeId,
    status,
    uncategorizedOnly,
    search,
    fromDate,
    toDate,
    limit,
  ];
}

/// One loaded keyset page plus what came before it.
class TransactionPageState extends Equatable {
  const TransactionPageState({
    required this.filter,
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final TransactionFilter filter;

  /// Newest first, as the server returns them.
  final List<TransactionView> items;
  final String? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;

  TransactionPageState copyWith({
    List<TransactionView>? items,
    String? nextCursor,
    bool? isLoadingMore,
  }) {
    return TransactionPageState(
      filter: filter,
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [filter, items, nextCursor, isLoadingMore];
}

/// The paged transaction list for one entity, filtered by
/// [TransactionFilter] and paged by the server's keyset cursor.
@riverpod
class TransactionPages extends _$TransactionPages {
  @override
  Future<TransactionPageState> build(String entityId) async {
    const filter = TransactionFilter();
    return _load(entityId, filter, null);
  }

  /// Replaces the filters and reloads from the first page.
  Future<void> apply(TransactionFilter filter) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _load(entityId, filter, null));
  }

  /// Loads the next page and appends it.
  Future<void> loadMore() async {
    final current = state.value;
    final cursor = current?.nextCursor;
    if (current == null || cursor == null || current.isLoadingMore) return;
    state = AsyncValue.data(
      current.copyWith(isLoadingMore: true),
    );
    try {
      final page = await _load(entityId, current.filter, cursor);
      state = AsyncValue.data(
        TransactionPageState(
          filter: current.filter,
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } on Exception {
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<TransactionPageState> _load(
    String entityId,
    TransactionFilter filter,
    String? cursor,
  ) async {
    final client = ref.read(serverpodClientProvider);
    final query = filter.query(entityId)..cursor = cursor;
    final page = await client.transaction.list(query);
    return TransactionPageState(
      filter: filter,
      items: page.items,
      nextCursor: page.nextCursor,
    );
  }
}
