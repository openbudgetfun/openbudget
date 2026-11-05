// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_proposals_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantProposalsState {

 List<AssistantProposalCard> get pending; List<AssistantProposalCard> get history;
/// Create a copy of AssistantProposalsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantProposalsStateCopyWith<AssistantProposalsState> get copyWith => _$AssistantProposalsStateCopyWithImpl<AssistantProposalsState>(this as AssistantProposalsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssistantProposalsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantProposalsState&&const DeepCollectionEquality().equals(other.pending, _this.pending)&&const DeepCollectionEquality().equals(other.history, _this.history));
}


@override
int get hashCode {
  final _this = this as AssistantProposalsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.pending),const DeepCollectionEquality().hash(_this.history));
}

@override
String toString() {
  final _this = this as AssistantProposalsState;
  return 'AssistantProposalsState(pending: ${_this.pending}, history: ${_this.history})';
}


}

/// @nodoc
abstract mixin class $AssistantProposalsStateCopyWith<$Res>  {
  factory $AssistantProposalsStateCopyWith(AssistantProposalsState value, $Res Function(AssistantProposalsState) _then) = _$AssistantProposalsStateCopyWithImpl;
@useResult
$Res call({
 List<AssistantProposalCard> pending, List<AssistantProposalCard> history
});




}
/// @nodoc
class _$AssistantProposalsStateCopyWithImpl<$Res>
    implements $AssistantProposalsStateCopyWith<$Res> {
  _$AssistantProposalsStateCopyWithImpl(this._self, this._then);

  final AssistantProposalsState _self;
  final $Res Function(AssistantProposalsState) _then;

/// Create a copy of AssistantProposalsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pending = null,Object? history = null,}) {
  return _then(AssistantProposalsState(
pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as List<AssistantProposalCard>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<AssistantProposalCard>,
  ));
}

}


/// Adds pattern-matching-related methods to [AssistantProposalsState].
extension AssistantProposalsStatePatterns on AssistantProposalsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantProposalsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantProposalsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantProposalsState value)  $default,){
final _that = this;
switch (_that) {
case _AssistantProposalsState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantProposalsState value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantProposalsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AssistantProposalCard> pending,  List<AssistantProposalCard> history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantProposalsState() when $default != null:
return $default(_that.pending,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AssistantProposalCard> pending,  List<AssistantProposalCard> history)  $default,) {final _that = this;
switch (_that) {
case _AssistantProposalsState():
return $default(_that.pending,_that.history);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AssistantProposalCard> pending,  List<AssistantProposalCard> history)?  $default,) {final _that = this;
switch (_that) {
case _AssistantProposalsState() when $default != null:
return $default(_that.pending,_that.history);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantProposalsState implements AssistantProposalsState {
  const _AssistantProposalsState({ List<AssistantProposalCard> pending = const [],  List<AssistantProposalCard> history = const []}): _pending = pending,_history = history;
  

 final  List<AssistantProposalCard> _pending;
@override@JsonKey() List<AssistantProposalCard> get pending {
  if (_pending is EqualUnmodifiableListView) return _pending;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pending);
}

 final  List<AssistantProposalCard> _history;
@override@JsonKey() List<AssistantProposalCard> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of AssistantProposalsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantProposalsStateCopyWith<_AssistantProposalsState> get copyWith => __$AssistantProposalsStateCopyWithImpl<_AssistantProposalsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantProposalsState&&const DeepCollectionEquality().equals(other.pending, _pending)&&const DeepCollectionEquality().equals(other.history, _history));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_pending),const DeepCollectionEquality().hash(_history));
}

@override
String toString() {
    return 'AssistantProposalsState(pending: $pending, history: $history)';
}


}

/// @nodoc
abstract mixin class _$AssistantProposalsStateCopyWith<$Res> implements $AssistantProposalsStateCopyWith<$Res> {
  factory _$AssistantProposalsStateCopyWith(_AssistantProposalsState value, $Res Function(_AssistantProposalsState) _then) = __$AssistantProposalsStateCopyWithImpl;
@override @useResult
$Res call({
 List<AssistantProposalCard> pending, List<AssistantProposalCard> history
});




}
/// @nodoc
class __$AssistantProposalsStateCopyWithImpl<$Res>
    implements _$AssistantProposalsStateCopyWith<$Res> {
  __$AssistantProposalsStateCopyWithImpl(this._self, this._then);

  final _AssistantProposalsState _self;
  final $Res Function(_AssistantProposalsState) _then;

/// Create a copy of AssistantProposalsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pending = null,Object? history = null,}) {
  return _then(_AssistantProposalsState(
pending: null == pending ? _self._pending : pending // ignore: cast_nullable_to_non_nullable
as List<AssistantProposalCard>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<AssistantProposalCard>,
  ));
}


}

// dart format on
