// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_access_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AgentAccessFailure {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentAccessFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentAccessFailure()';
}


}

/// @nodoc
class $AgentAccessFailureCopyWith<$Res>  {
$AgentAccessFailureCopyWith(AgentAccessFailure _, $Res Function(AgentAccessFailure) __);
}


/// Adds pattern-matching-related methods to [AgentAccessFailure].
extension AgentAccessFailurePatterns on AgentAccessFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AgentAccessValidationFailure value)?  validation,TResult Function( AgentAccessUnknownFailure value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AgentAccessValidationFailure() when validation != null:
return validation(_that);case AgentAccessUnknownFailure() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AgentAccessValidationFailure value)  validation,required TResult Function( AgentAccessUnknownFailure value)  unknown,}){
final _that = this;
switch (_that) {
case AgentAccessValidationFailure():
return validation(_that);case AgentAccessUnknownFailure():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AgentAccessValidationFailure value)?  validation,TResult? Function( AgentAccessUnknownFailure value)?  unknown,}){
final _that = this;
switch (_that) {
case AgentAccessValidationFailure() when validation != null:
return validation(_that);case AgentAccessUnknownFailure() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message)?  validation,TResult Function()?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AgentAccessValidationFailure() when validation != null:
return validation(_that.message);case AgentAccessUnknownFailure() when unknown != null:
return unknown();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message)  validation,required TResult Function()  unknown,}) {final _that = this;
switch (_that) {
case AgentAccessValidationFailure():
return validation(_that.message);case AgentAccessUnknownFailure():
return unknown();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message)?  validation,TResult? Function()?  unknown,}) {final _that = this;
switch (_that) {
case AgentAccessValidationFailure() when validation != null:
return validation(_that.message);case AgentAccessUnknownFailure() when unknown != null:
return unknown();case _:
  return null;

}
}

}

/// @nodoc


class AgentAccessValidationFailure implements AgentAccessFailure {
  const AgentAccessValidationFailure({required this.message});
  

 final  String message;

/// Create a copy of AgentAccessFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentAccessValidationFailureCopyWith<AgentAccessValidationFailure> get copyWith => _$AgentAccessValidationFailureCopyWithImpl<AgentAccessValidationFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentAccessValidationFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AgentAccessFailure.validation(message: $message)';
}


}

/// @nodoc
abstract mixin class $AgentAccessValidationFailureCopyWith<$Res> implements $AgentAccessFailureCopyWith<$Res> {
  factory $AgentAccessValidationFailureCopyWith(AgentAccessValidationFailure value, $Res Function(AgentAccessValidationFailure) _then) = _$AgentAccessValidationFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AgentAccessValidationFailureCopyWithImpl<$Res>
    implements $AgentAccessValidationFailureCopyWith<$Res> {
  _$AgentAccessValidationFailureCopyWithImpl(this._self, this._then);

  final AgentAccessValidationFailure _self;
  final $Res Function(AgentAccessValidationFailure) _then;

/// Create a copy of AgentAccessFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AgentAccessValidationFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AgentAccessUnknownFailure implements AgentAccessFailure {
  const AgentAccessUnknownFailure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentAccessUnknownFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentAccessFailure.unknown()';
}


}




/// @nodoc
mixin _$AgentAccessState {

 List<AgentAccessTokenView> get tokens; bool get isCreating; UuidValue? get revokingId; AgentAccessFailure? get failure;
/// Create a copy of AgentAccessState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentAccessStateCopyWith<AgentAccessState> get copyWith => _$AgentAccessStateCopyWithImpl<AgentAccessState>(this as AgentAccessState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AgentAccessState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentAccessState&&const DeepCollectionEquality().equals(other.tokens, _this.tokens)&&(identical(other.isCreating, _this.isCreating) || other.isCreating == _this.isCreating)&&(identical(other.revokingId, _this.revokingId) || other.revokingId == _this.revokingId)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as AgentAccessState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.tokens),_this.isCreating,_this.revokingId,_this.failure);
}

@override
String toString() {
  final _this = this as AgentAccessState;
  return 'AgentAccessState(tokens: ${_this.tokens}, isCreating: ${_this.isCreating}, revokingId: ${_this.revokingId}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $AgentAccessStateCopyWith<$Res>  {
  factory $AgentAccessStateCopyWith(AgentAccessState value, $Res Function(AgentAccessState) _then) = _$AgentAccessStateCopyWithImpl;
@useResult
$Res call({
 List<AgentAccessTokenView> tokens, bool isCreating, UuidValue? revokingId, AgentAccessFailure? failure
});


$AgentAccessFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$AgentAccessStateCopyWithImpl<$Res>
    implements $AgentAccessStateCopyWith<$Res> {
  _$AgentAccessStateCopyWithImpl(this._self, this._then);

  final AgentAccessState _self;
  final $Res Function(AgentAccessState) _then;

/// Create a copy of AgentAccessState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokens = null,Object? isCreating = null,Object? revokingId = freezed,Object? failure = freezed,}) {
  return _then(AgentAccessState(
tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as List<AgentAccessTokenView>,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,revokingId: freezed == revokingId ? _self.revokingId : revokingId // ignore: cast_nullable_to_non_nullable
as UuidValue?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AgentAccessFailure?,
  ));
}
/// Create a copy of AgentAccessState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentAccessFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AgentAccessFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}


/// Adds pattern-matching-related methods to [AgentAccessState].
extension AgentAccessStatePatterns on AgentAccessState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentAccessState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentAccessState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentAccessState value)  $default,){
final _that = this;
switch (_that) {
case _AgentAccessState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentAccessState value)?  $default,){
final _that = this;
switch (_that) {
case _AgentAccessState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AgentAccessTokenView> tokens,  bool isCreating,  UuidValue? revokingId,  AgentAccessFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentAccessState() when $default != null:
return $default(_that.tokens,_that.isCreating,_that.revokingId,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AgentAccessTokenView> tokens,  bool isCreating,  UuidValue? revokingId,  AgentAccessFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _AgentAccessState():
return $default(_that.tokens,_that.isCreating,_that.revokingId,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AgentAccessTokenView> tokens,  bool isCreating,  UuidValue? revokingId,  AgentAccessFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _AgentAccessState() when $default != null:
return $default(_that.tokens,_that.isCreating,_that.revokingId,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _AgentAccessState implements AgentAccessState {
  const _AgentAccessState({ List<AgentAccessTokenView> tokens = const <AgentAccessTokenView>[], this.isCreating = false, this.revokingId, this.failure}): _tokens = tokens;
  

 final  List<AgentAccessTokenView> _tokens;
@override@JsonKey() List<AgentAccessTokenView> get tokens {
  if (_tokens is EqualUnmodifiableListView) return _tokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tokens);
}

@override@JsonKey() final  bool isCreating;
@override final  UuidValue? revokingId;
@override final  AgentAccessFailure? failure;

/// Create a copy of AgentAccessState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentAccessStateCopyWith<_AgentAccessState> get copyWith => __$AgentAccessStateCopyWithImpl<_AgentAccessState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentAccessState&&const DeepCollectionEquality().equals(other.tokens, _tokens)&&(identical(other.isCreating, isCreating) || other.isCreating == isCreating)&&(identical(other.revokingId, revokingId) || other.revokingId == revokingId)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_tokens),isCreating,revokingId,failure);
}

@override
String toString() {
    return 'AgentAccessState(tokens: $tokens, isCreating: $isCreating, revokingId: $revokingId, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$AgentAccessStateCopyWith<$Res> implements $AgentAccessStateCopyWith<$Res> {
  factory _$AgentAccessStateCopyWith(_AgentAccessState value, $Res Function(_AgentAccessState) _then) = __$AgentAccessStateCopyWithImpl;
@override @useResult
$Res call({
 List<AgentAccessTokenView> tokens, bool isCreating, UuidValue? revokingId, AgentAccessFailure? failure
});


@override $AgentAccessFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$AgentAccessStateCopyWithImpl<$Res>
    implements _$AgentAccessStateCopyWith<$Res> {
  __$AgentAccessStateCopyWithImpl(this._self, this._then);

  final _AgentAccessState _self;
  final $Res Function(_AgentAccessState) _then;

/// Create a copy of AgentAccessState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokens = null,Object? isCreating = null,Object? revokingId = freezed,Object? failure = freezed,}) {
  return _then(_AgentAccessState(
tokens: null == tokens ? _self._tokens : tokens // ignore: cast_nullable_to_non_nullable
as List<AgentAccessTokenView>,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,revokingId: freezed == revokingId ? _self.revokingId : revokingId // ignore: cast_nullable_to_non_nullable
as UuidValue?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AgentAccessFailure?,
  ));
}

/// Create a copy of AgentAccessState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentAccessFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AgentAccessFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
