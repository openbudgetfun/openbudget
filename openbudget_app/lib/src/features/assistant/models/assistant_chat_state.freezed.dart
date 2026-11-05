// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantChatState {

/// The conversation being shown, or null for a new one.
 String? get conversationId;/// Messages and proposals in the order they happened.
 List<AssistantTimelineItem> get items;/// Whether an existing conversation is being opened.
 bool get isLoadingHistory;/// Whether a turn is streaming right now.
 bool get isStreaming;/// The last failure, cleared when the next turn starts.
 AssistantFailure? get failure;
/// Create a copy of AssistantChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantChatStateCopyWith<AssistantChatState> get copyWith => _$AssistantChatStateCopyWithImpl<AssistantChatState>(this as AssistantChatState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssistantChatState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantChatState&&(identical(other.conversationId, _this.conversationId) || other.conversationId == _this.conversationId)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.isLoadingHistory, _this.isLoadingHistory) || other.isLoadingHistory == _this.isLoadingHistory)&&(identical(other.isStreaming, _this.isStreaming) || other.isStreaming == _this.isStreaming)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as AssistantChatState;
  return Object.hash(runtimeType,_this.conversationId,const DeepCollectionEquality().hash(_this.items),_this.isLoadingHistory,_this.isStreaming,_this.failure);
}

@override
String toString() {
  final _this = this as AssistantChatState;
  return 'AssistantChatState(conversationId: ${_this.conversationId}, items: ${_this.items}, isLoadingHistory: ${_this.isLoadingHistory}, isStreaming: ${_this.isStreaming}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $AssistantChatStateCopyWith<$Res>  {
  factory $AssistantChatStateCopyWith(AssistantChatState value, $Res Function(AssistantChatState) _then) = _$AssistantChatStateCopyWithImpl;
@useResult
$Res call({
 String? conversationId, List<AssistantTimelineItem> items, bool isLoadingHistory, bool isStreaming, AssistantFailure? failure
});


$AssistantFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$AssistantChatStateCopyWithImpl<$Res>
    implements $AssistantChatStateCopyWith<$Res> {
  _$AssistantChatStateCopyWithImpl(this._self, this._then);

  final AssistantChatState _self;
  final $Res Function(AssistantChatState) _then;

/// Create a copy of AssistantChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = freezed,Object? items = null,Object? isLoadingHistory = null,Object? isStreaming = null,Object? failure = freezed,}) {
  return _then(AssistantChatState(
conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AssistantTimelineItem>,isLoadingHistory: null == isLoadingHistory ? _self.isLoadingHistory : isLoadingHistory // ignore: cast_nullable_to_non_nullable
as bool,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AssistantFailure?,
  ));
}
/// Create a copy of AssistantChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssistantFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AssistantFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}


/// Adds pattern-matching-related methods to [AssistantChatState].
extension AssistantChatStatePatterns on AssistantChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantChatState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantChatState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantChatState value)  $default,){
final _that = this;
switch (_that) {
case _AssistantChatState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantChatState value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantChatState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? conversationId,  List<AssistantTimelineItem> items,  bool isLoadingHistory,  bool isStreaming,  AssistantFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantChatState() when $default != null:
return $default(_that.conversationId,_that.items,_that.isLoadingHistory,_that.isStreaming,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? conversationId,  List<AssistantTimelineItem> items,  bool isLoadingHistory,  bool isStreaming,  AssistantFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _AssistantChatState():
return $default(_that.conversationId,_that.items,_that.isLoadingHistory,_that.isStreaming,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? conversationId,  List<AssistantTimelineItem> items,  bool isLoadingHistory,  bool isStreaming,  AssistantFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _AssistantChatState() when $default != null:
return $default(_that.conversationId,_that.items,_that.isLoadingHistory,_that.isStreaming,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantChatState implements AssistantChatState {
  const _AssistantChatState({this.conversationId,  List<AssistantTimelineItem> items = const [], this.isLoadingHistory = false, this.isStreaming = false, this.failure}): _items = items;
  

/// The conversation being shown, or null for a new one.
@override final  String? conversationId;
/// Messages and proposals in the order they happened.
 final  List<AssistantTimelineItem> _items;
/// Messages and proposals in the order they happened.
@override@JsonKey() List<AssistantTimelineItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// Whether an existing conversation is being opened.
@override@JsonKey() final  bool isLoadingHistory;
/// Whether a turn is streaming right now.
@override@JsonKey() final  bool isStreaming;
/// The last failure, cleared when the next turn starts.
@override final  AssistantFailure? failure;

/// Create a copy of AssistantChatState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantChatStateCopyWith<_AssistantChatState> get copyWith => __$AssistantChatStateCopyWithImpl<_AssistantChatState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantChatState&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.isLoadingHistory, isLoadingHistory) || other.isLoadingHistory == isLoadingHistory)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,conversationId,const DeepCollectionEquality().hash(_items),isLoadingHistory,isStreaming,failure);
}

@override
String toString() {
    return 'AssistantChatState(conversationId: $conversationId, items: $items, isLoadingHistory: $isLoadingHistory, isStreaming: $isStreaming, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$AssistantChatStateCopyWith<$Res> implements $AssistantChatStateCopyWith<$Res> {
  factory _$AssistantChatStateCopyWith(_AssistantChatState value, $Res Function(_AssistantChatState) _then) = __$AssistantChatStateCopyWithImpl;
@override @useResult
$Res call({
 String? conversationId, List<AssistantTimelineItem> items, bool isLoadingHistory, bool isStreaming, AssistantFailure? failure
});


@override $AssistantFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$AssistantChatStateCopyWithImpl<$Res>
    implements _$AssistantChatStateCopyWith<$Res> {
  __$AssistantChatStateCopyWithImpl(this._self, this._then);

  final _AssistantChatState _self;
  final $Res Function(_AssistantChatState) _then;

/// Create a copy of AssistantChatState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = freezed,Object? items = null,Object? isLoadingHistory = null,Object? isStreaming = null,Object? failure = freezed,}) {
  return _then(_AssistantChatState(
conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AssistantTimelineItem>,isLoadingHistory: null == isLoadingHistory ? _self.isLoadingHistory : isLoadingHistory // ignore: cast_nullable_to_non_nullable
as bool,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AssistantFailure?,
  ));
}

/// Create a copy of AssistantChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssistantFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AssistantFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
