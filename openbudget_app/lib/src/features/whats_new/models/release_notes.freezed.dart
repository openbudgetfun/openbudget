// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_notes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseNotes {

 String get title; List<String> get summary; List<ReleaseNotesSection> get sections;
/// Create a copy of ReleaseNotes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseNotesCopyWith<ReleaseNotes> get copyWith => _$ReleaseNotesCopyWithImpl<ReleaseNotes>(this as ReleaseNotes, _$identity);

  /// Serializes this ReleaseNotes to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReleaseNotes;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseNotes&&(identical(other.title, _this.title) || other.title == _this.title)&&const DeepCollectionEquality().equals(other.summary, _this.summary)&&const DeepCollectionEquality().equals(other.sections, _this.sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReleaseNotes;
  return Object.hash(runtimeType,_this.title,const DeepCollectionEquality().hash(_this.summary),const DeepCollectionEquality().hash(_this.sections));
}

@override
String toString() {
  final _this = this as ReleaseNotes;
  return 'ReleaseNotes(title: ${_this.title}, summary: ${_this.summary}, sections: ${_this.sections})';
}


}

/// @nodoc
abstract mixin class $ReleaseNotesCopyWith<$Res>  {
  factory $ReleaseNotesCopyWith(ReleaseNotes value, $Res Function(ReleaseNotes) _then) = _$ReleaseNotesCopyWithImpl;
@useResult
$Res call({
 String title, List<String> summary, List<ReleaseNotesSection> sections
});




}
/// @nodoc
class _$ReleaseNotesCopyWithImpl<$Res>
    implements $ReleaseNotesCopyWith<$Res> {
  _$ReleaseNotesCopyWithImpl(this._self, this._then);

  final ReleaseNotes _self;
  final $Res Function(ReleaseNotes) _then;

/// Create a copy of ReleaseNotes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? summary = null,Object? sections = null,}) {
  return _then(ReleaseNotes(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as List<String>,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<ReleaseNotesSection>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseNotes].
extension ReleaseNotesPatterns on ReleaseNotes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseNotes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseNotes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseNotes value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseNotes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseNotes value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseNotes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<String> summary,  List<ReleaseNotesSection> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseNotes() when $default != null:
return $default(_that.title,_that.summary,_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<String> summary,  List<ReleaseNotesSection> sections)  $default,) {final _that = this;
switch (_that) {
case _ReleaseNotes():
return $default(_that.title,_that.summary,_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<String> summary,  List<ReleaseNotesSection> sections)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseNotes() when $default != null:
return $default(_that.title,_that.summary,_that.sections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseNotes implements ReleaseNotes {
  const _ReleaseNotes({required this.title,  List<String> summary = const <String>[],  List<ReleaseNotesSection> sections = const <ReleaseNotesSection>[]}): _summary = summary,_sections = sections;
  factory _ReleaseNotes.fromJson(Map<String, dynamic> json) => _$ReleaseNotesFromJson(json);

@override final  String title;
 final  List<String> _summary;
@override@JsonKey() List<String> get summary {
  if (_summary is EqualUnmodifiableListView) return _summary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_summary);
}

 final  List<ReleaseNotesSection> _sections;
@override@JsonKey() List<ReleaseNotesSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of ReleaseNotes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseNotesCopyWith<_ReleaseNotes> get copyWith => __$ReleaseNotesCopyWithImpl<_ReleaseNotes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseNotesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseNotes&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.summary, _summary)&&const DeepCollectionEquality().equals(other.sections, _sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_summary),const DeepCollectionEquality().hash(_sections));
}

@override
String toString() {
    return 'ReleaseNotes(title: $title, summary: $summary, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$ReleaseNotesCopyWith<$Res> implements $ReleaseNotesCopyWith<$Res> {
  factory _$ReleaseNotesCopyWith(_ReleaseNotes value, $Res Function(_ReleaseNotes) _then) = __$ReleaseNotesCopyWithImpl;
@override @useResult
$Res call({
 String title, List<String> summary, List<ReleaseNotesSection> sections
});




}
/// @nodoc
class __$ReleaseNotesCopyWithImpl<$Res>
    implements _$ReleaseNotesCopyWith<$Res> {
  __$ReleaseNotesCopyWithImpl(this._self, this._then);

  final _ReleaseNotes _self;
  final $Res Function(_ReleaseNotes) _then;

/// Create a copy of ReleaseNotes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? summary = null,Object? sections = null,}) {
  return _then(_ReleaseNotes(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self._summary : summary // ignore: cast_nullable_to_non_nullable
as List<String>,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<ReleaseNotesSection>,
  ));
}


}


/// @nodoc
mixin _$ReleaseNotesSection {

 String get title; bool get collapsed; List<ReleaseNotesEntry> get entries;
/// Create a copy of ReleaseNotesSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseNotesSectionCopyWith<ReleaseNotesSection> get copyWith => _$ReleaseNotesSectionCopyWithImpl<ReleaseNotesSection>(this as ReleaseNotesSection, _$identity);

  /// Serializes this ReleaseNotesSection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReleaseNotesSection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseNotesSection&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.collapsed, _this.collapsed) || other.collapsed == _this.collapsed)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReleaseNotesSection;
  return Object.hash(runtimeType,_this.title,_this.collapsed,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as ReleaseNotesSection;
  return 'ReleaseNotesSection(title: ${_this.title}, collapsed: ${_this.collapsed}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $ReleaseNotesSectionCopyWith<$Res>  {
  factory $ReleaseNotesSectionCopyWith(ReleaseNotesSection value, $Res Function(ReleaseNotesSection) _then) = _$ReleaseNotesSectionCopyWithImpl;
@useResult
$Res call({
 String title, bool collapsed, List<ReleaseNotesEntry> entries
});




}
/// @nodoc
class _$ReleaseNotesSectionCopyWithImpl<$Res>
    implements $ReleaseNotesSectionCopyWith<$Res> {
  _$ReleaseNotesSectionCopyWithImpl(this._self, this._then);

  final ReleaseNotesSection _self;
  final $Res Function(ReleaseNotesSection) _then;

/// Create a copy of ReleaseNotesSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? collapsed = null,Object? entries = null,}) {
  return _then(ReleaseNotesSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,collapsed: null == collapsed ? _self.collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<ReleaseNotesEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseNotesSection].
extension ReleaseNotesSectionPatterns on ReleaseNotesSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseNotesSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseNotesSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseNotesSection value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseNotesSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseNotesSection value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseNotesSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  bool collapsed,  List<ReleaseNotesEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseNotesSection() when $default != null:
return $default(_that.title,_that.collapsed,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  bool collapsed,  List<ReleaseNotesEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _ReleaseNotesSection():
return $default(_that.title,_that.collapsed,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  bool collapsed,  List<ReleaseNotesEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseNotesSection() when $default != null:
return $default(_that.title,_that.collapsed,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseNotesSection implements ReleaseNotesSection {
  const _ReleaseNotesSection({required this.title, this.collapsed = false,  List<ReleaseNotesEntry> entries = const <ReleaseNotesEntry>[]}): _entries = entries;
  factory _ReleaseNotesSection.fromJson(Map<String, dynamic> json) => _$ReleaseNotesSectionFromJson(json);

@override final  String title;
@override@JsonKey() final  bool collapsed;
 final  List<ReleaseNotesEntry> _entries;
@override@JsonKey() List<ReleaseNotesEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of ReleaseNotesSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseNotesSectionCopyWith<_ReleaseNotesSection> get copyWith => __$ReleaseNotesSectionCopyWithImpl<_ReleaseNotesSection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseNotesSectionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseNotesSection&&(identical(other.title, title) || other.title == title)&&(identical(other.collapsed, collapsed) || other.collapsed == collapsed)&&const DeepCollectionEquality().equals(other.entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,collapsed,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'ReleaseNotesSection(title: $title, collapsed: $collapsed, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$ReleaseNotesSectionCopyWith<$Res> implements $ReleaseNotesSectionCopyWith<$Res> {
  factory _$ReleaseNotesSectionCopyWith(_ReleaseNotesSection value, $Res Function(_ReleaseNotesSection) _then) = __$ReleaseNotesSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, bool collapsed, List<ReleaseNotesEntry> entries
});




}
/// @nodoc
class __$ReleaseNotesSectionCopyWithImpl<$Res>
    implements _$ReleaseNotesSectionCopyWith<$Res> {
  __$ReleaseNotesSectionCopyWithImpl(this._self, this._then);

  final _ReleaseNotesSection _self;
  final $Res Function(_ReleaseNotesSection) _then;

/// Create a copy of ReleaseNotesSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? collapsed = null,Object? entries = null,}) {
  return _then(_ReleaseNotesSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,collapsed: null == collapsed ? _self.collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<ReleaseNotesEntry>,
  ));
}


}


/// @nodoc
mixin _$ReleaseNotesEntry {

 String get summary;@JsonKey(name: 'details_markdown') String get detailsMarkdown;@JsonKey(name: 'change_type') String? get changeType;
/// Create a copy of ReleaseNotesEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseNotesEntryCopyWith<ReleaseNotesEntry> get copyWith => _$ReleaseNotesEntryCopyWithImpl<ReleaseNotesEntry>(this as ReleaseNotesEntry, _$identity);

  /// Serializes this ReleaseNotesEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReleaseNotesEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseNotesEntry&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.detailsMarkdown, _this.detailsMarkdown) || other.detailsMarkdown == _this.detailsMarkdown)&&(identical(other.changeType, _this.changeType) || other.changeType == _this.changeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReleaseNotesEntry;
  return Object.hash(runtimeType,_this.summary,_this.detailsMarkdown,_this.changeType);
}

@override
String toString() {
  final _this = this as ReleaseNotesEntry;
  return 'ReleaseNotesEntry(summary: ${_this.summary}, detailsMarkdown: ${_this.detailsMarkdown}, changeType: ${_this.changeType})';
}


}

/// @nodoc
abstract mixin class $ReleaseNotesEntryCopyWith<$Res>  {
  factory $ReleaseNotesEntryCopyWith(ReleaseNotesEntry value, $Res Function(ReleaseNotesEntry) _then) = _$ReleaseNotesEntryCopyWithImpl;
@useResult
$Res call({
 String summary,@JsonKey(name: 'details_markdown') String detailsMarkdown,@JsonKey(name: 'change_type') String? changeType
});




}
/// @nodoc
class _$ReleaseNotesEntryCopyWithImpl<$Res>
    implements $ReleaseNotesEntryCopyWith<$Res> {
  _$ReleaseNotesEntryCopyWithImpl(this._self, this._then);

  final ReleaseNotesEntry _self;
  final $Res Function(ReleaseNotesEntry) _then;

/// Create a copy of ReleaseNotesEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? detailsMarkdown = null,Object? changeType = freezed,}) {
  return _then(ReleaseNotesEntry(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,detailsMarkdown: null == detailsMarkdown ? _self.detailsMarkdown : detailsMarkdown // ignore: cast_nullable_to_non_nullable
as String,changeType: freezed == changeType ? _self.changeType : changeType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseNotesEntry].
extension ReleaseNotesEntryPatterns on ReleaseNotesEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseNotesEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseNotesEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseNotesEntry value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseNotesEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseNotesEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseNotesEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String summary, @JsonKey(name: 'details_markdown')  String detailsMarkdown, @JsonKey(name: 'change_type')  String? changeType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseNotesEntry() when $default != null:
return $default(_that.summary,_that.detailsMarkdown,_that.changeType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String summary, @JsonKey(name: 'details_markdown')  String detailsMarkdown, @JsonKey(name: 'change_type')  String? changeType)  $default,) {final _that = this;
switch (_that) {
case _ReleaseNotesEntry():
return $default(_that.summary,_that.detailsMarkdown,_that.changeType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String summary, @JsonKey(name: 'details_markdown')  String detailsMarkdown, @JsonKey(name: 'change_type')  String? changeType)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseNotesEntry() when $default != null:
return $default(_that.summary,_that.detailsMarkdown,_that.changeType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseNotesEntry implements ReleaseNotesEntry {
  const _ReleaseNotesEntry({required this.summary, @JsonKey(name: 'details_markdown') this.detailsMarkdown = '', @JsonKey(name: 'change_type') this.changeType});
  factory _ReleaseNotesEntry.fromJson(Map<String, dynamic> json) => _$ReleaseNotesEntryFromJson(json);

@override final  String summary;
@override@JsonKey(name: 'details_markdown') final  String detailsMarkdown;
@override@JsonKey(name: 'change_type') final  String? changeType;

/// Create a copy of ReleaseNotesEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseNotesEntryCopyWith<_ReleaseNotesEntry> get copyWith => __$ReleaseNotesEntryCopyWithImpl<_ReleaseNotesEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseNotesEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseNotesEntry&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.detailsMarkdown, detailsMarkdown) || other.detailsMarkdown == detailsMarkdown)&&(identical(other.changeType, changeType) || other.changeType == changeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,summary,detailsMarkdown,changeType);
}

@override
String toString() {
    return 'ReleaseNotesEntry(summary: $summary, detailsMarkdown: $detailsMarkdown, changeType: $changeType)';
}


}

/// @nodoc
abstract mixin class _$ReleaseNotesEntryCopyWith<$Res> implements $ReleaseNotesEntryCopyWith<$Res> {
  factory _$ReleaseNotesEntryCopyWith(_ReleaseNotesEntry value, $Res Function(_ReleaseNotesEntry) _then) = __$ReleaseNotesEntryCopyWithImpl;
@override @useResult
$Res call({
 String summary,@JsonKey(name: 'details_markdown') String detailsMarkdown,@JsonKey(name: 'change_type') String? changeType
});




}
/// @nodoc
class __$ReleaseNotesEntryCopyWithImpl<$Res>
    implements _$ReleaseNotesEntryCopyWith<$Res> {
  __$ReleaseNotesEntryCopyWithImpl(this._self, this._then);

  final _ReleaseNotesEntry _self;
  final $Res Function(_ReleaseNotesEntry) _then;

/// Create a copy of ReleaseNotesEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? detailsMarkdown = null,Object? changeType = freezed,}) {
  return _then(_ReleaseNotesEntry(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,detailsMarkdown: null == detailsMarkdown ? _self.detailsMarkdown : detailsMarkdown // ignore: cast_nullable_to_non_nullable
as String,changeType: freezed == changeType ? _self.changeType : changeType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
