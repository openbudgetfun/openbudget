// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quick_budget_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuickBudgetSuggestion {

 int get budgetedLastMonth; int get spentLastMonth; int get averageBudgeted; int get averageSpent;
/// Create a copy of QuickBudgetSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuickBudgetSuggestionCopyWith<QuickBudgetSuggestion> get copyWith => _$QuickBudgetSuggestionCopyWithImpl<QuickBudgetSuggestion>(this as QuickBudgetSuggestion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuickBudgetSuggestion&&(identical(other.budgetedLastMonth, budgetedLastMonth) || other.budgetedLastMonth == budgetedLastMonth)&&(identical(other.spentLastMonth, spentLastMonth) || other.spentLastMonth == spentLastMonth)&&(identical(other.averageBudgeted, averageBudgeted) || other.averageBudgeted == averageBudgeted)&&(identical(other.averageSpent, averageSpent) || other.averageSpent == averageSpent));
}


@override
int get hashCode => Object.hash(runtimeType,budgetedLastMonth,spentLastMonth,averageBudgeted,averageSpent);

@override
String toString() {
  return 'QuickBudgetSuggestion(budgetedLastMonth: $budgetedLastMonth, spentLastMonth: $spentLastMonth, averageBudgeted: $averageBudgeted, averageSpent: $averageSpent)';
}


}

/// @nodoc
abstract mixin class $QuickBudgetSuggestionCopyWith<$Res>  {
  factory $QuickBudgetSuggestionCopyWith(QuickBudgetSuggestion value, $Res Function(QuickBudgetSuggestion) _then) = _$QuickBudgetSuggestionCopyWithImpl;
@useResult
$Res call({
 int budgetedLastMonth, int spentLastMonth, int averageBudgeted, int averageSpent
});




}
/// @nodoc
class _$QuickBudgetSuggestionCopyWithImpl<$Res>
    implements $QuickBudgetSuggestionCopyWith<$Res> {
  _$QuickBudgetSuggestionCopyWithImpl(this._self, this._then);

  final QuickBudgetSuggestion _self;
  final $Res Function(QuickBudgetSuggestion) _then;

/// Create a copy of QuickBudgetSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? budgetedLastMonth = null,Object? spentLastMonth = null,Object? averageBudgeted = null,Object? averageSpent = null,}) {
  return _then(_self.copyWith(
budgetedLastMonth: null == budgetedLastMonth ? _self.budgetedLastMonth : budgetedLastMonth // ignore: cast_nullable_to_non_nullable
as int,spentLastMonth: null == spentLastMonth ? _self.spentLastMonth : spentLastMonth // ignore: cast_nullable_to_non_nullable
as int,averageBudgeted: null == averageBudgeted ? _self.averageBudgeted : averageBudgeted // ignore: cast_nullable_to_non_nullable
as int,averageSpent: null == averageSpent ? _self.averageSpent : averageSpent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [QuickBudgetSuggestion].
extension QuickBudgetSuggestionPatterns on QuickBudgetSuggestion {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuickBudgetSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuickBudgetSuggestion() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuickBudgetSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _QuickBudgetSuggestion():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuickBudgetSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _QuickBudgetSuggestion() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int budgetedLastMonth,  int spentLastMonth,  int averageBudgeted,  int averageSpent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuickBudgetSuggestion() when $default != null:
return $default(_that.budgetedLastMonth,_that.spentLastMonth,_that.averageBudgeted,_that.averageSpent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int budgetedLastMonth,  int spentLastMonth,  int averageBudgeted,  int averageSpent)  $default,) {final _that = this;
switch (_that) {
case _QuickBudgetSuggestion():
return $default(_that.budgetedLastMonth,_that.spentLastMonth,_that.averageBudgeted,_that.averageSpent);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int budgetedLastMonth,  int spentLastMonth,  int averageBudgeted,  int averageSpent)?  $default,) {final _that = this;
switch (_that) {
case _QuickBudgetSuggestion() when $default != null:
return $default(_that.budgetedLastMonth,_that.spentLastMonth,_that.averageBudgeted,_that.averageSpent);case _:
  return null;

}
}

}

/// @nodoc


class _QuickBudgetSuggestion implements QuickBudgetSuggestion {
  const _QuickBudgetSuggestion({required this.budgetedLastMonth, required this.spentLastMonth, required this.averageBudgeted, required this.averageSpent});
  

@override final  int budgetedLastMonth;
@override final  int spentLastMonth;
@override final  int averageBudgeted;
@override final  int averageSpent;

/// Create a copy of QuickBudgetSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuickBudgetSuggestionCopyWith<_QuickBudgetSuggestion> get copyWith => __$QuickBudgetSuggestionCopyWithImpl<_QuickBudgetSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuickBudgetSuggestion&&(identical(other.budgetedLastMonth, budgetedLastMonth) || other.budgetedLastMonth == budgetedLastMonth)&&(identical(other.spentLastMonth, spentLastMonth) || other.spentLastMonth == spentLastMonth)&&(identical(other.averageBudgeted, averageBudgeted) || other.averageBudgeted == averageBudgeted)&&(identical(other.averageSpent, averageSpent) || other.averageSpent == averageSpent));
}


@override
int get hashCode => Object.hash(runtimeType,budgetedLastMonth,spentLastMonth,averageBudgeted,averageSpent);

@override
String toString() {
  return 'QuickBudgetSuggestion(budgetedLastMonth: $budgetedLastMonth, spentLastMonth: $spentLastMonth, averageBudgeted: $averageBudgeted, averageSpent: $averageSpent)';
}


}

/// @nodoc
abstract mixin class _$QuickBudgetSuggestionCopyWith<$Res> implements $QuickBudgetSuggestionCopyWith<$Res> {
  factory _$QuickBudgetSuggestionCopyWith(_QuickBudgetSuggestion value, $Res Function(_QuickBudgetSuggestion) _then) = __$QuickBudgetSuggestionCopyWithImpl;
@override @useResult
$Res call({
 int budgetedLastMonth, int spentLastMonth, int averageBudgeted, int averageSpent
});




}
/// @nodoc
class __$QuickBudgetSuggestionCopyWithImpl<$Res>
    implements _$QuickBudgetSuggestionCopyWith<$Res> {
  __$QuickBudgetSuggestionCopyWithImpl(this._self, this._then);

  final _QuickBudgetSuggestion _self;
  final $Res Function(_QuickBudgetSuggestion) _then;

/// Create a copy of QuickBudgetSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? budgetedLastMonth = null,Object? spentLastMonth = null,Object? averageBudgeted = null,Object? averageSpent = null,}) {
  return _then(_QuickBudgetSuggestion(
budgetedLastMonth: null == budgetedLastMonth ? _self.budgetedLastMonth : budgetedLastMonth // ignore: cast_nullable_to_non_nullable
as int,spentLastMonth: null == spentLastMonth ? _self.spentLastMonth : spentLastMonth // ignore: cast_nullable_to_non_nullable
as int,averageBudgeted: null == averageBudgeted ? _self.averageBudgeted : averageBudgeted // ignore: cast_nullable_to_non_nullable
as int,averageSpent: null == averageSpent ? _self.averageSpent : averageSpent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
