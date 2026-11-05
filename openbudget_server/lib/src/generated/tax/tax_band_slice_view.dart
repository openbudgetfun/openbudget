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

/// The part of a tax base that fell in one rate band.
abstract class TaxBandSliceView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TaxBandSliceView._({
    required this.label,
    required this.baseMinor,
    required this.rateBasisPoints,
    required this.taxMinor,
  });

  factory TaxBandSliceView({
    required String label,
    required int baseMinor,
    required int rateBasisPoints,
    required int taxMinor,
  }) = _TaxBandSliceViewImpl;

  factory TaxBandSliceView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxBandSliceView(
      label: jsonSerialization['label'] as String,
      baseMinor: jsonSerialization['baseMinor'] as int,
      rateBasisPoints: jsonSerialization['rateBasisPoints'] as int,
      taxMinor: jsonSerialization['taxMinor'] as int,
    );
  }

  String label;

  int baseMinor;

  /// 2000 is 20%.
  int rateBasisPoints;

  int taxMinor;

  /// Returns a shallow copy of this [TaxBandSliceView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaxBandSliceView copyWith({
    String? label,
    int? baseMinor,
    int? rateBasisPoints,
    int? taxMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxBandSliceView',
      'label': label,
      'baseMinor': baseMinor,
      'rateBasisPoints': rateBasisPoints,
      'taxMinor': taxMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxBandSliceView',
      'label': label,
      'baseMinor': baseMinor,
      'rateBasisPoints': rateBasisPoints,
      'taxMinor': taxMinor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TaxBandSliceViewImpl extends TaxBandSliceView {
  _TaxBandSliceViewImpl({
    required String label,
    required int baseMinor,
    required int rateBasisPoints,
    required int taxMinor,
  }) : super._(
         label: label,
         baseMinor: baseMinor,
         rateBasisPoints: rateBasisPoints,
         taxMinor: taxMinor,
       );

  /// Returns a shallow copy of this [TaxBandSliceView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaxBandSliceView copyWith({
    String? label,
    int? baseMinor,
    int? rateBasisPoints,
    int? taxMinor,
  }) {
    return TaxBandSliceView(
      label: label ?? this.label,
      baseMinor: baseMinor ?? this.baseMinor,
      rateBasisPoints: rateBasisPoints ?? this.rateBasisPoints,
      taxMinor: taxMinor ?? this.taxMinor,
    );
  }
}
