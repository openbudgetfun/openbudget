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

/// The terms and addresses the app needs to build a subscribe transaction.
abstract class SolanaPlanView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SolanaPlanView._({
    required this.planAddress,
    required this.programAddress,
    required this.usdcMint,
    required this.amountBaseUnits,
    required this.periodSeconds,
  });

  factory SolanaPlanView({
    required String planAddress,
    required String programAddress,
    required String usdcMint,
    required int amountBaseUnits,
    required int periodSeconds,
  }) = _SolanaPlanViewImpl;

  factory SolanaPlanView.fromJson(Map<String, dynamic> jsonSerialization) {
    return SolanaPlanView(
      planAddress: jsonSerialization['planAddress'] as String,
      programAddress: jsonSerialization['programAddress'] as String,
      usdcMint: jsonSerialization['usdcMint'] as String,
      amountBaseUnits: jsonSerialization['amountBaseUnits'] as int,
      periodSeconds: jsonSerialization['periodSeconds'] as int,
    );
  }

  String planAddress;

  String programAddress;

  String usdcMint;

  int amountBaseUnits;

  int periodSeconds;

  /// Returns a shallow copy of this [SolanaPlanView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SolanaPlanView copyWith({
    String? planAddress,
    String? programAddress,
    String? usdcMint,
    int? amountBaseUnits,
    int? periodSeconds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaPlanView',
      'planAddress': planAddress,
      'programAddress': programAddress,
      'usdcMint': usdcMint,
      'amountBaseUnits': amountBaseUnits,
      'periodSeconds': periodSeconds,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SolanaPlanView',
      'planAddress': planAddress,
      'programAddress': programAddress,
      'usdcMint': usdcMint,
      'amountBaseUnits': amountBaseUnits,
      'periodSeconds': periodSeconds,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SolanaPlanViewImpl extends SolanaPlanView {
  _SolanaPlanViewImpl({
    required String planAddress,
    required String programAddress,
    required String usdcMint,
    required int amountBaseUnits,
    required int periodSeconds,
  }) : super._(
         planAddress: planAddress,
         programAddress: programAddress,
         usdcMint: usdcMint,
         amountBaseUnits: amountBaseUnits,
         periodSeconds: periodSeconds,
       );

  /// Returns a shallow copy of this [SolanaPlanView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SolanaPlanView copyWith({
    String? planAddress,
    String? programAddress,
    String? usdcMint,
    int? amountBaseUnits,
    int? periodSeconds,
  }) {
    return SolanaPlanView(
      planAddress: planAddress ?? this.planAddress,
      programAddress: programAddress ?? this.programAddress,
      usdcMint: usdcMint ?? this.usdcMint,
      amountBaseUnits: amountBaseUnits ?? this.amountBaseUnits,
      periodSeconds: periodSeconds ?? this.periodSeconds,
    );
  }
}
