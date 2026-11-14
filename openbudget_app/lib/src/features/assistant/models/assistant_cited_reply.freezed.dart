// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_cited_reply.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantCitedReply {

/// The reply in reading order.
 List<AssistantReplySegment> get segments;/// Every source the reply cites, in number order.
 List<AssistantNumberedSource> get sources;
/// Create a copy of AssistantCitedReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantCitedReplyCopyWith<AssistantCitedReply> get copyWith => _$AssistantCitedReplyCopyWithImpl<AssistantCitedReply>(this as AssistantCitedReply, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssistantCitedReply;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantCitedReply&&const DeepCollectionEquality().equals(other.segments, _this.segments)&&const DeepCollectionEquality().equals(other.sources, _this.sources));
}


@override
int get hashCode {
  final _this = this as AssistantCitedReply;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.segments),const DeepCollectionEquality().hash(_this.sources));
}

@override
String toString() {
  final _this = this as AssistantCitedReply;
  return 'AssistantCitedReply(segments: ${_this.segments}, sources: ${_this.sources})';
}


}

/// @nodoc
abstract mixin class $AssistantCitedReplyCopyWith<$Res>  {
  factory $AssistantCitedReplyCopyWith(AssistantCitedReply value, $Res Function(AssistantCitedReply) _then) = _$AssistantCitedReplyCopyWithImpl;
@useResult
$Res call({
 List<AssistantReplySegment> segments, List<AssistantNumberedSource> sources
});




}
/// @nodoc
class _$AssistantCitedReplyCopyWithImpl<$Res>
    implements $AssistantCitedReplyCopyWith<$Res> {
  _$AssistantCitedReplyCopyWithImpl(this._self, this._then);

  final AssistantCitedReply _self;
  final $Res Function(AssistantCitedReply) _then;

/// Create a copy of AssistantCitedReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? segments = null,Object? sources = null,}) {
  return _then(AssistantCitedReply(
segments: null == segments ? _self.segments : segments // ignore: cast_nullable_to_non_nullable
as List<AssistantReplySegment>,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<AssistantNumberedSource>,
  ));
}

}


/// Adds pattern-matching-related methods to [AssistantCitedReply].
extension AssistantCitedReplyPatterns on AssistantCitedReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantCitedReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantCitedReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantCitedReply value)  $default,){
final _that = this;
switch (_that) {
case _AssistantCitedReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantCitedReply value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantCitedReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AssistantReplySegment> segments,  List<AssistantNumberedSource> sources)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantCitedReply() when $default != null:
return $default(_that.segments,_that.sources);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AssistantReplySegment> segments,  List<AssistantNumberedSource> sources)  $default,) {final _that = this;
switch (_that) {
case _AssistantCitedReply():
return $default(_that.segments,_that.sources);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AssistantReplySegment> segments,  List<AssistantNumberedSource> sources)?  $default,) {final _that = this;
switch (_that) {
case _AssistantCitedReply() when $default != null:
return $default(_that.segments,_that.sources);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantCitedReply extends AssistantCitedReply {
  const _AssistantCitedReply({required  List<AssistantReplySegment> segments, required  List<AssistantNumberedSource> sources}): _segments = segments,_sources = sources,super._();
  

/// The reply in reading order.
 final  List<AssistantReplySegment> _segments;
/// The reply in reading order.
@override List<AssistantReplySegment> get segments {
  if (_segments is EqualUnmodifiableListView) return _segments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_segments);
}

/// Every source the reply cites, in number order.
 final  List<AssistantNumberedSource> _sources;
/// Every source the reply cites, in number order.
@override List<AssistantNumberedSource> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}


/// Create a copy of AssistantCitedReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantCitedReplyCopyWith<_AssistantCitedReply> get copyWith => __$AssistantCitedReplyCopyWithImpl<_AssistantCitedReply>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantCitedReply&&const DeepCollectionEquality().equals(other.segments, _segments)&&const DeepCollectionEquality().equals(other.sources, _sources));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_segments),const DeepCollectionEquality().hash(_sources));
}

@override
String toString() {
    return 'AssistantCitedReply(segments: $segments, sources: $sources)';
}


}

/// @nodoc
abstract mixin class _$AssistantCitedReplyCopyWith<$Res> implements $AssistantCitedReplyCopyWith<$Res> {
  factory _$AssistantCitedReplyCopyWith(_AssistantCitedReply value, $Res Function(_AssistantCitedReply) _then) = __$AssistantCitedReplyCopyWithImpl;
@override @useResult
$Res call({
 List<AssistantReplySegment> segments, List<AssistantNumberedSource> sources
});




}
/// @nodoc
class __$AssistantCitedReplyCopyWithImpl<$Res>
    implements _$AssistantCitedReplyCopyWith<$Res> {
  __$AssistantCitedReplyCopyWithImpl(this._self, this._then);

  final _AssistantCitedReply _self;
  final $Res Function(_AssistantCitedReply) _then;

/// Create a copy of AssistantCitedReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? segments = null,Object? sources = null,}) {
  return _then(_AssistantCitedReply(
segments: null == segments ? _self._segments : segments // ignore: cast_nullable_to_non_nullable
as List<AssistantReplySegment>,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<AssistantNumberedSource>,
  ));
}


}

/// @nodoc
mixin _$AssistantReplySegment {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantReplySegment);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AssistantReplySegment()';
}


}

/// @nodoc
class $AssistantReplySegmentCopyWith<$Res>  {
$AssistantReplySegmentCopyWith(AssistantReplySegment _, $Res Function(AssistantReplySegment) __);
}


/// Adds pattern-matching-related methods to [AssistantReplySegment].
extension AssistantReplySegmentPatterns on AssistantReplySegment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AssistantReplyText value)?  text,TResult Function( AssistantReplyCitation value)?  citation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AssistantReplyText() when text != null:
return text(_that);case AssistantReplyCitation() when citation != null:
return citation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AssistantReplyText value)  text,required TResult Function( AssistantReplyCitation value)  citation,}){
final _that = this;
switch (_that) {
case AssistantReplyText():
return text(_that);case AssistantReplyCitation():
return citation(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AssistantReplyText value)?  text,TResult? Function( AssistantReplyCitation value)?  citation,}){
final _that = this;
switch (_that) {
case AssistantReplyText() when text != null:
return text(_that);case AssistantReplyCitation() when citation != null:
return citation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text)?  text,TResult Function( int number,  String key,  String title)?  citation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AssistantReplyText() when text != null:
return text(_that.text);case AssistantReplyCitation() when citation != null:
return citation(_that.number,_that.key,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text)  text,required TResult Function( int number,  String key,  String title)  citation,}) {final _that = this;
switch (_that) {
case AssistantReplyText():
return text(_that.text);case AssistantReplyCitation():
return citation(_that.number,_that.key,_that.title);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text)?  text,TResult? Function( int number,  String key,  String title)?  citation,}) {final _that = this;
switch (_that) {
case AssistantReplyText() when text != null:
return text(_that.text);case AssistantReplyCitation() when citation != null:
return citation(_that.number,_that.key,_that.title);case _:
  return null;

}
}

}

/// @nodoc


class AssistantReplyText implements AssistantReplySegment {
  const AssistantReplyText(this.text);
  

 final  String text;

/// Create a copy of AssistantReplySegment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantReplyTextCopyWith<AssistantReplyText> get copyWith => _$AssistantReplyTextCopyWithImpl<AssistantReplyText>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantReplyText&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text);
}

@override
String toString() {
    return 'AssistantReplySegment.text(text: $text)';
}


}

/// @nodoc
abstract mixin class $AssistantReplyTextCopyWith<$Res> implements $AssistantReplySegmentCopyWith<$Res> {
  factory $AssistantReplyTextCopyWith(AssistantReplyText value, $Res Function(AssistantReplyText) _then) = _$AssistantReplyTextCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$AssistantReplyTextCopyWithImpl<$Res>
    implements $AssistantReplyTextCopyWith<$Res> {
  _$AssistantReplyTextCopyWithImpl(this._self, this._then);

  final AssistantReplyText _self;
  final $Res Function(AssistantReplyText) _then;

/// Create a copy of AssistantReplySegment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(AssistantReplyText(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AssistantReplyCitation implements AssistantReplySegment {
  const AssistantReplyCitation({required this.number, required this.key, required this.title});
  

 final  int number;
 final  String key;
/// The title of the key's first source, for the chip's spoken label.
 final  String title;

/// Create a copy of AssistantReplySegment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantReplyCitationCopyWith<AssistantReplyCitation> get copyWith => _$AssistantReplyCitationCopyWithImpl<AssistantReplyCitation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantReplyCitation&&(identical(other.number, number) || other.number == number)&&(identical(other.key, key) || other.key == key)&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode {
    return Object.hash(runtimeType,number,key,title);
}

@override
String toString() {
    return 'AssistantReplySegment.citation(number: $number, key: $key, title: $title)';
}


}

/// @nodoc
abstract mixin class $AssistantReplyCitationCopyWith<$Res> implements $AssistantReplySegmentCopyWith<$Res> {
  factory $AssistantReplyCitationCopyWith(AssistantReplyCitation value, $Res Function(AssistantReplyCitation) _then) = _$AssistantReplyCitationCopyWithImpl;
@useResult
$Res call({
 int number, String key, String title
});




}
/// @nodoc
class _$AssistantReplyCitationCopyWithImpl<$Res>
    implements $AssistantReplyCitationCopyWith<$Res> {
  _$AssistantReplyCitationCopyWithImpl(this._self, this._then);

  final AssistantReplyCitation _self;
  final $Res Function(AssistantReplyCitation) _then;

/// Create a copy of AssistantReplySegment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? number = null,Object? key = null,Object? title = null,}) {
  return _then(AssistantReplyCitation(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AssistantNumberedSource {

 int get number; AssistantSource get source;
/// Create a copy of AssistantNumberedSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantNumberedSourceCopyWith<AssistantNumberedSource> get copyWith => _$AssistantNumberedSourceCopyWithImpl<AssistantNumberedSource>(this as AssistantNumberedSource, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssistantNumberedSource;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantNumberedSource&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.source, _this.source) || other.source == _this.source));
}


@override
int get hashCode {
  final _this = this as AssistantNumberedSource;
  return Object.hash(runtimeType,_this.number,_this.source);
}

@override
String toString() {
  final _this = this as AssistantNumberedSource;
  return 'AssistantNumberedSource(number: ${_this.number}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $AssistantNumberedSourceCopyWith<$Res>  {
  factory $AssistantNumberedSourceCopyWith(AssistantNumberedSource value, $Res Function(AssistantNumberedSource) _then) = _$AssistantNumberedSourceCopyWithImpl;
@useResult
$Res call({
 int number, AssistantSource source
});


$AssistantSourceCopyWith<$Res> get source;

}
/// @nodoc
class _$AssistantNumberedSourceCopyWithImpl<$Res>
    implements $AssistantNumberedSourceCopyWith<$Res> {
  _$AssistantNumberedSourceCopyWithImpl(this._self, this._then);

  final AssistantNumberedSource _self;
  final $Res Function(AssistantNumberedSource) _then;

/// Create a copy of AssistantNumberedSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? source = null,}) {
  return _then(AssistantNumberedSource(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AssistantSource,
  ));
}
/// Create a copy of AssistantNumberedSource
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssistantSourceCopyWith<$Res> get source {
  
  return $AssistantSourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}


/// Adds pattern-matching-related methods to [AssistantNumberedSource].
extension AssistantNumberedSourcePatterns on AssistantNumberedSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantNumberedSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantNumberedSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantNumberedSource value)  $default,){
final _that = this;
switch (_that) {
case _AssistantNumberedSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantNumberedSource value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantNumberedSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  AssistantSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantNumberedSource() when $default != null:
return $default(_that.number,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  AssistantSource source)  $default,) {final _that = this;
switch (_that) {
case _AssistantNumberedSource():
return $default(_that.number,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  AssistantSource source)?  $default,) {final _that = this;
switch (_that) {
case _AssistantNumberedSource() when $default != null:
return $default(_that.number,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantNumberedSource implements AssistantNumberedSource {
  const _AssistantNumberedSource({required this.number, required this.source});
  

@override final  int number;
@override final  AssistantSource source;

/// Create a copy of AssistantNumberedSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantNumberedSourceCopyWith<_AssistantNumberedSource> get copyWith => __$AssistantNumberedSourceCopyWithImpl<_AssistantNumberedSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantNumberedSource&&(identical(other.number, number) || other.number == number)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode {
    return Object.hash(runtimeType,number,source);
}

@override
String toString() {
    return 'AssistantNumberedSource(number: $number, source: $source)';
}


}

/// @nodoc
abstract mixin class _$AssistantNumberedSourceCopyWith<$Res> implements $AssistantNumberedSourceCopyWith<$Res> {
  factory _$AssistantNumberedSourceCopyWith(_AssistantNumberedSource value, $Res Function(_AssistantNumberedSource) _then) = __$AssistantNumberedSourceCopyWithImpl;
@override @useResult
$Res call({
 int number, AssistantSource source
});


@override $AssistantSourceCopyWith<$Res> get source;

}
/// @nodoc
class __$AssistantNumberedSourceCopyWithImpl<$Res>
    implements _$AssistantNumberedSourceCopyWith<$Res> {
  __$AssistantNumberedSourceCopyWithImpl(this._self, this._then);

  final _AssistantNumberedSource _self;
  final $Res Function(_AssistantNumberedSource) _then;

/// Create a copy of AssistantNumberedSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? source = null,}) {
  return _then(_AssistantNumberedSource(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AssistantSource,
  ));
}

/// Create a copy of AssistantNumberedSource
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssistantSourceCopyWith<$Res> get source {
  
  return $AssistantSourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}

// dart format on
