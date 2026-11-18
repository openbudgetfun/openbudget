// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantSource {

/// The key the reply cites it by, as in `[^key]`.
 String get key;/// What the source is called.
 String get title;/// Where the source lives.
 String get url;/// Who publishes it: the source's website without `www.`.
 String get authority;/// How firmly the source backs the rule, or null for a grade this app
/// does not know yet.
 SourceGrade? get grade;/// Whether the source describes a rule that is announced but not yet law.
 bool get announced;/// When the source was last checked.
 DateTime? get verifiedOn;
/// Create a copy of AssistantSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantSourceCopyWith<AssistantSource> get copyWith => _$AssistantSourceCopyWithImpl<AssistantSource>(this as AssistantSource, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssistantSource;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantSource&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.authority, _this.authority) || other.authority == _this.authority)&&(identical(other.grade, _this.grade) || other.grade == _this.grade)&&(identical(other.announced, _this.announced) || other.announced == _this.announced)&&(identical(other.verifiedOn, _this.verifiedOn) || other.verifiedOn == _this.verifiedOn));
}


@override
int get hashCode {
  final _this = this as AssistantSource;
  return Object.hash(runtimeType,_this.key,_this.title,_this.url,_this.authority,_this.grade,_this.announced,_this.verifiedOn);
}

@override
String toString() {
  final _this = this as AssistantSource;
  return 'AssistantSource(key: ${_this.key}, title: ${_this.title}, url: ${_this.url}, authority: ${_this.authority}, grade: ${_this.grade}, announced: ${_this.announced}, verifiedOn: ${_this.verifiedOn})';
}


}

/// @nodoc
abstract mixin class $AssistantSourceCopyWith<$Res>  {
  factory $AssistantSourceCopyWith(AssistantSource value, $Res Function(AssistantSource) _then) = _$AssistantSourceCopyWithImpl;
@useResult
$Res call({
 String key, String title, String url, String authority, SourceGrade? grade, bool announced, DateTime? verifiedOn
});




}
/// @nodoc
class _$AssistantSourceCopyWithImpl<$Res>
    implements $AssistantSourceCopyWith<$Res> {
  _$AssistantSourceCopyWithImpl(this._self, this._then);

  final AssistantSource _self;
  final $Res Function(AssistantSource) _then;

/// Create a copy of AssistantSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? title = null,Object? url = null,Object? authority = null,Object? grade = freezed,Object? announced = null,Object? verifiedOn = freezed,}) {
  return _then(AssistantSource(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as String,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as SourceGrade?,announced: null == announced ? _self.announced : announced // ignore: cast_nullable_to_non_nullable
as bool,verifiedOn: freezed == verifiedOn ? _self.verifiedOn : verifiedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssistantSource].
extension AssistantSourcePatterns on AssistantSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantSource value)  $default,){
final _that = this;
switch (_that) {
case _AssistantSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantSource value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String title,  String url,  String authority,  SourceGrade? grade,  bool announced,  DateTime? verifiedOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantSource() when $default != null:
return $default(_that.key,_that.title,_that.url,_that.authority,_that.grade,_that.announced,_that.verifiedOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String title,  String url,  String authority,  SourceGrade? grade,  bool announced,  DateTime? verifiedOn)  $default,) {final _that = this;
switch (_that) {
case _AssistantSource():
return $default(_that.key,_that.title,_that.url,_that.authority,_that.grade,_that.announced,_that.verifiedOn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String title,  String url,  String authority,  SourceGrade? grade,  bool announced,  DateTime? verifiedOn)?  $default,) {final _that = this;
switch (_that) {
case _AssistantSource() when $default != null:
return $default(_that.key,_that.title,_that.url,_that.authority,_that.grade,_that.announced,_that.verifiedOn);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantSource implements AssistantSource {
  const _AssistantSource({required this.key, required this.title, required this.url, required this.authority, required this.grade, required this.announced, this.verifiedOn});
  

/// The key the reply cites it by, as in `[^key]`.
@override final  String key;
/// What the source is called.
@override final  String title;
/// Where the source lives.
@override final  String url;
/// Who publishes it: the source's website without `www.`.
@override final  String authority;
/// How firmly the source backs the rule, or null for a grade this app
/// does not know yet.
@override final  SourceGrade? grade;
/// Whether the source describes a rule that is announced but not yet law.
@override final  bool announced;
/// When the source was last checked.
@override final  DateTime? verifiedOn;

/// Create a copy of AssistantSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantSourceCopyWith<_AssistantSource> get copyWith => __$AssistantSourceCopyWithImpl<_AssistantSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantSource&&(identical(other.key, key) || other.key == key)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.authority, authority) || other.authority == authority)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.announced, announced) || other.announced == announced)&&(identical(other.verifiedOn, verifiedOn) || other.verifiedOn == verifiedOn));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,title,url,authority,grade,announced,verifiedOn);
}

@override
String toString() {
    return 'AssistantSource(key: $key, title: $title, url: $url, authority: $authority, grade: $grade, announced: $announced, verifiedOn: $verifiedOn)';
}


}

/// @nodoc
abstract mixin class _$AssistantSourceCopyWith<$Res> implements $AssistantSourceCopyWith<$Res> {
  factory _$AssistantSourceCopyWith(_AssistantSource value, $Res Function(_AssistantSource) _then) = __$AssistantSourceCopyWithImpl;
@override @useResult
$Res call({
 String key, String title, String url, String authority, SourceGrade? grade, bool announced, DateTime? verifiedOn
});




}
/// @nodoc
class __$AssistantSourceCopyWithImpl<$Res>
    implements _$AssistantSourceCopyWith<$Res> {
  __$AssistantSourceCopyWithImpl(this._self, this._then);

  final _AssistantSource _self;
  final $Res Function(_AssistantSource) _then;

/// Create a copy of AssistantSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? title = null,Object? url = null,Object? authority = null,Object? grade = freezed,Object? announced = null,Object? verifiedOn = freezed,}) {
  return _then(_AssistantSource(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,authority: null == authority ? _self.authority : authority // ignore: cast_nullable_to_non_nullable
as String,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as SourceGrade?,announced: null == announced ? _self.announced : announced // ignore: cast_nullable_to_non_nullable
as bool,verifiedOn: freezed == verifiedOn ? _self.verifiedOn : verifiedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
