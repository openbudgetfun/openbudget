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
mixin _$CategoryWithEnvelopes {

 Category get category; List<Envelope> get envelopes; int get totalBudgetedCents; int get totalSpentCents; int get totalAvailableCents;
/// Create a copy of CategoryWithEnvelopes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryWithEnvelopesCopyWith<CategoryWithEnvelopes> get copyWith => _$CategoryWithEnvelopesCopyWithImpl<CategoryWithEnvelopes>(this as CategoryWithEnvelopes, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryWithEnvelopes&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.envelopes, envelopes)&&(identical(other.totalBudgetedCents, totalBudgetedCents) || other.totalBudgetedCents == totalBudgetedCents)&&(identical(other.totalSpentCents, totalSpentCents) || other.totalSpentCents == totalSpentCents)&&(identical(other.totalAvailableCents, totalAvailableCents) || other.totalAvailableCents == totalAvailableCents));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(envelopes),totalBudgetedCents,totalSpentCents,totalAvailableCents);

@override
String toString() {
  return 'CategoryWithEnvelopes(category: $category, envelopes: $envelopes, totalBudgetedCents: $totalBudgetedCents, totalSpentCents: $totalSpentCents, totalAvailableCents: $totalAvailableCents)';
}


}

/// @nodoc
abstract mixin class $CategoryWithEnvelopesCopyWith<$Res>  {
  factory $CategoryWithEnvelopesCopyWith(CategoryWithEnvelopes value, $Res Function(CategoryWithEnvelopes) _then) = _$CategoryWithEnvelopesCopyWithImpl;
@useResult
$Res call({
 Category category, List<Envelope> envelopes, int totalBudgetedCents, int totalSpentCents, int totalAvailableCents
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
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? envelopes = null,Object? totalBudgetedCents = null,Object? totalSpentCents = null,Object? totalAvailableCents = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,envelopes: null == envelopes ? _self.envelopes : envelopes // ignore: cast_nullable_to_non_nullable
as List<Envelope>,totalBudgetedCents: null == totalBudgetedCents ? _self.totalBudgetedCents : totalBudgetedCents // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Category category,  List<Envelope> envelopes,  int totalBudgetedCents,  int totalSpentCents,  int totalAvailableCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryWithEnvelopes() when $default != null:
return $default(_that.category,_that.envelopes,_that.totalBudgetedCents,_that.totalSpentCents,_that.totalAvailableCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Category category,  List<Envelope> envelopes,  int totalBudgetedCents,  int totalSpentCents,  int totalAvailableCents)  $default,) {final _that = this;
switch (_that) {
case _CategoryWithEnvelopes():
return $default(_that.category,_that.envelopes,_that.totalBudgetedCents,_that.totalSpentCents,_that.totalAvailableCents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Category category,  List<Envelope> envelopes,  int totalBudgetedCents,  int totalSpentCents,  int totalAvailableCents)?  $default,) {final _that = this;
switch (_that) {
case _CategoryWithEnvelopes() when $default != null:
return $default(_that.category,_that.envelopes,_that.totalBudgetedCents,_that.totalSpentCents,_that.totalAvailableCents);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryWithEnvelopes implements CategoryWithEnvelopes {
  const _CategoryWithEnvelopes({required this.category, required final  List<Envelope> envelopes, required this.totalBudgetedCents, required this.totalSpentCents, required this.totalAvailableCents}): _envelopes = envelopes;
  

@override final  Category category;
 final  List<Envelope> _envelopes;
@override List<Envelope> get envelopes {
  if (_envelopes is EqualUnmodifiableListView) return _envelopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_envelopes);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryWithEnvelopes&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._envelopes, _envelopes)&&(identical(other.totalBudgetedCents, totalBudgetedCents) || other.totalBudgetedCents == totalBudgetedCents)&&(identical(other.totalSpentCents, totalSpentCents) || other.totalSpentCents == totalSpentCents)&&(identical(other.totalAvailableCents, totalAvailableCents) || other.totalAvailableCents == totalAvailableCents));
}


@override
int get hashCode => Object.hash(runtimeType,category,const DeepCollectionEquality().hash(_envelopes),totalBudgetedCents,totalSpentCents,totalAvailableCents);

@override
String toString() {
  return 'CategoryWithEnvelopes(category: $category, envelopes: $envelopes, totalBudgetedCents: $totalBudgetedCents, totalSpentCents: $totalSpentCents, totalAvailableCents: $totalAvailableCents)';
}


}

/// @nodoc
abstract mixin class _$CategoryWithEnvelopesCopyWith<$Res> implements $CategoryWithEnvelopesCopyWith<$Res> {
  factory _$CategoryWithEnvelopesCopyWith(_CategoryWithEnvelopes value, $Res Function(_CategoryWithEnvelopes) _then) = __$CategoryWithEnvelopesCopyWithImpl;
@override @useResult
$Res call({
 Category category, List<Envelope> envelopes, int totalBudgetedCents, int totalSpentCents, int totalAvailableCents
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
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? envelopes = null,Object? totalBudgetedCents = null,Object? totalSpentCents = null,Object? totalAvailableCents = null,}) {
  return _then(_CategoryWithEnvelopes(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,envelopes: null == envelopes ? _self._envelopes : envelopes // ignore: cast_nullable_to_non_nullable
as List<Envelope>,totalBudgetedCents: null == totalBudgetedCents ? _self.totalBudgetedCents : totalBudgetedCents // ignore: cast_nullable_to_non_nullable
as int,totalSpentCents: null == totalSpentCents ? _self.totalSpentCents : totalSpentCents // ignore: cast_nullable_to_non_nullable
as int,totalAvailableCents: null == totalAvailableCents ? _self.totalAvailableCents : totalAvailableCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$BudgetSummary {

 Budget get budget; List<CategoryWithEnvelopes> get categories; int get totalIncomeCents; int get totalBudgetedCents; int get readyToAssignCents;
/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetSummaryCopyWith<BudgetSummary> get copyWith => _$BudgetSummaryCopyWithImpl<BudgetSummary>(this as BudgetSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetSummary&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.totalIncomeCents, totalIncomeCents) || other.totalIncomeCents == totalIncomeCents)&&(identical(other.totalBudgetedCents, totalBudgetedCents) || other.totalBudgetedCents == totalBudgetedCents)&&(identical(other.readyToAssignCents, readyToAssignCents) || other.readyToAssignCents == readyToAssignCents));
}


@override
int get hashCode => Object.hash(runtimeType,budget,const DeepCollectionEquality().hash(categories),totalIncomeCents,totalBudgetedCents,readyToAssignCents);

@override
String toString() {
  return 'BudgetSummary(budget: $budget, categories: $categories, totalIncomeCents: $totalIncomeCents, totalBudgetedCents: $totalBudgetedCents, readyToAssignCents: $readyToAssignCents)';
}


}

/// @nodoc
abstract mixin class $BudgetSummaryCopyWith<$Res>  {
  factory $BudgetSummaryCopyWith(BudgetSummary value, $Res Function(BudgetSummary) _then) = _$BudgetSummaryCopyWithImpl;
@useResult
$Res call({
 Budget budget, List<CategoryWithEnvelopes> categories, int totalIncomeCents, int totalBudgetedCents, int readyToAssignCents
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
@pragma('vm:prefer-inline') @override $Res call({Object? budget = null,Object? categories = null,Object? totalIncomeCents = null,Object? totalBudgetedCents = null,Object? readyToAssignCents = null,}) {
  return _then(_self.copyWith(
budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as Budget,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryWithEnvelopes>,totalIncomeCents: null == totalIncomeCents ? _self.totalIncomeCents : totalIncomeCents // ignore: cast_nullable_to_non_nullable
as int,totalBudgetedCents: null == totalBudgetedCents ? _self.totalBudgetedCents : totalBudgetedCents // ignore: cast_nullable_to_non_nullable
as int,readyToAssignCents: null == readyToAssignCents ? _self.readyToAssignCents : readyToAssignCents // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Budget budget,  List<CategoryWithEnvelopes> categories,  int totalIncomeCents,  int totalBudgetedCents,  int readyToAssignCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.budget,_that.categories,_that.totalIncomeCents,_that.totalBudgetedCents,_that.readyToAssignCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Budget budget,  List<CategoryWithEnvelopes> categories,  int totalIncomeCents,  int totalBudgetedCents,  int readyToAssignCents)  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary():
return $default(_that.budget,_that.categories,_that.totalIncomeCents,_that.totalBudgetedCents,_that.readyToAssignCents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Budget budget,  List<CategoryWithEnvelopes> categories,  int totalIncomeCents,  int totalBudgetedCents,  int readyToAssignCents)?  $default,) {final _that = this;
switch (_that) {
case _BudgetSummary() when $default != null:
return $default(_that.budget,_that.categories,_that.totalIncomeCents,_that.totalBudgetedCents,_that.readyToAssignCents);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetSummary implements BudgetSummary {
  const _BudgetSummary({required this.budget, required final  List<CategoryWithEnvelopes> categories, required this.totalIncomeCents, required this.totalBudgetedCents, required this.readyToAssignCents}): _categories = categories;
  

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

/// Create a copy of BudgetSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetSummaryCopyWith<_BudgetSummary> get copyWith => __$BudgetSummaryCopyWithImpl<_BudgetSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetSummary&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.totalIncomeCents, totalIncomeCents) || other.totalIncomeCents == totalIncomeCents)&&(identical(other.totalBudgetedCents, totalBudgetedCents) || other.totalBudgetedCents == totalBudgetedCents)&&(identical(other.readyToAssignCents, readyToAssignCents) || other.readyToAssignCents == readyToAssignCents));
}


@override
int get hashCode => Object.hash(runtimeType,budget,const DeepCollectionEquality().hash(_categories),totalIncomeCents,totalBudgetedCents,readyToAssignCents);

@override
String toString() {
  return 'BudgetSummary(budget: $budget, categories: $categories, totalIncomeCents: $totalIncomeCents, totalBudgetedCents: $totalBudgetedCents, readyToAssignCents: $readyToAssignCents)';
}


}

/// @nodoc
abstract mixin class _$BudgetSummaryCopyWith<$Res> implements $BudgetSummaryCopyWith<$Res> {
  factory _$BudgetSummaryCopyWith(_BudgetSummary value, $Res Function(_BudgetSummary) _then) = __$BudgetSummaryCopyWithImpl;
@override @useResult
$Res call({
 Budget budget, List<CategoryWithEnvelopes> categories, int totalIncomeCents, int totalBudgetedCents, int readyToAssignCents
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
@override @pragma('vm:prefer-inline') $Res call({Object? budget = null,Object? categories = null,Object? totalIncomeCents = null,Object? totalBudgetedCents = null,Object? readyToAssignCents = null,}) {
  return _then(_BudgetSummary(
budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as Budget,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryWithEnvelopes>,totalIncomeCents: null == totalIncomeCents ? _self.totalIncomeCents : totalIncomeCents // ignore: cast_nullable_to_non_nullable
as int,totalBudgetedCents: null == totalBudgetedCents ? _self.totalBudgetedCents : totalBudgetedCents // ignore: cast_nullable_to_non_nullable
as int,readyToAssignCents: null == readyToAssignCents ? _self.readyToAssignCents : readyToAssignCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
