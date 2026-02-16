// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_assign_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AutoAssignItem {

 String get envelopeId; String get envelopeName; int get currentAllocatedCents; int get proposedAllocatedCents; int get addedCents;
/// Create a copy of AutoAssignItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoAssignItemCopyWith<AutoAssignItem> get copyWith => _$AutoAssignItemCopyWithImpl<AutoAssignItem>(this as AutoAssignItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoAssignItem&&(identical(other.envelopeId, envelopeId) || other.envelopeId == envelopeId)&&(identical(other.envelopeName, envelopeName) || other.envelopeName == envelopeName)&&(identical(other.currentAllocatedCents, currentAllocatedCents) || other.currentAllocatedCents == currentAllocatedCents)&&(identical(other.proposedAllocatedCents, proposedAllocatedCents) || other.proposedAllocatedCents == proposedAllocatedCents)&&(identical(other.addedCents, addedCents) || other.addedCents == addedCents));
}


@override
int get hashCode => Object.hash(runtimeType,envelopeId,envelopeName,currentAllocatedCents,proposedAllocatedCents,addedCents);

@override
String toString() {
  return 'AutoAssignItem(envelopeId: $envelopeId, envelopeName: $envelopeName, currentAllocatedCents: $currentAllocatedCents, proposedAllocatedCents: $proposedAllocatedCents, addedCents: $addedCents)';
}


}

/// @nodoc
abstract mixin class $AutoAssignItemCopyWith<$Res>  {
  factory $AutoAssignItemCopyWith(AutoAssignItem value, $Res Function(AutoAssignItem) _then) = _$AutoAssignItemCopyWithImpl;
@useResult
$Res call({
 String envelopeId, String envelopeName, int currentAllocatedCents, int proposedAllocatedCents, int addedCents
});




}
/// @nodoc
class _$AutoAssignItemCopyWithImpl<$Res>
    implements $AutoAssignItemCopyWith<$Res> {
  _$AutoAssignItemCopyWithImpl(this._self, this._then);

  final AutoAssignItem _self;
  final $Res Function(AutoAssignItem) _then;

/// Create a copy of AutoAssignItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? envelopeId = null,Object? envelopeName = null,Object? currentAllocatedCents = null,Object? proposedAllocatedCents = null,Object? addedCents = null,}) {
  return _then(_self.copyWith(
envelopeId: null == envelopeId ? _self.envelopeId : envelopeId // ignore: cast_nullable_to_non_nullable
as String,envelopeName: null == envelopeName ? _self.envelopeName : envelopeName // ignore: cast_nullable_to_non_nullable
as String,currentAllocatedCents: null == currentAllocatedCents ? _self.currentAllocatedCents : currentAllocatedCents // ignore: cast_nullable_to_non_nullable
as int,proposedAllocatedCents: null == proposedAllocatedCents ? _self.proposedAllocatedCents : proposedAllocatedCents // ignore: cast_nullable_to_non_nullable
as int,addedCents: null == addedCents ? _self.addedCents : addedCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoAssignItem].
extension AutoAssignItemPatterns on AutoAssignItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutoAssignItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutoAssignItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutoAssignItem value)  $default,){
final _that = this;
switch (_that) {
case _AutoAssignItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutoAssignItem value)?  $default,){
final _that = this;
switch (_that) {
case _AutoAssignItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String envelopeId,  String envelopeName,  int currentAllocatedCents,  int proposedAllocatedCents,  int addedCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutoAssignItem() when $default != null:
return $default(_that.envelopeId,_that.envelopeName,_that.currentAllocatedCents,_that.proposedAllocatedCents,_that.addedCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String envelopeId,  String envelopeName,  int currentAllocatedCents,  int proposedAllocatedCents,  int addedCents)  $default,) {final _that = this;
switch (_that) {
case _AutoAssignItem():
return $default(_that.envelopeId,_that.envelopeName,_that.currentAllocatedCents,_that.proposedAllocatedCents,_that.addedCents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String envelopeId,  String envelopeName,  int currentAllocatedCents,  int proposedAllocatedCents,  int addedCents)?  $default,) {final _that = this;
switch (_that) {
case _AutoAssignItem() when $default != null:
return $default(_that.envelopeId,_that.envelopeName,_that.currentAllocatedCents,_that.proposedAllocatedCents,_that.addedCents);case _:
  return null;

}
}

}

/// @nodoc


class _AutoAssignItem implements AutoAssignItem {
  const _AutoAssignItem({required this.envelopeId, required this.envelopeName, required this.currentAllocatedCents, required this.proposedAllocatedCents, required this.addedCents});
  

@override final  String envelopeId;
@override final  String envelopeName;
@override final  int currentAllocatedCents;
@override final  int proposedAllocatedCents;
@override final  int addedCents;

/// Create a copy of AutoAssignItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutoAssignItemCopyWith<_AutoAssignItem> get copyWith => __$AutoAssignItemCopyWithImpl<_AutoAssignItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutoAssignItem&&(identical(other.envelopeId, envelopeId) || other.envelopeId == envelopeId)&&(identical(other.envelopeName, envelopeName) || other.envelopeName == envelopeName)&&(identical(other.currentAllocatedCents, currentAllocatedCents) || other.currentAllocatedCents == currentAllocatedCents)&&(identical(other.proposedAllocatedCents, proposedAllocatedCents) || other.proposedAllocatedCents == proposedAllocatedCents)&&(identical(other.addedCents, addedCents) || other.addedCents == addedCents));
}


@override
int get hashCode => Object.hash(runtimeType,envelopeId,envelopeName,currentAllocatedCents,proposedAllocatedCents,addedCents);

@override
String toString() {
  return 'AutoAssignItem(envelopeId: $envelopeId, envelopeName: $envelopeName, currentAllocatedCents: $currentAllocatedCents, proposedAllocatedCents: $proposedAllocatedCents, addedCents: $addedCents)';
}


}

/// @nodoc
abstract mixin class _$AutoAssignItemCopyWith<$Res> implements $AutoAssignItemCopyWith<$Res> {
  factory _$AutoAssignItemCopyWith(_AutoAssignItem value, $Res Function(_AutoAssignItem) _then) = __$AutoAssignItemCopyWithImpl;
@override @useResult
$Res call({
 String envelopeId, String envelopeName, int currentAllocatedCents, int proposedAllocatedCents, int addedCents
});




}
/// @nodoc
class __$AutoAssignItemCopyWithImpl<$Res>
    implements _$AutoAssignItemCopyWith<$Res> {
  __$AutoAssignItemCopyWithImpl(this._self, this._then);

  final _AutoAssignItem _self;
  final $Res Function(_AutoAssignItem) _then;

/// Create a copy of AutoAssignItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? envelopeId = null,Object? envelopeName = null,Object? currentAllocatedCents = null,Object? proposedAllocatedCents = null,Object? addedCents = null,}) {
  return _then(_AutoAssignItem(
envelopeId: null == envelopeId ? _self.envelopeId : envelopeId // ignore: cast_nullable_to_non_nullable
as String,envelopeName: null == envelopeName ? _self.envelopeName : envelopeName // ignore: cast_nullable_to_non_nullable
as String,currentAllocatedCents: null == currentAllocatedCents ? _self.currentAllocatedCents : currentAllocatedCents // ignore: cast_nullable_to_non_nullable
as int,proposedAllocatedCents: null == proposedAllocatedCents ? _self.proposedAllocatedCents : proposedAllocatedCents // ignore: cast_nullable_to_non_nullable
as int,addedCents: null == addedCents ? _self.addedCents : addedCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AutoAssignProposal {

 List<AutoAssignItem> get items; int get totalToAssignCents; int get totalAssignedCents;
/// Create a copy of AutoAssignProposal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoAssignProposalCopyWith<AutoAssignProposal> get copyWith => _$AutoAssignProposalCopyWithImpl<AutoAssignProposal>(this as AutoAssignProposal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoAssignProposal&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalToAssignCents, totalToAssignCents) || other.totalToAssignCents == totalToAssignCents)&&(identical(other.totalAssignedCents, totalAssignedCents) || other.totalAssignedCents == totalAssignedCents));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalToAssignCents,totalAssignedCents);

@override
String toString() {
  return 'AutoAssignProposal(items: $items, totalToAssignCents: $totalToAssignCents, totalAssignedCents: $totalAssignedCents)';
}


}

/// @nodoc
abstract mixin class $AutoAssignProposalCopyWith<$Res>  {
  factory $AutoAssignProposalCopyWith(AutoAssignProposal value, $Res Function(AutoAssignProposal) _then) = _$AutoAssignProposalCopyWithImpl;
@useResult
$Res call({
 List<AutoAssignItem> items, int totalToAssignCents, int totalAssignedCents
});




}
/// @nodoc
class _$AutoAssignProposalCopyWithImpl<$Res>
    implements $AutoAssignProposalCopyWith<$Res> {
  _$AutoAssignProposalCopyWithImpl(this._self, this._then);

  final AutoAssignProposal _self;
  final $Res Function(AutoAssignProposal) _then;

/// Create a copy of AutoAssignProposal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalToAssignCents = null,Object? totalAssignedCents = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AutoAssignItem>,totalToAssignCents: null == totalToAssignCents ? _self.totalToAssignCents : totalToAssignCents // ignore: cast_nullable_to_non_nullable
as int,totalAssignedCents: null == totalAssignedCents ? _self.totalAssignedCents : totalAssignedCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoAssignProposal].
extension AutoAssignProposalPatterns on AutoAssignProposal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutoAssignProposal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutoAssignProposal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutoAssignProposal value)  $default,){
final _that = this;
switch (_that) {
case _AutoAssignProposal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutoAssignProposal value)?  $default,){
final _that = this;
switch (_that) {
case _AutoAssignProposal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AutoAssignItem> items,  int totalToAssignCents,  int totalAssignedCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutoAssignProposal() when $default != null:
return $default(_that.items,_that.totalToAssignCents,_that.totalAssignedCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AutoAssignItem> items,  int totalToAssignCents,  int totalAssignedCents)  $default,) {final _that = this;
switch (_that) {
case _AutoAssignProposal():
return $default(_that.items,_that.totalToAssignCents,_that.totalAssignedCents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AutoAssignItem> items,  int totalToAssignCents,  int totalAssignedCents)?  $default,) {final _that = this;
switch (_that) {
case _AutoAssignProposal() when $default != null:
return $default(_that.items,_that.totalToAssignCents,_that.totalAssignedCents);case _:
  return null;

}
}

}

/// @nodoc


class _AutoAssignProposal implements AutoAssignProposal {
  const _AutoAssignProposal({required final  List<AutoAssignItem> items, required this.totalToAssignCents, required this.totalAssignedCents}): _items = items;
  

 final  List<AutoAssignItem> _items;
@override List<AutoAssignItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalToAssignCents;
@override final  int totalAssignedCents;

/// Create a copy of AutoAssignProposal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutoAssignProposalCopyWith<_AutoAssignProposal> get copyWith => __$AutoAssignProposalCopyWithImpl<_AutoAssignProposal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutoAssignProposal&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalToAssignCents, totalToAssignCents) || other.totalToAssignCents == totalToAssignCents)&&(identical(other.totalAssignedCents, totalAssignedCents) || other.totalAssignedCents == totalAssignedCents));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalToAssignCents,totalAssignedCents);

@override
String toString() {
  return 'AutoAssignProposal(items: $items, totalToAssignCents: $totalToAssignCents, totalAssignedCents: $totalAssignedCents)';
}


}

/// @nodoc
abstract mixin class _$AutoAssignProposalCopyWith<$Res> implements $AutoAssignProposalCopyWith<$Res> {
  factory _$AutoAssignProposalCopyWith(_AutoAssignProposal value, $Res Function(_AutoAssignProposal) _then) = __$AutoAssignProposalCopyWithImpl;
@override @useResult
$Res call({
 List<AutoAssignItem> items, int totalToAssignCents, int totalAssignedCents
});




}
/// @nodoc
class __$AutoAssignProposalCopyWithImpl<$Res>
    implements _$AutoAssignProposalCopyWith<$Res> {
  __$AutoAssignProposalCopyWithImpl(this._self, this._then);

  final _AutoAssignProposal _self;
  final $Res Function(_AutoAssignProposal) _then;

/// Create a copy of AutoAssignProposal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalToAssignCents = null,Object? totalAssignedCents = null,}) {
  return _then(_AutoAssignProposal(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AutoAssignItem>,totalToAssignCents: null == totalToAssignCents ? _self.totalToAssignCents : totalToAssignCents // ignore: cast_nullable_to_non_nullable
as int,totalAssignedCents: null == totalAssignedCents ? _self.totalAssignedCents : totalAssignedCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
