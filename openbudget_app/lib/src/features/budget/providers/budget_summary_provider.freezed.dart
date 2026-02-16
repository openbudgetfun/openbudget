// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_summary_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MonthlyEnvelopeData {

 Envelope get envelope; int get allocatedCents; int get spentCents; int get availableCents; int get carryoverCents;
/// Create a copy of MonthlyEnvelopeData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyEnvelopeDataCopyWith<MonthlyEnvelopeData> get copyWith => _$MonthlyEnvelopeDataCopyWithImpl<MonthlyEnvelopeData>(this as MonthlyEnvelopeData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyEnvelopeData&&(identical(other.envelope, envelope) || other.envelope == envelope)&&(identical(other.allocatedCents, allocatedCents) || other.allocatedCents == allocatedCents)&&(identical(other.spentCents, spentCents) || other.spentCents == spentCents)&&(identical(other.availableCents, availableCents) || other.availableCents == availableCents)&&(identical(other.carryoverCents, carryoverCents) || other.carryoverCents == carryoverCents));
}


@override
int get hashCode => Object.hash(runtimeType,envelope,allocatedCents,spentCents,availableCents,carryoverCents);

@override
String toString() {
  return 'MonthlyEnvelopeData(envelope: $envelope, allocatedCents: $allocatedCents, spentCents: $spentCents, availableCents: $availableCents, carryoverCents: $carryoverCents)';
}


}

/// @nodoc
abstract mixin class $MonthlyEnvelopeDataCopyWith<$Res>  {
  factory $MonthlyEnvelopeDataCopyWith(MonthlyEnvelopeData value, $Res Function(MonthlyEnvelopeData) _then) = _$MonthlyEnvelopeDataCopyWithImpl;
@useResult
$Res call({
 Envelope envelope, int allocatedCents, int spentCents, int availableCents, int carryoverCents
});




}
/// @nodoc
class _$MonthlyEnvelopeDataCopyWithImpl<$Res>
    implements $MonthlyEnvelopeDataCopyWith<$Res> {
  _$MonthlyEnvelopeDataCopyWithImpl(this._self, this._then);

  final MonthlyEnvelopeData _self;
  final $Res Function(MonthlyEnvelopeData) _then;

/// Create a copy of MonthlyEnvelopeData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? envelope = null,Object? allocatedCents = null,Object? spentCents = null,Object? availableCents = null,Object? carryoverCents = null,}) {
  return _then(_self.copyWith(
envelope: null == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as Envelope,allocatedCents: null == allocatedCents ? _self.allocatedCents : allocatedCents // ignore: cast_nullable_to_non_nullable
as int,spentCents: null == spentCents ? _self.spentCents : spentCents // ignore: cast_nullable_to_non_nullable
as int,availableCents: null == availableCents ? _self.availableCents : availableCents // ignore: cast_nullable_to_non_nullable
as int,carryoverCents: null == carryoverCents ? _self.carryoverCents : carryoverCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyEnvelopeData].
extension MonthlyEnvelopeDataPatterns on MonthlyEnvelopeData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyEnvelopeData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyEnvelopeData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyEnvelopeData value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyEnvelopeData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyEnvelopeData value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyEnvelopeData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Envelope envelope,  int allocatedCents,  int spentCents,  int availableCents,  int carryoverCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyEnvelopeData() when $default != null:
return $default(_that.envelope,_that.allocatedCents,_that.spentCents,_that.availableCents,_that.carryoverCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Envelope envelope,  int allocatedCents,  int spentCents,  int availableCents,  int carryoverCents)  $default,) {final _that = this;
switch (_that) {
case _MonthlyEnvelopeData():
return $default(_that.envelope,_that.allocatedCents,_that.spentCents,_that.availableCents,_that.carryoverCents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Envelope envelope,  int allocatedCents,  int spentCents,  int availableCents,  int carryoverCents)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyEnvelopeData() when $default != null:
return $default(_that.envelope,_that.allocatedCents,_that.spentCents,_that.availableCents,_that.carryoverCents);case _:
  return null;

}
}

}

/// @nodoc


class _MonthlyEnvelopeData implements MonthlyEnvelopeData {
  const _MonthlyEnvelopeData({required this.envelope, required this.allocatedCents, required this.spentCents, required this.availableCents, required this.carryoverCents});
  

@override final  Envelope envelope;
@override final  int allocatedCents;
@override final  int spentCents;
@override final  int availableCents;
@override final  int carryoverCents;

/// Create a copy of MonthlyEnvelopeData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyEnvelopeDataCopyWith<_MonthlyEnvelopeData> get copyWith => __$MonthlyEnvelopeDataCopyWithImpl<_MonthlyEnvelopeData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyEnvelopeData&&(identical(other.envelope, envelope) || other.envelope == envelope)&&(identical(other.allocatedCents, allocatedCents) || other.allocatedCents == allocatedCents)&&(identical(other.spentCents, spentCents) || other.spentCents == spentCents)&&(identical(other.availableCents, availableCents) || other.availableCents == availableCents)&&(identical(other.carryoverCents, carryoverCents) || other.carryoverCents == carryoverCents));
}


@override
int get hashCode => Object.hash(runtimeType,envelope,allocatedCents,spentCents,availableCents,carryoverCents);

@override
String toString() {
  return 'MonthlyEnvelopeData(envelope: $envelope, allocatedCents: $allocatedCents, spentCents: $spentCents, availableCents: $availableCents, carryoverCents: $carryoverCents)';
}


}

/// @nodoc
abstract mixin class _$MonthlyEnvelopeDataCopyWith<$Res> implements $MonthlyEnvelopeDataCopyWith<$Res> {
  factory _$MonthlyEnvelopeDataCopyWith(_MonthlyEnvelopeData value, $Res Function(_MonthlyEnvelopeData) _then) = __$MonthlyEnvelopeDataCopyWithImpl;
@override @useResult
$Res call({
 Envelope envelope, int allocatedCents, int spentCents, int availableCents, int carryoverCents
});




}
/// @nodoc
class __$MonthlyEnvelopeDataCopyWithImpl<$Res>
    implements _$MonthlyEnvelopeDataCopyWith<$Res> {
  __$MonthlyEnvelopeDataCopyWithImpl(this._self, this._then);

  final _MonthlyEnvelopeData _self;
  final $Res Function(_MonthlyEnvelopeData) _then;

/// Create a copy of MonthlyEnvelopeData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? envelope = null,Object? allocatedCents = null,Object? spentCents = null,Object? availableCents = null,Object? carryoverCents = null,}) {
  return _then(_MonthlyEnvelopeData(
envelope: null == envelope ? _self.envelope : envelope // ignore: cast_nullable_to_non_nullable
as Envelope,allocatedCents: null == allocatedCents ? _self.allocatedCents : allocatedCents // ignore: cast_nullable_to_non_nullable
as int,spentCents: null == spentCents ? _self.spentCents : spentCents // ignore: cast_nullable_to_non_nullable
as int,availableCents: null == availableCents ? _self.availableCents : availableCents // ignore: cast_nullable_to_non_nullable
as int,carryoverCents: null == carryoverCents ? _self.carryoverCents : carryoverCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CategoryWithEnvelopes {

 Category get category; List<Envelope> get envelopes; List<MonthlyEnvelopeData> get monthlyEnvelopes; int get totalBudgetedCents; int get totalSpentCents; int get totalAvailableCents;
/// Create a copy of CategoryWithEnvelopes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryWithEnvelopesCopyWith<CategoryWithEnvelopes> get copyWith => _$CategoryWithEnvelopesCopyWithImpl<CategoryWithEnvelopes>(this as CategoryWithEnvelopes, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryWithEnvelopes&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.envelopes, envelopes)&&const DeepCollectionEquality().equals(other.monthlyEnvelopes, monthlyEnvelopes)&&(identical(other.totalBudgetedCents, totalBudgetedCents) || other.totalBudgetedCents == totalBudgetedCents)&&(identical(other.totalSpentCents, totalSpentCents) || other.totalSpentCents == totalSpentCents)&&(identical(other.totalAvailableCents, totalAvailableCents) || other.totalAvailableCents == totalAvailableCents));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(envelopes),const DeepCollectionEquality().hash(monthlyEnvelopes),totalBudgetedCents,totalSpentCents,totalAvailableCents);

@override
String toString() {
  return 'CategoryWithEnvelopes(category: $category, envelopes: $envelopes, monthlyEnvelopes: $monthlyEnvelopes, totalBudgetedCents: $totalBudgetedCents, totalSpentCents: $totalSpentCents, totalAvailableCents: $totalAvailableCents)';
}


}

/// @nodoc
abstract mixin class $CategoryWithEnvelopesCopyWith<$Res>  {
  factory $CategoryWithEnvelopesCopyWith(CategoryWithEnvelopes value, $Res Function(CategoryWithEnvelopes) _then) = _$CategoryWithEnvelopesCopyWithImpl;
@useResult
$Res call({
 Category category, List<Envelope> envelopes, List<MonthlyEnvelopeData> monthlyEnvelopes, int totalBudgetedCents, int totalSpentCents, int totalAvailableCents
});




}
/// @nodoc
class _$CategoryWithEnvelopesCopyWithImpl<$Res>
    implements $CategoryWithEnvelopesCopyWith<$Res> {
  _$CategoryWithEnvelopesCopyWithImpl(this._self, this._then);

  final CategoryWithEnvelopes _self;
  final $Res Function(CategoryWithEnvelopes) _then;

/// Create a copy of CategoryWithEnvelopes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? envelopes = null,Object? monthlyEnvelopes = null,Object? totalBudgetedCents = null,Object? totalSpentCents = null,Object? totalAvailableCents = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,envelopes: null == envelopes ? _self.envelopes : envelopes // ignore: cast_nullable_to_non_nullable
as List<Envelope>,monthlyEnvelopes: null == monthlyEnvelopes ? _self.monthlyEnvelopes : monthlyEnvelopes // ignore: cast_nullable_to_non_nullable
as List<MonthlyEnvelopeData>,totalBudgetedCents: null == totalBudgetedCents ? _self.totalBudgetedCents : totalBudgetedCents // ignore: cast_nullable_to_non_nullable
as int,totalSpentCents: null == totalSpentCents ? _self.totalSpentCents : totalSpentCents // ignore: cast_nullable_to_non_nullable
as int,totalAvailableCents: null == totalAvailableCents ? _self.totalAvailableCents : totalAvailableCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryWithEnvelopes].
extension CategoryWithEnvelopesPatterns on CategoryWithEnvelopes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryWithEnvelopes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryWithEnvelopes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryWithEnvelopes value)  $default,){
final _that = this;
switch (_that) {
case _CategoryWithEnvelopes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryWithEnvelopes value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryWithEnvelopes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Category category,  List<Envelope> envelopes,  List<MonthlyEnvelopeData> monthlyEnvelopes,  int totalBudgetedCents,  int totalSpentCents,  int totalAvailableCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryWithEnvelopes() when $default != null:
return $default(_that.category,_that.envelopes,_that.monthlyEnvelopes,_that.totalBudgetedCents,_that.totalSpentCents,_that.totalAvailableCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Category category,  List<Envelope> envelopes,  List<MonthlyEnvelopeData> monthlyEnvelopes,  int totalBudgetedCents,  int totalSpentCents,  int totalAvailableCents)  $default,) {final _that = this;
switch (_that) {
case _CategoryWithEnvelopes():
return $default(_that.category,_that.envelopes,_that.monthlyEnvelopes,_that.totalBudgetedCents,_that.totalSpentCents,_that.totalAvailableCents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Category category,  List<Envelope> envelopes,  List<MonthlyEnvelopeData> monthlyEnvelopes,  int totalBudgetedCents,  int totalSpentCents,  int totalAvailableCents)?  $default,) {final _that = this;
switch (_that) {
case _CategoryWithEnvelopes() when $default != null:
return $default(_that.category,_that.envelopes,_that.monthlyEnvelopes,_that.totalBudgetedCents,_that.totalSpentCents,_that.totalAvailableCents);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryWithEnvelopes implements CategoryWithEnvelopes {
  const _CategoryWithEnvelopes({required this.category, required final  List<Envelope> envelopes, required final  List<MonthlyEnvelopeData> monthlyEnvelopes, required this.totalBudgetedCents, required this.totalSpentCents, required this.totalAvailableCents}): _envelopes = envelopes,_monthlyEnvelopes = monthlyEnvelopes;
  

@override final  Category category;
 final  List<Envelope> _envelopes;
@override List<Envelope> get envelopes {
  if (_envelopes is EqualUnmodifiableListView) return _envelopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_envelopes);
}

 final  List<MonthlyEnvelopeData> _monthlyEnvelopes;
@override List<MonthlyEnvelopeData> get monthlyEnvelopes {
  if (_monthlyEnvelopes is EqualUnmodifiableListView) return _monthlyEnvelopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlyEnvelopes);
}

@override final  int totalBudgetedCents;
@override final  int totalSpentCents;
@override final  int totalAvailableCents;

/// Create a copy of CategoryWithEnvelopes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryWithEnvelopesCopyWith<_CategoryWithEnvelopes> get copyWith => __$CategoryWithEnvelopesCopyWithImpl<_CategoryWithEnvelopes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryWithEnvelopes&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._envelopes, _envelopes)&&const DeepCollectionEquality().equals(other._monthlyEnvelopes, _monthlyEnvelopes)&&(identical(other.totalBudgetedCents, totalBudgetedCents) || other.totalBudgetedCents == totalBudgetedCents)&&(identical(other.totalSpentCents, totalSpentCents) || other.totalSpentCents == totalSpentCents)&&(identical(other.totalAvailableCents, totalAvailableCents) || other.totalAvailableCents == totalAvailableCents));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(_envelopes),const DeepCollectionEquality().hash(_monthlyEnvelopes),totalBudgetedCents,totalSpentCents,totalAvailableCents);

@override
String toString() {
  return 'CategoryWithEnvelopes(category: $category, envelopes: $envelopes, monthlyEnvelopes: $monthlyEnvelopes, totalBudgetedCents: $totalBudgetedCents, totalSpentCents: $totalSpentCents, totalAvailableCents: $totalAvailableCents)';
}


}

/// @nodoc
abstract mixin class _$CategoryWithEnvelopesCopyWith<$Res> implements $CategoryWithEnvelopesCopyWith<$Res> {
  factory _$CategoryWithEnvelopesCopyWith(_CategoryWithEnvelopes value, $Res Function(_CategoryWithEnvelopes) _then) = __$CategoryWithEnvelopesCopyWithImpl;
@override @useResult
$Res call({
 Category category, List<Envelope> envelopes, List<MonthlyEnvelopeData> monthlyEnvelopes, int totalBudgetedCents, int totalSpentCents, int totalAvailableCents
});




}
/// @nodoc
class __$CategoryWithEnvelopesCopyWithImpl<$Res>
    implements _$CategoryWithEnvelopesCopyWith<$Res> {
  __$CategoryWithEnvelopesCopyWithImpl(this._self, this._then);

  final _CategoryWithEnvelopes _self;
  final $Res Function(_CategoryWithEnvelopes) _then;

/// Create a copy of CategoryWithEnvelopes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? envelopes = null,Object? monthlyEnvelopes = null,Object? totalBudgetedCents = null,Object? totalSpentCents = null,Object? totalAvailableCents = null,}) {
  return _then(_CategoryWithEnvelopes(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,envelopes: null == envelopes ? _self._envelopes : envelopes // ignore: cast_nullable_to_non_nullable
as List<Envelope>,monthlyEnvelopes: null == monthlyEnvelopes ? _self._monthlyEnvelopes : monthlyEnvelopes // ignore: cast_nullable_to_non_nullable
as List<MonthlyEnvelopeData>,totalBudgetedCents: null == totalBudgetedCents ? _self.totalBudgetedCents : totalBudgetedCents // ignore: cast_nullable_to_non_nullable
as int,totalSpentCents: null == totalSpentCents ? _self.totalSpentCents : totalSpentCents // ignore: cast_nullable_to_non_nullable
as int,totalAvailableCents: null == totalAvailableCents ? _self.totalAvailableCents : totalAvailableCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$BudgetSummary {

 Budget get budget; List<CategoryWithEnvelopes> get categories; int get totalIncomeCents; int get totalBudgetedCents; int get readyToAssignCents; int get year; int get month;
/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetSummaryCopyWith<BudgetSummary> get copyWith => _$BudgetSummaryCopyWithImpl<BudgetSummary>(this as BudgetSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetSummary&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.totalIncomeCents, totalIncomeCents) || other.totalIncomeCents == totalIncomeCents)&&(identical(other.totalBudgetedCents, totalBudgetedCents) || other.totalBudgetedCents == totalBudgetedCents)&&(identical(other.readyToAssignCents, readyToAssignCents) || other.readyToAssignCents == readyToAssignCents)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month));
}


@override
int get hashCode => Object.hash(runtimeType,budget,const DeepCollectionEquality().hash(categories),totalIncomeCents,totalBudgetedCents,readyToAssignCents,year,month);

@override
String toString() {
  return 'BudgetSummary(budget: $budget, categories: $categories, totalIncomeCents: $totalIncomeCents, totalBudgetedCents: $totalBudgetedCents, readyToAssignCents: $readyToAssignCents, year: $year, month: $month)';
}


}

/// @nodoc
abstract mixin class $BudgetSummaryCopyWith<$Res>  {
  factory $BudgetSummaryCopyWith(BudgetSummary value, $Res Function(BudgetSummary) _then) = _$BudgetSummaryCopyWithImpl;
@useResult
$Res call({
 Budget budget, List<CategoryWithEnvelopes> categories, int totalIncomeCents, int totalBudgetedCents, int readyToAssignCents, int year, int month
});




}
/// @nodoc
class _$BudgetSummaryCopyWithImpl<$Res>
    implements $BudgetSummaryCopyWith<$Res> {
  _$BudgetSummaryCopyWithImpl(this._self, this._then);

  final BudgetSummary _self;
  final $Res Function(BudgetSummary) _then;

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? budget = null,Object? categories = null,Object? totalIncomeCents = null,Object? totalBudgetedCents = null,Object? readyToAssignCents = null,Object? year = null,Object? month = null,}) {
  return _then(_self.copyWith(
budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as Budget,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryWithEnvelopes>,totalIncomeCents: null == totalIncomeCents ? _self.totalIncomeCents : totalIncomeCents // ignore: cast_nullable_to_non_nullable
as int,totalBudgetedCents: null == totalBudgetedCents ? _self.totalBudgetedCents : totalBudgetedCents // ignore: cast_nullable_to_non_nullable
as int,readyToAssignCents: null == readyToAssignCents ? _self.readyToAssignCents : readyToAssignCents // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetSummary].
extension BudgetSummaryPatterns on BudgetSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetSummary value)  $default,){
final _that = this;
switch (_that) {
case _BudgetSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetSummary value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Budget budget,  List<CategoryWithEnvelopes> categories,  int totalIncomeCents,  int totalBudgetedCents,  int readyToAssignCents,  int year,  int month)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.budget,_that.categories,_that.totalIncomeCents,_that.totalBudgetedCents,_that.readyToAssignCents,_that.year,_that.month);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Budget budget,  List<CategoryWithEnvelopes> categories,  int totalIncomeCents,  int totalBudgetedCents,  int readyToAssignCents,  int year,  int month)  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary():
return $default(_that.budget,_that.categories,_that.totalIncomeCents,_that.totalBudgetedCents,_that.readyToAssignCents,_that.year,_that.month);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Budget budget,  List<CategoryWithEnvelopes> categories,  int totalIncomeCents,  int totalBudgetedCents,  int readyToAssignCents,  int year,  int month)?  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.budget,_that.categories,_that.totalIncomeCents,_that.totalBudgetedCents,_that.readyToAssignCents,_that.year,_that.month);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetSummary implements BudgetSummary {
  const _BudgetSummary({required this.budget, required final  List<CategoryWithEnvelopes> categories, required this.totalIncomeCents, required this.totalBudgetedCents, required this.readyToAssignCents, required this.year, required this.month}): _categories = categories;
  

@override final  Budget budget;
 final  List<CategoryWithEnvelopes> _categories;
@override List<CategoryWithEnvelopes> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override final  int totalIncomeCents;
@override final  int totalBudgetedCents;
@override final  int readyToAssignCents;
@override final  int year;
@override final  int month;

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetSummaryCopyWith<_BudgetSummary> get copyWith => __$BudgetSummaryCopyWithImpl<_BudgetSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetSummary&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.totalIncomeCents, totalIncomeCents) || other.totalIncomeCents == totalIncomeCents)&&(identical(other.totalBudgetedCents, totalBudgetedCents) || other.totalBudgetedCents == totalBudgetedCents)&&(identical(other.readyToAssignCents, readyToAssignCents) || other.readyToAssignCents == readyToAssignCents)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month));
}


@override
int get hashCode => Object.hash(runtimeType,budget,const DeepCollectionEquality().hash(_categories),totalIncomeCents,totalBudgetedCents,readyToAssignCents,year,month);

@override
String toString() {
  return 'BudgetSummary(budget: $budget, categories: $categories, totalIncomeCents: $totalIncomeCents, totalBudgetedCents: $totalBudgetedCents, readyToAssignCents: $readyToAssignCents, year: $year, month: $month)';
}


}

/// @nodoc
abstract mixin class _$BudgetSummaryCopyWith<$Res> implements $BudgetSummaryCopyWith<$Res> {
  factory _$BudgetSummaryCopyWith(_BudgetSummary value, $Res Function(_BudgetSummary) _then) = __$BudgetSummaryCopyWithImpl;
@override @useResult
$Res call({
 Budget budget, List<CategoryWithEnvelopes> categories, int totalIncomeCents, int totalBudgetedCents, int readyToAssignCents, int year, int month
});




}
/// @nodoc
class __$BudgetSummaryCopyWithImpl<$Res>
    implements _$BudgetSummaryCopyWith<$Res> {
  __$BudgetSummaryCopyWithImpl(this._self, this._then);

  final _BudgetSummary _self;
  final $Res Function(_BudgetSummary) _then;

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? budget = null,Object? categories = null,Object? totalIncomeCents = null,Object? totalBudgetedCents = null,Object? readyToAssignCents = null,Object? year = null,Object? month = null,}) {
  return _then(_BudgetSummary(
budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as Budget,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryWithEnvelopes>,totalIncomeCents: null == totalIncomeCents ? _self.totalIncomeCents : totalIncomeCents // ignore: cast_nullable_to_non_nullable
as int,totalBudgetedCents: null == totalBudgetedCents ? _self.totalBudgetedCents : totalBudgetedCents // ignore: cast_nullable_to_non_nullable
as int,readyToAssignCents: null == readyToAssignCents ? _self.readyToAssignCents : readyToAssignCents // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
