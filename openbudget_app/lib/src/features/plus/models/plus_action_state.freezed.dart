// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plus_action_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlusActionState {

 bool get isBusy; PlusActionKind? get running; PlusActionFailure? get failure;
/// Create a copy of PlusActionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlusActionStateCopyWith<PlusActionState> get copyWith => _$PlusActionStateCopyWithImpl<PlusActionState>(this as PlusActionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlusActionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlusActionState&&(identical(other.isBusy, _this.isBusy) || other.isBusy == _this.isBusy)&&(identical(other.running, _this.running) || other.running == _this.running)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as PlusActionState;
  return Object.hash(runtimeType,_this.isBusy,_this.running,_this.failure);
}

@override
String toString() {
  final _this = this as PlusActionState;
  return 'PlusActionState(isBusy: ${_this.isBusy}, running: ${_this.running}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $PlusActionStateCopyWith<$Res>  {
  factory $PlusActionStateCopyWith(PlusActionState value, $Res Function(PlusActionState) _then) = _$PlusActionStateCopyWithImpl;
@useResult
$Res call({
 bool isBusy, PlusActionKind? running, PlusActionFailure? failure
});




}
/// @nodoc
class _$PlusActionStateCopyWithImpl<$Res>
    implements $PlusActionStateCopyWith<$Res> {
  _$PlusActionStateCopyWithImpl(this._self, this._then);

  final PlusActionState _self;
  final $Res Function(PlusActionState) _then;

/// Create a copy of PlusActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isBusy = null,Object? running = freezed,Object? failure = freezed,}) {
  return _then(PlusActionState(
isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,running: freezed == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as PlusActionKind?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PlusActionFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlusActionState].
extension PlusActionStatePatterns on PlusActionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlusActionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlusActionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlusActionState value)  $default,){
final _that = this;
switch (_that) {
case _PlusActionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlusActionState value)?  $default,){
final _that = this;
switch (_that) {
case _PlusActionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isBusy,  PlusActionKind? running,  PlusActionFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlusActionState() when $default != null:
return $default(_that.isBusy,_that.running,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isBusy,  PlusActionKind? running,  PlusActionFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _PlusActionState():
return $default(_that.isBusy,_that.running,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isBusy,  PlusActionKind? running,  PlusActionFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _PlusActionState() when $default != null:
return $default(_that.isBusy,_that.running,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _PlusActionState implements PlusActionState {
  const _PlusActionState({this.isBusy = false, this.running, this.failure});
  

@override@JsonKey() final  bool isBusy;
@override final  PlusActionKind? running;
@override final  PlusActionFailure? failure;

/// Create a copy of PlusActionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlusActionStateCopyWith<_PlusActionState> get copyWith => __$PlusActionStateCopyWithImpl<_PlusActionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlusActionState&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.running, running) || other.running == running)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isBusy,running,failure);
}

@override
String toString() {
    return 'PlusActionState(isBusy: $isBusy, running: $running, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$PlusActionStateCopyWith<$Res> implements $PlusActionStateCopyWith<$Res> {
  factory _$PlusActionStateCopyWith(_PlusActionState value, $Res Function(_PlusActionState) _then) = __$PlusActionStateCopyWithImpl;
@override @useResult
$Res call({
 bool isBusy, PlusActionKind? running, PlusActionFailure? failure
});




}
/// @nodoc
class __$PlusActionStateCopyWithImpl<$Res>
    implements _$PlusActionStateCopyWith<$Res> {
  __$PlusActionStateCopyWithImpl(this._self, this._then);

  final _PlusActionState _self;
  final $Res Function(_PlusActionState) _then;

/// Create a copy of PlusActionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isBusy = null,Object? running = freezed,Object? failure = freezed,}) {
  return _then(_PlusActionState(
isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,running: freezed == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as PlusActionKind?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PlusActionFailure?,
  ));
}


}

// dart format on
