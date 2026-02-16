// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_calendar_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScheduledOccurrence {

 RecurringTransaction get recurring; DateTime get date; bool get isDue;
/// Create a copy of ScheduledOccurrence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduledOccurrenceCopyWith<ScheduledOccurrence> get copyWith => _$ScheduledOccurrenceCopyWithImpl<ScheduledOccurrence>(this as ScheduledOccurrence, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduledOccurrence&&(identical(other.recurring, recurring) || other.recurring == recurring)&&(identical(other.date, date) || other.date == date)&&(identical(other.isDue, isDue) || other.isDue == isDue));
}


@override
int get hashCode => Object.hash(runtimeType,recurring,date,isDue);

@override
String toString() {
  return 'ScheduledOccurrence(recurring: $recurring, date: $date, isDue: $isDue)';
}


}

/// @nodoc
abstract mixin class $ScheduledOccurrenceCopyWith<$Res>  {
  factory $ScheduledOccurrenceCopyWith(ScheduledOccurrence value, $Res Function(ScheduledOccurrence) _then) = _$ScheduledOccurrenceCopyWithImpl;
@useResult
$Res call({
 RecurringTransaction recurring, DateTime date, bool isDue
});




}
/// @nodoc
class _$ScheduledOccurrenceCopyWithImpl<$Res>
    implements $ScheduledOccurrenceCopyWith<$Res> {
  _$ScheduledOccurrenceCopyWithImpl(this._self, this._then);

  final ScheduledOccurrence _self;
  final $Res Function(ScheduledOccurrence) _then;

/// Create a copy of ScheduledOccurrence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recurring = null,Object? date = null,Object? isDue = null,}) {
  return _then(_self.copyWith(
recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as RecurringTransaction,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isDue: null == isDue ? _self.isDue : isDue // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduledOccurrence].
extension ScheduledOccurrencePatterns on ScheduledOccurrence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduledOccurrence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduledOccurrence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduledOccurrence value)  $default,){
final _that = this;
switch (_that) {
case _ScheduledOccurrence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduledOccurrence value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduledOccurrence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecurringTransaction recurring,  DateTime date,  bool isDue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduledOccurrence() when $default != null:
return $default(_that.recurring,_that.date,_that.isDue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecurringTransaction recurring,  DateTime date,  bool isDue)  $default,) {final _that = this;
switch (_that) {
case _ScheduledOccurrence():
return $default(_that.recurring,_that.date,_that.isDue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecurringTransaction recurring,  DateTime date,  bool isDue)?  $default,) {final _that = this;
switch (_that) {
case _ScheduledOccurrence() when $default != null:
return $default(_that.recurring,_that.date,_that.isDue);case _:
  return null;

}
}

}

/// @nodoc


class _ScheduledOccurrence implements ScheduledOccurrence {
  const _ScheduledOccurrence({required this.recurring, required this.date, required this.isDue});
  

@override final  RecurringTransaction recurring;
@override final  DateTime date;
@override final  bool isDue;

/// Create a copy of ScheduledOccurrence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduledOccurrenceCopyWith<_ScheduledOccurrence> get copyWith => __$ScheduledOccurrenceCopyWithImpl<_ScheduledOccurrence>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduledOccurrence&&(identical(other.recurring, recurring) || other.recurring == recurring)&&(identical(other.date, date) || other.date == date)&&(identical(other.isDue, isDue) || other.isDue == isDue));
}


@override
int get hashCode => Object.hash(runtimeType,recurring,date,isDue);

@override
String toString() {
  return 'ScheduledOccurrence(recurring: $recurring, date: $date, isDue: $isDue)';
}


}

/// @nodoc
abstract mixin class _$ScheduledOccurrenceCopyWith<$Res> implements $ScheduledOccurrenceCopyWith<$Res> {
  factory _$ScheduledOccurrenceCopyWith(_ScheduledOccurrence value, $Res Function(_ScheduledOccurrence) _then) = __$ScheduledOccurrenceCopyWithImpl;
@override @useResult
$Res call({
 RecurringTransaction recurring, DateTime date, bool isDue
});




}
/// @nodoc
class __$ScheduledOccurrenceCopyWithImpl<$Res>
    implements _$ScheduledOccurrenceCopyWith<$Res> {
  __$ScheduledOccurrenceCopyWithImpl(this._self, this._then);

  final _ScheduledOccurrence _self;
  final $Res Function(_ScheduledOccurrence) _then;

/// Create a copy of ScheduledOccurrence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recurring = null,Object? date = null,Object? isDue = null,}) {
  return _then(_ScheduledOccurrence(
recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as RecurringTransaction,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isDue: null == isDue ? _self.isDue : isDue // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
