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

/// The Ready to Assign breakdown for one month, in base minor units. Also
/// one row of the month-range reports.
abstract class BudgetMonthSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  BudgetMonthSummary._({
    required this.month,
    required this.incomeMinor,
    required this.uncategorizedMinor,
    required this.fxDifferenceMinor,
    required this.allocatedMinor,
    required this.activityMinor,
    required this.overspentLastMonthMinor,
    required this.assignedInFutureMinor,
    required this.readyToAssignMinor,
    required this.availableMinor,
  });

  factory BudgetMonthSummary({
    required int month,
    required int incomeMinor,
    required int uncategorizedMinor,
    required int fxDifferenceMinor,
    required int allocatedMinor,
    required int activityMinor,
    required int overspentLastMonthMinor,
    required int assignedInFutureMinor,
    required int readyToAssignMinor,
    required int availableMinor,
  }) = _BudgetMonthSummaryImpl;

  factory BudgetMonthSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return BudgetMonthSummary(
      month: jsonSerialization['month'] as int,
      incomeMinor: jsonSerialization['incomeMinor'] as int,
      uncategorizedMinor: jsonSerialization['uncategorizedMinor'] as int,
      fxDifferenceMinor: jsonSerialization['fxDifferenceMinor'] as int,
      allocatedMinor: jsonSerialization['allocatedMinor'] as int,
      activityMinor: jsonSerialization['activityMinor'] as int,
      overspentLastMonthMinor:
          jsonSerialization['overspentLastMonthMinor'] as int,
      assignedInFutureMinor: jsonSerialization['assignedInFutureMinor'] as int,
      readyToAssignMinor: jsonSerialization['readyToAssignMinor'] as int,
      availableMinor: jsonSerialization['availableMinor'] as int,
    );
  }

  /// yyyymm.
  int month;

  /// Inflows this month with no envelope, positive.
  int incomeMinor;

  /// Outflows this month with no envelope, negative or 0.
  int uncategorizedMinor;

  /// FX revaluations this month, signed.
  int fxDifferenceMinor;

  /// Assigned this month.
  int allocatedMinor;

  /// Sum of envelope activity this month; negative is spending.
  int activityMinor;

  /// Overspending at the end of last month, positive. It comes out of this
  /// month's Ready to Assign.
  int overspentLastMonthMinor;

  /// Assigned in months after this one.
  int assignedInFutureMinor;

  /// Money not yet given a job. Negative means more was assigned than exists.
  int readyToAssignMinor;

  /// Sum of envelope availableMinor.
  int availableMinor;

  /// Returns a shallow copy of this [BudgetMonthSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BudgetMonthSummary copyWith({
    int? month,
    int? incomeMinor,
    int? uncategorizedMinor,
    int? fxDifferenceMinor,
    int? allocatedMinor,
    int? activityMinor,
    int? overspentLastMonthMinor,
    int? assignedInFutureMinor,
    int? readyToAssignMinor,
    int? availableMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BudgetMonthSummary',
      'month': month,
      'incomeMinor': incomeMinor,
      'uncategorizedMinor': uncategorizedMinor,
      'fxDifferenceMinor': fxDifferenceMinor,
      'allocatedMinor': allocatedMinor,
      'activityMinor': activityMinor,
      'overspentLastMonthMinor': overspentLastMonthMinor,
      'assignedInFutureMinor': assignedInFutureMinor,
      'readyToAssignMinor': readyToAssignMinor,
      'availableMinor': availableMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BudgetMonthSummary',
      'month': month,
      'incomeMinor': incomeMinor,
      'uncategorizedMinor': uncategorizedMinor,
      'fxDifferenceMinor': fxDifferenceMinor,
      'allocatedMinor': allocatedMinor,
      'activityMinor': activityMinor,
      'overspentLastMonthMinor': overspentLastMonthMinor,
      'assignedInFutureMinor': assignedInFutureMinor,
      'readyToAssignMinor': readyToAssignMinor,
      'availableMinor': availableMinor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _BudgetMonthSummaryImpl extends BudgetMonthSummary {
  _BudgetMonthSummaryImpl({
    required int month,
    required int incomeMinor,
    required int uncategorizedMinor,
    required int fxDifferenceMinor,
    required int allocatedMinor,
    required int activityMinor,
    required int overspentLastMonthMinor,
    required int assignedInFutureMinor,
    required int readyToAssignMinor,
    required int availableMinor,
  }) : super._(
         month: month,
         incomeMinor: incomeMinor,
         uncategorizedMinor: uncategorizedMinor,
         fxDifferenceMinor: fxDifferenceMinor,
         allocatedMinor: allocatedMinor,
         activityMinor: activityMinor,
         overspentLastMonthMinor: overspentLastMonthMinor,
         assignedInFutureMinor: assignedInFutureMinor,
         readyToAssignMinor: readyToAssignMinor,
         availableMinor: availableMinor,
       );

  /// Returns a shallow copy of this [BudgetMonthSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BudgetMonthSummary copyWith({
    int? month,
    int? incomeMinor,
    int? uncategorizedMinor,
    int? fxDifferenceMinor,
    int? allocatedMinor,
    int? activityMinor,
    int? overspentLastMonthMinor,
    int? assignedInFutureMinor,
    int? readyToAssignMinor,
    int? availableMinor,
  }) {
    return BudgetMonthSummary(
      month: month ?? this.month,
      incomeMinor: incomeMinor ?? this.incomeMinor,
      uncategorizedMinor: uncategorizedMinor ?? this.uncategorizedMinor,
      fxDifferenceMinor: fxDifferenceMinor ?? this.fxDifferenceMinor,
      allocatedMinor: allocatedMinor ?? this.allocatedMinor,
      activityMinor: activityMinor ?? this.activityMinor,
      overspentLastMonthMinor:
          overspentLastMonthMinor ?? this.overspentLastMonthMinor,
      assignedInFutureMinor:
          assignedInFutureMinor ?? this.assignedInFutureMinor,
      readyToAssignMinor: readyToAssignMinor ?? this.readyToAssignMinor,
      availableMinor: availableMinor ?? this.availableMinor,
    );
  }
}
