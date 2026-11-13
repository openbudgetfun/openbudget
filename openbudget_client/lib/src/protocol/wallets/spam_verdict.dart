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

/// Whether a holding counts toward net worth.
enum SpamVerdict implements _isc.SerializableModel {
  /// Counted when priced.
  clean,

  /// Matched a spam rule; not counted until the user allows it.
  suspected,

  /// The user hid it; never counted.
  hiddenByUser,

  /// The user allowed it; counted when priced, whatever the rules say.
  allowedByUser;

  static SpamVerdict fromJson(String name) {
    switch (name) {
      case 'clean':
        return SpamVerdict.clean;
      case 'suspected':
        return SpamVerdict.suspected;
      case 'hiddenByUser':
        return SpamVerdict.hiddenByUser;
      case 'allowedByUser':
        return SpamVerdict.allowedByUser;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "SpamVerdict"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
