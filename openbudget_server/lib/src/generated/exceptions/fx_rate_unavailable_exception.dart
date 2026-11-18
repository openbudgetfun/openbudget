/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

/// Thrown when a write needs an exchange rate that the server does not have.
/// The app answers by asking the user for a manual rate.
abstract class FxRateUnavailableException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  FxRateUnavailableException._({
    String? message,
    required this.fromCurrencyCode,
    required this.toCurrencyCode,
    required this.date,
  }) : message = message ?? 'Exchange rate not available';

  factory FxRateUnavailableException({
    String? message,
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required DateTime date,
  }) = _FxRateUnavailableExceptionImpl;

  factory FxRateUnavailableException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return FxRateUnavailableException(
      message: jsonSerialization['message'] as String?,
      fromCurrencyCode: jsonSerialization['fromCurrencyCode'] as String,
      toCurrencyCode: jsonSerialization['toCurrencyCode'] as String,
      date: _is.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
    );
  }

  String message;

  String fromCurrencyCode;

  String toCurrencyCode;

  /// Calendar date the rate was needed for.
  DateTime date;

  /// Returns a shallow copy of this [FxRateUnavailableException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FxRateUnavailableException copyWith({
    String? message,
    String? fromCurrencyCode,
    String? toCurrencyCode,
    DateTime? date,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxRateUnavailableException',
      'message': message,
      'fromCurrencyCode': fromCurrencyCode,
      'toCurrencyCode': toCurrencyCode,
      'date': date.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FxRateUnavailableException',
      'message': message,
      'fromCurrencyCode': fromCurrencyCode,
      'toCurrencyCode': toCurrencyCode,
      'date': date.toJson(),
    };
  }

  @override
  String toString() {
    return 'FxRateUnavailableException(message: $message, fromCurrencyCode: $fromCurrencyCode, toCurrencyCode: $toCurrencyCode, date: $date)';
  }
}

class _FxRateUnavailableExceptionImpl extends FxRateUnavailableException {
  _FxRateUnavailableExceptionImpl({
    String? message,
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required DateTime date,
  }) : super._(
         message: message,
         fromCurrencyCode: fromCurrencyCode,
         toCurrencyCode: toCurrencyCode,
         date: date,
       );

  /// Returns a shallow copy of this [FxRateUnavailableException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FxRateUnavailableException copyWith({
    String? message,
    String? fromCurrencyCode,
    String? toCurrencyCode,
    DateTime? date,
  }) {
    return FxRateUnavailableException(
      message: message ?? this.message,
      fromCurrencyCode: fromCurrencyCode ?? this.fromCurrencyCode,
      toCurrencyCode: toCurrencyCode ?? this.toCurrencyCode,
      date: date ?? this.date,
    );
  }
}
