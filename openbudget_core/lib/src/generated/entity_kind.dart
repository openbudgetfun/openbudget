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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

/// What an entity is, for tax and for which features it may use.
enum EntityKind implements _iss.SerializableModel {
  /// A person or household. Envelope budgeting only.
  individual,

  /// A self-employed business whose profit is taxed on its owner's return.
  soleTrader,

  /// A limited company with its own return.
  company;

  static EntityKind fromJson(String name) {
    switch (name) {
      case 'individual':
        return EntityKind.individual;
      case 'soleTrader':
        return EntityKind.soleTrader;
      case 'company':
        return EntityKind.company;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "EntityKind"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
