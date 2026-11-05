// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whats_new_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WhatsNewNotesResult implements DiagnosticableTreeMixin {

 String get version;
/// Create a copy of WhatsNewNotesResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhatsNewNotesResultCopyWith<WhatsNewNotesResult> get copyWith => _$WhatsNewNotesResultCopyWithImpl<WhatsNewNotesResult>(this as WhatsNewNotesResult, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as WhatsNewNotesResult;
  properties
    ..add(DiagnosticsProperty('type', 'WhatsNewNotesResult'))
    ..add(DiagnosticsProperty('version', _this.version));
}

@override
bool operator ==(Object other) {
  final _this = this as WhatsNewNotesResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhatsNewNotesResult&&(identical(other.version, _this.version) || other.version == _this.version));
}


@override
int get hashCode {
  final _this = this as WhatsNewNotesResult;
  return Object.hash(runtimeType,_this.version);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as WhatsNewNotesResult;
  return 'WhatsNewNotesResult(version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $WhatsNewNotesResultCopyWith<$Res>  {
  factory $WhatsNewNotesResultCopyWith(WhatsNewNotesResult value, $Res Function(WhatsNewNotesResult) _then) = _$WhatsNewNotesResultCopyWithImpl;
@useResult
$Res call({
 String version
});




}
/// @nodoc
class _$WhatsNewNotesResultCopyWithImpl<$Res>
    implements $WhatsNewNotesResultCopyWith<$Res> {
  _$WhatsNewNotesResultCopyWithImpl(this._self, this._then);

  final WhatsNewNotesResult _self;
  final $Res Function(WhatsNewNotesResult) _then;

/// Create a copy of WhatsNewNotesResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WhatsNewNotesResult].
extension WhatsNewNotesResultPatterns on WhatsNewNotesResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WhatsNewNotesAvailable value)?  available,TResult Function( WhatsNewNotesNotFound value)?  notFound,TResult Function( WhatsNewNotesInvalid value)?  invalid,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WhatsNewNotesAvailable() when available != null:
return available(_that);case WhatsNewNotesNotFound() when notFound != null:
return notFound(_that);case WhatsNewNotesInvalid() when invalid != null:
return invalid(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WhatsNewNotesAvailable value)  available,required TResult Function( WhatsNewNotesNotFound value)  notFound,required TResult Function( WhatsNewNotesInvalid value)  invalid,}){
final _that = this;
switch (_that) {
case WhatsNewNotesAvailable():
return available(_that);case WhatsNewNotesNotFound():
return notFound(_that);case WhatsNewNotesInvalid():
return invalid(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WhatsNewNotesAvailable value)?  available,TResult? Function( WhatsNewNotesNotFound value)?  notFound,TResult? Function( WhatsNewNotesInvalid value)?  invalid,}){
final _that = this;
switch (_that) {
case WhatsNewNotesAvailable() when available != null:
return available(_that);case WhatsNewNotesNotFound() when notFound != null:
return notFound(_that);case WhatsNewNotesInvalid() when invalid != null:
return invalid(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String version,  ReleaseNotes notes)?  available,TResult Function( String version)?  notFound,TResult Function( String version,  String message)?  invalid,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WhatsNewNotesAvailable() when available != null:
return available(_that.version,_that.notes);case WhatsNewNotesNotFound() when notFound != null:
return notFound(_that.version);case WhatsNewNotesInvalid() when invalid != null:
return invalid(_that.version,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String version,  ReleaseNotes notes)  available,required TResult Function( String version)  notFound,required TResult Function( String version,  String message)  invalid,}) {final _that = this;
switch (_that) {
case WhatsNewNotesAvailable():
return available(_that.version,_that.notes);case WhatsNewNotesNotFound():
return notFound(_that.version);case WhatsNewNotesInvalid():
return invalid(_that.version,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String version,  ReleaseNotes notes)?  available,TResult? Function( String version)?  notFound,TResult? Function( String version,  String message)?  invalid,}) {final _that = this;
switch (_that) {
case WhatsNewNotesAvailable() when available != null:
return available(_that.version,_that.notes);case WhatsNewNotesNotFound() when notFound != null:
return notFound(_that.version);case WhatsNewNotesInvalid() when invalid != null:
return invalid(_that.version,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class WhatsNewNotesAvailable with DiagnosticableTreeMixin implements WhatsNewNotesResult {
  const WhatsNewNotesAvailable({required this.version, required this.notes});
  

@override final  String version;
 final  ReleaseNotes notes;

/// Create a copy of WhatsNewNotesResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhatsNewNotesAvailableCopyWith<WhatsNewNotesAvailable> get copyWith => _$WhatsNewNotesAvailableCopyWithImpl<WhatsNewNotesAvailable>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'WhatsNewNotesResult.available'))
    ..add(DiagnosticsProperty('version', version))..add(DiagnosticsProperty('notes', notes));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WhatsNewNotesAvailable&&(identical(other.version, version) || other.version == version)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,version,notes);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'WhatsNewNotesResult.available(version: $version, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $WhatsNewNotesAvailableCopyWith<$Res> implements $WhatsNewNotesResultCopyWith<$Res> {
  factory $WhatsNewNotesAvailableCopyWith(WhatsNewNotesAvailable value, $Res Function(WhatsNewNotesAvailable) _then) = _$WhatsNewNotesAvailableCopyWithImpl;
@override @useResult
$Res call({
 String version, ReleaseNotes notes
});


$ReleaseNotesCopyWith<$Res> get notes;

}
/// @nodoc
class _$WhatsNewNotesAvailableCopyWithImpl<$Res>
    implements $WhatsNewNotesAvailableCopyWith<$Res> {
  _$WhatsNewNotesAvailableCopyWithImpl(this._self, this._then);

  final WhatsNewNotesAvailable _self;
  final $Res Function(WhatsNewNotesAvailable) _then;

/// Create a copy of WhatsNewNotesResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? notes = null,}) {
  return _then(WhatsNewNotesAvailable(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as ReleaseNotes,
  ));
}

/// Create a copy of WhatsNewNotesResult
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


class WhatsNewNotesNotFound with DiagnosticableTreeMixin implements WhatsNewNotesResult {
  const WhatsNewNotesNotFound({required this.version});
  

@override final  String version;

/// Create a copy of WhatsNewNotesResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhatsNewNotesNotFoundCopyWith<WhatsNewNotesNotFound> get copyWith => _$WhatsNewNotesNotFoundCopyWithImpl<WhatsNewNotesNotFound>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'WhatsNewNotesResult.notFound'))
    ..add(DiagnosticsProperty('version', version));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WhatsNewNotesNotFound&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode {
    return Object.hash(runtimeType,version);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'WhatsNewNotesResult.notFound(version: $version)';
}


}

/// @nodoc
abstract mixin class $WhatsNewNotesNotFoundCopyWith<$Res> implements $WhatsNewNotesResultCopyWith<$Res> {
  factory $WhatsNewNotesNotFoundCopyWith(WhatsNewNotesNotFound value, $Res Function(WhatsNewNotesNotFound) _then) = _$WhatsNewNotesNotFoundCopyWithImpl;
@override @useResult
$Res call({
 String version
});




}
/// @nodoc
class _$WhatsNewNotesNotFoundCopyWithImpl<$Res>
    implements $WhatsNewNotesNotFoundCopyWith<$Res> {
  _$WhatsNewNotesNotFoundCopyWithImpl(this._self, this._then);

  final WhatsNewNotesNotFound _self;
  final $Res Function(WhatsNewNotesNotFound) _then;

/// Create a copy of WhatsNewNotesResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,}) {
  return _then(WhatsNewNotesNotFound(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class WhatsNewNotesInvalid with DiagnosticableTreeMixin implements WhatsNewNotesResult {
  const WhatsNewNotesInvalid({required this.version, required this.message});
  

@override final  String version;
 final  String message;

/// Create a copy of WhatsNewNotesResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhatsNewNotesInvalidCopyWith<WhatsNewNotesInvalid> get copyWith => _$WhatsNewNotesInvalidCopyWithImpl<WhatsNewNotesInvalid>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'WhatsNewNotesResult.invalid'))
    ..add(DiagnosticsProperty('version', version))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WhatsNewNotesInvalid&&(identical(other.version, version) || other.version == version)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,version,message);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'WhatsNewNotesResult.invalid(version: $version, message: $message)';
}


}

/// @nodoc
abstract mixin class $WhatsNewNotesInvalidCopyWith<$Res> implements $WhatsNewNotesResultCopyWith<$Res> {
  factory $WhatsNewNotesInvalidCopyWith(WhatsNewNotesInvalid value, $Res Function(WhatsNewNotesInvalid) _then) = _$WhatsNewNotesInvalidCopyWithImpl;
@override @useResult
$Res call({
 String version, String message
});




}
/// @nodoc
class _$WhatsNewNotesInvalidCopyWithImpl<$Res>
    implements $WhatsNewNotesInvalidCopyWith<$Res> {
  _$WhatsNewNotesInvalidCopyWithImpl(this._self, this._then);

  final WhatsNewNotesInvalid _self;
  final $Res Function(WhatsNewNotesInvalid) _then;

/// Create a copy of WhatsNewNotesResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? message = null,}) {
  return _then(WhatsNewNotesInvalid(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
