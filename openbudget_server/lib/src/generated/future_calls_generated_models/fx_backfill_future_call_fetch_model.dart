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

abstract class FxBackfillFutureCallFetchModel
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FxBackfillFutureCallFetchModel._({required this.date});

  factory FxBackfillFutureCallFetchModel({required DateTime date}) =
      _FxBackfillFutureCallFetchModelImpl;

  factory FxBackfillFutureCallFetchModel.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return FxBackfillFutureCallFetchModel(
      date: _is.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
    );
  }

  DateTime date;

  /// Returns a shallow copy of this [FxBackfillFutureCallFetchModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FxBackfillFutureCallFetchModel copyWith({DateTime? date});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxBackfillFutureCallFetchModel',
      'date': date.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _FxBackfillFutureCallFetchModelImpl
    extends FxBackfillFutureCallFetchModel {
  _FxBackfillFutureCallFetchModelImpl({required DateTime date})
    : super._(date: date);

  /// Returns a shallow copy of this [FxBackfillFutureCallFetchModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FxBackfillFutureCallFetchModel copyWith({DateTime? date}) {
    return FxBackfillFutureCallFetchModel(date: date ?? this.date);
  }
}
