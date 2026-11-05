// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_notes_parser.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReleaseNotesParseResult {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseNotesParseResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReleaseNotesParseResult()';
}


}

/// @nodoc
class $ReleaseNotesParseResultCopyWith<$Res>  {
$ReleaseNotesParseResultCopyWith(ReleaseNotesParseResult _, $Res Function(ReleaseNotesParseResult) __);
}


/// Adds pattern-matching-related methods to [ReleaseNotesParseResult].
extension ReleaseNotesParseResultPatterns on ReleaseNotesParseResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ReleaseNotesParseSuccess value)?  success,TResult Function( ReleaseNotesParseFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ReleaseNotesParseSuccess() when success != null:
return success(_that);case ReleaseNotesParseFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ReleaseNotesParseSuccess value)  success,required TResult Function( ReleaseNotesParseFailure value)  failure,}){
final _that = this;
switch (_that) {
case ReleaseNotesParseSuccess():
return success(_that);case ReleaseNotesParseFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ReleaseNotesParseSuccess value)?  success,TResult? Function( ReleaseNotesParseFailure value)?  failure,}){
final _that = this;
switch (_that) {
case ReleaseNotesParseSuccess() when success != null:
return success(_that);case ReleaseNotesParseFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ReleaseNotes notes)?  success,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ReleaseNotesParseSuccess() when success != null:
return success(_that.notes);case ReleaseNotesParseFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ReleaseNotes notes)  success,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case ReleaseNotesParseSuccess():
return success(_that.notes);case ReleaseNotesParseFailure():
return failure(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ReleaseNotes notes)?  success,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case ReleaseNotesParseSuccess() when success != null:
return success(_that.notes);case ReleaseNotesParseFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ReleaseNotesParseSuccess implements ReleaseNotesParseResult {
  const ReleaseNotesParseSuccess(this.notes);
  

 final  ReleaseNotes notes;

/// Create a copy of ReleaseNotesParseResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseNotesParseSuccessCopyWith<ReleaseNotesParseSuccess> get copyWith => _$ReleaseNotesParseSuccessCopyWithImpl<ReleaseNotesParseSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseNotesParseSuccess&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,notes);
}

@override
String toString() {
    return 'ReleaseNotesParseResult.success(notes: $notes)';
}


}

/// @nodoc
abstract mixin class $ReleaseNotesParseSuccessCopyWith<$Res> implements $ReleaseNotesParseResultCopyWith<$Res> {
  factory $ReleaseNotesParseSuccessCopyWith(ReleaseNotesParseSuccess value, $Res Function(ReleaseNotesParseSuccess) _then) = _$ReleaseNotesParseSuccessCopyWithImpl;
@useResult
$Res call({
 ReleaseNotes notes
});


$ReleaseNotesCopyWith<$Res> get notes;

}
/// @nodoc
class _$ReleaseNotesParseSuccessCopyWithImpl<$Res>
    implements $ReleaseNotesParseSuccessCopyWith<$Res> {
  _$ReleaseNotesParseSuccessCopyWithImpl(this._self, this._then);

  final ReleaseNotesParseSuccess _self;
  final $Res Function(ReleaseNotesParseSuccess) _then;

/// Create a copy of ReleaseNotesParseResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? notes = null,}) {
  return _then(ReleaseNotesParseSuccess(
null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as ReleaseNotes,
  ));
}

/// Create a copy of ReleaseNotesParseResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseNotesCopyWith<$Res> get notes {
  
  return $ReleaseNotesCopyWith<$Res>(_self.notes, (value) {
    return _then(_self.copyWith(notes: value));
  });
}
}

/// @nodoc


class ReleaseNotesParseFailure implements ReleaseNotesParseResult {
  const ReleaseNotesParseFailure(this.message);
  

 final  String message;

/// Create a copy of ReleaseNotesParseResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseNotesParseFailureCopyWith<ReleaseNotesParseFailure> get copyWith => _$ReleaseNotesParseFailureCopyWithImpl<ReleaseNotesParseFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseNotesParseFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'ReleaseNotesParseResult.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $ReleaseNotesParseFailureCopyWith<$Res> implements $ReleaseNotesParseResultCopyWith<$Res> {
  factory $ReleaseNotesParseFailureCopyWith(ReleaseNotesParseFailure value, $Res Function(ReleaseNotesParseFailure) _then) = _$ReleaseNotesParseFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ReleaseNotesParseFailureCopyWithImpl<$Res>
    implements $ReleaseNotesParseFailureCopyWith<$Res> {
  _$ReleaseNotesParseFailureCopyWithImpl(this._self, this._then);

  final ReleaseNotesParseFailure _self;
  final $Res Function(ReleaseNotesParseFailure) _then;

/// Create a copy of ReleaseNotesParseResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ReleaseNotesParseFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
