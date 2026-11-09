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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// Spacing of net worth history points.
enum NetWorthGranularity implements _isc.SerializableModel {
  /// Ranges up to 92 days.
  day,

  /// Ranges up to 2 years. Weeks end on Sunday.
  week,

  /// Any range up to 400 months.
  month;

  static NetWorthGranularity fromJson(String name) {
    switch (name) {
      case 'day':
        return NetWorthGranularity.day;
      case 'week':
        return NetWorthGranularity.week;
      case 'month':
        return NetWorthGranularity.month;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "NetWorthGranularity"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
