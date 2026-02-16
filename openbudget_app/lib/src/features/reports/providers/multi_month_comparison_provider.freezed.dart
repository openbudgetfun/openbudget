// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multi_month_comparison_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MonthColumn {

 int get year; int get month; int get totalBudgetedCents; int get totalSpentCents; int get totalAvailableCents; int get totalIncomeCents;
/// Create a copy of MonthColumn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthColumnCopyWith<MonthColumn> get copyWith => _$MonthColumnCopyWithImpl<MonthColumn>(this as MonthColumn, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthColumn&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.totalBudgetedCents, totalBudgetedCents) || other.totalBudgetedCents == totalBudgetedCents)&&(identical(other.totalSpentCents, totalSpentCents) || other.totalSpentCents == totalSpentCents)&&(identical(other.totalAvailableCents, totalAvailableCents) || other.totalAvailableCents == totalAvailableCents)&&(identical(other.totalIncomeCents, totalIncomeCents) || other.totalIncomeCents == totalIncomeCents));
}


@override
int get hashCode => Object.hash(runtimeType,year,month,totalBudgetedCents,totalSpentCents,totalAvailableCents,totalIncomeCents);

@override
String toString() {
  return 'MonthColumn(year: $year, month: $month, totalBudgetedCents: $totalBudgetedCents, totalSpentCents: $totalSpentCents, totalAvailableCents: $totalAvailableCents, totalIncomeCents: $totalIncomeCents)';
}


}

/// @nodoc
abstract mixin class $MonthColumnCopyWith<$Res>  {
  factory $MonthColumnCopyWith(MonthColumn value, $Res Function(MonthColumn) _then) = _$MonthColumnCopyWithImpl;
@useResult
$Res call({
 int year, int month, int totalBudgetedCents, int totalSpentCents, int totalAvailableCents, int totalIncomeCents
});




}
/// @nodoc
class _$MonthColumnCopyWithImpl<$Res>
    implements $MonthColumnCopyWith<$Res> {
  _$MonthColumnCopyWithImpl(this._self, this._then);

  final MonthColumn _self;
  final $Res Function(MonthColumn) _then;

/// Create a copy of MonthColumn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? month = null,Object? totalBudgetedCents = null,Object? totalSpentCents = null,Object? totalAvailableCents = null,Object? totalIncomeCents = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,totalBudgetedCents: null == totalBudgetedCents ? _self.totalBudgetedCents : totalBudgetedCents // ignore: cast_nullable_to_non_nullable
as int,totalSpentCents: null == totalSpentCents ? _self.totalSpentCents : totalSpentCents // ignore: cast_nullable_to_non_nullable
as int,totalAvailableCents: null == totalAvailableCents ? _self.totalAvailableCents : totalAvailableCents // ignore: cast_nullable_to_non_nullable
as int,totalIncomeCents: null == totalIncomeCents ? _self.totalIncomeCents : totalIncomeCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthColumn].
extension MonthColumnPatterns on MonthColumn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthColumn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthColumn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthColumn value)  $default,){
final _that = this;
switch (_that) {
case _MonthColumn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthColumn value)?  $default,){
final _that = this;
switch (_that) {
case _MonthColumn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int month,  int totalBudgetedCents,  int totalSpentCents,  int totalAvailableCents,  int totalIncomeCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthColumn() when $default != null:
return $default(_that.year,_that.month,_that.totalBudgetedCents,_that.totalSpentCents,_that.totalAvailableCents,_that.totalIncomeCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int month,  int totalBudgetedCents,  int totalSpentCents,  int totalAvailableCents,  int totalIncomeCents)  $default,) {final _that = this;
switch (_that) {
case _MonthColumn():
return $default(_that.year,_that.month,_that.totalBudgetedCents,_that.totalSpentCents,_that.totalAvailableCents,_that.totalIncomeCents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int month,  int totalBudgetedCents,  int totalSpentCents,  int totalAvailableCents,  int totalIncomeCents)?  $default,) {final _that = this;
switch (_that) {
case _MonthColumn() when $default != null:
return $default(_that.year,_that.month,_that.totalBudgetedCents,_that.totalSpentCents,_that.totalAvailableCents,_that.totalIncomeCents);case _:
  return null;

}
}

}

/// @nodoc


class _MonthColumn implements MonthColumn {
  const _MonthColumn({required this.year, required this.month, required this.totalBudgetedCents, required this.totalSpentCents, required this.totalAvailableCents, required this.totalIncomeCents});
  

@override final  int year;
@override final  int month;
@override final  int totalBudgetedCents;
@override final  int totalSpentCents;
@override final  int totalAvailableCents;
@override final  int totalIncomeCents;

/// Create a copy of MonthColumn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthColumnCopyWith<_MonthColumn> get copyWith => __$MonthColumnCopyWithImpl<_MonthColumn>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthColumn&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.totalBudgetedCents, totalBudgetedCents) || other.totalBudgetedCents == totalBudgetedCents)&&(identical(other.totalSpentCents, totalSpentCents) || other.totalSpentCents == totalSpentCents)&&(identical(other.totalAvailableCents, totalAvailableCents) || other.totalAvailableCents == totalAvailableCents)&&(identical(other.totalIncomeCents, totalIncomeCents) || other.totalIncomeCents == totalIncomeCents));
}


@override
int get hashCode => Object.hash(runtimeType,year,month,totalBudgetedCents,totalSpentCents,totalAvailableCents,totalIncomeCents);

@override
String toString() {
  return 'MonthColumn(year: $year, month: $month, totalBudgetedCents: $totalBudgetedCents, totalSpentCents: $totalSpentCents, totalAvailableCents: $totalAvailableCents, totalIncomeCents: $totalIncomeCents)';
}


}

/// @nodoc
abstract mixin class _$MonthColumnCopyWith<$Res> implements $MonthColumnCopyWith<$Res> {
  factory _$MonthColumnCopyWith(_MonthColumn value, $Res Function(_MonthColumn) _then) = __$MonthColumnCopyWithImpl;
@override @useResult
$Res call({
 int year, int month, int totalBudgetedCents, int totalSpentCents, int totalAvailableCents, int totalIncomeCents
});




}
/// @nodoc
class __$MonthColumnCopyWithImpl<$Res>
    implements _$MonthColumnCopyWith<$Res> {
  __$MonthColumnCopyWithImpl(this._self, this._then);

  final _MonthColumn _self;
  final $Res Function(_MonthColumn) _then;

/// Create a copy of MonthColumn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,Object? totalBudgetedCents = null,Object? totalSpentCents = null,Object? totalAvailableCents = null,Object? totalIncomeCents = null,}) {
  return _then(_MonthColumn(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,totalBudgetedCents: null == totalBudgetedCents ? _self.totalBudgetedCents : totalBudgetedCents // ignore: cast_nullable_to_non_nullable
as int,totalSpentCents: null == totalSpentCents ? _self.totalSpentCents : totalSpentCents // ignore: cast_nullable_to_non_nullable
as int,totalAvailableCents: null == totalAvailableCents ? _self.totalAvailableCents : totalAvailableCents // ignore: cast_nullable_to_non_nullable
as int,totalIncomeCents: null == totalIncomeCents ? _self.totalIncomeCents : totalIncomeCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$EnvelopeComparison {

 Envelope get envelope;/// Keyed by "year-month" string, each entry holds
/// [budgeted, spent, available].
 Map<String, List<int>> get monthData;
/// Create a copy of EnvelopeComparison
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnvelopeComparisonCopyWith<EnvelopeComparison> get copyWith => _$EnvelopeComparisonCopyWithImpl<EnvelopeComparison>(this as EnvelopeComparison, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvelopeComparison&&(identical(other.envelope, envelope) || other.envelope == envelope)&&const DeepCollectionEquality().equals(other.monthData, monthData));
}


@override
int get hashCode => Object.hash(runtimeType,envelope,const DeepCollectionEquality().hash(monthData));

@override
String toString() {
  return 'EnvelopeComparison(envelope: $envelope, monthData: $monthData)';
}


}

/// @nodoc
abstract mixin class $EnvelopeComparisonCopyWith<$Res>  {
  factory $EnvelopeComparisonCopyWith(EnvelopeComparison value, $Res Function(EnvelopeComparison) _then) = _$EnvelopeComparisonCopyWithImpl;
@useResult
$Res call({
 Envelope envelope, Map<String, List<int>> monthData
});




}
/// @nodoc
class _$EnvelopeComparisonCopyWithImpl<$Res>
    implements $EnvelopeComparisonCopyWith<$Res> {
  _$EnvelopeComparisonCopyWithImpl(this._self, this._then);

  final EnvelopeComparison _self;
  final $Res Function(EnvelopeComparison) _then;

/// Create a copy of EnvelopeComparison
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? envelope = null,Object? monthData = null,}) {
  return _then(_self.copyWith(
envelope: null == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as Envelope,monthData: null == monthData ? _self.monthData : monthData // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,
  ));
}

}


/// Adds pattern-matching-related methods to [EnvelopeComparison].
extension EnvelopeComparisonPatterns on EnvelopeComparison {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnvelopeComparison value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnvelopeComparison() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnvelopeComparison value)  $default,){
final _that = this;
switch (_that) {
case _EnvelopeComparison():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnvelopeComparison value)?  $default,){
final _that = this;
switch (_that) {
case _EnvelopeComparison() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Envelope envelope,  Map<String, List<int>> monthData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnvelopeComparison() when $default != null:
return $default(_that.envelope,_that.monthData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Envelope envelope,  Map<String, List<int>> monthData)  $default,) {final _that = this;
switch (_that) {
case _EnvelopeComparison():
return $default(_that.envelope,_that.monthData);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Envelope envelope,  Map<String, List<int>> monthData)?  $default,) {final _that = this;
switch (_that) {
case _EnvelopeComparison() when $default != null:
return $default(_that.envelope,_that.monthData);case _:
  return null;

}
}

}

/// @nodoc


class _EnvelopeComparison implements EnvelopeComparison {
  const _EnvelopeComparison({required this.envelope, required final  Map<String, List<int>> monthData}): _monthData = monthData;
  

@override final  Envelope envelope;
/// Keyed by "year-month" string, each entry holds
/// [budgeted, spent, available].
 final  Map<String, List<int>> _monthData;
/// Keyed by "year-month" string, each entry holds
/// [budgeted, spent, available].
@override Map<String, List<int>> get monthData {
  if (_monthData is EqualUnmodifiableMapView) return _monthData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_monthData);
}


/// Create a copy of EnvelopeComparison
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnvelopeComparisonCopyWith<_EnvelopeComparison> get copyWith => __$EnvelopeComparisonCopyWithImpl<_EnvelopeComparison>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnvelopeComparison&&(identical(other.envelope, envelope) || other.envelope == envelope)&&const DeepCollectionEquality().equals(other._monthData, _monthData));
}


@override
int get hashCode => Object.hash(runtimeType,envelope,const DeepCollectionEquality().hash(_monthData));

@override
String toString() {
  return 'EnvelopeComparison(envelope: $envelope, monthData: $monthData)';
}


}

/// @nodoc
abstract mixin class _$EnvelopeComparisonCopyWith<$Res> implements $EnvelopeComparisonCopyWith<$Res> {
  factory _$EnvelopeComparisonCopyWith(_EnvelopeComparison value, $Res Function(_EnvelopeComparison) _then) = __$EnvelopeComparisonCopyWithImpl;
@override @useResult
$Res call({
 Envelope envelope, Map<String, List<int>> monthData
});




}
/// @nodoc
class __$EnvelopeComparisonCopyWithImpl<$Res>
    implements _$EnvelopeComparisonCopyWith<$Res> {
  __$EnvelopeComparisonCopyWithImpl(this._self, this._then);

  final _EnvelopeComparison _self;
  final $Res Function(_EnvelopeComparison) _then;

/// Create a copy of EnvelopeComparison
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? envelope = null,Object? monthData = null,}) {
  return _then(_EnvelopeComparison(
envelope: null == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as Envelope,monthData: null == monthData ? _self._monthData : monthData // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,
  ));
}


}

/// @nodoc
mixin _$CategoryComparison {

 Category get category; List<EnvelopeComparison> get envelopes;/// Keyed by "year-month" string, each entry holds
/// [budgeted, spent, available].
 Map<String, List<int>> get monthTotals;
/// Create a copy of CategoryComparison
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryComparisonCopyWith<CategoryComparison> get copyWith => _$CategoryComparisonCopyWithImpl<CategoryComparison>(this as CategoryComparison, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryComparison&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.envelopes, envelopes)&&const DeepCollectionEquality().equals(other.monthTotals, monthTotals));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(envelopes),const DeepCollectionEquality().hash(monthTotals));

@override
String toString() {
  return 'CategoryComparison(category: $category, envelopes: $envelopes, monthTotals: $monthTotals)';
}


}

/// @nodoc
abstract mixin class $CategoryComparisonCopyWith<$Res>  {
  factory $CategoryComparisonCopyWith(CategoryComparison value, $Res Function(CategoryComparison) _then) = _$CategoryComparisonCopyWithImpl;
@useResult
$Res call({
 Category category, List<EnvelopeComparison> envelopes, Map<String, List<int>> monthTotals
});




}
/// @nodoc
class _$CategoryComparisonCopyWithImpl<$Res>
    implements $CategoryComparisonCopyWith<$Res> {
  _$CategoryComparisonCopyWithImpl(this._self, this._then);

  final CategoryComparison _self;
  final $Res Function(CategoryComparison) _then;

/// Create a copy of CategoryComparison
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? envelopes = null,Object? monthTotals = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,envelopes: null == envelopes ? _self.envelopes : envelopes // ignore: cast_nullable_to_non_nullable
as List<EnvelopeComparison>,monthTotals: null == monthTotals ? _self.monthTotals : monthTotals // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryComparison].
extension CategoryComparisonPatterns on CategoryComparison {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryComparison value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryComparison() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryComparison value)  $default,){
final _that = this;
switch (_that) {
case _CategoryComparison():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryComparison value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryComparison() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Category category,  List<EnvelopeComparison> envelopes,  Map<String, List<int>> monthTotals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryComparison() when $default != null:
return $default(_that.category,_that.envelopes,_that.monthTotals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Category category,  List<EnvelopeComparison> envelopes,  Map<String, List<int>> monthTotals)  $default,) {final _that = this;
switch (_that) {
case _CategoryComparison():
return $default(_that.category,_that.envelopes,_that.monthTotals);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Category category,  List<EnvelopeComparison> envelopes,  Map<String, List<int>> monthTotals)?  $default,) {final _that = this;
switch (_that) {
case _CategoryComparison() when $default != null:
return $default(_that.category,_that.envelopes,_that.monthTotals);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryComparison implements CategoryComparison {
  const _CategoryComparison({required this.category, required final  List<EnvelopeComparison> envelopes, required final  Map<String, List<int>> monthTotals}): _envelopes = envelopes,_monthTotals = monthTotals;
  

@override final  Category category;
 final  List<EnvelopeComparison> _envelopes;
@override List<EnvelopeComparison> get envelopes {
  if (_envelopes is EqualUnmodifiableListView) return _envelopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_envelopes);
}

/// Keyed by "year-month" string, each entry holds
/// [budgeted, spent, available].
 final  Map<String, List<int>> _monthTotals;
/// Keyed by "year-month" string, each entry holds
/// [budgeted, spent, available].
@override Map<String, List<int>> get monthTotals {
  if (_monthTotals is EqualUnmodifiableMapView) return _monthTotals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_monthTotals);
}


/// Create a copy of CategoryComparison
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryComparisonCopyWith<_CategoryComparison> get copyWith => __$CategoryComparisonCopyWithImpl<_CategoryComparison>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryComparison&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._envelopes, _envelopes)&&const DeepCollectionEquality().equals(other._monthTotals, _monthTotals));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(_envelopes),const DeepCollectionEquality().hash(_monthTotals));

@override
String toString() {
  return 'CategoryComparison(category: $category, envelopes: $envelopes, monthTotals: $monthTotals)';
}


}

/// @nodoc
abstract mixin class _$CategoryComparisonCopyWith<$Res> implements $CategoryComparisonCopyWith<$Res> {
  factory _$CategoryComparisonCopyWith(_CategoryComparison value, $Res Function(_CategoryComparison) _then) = __$CategoryComparisonCopyWithImpl;
@override @useResult
$Res call({
 Category category, List<EnvelopeComparison> envelopes, Map<String, List<int>> monthTotals
});




}
/// @nodoc
class __$CategoryComparisonCopyWithImpl<$Res>
    implements _$CategoryComparisonCopyWith<$Res> {
  __$CategoryComparisonCopyWithImpl(this._self, this._then);

  final _CategoryComparison _self;
  final $Res Function(_CategoryComparison) _then;

/// Create a copy of CategoryComparison
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? envelopes = null,Object? monthTotals = null,}) {
  return _then(_CategoryComparison(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,envelopes: null == envelopes ? _self._envelopes : envelopes // ignore: cast_nullable_to_non_nullable
as List<EnvelopeComparison>,monthTotals: null == monthTotals ? _self._monthTotals : monthTotals // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,
  ));
}


}

/// @nodoc
mixin _$MultiMonthComparison {

 Budget get budget; List<MonthColumn> get months; List<CategoryComparison> get categories;
/// Create a copy of MultiMonthComparison
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultiMonthComparisonCopyWith<MultiMonthComparison> get copyWith => _$MultiMonthComparisonCopyWithImpl<MultiMonthComparison>(this as MultiMonthComparison, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultiMonthComparison&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other.months, months)&&const DeepCollectionEquality().equals(other.categories, categories));
}


@override
int get hashCode => Object.hash(runtimeType,budget,const DeepCollectionEquality().hash(months),const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'MultiMonthComparison(budget: $budget, months: $months, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $MultiMonthComparisonCopyWith<$Res>  {
  factory $MultiMonthComparisonCopyWith(MultiMonthComparison value, $Res Function(MultiMonthComparison) _then) = _$MultiMonthComparisonCopyWithImpl;
@useResult
$Res call({
 Budget budget, List<MonthColumn> months, List<CategoryComparison> categories
});




}
/// @nodoc
class _$MultiMonthComparisonCopyWithImpl<$Res>
    implements $MultiMonthComparisonCopyWith<$Res> {
  _$MultiMonthComparisonCopyWithImpl(this._self, this._then);

  final MultiMonthComparison _self;
  final $Res Function(MultiMonthComparison) _then;

/// Create a copy of MultiMonthComparison
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? budget = null,Object? months = null,Object? categories = null,}) {
  return _then(_self.copyWith(
budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as Budget,months: null == months ? _self.months : months // ignore: cast_nullable_to_non_nullable
as List<MonthColumn>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryComparison>,
  ));
}

}


/// Adds pattern-matching-related methods to [MultiMonthComparison].
extension MultiMonthComparisonPatterns on MultiMonthComparison {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MultiMonthComparison value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MultiMonthComparison() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MultiMonthComparison value)  $default,){
final _that = this;
switch (_that) {
case _MultiMonthComparison():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MultiMonthComparison value)?  $default,){
final _that = this;
switch (_that) {
case _MultiMonthComparison() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Budget budget,  List<MonthColumn> months,  List<CategoryComparison> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MultiMonthComparison() when $default != null:
return $default(_that.budget,_that.months,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Budget budget,  List<MonthColumn> months,  List<CategoryComparison> categories)  $default,) {final _that = this;
switch (_that) {
case _MultiMonthComparison():
return $default(_that.budget,_that.months,_that.categories);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Budget budget,  List<MonthColumn> months,  List<CategoryComparison> categories)?  $default,) {final _that = this;
switch (_that) {
case _MultiMonthComparison() when $default != null:
return $default(_that.budget,_that.months,_that.categories);case _:
  return null;

}
}

}

/// @nodoc


class _MultiMonthComparison implements MultiMonthComparison {
  const _MultiMonthComparison({required this.budget, required final  List<MonthColumn> months, required final  List<CategoryComparison> categories}): _months = months,_categories = categories;
  

@override final  Budget budget;
 final  List<MonthColumn> _months;
@override List<MonthColumn> get months {
  if (_months is EqualUnmodifiableListView) return _months;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_months);
}

 final  List<CategoryComparison> _categories;
@override List<CategoryComparison> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of MultiMonthComparison
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MultiMonthComparisonCopyWith<_MultiMonthComparison> get copyWith => __$MultiMonthComparisonCopyWithImpl<_MultiMonthComparison>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MultiMonthComparison&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other._months, _months)&&const DeepCollectionEquality().equals(other._categories, _categories));
}


@override
int get hashCode => Object.hash(runtimeType,budget,const DeepCollectionEquality().hash(_months),const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'MultiMonthComparison(budget: $budget, months: $months, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$MultiMonthComparisonCopyWith<$Res> implements $MultiMonthComparisonCopyWith<$Res> {
  factory _$MultiMonthComparisonCopyWith(_MultiMonthComparison value, $Res Function(_MultiMonthComparison) _then) = __$MultiMonthComparisonCopyWithImpl;
@override @useResult
$Res call({
 Budget budget, List<MonthColumn> months, List<CategoryComparison> categories
});




}
/// @nodoc
class __$MultiMonthComparisonCopyWithImpl<$Res>
    implements _$MultiMonthComparisonCopyWith<$Res> {
  __$MultiMonthComparisonCopyWithImpl(this._self, this._then);

  final _MultiMonthComparison _self;
  final $Res Function(_MultiMonthComparison) _then;

/// Create a copy of MultiMonthComparison
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? budget = null,Object? months = null,Object? categories = null,}) {
  return _then(_MultiMonthComparison(
budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as Budget,months: null == months ? _self._months : months // ignore: cast_nullable_to_non_nullable
as List<MonthColumn>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryComparison>,
  ));
}


}

// dart format on
