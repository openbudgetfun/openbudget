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
import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

import '../tax/tax_band_slice_view.dart' as _iidbecd2;

/// One tax a report computes, such as income tax or Class 4 NICs.
abstract class TaxLiabilityView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TaxLiabilityView._({
    required this.label,
    required this.amountMinor,
    required this.bands,
  });

  factory TaxLiabilityView({
    required String label,
    required int amountMinor,
    required List<_iidbecd2.TaxBandSliceView> bands,
  }) = _TaxLiabilityViewImpl;

  factory TaxLiabilityView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxLiabilityView(
      label: jsonSerialization['label'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      bands: _is0sbm8r.Protocol().deserialize<List<_iidbecd2.TaxBandSliceView>>(
        jsonSerialization['bands'],
      ),
    );
  }

  String label;

  int amountMinor;

  /// How amountMinor was built, band by band.
  List<_iidbecd2.TaxBandSliceView> bands;

  /// Returns a shallow copy of this [TaxLiabilityView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaxLiabilityView copyWith({
    String? label,
    int? amountMinor,
    List<_iidbecd2.TaxBandSliceView>? bands,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxLiabilityView',
      'label': label,
      'amountMinor': amountMinor,
      'bands': bands.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxLiabilityView',
      'label': label,
      'amountMinor': amountMinor,
      'bands': bands.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TaxLiabilityViewImpl extends TaxLiabilityView {
  _TaxLiabilityViewImpl({
    required String label,
    required int amountMinor,
    required List<_iidbecd2.TaxBandSliceView> bands,
  }) : super._(
         label: label,
         amountMinor: amountMinor,
         bands: bands,
       );

  /// Returns a shallow copy of this [TaxLiabilityView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaxLiabilityView copyWith({
    String? label,
    int? amountMinor,
    List<_iidbecd2.TaxBandSliceView>? bands,
  }) {
    return TaxLiabilityView(
      label: label ?? this.label,
      amountMinor: amountMinor ?? this.amountMinor,
      bands: bands ?? this.bands.map((e0) => e0.copyWith()).toList(),
    );
  }
}
