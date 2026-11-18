import 'package:openbudget_core/openbudget_core.dart';

/// Exact conversions between raw token quantities, decimal unit prices and
/// fiat minor units.
///
/// Nothing here uses `double`: a provider's JSON number is converted once at
/// its boundary with [ExactDecimal.fromDouble], and every later step runs on
/// [BigInt]. The single rounding step is half up, matching the ledger helpers.
abstract final class WalletMath {
  static final BigInt _ten = BigInt.from(10);

  /// Values [quantityRaw] whole tokens at [unitPrice], in [currencyCode] minor
  /// units, rounding half up once.
  ///
  /// Returns null when the currency has no known exponent. Throws
  /// [RangeError] when the rounded value would not survive a web client.
  static int? valueMinor({
    required BigInt quantityRaw,
    required int decimals,
    required ExactDecimal unitPrice,
    required String currencyCode,
  }) {
    _requireQuantity(quantityRaw);
    _requireDecimals(decimals);
    final exponent = exponentForCurrency(currencyCode);
    if (exponent == null) return null;

    final numerator = quantityRaw * unitPrice.numerator * _ten.pow(exponent);
    final denominator = _ten.pow(decimals) * unitPrice.denominator;
    return _safeMinor(_roundHalfUp(numerator, denominator));
  }

  /// Converts a provider total price, already denominated in whole currency
  /// units, into [currencyCode] minor units.
  static int? totalValueMinor({
    required ExactDecimal totalPrice,
    required String currencyCode,
  }) {
    final exponent = exponentForCurrency(currencyCode);
    if (exponent == null) return null;
    final numerator = totalPrice.numerator * _ten.pow(exponent);
    return _safeMinor(_roundHalfUp(numerator, totalPrice.denominator));
  }

  /// Derives the exact unit price for display from a provider total price.
  ///
  /// The value written to a holding is rounded from the provider total, not
  /// recomputed from this display string, so a cent is never invented.
  static String? unitPriceFromTotal({
    required ExactDecimal totalPrice,
    required BigInt quantityRaw,
    required int decimals,
  }) {
    _requireQuantity(quantityRaw);
    _requireDecimals(decimals);
    if (quantityRaw == BigInt.zero) return null;
    final price = ExactDecimal(
      totalPrice.numerator * _ten.pow(decimals),
      totalPrice.denominator * quantityRaw,
    ).divide(ExactDecimal.one, significantDigits: 18);
    return price.toString();
  }

  /// Parses a stored exact price, rejecting malformed or non-positive values.
  static ExactDecimal? parseUnitPrice(String? raw) {
    if (raw == null) return null;
    return ExactDecimal.tryParse(raw);
  }

  static void _requireQuantity(BigInt quantityRaw) {
    if (quantityRaw.isNegative) {
      throw const WalletValueException('Token quantities cannot be negative.');
    }
  }

  static void _requireDecimals(int decimals) {
    if (decimals < 0 || decimals > 36) {
      throw const WalletValueException(
        'Token decimals must be between 0 and 36.',
      );
    }
  }

  static int _safeMinor(BigInt value) {
    if (value > BigInt.from(maxSafeMinor)) {
      throw const WalletValueException(
        'Wallet value exceeds the web-safe minor range.',
      );
    }
    return value.toInt();
  }

  static BigInt _roundHalfUp(BigInt numerator, BigInt denominator) {
    final doubled = numerator * BigInt.two + denominator;
    return doubled ~/ (denominator * BigInt.two);
  }
}

/// A value that cannot be represented safely in minor units.
final class WalletValueException implements Exception {
  const WalletValueException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One parsed token movement used to rebuild an asset's FIFO lots.
final class WalletTokenMovement {
  const WalletTokenMovement({
    required this.mint,
    required this.fromAccount,
    required this.toAccount,
    required this.amountRaw,
  });

  final String mint;
  final String fromAccount;
  final String toAccount;
  final BigInt amountRaw;
}

/// A transaction shaped for the exact FIFO estimator.
final class WalletPnlTransaction {
  const WalletPnlTransaction({
    required this.signature,
    required this.slot,
    required this.occurredAt,
    required this.movements,
  });

  final String signature;
  final int slot;
  final DateTime? occurredAt;
  final List<WalletTokenMovement> movements;
}

/// A current holding shaped for the exact FIFO estimator.
final class WalletPnlHolding {
  const WalletPnlHolding({
    required this.assetId,
    required this.quantityRaw,
    required this.decimals,
    required this.unitPrice,
    required this.currencyCode,
  });

  final String assetId;
  final BigInt quantityRaw;
  final int decimals;
  final ExactDecimal unitPrice;
  final String currencyCode;
}

/// The estimated minor amounts for one transaction.
final class WalletTransactionPnl {
  const WalletTransactionPnl({
    required this.costBasisMinor,
    required this.proceedsMinor,
    required this.realizedPnlMinor,
    required this.currencyCode,
  });

  final int costBasisMinor;
  final int proceedsMinor;
  final int realizedPnlMinor;
  final String currencyCode;
}

/// The estimated minor amounts for one current holding.
final class WalletHoldingPnl {
  const WalletHoldingPnl({
    required this.costBasisMinor,
    required this.realizedPnlMinor,
    required this.currencyCode,
  });

  final int? costBasisMinor;
  final int? realizedPnlMinor;
  final String currencyCode;
}

/// The persisted P&L facts a sync should write, plus any explicit warnings.
final class WalletPnlEstimate {
  const WalletPnlEstimate({
    required this.transactions,
    required this.holdings,
    required this.warnings,
  });

  static const empty = WalletPnlEstimate(
    transactions: {},
    holdings: {},
    warnings: [],
  );

  final Map<String, WalletTransactionPnl> transactions;
  final Map<String, WalletHoldingPnl> holdings;
  final List<String> warnings;
}

/// Rebuilds the existing FIFO estimate on exact raw quantities and minor units.
///
/// This preserves the old estimate's behaviour: an acquisition lot costs the
/// holding's current unit price, disposals consume the oldest lot first, and a
/// disposal larger than the tracked lots is only a partial estimate. No tax
/// law is inferred beyond that.
abstract final class WalletPnlCalculator {
  static WalletPnlEstimate estimate({
    required String walletAddress,
    required List<WalletPnlTransaction> transactions,
    required Iterable<WalletPnlHolding> holdings,
  }) {
    final holdingByAsset = {for (final h in holdings) h.assetId: h};
    final transactionsBySignature = <String, WalletTransactionPnl>{};
    final stateByAsset = <String, _AssetFifo>{};
    final warnings = <String>[];
    final warningSet = <String>{};

    final ordered = [...transactions]..sort(_compareTransactions);

    for (final transaction in ordered) {
      final netRawByAsset = <String, BigInt>{};
      for (final movement in transaction.movements) {
        final mint = movement.mint.trim();
        if (mint.isEmpty) continue;
        var delta = BigInt.zero;
        if (movement.toAccount.trim() == walletAddress) {
          delta += movement.amountRaw;
        }
        if (movement.fromAccount.trim() == walletAddress) {
          delta -= movement.amountRaw;
        }
        if (delta == BigInt.zero) continue;
        netRawByAsset[mint] = (netRawByAsset[mint] ?? BigInt.zero) + delta;
      }

      var cost = _Rational.zero;
      var proceeds = _Rational.zero;
      var hasEstimate = false;
      String? currencyCode;

      for (final entry in netRawByAsset.entries) {
        final holding = holdingByAsset[entry.key];
        if (holding == null) continue;
        final exponent = exponentForCurrency(holding.currencyCode);
        if (exponent == null) {
          _warn(
            warnings,
            warningSet,
            'Missing currency exponent for P&L asset ${entry.key}',
          );
          continue;
        }
        final price = holding.unitPrice;
        final delta = entry.value;
        if (delta.isNegative) {
          final disposed = delta.abs();
          final available =
              stateByAsset[entry.key]?.totalQuantity ?? BigInt.zero;
          final state = stateByAsset.putIfAbsent(
            entry.key,
            _AssetFifo.new,
          );
          final consumedCost = state.disposeFifo(disposed);
          final disposalProceeds = _quantityValue(
            disposed,
            holding.decimals,
            price,
          );
          final realized = disposalProceeds - consumedCost;
          state.realized += realized;
          cost += consumedCost;
          proceeds += disposalProceeds;
          hasEstimate = true;
          currencyCode = holding.currencyCode;

          if (disposed > available) {
            _warn(
              warnings,
              warningSet,
              'Partial P&L estimate for ${entry.key}: disposal exceeded '
              'tracked basis quantity.',
            );
          }
        } else if (delta > BigInt.zero) {
          stateByAsset
              .putIfAbsent(entry.key, _AssetFifo.new)
              .addLot(
                quantityRaw: delta,
                decimals: holding.decimals,
                unitPrice: price,
              );
        }
      }

      if (!hasEstimate || currencyCode == null) continue;
      final exponent = exponentForCurrency(currencyCode)!;
      transactionsBySignature[transaction.signature] = WalletTransactionPnl(
        costBasisMinor: _minor(cost, exponent),
        proceedsMinor: _minor(proceeds, exponent),
        realizedPnlMinor: _minor(proceeds - cost, exponent),
        currencyCode: currencyCode,
      );
    }

    final holdingEstimates = <String, WalletHoldingPnl>{};
    for (final holding in holdings) {
      final exponent = exponentForCurrency(holding.currencyCode);
      if (exponent == null) {
        _warn(
          warnings,
          warningSet,
          'Missing currency exponent for P&L asset ${holding.assetId}',
        );
        continue;
      }
      final state = stateByAsset[holding.assetId];
      final costBasisMajor = _holdingCostBasis(
        holding,
        state,
        warnings: warnings,
        warningSet: warningSet,
      );
      final realized = state?.realized;
      holdingEstimates[holding.assetId] = WalletHoldingPnl(
        costBasisMinor: costBasisMajor == null
            ? null
            : _minor(costBasisMajor, exponent),
        realizedPnlMinor: realized == null ? null : _minor(realized, exponent),
        currencyCode: holding.currencyCode,
      );
    }

    return WalletPnlEstimate(
      transactions: transactionsBySignature,
      holdings: holdingEstimates,
      warnings: warnings,
    );
  }

  static int _compareTransactions(
    WalletPnlTransaction left,
    WalletPnlTransaction right,
  ) {
    final leftAt = left.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final rightAt = right.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final byTime = leftAt.compareTo(rightAt);
    if (byTime != 0) return byTime;
    final bySlot = left.slot.compareTo(right.slot);
    if (bySlot != 0) return bySlot;
    return left.signature.compareTo(right.signature);
  }

  static _Rational? _holdingCostBasis(
    WalletPnlHolding holding,
    _AssetFifo? state, {
    required List<String> warnings,
    required Set<String> warningSet,
  }) {
    if (holding.quantityRaw == BigInt.zero) return _Rational.zero;

    if (state == null || state.totalQuantity == BigInt.zero) {
      return _quantityValue(
        holding.quantityRaw,
        holding.decimals,
        holding.unitPrice,
      );
    }

    final trackedQuantity = state.totalQuantity;
    final trackedCost = state.totalCost;
    if (holding.quantityRaw == trackedQuantity) {
      return _maxZero(trackedCost);
    }
    if (holding.quantityRaw < trackedQuantity) {
      final scaled = trackedCost.scale(
        holding.quantityRaw,
        trackedQuantity,
      );
      _warn(
        warnings,
        warningSet,
        'Estimated basis scaled down for ${holding.assetId}: tracked lots '
        'exceed current balance.',
      );
      return _maxZero(scaled);
    }

    final additionalQuantity = holding.quantityRaw - trackedQuantity;
    _warn(
      warnings,
      warningSet,
      'Estimated basis backfilled for ${holding.assetId}: current balance '
      'exceeds tracked lot quantity.',
    );
    return _maxZero(
      trackedCost +
          _quantityValue(
            additionalQuantity,
            holding.decimals,
            holding.unitPrice,
          ),
    );
  }

  static _Rational _quantityValue(
    BigInt quantityRaw,
    int decimals,
    ExactDecimal unitPrice,
  ) => _Rational(
    quantityRaw * unitPrice.numerator,
    BigInt.from(10).pow(decimals) * unitPrice.denominator,
  );

  static _Rational _maxZero(_Rational value) =>
      value.isNegative ? _Rational.zero : value;

  static int _minor(_Rational major, int exponent) {
    final scaled = major * _Rational(BigInt.from(10).pow(exponent), BigInt.one);
    return scaled.roundHalfUp();
  }

  static void _warn(List<String> warnings, Set<String> seen, String warning) {
    if (seen.add(warning)) warnings.add(warning);
  }
}

final class _AssetFifo {
  final List<_Lot> _lots = [];
  _Rational realized = _Rational.zero;

  BigInt get totalQuantity =>
      _lots.fold(BigInt.zero, (sum, lot) => sum + lot.quantityRaw);

  _Rational get totalCost =>
      _lots.fold(_Rational.zero, (sum, lot) => sum + lot.cost);

  void addLot({
    required BigInt quantityRaw,
    required int decimals,
    required ExactDecimal unitPrice,
  }) {
    if (quantityRaw <= BigInt.zero) return;
    _lots.add(_Lot(quantityRaw, decimals, unitPrice));
  }

  _Rational disposeFifo(BigInt quantityRaw) {
    var remaining = quantityRaw;
    var removed = _Rational.zero;
    while (remaining > BigInt.zero && _lots.isNotEmpty) {
      final lot = _lots.first;
      final consumed = remaining < lot.quantityRaw
          ? remaining
          : lot.quantityRaw;
      removed += lot.costFor(consumed);
      lot.quantityRaw -= consumed;
      remaining -= consumed;
      if (lot.quantityRaw == BigInt.zero) {
        _lots.removeAt(0);
      }
    }
    return removed;
  }
}

final class _Lot {
  _Lot(this.quantityRaw, this.decimals, this.unitPrice);

  BigInt quantityRaw;
  final int decimals;
  final ExactDecimal unitPrice;

  _Rational get cost => costFor(quantityRaw);

  _Rational costFor(BigInt quantity) => _Rational(
    quantity * unitPrice.numerator,
    BigInt.from(10).pow(decimals) * unitPrice.denominator,
  );
}

/// A rational number kept exact until the one half-up rounding step.
final class _Rational {
  _Rational(this.numerator, this.denominator)
    : assert(denominator > BigInt.zero, 'denominator must be positive');

  static final zero = _Rational(BigInt.zero, BigInt.one);
  final BigInt numerator;
  final BigInt denominator;

  bool get isNegative => numerator.isNegative;

  bool operator <(BigInt other) => numerator < other * denominator;

  bool operator >(BigInt other) => numerator > other * denominator;

  _Rational operator +(_Rational other) => _Rational(
    numerator * other.denominator + other.numerator * denominator,
    denominator * other.denominator,
  );

  _Rational operator -(_Rational other) => _Rational(
    numerator * other.denominator - other.numerator * denominator,
    denominator * other.denominator,
  );

  _Rational operator *(_Rational other) => _Rational(
    numerator * other.numerator,
    denominator * other.denominator,
  );

  _Rational scale(BigInt numeratorPart, BigInt denominatorPart) =>
      _Rational(numerator * numeratorPart, denominator * denominatorPart);

  int roundHalfUp() {
    final negative = numerator.isNegative;
    final absolute = numerator.abs();
    final doubled = absolute * BigInt.two + denominator;
    final rounded = doubled ~/ (denominator * BigInt.two);
    if (rounded > BigInt.from(maxSafeMinor)) {
      throw const WalletValueException(
        'Wallet P&L exceeds the web-safe minor range.',
      );
    }
    return (negative ? -rounded : rounded).toInt();
  }

  @override
  String toString() => '$numerator/$denominator';
}
