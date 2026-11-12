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

/// How often a recurring transaction repeats. Occurrence dates are expanded
/// by `nextOccurrence` in `openbudget_core`, shared by the server's posting
/// job and the app's calendar.
enum RecurrenceFrequency implements _iss.SerializableModel {
  daily,
  weekly,
  biweekly,
  monthly,
  yearly;

  static RecurrenceFrequency fromJson(String name) {
    switch (name) {
      case 'daily':
        return RecurrenceFrequency.daily;
      case 'weekly':
        return RecurrenceFrequency.weekly;
      case 'biweekly':
        return RecurrenceFrequency.biweekly;
      case 'monthly':
        return RecurrenceFrequency.monthly;
      case 'yearly':
        return RecurrenceFrequency.yearly;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "RecurrenceFrequency"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
